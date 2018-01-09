
obj/user/init:     file format elf32-i386


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
  80002c:	e8 6f 03 00 00       	call   8003a0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  80003e:	b8 00 00 00 00       	mov    $0x0,%eax
	for (i = 0; i < n; i++)
  800043:	ba 00 00 00 00       	mov    $0x0,%edx
  800048:	eb 0c                	jmp    800056 <sum+0x23>
		tot ^= i * s[i];
  80004a:	0f be 0c 16          	movsbl (%esi,%edx,1),%ecx
  80004e:	0f af ca             	imul   %edx,%ecx
  800051:	31 c8                	xor    %ecx,%eax

int
sum(const char *s, int n)
{
	int i, tot = 0;
	for (i = 0; i < n; i++)
  800053:	83 c2 01             	add    $0x1,%edx
  800056:	39 da                	cmp    %ebx,%edx
  800058:	7c f0                	jl     80004a <sum+0x17>
		tot ^= i * s[i];
	return tot;
}
  80005a:	5b                   	pop    %ebx
  80005b:	5e                   	pop    %esi
  80005c:	5d                   	pop    %ebp
  80005d:	c3                   	ret    

0080005e <umain>:

void
umain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	57                   	push   %edi
  800062:	56                   	push   %esi
  800063:	53                   	push   %ebx
  800064:	81 ec 18 01 00 00    	sub    $0x118,%esp
  80006a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  80006d:	68 00 26 80 00       	push   $0x802600
  800072:	e8 62 04 00 00       	call   8004d9 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800077:	83 c4 08             	add    $0x8,%esp
  80007a:	68 70 17 00 00       	push   $0x1770
  80007f:	68 00 30 80 00       	push   $0x803000
  800084:	e8 aa ff ff ff       	call   800033 <sum>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  800091:	74 18                	je     8000ab <umain+0x4d>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  800093:	83 ec 04             	sub    $0x4,%esp
  800096:	68 9e 98 0f 00       	push   $0xf989e
  80009b:	50                   	push   %eax
  80009c:	68 c8 26 80 00       	push   $0x8026c8
  8000a1:	e8 33 04 00 00       	call   8004d9 <cprintf>
  8000a6:	83 c4 10             	add    $0x10,%esp
  8000a9:	eb 10                	jmp    8000bb <umain+0x5d>
			x, want);
	else
		cprintf("init: data seems okay\n");
  8000ab:	83 ec 0c             	sub    $0xc,%esp
  8000ae:	68 0f 26 80 00       	push   $0x80260f
  8000b3:	e8 21 04 00 00       	call   8004d9 <cprintf>
  8000b8:	83 c4 10             	add    $0x10,%esp
	if ((x = sum(bss, sizeof bss)) != 0)
  8000bb:	83 ec 08             	sub    $0x8,%esp
  8000be:	68 70 17 00 00       	push   $0x1770
  8000c3:	68 40 50 80 00       	push   $0x805040
  8000c8:	e8 66 ff ff ff       	call   800033 <sum>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	74 13                	je     8000e7 <umain+0x89>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	50                   	push   %eax
  8000d8:	68 04 27 80 00       	push   $0x802704
  8000dd:	e8 f7 03 00 00       	call   8004d9 <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb 10                	jmp    8000f7 <umain+0x99>
	else
		cprintf("init: bss seems okay\n");
  8000e7:	83 ec 0c             	sub    $0xc,%esp
  8000ea:	68 26 26 80 00       	push   $0x802626
  8000ef:	e8 e5 03 00 00       	call   8004d9 <cprintf>
  8000f4:	83 c4 10             	add    $0x10,%esp

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000f7:	83 ec 08             	sub    $0x8,%esp
  8000fa:	68 3c 26 80 00       	push   $0x80263c
  8000ff:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 72 09 00 00       	call   800a7d <strcat>
	for (i = 0; i < argc; i++) {
  80010b:	83 c4 10             	add    $0x10,%esp
  80010e:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  800113:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800119:	eb 2e                	jmp    800149 <umain+0xeb>
		strcat(args, " '");
  80011b:	83 ec 08             	sub    $0x8,%esp
  80011e:	68 48 26 80 00       	push   $0x802648
  800123:	56                   	push   %esi
  800124:	e8 54 09 00 00       	call   800a7d <strcat>
		strcat(args, argv[i]);
  800129:	83 c4 08             	add    $0x8,%esp
  80012c:	ff 34 9f             	pushl  (%edi,%ebx,4)
  80012f:	56                   	push   %esi
  800130:	e8 48 09 00 00       	call   800a7d <strcat>
		strcat(args, "'");
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	68 49 26 80 00       	push   $0x802649
  80013d:	56                   	push   %esi
  80013e:	e8 3a 09 00 00       	call   800a7d <strcat>
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
	for (i = 0; i < argc; i++) {
  800143:	83 c3 01             	add    $0x1,%ebx
  800146:	83 c4 10             	add    $0x10,%esp
  800149:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  80014c:	7c cd                	jl     80011b <umain+0xbd>
		strcat(args, " '");
		strcat(args, argv[i]);
		strcat(args, "'");
	}
	cprintf("%s\n", args);
  80014e:	83 ec 08             	sub    $0x8,%esp
  800151:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  800157:	50                   	push   %eax
  800158:	68 4b 26 80 00       	push   $0x80264b
  80015d:	e8 77 03 00 00       	call   8004d9 <cprintf>

	cprintf("init: running sh\n");
  800162:	c7 04 24 4f 26 80 00 	movl   $0x80264f,(%esp)
  800169:	e8 6b 03 00 00       	call   8004d9 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  80016e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800175:	e8 9c 10 00 00       	call   801216 <close>
	if ((r = opencons()) < 0)
  80017a:	e8 c7 01 00 00       	call   800346 <opencons>
  80017f:	83 c4 10             	add    $0x10,%esp
  800182:	85 c0                	test   %eax,%eax
  800184:	79 12                	jns    800198 <umain+0x13a>
		panic("opencons: %i", r);
  800186:	50                   	push   %eax
  800187:	68 61 26 80 00       	push   $0x802661
  80018c:	6a 37                	push   $0x37
  80018e:	68 6e 26 80 00       	push   $0x80266e
  800193:	e8 68 02 00 00       	call   800400 <_panic>
	if (r != 0)
  800198:	85 c0                	test   %eax,%eax
  80019a:	74 12                	je     8001ae <umain+0x150>
		panic("first opencons used fd %d", r);
  80019c:	50                   	push   %eax
  80019d:	68 7a 26 80 00       	push   $0x80267a
  8001a2:	6a 39                	push   $0x39
  8001a4:	68 6e 26 80 00       	push   $0x80266e
  8001a9:	e8 52 02 00 00       	call   800400 <_panic>
	if ((r = dup(0, 1)) < 0)
  8001ae:	83 ec 08             	sub    $0x8,%esp
  8001b1:	6a 01                	push   $0x1
  8001b3:	6a 00                	push   $0x0
  8001b5:	e8 ae 10 00 00       	call   801268 <dup>
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	79 12                	jns    8001d3 <umain+0x175>
		panic("dup: %i", r);
  8001c1:	50                   	push   %eax
  8001c2:	68 94 26 80 00       	push   $0x802694
  8001c7:	6a 3b                	push   $0x3b
  8001c9:	68 6e 26 80 00       	push   $0x80266e
  8001ce:	e8 2d 02 00 00       	call   800400 <_panic>
	while (1) {
		cprintf("init: starting sh\n");
  8001d3:	83 ec 0c             	sub    $0xc,%esp
  8001d6:	68 9c 26 80 00       	push   $0x80269c
  8001db:	e8 f9 02 00 00       	call   8004d9 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  8001e0:	83 c4 0c             	add    $0xc,%esp
  8001e3:	6a 00                	push   $0x0
  8001e5:	68 b0 26 80 00       	push   $0x8026b0
  8001ea:	68 af 26 80 00       	push   $0x8026af
  8001ef:	e8 e8 1b 00 00       	call   801ddc <spawnl>
		if (r < 0) {
  8001f4:	83 c4 10             	add    $0x10,%esp
  8001f7:	85 c0                	test   %eax,%eax
  8001f9:	79 13                	jns    80020e <umain+0x1b0>
			cprintf("init: spawn sh: %i\n", r);
  8001fb:	83 ec 08             	sub    $0x8,%esp
  8001fe:	50                   	push   %eax
  8001ff:	68 b3 26 80 00       	push   $0x8026b3
  800204:	e8 d0 02 00 00       	call   8004d9 <cprintf>
			continue;
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	eb c5                	jmp    8001d3 <umain+0x175>
		}
		wait(r);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	e8 8b 1f 00 00       	call   8021a2 <wait>
  800217:	83 c4 10             	add    $0x10,%esp
  80021a:	eb b7                	jmp    8001d3 <umain+0x175>

0080021c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80021f:	b8 00 00 00 00       	mov    $0x0,%eax
  800224:	5d                   	pop    %ebp
  800225:	c3                   	ret    

00800226 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800226:	55                   	push   %ebp
  800227:	89 e5                	mov    %esp,%ebp
  800229:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80022c:	68 33 27 80 00       	push   $0x802733
  800231:	ff 75 0c             	pushl  0xc(%ebp)
  800234:	e8 24 08 00 00       	call   800a5d <strcpy>
	return 0;
}
  800239:	b8 00 00 00 00       	mov    $0x0,%eax
  80023e:	c9                   	leave  
  80023f:	c3                   	ret    

00800240 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80024c:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800251:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800257:	eb 2e                	jmp    800287 <devcons_write+0x47>
		m = n - tot;
  800259:	8b 55 10             	mov    0x10(%ebp),%edx
  80025c:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  80025e:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800263:	83 fa 7f             	cmp    $0x7f,%edx
  800266:	77 02                	ja     80026a <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800268:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80026a:	83 ec 04             	sub    $0x4,%esp
  80026d:	56                   	push   %esi
  80026e:	03 45 0c             	add    0xc(%ebp),%eax
  800271:	50                   	push   %eax
  800272:	57                   	push   %edi
  800273:	e8 77 09 00 00       	call   800bef <memmove>
		sys_cputs(buf, m);
  800278:	83 c4 08             	add    $0x8,%esp
  80027b:	56                   	push   %esi
  80027c:	57                   	push   %edi
  80027d:	e8 29 0b 00 00       	call   800dab <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800282:	01 f3                	add    %esi,%ebx
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	89 d8                	mov    %ebx,%eax
  800289:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80028c:	72 cb                	jb     800259 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80028e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  80029c:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8002a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002a5:	75 07                	jne    8002ae <devcons_read+0x18>
  8002a7:	eb 28                	jmp    8002d1 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8002a9:	e8 9a 0b 00 00       	call   800e48 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8002ae:	e8 16 0b 00 00       	call   800dc9 <sys_cgetc>
  8002b3:	85 c0                	test   %eax,%eax
  8002b5:	74 f2                	je     8002a9 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8002b7:	85 c0                	test   %eax,%eax
  8002b9:	78 16                	js     8002d1 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8002bb:	83 f8 04             	cmp    $0x4,%eax
  8002be:	74 0c                	je     8002cc <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8002c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c3:	88 02                	mov    %al,(%edx)
	return 1;
  8002c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8002ca:	eb 05                	jmp    8002d1 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8002cc:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8002d1:	c9                   	leave  
  8002d2:	c3                   	ret    

008002d3 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8002d3:	55                   	push   %ebp
  8002d4:	89 e5                	mov    %esp,%ebp
  8002d6:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8002df:	6a 01                	push   $0x1
  8002e1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002e4:	50                   	push   %eax
  8002e5:	e8 c1 0a 00 00       	call   800dab <sys_cputs>
  8002ea:	83 c4 10             	add    $0x10,%esp
}
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <getchar>:

int
getchar(void)
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8002f5:	6a 01                	push   $0x1
  8002f7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8002fa:	50                   	push   %eax
  8002fb:	6a 00                	push   $0x0
  8002fd:	e8 54 10 00 00       	call   801356 <read>
	if (r < 0)
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	85 c0                	test   %eax,%eax
  800307:	78 0f                	js     800318 <getchar+0x29>
		return r;
	if (r < 1)
  800309:	85 c0                	test   %eax,%eax
  80030b:	7e 06                	jle    800313 <getchar+0x24>
		return -E_EOF;
	return c;
  80030d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800311:	eb 05                	jmp    800318 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800313:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800323:	50                   	push   %eax
  800324:	ff 75 08             	pushl  0x8(%ebp)
  800327:	e8 c1 0d 00 00       	call   8010ed <fd_lookup>
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	85 c0                	test   %eax,%eax
  800331:	78 11                	js     800344 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800336:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80033c:	39 10                	cmp    %edx,(%eax)
  80033e:	0f 94 c0             	sete   %al
  800341:	0f b6 c0             	movzbl %al,%eax
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <opencons>:

int
opencons(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80034c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80034f:	50                   	push   %eax
  800350:	e8 49 0d 00 00       	call   80109e <fd_alloc>
  800355:	83 c4 10             	add    $0x10,%esp
		return r;
  800358:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80035a:	85 c0                	test   %eax,%eax
  80035c:	78 3e                	js     80039c <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80035e:	83 ec 04             	sub    $0x4,%esp
  800361:	68 07 04 00 00       	push   $0x407
  800366:	ff 75 f4             	pushl  -0xc(%ebp)
  800369:	6a 00                	push   $0x0
  80036b:	e8 f7 0a 00 00       	call   800e67 <sys_page_alloc>
  800370:	83 c4 10             	add    $0x10,%esp
		return r;
  800373:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800375:	85 c0                	test   %eax,%eax
  800377:	78 23                	js     80039c <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800379:	8b 15 70 47 80 00    	mov    0x804770,%edx
  80037f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800382:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800384:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800387:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80038e:	83 ec 0c             	sub    $0xc,%esp
  800391:	50                   	push   %eax
  800392:	e8 e0 0c 00 00       	call   801077 <fd2num>
  800397:	89 c2                	mov    %eax,%edx
  800399:	83 c4 10             	add    $0x10,%esp
}
  80039c:	89 d0                	mov    %edx,%eax
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    

008003a0 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	56                   	push   %esi
  8003a4:	53                   	push   %ebx
  8003a5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003a8:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8003ab:	e8 79 0a 00 00       	call   800e29 <sys_getenvid>
  8003b0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003b5:	6b c0 78             	imul   $0x78,%eax,%eax
  8003b8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003bd:	a3 b0 67 80 00       	mov    %eax,0x8067b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003c2:	85 db                	test   %ebx,%ebx
  8003c4:	7e 07                	jle    8003cd <libmain+0x2d>
		binaryname = argv[0];
  8003c6:	8b 06                	mov    (%esi),%eax
  8003c8:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	56                   	push   %esi
  8003d1:	53                   	push   %ebx
  8003d2:	e8 87 fc ff ff       	call   80005e <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8003d7:	e8 0a 00 00 00       	call   8003e6 <exit>
  8003dc:	83 c4 10             	add    $0x10,%esp
#endif
}
  8003df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8003e2:	5b                   	pop    %ebx
  8003e3:	5e                   	pop    %esi
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8003ec:	e8 52 0e 00 00       	call   801243 <close_all>
	sys_env_destroy(0);
  8003f1:	83 ec 0c             	sub    $0xc,%esp
  8003f4:	6a 00                	push   $0x0
  8003f6:	e8 ed 09 00 00       	call   800de8 <sys_env_destroy>
  8003fb:	83 c4 10             	add    $0x10,%esp
}
  8003fe:	c9                   	leave  
  8003ff:	c3                   	ret    

00800400 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800405:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800408:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80040e:	e8 16 0a 00 00       	call   800e29 <sys_getenvid>
  800413:	83 ec 0c             	sub    $0xc,%esp
  800416:	ff 75 0c             	pushl  0xc(%ebp)
  800419:	ff 75 08             	pushl  0x8(%ebp)
  80041c:	56                   	push   %esi
  80041d:	50                   	push   %eax
  80041e:	68 4c 27 80 00       	push   $0x80274c
  800423:	e8 b1 00 00 00       	call   8004d9 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800428:	83 c4 18             	add    $0x18,%esp
  80042b:	53                   	push   %ebx
  80042c:	ff 75 10             	pushl  0x10(%ebp)
  80042f:	e8 54 00 00 00       	call   800488 <vcprintf>
	cprintf("\n");
  800434:	c7 04 24 27 2b 80 00 	movl   $0x802b27,(%esp)
  80043b:	e8 99 00 00 00       	call   8004d9 <cprintf>
  800440:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800443:	cc                   	int3   
  800444:	eb fd                	jmp    800443 <_panic+0x43>

00800446 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	53                   	push   %ebx
  80044a:	83 ec 04             	sub    $0x4,%esp
  80044d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800450:	8b 13                	mov    (%ebx),%edx
  800452:	8d 42 01             	lea    0x1(%edx),%eax
  800455:	89 03                	mov    %eax,(%ebx)
  800457:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80045a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80045e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800463:	75 1a                	jne    80047f <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	68 ff 00 00 00       	push   $0xff
  80046d:	8d 43 08             	lea    0x8(%ebx),%eax
  800470:	50                   	push   %eax
  800471:	e8 35 09 00 00       	call   800dab <sys_cputs>
		b->idx = 0;
  800476:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80047c:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80047f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800483:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800486:	c9                   	leave  
  800487:	c3                   	ret    

00800488 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800488:	55                   	push   %ebp
  800489:	89 e5                	mov    %esp,%ebp
  80048b:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800491:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800498:	00 00 00 
	b.cnt = 0;
  80049b:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004a2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004a5:	ff 75 0c             	pushl  0xc(%ebp)
  8004a8:	ff 75 08             	pushl  0x8(%ebp)
  8004ab:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004b1:	50                   	push   %eax
  8004b2:	68 46 04 80 00       	push   $0x800446
  8004b7:	e8 4f 01 00 00       	call   80060b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004bc:	83 c4 08             	add    $0x8,%esp
  8004bf:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004c5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004cb:	50                   	push   %eax
  8004cc:	e8 da 08 00 00       	call   800dab <sys_cputs>

	return b.cnt;
}
  8004d1:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8004df:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8004e2:	50                   	push   %eax
  8004e3:	ff 75 08             	pushl  0x8(%ebp)
  8004e6:	e8 9d ff ff ff       	call   800488 <vcprintf>
	va_end(ap);

	return cnt;
}
  8004eb:	c9                   	leave  
  8004ec:	c3                   	ret    

008004ed <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8004ed:	55                   	push   %ebp
  8004ee:	89 e5                	mov    %esp,%ebp
  8004f0:	57                   	push   %edi
  8004f1:	56                   	push   %esi
  8004f2:	53                   	push   %ebx
  8004f3:	83 ec 1c             	sub    $0x1c,%esp
  8004f6:	89 c7                	mov    %eax,%edi
  8004f8:	89 d6                	mov    %edx,%esi
  8004fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800500:	89 d1                	mov    %edx,%ecx
  800502:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800505:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800508:	8b 45 10             	mov    0x10(%ebp),%eax
  80050b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80050e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800511:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800518:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80051b:	72 05                	jb     800522 <printnum+0x35>
  80051d:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800520:	77 3e                	ja     800560 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	ff 75 18             	pushl  0x18(%ebp)
  800528:	83 eb 01             	sub    $0x1,%ebx
  80052b:	53                   	push   %ebx
  80052c:	50                   	push   %eax
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	ff 75 e4             	pushl  -0x1c(%ebp)
  800533:	ff 75 e0             	pushl  -0x20(%ebp)
  800536:	ff 75 dc             	pushl  -0x24(%ebp)
  800539:	ff 75 d8             	pushl  -0x28(%ebp)
  80053c:	e8 ef 1d 00 00       	call   802330 <__udivdi3>
  800541:	83 c4 18             	add    $0x18,%esp
  800544:	52                   	push   %edx
  800545:	50                   	push   %eax
  800546:	89 f2                	mov    %esi,%edx
  800548:	89 f8                	mov    %edi,%eax
  80054a:	e8 9e ff ff ff       	call   8004ed <printnum>
  80054f:	83 c4 20             	add    $0x20,%esp
  800552:	eb 13                	jmp    800567 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800554:	83 ec 08             	sub    $0x8,%esp
  800557:	56                   	push   %esi
  800558:	ff 75 18             	pushl  0x18(%ebp)
  80055b:	ff d7                	call   *%edi
  80055d:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800560:	83 eb 01             	sub    $0x1,%ebx
  800563:	85 db                	test   %ebx,%ebx
  800565:	7f ed                	jg     800554 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	56                   	push   %esi
  80056b:	83 ec 04             	sub    $0x4,%esp
  80056e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800571:	ff 75 e0             	pushl  -0x20(%ebp)
  800574:	ff 75 dc             	pushl  -0x24(%ebp)
  800577:	ff 75 d8             	pushl  -0x28(%ebp)
  80057a:	e8 e1 1e 00 00       	call   802460 <__umoddi3>
  80057f:	83 c4 14             	add    $0x14,%esp
  800582:	0f be 80 6f 27 80 00 	movsbl 0x80276f(%eax),%eax
  800589:	50                   	push   %eax
  80058a:	ff d7                	call   *%edi
  80058c:	83 c4 10             	add    $0x10,%esp
}
  80058f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800592:	5b                   	pop    %ebx
  800593:	5e                   	pop    %esi
  800594:	5f                   	pop    %edi
  800595:	5d                   	pop    %ebp
  800596:	c3                   	ret    

00800597 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80059a:	83 fa 01             	cmp    $0x1,%edx
  80059d:	7e 0e                	jle    8005ad <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80059f:	8b 10                	mov    (%eax),%edx
  8005a1:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005a4:	89 08                	mov    %ecx,(%eax)
  8005a6:	8b 02                	mov    (%edx),%eax
  8005a8:	8b 52 04             	mov    0x4(%edx),%edx
  8005ab:	eb 22                	jmp    8005cf <getuint+0x38>
	else if (lflag)
  8005ad:	85 d2                	test   %edx,%edx
  8005af:	74 10                	je     8005c1 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005b6:	89 08                	mov    %ecx,(%eax)
  8005b8:	8b 02                	mov    (%edx),%eax
  8005ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bf:	eb 0e                	jmp    8005cf <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8005c1:	8b 10                	mov    (%eax),%edx
  8005c3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005c6:	89 08                	mov    %ecx,(%eax)
  8005c8:	8b 02                	mov    (%edx),%eax
  8005ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8005cf:	5d                   	pop    %ebp
  8005d0:	c3                   	ret    

008005d1 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8005d1:	55                   	push   %ebp
  8005d2:	89 e5                	mov    %esp,%ebp
  8005d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8005d7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	3b 50 04             	cmp    0x4(%eax),%edx
  8005e0:	73 0a                	jae    8005ec <sprintputch+0x1b>
		*b->buf++ = ch;
  8005e2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8005e5:	89 08                	mov    %ecx,(%eax)
  8005e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ea:	88 02                	mov    %al,(%edx)
}
  8005ec:	5d                   	pop    %ebp
  8005ed:	c3                   	ret    

008005ee <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8005ee:	55                   	push   %ebp
  8005ef:	89 e5                	mov    %esp,%ebp
  8005f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8005f4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005f7:	50                   	push   %eax
  8005f8:	ff 75 10             	pushl  0x10(%ebp)
  8005fb:	ff 75 0c             	pushl  0xc(%ebp)
  8005fe:	ff 75 08             	pushl  0x8(%ebp)
  800601:	e8 05 00 00 00       	call   80060b <vprintfmt>
	va_end(ap);
  800606:	83 c4 10             	add    $0x10,%esp
}
  800609:	c9                   	leave  
  80060a:	c3                   	ret    

0080060b <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	57                   	push   %edi
  80060f:	56                   	push   %esi
  800610:	53                   	push   %ebx
  800611:	83 ec 2c             	sub    $0x2c,%esp
  800614:	8b 75 08             	mov    0x8(%ebp),%esi
  800617:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80061a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80061d:	eb 12                	jmp    800631 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80061f:	85 c0                	test   %eax,%eax
  800621:	0f 84 8d 03 00 00    	je     8009b4 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800627:	83 ec 08             	sub    $0x8,%esp
  80062a:	53                   	push   %ebx
  80062b:	50                   	push   %eax
  80062c:	ff d6                	call   *%esi
  80062e:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800631:	83 c7 01             	add    $0x1,%edi
  800634:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800638:	83 f8 25             	cmp    $0x25,%eax
  80063b:	75 e2                	jne    80061f <vprintfmt+0x14>
  80063d:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800641:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800648:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80064f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800656:	ba 00 00 00 00       	mov    $0x0,%edx
  80065b:	eb 07                	jmp    800664 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065d:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800660:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800664:	8d 47 01             	lea    0x1(%edi),%eax
  800667:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80066a:	0f b6 07             	movzbl (%edi),%eax
  80066d:	0f b6 c8             	movzbl %al,%ecx
  800670:	83 e8 23             	sub    $0x23,%eax
  800673:	3c 55                	cmp    $0x55,%al
  800675:	0f 87 1e 03 00 00    	ja     800999 <vprintfmt+0x38e>
  80067b:	0f b6 c0             	movzbl %al,%eax
  80067e:	ff 24 85 c0 28 80 00 	jmp    *0x8028c0(,%eax,4)
  800685:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800688:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80068c:	eb d6                	jmp    800664 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800691:	b8 00 00 00 00       	mov    $0x0,%eax
  800696:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800699:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80069c:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8006a0:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8006a3:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8006a6:	83 fa 09             	cmp    $0x9,%edx
  8006a9:	77 38                	ja     8006e3 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8006ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8006ae:	eb e9                	jmp    800699 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8006b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8006b6:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8006b9:	8b 00                	mov    (%eax),%eax
  8006bb:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8006c1:	eb 26                	jmp    8006e9 <vprintfmt+0xde>
  8006c3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c6:	89 c8                	mov    %ecx,%eax
  8006c8:	c1 f8 1f             	sar    $0x1f,%eax
  8006cb:	f7 d0                	not    %eax
  8006cd:	21 c1                	and    %eax,%ecx
  8006cf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d5:	eb 8d                	jmp    800664 <vprintfmt+0x59>
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8006da:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8006e1:	eb 81                	jmp    800664 <vprintfmt+0x59>
  8006e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006e6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8006e9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ed:	0f 89 71 ff ff ff    	jns    800664 <vprintfmt+0x59>
				width = precision, precision = -1;
  8006f3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8006f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006f9:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800700:	e9 5f ff ff ff       	jmp    800664 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800705:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800708:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80070b:	e9 54 ff ff ff       	jmp    800664 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800710:	8b 45 14             	mov    0x14(%ebp),%eax
  800713:	8d 50 04             	lea    0x4(%eax),%edx
  800716:	89 55 14             	mov    %edx,0x14(%ebp)
  800719:	83 ec 08             	sub    $0x8,%esp
  80071c:	53                   	push   %ebx
  80071d:	ff 30                	pushl  (%eax)
  80071f:	ff d6                	call   *%esi
			break;
  800721:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800724:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800727:	e9 05 ff ff ff       	jmp    800631 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8d 50 04             	lea    0x4(%eax),%edx
  800732:	89 55 14             	mov    %edx,0x14(%ebp)
  800735:	8b 00                	mov    (%eax),%eax
  800737:	99                   	cltd   
  800738:	31 d0                	xor    %edx,%eax
  80073a:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80073c:	83 f8 0f             	cmp    $0xf,%eax
  80073f:	7f 0b                	jg     80074c <vprintfmt+0x141>
  800741:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  800748:	85 d2                	test   %edx,%edx
  80074a:	75 18                	jne    800764 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80074c:	50                   	push   %eax
  80074d:	68 87 27 80 00       	push   $0x802787
  800752:	53                   	push   %ebx
  800753:	56                   	push   %esi
  800754:	e8 95 fe ff ff       	call   8005ee <printfmt>
  800759:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80075c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80075f:	e9 cd fe ff ff       	jmp    800631 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800764:	52                   	push   %edx
  800765:	68 71 2b 80 00       	push   $0x802b71
  80076a:	53                   	push   %ebx
  80076b:	56                   	push   %esi
  80076c:	e8 7d fe ff ff       	call   8005ee <printfmt>
  800771:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800774:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800777:	e9 b5 fe ff ff       	jmp    800631 <vprintfmt+0x26>
  80077c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80077f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800782:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8d 50 04             	lea    0x4(%eax),%edx
  80078b:	89 55 14             	mov    %edx,0x14(%ebp)
  80078e:	8b 38                	mov    (%eax),%edi
  800790:	85 ff                	test   %edi,%edi
  800792:	75 05                	jne    800799 <vprintfmt+0x18e>
				p = "(null)";
  800794:	bf 80 27 80 00       	mov    $0x802780,%edi
			if (width > 0 && padc != '-')
  800799:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80079d:	0f 84 91 00 00 00    	je     800834 <vprintfmt+0x229>
  8007a3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007a7:	0f 8e 95 00 00 00    	jle    800842 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	51                   	push   %ecx
  8007b1:	57                   	push   %edi
  8007b2:	e8 85 02 00 00       	call   800a3c <strnlen>
  8007b7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007ba:	29 c1                	sub    %eax,%ecx
  8007bc:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007bf:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8007c2:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8007c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007c9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8007cc:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ce:	eb 0f                	jmp    8007df <vprintfmt+0x1d4>
					putch(padc, putdat);
  8007d0:	83 ec 08             	sub    $0x8,%esp
  8007d3:	53                   	push   %ebx
  8007d4:	ff 75 e0             	pushl  -0x20(%ebp)
  8007d7:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8007d9:	83 ef 01             	sub    $0x1,%edi
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	85 ff                	test   %edi,%edi
  8007e1:	7f ed                	jg     8007d0 <vprintfmt+0x1c5>
  8007e3:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8007e6:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8007e9:	89 c8                	mov    %ecx,%eax
  8007eb:	c1 f8 1f             	sar    $0x1f,%eax
  8007ee:	f7 d0                	not    %eax
  8007f0:	21 c8                	and    %ecx,%eax
  8007f2:	29 c1                	sub    %eax,%ecx
  8007f4:	89 75 08             	mov    %esi,0x8(%ebp)
  8007f7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007fa:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007fd:	89 cb                	mov    %ecx,%ebx
  8007ff:	eb 4d                	jmp    80084e <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800801:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800805:	74 1b                	je     800822 <vprintfmt+0x217>
  800807:	0f be c0             	movsbl %al,%eax
  80080a:	83 e8 20             	sub    $0x20,%eax
  80080d:	83 f8 5e             	cmp    $0x5e,%eax
  800810:	76 10                	jbe    800822 <vprintfmt+0x217>
					putch('?', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	ff 75 0c             	pushl  0xc(%ebp)
  800818:	6a 3f                	push   $0x3f
  80081a:	ff 55 08             	call   *0x8(%ebp)
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	eb 0d                	jmp    80082f <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800822:	83 ec 08             	sub    $0x8,%esp
  800825:	ff 75 0c             	pushl  0xc(%ebp)
  800828:	52                   	push   %edx
  800829:	ff 55 08             	call   *0x8(%ebp)
  80082c:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80082f:	83 eb 01             	sub    $0x1,%ebx
  800832:	eb 1a                	jmp    80084e <vprintfmt+0x243>
  800834:	89 75 08             	mov    %esi,0x8(%ebp)
  800837:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80083a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80083d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800840:	eb 0c                	jmp    80084e <vprintfmt+0x243>
  800842:	89 75 08             	mov    %esi,0x8(%ebp)
  800845:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800848:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084e:	83 c7 01             	add    $0x1,%edi
  800851:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800855:	0f be d0             	movsbl %al,%edx
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 23                	je     80087f <vprintfmt+0x274>
  80085c:	85 f6                	test   %esi,%esi
  80085e:	78 a1                	js     800801 <vprintfmt+0x1f6>
  800860:	83 ee 01             	sub    $0x1,%esi
  800863:	79 9c                	jns    800801 <vprintfmt+0x1f6>
  800865:	89 df                	mov    %ebx,%edi
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	eb 18                	jmp    800887 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80086f:	83 ec 08             	sub    $0x8,%esp
  800872:	53                   	push   %ebx
  800873:	6a 20                	push   $0x20
  800875:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800877:	83 ef 01             	sub    $0x1,%edi
  80087a:	83 c4 10             	add    $0x10,%esp
  80087d:	eb 08                	jmp    800887 <vprintfmt+0x27c>
  80087f:	89 df                	mov    %ebx,%edi
  800881:	8b 75 08             	mov    0x8(%ebp),%esi
  800884:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800887:	85 ff                	test   %edi,%edi
  800889:	7f e4                	jg     80086f <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80088b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80088e:	e9 9e fd ff ff       	jmp    800631 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800893:	83 fa 01             	cmp    $0x1,%edx
  800896:	7e 16                	jle    8008ae <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800898:	8b 45 14             	mov    0x14(%ebp),%eax
  80089b:	8d 50 08             	lea    0x8(%eax),%edx
  80089e:	89 55 14             	mov    %edx,0x14(%ebp)
  8008a1:	8b 50 04             	mov    0x4(%eax),%edx
  8008a4:	8b 00                	mov    (%eax),%eax
  8008a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8008ac:	eb 32                	jmp    8008e0 <vprintfmt+0x2d5>
	else if (lflag)
  8008ae:	85 d2                	test   %edx,%edx
  8008b0:	74 18                	je     8008ca <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8d 50 04             	lea    0x4(%eax),%edx
  8008b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bb:	8b 00                	mov    (%eax),%eax
  8008bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008c0:	89 c1                	mov    %eax,%ecx
  8008c2:	c1 f9 1f             	sar    $0x1f,%ecx
  8008c5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008c8:	eb 16                	jmp    8008e0 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 00                	mov    (%eax),%eax
  8008d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008d8:	89 c1                	mov    %eax,%ecx
  8008da:	c1 f9 1f             	sar    $0x1f,%ecx
  8008dd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8008e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008e3:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8008e6:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8008eb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ef:	79 74                	jns    800965 <vprintfmt+0x35a>
				putch('-', putdat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	53                   	push   %ebx
  8008f5:	6a 2d                	push   $0x2d
  8008f7:	ff d6                	call   *%esi
				num = -(long long) num;
  8008f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008ff:	f7 d8                	neg    %eax
  800901:	83 d2 00             	adc    $0x0,%edx
  800904:	f7 da                	neg    %edx
  800906:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800909:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80090e:	eb 55                	jmp    800965 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800910:	8d 45 14             	lea    0x14(%ebp),%eax
  800913:	e8 7f fc ff ff       	call   800597 <getuint>
			base = 10;
  800918:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80091d:	eb 46                	jmp    800965 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80091f:	8d 45 14             	lea    0x14(%ebp),%eax
  800922:	e8 70 fc ff ff       	call   800597 <getuint>
			base = 8;
  800927:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80092c:	eb 37                	jmp    800965 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	53                   	push   %ebx
  800932:	6a 30                	push   $0x30
  800934:	ff d6                	call   *%esi
			putch('x', putdat);
  800936:	83 c4 08             	add    $0x8,%esp
  800939:	53                   	push   %ebx
  80093a:	6a 78                	push   $0x78
  80093c:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80093e:	8b 45 14             	mov    0x14(%ebp),%eax
  800941:	8d 50 04             	lea    0x4(%eax),%edx
  800944:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800947:	8b 00                	mov    (%eax),%eax
  800949:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80094e:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800951:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800956:	eb 0d                	jmp    800965 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800958:	8d 45 14             	lea    0x14(%ebp),%eax
  80095b:	e8 37 fc ff ff       	call   800597 <getuint>
			base = 16;
  800960:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800965:	83 ec 0c             	sub    $0xc,%esp
  800968:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80096c:	57                   	push   %edi
  80096d:	ff 75 e0             	pushl  -0x20(%ebp)
  800970:	51                   	push   %ecx
  800971:	52                   	push   %edx
  800972:	50                   	push   %eax
  800973:	89 da                	mov    %ebx,%edx
  800975:	89 f0                	mov    %esi,%eax
  800977:	e8 71 fb ff ff       	call   8004ed <printnum>
			break;
  80097c:	83 c4 20             	add    $0x20,%esp
  80097f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800982:	e9 aa fc ff ff       	jmp    800631 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800987:	83 ec 08             	sub    $0x8,%esp
  80098a:	53                   	push   %ebx
  80098b:	51                   	push   %ecx
  80098c:	ff d6                	call   *%esi
			break;
  80098e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800991:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800994:	e9 98 fc ff ff       	jmp    800631 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	6a 25                	push   $0x25
  80099f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009a1:	83 c4 10             	add    $0x10,%esp
  8009a4:	eb 03                	jmp    8009a9 <vprintfmt+0x39e>
  8009a6:	83 ef 01             	sub    $0x1,%edi
  8009a9:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8009ad:	75 f7                	jne    8009a6 <vprintfmt+0x39b>
  8009af:	e9 7d fc ff ff       	jmp    800631 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8009b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009b7:	5b                   	pop    %ebx
  8009b8:	5e                   	pop    %esi
  8009b9:	5f                   	pop    %edi
  8009ba:	5d                   	pop    %ebp
  8009bb:	c3                   	ret    

008009bc <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 18             	sub    $0x18,%esp
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009c8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009cb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009cf:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009d2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009d9:	85 c0                	test   %eax,%eax
  8009db:	74 26                	je     800a03 <vsnprintf+0x47>
  8009dd:	85 d2                	test   %edx,%edx
  8009df:	7e 22                	jle    800a03 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009e1:	ff 75 14             	pushl  0x14(%ebp)
  8009e4:	ff 75 10             	pushl  0x10(%ebp)
  8009e7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009ea:	50                   	push   %eax
  8009eb:	68 d1 05 80 00       	push   $0x8005d1
  8009f0:	e8 16 fc ff ff       	call   80060b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009f5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009fe:	83 c4 10             	add    $0x10,%esp
  800a01:	eb 05                	jmp    800a08 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800a03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a10:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a13:	50                   	push   %eax
  800a14:	ff 75 10             	pushl  0x10(%ebp)
  800a17:	ff 75 0c             	pushl  0xc(%ebp)
  800a1a:	ff 75 08             	pushl  0x8(%ebp)
  800a1d:	e8 9a ff ff ff       	call   8009bc <vsnprintf>
	va_end(ap);

	return rc;
}
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
  800a2f:	eb 03                	jmp    800a34 <strlen+0x10>
		n++;
  800a31:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a34:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a38:	75 f7                	jne    800a31 <strlen+0xd>
		n++;
	return n;
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a3c:	55                   	push   %ebp
  800a3d:	89 e5                	mov    %esp,%ebp
  800a3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a42:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	eb 03                	jmp    800a4f <strnlen+0x13>
		n++;
  800a4c:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a4f:	39 c2                	cmp    %eax,%edx
  800a51:	74 08                	je     800a5b <strnlen+0x1f>
  800a53:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a57:	75 f3                	jne    800a4c <strnlen+0x10>
  800a59:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a67:	89 c2                	mov    %eax,%edx
  800a69:	83 c2 01             	add    $0x1,%edx
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a73:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a76:	84 db                	test   %bl,%bl
  800a78:	75 ef                	jne    800a69 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a7a:	5b                   	pop    %ebx
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	53                   	push   %ebx
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	53                   	push   %ebx
  800a85:	e8 9a ff ff ff       	call   800a24 <strlen>
  800a8a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a8d:	ff 75 0c             	pushl  0xc(%ebp)
  800a90:	01 d8                	add    %ebx,%eax
  800a92:	50                   	push   %eax
  800a93:	e8 c5 ff ff ff       	call   800a5d <strcpy>
	return dst;
}
  800a98:	89 d8                	mov    %ebx,%eax
  800a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800aaf:	89 f2                	mov    %esi,%edx
  800ab1:	eb 0f                	jmp    800ac2 <strncpy+0x23>
		*dst++ = *src;
  800ab3:	83 c2 01             	add    $0x1,%edx
  800ab6:	0f b6 01             	movzbl (%ecx),%eax
  800ab9:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800abc:	80 39 01             	cmpb   $0x1,(%ecx)
  800abf:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac2:	39 da                	cmp    %ebx,%edx
  800ac4:	75 ed                	jne    800ab3 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ac6:	89 f0                	mov    %esi,%eax
  800ac8:	5b                   	pop    %ebx
  800ac9:	5e                   	pop    %esi
  800aca:	5d                   	pop    %ebp
  800acb:	c3                   	ret    

00800acc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800acc:	55                   	push   %ebp
  800acd:	89 e5                	mov    %esp,%ebp
  800acf:	56                   	push   %esi
  800ad0:	53                   	push   %ebx
  800ad1:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ad7:	8b 55 10             	mov    0x10(%ebp),%edx
  800ada:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800adc:	85 d2                	test   %edx,%edx
  800ade:	74 21                	je     800b01 <strlcpy+0x35>
  800ae0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800ae4:	89 f2                	mov    %esi,%edx
  800ae6:	eb 09                	jmp    800af1 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800ae8:	83 c2 01             	add    $0x1,%edx
  800aeb:	83 c1 01             	add    $0x1,%ecx
  800aee:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af1:	39 c2                	cmp    %eax,%edx
  800af3:	74 09                	je     800afe <strlcpy+0x32>
  800af5:	0f b6 19             	movzbl (%ecx),%ebx
  800af8:	84 db                	test   %bl,%bl
  800afa:	75 ec                	jne    800ae8 <strlcpy+0x1c>
  800afc:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800afe:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b01:	29 f0                	sub    %esi,%eax
}
  800b03:	5b                   	pop    %ebx
  800b04:	5e                   	pop    %esi
  800b05:	5d                   	pop    %ebp
  800b06:	c3                   	ret    

00800b07 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b07:	55                   	push   %ebp
  800b08:	89 e5                	mov    %esp,%ebp
  800b0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b10:	eb 06                	jmp    800b18 <strcmp+0x11>
		p++, q++;
  800b12:	83 c1 01             	add    $0x1,%ecx
  800b15:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b18:	0f b6 01             	movzbl (%ecx),%eax
  800b1b:	84 c0                	test   %al,%al
  800b1d:	74 04                	je     800b23 <strcmp+0x1c>
  800b1f:	3a 02                	cmp    (%edx),%al
  800b21:	74 ef                	je     800b12 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b23:	0f b6 c0             	movzbl %al,%eax
  800b26:	0f b6 12             	movzbl (%edx),%edx
  800b29:	29 d0                	sub    %edx,%eax
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	53                   	push   %ebx
  800b31:	8b 45 08             	mov    0x8(%ebp),%eax
  800b34:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b37:	89 c3                	mov    %eax,%ebx
  800b39:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b3c:	eb 06                	jmp    800b44 <strncmp+0x17>
		n--, p++, q++;
  800b3e:	83 c0 01             	add    $0x1,%eax
  800b41:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b44:	39 d8                	cmp    %ebx,%eax
  800b46:	74 15                	je     800b5d <strncmp+0x30>
  800b48:	0f b6 08             	movzbl (%eax),%ecx
  800b4b:	84 c9                	test   %cl,%cl
  800b4d:	74 04                	je     800b53 <strncmp+0x26>
  800b4f:	3a 0a                	cmp    (%edx),%cl
  800b51:	74 eb                	je     800b3e <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b53:	0f b6 00             	movzbl (%eax),%eax
  800b56:	0f b6 12             	movzbl (%edx),%edx
  800b59:	29 d0                	sub    %edx,%eax
  800b5b:	eb 05                	jmp    800b62 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b5d:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b6f:	eb 07                	jmp    800b78 <strchr+0x13>
		if (*s == c)
  800b71:	38 ca                	cmp    %cl,%dl
  800b73:	74 0f                	je     800b84 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b75:	83 c0 01             	add    $0x1,%eax
  800b78:	0f b6 10             	movzbl (%eax),%edx
  800b7b:	84 d2                	test   %dl,%dl
  800b7d:	75 f2                	jne    800b71 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b84:	5d                   	pop    %ebp
  800b85:	c3                   	ret    

00800b86 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b86:	55                   	push   %ebp
  800b87:	89 e5                	mov    %esp,%ebp
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b90:	eb 03                	jmp    800b95 <strfind+0xf>
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	74 04                	je     800ba0 <strfind+0x1a>
  800b9c:	38 ca                	cmp    %cl,%dl
  800b9e:	75 f2                	jne    800b92 <strfind+0xc>
			break;
	return (char *) s;
}
  800ba0:	5d                   	pop    %ebp
  800ba1:	c3                   	ret    

00800ba2 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bab:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800bae:	85 c9                	test   %ecx,%ecx
  800bb0:	74 36                	je     800be8 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bb2:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800bb8:	75 28                	jne    800be2 <memset+0x40>
  800bba:	f6 c1 03             	test   $0x3,%cl
  800bbd:	75 23                	jne    800be2 <memset+0x40>
		c &= 0xFF;
  800bbf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bc3:	89 d3                	mov    %edx,%ebx
  800bc5:	c1 e3 08             	shl    $0x8,%ebx
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	c1 e6 18             	shl    $0x18,%esi
  800bcd:	89 d0                	mov    %edx,%eax
  800bcf:	c1 e0 10             	shl    $0x10,%eax
  800bd2:	09 f0                	or     %esi,%eax
  800bd4:	09 c2                	or     %eax,%edx
  800bd6:	89 d0                	mov    %edx,%eax
  800bd8:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800bda:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800bdd:	fc                   	cld    
  800bde:	f3 ab                	rep stos %eax,%es:(%edi)
  800be0:	eb 06                	jmp    800be8 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800be2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be5:	fc                   	cld    
  800be6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800be8:	89 f8                	mov    %edi,%eax
  800bea:	5b                   	pop    %ebx
  800beb:	5e                   	pop    %esi
  800bec:	5f                   	pop    %edi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	57                   	push   %edi
  800bf3:	56                   	push   %esi
  800bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bfa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bfd:	39 c6                	cmp    %eax,%esi
  800bff:	73 35                	jae    800c36 <memmove+0x47>
  800c01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c04:	39 d0                	cmp    %edx,%eax
  800c06:	73 2e                	jae    800c36 <memmove+0x47>
		s += n;
		d += n;
  800c08:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800c0b:	89 d6                	mov    %edx,%esi
  800c0d:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c0f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c15:	75 13                	jne    800c2a <memmove+0x3b>
  800c17:	f6 c1 03             	test   $0x3,%cl
  800c1a:	75 0e                	jne    800c2a <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c1c:	83 ef 04             	sub    $0x4,%edi
  800c1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c22:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800c25:	fd                   	std    
  800c26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c28:	eb 09                	jmp    800c33 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c2a:	83 ef 01             	sub    $0x1,%edi
  800c2d:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c30:	fd                   	std    
  800c31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c33:	fc                   	cld    
  800c34:	eb 1d                	jmp    800c53 <memmove+0x64>
  800c36:	89 f2                	mov    %esi,%edx
  800c38:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c3a:	f6 c2 03             	test   $0x3,%dl
  800c3d:	75 0f                	jne    800c4e <memmove+0x5f>
  800c3f:	f6 c1 03             	test   $0x3,%cl
  800c42:	75 0a                	jne    800c4e <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c44:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800c47:	89 c7                	mov    %eax,%edi
  800c49:	fc                   	cld    
  800c4a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c4c:	eb 05                	jmp    800c53 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800c4e:	89 c7                	mov    %eax,%edi
  800c50:	fc                   	cld    
  800c51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c53:	5e                   	pop    %esi
  800c54:	5f                   	pop    %edi
  800c55:	5d                   	pop    %ebp
  800c56:	c3                   	ret    

00800c57 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c5a:	ff 75 10             	pushl  0x10(%ebp)
  800c5d:	ff 75 0c             	pushl  0xc(%ebp)
  800c60:	ff 75 08             	pushl  0x8(%ebp)
  800c63:	e8 87 ff ff ff       	call   800bef <memmove>
}
  800c68:	c9                   	leave  
  800c69:	c3                   	ret    

00800c6a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c75:	89 c6                	mov    %eax,%esi
  800c77:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7a:	eb 1a                	jmp    800c96 <memcmp+0x2c>
		if (*s1 != *s2)
  800c7c:	0f b6 08             	movzbl (%eax),%ecx
  800c7f:	0f b6 1a             	movzbl (%edx),%ebx
  800c82:	38 d9                	cmp    %bl,%cl
  800c84:	74 0a                	je     800c90 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c86:	0f b6 c1             	movzbl %cl,%eax
  800c89:	0f b6 db             	movzbl %bl,%ebx
  800c8c:	29 d8                	sub    %ebx,%eax
  800c8e:	eb 0f                	jmp    800c9f <memcmp+0x35>
		s1++, s2++;
  800c90:	83 c0 01             	add    $0x1,%eax
  800c93:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c96:	39 f0                	cmp    %esi,%eax
  800c98:	75 e2                	jne    800c7c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c9a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c9f:	5b                   	pop    %ebx
  800ca0:	5e                   	pop    %esi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cac:	89 c2                	mov    %eax,%edx
  800cae:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb1:	eb 07                	jmp    800cba <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cb3:	38 08                	cmp    %cl,(%eax)
  800cb5:	74 07                	je     800cbe <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800cb7:	83 c0 01             	add    $0x1,%eax
  800cba:	39 d0                	cmp    %edx,%eax
  800cbc:	72 f5                	jb     800cb3 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    

00800cc0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc0:	55                   	push   %ebp
  800cc1:	89 e5                	mov    %esp,%ebp
  800cc3:	57                   	push   %edi
  800cc4:	56                   	push   %esi
  800cc5:	53                   	push   %ebx
  800cc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ccc:	eb 03                	jmp    800cd1 <strtol+0x11>
		s++;
  800cce:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd1:	0f b6 01             	movzbl (%ecx),%eax
  800cd4:	3c 09                	cmp    $0x9,%al
  800cd6:	74 f6                	je     800cce <strtol+0xe>
  800cd8:	3c 20                	cmp    $0x20,%al
  800cda:	74 f2                	je     800cce <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800cdc:	3c 2b                	cmp    $0x2b,%al
  800cde:	75 0a                	jne    800cea <strtol+0x2a>
		s++;
  800ce0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ce3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ce8:	eb 10                	jmp    800cfa <strtol+0x3a>
  800cea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800cef:	3c 2d                	cmp    $0x2d,%al
  800cf1:	75 07                	jne    800cfa <strtol+0x3a>
		s++, neg = 1;
  800cf3:	8d 49 01             	lea    0x1(%ecx),%ecx
  800cf6:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cfa:	85 db                	test   %ebx,%ebx
  800cfc:	0f 94 c0             	sete   %al
  800cff:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d05:	75 19                	jne    800d20 <strtol+0x60>
  800d07:	80 39 30             	cmpb   $0x30,(%ecx)
  800d0a:	75 14                	jne    800d20 <strtol+0x60>
  800d0c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d10:	0f 85 8a 00 00 00    	jne    800da0 <strtol+0xe0>
		s += 2, base = 16;
  800d16:	83 c1 02             	add    $0x2,%ecx
  800d19:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d1e:	eb 16                	jmp    800d36 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d20:	84 c0                	test   %al,%al
  800d22:	74 12                	je     800d36 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d24:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d29:	80 39 30             	cmpb   $0x30,(%ecx)
  800d2c:	75 08                	jne    800d36 <strtol+0x76>
		s++, base = 8;
  800d2e:	83 c1 01             	add    $0x1,%ecx
  800d31:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
  800d3b:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800d3e:	0f b6 11             	movzbl (%ecx),%edx
  800d41:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d44:	89 f3                	mov    %esi,%ebx
  800d46:	80 fb 09             	cmp    $0x9,%bl
  800d49:	77 08                	ja     800d53 <strtol+0x93>
			dig = *s - '0';
  800d4b:	0f be d2             	movsbl %dl,%edx
  800d4e:	83 ea 30             	sub    $0x30,%edx
  800d51:	eb 22                	jmp    800d75 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800d53:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d56:	89 f3                	mov    %esi,%ebx
  800d58:	80 fb 19             	cmp    $0x19,%bl
  800d5b:	77 08                	ja     800d65 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800d5d:	0f be d2             	movsbl %dl,%edx
  800d60:	83 ea 57             	sub    $0x57,%edx
  800d63:	eb 10                	jmp    800d75 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800d65:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d68:	89 f3                	mov    %esi,%ebx
  800d6a:	80 fb 19             	cmp    $0x19,%bl
  800d6d:	77 16                	ja     800d85 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d6f:	0f be d2             	movsbl %dl,%edx
  800d72:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d75:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d78:	7d 0f                	jge    800d89 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800d7a:	83 c1 01             	add    $0x1,%ecx
  800d7d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d81:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d83:	eb b9                	jmp    800d3e <strtol+0x7e>
  800d85:	89 c2                	mov    %eax,%edx
  800d87:	eb 02                	jmp    800d8b <strtol+0xcb>
  800d89:	89 c2                	mov    %eax,%edx

	if (endptr)
  800d8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8f:	74 05                	je     800d96 <strtol+0xd6>
		*endptr = (char *) s;
  800d91:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d94:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d96:	85 ff                	test   %edi,%edi
  800d98:	74 0c                	je     800da6 <strtol+0xe6>
  800d9a:	89 d0                	mov    %edx,%eax
  800d9c:	f7 d8                	neg    %eax
  800d9e:	eb 06                	jmp    800da6 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800da0:	84 c0                	test   %al,%al
  800da2:	75 8a                	jne    800d2e <strtol+0x6e>
  800da4:	eb 90                	jmp    800d36 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    

00800dab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	57                   	push   %edi
  800daf:	56                   	push   %esi
  800db0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	b8 00 00 00 00       	mov    $0x0,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 c3                	mov    %eax,%ebx
  800dbe:	89 c7                	mov    %eax,%edi
  800dc0:	89 c6                	mov    %eax,%esi
  800dc2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800dc4:	5b                   	pop    %ebx
  800dc5:	5e                   	pop    %esi
  800dc6:	5f                   	pop    %edi
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	57                   	push   %edi
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd4:	b8 01 00 00 00       	mov    $0x1,%eax
  800dd9:	89 d1                	mov    %edx,%ecx
  800ddb:	89 d3                	mov    %edx,%ebx
  800ddd:	89 d7                	mov    %edx,%edi
  800ddf:	89 d6                	mov    %edx,%esi
  800de1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
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
  800df1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800df6:	b8 03 00 00 00       	mov    $0x3,%eax
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 cb                	mov    %ecx,%ebx
  800e00:	89 cf                	mov    %ecx,%edi
  800e02:	89 ce                	mov    %ecx,%esi
  800e04:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7e 17                	jle    800e21 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	50                   	push   %eax
  800e0e:	6a 03                	push   $0x3
  800e10:	68 9f 2a 80 00       	push   $0x802a9f
  800e15:	6a 23                	push   $0x23
  800e17:	68 bc 2a 80 00       	push   $0x802abc
  800e1c:	e8 df f5 ff ff       	call   800400 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800e21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e24:	5b                   	pop    %ebx
  800e25:	5e                   	pop    %esi
  800e26:	5f                   	pop    %edi
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e34:	b8 02 00 00 00       	mov    $0x2,%eax
  800e39:	89 d1                	mov    %edx,%ecx
  800e3b:	89 d3                	mov    %edx,%ebx
  800e3d:	89 d7                	mov    %edx,%edi
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e43:	5b                   	pop    %ebx
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <sys_yield>:

void
sys_yield(void)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
  800e4b:	57                   	push   %edi
  800e4c:	56                   	push   %esi
  800e4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e53:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e58:	89 d1                	mov    %edx,%ecx
  800e5a:	89 d3                	mov    %edx,%ebx
  800e5c:	89 d7                	mov    %edx,%edi
  800e5e:	89 d6                	mov    %edx,%esi
  800e60:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e62:	5b                   	pop    %ebx
  800e63:	5e                   	pop    %esi
  800e64:	5f                   	pop    %edi
  800e65:	5d                   	pop    %ebp
  800e66:	c3                   	ret    

00800e67 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	57                   	push   %edi
  800e6b:	56                   	push   %esi
  800e6c:	53                   	push   %ebx
  800e6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e70:	be 00 00 00 00       	mov    $0x0,%esi
  800e75:	b8 04 00 00 00       	mov    $0x4,%eax
  800e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e83:	89 f7                	mov    %esi,%edi
  800e85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e87:	85 c0                	test   %eax,%eax
  800e89:	7e 17                	jle    800ea2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8b:	83 ec 0c             	sub    $0xc,%esp
  800e8e:	50                   	push   %eax
  800e8f:	6a 04                	push   $0x4
  800e91:	68 9f 2a 80 00       	push   $0x802a9f
  800e96:	6a 23                	push   $0x23
  800e98:	68 bc 2a 80 00       	push   $0x802abc
  800e9d:	e8 5e f5 ff ff       	call   800400 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb3:	b8 05 00 00 00       	mov    $0x5,%eax
  800eb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ec4:	8b 75 18             	mov    0x18(%ebp),%esi
  800ec7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	7e 17                	jle    800ee4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecd:	83 ec 0c             	sub    $0xc,%esp
  800ed0:	50                   	push   %eax
  800ed1:	6a 05                	push   $0x5
  800ed3:	68 9f 2a 80 00       	push   $0x802a9f
  800ed8:	6a 23                	push   $0x23
  800eda:	68 bc 2a 80 00       	push   $0x802abc
  800edf:	e8 1c f5 ff ff       	call   800400 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ee4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efa:	b8 06 00 00 00       	mov    $0x6,%eax
  800eff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
  800f05:	89 df                	mov    %ebx,%edi
  800f07:	89 de                	mov    %ebx,%esi
  800f09:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	7e 17                	jle    800f26 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0f:	83 ec 0c             	sub    $0xc,%esp
  800f12:	50                   	push   %eax
  800f13:	6a 06                	push   $0x6
  800f15:	68 9f 2a 80 00       	push   $0x802a9f
  800f1a:	6a 23                	push   $0x23
  800f1c:	68 bc 2a 80 00       	push   $0x802abc
  800f21:	e8 da f4 ff ff       	call   800400 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800f41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f44:	8b 55 08             	mov    0x8(%ebp),%edx
  800f47:	89 df                	mov    %ebx,%edi
  800f49:	89 de                	mov    %ebx,%esi
  800f4b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	7e 17                	jle    800f68 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	50                   	push   %eax
  800f55:	6a 08                	push   $0x8
  800f57:	68 9f 2a 80 00       	push   $0x802a9f
  800f5c:	6a 23                	push   $0x23
  800f5e:	68 bc 2a 80 00       	push   $0x802abc
  800f63:	e8 98 f4 ff ff       	call   800400 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6b:	5b                   	pop    %ebx
  800f6c:	5e                   	pop    %esi
  800f6d:	5f                   	pop    %edi
  800f6e:	5d                   	pop    %ebp
  800f6f:	c3                   	ret    

00800f70 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
  800f76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f7e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f86:	8b 55 08             	mov    0x8(%ebp),%edx
  800f89:	89 df                	mov    %ebx,%edi
  800f8b:	89 de                	mov    %ebx,%esi
  800f8d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	7e 17                	jle    800faa <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f93:	83 ec 0c             	sub    $0xc,%esp
  800f96:	50                   	push   %eax
  800f97:	6a 09                	push   $0x9
  800f99:	68 9f 2a 80 00       	push   $0x802a9f
  800f9e:	6a 23                	push   $0x23
  800fa0:	68 bc 2a 80 00       	push   $0x802abc
  800fa5:	e8 56 f4 ff ff       	call   800400 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800faa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fad:	5b                   	pop    %ebx
  800fae:	5e                   	pop    %esi
  800faf:	5f                   	pop    %edi
  800fb0:	5d                   	pop    %ebp
  800fb1:	c3                   	ret    

00800fb2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fc0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800fcb:	89 df                	mov    %ebx,%edi
  800fcd:	89 de                	mov    %ebx,%esi
  800fcf:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	7e 17                	jle    800fec <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	50                   	push   %eax
  800fd9:	6a 0a                	push   $0xa
  800fdb:	68 9f 2a 80 00       	push   $0x802a9f
  800fe0:	6a 23                	push   $0x23
  800fe2:	68 bc 2a 80 00       	push   $0x802abc
  800fe7:	e8 14 f4 ff ff       	call   800400 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fef:	5b                   	pop    %ebx
  800ff0:	5e                   	pop    %esi
  800ff1:	5f                   	pop    %edi
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    

00800ff4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	57                   	push   %edi
  800ff8:	56                   	push   %esi
  800ff9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffa:	be 00 00 00 00       	mov    $0x0,%esi
  800fff:	b8 0c 00 00 00       	mov    $0xc,%eax
  801004:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801007:	8b 55 08             	mov    0x8(%ebp),%edx
  80100a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80100d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801010:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5f                   	pop    %edi
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
  80101d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	b9 00 00 00 00       	mov    $0x0,%ecx
  801025:	b8 0d 00 00 00       	mov    $0xd,%eax
  80102a:	8b 55 08             	mov    0x8(%ebp),%edx
  80102d:	89 cb                	mov    %ecx,%ebx
  80102f:	89 cf                	mov    %ecx,%edi
  801031:	89 ce                	mov    %ecx,%esi
  801033:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801035:	85 c0                	test   %eax,%eax
  801037:	7e 17                	jle    801050 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	50                   	push   %eax
  80103d:	6a 0d                	push   $0xd
  80103f:	68 9f 2a 80 00       	push   $0x802a9f
  801044:	6a 23                	push   $0x23
  801046:	68 bc 2a 80 00       	push   $0x802abc
  80104b:	e8 b0 f3 ff ff       	call   800400 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801050:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_gettime>:

int sys_gettime(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80105e:	ba 00 00 00 00       	mov    $0x0,%edx
  801063:	b8 0e 00 00 00       	mov    $0xe,%eax
  801068:	89 d1                	mov    %edx,%ecx
  80106a:	89 d3                	mov    %edx,%ebx
  80106c:	89 d7                	mov    %edx,%edi
  80106e:	89 d6                	mov    %edx,%esi
  801070:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  801072:	5b                   	pop    %ebx
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    

00801077 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80107a:	8b 45 08             	mov    0x8(%ebp),%eax
  80107d:	05 00 00 00 30       	add    $0x30000000,%eax
  801082:	c1 e8 0c             	shr    $0xc,%eax
}
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    

00801087 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80108a:	8b 45 08             	mov    0x8(%ebp),%eax
  80108d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801092:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801097:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80109c:	5d                   	pop    %ebp
  80109d:	c3                   	ret    

0080109e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	c1 ea 16             	shr    $0x16,%edx
  8010ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b5:	f6 c2 01             	test   $0x1,%dl
  8010b8:	74 11                	je     8010cb <fd_alloc+0x2d>
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	c1 ea 0c             	shr    $0xc,%edx
  8010bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	75 09                	jne    8010d4 <fd_alloc+0x36>
			*fd_store = fd;
  8010cb:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d2:	eb 17                	jmp    8010eb <fd_alloc+0x4d>
  8010d4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010de:	75 c9                	jne    8010a9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010e0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010e6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f3:	83 f8 1f             	cmp    $0x1f,%eax
  8010f6:	77 36                	ja     80112e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f8:	c1 e0 0c             	shl    $0xc,%eax
  8010fb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801100:	89 c2                	mov    %eax,%edx
  801102:	c1 ea 16             	shr    $0x16,%edx
  801105:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110c:	f6 c2 01             	test   $0x1,%dl
  80110f:	74 24                	je     801135 <fd_lookup+0x48>
  801111:	89 c2                	mov    %eax,%edx
  801113:	c1 ea 0c             	shr    $0xc,%edx
  801116:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111d:	f6 c2 01             	test   $0x1,%dl
  801120:	74 1a                	je     80113c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801122:	8b 55 0c             	mov    0xc(%ebp),%edx
  801125:	89 02                	mov    %eax,(%edx)
	return 0;
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	eb 13                	jmp    801141 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801133:	eb 0c                	jmp    801141 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801135:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113a:	eb 05                	jmp    801141 <fd_lookup+0x54>
  80113c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801141:	5d                   	pop    %ebp
  801142:	c3                   	ret    

00801143 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 08             	sub    $0x8,%esp
  801149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114c:	ba 48 2b 80 00       	mov    $0x802b48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801151:	eb 13                	jmp    801166 <dev_lookup+0x23>
  801153:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801156:	39 08                	cmp    %ecx,(%eax)
  801158:	75 0c                	jne    801166 <dev_lookup+0x23>
			*dev = devtab[i];
  80115a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80115d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
  801164:	eb 2e                	jmp    801194 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801166:	8b 02                	mov    (%edx),%eax
  801168:	85 c0                	test   %eax,%eax
  80116a:	75 e7                	jne    801153 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80116c:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  801171:	8b 40 48             	mov    0x48(%eax),%eax
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	51                   	push   %ecx
  801178:	50                   	push   %eax
  801179:	68 cc 2a 80 00       	push   $0x802acc
  80117e:	e8 56 f3 ff ff       	call   8004d9 <cprintf>
	*dev = 0;
  801183:	8b 45 0c             	mov    0xc(%ebp),%eax
  801186:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80118c:	83 c4 10             	add    $0x10,%esp
  80118f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801194:	c9                   	leave  
  801195:	c3                   	ret    

00801196 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	56                   	push   %esi
  80119a:	53                   	push   %ebx
  80119b:	83 ec 10             	sub    $0x10,%esp
  80119e:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a7:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ae:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b1:	50                   	push   %eax
  8011b2:	e8 36 ff ff ff       	call   8010ed <fd_lookup>
  8011b7:	83 c4 08             	add    $0x8,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 05                	js     8011c3 <fd_close+0x2d>
	    || fd != fd2)
  8011be:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011c1:	74 0b                	je     8011ce <fd_close+0x38>
		return (must_exist ? r : 0);
  8011c3:	80 fb 01             	cmp    $0x1,%bl
  8011c6:	19 d2                	sbb    %edx,%edx
  8011c8:	f7 d2                	not    %edx
  8011ca:	21 d0                	and    %edx,%eax
  8011cc:	eb 41                	jmp    80120f <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011ce:	83 ec 08             	sub    $0x8,%esp
  8011d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d4:	50                   	push   %eax
  8011d5:	ff 36                	pushl  (%esi)
  8011d7:	e8 67 ff ff ff       	call   801143 <dev_lookup>
  8011dc:	89 c3                	mov    %eax,%ebx
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 1a                	js     8011ff <fd_close+0x69>
		if (dev->dev_close)
  8011e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011eb:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f0:	85 c0                	test   %eax,%eax
  8011f2:	74 0b                	je     8011ff <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8011f4:	83 ec 0c             	sub    $0xc,%esp
  8011f7:	56                   	push   %esi
  8011f8:	ff d0                	call   *%eax
  8011fa:	89 c3                	mov    %eax,%ebx
  8011fc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011ff:	83 ec 08             	sub    $0x8,%esp
  801202:	56                   	push   %esi
  801203:	6a 00                	push   $0x0
  801205:	e8 e2 fc ff ff       	call   800eec <sys_page_unmap>
	return r;
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	89 d8                	mov    %ebx,%eax
}
  80120f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801212:	5b                   	pop    %ebx
  801213:	5e                   	pop    %esi
  801214:	5d                   	pop    %ebp
  801215:	c3                   	ret    

00801216 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801216:	55                   	push   %ebp
  801217:	89 e5                	mov    %esp,%ebp
  801219:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121f:	50                   	push   %eax
  801220:	ff 75 08             	pushl  0x8(%ebp)
  801223:	e8 c5 fe ff ff       	call   8010ed <fd_lookup>
  801228:	89 c2                	mov    %eax,%edx
  80122a:	83 c4 08             	add    $0x8,%esp
  80122d:	85 d2                	test   %edx,%edx
  80122f:	78 10                	js     801241 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801231:	83 ec 08             	sub    $0x8,%esp
  801234:	6a 01                	push   $0x1
  801236:	ff 75 f4             	pushl  -0xc(%ebp)
  801239:	e8 58 ff ff ff       	call   801196 <fd_close>
  80123e:	83 c4 10             	add    $0x10,%esp
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    

00801243 <close_all>:

void
close_all(void)
{
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	53                   	push   %ebx
  801247:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80124a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80124f:	83 ec 0c             	sub    $0xc,%esp
  801252:	53                   	push   %ebx
  801253:	e8 be ff ff ff       	call   801216 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801258:	83 c3 01             	add    $0x1,%ebx
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	83 fb 20             	cmp    $0x20,%ebx
  801261:	75 ec                	jne    80124f <close_all+0xc>
		close(i);
}
  801263:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801266:	c9                   	leave  
  801267:	c3                   	ret    

00801268 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	57                   	push   %edi
  80126c:	56                   	push   %esi
  80126d:	53                   	push   %ebx
  80126e:	83 ec 2c             	sub    $0x2c,%esp
  801271:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801274:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801277:	50                   	push   %eax
  801278:	ff 75 08             	pushl  0x8(%ebp)
  80127b:	e8 6d fe ff ff       	call   8010ed <fd_lookup>
  801280:	89 c2                	mov    %eax,%edx
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	85 d2                	test   %edx,%edx
  801287:	0f 88 c1 00 00 00    	js     80134e <dup+0xe6>
		return r;
	close(newfdnum);
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	56                   	push   %esi
  801291:	e8 80 ff ff ff       	call   801216 <close>

	newfd = INDEX2FD(newfdnum);
  801296:	89 f3                	mov    %esi,%ebx
  801298:	c1 e3 0c             	shl    $0xc,%ebx
  80129b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012a1:	83 c4 04             	add    $0x4,%esp
  8012a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a7:	e8 db fd ff ff       	call   801087 <fd2data>
  8012ac:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012ae:	89 1c 24             	mov    %ebx,(%esp)
  8012b1:	e8 d1 fd ff ff       	call   801087 <fd2data>
  8012b6:	83 c4 10             	add    $0x10,%esp
  8012b9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012bc:	89 f8                	mov    %edi,%eax
  8012be:	c1 e8 16             	shr    $0x16,%eax
  8012c1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c8:	a8 01                	test   $0x1,%al
  8012ca:	74 37                	je     801303 <dup+0x9b>
  8012cc:	89 f8                	mov    %edi,%eax
  8012ce:	c1 e8 0c             	shr    $0xc,%eax
  8012d1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d8:	f6 c2 01             	test   $0x1,%dl
  8012db:	74 26                	je     801303 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012dd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e4:	83 ec 0c             	sub    $0xc,%esp
  8012e7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ec:	50                   	push   %eax
  8012ed:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f0:	6a 00                	push   $0x0
  8012f2:	57                   	push   %edi
  8012f3:	6a 00                	push   $0x0
  8012f5:	e8 b0 fb ff ff       	call   800eaa <sys_page_map>
  8012fa:	89 c7                	mov    %eax,%edi
  8012fc:	83 c4 20             	add    $0x20,%esp
  8012ff:	85 c0                	test   %eax,%eax
  801301:	78 2e                	js     801331 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801303:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801306:	89 d0                	mov    %edx,%eax
  801308:	c1 e8 0c             	shr    $0xc,%eax
  80130b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801312:	83 ec 0c             	sub    $0xc,%esp
  801315:	25 07 0e 00 00       	and    $0xe07,%eax
  80131a:	50                   	push   %eax
  80131b:	53                   	push   %ebx
  80131c:	6a 00                	push   $0x0
  80131e:	52                   	push   %edx
  80131f:	6a 00                	push   $0x0
  801321:	e8 84 fb ff ff       	call   800eaa <sys_page_map>
  801326:	89 c7                	mov    %eax,%edi
  801328:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80132b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80132d:	85 ff                	test   %edi,%edi
  80132f:	79 1d                	jns    80134e <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	53                   	push   %ebx
  801335:	6a 00                	push   $0x0
  801337:	e8 b0 fb ff ff       	call   800eec <sys_page_unmap>
	sys_page_unmap(0, nva);
  80133c:	83 c4 08             	add    $0x8,%esp
  80133f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801342:	6a 00                	push   $0x0
  801344:	e8 a3 fb ff ff       	call   800eec <sys_page_unmap>
	return r;
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	89 f8                	mov    %edi,%eax
}
  80134e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801351:	5b                   	pop    %ebx
  801352:	5e                   	pop    %esi
  801353:	5f                   	pop    %edi
  801354:	5d                   	pop    %ebp
  801355:	c3                   	ret    

00801356 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	53                   	push   %ebx
  80135a:	83 ec 14             	sub    $0x14,%esp
  80135d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801360:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801363:	50                   	push   %eax
  801364:	53                   	push   %ebx
  801365:	e8 83 fd ff ff       	call   8010ed <fd_lookup>
  80136a:	83 c4 08             	add    $0x8,%esp
  80136d:	89 c2                	mov    %eax,%edx
  80136f:	85 c0                	test   %eax,%eax
  801371:	78 6d                	js     8013e0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801373:	83 ec 08             	sub    $0x8,%esp
  801376:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801379:	50                   	push   %eax
  80137a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137d:	ff 30                	pushl  (%eax)
  80137f:	e8 bf fd ff ff       	call   801143 <dev_lookup>
  801384:	83 c4 10             	add    $0x10,%esp
  801387:	85 c0                	test   %eax,%eax
  801389:	78 4c                	js     8013d7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80138b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80138e:	8b 42 08             	mov    0x8(%edx),%eax
  801391:	83 e0 03             	and    $0x3,%eax
  801394:	83 f8 01             	cmp    $0x1,%eax
  801397:	75 21                	jne    8013ba <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801399:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  80139e:	8b 40 48             	mov    0x48(%eax),%eax
  8013a1:	83 ec 04             	sub    $0x4,%esp
  8013a4:	53                   	push   %ebx
  8013a5:	50                   	push   %eax
  8013a6:	68 0d 2b 80 00       	push   $0x802b0d
  8013ab:	e8 29 f1 ff ff       	call   8004d9 <cprintf>
		return -E_INVAL;
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013b8:	eb 26                	jmp    8013e0 <read+0x8a>
	}
	if (!dev->dev_read)
  8013ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bd:	8b 40 08             	mov    0x8(%eax),%eax
  8013c0:	85 c0                	test   %eax,%eax
  8013c2:	74 17                	je     8013db <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c4:	83 ec 04             	sub    $0x4,%esp
  8013c7:	ff 75 10             	pushl  0x10(%ebp)
  8013ca:	ff 75 0c             	pushl  0xc(%ebp)
  8013cd:	52                   	push   %edx
  8013ce:	ff d0                	call   *%eax
  8013d0:	89 c2                	mov    %eax,%edx
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	eb 09                	jmp    8013e0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013d7:	89 c2                	mov    %eax,%edx
  8013d9:	eb 05                	jmp    8013e0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013e0:	89 d0                	mov    %edx,%eax
  8013e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    

008013e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	57                   	push   %edi
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fb:	eb 21                	jmp    80141e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013fd:	83 ec 04             	sub    $0x4,%esp
  801400:	89 f0                	mov    %esi,%eax
  801402:	29 d8                	sub    %ebx,%eax
  801404:	50                   	push   %eax
  801405:	89 d8                	mov    %ebx,%eax
  801407:	03 45 0c             	add    0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	57                   	push   %edi
  80140c:	e8 45 ff ff ff       	call   801356 <read>
		if (m < 0)
  801411:	83 c4 10             	add    $0x10,%esp
  801414:	85 c0                	test   %eax,%eax
  801416:	78 0c                	js     801424 <readn+0x3d>
			return m;
		if (m == 0)
  801418:	85 c0                	test   %eax,%eax
  80141a:	74 06                	je     801422 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80141c:	01 c3                	add    %eax,%ebx
  80141e:	39 f3                	cmp    %esi,%ebx
  801420:	72 db                	jb     8013fd <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801422:	89 d8                	mov    %ebx,%eax
}
  801424:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5f                   	pop    %edi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	53                   	push   %ebx
  801430:	83 ec 14             	sub    $0x14,%esp
  801433:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801436:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801439:	50                   	push   %eax
  80143a:	53                   	push   %ebx
  80143b:	e8 ad fc ff ff       	call   8010ed <fd_lookup>
  801440:	83 c4 08             	add    $0x8,%esp
  801443:	89 c2                	mov    %eax,%edx
  801445:	85 c0                	test   %eax,%eax
  801447:	78 68                	js     8014b1 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801449:	83 ec 08             	sub    $0x8,%esp
  80144c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801453:	ff 30                	pushl  (%eax)
  801455:	e8 e9 fc ff ff       	call   801143 <dev_lookup>
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 47                	js     8014a8 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801461:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801464:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801468:	75 21                	jne    80148b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80146a:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  80146f:	8b 40 48             	mov    0x48(%eax),%eax
  801472:	83 ec 04             	sub    $0x4,%esp
  801475:	53                   	push   %ebx
  801476:	50                   	push   %eax
  801477:	68 29 2b 80 00       	push   $0x802b29
  80147c:	e8 58 f0 ff ff       	call   8004d9 <cprintf>
		return -E_INVAL;
  801481:	83 c4 10             	add    $0x10,%esp
  801484:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801489:	eb 26                	jmp    8014b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80148b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80148e:	8b 52 0c             	mov    0xc(%edx),%edx
  801491:	85 d2                	test   %edx,%edx
  801493:	74 17                	je     8014ac <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	ff 75 10             	pushl  0x10(%ebp)
  80149b:	ff 75 0c             	pushl  0xc(%ebp)
  80149e:	50                   	push   %eax
  80149f:	ff d2                	call   *%edx
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	eb 09                	jmp    8014b1 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a8:	89 c2                	mov    %eax,%edx
  8014aa:	eb 05                	jmp    8014b1 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014b1:	89 d0                	mov    %edx,%eax
  8014b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014b6:	c9                   	leave  
  8014b7:	c3                   	ret    

008014b8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b8:	55                   	push   %ebp
  8014b9:	89 e5                	mov    %esp,%ebp
  8014bb:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014be:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014c1:	50                   	push   %eax
  8014c2:	ff 75 08             	pushl  0x8(%ebp)
  8014c5:	e8 23 fc ff ff       	call   8010ed <fd_lookup>
  8014ca:	83 c4 08             	add    $0x8,%esp
  8014cd:	85 c0                	test   %eax,%eax
  8014cf:	78 0e                	js     8014df <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014d1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d7:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	53                   	push   %ebx
  8014e5:	83 ec 14             	sub    $0x14,%esp
  8014e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ee:	50                   	push   %eax
  8014ef:	53                   	push   %ebx
  8014f0:	e8 f8 fb ff ff       	call   8010ed <fd_lookup>
  8014f5:	83 c4 08             	add    $0x8,%esp
  8014f8:	89 c2                	mov    %eax,%edx
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 65                	js     801563 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014fe:	83 ec 08             	sub    $0x8,%esp
  801501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801504:	50                   	push   %eax
  801505:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801508:	ff 30                	pushl  (%eax)
  80150a:	e8 34 fc ff ff       	call   801143 <dev_lookup>
  80150f:	83 c4 10             	add    $0x10,%esp
  801512:	85 c0                	test   %eax,%eax
  801514:	78 44                	js     80155a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801519:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80151d:	75 21                	jne    801540 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80151f:	a1 b0 67 80 00       	mov    0x8067b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801524:	8b 40 48             	mov    0x48(%eax),%eax
  801527:	83 ec 04             	sub    $0x4,%esp
  80152a:	53                   	push   %ebx
  80152b:	50                   	push   %eax
  80152c:	68 ec 2a 80 00       	push   $0x802aec
  801531:	e8 a3 ef ff ff       	call   8004d9 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80153e:	eb 23                	jmp    801563 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801540:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801543:	8b 52 18             	mov    0x18(%edx),%edx
  801546:	85 d2                	test   %edx,%edx
  801548:	74 14                	je     80155e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	ff 75 0c             	pushl  0xc(%ebp)
  801550:	50                   	push   %eax
  801551:	ff d2                	call   *%edx
  801553:	89 c2                	mov    %eax,%edx
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	eb 09                	jmp    801563 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155a:	89 c2                	mov    %eax,%edx
  80155c:	eb 05                	jmp    801563 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80155e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801563:	89 d0                	mov    %edx,%eax
  801565:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801568:	c9                   	leave  
  801569:	c3                   	ret    

0080156a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80156a:	55                   	push   %ebp
  80156b:	89 e5                	mov    %esp,%ebp
  80156d:	53                   	push   %ebx
  80156e:	83 ec 14             	sub    $0x14,%esp
  801571:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801574:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801577:	50                   	push   %eax
  801578:	ff 75 08             	pushl  0x8(%ebp)
  80157b:	e8 6d fb ff ff       	call   8010ed <fd_lookup>
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	89 c2                	mov    %eax,%edx
  801585:	85 c0                	test   %eax,%eax
  801587:	78 58                	js     8015e1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80158f:	50                   	push   %eax
  801590:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801593:	ff 30                	pushl  (%eax)
  801595:	e8 a9 fb ff ff       	call   801143 <dev_lookup>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 37                	js     8015d8 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015a4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015a8:	74 32                	je     8015dc <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015aa:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015ad:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015b4:	00 00 00 
	stat->st_isdir = 0;
  8015b7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015be:	00 00 00 
	stat->st_dev = dev;
  8015c1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	ff 75 f0             	pushl  -0x10(%ebp)
  8015ce:	ff 50 14             	call   *0x14(%eax)
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	eb 09                	jmp    8015e1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d8:	89 c2                	mov    %eax,%edx
  8015da:	eb 05                	jmp    8015e1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015dc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015e1:	89 d0                	mov    %edx,%eax
  8015e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	56                   	push   %esi
  8015ec:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	6a 00                	push   $0x0
  8015f2:	ff 75 08             	pushl  0x8(%ebp)
  8015f5:	e8 e7 01 00 00       	call   8017e1 <open>
  8015fa:	89 c3                	mov    %eax,%ebx
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	85 db                	test   %ebx,%ebx
  801601:	78 1b                	js     80161e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801603:	83 ec 08             	sub    $0x8,%esp
  801606:	ff 75 0c             	pushl  0xc(%ebp)
  801609:	53                   	push   %ebx
  80160a:	e8 5b ff ff ff       	call   80156a <fstat>
  80160f:	89 c6                	mov    %eax,%esi
	close(fd);
  801611:	89 1c 24             	mov    %ebx,(%esp)
  801614:	e8 fd fb ff ff       	call   801216 <close>
	return r;
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	89 f0                	mov    %esi,%eax
}
  80161e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801621:	5b                   	pop    %ebx
  801622:	5e                   	pop    %esi
  801623:	5d                   	pop    %ebp
  801624:	c3                   	ret    

00801625 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	56                   	push   %esi
  801629:	53                   	push   %ebx
  80162a:	89 c6                	mov    %eax,%esi
  80162c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80162e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801635:	75 12                	jne    801649 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801637:	83 ec 0c             	sub    $0xc,%esp
  80163a:	6a 03                	push   $0x3
  80163c:	e8 72 0c 00 00       	call   8022b3 <ipc_find_env>
  801641:	a3 00 50 80 00       	mov    %eax,0x805000
  801646:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801649:	6a 07                	push   $0x7
  80164b:	68 00 70 80 00       	push   $0x807000
  801650:	56                   	push   %esi
  801651:	ff 35 00 50 80 00    	pushl  0x805000
  801657:	e8 06 0c 00 00       	call   802262 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80165c:	83 c4 0c             	add    $0xc,%esp
  80165f:	6a 00                	push   $0x0
  801661:	53                   	push   %ebx
  801662:	6a 00                	push   $0x0
  801664:	e8 93 0b 00 00       	call   8021fc <ipc_recv>
}
  801669:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5e                   	pop    %esi
  80166e:	5d                   	pop    %ebp
  80166f:	c3                   	ret    

00801670 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801670:	55                   	push   %ebp
  801671:	89 e5                	mov    %esp,%ebp
  801673:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	8b 40 0c             	mov    0xc(%eax),%eax
  80167c:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801681:	8b 45 0c             	mov    0xc(%ebp),%eax
  801684:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801689:	ba 00 00 00 00       	mov    $0x0,%edx
  80168e:	b8 02 00 00 00       	mov    $0x2,%eax
  801693:	e8 8d ff ff ff       	call   801625 <fsipc>
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a6:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8016ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b0:	b8 06 00 00 00       	mov    $0x6,%eax
  8016b5:	e8 6b ff ff ff       	call   801625 <fsipc>
}
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 04             	sub    $0x4,%esp
  8016c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cc:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8016db:	e8 45 ff ff ff       	call   801625 <fsipc>
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	85 d2                	test   %edx,%edx
  8016e4:	78 2c                	js     801712 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	68 00 70 80 00       	push   $0x807000
  8016ee:	53                   	push   %ebx
  8016ef:	e8 69 f3 ff ff       	call   800a5d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f4:	a1 80 70 80 00       	mov    0x807080,%eax
  8016f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ff:	a1 84 70 80 00       	mov    0x807084,%eax
  801704:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801712:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 08             	sub    $0x8,%esp
  80171d:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801720:	8b 55 08             	mov    0x8(%ebp),%edx
  801723:	8b 52 0c             	mov    0xc(%edx),%edx
  801726:	89 15 00 70 80 00    	mov    %edx,0x807000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  80172c:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801731:	76 05                	jbe    801738 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801733:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801738:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(req->req_buf, buf, movesize);
  80173d:	83 ec 04             	sub    $0x4,%esp
  801740:	50                   	push   %eax
  801741:	ff 75 0c             	pushl  0xc(%ebp)
  801744:	68 08 70 80 00       	push   $0x807008
  801749:	e8 a1 f4 ff ff       	call   800bef <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80174e:	ba 00 00 00 00       	mov    $0x0,%edx
  801753:	b8 04 00 00 00       	mov    $0x4,%eax
  801758:	e8 c8 fe ff ff       	call   801625 <fsipc>
	return write;
}
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	56                   	push   %esi
  801763:	53                   	push   %ebx
  801764:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801767:	8b 45 08             	mov    0x8(%ebp),%eax
  80176a:	8b 40 0c             	mov    0xc(%eax),%eax
  80176d:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801772:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801778:	ba 00 00 00 00       	mov    $0x0,%edx
  80177d:	b8 03 00 00 00       	mov    $0x3,%eax
  801782:	e8 9e fe ff ff       	call   801625 <fsipc>
  801787:	89 c3                	mov    %eax,%ebx
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 4b                	js     8017d8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80178d:	39 c6                	cmp    %eax,%esi
  80178f:	73 16                	jae    8017a7 <devfile_read+0x48>
  801791:	68 58 2b 80 00       	push   $0x802b58
  801796:	68 5f 2b 80 00       	push   $0x802b5f
  80179b:	6a 7c                	push   $0x7c
  80179d:	68 74 2b 80 00       	push   $0x802b74
  8017a2:	e8 59 ec ff ff       	call   800400 <_panic>
	assert(r <= PGSIZE);
  8017a7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017ac:	7e 16                	jle    8017c4 <devfile_read+0x65>
  8017ae:	68 7f 2b 80 00       	push   $0x802b7f
  8017b3:	68 5f 2b 80 00       	push   $0x802b5f
  8017b8:	6a 7d                	push   $0x7d
  8017ba:	68 74 2b 80 00       	push   $0x802b74
  8017bf:	e8 3c ec ff ff       	call   800400 <_panic>
	memmove(buf, &fsipcbuf, r);
  8017c4:	83 ec 04             	sub    $0x4,%esp
  8017c7:	50                   	push   %eax
  8017c8:	68 00 70 80 00       	push   $0x807000
  8017cd:	ff 75 0c             	pushl  0xc(%ebp)
  8017d0:	e8 1a f4 ff ff       	call   800bef <memmove>
	return r;
  8017d5:	83 c4 10             	add    $0x10,%esp
}
  8017d8:	89 d8                	mov    %ebx,%eax
  8017da:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017dd:	5b                   	pop    %ebx
  8017de:	5e                   	pop    %esi
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	53                   	push   %ebx
  8017e5:	83 ec 20             	sub    $0x20,%esp
  8017e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017eb:	53                   	push   %ebx
  8017ec:	e8 33 f2 ff ff       	call   800a24 <strlen>
  8017f1:	83 c4 10             	add    $0x10,%esp
  8017f4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017f9:	7f 67                	jg     801862 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017fb:	83 ec 0c             	sub    $0xc,%esp
  8017fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801801:	50                   	push   %eax
  801802:	e8 97 f8 ff ff       	call   80109e <fd_alloc>
  801807:	83 c4 10             	add    $0x10,%esp
		return r;
  80180a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80180c:	85 c0                	test   %eax,%eax
  80180e:	78 57                	js     801867 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801810:	83 ec 08             	sub    $0x8,%esp
  801813:	53                   	push   %ebx
  801814:	68 00 70 80 00       	push   $0x807000
  801819:	e8 3f f2 ff ff       	call   800a5d <strcpy>
	fsipcbuf.open.req_omode = mode;
  80181e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801821:	a3 00 74 80 00       	mov    %eax,0x807400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801826:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801829:	b8 01 00 00 00       	mov    $0x1,%eax
  80182e:	e8 f2 fd ff ff       	call   801625 <fsipc>
  801833:	89 c3                	mov    %eax,%ebx
  801835:	83 c4 10             	add    $0x10,%esp
  801838:	85 c0                	test   %eax,%eax
  80183a:	79 14                	jns    801850 <open+0x6f>
		fd_close(fd, 0);
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	6a 00                	push   $0x0
  801841:	ff 75 f4             	pushl  -0xc(%ebp)
  801844:	e8 4d f9 ff ff       	call   801196 <fd_close>
		return r;
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	89 da                	mov    %ebx,%edx
  80184e:	eb 17                	jmp    801867 <open+0x86>
	}

	return fd2num(fd);
  801850:	83 ec 0c             	sub    $0xc,%esp
  801853:	ff 75 f4             	pushl  -0xc(%ebp)
  801856:	e8 1c f8 ff ff       	call   801077 <fd2num>
  80185b:	89 c2                	mov    %eax,%edx
  80185d:	83 c4 10             	add    $0x10,%esp
  801860:	eb 05                	jmp    801867 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801862:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801867:	89 d0                	mov    %edx,%eax
  801869:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186c:	c9                   	leave  
  80186d:	c3                   	ret    

0080186e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80186e:	55                   	push   %ebp
  80186f:	89 e5                	mov    %esp,%ebp
  801871:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801874:	ba 00 00 00 00       	mov    $0x0,%edx
  801879:	b8 08 00 00 00       	mov    $0x8,%eax
  80187e:	e8 a2 fd ff ff       	call   801625 <fsipc>
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	57                   	push   %edi
  801889:	56                   	push   %esi
  80188a:	53                   	push   %ebx
  80188b:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801891:	6a 00                	push   $0x0
  801893:	ff 75 08             	pushl  0x8(%ebp)
  801896:	e8 46 ff ff ff       	call   8017e1 <open>
  80189b:	89 c1                	mov    %eax,%ecx
  80189d:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	0f 88 c6 04 00 00    	js     801d74 <spawn+0x4ef>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  8018ae:	83 ec 04             	sub    $0x4,%esp
  8018b1:	68 00 02 00 00       	push   $0x200
  8018b6:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8018bc:	50                   	push   %eax
  8018bd:	51                   	push   %ecx
  8018be:	e8 24 fb ff ff       	call   8013e7 <readn>
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	3d 00 02 00 00       	cmp    $0x200,%eax
  8018cb:	75 0c                	jne    8018d9 <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  8018cd:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  8018d4:	45 4c 46 
  8018d7:	74 33                	je     80190c <spawn+0x87>
		close(fd);
  8018d9:	83 ec 0c             	sub    $0xc,%esp
  8018dc:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8018e2:	e8 2f f9 ff ff       	call   801216 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8018e7:	83 c4 0c             	add    $0xc,%esp
  8018ea:	68 7f 45 4c 46       	push   $0x464c457f
  8018ef:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8018f5:	68 8b 2b 80 00       	push   $0x802b8b
  8018fa:	e8 da eb ff ff       	call   8004d9 <cprintf>
		return -E_NOT_EXEC;
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  801907:	e9 c8 04 00 00       	jmp    801dd4 <spawn+0x54f>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80190c:	b8 07 00 00 00       	mov    $0x7,%eax
  801911:	cd 30                	int    $0x30
  801913:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  801919:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  80191f:	85 c0                	test   %eax,%eax
  801921:	0f 88 55 04 00 00    	js     801d7c <spawn+0x4f7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801927:	89 c6                	mov    %eax,%esi
  801929:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  80192f:	6b f6 78             	imul   $0x78,%esi,%esi
  801932:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801938:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  80193e:	b9 11 00 00 00       	mov    $0x11,%ecx
  801943:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801945:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80194b:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  801951:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  801956:	be 00 00 00 00       	mov    $0x0,%esi
  80195b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80195e:	eb 13                	jmp    801973 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  801960:	83 ec 0c             	sub    $0xc,%esp
  801963:	50                   	push   %eax
  801964:	e8 bb f0 ff ff       	call   800a24 <strlen>
  801969:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  80196d:	83 c3 01             	add    $0x1,%ebx
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  80197a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80197d:	85 c0                	test   %eax,%eax
  80197f:	75 df                	jne    801960 <spawn+0xdb>
  801981:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  801987:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  80198d:	bf 00 10 40 00       	mov    $0x401000,%edi
  801992:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801994:	89 fa                	mov    %edi,%edx
  801996:	83 e2 fc             	and    $0xfffffffc,%edx
  801999:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8019a0:	29 c2                	sub    %eax,%edx
  8019a2:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8019a8:	8d 42 f8             	lea    -0x8(%edx),%eax
  8019ab:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8019b0:	0f 86 d6 03 00 00    	jbe    801d8c <spawn+0x507>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8019b6:	83 ec 04             	sub    $0x4,%esp
  8019b9:	6a 07                	push   $0x7
  8019bb:	68 00 00 40 00       	push   $0x400000
  8019c0:	6a 00                	push   $0x0
  8019c2:	e8 a0 f4 ff ff       	call   800e67 <sys_page_alloc>
  8019c7:	83 c4 10             	add    $0x10,%esp
  8019ca:	85 c0                	test   %eax,%eax
  8019cc:	0f 88 02 04 00 00    	js     801dd4 <spawn+0x54f>
  8019d2:	be 00 00 00 00       	mov    $0x0,%esi
  8019d7:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  8019dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8019e0:	eb 30                	jmp    801a12 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  8019e2:	8d 87 00 d0 3f ee    	lea    -0x11c03000(%edi),%eax
  8019e8:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  8019ee:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8019f1:	83 ec 08             	sub    $0x8,%esp
  8019f4:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019f7:	57                   	push   %edi
  8019f8:	e8 60 f0 ff ff       	call   800a5d <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019fd:	83 c4 04             	add    $0x4,%esp
  801a00:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801a03:	e8 1c f0 ff ff       	call   800a24 <strlen>
  801a08:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  801a0c:	83 c6 01             	add    $0x1,%esi
  801a0f:	83 c4 10             	add    $0x10,%esp
  801a12:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  801a18:	7c c8                	jl     8019e2 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  801a1a:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801a20:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801a26:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  801a2d:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801a33:	74 19                	je     801a4e <spawn+0x1c9>
  801a35:	68 14 2c 80 00       	push   $0x802c14
  801a3a:	68 5f 2b 80 00       	push   $0x802b5f
  801a3f:	68 f1 00 00 00       	push   $0xf1
  801a44:	68 a5 2b 80 00       	push   $0x802ba5
  801a49:	e8 b2 e9 ff ff       	call   800400 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  801a4e:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801a54:	89 f8                	mov    %edi,%eax
  801a56:	2d 00 30 c0 11       	sub    $0x11c03000,%eax
  801a5b:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  801a5e:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  801a64:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  801a67:	8d 87 f8 cf 3f ee    	lea    -0x11c03008(%edi),%eax
  801a6d:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	6a 07                	push   $0x7
  801a78:	68 00 d0 7f ee       	push   $0xee7fd000
  801a7d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a83:	68 00 00 40 00       	push   $0x400000
  801a88:	6a 00                	push   $0x0
  801a8a:	e8 1b f4 ff ff       	call   800eaa <sys_page_map>
  801a8f:	89 c3                	mov    %eax,%ebx
  801a91:	83 c4 20             	add    $0x20,%esp
  801a94:	85 c0                	test   %eax,%eax
  801a96:	0f 88 24 03 00 00    	js     801dc0 <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	68 00 00 40 00       	push   $0x400000
  801aa4:	6a 00                	push   $0x0
  801aa6:	e8 41 f4 ff ff       	call   800eec <sys_page_unmap>
  801aab:	89 c3                	mov    %eax,%ebx
  801aad:	83 c4 10             	add    $0x10,%esp
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	0f 88 08 03 00 00    	js     801dc0 <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801ab8:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801abe:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801ac5:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801acb:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801ad2:	00 00 00 
  801ad5:	e9 84 01 00 00       	jmp    801c5e <spawn+0x3d9>
		if (ph->p_type != ELF_PROG_LOAD)
  801ada:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801ae0:	83 38 01             	cmpl   $0x1,(%eax)
  801ae3:	0f 85 67 01 00 00    	jne    801c50 <spawn+0x3cb>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801ae9:	89 c1                	mov    %eax,%ecx
  801aeb:	8b 40 18             	mov    0x18(%eax),%eax
  801aee:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801af4:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801af7:	83 f8 01             	cmp    $0x1,%eax
  801afa:	19 c0                	sbb    %eax,%eax
  801afc:	83 e0 fe             	and    $0xfffffffe,%eax
  801aff:	83 c0 07             	add    $0x7,%eax
  801b02:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801b08:	89 c8                	mov    %ecx,%eax
  801b0a:	8b 49 04             	mov    0x4(%ecx),%ecx
  801b0d:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  801b13:	8b 78 10             	mov    0x10(%eax),%edi
  801b16:	8b 48 14             	mov    0x14(%eax),%ecx
  801b19:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  801b1f:	8b 70 08             	mov    0x8(%eax),%esi
{
	int i, r;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801b22:	89 f0                	mov    %esi,%eax
  801b24:	25 ff 0f 00 00       	and    $0xfff,%eax
  801b29:	74 10                	je     801b3b <spawn+0x2b6>
		va -= i;
  801b2b:	29 c6                	sub    %eax,%esi
		memsz += i;
  801b2d:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  801b33:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801b35:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801b3b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b40:	e9 f9 00 00 00       	jmp    801c3e <spawn+0x3b9>
		if (i >= filesz) {
  801b45:	39 fb                	cmp    %edi,%ebx
  801b47:	72 27                	jb     801b70 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  801b49:	83 ec 04             	sub    $0x4,%esp
  801b4c:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801b52:	56                   	push   %esi
  801b53:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801b59:	e8 09 f3 ff ff       	call   800e67 <sys_page_alloc>
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	85 c0                	test   %eax,%eax
  801b63:	0f 89 c9 00 00 00    	jns    801c32 <spawn+0x3ad>
  801b69:	89 c7                	mov    %eax,%edi
  801b6b:	e9 2d 02 00 00       	jmp    801d9d <spawn+0x518>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801b70:	83 ec 04             	sub    $0x4,%esp
  801b73:	6a 07                	push   $0x7
  801b75:	68 00 00 40 00       	push   $0x400000
  801b7a:	6a 00                	push   $0x0
  801b7c:	e8 e6 f2 ff ff       	call   800e67 <sys_page_alloc>
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	85 c0                	test   %eax,%eax
  801b86:	0f 88 07 02 00 00    	js     801d93 <spawn+0x50e>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b95:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  801b9b:	50                   	push   %eax
  801b9c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ba2:	e8 11 f9 ff ff       	call   8014b8 <seek>
  801ba7:	83 c4 10             	add    $0x10,%esp
  801baa:	85 c0                	test   %eax,%eax
  801bac:	0f 88 e5 01 00 00    	js     801d97 <spawn+0x512>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801bb2:	83 ec 04             	sub    $0x4,%esp
  801bb5:	89 fa                	mov    %edi,%edx
  801bb7:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  801bbd:	89 d0                	mov    %edx,%eax
  801bbf:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  801bc5:	76 05                	jbe    801bcc <spawn+0x347>
  801bc7:	b8 00 10 00 00       	mov    $0x1000,%eax
  801bcc:	50                   	push   %eax
  801bcd:	68 00 00 40 00       	push   $0x400000
  801bd2:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801bd8:	e8 0a f8 ff ff       	call   8013e7 <readn>
  801bdd:	83 c4 10             	add    $0x10,%esp
  801be0:	85 c0                	test   %eax,%eax
  801be2:	0f 88 b3 01 00 00    	js     801d9b <spawn+0x516>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  801be8:	83 ec 0c             	sub    $0xc,%esp
  801beb:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801bf1:	56                   	push   %esi
  801bf2:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  801bf8:	68 00 00 40 00       	push   $0x400000
  801bfd:	6a 00                	push   $0x0
  801bff:	e8 a6 f2 ff ff       	call   800eaa <sys_page_map>
  801c04:	83 c4 20             	add    $0x20,%esp
  801c07:	85 c0                	test   %eax,%eax
  801c09:	79 15                	jns    801c20 <spawn+0x39b>
				panic("spawn: sys_page_map data: %i", r);
  801c0b:	50                   	push   %eax
  801c0c:	68 b1 2b 80 00       	push   $0x802bb1
  801c11:	68 23 01 00 00       	push   $0x123
  801c16:	68 a5 2b 80 00       	push   $0x802ba5
  801c1b:	e8 e0 e7 ff ff       	call   800400 <_panic>
			sys_page_unmap(0, UTEMP);
  801c20:	83 ec 08             	sub    $0x8,%esp
  801c23:	68 00 00 40 00       	push   $0x400000
  801c28:	6a 00                	push   $0x0
  801c2a:	e8 bd f2 ff ff       	call   800eec <sys_page_unmap>
  801c2f:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  801c32:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801c38:	81 c6 00 10 00 00    	add    $0x1000,%esi
  801c3e:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  801c44:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  801c4a:	0f 82 f5 fe ff ff    	jb     801b45 <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c50:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  801c57:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  801c5e:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801c65:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  801c6b:	0f 8c 69 fe ff ff    	jl     801ada <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801c7a:	e8 97 f5 ff ff       	call   801216 <close>
  801c7f:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  801c82:	ba 00 00 00 00       	mov    $0x0,%edx
  801c87:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c8c:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        {
                if (!(uvpd[pn >> 10] & PTE_P) && !(pn % NPTENTRIES))
  801c92:	89 d8                	mov    %ebx,%eax
  801c94:	c1 f8 0a             	sar    $0xa,%eax
  801c97:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c9e:	a8 01                	test   $0x1,%al
  801ca0:	75 10                	jne    801cb2 <spawn+0x42d>
  801ca2:	f7 c2 ff 03 00 00    	test   $0x3ff,%edx
  801ca8:	75 08                	jne    801cb2 <spawn+0x42d>
                {
                        pn += NPTENTRIES - 1;
  801caa:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  801cb0:	eb 54                	jmp    801d06 <spawn+0x481>
                        continue;
                }
                if ((uvpt[pn] & PTE_P) && (uvpt[pn] & PTE_SHARE))
  801cb2:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801cb9:	a8 01                	test   $0x1,%al
  801cbb:	74 49                	je     801d06 <spawn+0x481>
  801cbd:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801cc4:	f6 c4 04             	test   $0x4,%ah
  801cc7:	74 3d                	je     801d06 <spawn+0x481>
                {
                        va = (void*)(pn << PGSHIFT);
  801cc9:	89 da                	mov    %ebx,%edx
  801ccb:	c1 e2 0c             	shl    $0xc,%edx
                        if ((sys_page_map(0, va, child, va, uvpt[pn] & PTE_SYSCALL)))
  801cce:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	25 07 0e 00 00       	and    $0xe07,%eax
  801cdd:	50                   	push   %eax
  801cde:	52                   	push   %edx
  801cdf:	56                   	push   %esi
  801ce0:	52                   	push   %edx
  801ce1:	6a 00                	push   $0x0
  801ce3:	e8 c2 f1 ff ff       	call   800eaa <sys_page_map>
  801ce8:	83 c4 20             	add    $0x20,%esp
  801ceb:	85 c0                	test   %eax,%eax
  801ced:	74 17                	je     801d06 <spawn+0x481>
                                panic("copy_shared_pages");
  801cef:	83 ec 04             	sub    $0x4,%esp
  801cf2:	68 ce 2b 80 00       	push   $0x802bce
  801cf7:	68 3c 01 00 00       	push   $0x13c
  801cfc:	68 a5 2b 80 00       	push   $0x802ba5
  801d01:	e8 fa e6 ff ff       	call   800400 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  801d06:	83 c3 01             	add    $0x1,%ebx
  801d09:	89 da                	mov    %ebx,%edx
  801d0b:	81 fb fe e7 0e 00    	cmp    $0xee7fe,%ebx
  801d11:	0f 86 7b ff ff ff    	jbe    801c92 <spawn+0x40d>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %i", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d17:	83 ec 08             	sub    $0x8,%esp
  801d1a:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d20:	50                   	push   %eax
  801d21:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d27:	e8 44 f2 ff ff       	call   800f70 <sys_env_set_trapframe>
  801d2c:	83 c4 10             	add    $0x10,%esp
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	79 15                	jns    801d48 <spawn+0x4c3>
		panic("sys_env_set_trapframe: %i", r);
  801d33:	50                   	push   %eax
  801d34:	68 e0 2b 80 00       	push   $0x802be0
  801d39:	68 85 00 00 00       	push   $0x85
  801d3e:	68 a5 2b 80 00       	push   $0x802ba5
  801d43:	e8 b8 e6 ff ff       	call   800400 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d48:	83 ec 08             	sub    $0x8,%esp
  801d4b:	6a 02                	push   $0x2
  801d4d:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801d53:	e8 d6 f1 ff ff       	call   800f2e <sys_env_set_status>
  801d58:	83 c4 10             	add    $0x10,%esp
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	79 25                	jns    801d84 <spawn+0x4ff>
		panic("sys_env_set_status: %i", r);
  801d5f:	50                   	push   %eax
  801d60:	68 fa 2b 80 00       	push   $0x802bfa
  801d65:	68 88 00 00 00       	push   $0x88
  801d6a:	68 a5 2b 80 00       	push   $0x802ba5
  801d6f:	e8 8c e6 ff ff       	call   800400 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801d74:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d7a:	eb 58                	jmp    801dd4 <spawn+0x54f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801d7c:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d82:	eb 50                	jmp    801dd4 <spawn+0x54f>
		panic("sys_env_set_trapframe: %i", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %i", r);

	return child;
  801d84:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  801d8a:	eb 48                	jmp    801dd4 <spawn+0x54f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801d8c:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  801d91:	eb 41                	jmp    801dd4 <spawn+0x54f>
  801d93:	89 c7                	mov    %eax,%edi
  801d95:	eb 06                	jmp    801d9d <spawn+0x518>
  801d97:	89 c7                	mov    %eax,%edi
  801d99:	eb 02                	jmp    801d9d <spawn+0x518>
  801d9b:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %i", r);

	return child;

error:
	sys_env_destroy(child);
  801d9d:	83 ec 0c             	sub    $0xc,%esp
  801da0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801da6:	e8 3d f0 ff ff       	call   800de8 <sys_env_destroy>
	close(fd);
  801dab:	83 c4 04             	add    $0x4,%esp
  801dae:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801db4:	e8 5d f4 ff ff       	call   801216 <close>
	return r;
  801db9:	83 c4 10             	add    $0x10,%esp
  801dbc:	89 f8                	mov    %edi,%eax
  801dbe:	eb 14                	jmp    801dd4 <spawn+0x54f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801dc0:	83 ec 08             	sub    $0x8,%esp
  801dc3:	68 00 00 40 00       	push   $0x400000
  801dc8:	6a 00                	push   $0x0
  801dca:	e8 1d f1 ff ff       	call   800eec <sys_page_unmap>
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801dd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd7:	5b                   	pop    %ebx
  801dd8:	5e                   	pop    %esi
  801dd9:	5f                   	pop    %edi
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801ddc:	55                   	push   %ebp
  801ddd:	89 e5                	mov    %esp,%ebp
  801ddf:	56                   	push   %esi
  801de0:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801de1:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801de4:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801de9:	eb 03                	jmp    801dee <spawnl+0x12>
		argc++;
  801deb:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801dee:	83 c2 04             	add    $0x4,%edx
  801df1:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801df5:	75 f4                	jne    801deb <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801df7:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801dfe:	83 e2 f0             	and    $0xfffffff0,%edx
  801e01:	29 d4                	sub    %edx,%esp
  801e03:	8d 54 24 03          	lea    0x3(%esp),%edx
  801e07:	c1 ea 02             	shr    $0x2,%edx
  801e0a:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801e11:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e16:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801e1d:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e24:	00 
  801e25:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e27:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2c:	eb 0a                	jmp    801e38 <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801e2e:	83 c0 01             	add    $0x1,%eax
  801e31:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801e35:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801e38:	39 d0                	cmp    %edx,%eax
  801e3a:	75 f2                	jne    801e2e <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801e3c:	83 ec 08             	sub    $0x8,%esp
  801e3f:	56                   	push   %esi
  801e40:	ff 75 08             	pushl  0x8(%ebp)
  801e43:	e8 3d fa ff ff       	call   801885 <spawn>
}
  801e48:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e4b:	5b                   	pop    %ebx
  801e4c:	5e                   	pop    %esi
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	56                   	push   %esi
  801e53:	53                   	push   %ebx
  801e54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e57:	83 ec 0c             	sub    $0xc,%esp
  801e5a:	ff 75 08             	pushl  0x8(%ebp)
  801e5d:	e8 25 f2 ff ff       	call   801087 <fd2data>
  801e62:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e64:	83 c4 08             	add    $0x8,%esp
  801e67:	68 3a 2c 80 00       	push   $0x802c3a
  801e6c:	53                   	push   %ebx
  801e6d:	e8 eb eb ff ff       	call   800a5d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e72:	8b 56 04             	mov    0x4(%esi),%edx
  801e75:	89 d0                	mov    %edx,%eax
  801e77:	2b 06                	sub    (%esi),%eax
  801e79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e86:	00 00 00 
	stat->st_dev = &devpipe;
  801e89:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801e90:	47 80 00 
	return 0;
}
  801e93:	b8 00 00 00 00       	mov    $0x0,%eax
  801e98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e9b:	5b                   	pop    %ebx
  801e9c:	5e                   	pop    %esi
  801e9d:	5d                   	pop    %ebp
  801e9e:	c3                   	ret    

00801e9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e9f:	55                   	push   %ebp
  801ea0:	89 e5                	mov    %esp,%ebp
  801ea2:	53                   	push   %ebx
  801ea3:	83 ec 0c             	sub    $0xc,%esp
  801ea6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ea9:	53                   	push   %ebx
  801eaa:	6a 00                	push   $0x0
  801eac:	e8 3b f0 ff ff       	call   800eec <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801eb1:	89 1c 24             	mov    %ebx,(%esp)
  801eb4:	e8 ce f1 ff ff       	call   801087 <fd2data>
  801eb9:	83 c4 08             	add    $0x8,%esp
  801ebc:	50                   	push   %eax
  801ebd:	6a 00                	push   $0x0
  801ebf:	e8 28 f0 ff ff       	call   800eec <sys_page_unmap>
}
  801ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	57                   	push   %edi
  801ecd:	56                   	push   %esi
  801ece:	53                   	push   %ebx
  801ecf:	83 ec 1c             	sub    $0x1c,%esp
  801ed2:	89 c7                	mov    %eax,%edi
  801ed4:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ed6:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  801edb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ede:	83 ec 0c             	sub    $0xc,%esp
  801ee1:	57                   	push   %edi
  801ee2:	e8 04 04 00 00       	call   8022eb <pageref>
  801ee7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801eea:	89 34 24             	mov    %esi,(%esp)
  801eed:	e8 f9 03 00 00       	call   8022eb <pageref>
  801ef2:	83 c4 10             	add    $0x10,%esp
  801ef5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ef8:	0f 94 c0             	sete   %al
  801efb:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801efe:	8b 15 b0 67 80 00    	mov    0x8067b0,%edx
  801f04:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f07:	39 cb                	cmp    %ecx,%ebx
  801f09:	74 15                	je     801f20 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801f0b:	8b 52 58             	mov    0x58(%edx),%edx
  801f0e:	50                   	push   %eax
  801f0f:	52                   	push   %edx
  801f10:	53                   	push   %ebx
  801f11:	68 48 2c 80 00       	push   $0x802c48
  801f16:	e8 be e5 ff ff       	call   8004d9 <cprintf>
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	eb b6                	jmp    801ed6 <_pipeisclosed+0xd>
	}
}
  801f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f23:	5b                   	pop    %ebx
  801f24:	5e                   	pop    %esi
  801f25:	5f                   	pop    %edi
  801f26:	5d                   	pop    %ebp
  801f27:	c3                   	ret    

00801f28 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	57                   	push   %edi
  801f2c:	56                   	push   %esi
  801f2d:	53                   	push   %ebx
  801f2e:	83 ec 28             	sub    $0x28,%esp
  801f31:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801f34:	56                   	push   %esi
  801f35:	e8 4d f1 ff ff       	call   801087 <fd2data>
  801f3a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f44:	eb 4b                	jmp    801f91 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801f46:	89 da                	mov    %ebx,%edx
  801f48:	89 f0                	mov    %esi,%eax
  801f4a:	e8 7a ff ff ff       	call   801ec9 <_pipeisclosed>
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	75 48                	jne    801f9b <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801f53:	e8 f0 ee ff ff       	call   800e48 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f58:	8b 43 04             	mov    0x4(%ebx),%eax
  801f5b:	8b 0b                	mov    (%ebx),%ecx
  801f5d:	8d 51 20             	lea    0x20(%ecx),%edx
  801f60:	39 d0                	cmp    %edx,%eax
  801f62:	73 e2                	jae    801f46 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f67:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f6b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f6e:	89 c2                	mov    %eax,%edx
  801f70:	c1 fa 1f             	sar    $0x1f,%edx
  801f73:	89 d1                	mov    %edx,%ecx
  801f75:	c1 e9 1b             	shr    $0x1b,%ecx
  801f78:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f7b:	83 e2 1f             	and    $0x1f,%edx
  801f7e:	29 ca                	sub    %ecx,%edx
  801f80:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f84:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f88:	83 c0 01             	add    $0x1,%eax
  801f8b:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f8e:	83 c7 01             	add    $0x1,%edi
  801f91:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f94:	75 c2                	jne    801f58 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f96:	8b 45 10             	mov    0x10(%ebp),%eax
  801f99:	eb 05                	jmp    801fa0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f9b:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801fa0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fa3:	5b                   	pop    %ebx
  801fa4:	5e                   	pop    %esi
  801fa5:	5f                   	pop    %edi
  801fa6:	5d                   	pop    %ebp
  801fa7:	c3                   	ret    

00801fa8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fa8:	55                   	push   %ebp
  801fa9:	89 e5                	mov    %esp,%ebp
  801fab:	57                   	push   %edi
  801fac:	56                   	push   %esi
  801fad:	53                   	push   %ebx
  801fae:	83 ec 18             	sub    $0x18,%esp
  801fb1:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801fb4:	57                   	push   %edi
  801fb5:	e8 cd f0 ff ff       	call   801087 <fd2data>
  801fba:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fbc:	83 c4 10             	add    $0x10,%esp
  801fbf:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc4:	eb 3d                	jmp    802003 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801fc6:	85 db                	test   %ebx,%ebx
  801fc8:	74 04                	je     801fce <devpipe_read+0x26>
				return i;
  801fca:	89 d8                	mov    %ebx,%eax
  801fcc:	eb 44                	jmp    802012 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801fce:	89 f2                	mov    %esi,%edx
  801fd0:	89 f8                	mov    %edi,%eax
  801fd2:	e8 f2 fe ff ff       	call   801ec9 <_pipeisclosed>
  801fd7:	85 c0                	test   %eax,%eax
  801fd9:	75 32                	jne    80200d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801fdb:	e8 68 ee ff ff       	call   800e48 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801fe0:	8b 06                	mov    (%esi),%eax
  801fe2:	3b 46 04             	cmp    0x4(%esi),%eax
  801fe5:	74 df                	je     801fc6 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fe7:	99                   	cltd   
  801fe8:	c1 ea 1b             	shr    $0x1b,%edx
  801feb:	01 d0                	add    %edx,%eax
  801fed:	83 e0 1f             	and    $0x1f,%eax
  801ff0:	29 d0                	sub    %edx,%eax
  801ff2:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ff7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ffa:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ffd:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802000:	83 c3 01             	add    $0x1,%ebx
  802003:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802006:	75 d8                	jne    801fe0 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802008:	8b 45 10             	mov    0x10(%ebp),%eax
  80200b:	eb 05                	jmp    802012 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80200d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802015:	5b                   	pop    %ebx
  802016:	5e                   	pop    %esi
  802017:	5f                   	pop    %edi
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    

0080201a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80201a:	55                   	push   %ebp
  80201b:	89 e5                	mov    %esp,%ebp
  80201d:	56                   	push   %esi
  80201e:	53                   	push   %ebx
  80201f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802025:	50                   	push   %eax
  802026:	e8 73 f0 ff ff       	call   80109e <fd_alloc>
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	89 c2                	mov    %eax,%edx
  802030:	85 c0                	test   %eax,%eax
  802032:	0f 88 2c 01 00 00    	js     802164 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802038:	83 ec 04             	sub    $0x4,%esp
  80203b:	68 07 04 00 00       	push   $0x407
  802040:	ff 75 f4             	pushl  -0xc(%ebp)
  802043:	6a 00                	push   $0x0
  802045:	e8 1d ee ff ff       	call   800e67 <sys_page_alloc>
  80204a:	83 c4 10             	add    $0x10,%esp
  80204d:	89 c2                	mov    %eax,%edx
  80204f:	85 c0                	test   %eax,%eax
  802051:	0f 88 0d 01 00 00    	js     802164 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802057:	83 ec 0c             	sub    $0xc,%esp
  80205a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80205d:	50                   	push   %eax
  80205e:	e8 3b f0 ff ff       	call   80109e <fd_alloc>
  802063:	89 c3                	mov    %eax,%ebx
  802065:	83 c4 10             	add    $0x10,%esp
  802068:	85 c0                	test   %eax,%eax
  80206a:	0f 88 e2 00 00 00    	js     802152 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802070:	83 ec 04             	sub    $0x4,%esp
  802073:	68 07 04 00 00       	push   $0x407
  802078:	ff 75 f0             	pushl  -0x10(%ebp)
  80207b:	6a 00                	push   $0x0
  80207d:	e8 e5 ed ff ff       	call   800e67 <sys_page_alloc>
  802082:	89 c3                	mov    %eax,%ebx
  802084:	83 c4 10             	add    $0x10,%esp
  802087:	85 c0                	test   %eax,%eax
  802089:	0f 88 c3 00 00 00    	js     802152 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80208f:	83 ec 0c             	sub    $0xc,%esp
  802092:	ff 75 f4             	pushl  -0xc(%ebp)
  802095:	e8 ed ef ff ff       	call   801087 <fd2data>
  80209a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209c:	83 c4 0c             	add    $0xc,%esp
  80209f:	68 07 04 00 00       	push   $0x407
  8020a4:	50                   	push   %eax
  8020a5:	6a 00                	push   $0x0
  8020a7:	e8 bb ed ff ff       	call   800e67 <sys_page_alloc>
  8020ac:	89 c3                	mov    %eax,%ebx
  8020ae:	83 c4 10             	add    $0x10,%esp
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	0f 88 89 00 00 00    	js     802142 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b9:	83 ec 0c             	sub    $0xc,%esp
  8020bc:	ff 75 f0             	pushl  -0x10(%ebp)
  8020bf:	e8 c3 ef ff ff       	call   801087 <fd2data>
  8020c4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020cb:	50                   	push   %eax
  8020cc:	6a 00                	push   $0x0
  8020ce:	56                   	push   %esi
  8020cf:	6a 00                	push   $0x0
  8020d1:	e8 d4 ed ff ff       	call   800eaa <sys_page_map>
  8020d6:	89 c3                	mov    %eax,%ebx
  8020d8:	83 c4 20             	add    $0x20,%esp
  8020db:	85 c0                	test   %eax,%eax
  8020dd:	78 55                	js     802134 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8020df:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e8:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8020ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020ed:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8020f4:	8b 15 ac 47 80 00    	mov    0x8047ac,%edx
  8020fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020fd:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802102:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802109:	83 ec 0c             	sub    $0xc,%esp
  80210c:	ff 75 f4             	pushl  -0xc(%ebp)
  80210f:	e8 63 ef ff ff       	call   801077 <fd2num>
  802114:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802117:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802119:	83 c4 04             	add    $0x4,%esp
  80211c:	ff 75 f0             	pushl  -0x10(%ebp)
  80211f:	e8 53 ef ff ff       	call   801077 <fd2num>
  802124:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802127:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80212a:	83 c4 10             	add    $0x10,%esp
  80212d:	ba 00 00 00 00       	mov    $0x0,%edx
  802132:	eb 30                	jmp    802164 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802134:	83 ec 08             	sub    $0x8,%esp
  802137:	56                   	push   %esi
  802138:	6a 00                	push   $0x0
  80213a:	e8 ad ed ff ff       	call   800eec <sys_page_unmap>
  80213f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802142:	83 ec 08             	sub    $0x8,%esp
  802145:	ff 75 f0             	pushl  -0x10(%ebp)
  802148:	6a 00                	push   $0x0
  80214a:	e8 9d ed ff ff       	call   800eec <sys_page_unmap>
  80214f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802152:	83 ec 08             	sub    $0x8,%esp
  802155:	ff 75 f4             	pushl  -0xc(%ebp)
  802158:	6a 00                	push   $0x0
  80215a:	e8 8d ed ff ff       	call   800eec <sys_page_unmap>
  80215f:	83 c4 10             	add    $0x10,%esp
  802162:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802164:	89 d0                	mov    %edx,%eax
  802166:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802169:	5b                   	pop    %ebx
  80216a:	5e                   	pop    %esi
  80216b:	5d                   	pop    %ebp
  80216c:	c3                   	ret    

0080216d <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80216d:	55                   	push   %ebp
  80216e:	89 e5                	mov    %esp,%ebp
  802170:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802173:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802176:	50                   	push   %eax
  802177:	ff 75 08             	pushl  0x8(%ebp)
  80217a:	e8 6e ef ff ff       	call   8010ed <fd_lookup>
  80217f:	89 c2                	mov    %eax,%edx
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	85 d2                	test   %edx,%edx
  802186:	78 18                	js     8021a0 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802188:	83 ec 0c             	sub    $0xc,%esp
  80218b:	ff 75 f4             	pushl  -0xc(%ebp)
  80218e:	e8 f4 ee ff ff       	call   801087 <fd2data>
	return _pipeisclosed(fd, p);
  802193:	89 c2                	mov    %eax,%edx
  802195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802198:	e8 2c fd ff ff       	call   801ec9 <_pipeisclosed>
  80219d:	83 c4 10             	add    $0x10,%esp
}
  8021a0:	c9                   	leave  
  8021a1:	c3                   	ret    

008021a2 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	57                   	push   %edi
  8021a6:	56                   	push   %esi
  8021a7:	53                   	push   %ebx
  8021a8:	83 ec 0c             	sub    $0xc,%esp
  8021ab:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  8021ae:	85 f6                	test   %esi,%esi
  8021b0:	75 16                	jne    8021c8 <wait+0x26>
  8021b2:	68 7c 2c 80 00       	push   $0x802c7c
  8021b7:	68 5f 2b 80 00       	push   $0x802b5f
  8021bc:	6a 09                	push   $0x9
  8021be:	68 87 2c 80 00       	push   $0x802c87
  8021c3:	e8 38 e2 ff ff       	call   800400 <_panic>
	e = &envs[ENVX(envid)];
  8021c8:	89 f3                	mov    %esi,%ebx
  8021ca:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021d0:	6b db 78             	imul   $0x78,%ebx,%ebx
  8021d3:	8d 7b 40             	lea    0x40(%ebx),%edi
  8021d6:	83 c3 50             	add    $0x50,%ebx
  8021d9:	eb 05                	jmp    8021e0 <wait+0x3e>
		sys_yield();
  8021db:	e8 68 ec ff ff       	call   800e48 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  8021e0:	8b 87 08 00 c0 ee    	mov    -0x113ffff8(%edi),%eax
  8021e6:	39 f0                	cmp    %esi,%eax
  8021e8:	75 0a                	jne    8021f4 <wait+0x52>
  8021ea:	8b 83 04 00 c0 ee    	mov    -0x113ffffc(%ebx),%eax
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	75 e7                	jne    8021db <wait+0x39>
		sys_yield();
}
  8021f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021f7:	5b                   	pop    %ebx
  8021f8:	5e                   	pop    %esi
  8021f9:	5f                   	pop    %edi
  8021fa:	5d                   	pop    %ebp
  8021fb:	c3                   	ret    

008021fc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021fc:	55                   	push   %ebp
  8021fd:	89 e5                	mov    %esp,%ebp
  8021ff:	56                   	push   %esi
  802200:	53                   	push   %ebx
  802201:	8b 75 08             	mov    0x8(%ebp),%esi
  802204:	8b 45 0c             	mov    0xc(%ebp),%eax
  802207:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  80220a:	85 f6                	test   %esi,%esi
  80220c:	74 06                	je     802214 <ipc_recv+0x18>
  80220e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  802214:	85 db                	test   %ebx,%ebx
  802216:	74 06                	je     80221e <ipc_recv+0x22>
  802218:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  80221e:	83 f8 01             	cmp    $0x1,%eax
  802221:	19 d2                	sbb    %edx,%edx
  802223:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  802225:	83 ec 0c             	sub    $0xc,%esp
  802228:	50                   	push   %eax
  802229:	e8 e9 ed ff ff       	call   801017 <sys_ipc_recv>
  80222e:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  802230:	83 c4 10             	add    $0x10,%esp
  802233:	85 d2                	test   %edx,%edx
  802235:	75 24                	jne    80225b <ipc_recv+0x5f>
	if (from_env_store)
  802237:	85 f6                	test   %esi,%esi
  802239:	74 0a                	je     802245 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  80223b:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  802240:	8b 40 70             	mov    0x70(%eax),%eax
  802243:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  802245:	85 db                	test   %ebx,%ebx
  802247:	74 0a                	je     802253 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  802249:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  80224e:	8b 40 74             	mov    0x74(%eax),%eax
  802251:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802253:	a1 b0 67 80 00       	mov    0x8067b0,%eax
  802258:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  80225b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80225e:	5b                   	pop    %ebx
  80225f:	5e                   	pop    %esi
  802260:	5d                   	pop    %ebp
  802261:	c3                   	ret    

00802262 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802262:	55                   	push   %ebp
  802263:	89 e5                	mov    %esp,%ebp
  802265:	57                   	push   %edi
  802266:	56                   	push   %esi
  802267:	53                   	push   %ebx
  802268:	83 ec 0c             	sub    $0xc,%esp
  80226b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80226e:	8b 75 0c             	mov    0xc(%ebp),%esi
  802271:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  802274:	83 fb 01             	cmp    $0x1,%ebx
  802277:	19 c0                	sbb    %eax,%eax
  802279:	09 c3                	or     %eax,%ebx
  80227b:	eb 1c                	jmp    802299 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  80227d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802280:	74 12                	je     802294 <ipc_send+0x32>
  802282:	50                   	push   %eax
  802283:	68 92 2c 80 00       	push   $0x802c92
  802288:	6a 36                	push   $0x36
  80228a:	68 a9 2c 80 00       	push   $0x802ca9
  80228f:	e8 6c e1 ff ff       	call   800400 <_panic>
		sys_yield();
  802294:	e8 af eb ff ff       	call   800e48 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802299:	ff 75 14             	pushl  0x14(%ebp)
  80229c:	53                   	push   %ebx
  80229d:	56                   	push   %esi
  80229e:	57                   	push   %edi
  80229f:	e8 50 ed ff ff       	call   800ff4 <sys_ipc_try_send>
		if (ret == 0) break;
  8022a4:	83 c4 10             	add    $0x10,%esp
  8022a7:	85 c0                	test   %eax,%eax
  8022a9:	75 d2                	jne    80227d <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  8022ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022ae:	5b                   	pop    %ebx
  8022af:	5e                   	pop    %esi
  8022b0:	5f                   	pop    %edi
  8022b1:	5d                   	pop    %ebp
  8022b2:	c3                   	ret    

008022b3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022b3:	55                   	push   %ebp
  8022b4:	89 e5                	mov    %esp,%ebp
  8022b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022b9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022be:	6b d0 78             	imul   $0x78,%eax,%edx
  8022c1:	83 c2 50             	add    $0x50,%edx
  8022c4:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  8022ca:	39 ca                	cmp    %ecx,%edx
  8022cc:	75 0d                	jne    8022db <ipc_find_env+0x28>
			return envs[i].env_id;
  8022ce:	6b c0 78             	imul   $0x78,%eax,%eax
  8022d1:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8022d6:	8b 40 08             	mov    0x8(%eax),%eax
  8022d9:	eb 0e                	jmp    8022e9 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8022db:	83 c0 01             	add    $0x1,%eax
  8022de:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022e3:	75 d9                	jne    8022be <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8022e5:	66 b8 00 00          	mov    $0x0,%ax
}
  8022e9:	5d                   	pop    %ebp
  8022ea:	c3                   	ret    

008022eb <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022eb:	55                   	push   %ebp
  8022ec:	89 e5                	mov    %esp,%ebp
  8022ee:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022f1:	89 d0                	mov    %edx,%eax
  8022f3:	c1 e8 16             	shr    $0x16,%eax
  8022f6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8022fd:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802302:	f6 c1 01             	test   $0x1,%cl
  802305:	74 1d                	je     802324 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802307:	c1 ea 0c             	shr    $0xc,%edx
  80230a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802311:	f6 c2 01             	test   $0x1,%dl
  802314:	74 0e                	je     802324 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802316:	c1 ea 0c             	shr    $0xc,%edx
  802319:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802320:	ef 
  802321:	0f b7 c0             	movzwl %ax,%eax
}
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	55                   	push   %ebp
  802331:	57                   	push   %edi
  802332:	56                   	push   %esi
  802333:	83 ec 10             	sub    $0x10,%esp
  802336:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80233a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80233e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802342:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802346:	85 d2                	test   %edx,%edx
  802348:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80234c:	89 34 24             	mov    %esi,(%esp)
  80234f:	89 c8                	mov    %ecx,%eax
  802351:	75 35                	jne    802388 <__udivdi3+0x58>
  802353:	39 f1                	cmp    %esi,%ecx
  802355:	0f 87 bd 00 00 00    	ja     802418 <__udivdi3+0xe8>
  80235b:	85 c9                	test   %ecx,%ecx
  80235d:	89 cd                	mov    %ecx,%ebp
  80235f:	75 0b                	jne    80236c <__udivdi3+0x3c>
  802361:	b8 01 00 00 00       	mov    $0x1,%eax
  802366:	31 d2                	xor    %edx,%edx
  802368:	f7 f1                	div    %ecx
  80236a:	89 c5                	mov    %eax,%ebp
  80236c:	89 f0                	mov    %esi,%eax
  80236e:	31 d2                	xor    %edx,%edx
  802370:	f7 f5                	div    %ebp
  802372:	89 c6                	mov    %eax,%esi
  802374:	89 f8                	mov    %edi,%eax
  802376:	f7 f5                	div    %ebp
  802378:	89 f2                	mov    %esi,%edx
  80237a:	83 c4 10             	add    $0x10,%esp
  80237d:	5e                   	pop    %esi
  80237e:	5f                   	pop    %edi
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    
  802381:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802388:	3b 14 24             	cmp    (%esp),%edx
  80238b:	77 7b                	ja     802408 <__udivdi3+0xd8>
  80238d:	0f bd f2             	bsr    %edx,%esi
  802390:	83 f6 1f             	xor    $0x1f,%esi
  802393:	0f 84 97 00 00 00    	je     802430 <__udivdi3+0x100>
  802399:	bd 20 00 00 00       	mov    $0x20,%ebp
  80239e:	89 d7                	mov    %edx,%edi
  8023a0:	89 f1                	mov    %esi,%ecx
  8023a2:	29 f5                	sub    %esi,%ebp
  8023a4:	d3 e7                	shl    %cl,%edi
  8023a6:	89 c2                	mov    %eax,%edx
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	d3 ea                	shr    %cl,%edx
  8023ac:	89 f1                	mov    %esi,%ecx
  8023ae:	09 fa                	or     %edi,%edx
  8023b0:	8b 3c 24             	mov    (%esp),%edi
  8023b3:	d3 e0                	shl    %cl,%eax
  8023b5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023b9:	89 e9                	mov    %ebp,%ecx
  8023bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8023bf:	8b 44 24 04          	mov    0x4(%esp),%eax
  8023c3:	89 fa                	mov    %edi,%edx
  8023c5:	d3 ea                	shr    %cl,%edx
  8023c7:	89 f1                	mov    %esi,%ecx
  8023c9:	d3 e7                	shl    %cl,%edi
  8023cb:	89 e9                	mov    %ebp,%ecx
  8023cd:	d3 e8                	shr    %cl,%eax
  8023cf:	09 c7                	or     %eax,%edi
  8023d1:	89 f8                	mov    %edi,%eax
  8023d3:	f7 74 24 08          	divl   0x8(%esp)
  8023d7:	89 d5                	mov    %edx,%ebp
  8023d9:	89 c7                	mov    %eax,%edi
  8023db:	f7 64 24 0c          	mull   0xc(%esp)
  8023df:	39 d5                	cmp    %edx,%ebp
  8023e1:	89 14 24             	mov    %edx,(%esp)
  8023e4:	72 11                	jb     8023f7 <__udivdi3+0xc7>
  8023e6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023ea:	89 f1                	mov    %esi,%ecx
  8023ec:	d3 e2                	shl    %cl,%edx
  8023ee:	39 c2                	cmp    %eax,%edx
  8023f0:	73 5e                	jae    802450 <__udivdi3+0x120>
  8023f2:	3b 2c 24             	cmp    (%esp),%ebp
  8023f5:	75 59                	jne    802450 <__udivdi3+0x120>
  8023f7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8023fa:	31 f6                	xor    %esi,%esi
  8023fc:	89 f2                	mov    %esi,%edx
  8023fe:	83 c4 10             	add    $0x10,%esp
  802401:	5e                   	pop    %esi
  802402:	5f                   	pop    %edi
  802403:	5d                   	pop    %ebp
  802404:	c3                   	ret    
  802405:	8d 76 00             	lea    0x0(%esi),%esi
  802408:	31 f6                	xor    %esi,%esi
  80240a:	31 c0                	xor    %eax,%eax
  80240c:	89 f2                	mov    %esi,%edx
  80240e:	83 c4 10             	add    $0x10,%esp
  802411:	5e                   	pop    %esi
  802412:	5f                   	pop    %edi
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
  802415:	8d 76 00             	lea    0x0(%esi),%esi
  802418:	89 f2                	mov    %esi,%edx
  80241a:	31 f6                	xor    %esi,%esi
  80241c:	89 f8                	mov    %edi,%eax
  80241e:	f7 f1                	div    %ecx
  802420:	89 f2                	mov    %esi,%edx
  802422:	83 c4 10             	add    $0x10,%esp
  802425:	5e                   	pop    %esi
  802426:	5f                   	pop    %edi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802434:	76 0b                	jbe    802441 <__udivdi3+0x111>
  802436:	31 c0                	xor    %eax,%eax
  802438:	3b 14 24             	cmp    (%esp),%edx
  80243b:	0f 83 37 ff ff ff    	jae    802378 <__udivdi3+0x48>
  802441:	b8 01 00 00 00       	mov    $0x1,%eax
  802446:	e9 2d ff ff ff       	jmp    802378 <__udivdi3+0x48>
  80244b:	90                   	nop
  80244c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 f8                	mov    %edi,%eax
  802452:	31 f6                	xor    %esi,%esi
  802454:	e9 1f ff ff ff       	jmp    802378 <__udivdi3+0x48>
  802459:	66 90                	xchg   %ax,%ax
  80245b:	66 90                	xchg   %ax,%ax
  80245d:	66 90                	xchg   %ax,%ax
  80245f:	90                   	nop

00802460 <__umoddi3>:
  802460:	55                   	push   %ebp
  802461:	57                   	push   %edi
  802462:	56                   	push   %esi
  802463:	83 ec 20             	sub    $0x20,%esp
  802466:	8b 44 24 34          	mov    0x34(%esp),%eax
  80246a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80246e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802472:	89 c6                	mov    %eax,%esi
  802474:	89 44 24 10          	mov    %eax,0x10(%esp)
  802478:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80247c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802480:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802484:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802488:	89 74 24 18          	mov    %esi,0x18(%esp)
  80248c:	85 c0                	test   %eax,%eax
  80248e:	89 c2                	mov    %eax,%edx
  802490:	75 1e                	jne    8024b0 <__umoddi3+0x50>
  802492:	39 f7                	cmp    %esi,%edi
  802494:	76 52                	jbe    8024e8 <__umoddi3+0x88>
  802496:	89 c8                	mov    %ecx,%eax
  802498:	89 f2                	mov    %esi,%edx
  80249a:	f7 f7                	div    %edi
  80249c:	89 d0                	mov    %edx,%eax
  80249e:	31 d2                	xor    %edx,%edx
  8024a0:	83 c4 20             	add    $0x20,%esp
  8024a3:	5e                   	pop    %esi
  8024a4:	5f                   	pop    %edi
  8024a5:	5d                   	pop    %ebp
  8024a6:	c3                   	ret    
  8024a7:	89 f6                	mov    %esi,%esi
  8024a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8024b0:	39 f0                	cmp    %esi,%eax
  8024b2:	77 5c                	ja     802510 <__umoddi3+0xb0>
  8024b4:	0f bd e8             	bsr    %eax,%ebp
  8024b7:	83 f5 1f             	xor    $0x1f,%ebp
  8024ba:	75 64                	jne    802520 <__umoddi3+0xc0>
  8024bc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8024c0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8024c4:	0f 86 f6 00 00 00    	jbe    8025c0 <__umoddi3+0x160>
  8024ca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8024ce:	0f 82 ec 00 00 00    	jb     8025c0 <__umoddi3+0x160>
  8024d4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8024d8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8024dc:	83 c4 20             	add    $0x20,%esp
  8024df:	5e                   	pop    %esi
  8024e0:	5f                   	pop    %edi
  8024e1:	5d                   	pop    %ebp
  8024e2:	c3                   	ret    
  8024e3:	90                   	nop
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	85 ff                	test   %edi,%edi
  8024ea:	89 fd                	mov    %edi,%ebp
  8024ec:	75 0b                	jne    8024f9 <__umoddi3+0x99>
  8024ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8024f3:	31 d2                	xor    %edx,%edx
  8024f5:	f7 f7                	div    %edi
  8024f7:	89 c5                	mov    %eax,%ebp
  8024f9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8024fd:	31 d2                	xor    %edx,%edx
  8024ff:	f7 f5                	div    %ebp
  802501:	89 c8                	mov    %ecx,%eax
  802503:	f7 f5                	div    %ebp
  802505:	eb 95                	jmp    80249c <__umoddi3+0x3c>
  802507:	89 f6                	mov    %esi,%esi
  802509:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802510:	89 c8                	mov    %ecx,%eax
  802512:	89 f2                	mov    %esi,%edx
  802514:	83 c4 20             	add    $0x20,%esp
  802517:	5e                   	pop    %esi
  802518:	5f                   	pop    %edi
  802519:	5d                   	pop    %ebp
  80251a:	c3                   	ret    
  80251b:	90                   	nop
  80251c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802520:	b8 20 00 00 00       	mov    $0x20,%eax
  802525:	89 e9                	mov    %ebp,%ecx
  802527:	29 e8                	sub    %ebp,%eax
  802529:	d3 e2                	shl    %cl,%edx
  80252b:	89 c7                	mov    %eax,%edi
  80252d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802531:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802535:	89 f9                	mov    %edi,%ecx
  802537:	d3 e8                	shr    %cl,%eax
  802539:	89 c1                	mov    %eax,%ecx
  80253b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80253f:	09 d1                	or     %edx,%ecx
  802541:	89 fa                	mov    %edi,%edx
  802543:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802547:	89 e9                	mov    %ebp,%ecx
  802549:	d3 e0                	shl    %cl,%eax
  80254b:	89 f9                	mov    %edi,%ecx
  80254d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802551:	89 f0                	mov    %esi,%eax
  802553:	d3 e8                	shr    %cl,%eax
  802555:	89 e9                	mov    %ebp,%ecx
  802557:	89 c7                	mov    %eax,%edi
  802559:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80255d:	d3 e6                	shl    %cl,%esi
  80255f:	89 d1                	mov    %edx,%ecx
  802561:	89 fa                	mov    %edi,%edx
  802563:	d3 e8                	shr    %cl,%eax
  802565:	89 e9                	mov    %ebp,%ecx
  802567:	09 f0                	or     %esi,%eax
  802569:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80256d:	f7 74 24 10          	divl   0x10(%esp)
  802571:	d3 e6                	shl    %cl,%esi
  802573:	89 d1                	mov    %edx,%ecx
  802575:	f7 64 24 0c          	mull   0xc(%esp)
  802579:	39 d1                	cmp    %edx,%ecx
  80257b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80257f:	89 d7                	mov    %edx,%edi
  802581:	89 c6                	mov    %eax,%esi
  802583:	72 0a                	jb     80258f <__umoddi3+0x12f>
  802585:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802589:	73 10                	jae    80259b <__umoddi3+0x13b>
  80258b:	39 d1                	cmp    %edx,%ecx
  80258d:	75 0c                	jne    80259b <__umoddi3+0x13b>
  80258f:	89 d7                	mov    %edx,%edi
  802591:	89 c6                	mov    %eax,%esi
  802593:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802597:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80259b:	89 ca                	mov    %ecx,%edx
  80259d:	89 e9                	mov    %ebp,%ecx
  80259f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8025a3:	29 f0                	sub    %esi,%eax
  8025a5:	19 fa                	sbb    %edi,%edx
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8025ae:	89 d7                	mov    %edx,%edi
  8025b0:	d3 e7                	shl    %cl,%edi
  8025b2:	89 e9                	mov    %ebp,%ecx
  8025b4:	09 f8                	or     %edi,%eax
  8025b6:	d3 ea                	shr    %cl,%edx
  8025b8:	83 c4 20             	add    $0x20,%esp
  8025bb:	5e                   	pop    %esi
  8025bc:	5f                   	pop    %edi
  8025bd:	5d                   	pop    %ebp
  8025be:	c3                   	ret    
  8025bf:	90                   	nop
  8025c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8025c4:	29 f9                	sub    %edi,%ecx
  8025c6:	19 c6                	sbb    %eax,%esi
  8025c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8025cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8025d0:	e9 ff fe ff ff       	jmp    8024d4 <__umoddi3+0x74>
