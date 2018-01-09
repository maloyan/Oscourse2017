
obj/user/testkbd:     file format elf32-i386


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
  80002c:	e8 3c 02 00 00       	call   80026d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  80003f:	e8 c4 0d 00 00       	call   800e08 <sys_yield>
umain(int argc, char **argv)
{
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
  800044:	83 eb 01             	sub    $0x1,%ebx
  800047:	75 f6                	jne    80003f <umain+0xc>
		sys_yield();

	close(0);
  800049:	83 ec 0c             	sub    $0xc,%esp
  80004c:	6a 00                	push   $0x0
  80004e:	e8 83 11 00 00       	call   8011d6 <close>
	if ((r = opencons()) < 0)
  800053:	e8 bb 01 00 00       	call   800213 <opencons>
  800058:	83 c4 10             	add    $0x10,%esp
  80005b:	85 c0                	test   %eax,%eax
  80005d:	79 12                	jns    800071 <umain+0x3e>
		panic("opencons: %i", r);
  80005f:	50                   	push   %eax
  800060:	68 c0 20 80 00       	push   $0x8020c0
  800065:	6a 0f                	push   $0xf
  800067:	68 cd 20 80 00       	push   $0x8020cd
  80006c:	e8 5c 02 00 00       	call   8002cd <_panic>
	if (r != 0)
  800071:	85 c0                	test   %eax,%eax
  800073:	74 12                	je     800087 <umain+0x54>
		panic("first opencons used fd %d", r);
  800075:	50                   	push   %eax
  800076:	68 dc 20 80 00       	push   $0x8020dc
  80007b:	6a 11                	push   $0x11
  80007d:	68 cd 20 80 00       	push   $0x8020cd
  800082:	e8 46 02 00 00       	call   8002cd <_panic>
	if ((r = dup(0, 1)) < 0)
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	6a 01                	push   $0x1
  80008c:	6a 00                	push   $0x0
  80008e:	e8 95 11 00 00       	call   801228 <dup>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	85 c0                	test   %eax,%eax
  800098:	79 12                	jns    8000ac <umain+0x79>
		panic("dup: %i", r);
  80009a:	50                   	push   %eax
  80009b:	68 f6 20 80 00       	push   $0x8020f6
  8000a0:	6a 13                	push   $0x13
  8000a2:	68 cd 20 80 00       	push   $0x8020cd
  8000a7:	e8 21 02 00 00       	call   8002cd <_panic>

	for(;;){
		char *buf;

		buf = readline("Type a line: ");
  8000ac:	83 ec 0c             	sub    $0xc,%esp
  8000af:	68 fe 20 80 00       	push   $0x8020fe
  8000b4:	e8 bf 0b 00 00       	call   800c78 <readline>
		if (buf != NULL)
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	85 c0                	test   %eax,%eax
  8000be:	74 15                	je     8000d5 <umain+0xa2>
			fprintf(1, "%s\n", buf);
  8000c0:	83 ec 04             	sub    $0x4,%esp
  8000c3:	50                   	push   %eax
  8000c4:	68 0c 21 80 00       	push   $0x80210c
  8000c9:	6a 01                	push   $0x1
  8000cb:	e8 5c 18 00 00       	call   80192c <fprintf>
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	eb d7                	jmp    8000ac <umain+0x79>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 10 21 80 00       	push   $0x802110
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 48 18 00 00       	call   80192c <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb c3                	jmp    8000ac <umain+0x79>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	5d                   	pop    %ebp
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000f9:	68 28 21 80 00       	push   $0x802128
  8000fe:	ff 75 0c             	pushl  0xc(%ebp)
  800101:	e8 24 08 00 00       	call   80092a <strcpy>
	return 0;
}
  800106:	b8 00 00 00 00       	mov    $0x0,%eax
  80010b:	c9                   	leave  
  80010c:	c3                   	ret    

0080010d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	57                   	push   %edi
  800111:	56                   	push   %esi
  800112:	53                   	push   %ebx
  800113:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800119:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80011e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800124:	eb 2e                	jmp    800154 <devcons_write+0x47>
		m = n - tot;
  800126:	8b 55 10             	mov    0x10(%ebp),%edx
  800129:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  80012b:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800130:	83 fa 7f             	cmp    $0x7f,%edx
  800133:	77 02                	ja     800137 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800135:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800137:	83 ec 04             	sub    $0x4,%esp
  80013a:	56                   	push   %esi
  80013b:	03 45 0c             	add    0xc(%ebp),%eax
  80013e:	50                   	push   %eax
  80013f:	57                   	push   %edi
  800140:	e8 77 09 00 00       	call   800abc <memmove>
		sys_cputs(buf, m);
  800145:	83 c4 08             	add    $0x8,%esp
  800148:	56                   	push   %esi
  800149:	57                   	push   %edi
  80014a:	e8 1c 0c 00 00       	call   800d6b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80014f:	01 f3                	add    %esi,%ebx
  800151:	83 c4 10             	add    $0x10,%esp
  800154:	89 d8                	mov    %ebx,%eax
  800156:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800159:	72 cb                	jb     800126 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  80015b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800169:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  80016e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800172:	75 07                	jne    80017b <devcons_read+0x18>
  800174:	eb 28                	jmp    80019e <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800176:	e8 8d 0c 00 00       	call   800e08 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  80017b:	e8 09 0c 00 00       	call   800d89 <sys_cgetc>
  800180:	85 c0                	test   %eax,%eax
  800182:	74 f2                	je     800176 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800184:	85 c0                	test   %eax,%eax
  800186:	78 16                	js     80019e <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800188:	83 f8 04             	cmp    $0x4,%eax
  80018b:	74 0c                	je     800199 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  80018d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800190:	88 02                	mov    %al,(%edx)
	return 1;
  800192:	b8 01 00 00 00       	mov    $0x1,%eax
  800197:	eb 05                	jmp    80019e <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800199:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8001ac:	6a 01                	push   $0x1
  8001ae:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001b1:	50                   	push   %eax
  8001b2:	e8 b4 0b 00 00       	call   800d6b <sys_cputs>
  8001b7:	83 c4 10             	add    $0x10,%esp
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <getchar>:

int
getchar(void)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8001c2:	6a 01                	push   $0x1
  8001c4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c7:	50                   	push   %eax
  8001c8:	6a 00                	push   $0x0
  8001ca:	e8 47 11 00 00       	call   801316 <read>
	if (r < 0)
  8001cf:	83 c4 10             	add    $0x10,%esp
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	78 0f                	js     8001e5 <getchar+0x29>
		return r;
	if (r < 1)
  8001d6:	85 c0                	test   %eax,%eax
  8001d8:	7e 06                	jle    8001e0 <getchar+0x24>
		return -E_EOF;
	return c;
  8001da:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8001de:	eb 05                	jmp    8001e5 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8001e0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8001e5:	c9                   	leave  
  8001e6:	c3                   	ret    

008001e7 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8001ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001f0:	50                   	push   %eax
  8001f1:	ff 75 08             	pushl  0x8(%ebp)
  8001f4:	e8 b4 0e 00 00       	call   8010ad <fd_lookup>
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	85 c0                	test   %eax,%eax
  8001fe:	78 11                	js     800211 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800200:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800203:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800209:	39 10                	cmp    %edx,(%eax)
  80020b:	0f 94 c0             	sete   %al
  80020e:	0f b6 c0             	movzbl %al,%eax
}
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <opencons>:

int
opencons(void)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800219:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80021c:	50                   	push   %eax
  80021d:	e8 3c 0e 00 00       	call   80105e <fd_alloc>
  800222:	83 c4 10             	add    $0x10,%esp
		return r;
  800225:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800227:	85 c0                	test   %eax,%eax
  800229:	78 3e                	js     800269 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80022b:	83 ec 04             	sub    $0x4,%esp
  80022e:	68 07 04 00 00       	push   $0x407
  800233:	ff 75 f4             	pushl  -0xc(%ebp)
  800236:	6a 00                	push   $0x0
  800238:	e8 ea 0b 00 00       	call   800e27 <sys_page_alloc>
  80023d:	83 c4 10             	add    $0x10,%esp
		return r;
  800240:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800242:	85 c0                	test   %eax,%eax
  800244:	78 23                	js     800269 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800246:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80024c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80024f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800251:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800254:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80025b:	83 ec 0c             	sub    $0xc,%esp
  80025e:	50                   	push   %eax
  80025f:	e8 d3 0d 00 00       	call   801037 <fd2num>
  800264:	89 c2                	mov    %eax,%edx
  800266:	83 c4 10             	add    $0x10,%esp
}
  800269:	89 d0                	mov    %edx,%eax
  80026b:	c9                   	leave  
  80026c:	c3                   	ret    

0080026d <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80026d:	55                   	push   %ebp
  80026e:	89 e5                	mov    %esp,%ebp
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800275:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800278:	e8 6c 0b 00 00       	call   800de9 <sys_getenvid>
  80027d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800282:	6b c0 78             	imul   $0x78,%eax,%eax
  800285:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80028a:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7e 07                	jle    80029a <libmain+0x2d>
		binaryname = argv[0];
  800293:	8b 06                	mov    (%esi),%eax
  800295:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  80029a:	83 ec 08             	sub    $0x8,%esp
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
  80029f:	e8 8f fd ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8002a4:	e8 0a 00 00 00       	call   8002b3 <exit>
  8002a9:	83 c4 10             	add    $0x10,%esp
#endif
}
  8002ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002af:	5b                   	pop    %ebx
  8002b0:	5e                   	pop    %esi
  8002b1:	5d                   	pop    %ebp
  8002b2:	c3                   	ret    

008002b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002b9:	e8 45 0f 00 00       	call   801203 <close_all>
	sys_env_destroy(0);
  8002be:	83 ec 0c             	sub    $0xc,%esp
  8002c1:	6a 00                	push   $0x0
  8002c3:	e8 e0 0a 00 00       	call   800da8 <sys_env_destroy>
  8002c8:	83 c4 10             	add    $0x10,%esp
}
  8002cb:	c9                   	leave  
  8002cc:	c3                   	ret    

008002cd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002d2:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002d5:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002db:	e8 09 0b 00 00       	call   800de9 <sys_getenvid>
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	ff 75 0c             	pushl  0xc(%ebp)
  8002e6:	ff 75 08             	pushl  0x8(%ebp)
  8002e9:	56                   	push   %esi
  8002ea:	50                   	push   %eax
  8002eb:	68 40 21 80 00       	push   $0x802140
  8002f0:	e8 b1 00 00 00       	call   8003a6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002f5:	83 c4 18             	add    $0x18,%esp
  8002f8:	53                   	push   %ebx
  8002f9:	ff 75 10             	pushl  0x10(%ebp)
  8002fc:	e8 54 00 00 00       	call   800355 <vcprintf>
	cprintf("\n");
  800301:	c7 04 24 26 21 80 00 	movl   $0x802126,(%esp)
  800308:	e8 99 00 00 00       	call   8003a6 <cprintf>
  80030d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800310:	cc                   	int3   
  800311:	eb fd                	jmp    800310 <_panic+0x43>

00800313 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	53                   	push   %ebx
  800317:	83 ec 04             	sub    $0x4,%esp
  80031a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80031d:	8b 13                	mov    (%ebx),%edx
  80031f:	8d 42 01             	lea    0x1(%edx),%eax
  800322:	89 03                	mov    %eax,(%ebx)
  800324:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800327:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80032b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800330:	75 1a                	jne    80034c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800332:	83 ec 08             	sub    $0x8,%esp
  800335:	68 ff 00 00 00       	push   $0xff
  80033a:	8d 43 08             	lea    0x8(%ebx),%eax
  80033d:	50                   	push   %eax
  80033e:	e8 28 0a 00 00       	call   800d6b <sys_cputs>
		b->idx = 0;
  800343:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800349:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80034c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800350:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800353:	c9                   	leave  
  800354:	c3                   	ret    

00800355 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800355:	55                   	push   %ebp
  800356:	89 e5                	mov    %esp,%ebp
  800358:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80035e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800365:	00 00 00 
	b.cnt = 0;
  800368:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80036f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800372:	ff 75 0c             	pushl  0xc(%ebp)
  800375:	ff 75 08             	pushl  0x8(%ebp)
  800378:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80037e:	50                   	push   %eax
  80037f:	68 13 03 80 00       	push   $0x800313
  800384:	e8 4f 01 00 00       	call   8004d8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800389:	83 c4 08             	add    $0x8,%esp
  80038c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800392:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800398:	50                   	push   %eax
  800399:	e8 cd 09 00 00       	call   800d6b <sys_cputs>

	return b.cnt;
}
  80039e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003a4:	c9                   	leave  
  8003a5:	c3                   	ret    

008003a6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ac:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003af:	50                   	push   %eax
  8003b0:	ff 75 08             	pushl  0x8(%ebp)
  8003b3:	e8 9d ff ff ff       	call   800355 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003b8:	c9                   	leave  
  8003b9:	c3                   	ret    

008003ba <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	57                   	push   %edi
  8003be:	56                   	push   %esi
  8003bf:	53                   	push   %ebx
  8003c0:	83 ec 1c             	sub    $0x1c,%esp
  8003c3:	89 c7                	mov    %eax,%edi
  8003c5:	89 d6                	mov    %edx,%esi
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cd:	89 d1                	mov    %edx,%ecx
  8003cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8003d8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003db:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003de:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003e5:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8003e8:	72 05                	jb     8003ef <printnum+0x35>
  8003ea:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8003ed:	77 3e                	ja     80042d <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ef:	83 ec 0c             	sub    $0xc,%esp
  8003f2:	ff 75 18             	pushl  0x18(%ebp)
  8003f5:	83 eb 01             	sub    $0x1,%ebx
  8003f8:	53                   	push   %ebx
  8003f9:	50                   	push   %eax
  8003fa:	83 ec 08             	sub    $0x8,%esp
  8003fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  800400:	ff 75 e0             	pushl  -0x20(%ebp)
  800403:	ff 75 dc             	pushl  -0x24(%ebp)
  800406:	ff 75 d8             	pushl  -0x28(%ebp)
  800409:	e8 d2 19 00 00       	call   801de0 <__udivdi3>
  80040e:	83 c4 18             	add    $0x18,%esp
  800411:	52                   	push   %edx
  800412:	50                   	push   %eax
  800413:	89 f2                	mov    %esi,%edx
  800415:	89 f8                	mov    %edi,%eax
  800417:	e8 9e ff ff ff       	call   8003ba <printnum>
  80041c:	83 c4 20             	add    $0x20,%esp
  80041f:	eb 13                	jmp    800434 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800421:	83 ec 08             	sub    $0x8,%esp
  800424:	56                   	push   %esi
  800425:	ff 75 18             	pushl  0x18(%ebp)
  800428:	ff d7                	call   *%edi
  80042a:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80042d:	83 eb 01             	sub    $0x1,%ebx
  800430:	85 db                	test   %ebx,%ebx
  800432:	7f ed                	jg     800421 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	56                   	push   %esi
  800438:	83 ec 04             	sub    $0x4,%esp
  80043b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80043e:	ff 75 e0             	pushl  -0x20(%ebp)
  800441:	ff 75 dc             	pushl  -0x24(%ebp)
  800444:	ff 75 d8             	pushl  -0x28(%ebp)
  800447:	e8 c4 1a 00 00       	call   801f10 <__umoddi3>
  80044c:	83 c4 14             	add    $0x14,%esp
  80044f:	0f be 80 63 21 80 00 	movsbl 0x802163(%eax),%eax
  800456:	50                   	push   %eax
  800457:	ff d7                	call   *%edi
  800459:	83 c4 10             	add    $0x10,%esp
}
  80045c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80045f:	5b                   	pop    %ebx
  800460:	5e                   	pop    %esi
  800461:	5f                   	pop    %edi
  800462:	5d                   	pop    %ebp
  800463:	c3                   	ret    

00800464 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800464:	55                   	push   %ebp
  800465:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800467:	83 fa 01             	cmp    $0x1,%edx
  80046a:	7e 0e                	jle    80047a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80046c:	8b 10                	mov    (%eax),%edx
  80046e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800471:	89 08                	mov    %ecx,(%eax)
  800473:	8b 02                	mov    (%edx),%eax
  800475:	8b 52 04             	mov    0x4(%edx),%edx
  800478:	eb 22                	jmp    80049c <getuint+0x38>
	else if (lflag)
  80047a:	85 d2                	test   %edx,%edx
  80047c:	74 10                	je     80048e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80047e:	8b 10                	mov    (%eax),%edx
  800480:	8d 4a 04             	lea    0x4(%edx),%ecx
  800483:	89 08                	mov    %ecx,(%eax)
  800485:	8b 02                	mov    (%edx),%eax
  800487:	ba 00 00 00 00       	mov    $0x0,%edx
  80048c:	eb 0e                	jmp    80049c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80048e:	8b 10                	mov    (%eax),%edx
  800490:	8d 4a 04             	lea    0x4(%edx),%ecx
  800493:	89 08                	mov    %ecx,(%eax)
  800495:	8b 02                	mov    (%edx),%eax
  800497:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80049c:	5d                   	pop    %ebp
  80049d:	c3                   	ret    

0080049e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80049e:	55                   	push   %ebp
  80049f:	89 e5                	mov    %esp,%ebp
  8004a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a8:	8b 10                	mov    (%eax),%edx
  8004aa:	3b 50 04             	cmp    0x4(%eax),%edx
  8004ad:	73 0a                	jae    8004b9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004af:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b2:	89 08                	mov    %ecx,(%eax)
  8004b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b7:	88 02                	mov    %al,(%edx)
}
  8004b9:	5d                   	pop    %ebp
  8004ba:	c3                   	ret    

008004bb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004bb:	55                   	push   %ebp
  8004bc:	89 e5                	mov    %esp,%ebp
  8004be:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004c1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c4:	50                   	push   %eax
  8004c5:	ff 75 10             	pushl  0x10(%ebp)
  8004c8:	ff 75 0c             	pushl  0xc(%ebp)
  8004cb:	ff 75 08             	pushl  0x8(%ebp)
  8004ce:	e8 05 00 00 00       	call   8004d8 <vprintfmt>
	va_end(ap);
  8004d3:	83 c4 10             	add    $0x10,%esp
}
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    

008004d8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004d8:	55                   	push   %ebp
  8004d9:	89 e5                	mov    %esp,%ebp
  8004db:	57                   	push   %edi
  8004dc:	56                   	push   %esi
  8004dd:	53                   	push   %ebx
  8004de:	83 ec 2c             	sub    $0x2c,%esp
  8004e1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ea:	eb 12                	jmp    8004fe <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	0f 84 8d 03 00 00    	je     800881 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8004f4:	83 ec 08             	sub    $0x8,%esp
  8004f7:	53                   	push   %ebx
  8004f8:	50                   	push   %eax
  8004f9:	ff d6                	call   *%esi
  8004fb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fe:	83 c7 01             	add    $0x1,%edi
  800501:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800505:	83 f8 25             	cmp    $0x25,%eax
  800508:	75 e2                	jne    8004ec <vprintfmt+0x14>
  80050a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80050e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800515:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80051c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800523:	ba 00 00 00 00       	mov    $0x0,%edx
  800528:	eb 07                	jmp    800531 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80052a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80052d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800531:	8d 47 01             	lea    0x1(%edi),%eax
  800534:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800537:	0f b6 07             	movzbl (%edi),%eax
  80053a:	0f b6 c8             	movzbl %al,%ecx
  80053d:	83 e8 23             	sub    $0x23,%eax
  800540:	3c 55                	cmp    $0x55,%al
  800542:	0f 87 1e 03 00 00    	ja     800866 <vprintfmt+0x38e>
  800548:	0f b6 c0             	movzbl %al,%eax
  80054b:	ff 24 85 c0 22 80 00 	jmp    *0x8022c0(,%eax,4)
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800555:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800559:	eb d6                	jmp    800531 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055e:	b8 00 00 00 00       	mov    $0x0,%eax
  800563:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800566:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800569:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80056d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800570:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800573:	83 fa 09             	cmp    $0x9,%edx
  800576:	77 38                	ja     8005b0 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800578:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80057b:	eb e9                	jmp    800566 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80057d:	8b 45 14             	mov    0x14(%ebp),%eax
  800580:	8d 48 04             	lea    0x4(%eax),%ecx
  800583:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800586:	8b 00                	mov    (%eax),%eax
  800588:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80058e:	eb 26                	jmp    8005b6 <vprintfmt+0xde>
  800590:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800593:	89 c8                	mov    %ecx,%eax
  800595:	c1 f8 1f             	sar    $0x1f,%eax
  800598:	f7 d0                	not    %eax
  80059a:	21 c1                	and    %eax,%ecx
  80059c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a2:	eb 8d                	jmp    800531 <vprintfmt+0x59>
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005a7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005ae:	eb 81                	jmp    800531 <vprintfmt+0x59>
  8005b0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005b6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005ba:	0f 89 71 ff ff ff    	jns    800531 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005c0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005cd:	e9 5f ff ff ff       	jmp    800531 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005d2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005d8:	e9 54 ff ff ff       	jmp    800531 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8d 50 04             	lea    0x4(%eax),%edx
  8005e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e6:	83 ec 08             	sub    $0x8,%esp
  8005e9:	53                   	push   %ebx
  8005ea:	ff 30                	pushl  (%eax)
  8005ec:	ff d6                	call   *%esi
			break;
  8005ee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8005f4:	e9 05 ff ff ff       	jmp    8004fe <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8d 50 04             	lea    0x4(%eax),%edx
  8005ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800602:	8b 00                	mov    (%eax),%eax
  800604:	99                   	cltd   
  800605:	31 d0                	xor    %edx,%eax
  800607:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800609:	83 f8 0f             	cmp    $0xf,%eax
  80060c:	7f 0b                	jg     800619 <vprintfmt+0x141>
  80060e:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  800615:	85 d2                	test   %edx,%edx
  800617:	75 18                	jne    800631 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800619:	50                   	push   %eax
  80061a:	68 7b 21 80 00       	push   $0x80217b
  80061f:	53                   	push   %ebx
  800620:	56                   	push   %esi
  800621:	e8 95 fe ff ff       	call   8004bb <printfmt>
  800626:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80062c:	e9 cd fe ff ff       	jmp    8004fe <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800631:	52                   	push   %edx
  800632:	68 81 25 80 00       	push   $0x802581
  800637:	53                   	push   %ebx
  800638:	56                   	push   %esi
  800639:	e8 7d fe ff ff       	call   8004bb <printfmt>
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800644:	e9 b5 fe ff ff       	jmp    8004fe <vprintfmt+0x26>
  800649:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80064c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80064f:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8d 50 04             	lea    0x4(%eax),%edx
  800658:	89 55 14             	mov    %edx,0x14(%ebp)
  80065b:	8b 38                	mov    (%eax),%edi
  80065d:	85 ff                	test   %edi,%edi
  80065f:	75 05                	jne    800666 <vprintfmt+0x18e>
				p = "(null)";
  800661:	bf 74 21 80 00       	mov    $0x802174,%edi
			if (width > 0 && padc != '-')
  800666:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80066a:	0f 84 91 00 00 00    	je     800701 <vprintfmt+0x229>
  800670:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800674:	0f 8e 95 00 00 00    	jle    80070f <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067a:	83 ec 08             	sub    $0x8,%esp
  80067d:	51                   	push   %ecx
  80067e:	57                   	push   %edi
  80067f:	e8 85 02 00 00       	call   800909 <strnlen>
  800684:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800687:	29 c1                	sub    %eax,%ecx
  800689:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80068c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800693:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800696:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800699:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80069b:	eb 0f                	jmp    8006ac <vprintfmt+0x1d4>
					putch(padc, putdat);
  80069d:	83 ec 08             	sub    $0x8,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a6:	83 ef 01             	sub    $0x1,%edi
  8006a9:	83 c4 10             	add    $0x10,%esp
  8006ac:	85 ff                	test   %edi,%edi
  8006ae:	7f ed                	jg     80069d <vprintfmt+0x1c5>
  8006b0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006b3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006b6:	89 c8                	mov    %ecx,%eax
  8006b8:	c1 f8 1f             	sar    $0x1f,%eax
  8006bb:	f7 d0                	not    %eax
  8006bd:	21 c8                	and    %ecx,%eax
  8006bf:	29 c1                	sub    %eax,%ecx
  8006c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8006c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ca:	89 cb                	mov    %ecx,%ebx
  8006cc:	eb 4d                	jmp    80071b <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006d2:	74 1b                	je     8006ef <vprintfmt+0x217>
  8006d4:	0f be c0             	movsbl %al,%eax
  8006d7:	83 e8 20             	sub    $0x20,%eax
  8006da:	83 f8 5e             	cmp    $0x5e,%eax
  8006dd:	76 10                	jbe    8006ef <vprintfmt+0x217>
					putch('?', putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	ff 75 0c             	pushl  0xc(%ebp)
  8006e5:	6a 3f                	push   $0x3f
  8006e7:	ff 55 08             	call   *0x8(%ebp)
  8006ea:	83 c4 10             	add    $0x10,%esp
  8006ed:	eb 0d                	jmp    8006fc <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8006ef:	83 ec 08             	sub    $0x8,%esp
  8006f2:	ff 75 0c             	pushl  0xc(%ebp)
  8006f5:	52                   	push   %edx
  8006f6:	ff 55 08             	call   *0x8(%ebp)
  8006f9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	83 eb 01             	sub    $0x1,%ebx
  8006ff:	eb 1a                	jmp    80071b <vprintfmt+0x243>
  800701:	89 75 08             	mov    %esi,0x8(%ebp)
  800704:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800707:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80070d:	eb 0c                	jmp    80071b <vprintfmt+0x243>
  80070f:	89 75 08             	mov    %esi,0x8(%ebp)
  800712:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800715:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800718:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80071b:	83 c7 01             	add    $0x1,%edi
  80071e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800722:	0f be d0             	movsbl %al,%edx
  800725:	85 d2                	test   %edx,%edx
  800727:	74 23                	je     80074c <vprintfmt+0x274>
  800729:	85 f6                	test   %esi,%esi
  80072b:	78 a1                	js     8006ce <vprintfmt+0x1f6>
  80072d:	83 ee 01             	sub    $0x1,%esi
  800730:	79 9c                	jns    8006ce <vprintfmt+0x1f6>
  800732:	89 df                	mov    %ebx,%edi
  800734:	8b 75 08             	mov    0x8(%ebp),%esi
  800737:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80073a:	eb 18                	jmp    800754 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 20                	push   $0x20
  800742:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800744:	83 ef 01             	sub    $0x1,%edi
  800747:	83 c4 10             	add    $0x10,%esp
  80074a:	eb 08                	jmp    800754 <vprintfmt+0x27c>
  80074c:	89 df                	mov    %ebx,%edi
  80074e:	8b 75 08             	mov    0x8(%ebp),%esi
  800751:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800754:	85 ff                	test   %edi,%edi
  800756:	7f e4                	jg     80073c <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800758:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80075b:	e9 9e fd ff ff       	jmp    8004fe <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800760:	83 fa 01             	cmp    $0x1,%edx
  800763:	7e 16                	jle    80077b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 08             	lea    0x8(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	8b 50 04             	mov    0x4(%eax),%edx
  800771:	8b 00                	mov    (%eax),%eax
  800773:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800776:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800779:	eb 32                	jmp    8007ad <vprintfmt+0x2d5>
	else if (lflag)
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 18                	je     800797 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80077f:	8b 45 14             	mov    0x14(%ebp),%eax
  800782:	8d 50 04             	lea    0x4(%eax),%edx
  800785:	89 55 14             	mov    %edx,0x14(%ebp)
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078d:	89 c1                	mov    %eax,%ecx
  80078f:	c1 f9 1f             	sar    $0x1f,%ecx
  800792:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800795:	eb 16                	jmp    8007ad <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800797:	8b 45 14             	mov    0x14(%ebp),%eax
  80079a:	8d 50 04             	lea    0x4(%eax),%edx
  80079d:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a0:	8b 00                	mov    (%eax),%eax
  8007a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a5:	89 c1                	mov    %eax,%ecx
  8007a7:	c1 f9 1f             	sar    $0x1f,%ecx
  8007aa:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007ad:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007b0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007b3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007b8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007bc:	79 74                	jns    800832 <vprintfmt+0x35a>
				putch('-', putdat);
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	53                   	push   %ebx
  8007c2:	6a 2d                	push   $0x2d
  8007c4:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c9:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007cc:	f7 d8                	neg    %eax
  8007ce:	83 d2 00             	adc    $0x0,%edx
  8007d1:	f7 da                	neg    %edx
  8007d3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007d6:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007db:	eb 55                	jmp    800832 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e0:	e8 7f fc ff ff       	call   800464 <getuint>
			base = 10;
  8007e5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8007ea:	eb 46                	jmp    800832 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8007ec:	8d 45 14             	lea    0x14(%ebp),%eax
  8007ef:	e8 70 fc ff ff       	call   800464 <getuint>
			base = 8;
  8007f4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8007f9:	eb 37                	jmp    800832 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8007fb:	83 ec 08             	sub    $0x8,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	6a 30                	push   $0x30
  800801:	ff d6                	call   *%esi
			putch('x', putdat);
  800803:	83 c4 08             	add    $0x8,%esp
  800806:	53                   	push   %ebx
  800807:	6a 78                	push   $0x78
  800809:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 04             	lea    0x4(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800814:	8b 00                	mov    (%eax),%eax
  800816:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80081b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80081e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800823:	eb 0d                	jmp    800832 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	e8 37 fc ff ff       	call   800464 <getuint>
			base = 16;
  80082d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800832:	83 ec 0c             	sub    $0xc,%esp
  800835:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800839:	57                   	push   %edi
  80083a:	ff 75 e0             	pushl  -0x20(%ebp)
  80083d:	51                   	push   %ecx
  80083e:	52                   	push   %edx
  80083f:	50                   	push   %eax
  800840:	89 da                	mov    %ebx,%edx
  800842:	89 f0                	mov    %esi,%eax
  800844:	e8 71 fb ff ff       	call   8003ba <printnum>
			break;
  800849:	83 c4 20             	add    $0x20,%esp
  80084c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80084f:	e9 aa fc ff ff       	jmp    8004fe <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800854:	83 ec 08             	sub    $0x8,%esp
  800857:	53                   	push   %ebx
  800858:	51                   	push   %ecx
  800859:	ff d6                	call   *%esi
			break;
  80085b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80085e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800861:	e9 98 fc ff ff       	jmp    8004fe <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	53                   	push   %ebx
  80086a:	6a 25                	push   $0x25
  80086c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	eb 03                	jmp    800876 <vprintfmt+0x39e>
  800873:	83 ef 01             	sub    $0x1,%edi
  800876:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80087a:	75 f7                	jne    800873 <vprintfmt+0x39b>
  80087c:	e9 7d fc ff ff       	jmp    8004fe <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800881:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800884:	5b                   	pop    %ebx
  800885:	5e                   	pop    %esi
  800886:	5f                   	pop    %edi
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	83 ec 18             	sub    $0x18,%esp
  80088f:	8b 45 08             	mov    0x8(%ebp),%eax
  800892:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800895:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800898:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80089f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	74 26                	je     8008d0 <vsnprintf+0x47>
  8008aa:	85 d2                	test   %edx,%edx
  8008ac:	7e 22                	jle    8008d0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ae:	ff 75 14             	pushl  0x14(%ebp)
  8008b1:	ff 75 10             	pushl  0x10(%ebp)
  8008b4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008b7:	50                   	push   %eax
  8008b8:	68 9e 04 80 00       	push   $0x80049e
  8008bd:	e8 16 fc ff ff       	call   8004d8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	eb 05                	jmp    8008d5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008dd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e0:	50                   	push   %eax
  8008e1:	ff 75 10             	pushl  0x10(%ebp)
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	ff 75 08             	pushl  0x8(%ebp)
  8008ea:	e8 9a ff ff ff       	call   800889 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fc:	eb 03                	jmp    800901 <strlen+0x10>
		n++;
  8008fe:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800901:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800905:	75 f7                	jne    8008fe <strlen+0xd>
		n++;
	return n;
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090f:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800912:	ba 00 00 00 00       	mov    $0x0,%edx
  800917:	eb 03                	jmp    80091c <strnlen+0x13>
		n++;
  800919:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80091c:	39 c2                	cmp    %eax,%edx
  80091e:	74 08                	je     800928 <strnlen+0x1f>
  800920:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800924:	75 f3                	jne    800919 <strnlen+0x10>
  800926:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800934:	89 c2                	mov    %eax,%edx
  800936:	83 c2 01             	add    $0x1,%edx
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800940:	88 5a ff             	mov    %bl,-0x1(%edx)
  800943:	84 db                	test   %bl,%bl
  800945:	75 ef                	jne    800936 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800951:	53                   	push   %ebx
  800952:	e8 9a ff ff ff       	call   8008f1 <strlen>
  800957:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80095a:	ff 75 0c             	pushl  0xc(%ebp)
  80095d:	01 d8                	add    %ebx,%eax
  80095f:	50                   	push   %eax
  800960:	e8 c5 ff ff ff       	call   80092a <strcpy>
	return dst;
}
  800965:	89 d8                	mov    %ebx,%eax
  800967:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096a:	c9                   	leave  
  80096b:	c3                   	ret    

0080096c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	56                   	push   %esi
  800970:	53                   	push   %ebx
  800971:	8b 75 08             	mov    0x8(%ebp),%esi
  800974:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800977:	89 f3                	mov    %esi,%ebx
  800979:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80097c:	89 f2                	mov    %esi,%edx
  80097e:	eb 0f                	jmp    80098f <strncpy+0x23>
		*dst++ = *src;
  800980:	83 c2 01             	add    $0x1,%edx
  800983:	0f b6 01             	movzbl (%ecx),%eax
  800986:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800989:	80 39 01             	cmpb   $0x1,(%ecx)
  80098c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80098f:	39 da                	cmp    %ebx,%edx
  800991:	75 ed                	jne    800980 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800993:	89 f0                	mov    %esi,%eax
  800995:	5b                   	pop    %ebx
  800996:	5e                   	pop    %esi
  800997:	5d                   	pop    %ebp
  800998:	c3                   	ret    

00800999 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	56                   	push   %esi
  80099d:	53                   	push   %ebx
  80099e:	8b 75 08             	mov    0x8(%ebp),%esi
  8009a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009a4:	8b 55 10             	mov    0x10(%ebp),%edx
  8009a7:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009a9:	85 d2                	test   %edx,%edx
  8009ab:	74 21                	je     8009ce <strlcpy+0x35>
  8009ad:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009b1:	89 f2                	mov    %esi,%edx
  8009b3:	eb 09                	jmp    8009be <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009b5:	83 c2 01             	add    $0x1,%edx
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009be:	39 c2                	cmp    %eax,%edx
  8009c0:	74 09                	je     8009cb <strlcpy+0x32>
  8009c2:	0f b6 19             	movzbl (%ecx),%ebx
  8009c5:	84 db                	test   %bl,%bl
  8009c7:	75 ec                	jne    8009b5 <strlcpy+0x1c>
  8009c9:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009cb:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009ce:	29 f0                	sub    %esi,%eax
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009da:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009dd:	eb 06                	jmp    8009e5 <strcmp+0x11>
		p++, q++;
  8009df:	83 c1 01             	add    $0x1,%ecx
  8009e2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009e5:	0f b6 01             	movzbl (%ecx),%eax
  8009e8:	84 c0                	test   %al,%al
  8009ea:	74 04                	je     8009f0 <strcmp+0x1c>
  8009ec:	3a 02                	cmp    (%edx),%al
  8009ee:	74 ef                	je     8009df <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f0:	0f b6 c0             	movzbl %al,%eax
  8009f3:	0f b6 12             	movzbl (%edx),%edx
  8009f6:	29 d0                	sub    %edx,%eax
}
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	53                   	push   %ebx
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a04:	89 c3                	mov    %eax,%ebx
  800a06:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a09:	eb 06                	jmp    800a11 <strncmp+0x17>
		n--, p++, q++;
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a11:	39 d8                	cmp    %ebx,%eax
  800a13:	74 15                	je     800a2a <strncmp+0x30>
  800a15:	0f b6 08             	movzbl (%eax),%ecx
  800a18:	84 c9                	test   %cl,%cl
  800a1a:	74 04                	je     800a20 <strncmp+0x26>
  800a1c:	3a 0a                	cmp    (%edx),%cl
  800a1e:	74 eb                	je     800a0b <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a20:	0f b6 00             	movzbl (%eax),%eax
  800a23:	0f b6 12             	movzbl (%edx),%edx
  800a26:	29 d0                	sub    %edx,%eax
  800a28:	eb 05                	jmp    800a2f <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a2a:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a2f:	5b                   	pop    %ebx
  800a30:	5d                   	pop    %ebp
  800a31:	c3                   	ret    

00800a32 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	8b 45 08             	mov    0x8(%ebp),%eax
  800a38:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a3c:	eb 07                	jmp    800a45 <strchr+0x13>
		if (*s == c)
  800a3e:	38 ca                	cmp    %cl,%dl
  800a40:	74 0f                	je     800a51 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a42:	83 c0 01             	add    $0x1,%eax
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	75 f2                	jne    800a3e <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a4c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a5d:	eb 03                	jmp    800a62 <strfind+0xf>
  800a5f:	83 c0 01             	add    $0x1,%eax
  800a62:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a65:	84 d2                	test   %dl,%dl
  800a67:	74 04                	je     800a6d <strfind+0x1a>
  800a69:	38 ca                	cmp    %cl,%dl
  800a6b:	75 f2                	jne    800a5f <strfind+0xc>
			break;
	return (char *) s;
}
  800a6d:	5d                   	pop    %ebp
  800a6e:	c3                   	ret    

00800a6f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a6f:	55                   	push   %ebp
  800a70:	89 e5                	mov    %esp,%ebp
  800a72:	57                   	push   %edi
  800a73:	56                   	push   %esi
  800a74:	53                   	push   %ebx
  800a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a78:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800a7b:	85 c9                	test   %ecx,%ecx
  800a7d:	74 36                	je     800ab5 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 28                	jne    800aaf <memset+0x40>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 23                	jne    800aaf <memset+0x40>
		c &= 0xFF;
  800a8c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	c1 e3 08             	shl    $0x8,%ebx
  800a95:	89 d6                	mov    %edx,%esi
  800a97:	c1 e6 18             	shl    $0x18,%esi
  800a9a:	89 d0                	mov    %edx,%eax
  800a9c:	c1 e0 10             	shl    $0x10,%eax
  800a9f:	09 f0                	or     %esi,%eax
  800aa1:	09 c2                	or     %eax,%edx
  800aa3:	89 d0                	mov    %edx,%eax
  800aa5:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aa7:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800aaa:	fc                   	cld    
  800aab:	f3 ab                	rep stos %eax,%es:(%edi)
  800aad:	eb 06                	jmp    800ab5 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab2:	fc                   	cld    
  800ab3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab5:	89 f8                	mov    %edi,%eax
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ac7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aca:	39 c6                	cmp    %eax,%esi
  800acc:	73 35                	jae    800b03 <memmove+0x47>
  800ace:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad1:	39 d0                	cmp    %edx,%eax
  800ad3:	73 2e                	jae    800b03 <memmove+0x47>
		s += n;
		d += n;
  800ad5:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800ad8:	89 d6                	mov    %edx,%esi
  800ada:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800adc:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ae2:	75 13                	jne    800af7 <memmove+0x3b>
  800ae4:	f6 c1 03             	test   $0x3,%cl
  800ae7:	75 0e                	jne    800af7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ae9:	83 ef 04             	sub    $0x4,%edi
  800aec:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aef:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800af2:	fd                   	std    
  800af3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af5:	eb 09                	jmp    800b00 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800af7:	83 ef 01             	sub    $0x1,%edi
  800afa:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800afd:	fd                   	std    
  800afe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b00:	fc                   	cld    
  800b01:	eb 1d                	jmp    800b20 <memmove+0x64>
  800b03:	89 f2                	mov    %esi,%edx
  800b05:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b07:	f6 c2 03             	test   $0x3,%dl
  800b0a:	75 0f                	jne    800b1b <memmove+0x5f>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 0a                	jne    800b1b <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b11:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b14:	89 c7                	mov    %eax,%edi
  800b16:	fc                   	cld    
  800b17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b19:	eb 05                	jmp    800b20 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b1b:	89 c7                	mov    %eax,%edi
  800b1d:	fc                   	cld    
  800b1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b20:	5e                   	pop    %esi
  800b21:	5f                   	pop    %edi
  800b22:	5d                   	pop    %ebp
  800b23:	c3                   	ret    

00800b24 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b27:	ff 75 10             	pushl  0x10(%ebp)
  800b2a:	ff 75 0c             	pushl  0xc(%ebp)
  800b2d:	ff 75 08             	pushl  0x8(%ebp)
  800b30:	e8 87 ff ff ff       	call   800abc <memmove>
}
  800b35:	c9                   	leave  
  800b36:	c3                   	ret    

00800b37 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	56                   	push   %esi
  800b3b:	53                   	push   %ebx
  800b3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b42:	89 c6                	mov    %eax,%esi
  800b44:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b47:	eb 1a                	jmp    800b63 <memcmp+0x2c>
		if (*s1 != *s2)
  800b49:	0f b6 08             	movzbl (%eax),%ecx
  800b4c:	0f b6 1a             	movzbl (%edx),%ebx
  800b4f:	38 d9                	cmp    %bl,%cl
  800b51:	74 0a                	je     800b5d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b53:	0f b6 c1             	movzbl %cl,%eax
  800b56:	0f b6 db             	movzbl %bl,%ebx
  800b59:	29 d8                	sub    %ebx,%eax
  800b5b:	eb 0f                	jmp    800b6c <memcmp+0x35>
		s1++, s2++;
  800b5d:	83 c0 01             	add    $0x1,%eax
  800b60:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b63:	39 f0                	cmp    %esi,%eax
  800b65:	75 e2                	jne    800b49 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	8b 45 08             	mov    0x8(%ebp),%eax
  800b76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b79:	89 c2                	mov    %eax,%edx
  800b7b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7e:	eb 07                	jmp    800b87 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b80:	38 08                	cmp    %cl,(%eax)
  800b82:	74 07                	je     800b8b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b84:	83 c0 01             	add    $0x1,%eax
  800b87:	39 d0                	cmp    %edx,%eax
  800b89:	72 f5                	jb     800b80 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    

00800b8d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	57                   	push   %edi
  800b91:	56                   	push   %esi
  800b92:	53                   	push   %ebx
  800b93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b99:	eb 03                	jmp    800b9e <strtol+0x11>
		s++;
  800b9b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9e:	0f b6 01             	movzbl (%ecx),%eax
  800ba1:	3c 09                	cmp    $0x9,%al
  800ba3:	74 f6                	je     800b9b <strtol+0xe>
  800ba5:	3c 20                	cmp    $0x20,%al
  800ba7:	74 f2                	je     800b9b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba9:	3c 2b                	cmp    $0x2b,%al
  800bab:	75 0a                	jne    800bb7 <strtol+0x2a>
		s++;
  800bad:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
  800bb5:	eb 10                	jmp    800bc7 <strtol+0x3a>
  800bb7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bbc:	3c 2d                	cmp    $0x2d,%al
  800bbe:	75 07                	jne    800bc7 <strtol+0x3a>
		s++, neg = 1;
  800bc0:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bc3:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc7:	85 db                	test   %ebx,%ebx
  800bc9:	0f 94 c0             	sete   %al
  800bcc:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bd2:	75 19                	jne    800bed <strtol+0x60>
  800bd4:	80 39 30             	cmpb   $0x30,(%ecx)
  800bd7:	75 14                	jne    800bed <strtol+0x60>
  800bd9:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bdd:	0f 85 8a 00 00 00    	jne    800c6d <strtol+0xe0>
		s += 2, base = 16;
  800be3:	83 c1 02             	add    $0x2,%ecx
  800be6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800beb:	eb 16                	jmp    800c03 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bed:	84 c0                	test   %al,%al
  800bef:	74 12                	je     800c03 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bf1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf6:	80 39 30             	cmpb   $0x30,(%ecx)
  800bf9:	75 08                	jne    800c03 <strtol+0x76>
		s++, base = 8;
  800bfb:	83 c1 01             	add    $0x1,%ecx
  800bfe:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c03:	b8 00 00 00 00       	mov    $0x0,%eax
  800c08:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c0b:	0f b6 11             	movzbl (%ecx),%edx
  800c0e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c11:	89 f3                	mov    %esi,%ebx
  800c13:	80 fb 09             	cmp    $0x9,%bl
  800c16:	77 08                	ja     800c20 <strtol+0x93>
			dig = *s - '0';
  800c18:	0f be d2             	movsbl %dl,%edx
  800c1b:	83 ea 30             	sub    $0x30,%edx
  800c1e:	eb 22                	jmp    800c42 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c20:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c23:	89 f3                	mov    %esi,%ebx
  800c25:	80 fb 19             	cmp    $0x19,%bl
  800c28:	77 08                	ja     800c32 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c2a:	0f be d2             	movsbl %dl,%edx
  800c2d:	83 ea 57             	sub    $0x57,%edx
  800c30:	eb 10                	jmp    800c42 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c32:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c35:	89 f3                	mov    %esi,%ebx
  800c37:	80 fb 19             	cmp    $0x19,%bl
  800c3a:	77 16                	ja     800c52 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c3c:	0f be d2             	movsbl %dl,%edx
  800c3f:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c42:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c45:	7d 0f                	jge    800c56 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c47:	83 c1 01             	add    $0x1,%ecx
  800c4a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c4e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c50:	eb b9                	jmp    800c0b <strtol+0x7e>
  800c52:	89 c2                	mov    %eax,%edx
  800c54:	eb 02                	jmp    800c58 <strtol+0xcb>
  800c56:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c58:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c5c:	74 05                	je     800c63 <strtol+0xd6>
		*endptr = (char *) s;
  800c5e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c61:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c63:	85 ff                	test   %edi,%edi
  800c65:	74 0c                	je     800c73 <strtol+0xe6>
  800c67:	89 d0                	mov    %edx,%eax
  800c69:	f7 d8                	neg    %eax
  800c6b:	eb 06                	jmp    800c73 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c6d:	84 c0                	test   %al,%al
  800c6f:	75 8a                	jne    800bfb <strtol+0x6e>
  800c71:	eb 90                	jmp    800c03 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL) {
  800c84:	85 c0                	test   %eax,%eax
  800c86:	74 13                	je     800c9b <readline+0x23>
#if JOS_KERNEL
		cprintf("%s", prompt);
#else
		fprintf(1, "%s", prompt);
  800c88:	83 ec 04             	sub    $0x4,%esp
  800c8b:	50                   	push   %eax
  800c8c:	68 81 25 80 00       	push   $0x802581
  800c91:	6a 01                	push   $0x1
  800c93:	e8 94 0c 00 00       	call   80192c <fprintf>
  800c98:	83 c4 10             	add    $0x10,%esp
#endif
	}

	i = 0;
	echoing = iscons(0);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	6a 00                	push   $0x0
  800ca0:	e8 42 f5 ff ff       	call   8001e7 <iscons>
  800ca5:	89 c7                	mov    %eax,%edi
  800ca7:	83 c4 10             	add    $0x10,%esp
#else
		fprintf(1, "%s", prompt);
#endif
	}

	i = 0;
  800caa:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  800caf:	e8 08 f5 ff ff       	call   8001bc <getchar>
  800cb4:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	79 29                	jns    800ce3 <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %i\n", c);
			return NULL;
  800cba:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  800cbf:	83 fb f8             	cmp    $0xfffffff8,%ebx
  800cc2:	0f 84 9b 00 00 00    	je     800d63 <readline+0xeb>
				cprintf("read error: %i\n", c);
  800cc8:	83 ec 08             	sub    $0x8,%esp
  800ccb:	53                   	push   %ebx
  800ccc:	68 9f 24 80 00       	push   $0x80249f
  800cd1:	e8 d0 f6 ff ff       	call   8003a6 <cprintf>
  800cd6:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800cd9:	b8 00 00 00 00       	mov    $0x0,%eax
  800cde:	e9 80 00 00 00       	jmp    800d63 <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800ce3:	83 f8 7f             	cmp    $0x7f,%eax
  800ce6:	0f 94 c2             	sete   %dl
  800ce9:	83 f8 08             	cmp    $0x8,%eax
  800cec:	0f 94 c0             	sete   %al
  800cef:	08 c2                	or     %al,%dl
  800cf1:	74 1a                	je     800d0d <readline+0x95>
  800cf3:	85 f6                	test   %esi,%esi
  800cf5:	7e 16                	jle    800d0d <readline+0x95>
			if (echoing)
  800cf7:	85 ff                	test   %edi,%edi
  800cf9:	74 0d                	je     800d08 <readline+0x90>
				cputchar('\b');
  800cfb:	83 ec 0c             	sub    $0xc,%esp
  800cfe:	6a 08                	push   $0x8
  800d00:	e8 9b f4 ff ff       	call   8001a0 <cputchar>
  800d05:	83 c4 10             	add    $0x10,%esp
			i--;
  800d08:	83 ee 01             	sub    $0x1,%esi
  800d0b:	eb a2                	jmp    800caf <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  800d0d:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  800d13:	7f 23                	jg     800d38 <readline+0xc0>
  800d15:	83 fb 1f             	cmp    $0x1f,%ebx
  800d18:	7e 1e                	jle    800d38 <readline+0xc0>
			if (echoing)
  800d1a:	85 ff                	test   %edi,%edi
  800d1c:	74 0c                	je     800d2a <readline+0xb2>
				cputchar(c);
  800d1e:	83 ec 0c             	sub    $0xc,%esp
  800d21:	53                   	push   %ebx
  800d22:	e8 79 f4 ff ff       	call   8001a0 <cputchar>
  800d27:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800d2a:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800d30:	8d 76 01             	lea    0x1(%esi),%esi
  800d33:	e9 77 ff ff ff       	jmp    800caf <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  800d38:	83 fb 0d             	cmp    $0xd,%ebx
  800d3b:	74 09                	je     800d46 <readline+0xce>
  800d3d:	83 fb 0a             	cmp    $0xa,%ebx
  800d40:	0f 85 69 ff ff ff    	jne    800caf <readline+0x37>
			if (echoing)
  800d46:	85 ff                	test   %edi,%edi
  800d48:	74 0d                	je     800d57 <readline+0xdf>
				cputchar('\n');
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	6a 0a                	push   $0xa
  800d4f:	e8 4c f4 ff ff       	call   8001a0 <cputchar>
  800d54:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  800d57:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  800d5e:	b8 00 40 80 00       	mov    $0x804000,%eax
		}
	}
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	b8 00 00 00 00       	mov    $0x0,%eax
  800d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d79:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7c:	89 c3                	mov    %eax,%ebx
  800d7e:	89 c7                	mov    %eax,%edi
  800d80:	89 c6                	mov    %eax,%esi
  800d82:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    

00800d89 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	57                   	push   %edi
  800d8d:	56                   	push   %esi
  800d8e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d94:	b8 01 00 00 00       	mov    $0x1,%eax
  800d99:	89 d1                	mov    %edx,%ecx
  800d9b:	89 d3                	mov    %edx,%ebx
  800d9d:	89 d7                	mov    %edx,%edi
  800d9f:	89 d6                	mov    %edx,%esi
  800da1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    

00800da8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
  800dae:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800db6:	b8 03 00 00 00       	mov    $0x3,%eax
  800dbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbe:	89 cb                	mov    %ecx,%ebx
  800dc0:	89 cf                	mov    %ecx,%edi
  800dc2:	89 ce                	mov    %ecx,%esi
  800dc4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	7e 17                	jle    800de1 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dca:	83 ec 0c             	sub    $0xc,%esp
  800dcd:	50                   	push   %eax
  800dce:	6a 03                	push   $0x3
  800dd0:	68 af 24 80 00       	push   $0x8024af
  800dd5:	6a 23                	push   $0x23
  800dd7:	68 cc 24 80 00       	push   $0x8024cc
  800ddc:	e8 ec f4 ff ff       	call   8002cd <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800de1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de4:	5b                   	pop    %ebx
  800de5:	5e                   	pop    %esi
  800de6:	5f                   	pop    %edi
  800de7:	5d                   	pop    %ebp
  800de8:	c3                   	ret    

00800de9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	57                   	push   %edi
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	ba 00 00 00 00       	mov    $0x0,%edx
  800df4:	b8 02 00 00 00       	mov    $0x2,%eax
  800df9:	89 d1                	mov    %edx,%ecx
  800dfb:	89 d3                	mov    %edx,%ebx
  800dfd:	89 d7                	mov    %edx,%edi
  800dff:	89 d6                	mov    %edx,%esi
  800e01:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    

00800e08 <sys_yield>:

void
sys_yield(void)
{
  800e08:	55                   	push   %ebp
  800e09:	89 e5                	mov    %esp,%ebp
  800e0b:	57                   	push   %edi
  800e0c:	56                   	push   %esi
  800e0d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e0e:	ba 00 00 00 00       	mov    $0x0,%edx
  800e13:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e18:	89 d1                	mov    %edx,%ecx
  800e1a:	89 d3                	mov    %edx,%ebx
  800e1c:	89 d7                	mov    %edx,%edi
  800e1e:	89 d6                	mov    %edx,%esi
  800e20:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e30:	be 00 00 00 00       	mov    $0x0,%esi
  800e35:	b8 04 00 00 00       	mov    $0x4,%eax
  800e3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e40:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e43:	89 f7                	mov    %esi,%edi
  800e45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 17                	jle    800e62 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	83 ec 0c             	sub    $0xc,%esp
  800e4e:	50                   	push   %eax
  800e4f:	6a 04                	push   $0x4
  800e51:	68 af 24 80 00       	push   $0x8024af
  800e56:	6a 23                	push   $0x23
  800e58:	68 cc 24 80 00       	push   $0x8024cc
  800e5d:	e8 6b f4 ff ff       	call   8002cd <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e65:	5b                   	pop    %ebx
  800e66:	5e                   	pop    %esi
  800e67:	5f                   	pop    %edi
  800e68:	5d                   	pop    %ebp
  800e69:	c3                   	ret    

00800e6a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	57                   	push   %edi
  800e6e:	56                   	push   %esi
  800e6f:	53                   	push   %ebx
  800e70:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e73:	b8 05 00 00 00       	mov    $0x5,%eax
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e81:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e84:	8b 75 18             	mov    0x18(%ebp),%esi
  800e87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	7e 17                	jle    800ea4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	50                   	push   %eax
  800e91:	6a 05                	push   $0x5
  800e93:	68 af 24 80 00       	push   $0x8024af
  800e98:	6a 23                	push   $0x23
  800e9a:	68 cc 24 80 00       	push   $0x8024cc
  800e9f:	e8 29 f4 ff ff       	call   8002cd <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea7:	5b                   	pop    %ebx
  800ea8:	5e                   	pop    %esi
  800ea9:	5f                   	pop    %edi
  800eaa:	5d                   	pop    %ebp
  800eab:	c3                   	ret    

00800eac <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800eac:	55                   	push   %ebp
  800ead:	89 e5                	mov    %esp,%ebp
  800eaf:	57                   	push   %edi
  800eb0:	56                   	push   %esi
  800eb1:	53                   	push   %ebx
  800eb2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eba:	b8 06 00 00 00       	mov    $0x6,%eax
  800ebf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec5:	89 df                	mov    %ebx,%edi
  800ec7:	89 de                	mov    %ebx,%esi
  800ec9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	7e 17                	jle    800ee6 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecf:	83 ec 0c             	sub    $0xc,%esp
  800ed2:	50                   	push   %eax
  800ed3:	6a 06                	push   $0x6
  800ed5:	68 af 24 80 00       	push   $0x8024af
  800eda:	6a 23                	push   $0x23
  800edc:	68 cc 24 80 00       	push   $0x8024cc
  800ee1:	e8 e7 f3 ff ff       	call   8002cd <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	57                   	push   %edi
  800ef2:	56                   	push   %esi
  800ef3:	53                   	push   %ebx
  800ef4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efc:	b8 08 00 00 00       	mov    $0x8,%eax
  800f01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	89 df                	mov    %ebx,%edi
  800f09:	89 de                	mov    %ebx,%esi
  800f0b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	7e 17                	jle    800f28 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	50                   	push   %eax
  800f15:	6a 08                	push   $0x8
  800f17:	68 af 24 80 00       	push   $0x8024af
  800f1c:	6a 23                	push   $0x23
  800f1e:	68 cc 24 80 00       	push   $0x8024cc
  800f23:	e8 a5 f3 ff ff       	call   8002cd <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f28:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2b:	5b                   	pop    %ebx
  800f2c:	5e                   	pop    %esi
  800f2d:	5f                   	pop    %edi
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	57                   	push   %edi
  800f34:	56                   	push   %esi
  800f35:	53                   	push   %ebx
  800f36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f39:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3e:	b8 09 00 00 00       	mov    $0x9,%eax
  800f43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f46:	8b 55 08             	mov    0x8(%ebp),%edx
  800f49:	89 df                	mov    %ebx,%edi
  800f4b:	89 de                	mov    %ebx,%esi
  800f4d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f4f:	85 c0                	test   %eax,%eax
  800f51:	7e 17                	jle    800f6a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f53:	83 ec 0c             	sub    $0xc,%esp
  800f56:	50                   	push   %eax
  800f57:	6a 09                	push   $0x9
  800f59:	68 af 24 80 00       	push   $0x8024af
  800f5e:	6a 23                	push   $0x23
  800f60:	68 cc 24 80 00       	push   $0x8024cc
  800f65:	e8 63 f3 ff ff       	call   8002cd <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	57                   	push   %edi
  800f76:	56                   	push   %esi
  800f77:	53                   	push   %ebx
  800f78:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f80:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f85:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f88:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8b:	89 df                	mov    %ebx,%edi
  800f8d:	89 de                	mov    %ebx,%esi
  800f8f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f91:	85 c0                	test   %eax,%eax
  800f93:	7e 17                	jle    800fac <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	50                   	push   %eax
  800f99:	6a 0a                	push   $0xa
  800f9b:	68 af 24 80 00       	push   $0x8024af
  800fa0:	6a 23                	push   $0x23
  800fa2:	68 cc 24 80 00       	push   $0x8024cc
  800fa7:	e8 21 f3 ff ff       	call   8002cd <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800fac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800faf:	5b                   	pop    %ebx
  800fb0:	5e                   	pop    %esi
  800fb1:	5f                   	pop    %edi
  800fb2:	5d                   	pop    %ebp
  800fb3:	c3                   	ret    

00800fb4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fb4:	55                   	push   %ebp
  800fb5:	89 e5                	mov    %esp,%ebp
  800fb7:	57                   	push   %edi
  800fb8:	56                   	push   %esi
  800fb9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fba:	be 00 00 00 00       	mov    $0x0,%esi
  800fbf:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc7:	8b 55 08             	mov    0x8(%ebp),%edx
  800fca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fcd:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fd0:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fd2:	5b                   	pop    %ebx
  800fd3:	5e                   	pop    %esi
  800fd4:	5f                   	pop    %edi
  800fd5:	5d                   	pop    %ebp
  800fd6:	c3                   	ret    

00800fd7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe5:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fea:	8b 55 08             	mov    0x8(%ebp),%edx
  800fed:	89 cb                	mov    %ecx,%ebx
  800fef:	89 cf                	mov    %ecx,%edi
  800ff1:	89 ce                	mov    %ecx,%esi
  800ff3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff5:	85 c0                	test   %eax,%eax
  800ff7:	7e 17                	jle    801010 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	50                   	push   %eax
  800ffd:	6a 0d                	push   $0xd
  800fff:	68 af 24 80 00       	push   $0x8024af
  801004:	6a 23                	push   $0x23
  801006:	68 cc 24 80 00       	push   $0x8024cc
  80100b:	e8 bd f2 ff ff       	call   8002cd <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801010:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801013:	5b                   	pop    %ebx
  801014:	5e                   	pop    %esi
  801015:	5f                   	pop    %edi
  801016:	5d                   	pop    %ebp
  801017:	c3                   	ret    

00801018 <sys_gettime>:

int sys_gettime(void)
{
  801018:	55                   	push   %ebp
  801019:	89 e5                	mov    %esp,%ebp
  80101b:	57                   	push   %edi
  80101c:	56                   	push   %esi
  80101d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80101e:	ba 00 00 00 00       	mov    $0x0,%edx
  801023:	b8 0e 00 00 00       	mov    $0xe,%eax
  801028:	89 d1                	mov    %edx,%ecx
  80102a:	89 d3                	mov    %edx,%ebx
  80102c:	89 d7                	mov    %edx,%edi
  80102e:	89 d6                	mov    %edx,%esi
  801030:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  801032:	5b                   	pop    %ebx
  801033:	5e                   	pop    %esi
  801034:	5f                   	pop    %edi
  801035:	5d                   	pop    %ebp
  801036:	c3                   	ret    

00801037 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80103a:	8b 45 08             	mov    0x8(%ebp),%eax
  80103d:	05 00 00 00 30       	add    $0x30000000,%eax
  801042:	c1 e8 0c             	shr    $0xc,%eax
}
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80104a:	8b 45 08             	mov    0x8(%ebp),%eax
  80104d:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801052:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801057:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80105c:	5d                   	pop    %ebp
  80105d:	c3                   	ret    

0080105e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80105e:	55                   	push   %ebp
  80105f:	89 e5                	mov    %esp,%ebp
  801061:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801064:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801069:	89 c2                	mov    %eax,%edx
  80106b:	c1 ea 16             	shr    $0x16,%edx
  80106e:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801075:	f6 c2 01             	test   $0x1,%dl
  801078:	74 11                	je     80108b <fd_alloc+0x2d>
  80107a:	89 c2                	mov    %eax,%edx
  80107c:	c1 ea 0c             	shr    $0xc,%edx
  80107f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801086:	f6 c2 01             	test   $0x1,%dl
  801089:	75 09                	jne    801094 <fd_alloc+0x36>
			*fd_store = fd;
  80108b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80108d:	b8 00 00 00 00       	mov    $0x0,%eax
  801092:	eb 17                	jmp    8010ab <fd_alloc+0x4d>
  801094:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801099:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80109e:	75 c9                	jne    801069 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010a0:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010a6:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010ab:	5d                   	pop    %ebp
  8010ac:	c3                   	ret    

008010ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ad:	55                   	push   %ebp
  8010ae:	89 e5                	mov    %esp,%ebp
  8010b0:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010b3:	83 f8 1f             	cmp    $0x1f,%eax
  8010b6:	77 36                	ja     8010ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010b8:	c1 e0 0c             	shl    $0xc,%eax
  8010bb:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010c0:	89 c2                	mov    %eax,%edx
  8010c2:	c1 ea 16             	shr    $0x16,%edx
  8010c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010cc:	f6 c2 01             	test   $0x1,%dl
  8010cf:	74 24                	je     8010f5 <fd_lookup+0x48>
  8010d1:	89 c2                	mov    %eax,%edx
  8010d3:	c1 ea 0c             	shr    $0xc,%edx
  8010d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010dd:	f6 c2 01             	test   $0x1,%dl
  8010e0:	74 1a                	je     8010fc <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e5:	89 02                	mov    %eax,(%edx)
	return 0;
  8010e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8010ec:	eb 13                	jmp    801101 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010f3:	eb 0c                	jmp    801101 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fa:	eb 05                	jmp    801101 <fd_lookup+0x54>
  8010fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 08             	sub    $0x8,%esp
  801109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110c:	ba 58 25 80 00       	mov    $0x802558,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801111:	eb 13                	jmp    801126 <dev_lookup+0x23>
  801113:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801116:	39 08                	cmp    %ecx,(%eax)
  801118:	75 0c                	jne    801126 <dev_lookup+0x23>
			*dev = devtab[i];
  80111a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80111d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80111f:	b8 00 00 00 00       	mov    $0x0,%eax
  801124:	eb 2e                	jmp    801154 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801126:	8b 02                	mov    (%edx),%eax
  801128:	85 c0                	test   %eax,%eax
  80112a:	75 e7                	jne    801113 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80112c:	a1 04 44 80 00       	mov    0x804404,%eax
  801131:	8b 40 48             	mov    0x48(%eax),%eax
  801134:	83 ec 04             	sub    $0x4,%esp
  801137:	51                   	push   %ecx
  801138:	50                   	push   %eax
  801139:	68 dc 24 80 00       	push   $0x8024dc
  80113e:	e8 63 f2 ff ff       	call   8003a6 <cprintf>
	*dev = 0;
  801143:	8b 45 0c             	mov    0xc(%ebp),%eax
  801146:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 10             	sub    $0x10,%esp
  80115e:	8b 75 08             	mov    0x8(%ebp),%esi
  801161:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801164:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801167:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801168:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80116e:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801171:	50                   	push   %eax
  801172:	e8 36 ff ff ff       	call   8010ad <fd_lookup>
  801177:	83 c4 08             	add    $0x8,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	78 05                	js     801183 <fd_close+0x2d>
	    || fd != fd2)
  80117e:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801181:	74 0b                	je     80118e <fd_close+0x38>
		return (must_exist ? r : 0);
  801183:	80 fb 01             	cmp    $0x1,%bl
  801186:	19 d2                	sbb    %edx,%edx
  801188:	f7 d2                	not    %edx
  80118a:	21 d0                	and    %edx,%eax
  80118c:	eb 41                	jmp    8011cf <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80118e:	83 ec 08             	sub    $0x8,%esp
  801191:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801194:	50                   	push   %eax
  801195:	ff 36                	pushl  (%esi)
  801197:	e8 67 ff ff ff       	call   801103 <dev_lookup>
  80119c:	89 c3                	mov    %eax,%ebx
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	78 1a                	js     8011bf <fd_close+0x69>
		if (dev->dev_close)
  8011a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a8:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011ab:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	74 0b                	je     8011bf <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8011b4:	83 ec 0c             	sub    $0xc,%esp
  8011b7:	56                   	push   %esi
  8011b8:	ff d0                	call   *%eax
  8011ba:	89 c3                	mov    %eax,%ebx
  8011bc:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011bf:	83 ec 08             	sub    $0x8,%esp
  8011c2:	56                   	push   %esi
  8011c3:	6a 00                	push   $0x0
  8011c5:	e8 e2 fc ff ff       	call   800eac <sys_page_unmap>
	return r;
  8011ca:	83 c4 10             	add    $0x10,%esp
  8011cd:	89 d8                	mov    %ebx,%eax
}
  8011cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d2:	5b                   	pop    %ebx
  8011d3:	5e                   	pop    %esi
  8011d4:	5d                   	pop    %ebp
  8011d5:	c3                   	ret    

008011d6 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011d6:	55                   	push   %ebp
  8011d7:	89 e5                	mov    %esp,%ebp
  8011d9:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011df:	50                   	push   %eax
  8011e0:	ff 75 08             	pushl  0x8(%ebp)
  8011e3:	e8 c5 fe ff ff       	call   8010ad <fd_lookup>
  8011e8:	89 c2                	mov    %eax,%edx
  8011ea:	83 c4 08             	add    $0x8,%esp
  8011ed:	85 d2                	test   %edx,%edx
  8011ef:	78 10                	js     801201 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	6a 01                	push   $0x1
  8011f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8011f9:	e8 58 ff ff ff       	call   801156 <fd_close>
  8011fe:	83 c4 10             	add    $0x10,%esp
}
  801201:	c9                   	leave  
  801202:	c3                   	ret    

00801203 <close_all>:

void
close_all(void)
{
  801203:	55                   	push   %ebp
  801204:	89 e5                	mov    %esp,%ebp
  801206:	53                   	push   %ebx
  801207:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80120a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80120f:	83 ec 0c             	sub    $0xc,%esp
  801212:	53                   	push   %ebx
  801213:	e8 be ff ff ff       	call   8011d6 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801218:	83 c3 01             	add    $0x1,%ebx
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	83 fb 20             	cmp    $0x20,%ebx
  801221:	75 ec                	jne    80120f <close_all+0xc>
		close(i);
}
  801223:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801226:	c9                   	leave  
  801227:	c3                   	ret    

00801228 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	57                   	push   %edi
  80122c:	56                   	push   %esi
  80122d:	53                   	push   %ebx
  80122e:	83 ec 2c             	sub    $0x2c,%esp
  801231:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801234:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 75 08             	pushl  0x8(%ebp)
  80123b:	e8 6d fe ff ff       	call   8010ad <fd_lookup>
  801240:	89 c2                	mov    %eax,%edx
  801242:	83 c4 08             	add    $0x8,%esp
  801245:	85 d2                	test   %edx,%edx
  801247:	0f 88 c1 00 00 00    	js     80130e <dup+0xe6>
		return r;
	close(newfdnum);
  80124d:	83 ec 0c             	sub    $0xc,%esp
  801250:	56                   	push   %esi
  801251:	e8 80 ff ff ff       	call   8011d6 <close>

	newfd = INDEX2FD(newfdnum);
  801256:	89 f3                	mov    %esi,%ebx
  801258:	c1 e3 0c             	shl    $0xc,%ebx
  80125b:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801261:	83 c4 04             	add    $0x4,%esp
  801264:	ff 75 e4             	pushl  -0x1c(%ebp)
  801267:	e8 db fd ff ff       	call   801047 <fd2data>
  80126c:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80126e:	89 1c 24             	mov    %ebx,(%esp)
  801271:	e8 d1 fd ff ff       	call   801047 <fd2data>
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80127c:	89 f8                	mov    %edi,%eax
  80127e:	c1 e8 16             	shr    $0x16,%eax
  801281:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801288:	a8 01                	test   $0x1,%al
  80128a:	74 37                	je     8012c3 <dup+0x9b>
  80128c:	89 f8                	mov    %edi,%eax
  80128e:	c1 e8 0c             	shr    $0xc,%eax
  801291:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801298:	f6 c2 01             	test   $0x1,%dl
  80129b:	74 26                	je     8012c3 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80129d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a4:	83 ec 0c             	sub    $0xc,%esp
  8012a7:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ac:	50                   	push   %eax
  8012ad:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012b0:	6a 00                	push   $0x0
  8012b2:	57                   	push   %edi
  8012b3:	6a 00                	push   $0x0
  8012b5:	e8 b0 fb ff ff       	call   800e6a <sys_page_map>
  8012ba:	89 c7                	mov    %eax,%edi
  8012bc:	83 c4 20             	add    $0x20,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 2e                	js     8012f1 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012c6:	89 d0                	mov    %edx,%eax
  8012c8:	c1 e8 0c             	shr    $0xc,%eax
  8012cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d2:	83 ec 0c             	sub    $0xc,%esp
  8012d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8012da:	50                   	push   %eax
  8012db:	53                   	push   %ebx
  8012dc:	6a 00                	push   $0x0
  8012de:	52                   	push   %edx
  8012df:	6a 00                	push   $0x0
  8012e1:	e8 84 fb ff ff       	call   800e6a <sys_page_map>
  8012e6:	89 c7                	mov    %eax,%edi
  8012e8:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012eb:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ed:	85 ff                	test   %edi,%edi
  8012ef:	79 1d                	jns    80130e <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	53                   	push   %ebx
  8012f5:	6a 00                	push   $0x0
  8012f7:	e8 b0 fb ff ff       	call   800eac <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	ff 75 d4             	pushl  -0x2c(%ebp)
  801302:	6a 00                	push   $0x0
  801304:	e8 a3 fb ff ff       	call   800eac <sys_page_unmap>
	return r;
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	89 f8                	mov    %edi,%eax
}
  80130e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801311:	5b                   	pop    %ebx
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    

00801316 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	53                   	push   %ebx
  80131a:	83 ec 14             	sub    $0x14,%esp
  80131d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801320:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801323:	50                   	push   %eax
  801324:	53                   	push   %ebx
  801325:	e8 83 fd ff ff       	call   8010ad <fd_lookup>
  80132a:	83 c4 08             	add    $0x8,%esp
  80132d:	89 c2                	mov    %eax,%edx
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 6d                	js     8013a0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133d:	ff 30                	pushl  (%eax)
  80133f:	e8 bf fd ff ff       	call   801103 <dev_lookup>
  801344:	83 c4 10             	add    $0x10,%esp
  801347:	85 c0                	test   %eax,%eax
  801349:	78 4c                	js     801397 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80134b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80134e:	8b 42 08             	mov    0x8(%edx),%eax
  801351:	83 e0 03             	and    $0x3,%eax
  801354:	83 f8 01             	cmp    $0x1,%eax
  801357:	75 21                	jne    80137a <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801359:	a1 04 44 80 00       	mov    0x804404,%eax
  80135e:	8b 40 48             	mov    0x48(%eax),%eax
  801361:	83 ec 04             	sub    $0x4,%esp
  801364:	53                   	push   %ebx
  801365:	50                   	push   %eax
  801366:	68 1d 25 80 00       	push   $0x80251d
  80136b:	e8 36 f0 ff ff       	call   8003a6 <cprintf>
		return -E_INVAL;
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801378:	eb 26                	jmp    8013a0 <read+0x8a>
	}
	if (!dev->dev_read)
  80137a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137d:	8b 40 08             	mov    0x8(%eax),%eax
  801380:	85 c0                	test   %eax,%eax
  801382:	74 17                	je     80139b <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	ff 75 10             	pushl  0x10(%ebp)
  80138a:	ff 75 0c             	pushl  0xc(%ebp)
  80138d:	52                   	push   %edx
  80138e:	ff d0                	call   *%eax
  801390:	89 c2                	mov    %eax,%edx
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	eb 09                	jmp    8013a0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801397:	89 c2                	mov    %eax,%edx
  801399:	eb 05                	jmp    8013a0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80139b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013a0:	89 d0                	mov    %edx,%eax
  8013a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a5:	c9                   	leave  
  8013a6:	c3                   	ret    

008013a7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013a7:	55                   	push   %ebp
  8013a8:	89 e5                	mov    %esp,%ebp
  8013aa:	57                   	push   %edi
  8013ab:	56                   	push   %esi
  8013ac:	53                   	push   %ebx
  8013ad:	83 ec 0c             	sub    $0xc,%esp
  8013b0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013b3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013bb:	eb 21                	jmp    8013de <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013bd:	83 ec 04             	sub    $0x4,%esp
  8013c0:	89 f0                	mov    %esi,%eax
  8013c2:	29 d8                	sub    %ebx,%eax
  8013c4:	50                   	push   %eax
  8013c5:	89 d8                	mov    %ebx,%eax
  8013c7:	03 45 0c             	add    0xc(%ebp),%eax
  8013ca:	50                   	push   %eax
  8013cb:	57                   	push   %edi
  8013cc:	e8 45 ff ff ff       	call   801316 <read>
		if (m < 0)
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	78 0c                	js     8013e4 <readn+0x3d>
			return m;
		if (m == 0)
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	74 06                	je     8013e2 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013dc:	01 c3                	add    %eax,%ebx
  8013de:	39 f3                	cmp    %esi,%ebx
  8013e0:	72 db                	jb     8013bd <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8013e2:	89 d8                	mov    %ebx,%eax
}
  8013e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e7:	5b                   	pop    %ebx
  8013e8:	5e                   	pop    %esi
  8013e9:	5f                   	pop    %edi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 14             	sub    $0x14,%esp
  8013f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013f9:	50                   	push   %eax
  8013fa:	53                   	push   %ebx
  8013fb:	e8 ad fc ff ff       	call   8010ad <fd_lookup>
  801400:	83 c4 08             	add    $0x8,%esp
  801403:	89 c2                	mov    %eax,%edx
  801405:	85 c0                	test   %eax,%eax
  801407:	78 68                	js     801471 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801409:	83 ec 08             	sub    $0x8,%esp
  80140c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140f:	50                   	push   %eax
  801410:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801413:	ff 30                	pushl  (%eax)
  801415:	e8 e9 fc ff ff       	call   801103 <dev_lookup>
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 c0                	test   %eax,%eax
  80141f:	78 47                	js     801468 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801421:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801424:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801428:	75 21                	jne    80144b <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80142a:	a1 04 44 80 00       	mov    0x804404,%eax
  80142f:	8b 40 48             	mov    0x48(%eax),%eax
  801432:	83 ec 04             	sub    $0x4,%esp
  801435:	53                   	push   %ebx
  801436:	50                   	push   %eax
  801437:	68 39 25 80 00       	push   $0x802539
  80143c:	e8 65 ef ff ff       	call   8003a6 <cprintf>
		return -E_INVAL;
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801449:	eb 26                	jmp    801471 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80144b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80144e:	8b 52 0c             	mov    0xc(%edx),%edx
  801451:	85 d2                	test   %edx,%edx
  801453:	74 17                	je     80146c <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	ff 75 10             	pushl  0x10(%ebp)
  80145b:	ff 75 0c             	pushl  0xc(%ebp)
  80145e:	50                   	push   %eax
  80145f:	ff d2                	call   *%edx
  801461:	89 c2                	mov    %eax,%edx
  801463:	83 c4 10             	add    $0x10,%esp
  801466:	eb 09                	jmp    801471 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801468:	89 c2                	mov    %eax,%edx
  80146a:	eb 05                	jmp    801471 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80146c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801471:	89 d0                	mov    %edx,%eax
  801473:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <seek>:

int
seek(int fdnum, off_t offset)
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147e:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	ff 75 08             	pushl  0x8(%ebp)
  801485:	e8 23 fc ff ff       	call   8010ad <fd_lookup>
  80148a:	83 c4 08             	add    $0x8,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 0e                	js     80149f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801491:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801494:	8b 55 0c             	mov    0xc(%ebp),%edx
  801497:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80149a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80149f:	c9                   	leave  
  8014a0:	c3                   	ret    

008014a1 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	53                   	push   %ebx
  8014a5:	83 ec 14             	sub    $0x14,%esp
  8014a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	53                   	push   %ebx
  8014b0:	e8 f8 fb ff ff       	call   8010ad <fd_lookup>
  8014b5:	83 c4 08             	add    $0x8,%esp
  8014b8:	89 c2                	mov    %eax,%edx
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 65                	js     801523 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014be:	83 ec 08             	sub    $0x8,%esp
  8014c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c4:	50                   	push   %eax
  8014c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c8:	ff 30                	pushl  (%eax)
  8014ca:	e8 34 fc ff ff       	call   801103 <dev_lookup>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 44                	js     80151a <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014dd:	75 21                	jne    801500 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014df:	a1 04 44 80 00       	mov    0x804404,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014e4:	8b 40 48             	mov    0x48(%eax),%eax
  8014e7:	83 ec 04             	sub    $0x4,%esp
  8014ea:	53                   	push   %ebx
  8014eb:	50                   	push   %eax
  8014ec:	68 fc 24 80 00       	push   $0x8024fc
  8014f1:	e8 b0 ee ff ff       	call   8003a6 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014fe:	eb 23                	jmp    801523 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801500:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801503:	8b 52 18             	mov    0x18(%edx),%edx
  801506:	85 d2                	test   %edx,%edx
  801508:	74 14                	je     80151e <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80150a:	83 ec 08             	sub    $0x8,%esp
  80150d:	ff 75 0c             	pushl  0xc(%ebp)
  801510:	50                   	push   %eax
  801511:	ff d2                	call   *%edx
  801513:	89 c2                	mov    %eax,%edx
  801515:	83 c4 10             	add    $0x10,%esp
  801518:	eb 09                	jmp    801523 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151a:	89 c2                	mov    %eax,%edx
  80151c:	eb 05                	jmp    801523 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80151e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801523:	89 d0                	mov    %edx,%eax
  801525:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801528:	c9                   	leave  
  801529:	c3                   	ret    

0080152a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 14             	sub    $0x14,%esp
  801531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801534:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	ff 75 08             	pushl  0x8(%ebp)
  80153b:	e8 6d fb ff ff       	call   8010ad <fd_lookup>
  801540:	83 c4 08             	add    $0x8,%esp
  801543:	89 c2                	mov    %eax,%edx
  801545:	85 c0                	test   %eax,%eax
  801547:	78 58                	js     8015a1 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80154f:	50                   	push   %eax
  801550:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801553:	ff 30                	pushl  (%eax)
  801555:	e8 a9 fb ff ff       	call   801103 <dev_lookup>
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 37                	js     801598 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801561:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801564:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801568:	74 32                	je     80159c <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80156a:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80156d:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801574:	00 00 00 
	stat->st_isdir = 0;
  801577:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80157e:	00 00 00 
	stat->st_dev = dev;
  801581:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801587:	83 ec 08             	sub    $0x8,%esp
  80158a:	53                   	push   %ebx
  80158b:	ff 75 f0             	pushl  -0x10(%ebp)
  80158e:	ff 50 14             	call   *0x14(%eax)
  801591:	89 c2                	mov    %eax,%edx
  801593:	83 c4 10             	add    $0x10,%esp
  801596:	eb 09                	jmp    8015a1 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801598:	89 c2                	mov    %eax,%edx
  80159a:	eb 05                	jmp    8015a1 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80159c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015a1:	89 d0                	mov    %edx,%eax
  8015a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	56                   	push   %esi
  8015ac:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	6a 00                	push   $0x0
  8015b2:	ff 75 08             	pushl  0x8(%ebp)
  8015b5:	e8 e7 01 00 00       	call   8017a1 <open>
  8015ba:	89 c3                	mov    %eax,%ebx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 db                	test   %ebx,%ebx
  8015c1:	78 1b                	js     8015de <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015c3:	83 ec 08             	sub    $0x8,%esp
  8015c6:	ff 75 0c             	pushl  0xc(%ebp)
  8015c9:	53                   	push   %ebx
  8015ca:	e8 5b ff ff ff       	call   80152a <fstat>
  8015cf:	89 c6                	mov    %eax,%esi
	close(fd);
  8015d1:	89 1c 24             	mov    %ebx,(%esp)
  8015d4:	e8 fd fb ff ff       	call   8011d6 <close>
	return r;
  8015d9:	83 c4 10             	add    $0x10,%esp
  8015dc:	89 f0                	mov    %esi,%eax
}
  8015de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5d                   	pop    %ebp
  8015e4:	c3                   	ret    

008015e5 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	56                   	push   %esi
  8015e9:	53                   	push   %ebx
  8015ea:	89 c6                	mov    %eax,%esi
  8015ec:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015ee:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  8015f5:	75 12                	jne    801609 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015f7:	83 ec 0c             	sub    $0xc,%esp
  8015fa:	6a 03                	push   $0x3
  8015fc:	e8 62 07 00 00       	call   801d63 <ipc_find_env>
  801601:	a3 00 44 80 00       	mov    %eax,0x804400
  801606:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801609:	6a 07                	push   $0x7
  80160b:	68 00 50 80 00       	push   $0x805000
  801610:	56                   	push   %esi
  801611:	ff 35 00 44 80 00    	pushl  0x804400
  801617:	e8 f6 06 00 00       	call   801d12 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80161c:	83 c4 0c             	add    $0xc,%esp
  80161f:	6a 00                	push   $0x0
  801621:	53                   	push   %ebx
  801622:	6a 00                	push   $0x0
  801624:	e8 83 06 00 00       	call   801cac <ipc_recv>
}
  801629:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162c:	5b                   	pop    %ebx
  80162d:	5e                   	pop    %esi
  80162e:	5d                   	pop    %ebp
  80162f:	c3                   	ret    

00801630 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801630:	55                   	push   %ebp
  801631:	89 e5                	mov    %esp,%ebp
  801633:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801636:	8b 45 08             	mov    0x8(%ebp),%eax
  801639:	8b 40 0c             	mov    0xc(%eax),%eax
  80163c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801641:	8b 45 0c             	mov    0xc(%ebp),%eax
  801644:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801649:	ba 00 00 00 00       	mov    $0x0,%edx
  80164e:	b8 02 00 00 00       	mov    $0x2,%eax
  801653:	e8 8d ff ff ff       	call   8015e5 <fsipc>
}
  801658:	c9                   	leave  
  801659:	c3                   	ret    

0080165a <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801660:	8b 45 08             	mov    0x8(%ebp),%eax
  801663:	8b 40 0c             	mov    0xc(%eax),%eax
  801666:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80166b:	ba 00 00 00 00       	mov    $0x0,%edx
  801670:	b8 06 00 00 00       	mov    $0x6,%eax
  801675:	e8 6b ff ff ff       	call   8015e5 <fsipc>
}
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	53                   	push   %ebx
  801680:	83 ec 04             	sub    $0x4,%esp
  801683:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801686:	8b 45 08             	mov    0x8(%ebp),%eax
  801689:	8b 40 0c             	mov    0xc(%eax),%eax
  80168c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801691:	ba 00 00 00 00       	mov    $0x0,%edx
  801696:	b8 05 00 00 00       	mov    $0x5,%eax
  80169b:	e8 45 ff ff ff       	call   8015e5 <fsipc>
  8016a0:	89 c2                	mov    %eax,%edx
  8016a2:	85 d2                	test   %edx,%edx
  8016a4:	78 2c                	js     8016d2 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016a6:	83 ec 08             	sub    $0x8,%esp
  8016a9:	68 00 50 80 00       	push   $0x805000
  8016ae:	53                   	push   %ebx
  8016af:	e8 76 f2 ff ff       	call   80092a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016b4:	a1 80 50 80 00       	mov    0x805080,%eax
  8016b9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016bf:	a1 84 50 80 00       	mov    0x805084,%eax
  8016c4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d5:	c9                   	leave  
  8016d6:	c3                   	ret    

008016d7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016d7:	55                   	push   %ebp
  8016d8:	89 e5                	mov    %esp,%ebp
  8016da:	83 ec 08             	sub    $0x8,%esp
  8016dd:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8016e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8016e3:	8b 52 0c             	mov    0xc(%edx),%edx
  8016e6:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8016ec:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8016f1:	76 05                	jbe    8016f8 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8016f3:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8016f8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8016fd:	83 ec 04             	sub    $0x4,%esp
  801700:	50                   	push   %eax
  801701:	ff 75 0c             	pushl  0xc(%ebp)
  801704:	68 08 50 80 00       	push   $0x805008
  801709:	e8 ae f3 ff ff       	call   800abc <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
  801713:	b8 04 00 00 00       	mov    $0x4,%eax
  801718:	e8 c8 fe ff ff       	call   8015e5 <fsipc>
	return write;
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801727:	8b 45 08             	mov    0x8(%ebp),%eax
  80172a:	8b 40 0c             	mov    0xc(%eax),%eax
  80172d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801732:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801738:	ba 00 00 00 00       	mov    $0x0,%edx
  80173d:	b8 03 00 00 00       	mov    $0x3,%eax
  801742:	e8 9e fe ff ff       	call   8015e5 <fsipc>
  801747:	89 c3                	mov    %eax,%ebx
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 4b                	js     801798 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80174d:	39 c6                	cmp    %eax,%esi
  80174f:	73 16                	jae    801767 <devfile_read+0x48>
  801751:	68 68 25 80 00       	push   $0x802568
  801756:	68 6f 25 80 00       	push   $0x80256f
  80175b:	6a 7c                	push   $0x7c
  80175d:	68 84 25 80 00       	push   $0x802584
  801762:	e8 66 eb ff ff       	call   8002cd <_panic>
	assert(r <= PGSIZE);
  801767:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80176c:	7e 16                	jle    801784 <devfile_read+0x65>
  80176e:	68 8f 25 80 00       	push   $0x80258f
  801773:	68 6f 25 80 00       	push   $0x80256f
  801778:	6a 7d                	push   $0x7d
  80177a:	68 84 25 80 00       	push   $0x802584
  80177f:	e8 49 eb ff ff       	call   8002cd <_panic>
	memmove(buf, &fsipcbuf, r);
  801784:	83 ec 04             	sub    $0x4,%esp
  801787:	50                   	push   %eax
  801788:	68 00 50 80 00       	push   $0x805000
  80178d:	ff 75 0c             	pushl  0xc(%ebp)
  801790:	e8 27 f3 ff ff       	call   800abc <memmove>
	return r;
  801795:	83 c4 10             	add    $0x10,%esp
}
  801798:	89 d8                	mov    %ebx,%eax
  80179a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	53                   	push   %ebx
  8017a5:	83 ec 20             	sub    $0x20,%esp
  8017a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017ab:	53                   	push   %ebx
  8017ac:	e8 40 f1 ff ff       	call   8008f1 <strlen>
  8017b1:	83 c4 10             	add    $0x10,%esp
  8017b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017b9:	7f 67                	jg     801822 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017bb:	83 ec 0c             	sub    $0xc,%esp
  8017be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c1:	50                   	push   %eax
  8017c2:	e8 97 f8 ff ff       	call   80105e <fd_alloc>
  8017c7:	83 c4 10             	add    $0x10,%esp
		return r;
  8017ca:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 57                	js     801827 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	53                   	push   %ebx
  8017d4:	68 00 50 80 00       	push   $0x805000
  8017d9:	e8 4c f1 ff ff       	call   80092a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e1:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8017ee:	e8 f2 fd ff ff       	call   8015e5 <fsipc>
  8017f3:	89 c3                	mov    %eax,%ebx
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	79 14                	jns    801810 <open+0x6f>
		fd_close(fd, 0);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	6a 00                	push   $0x0
  801801:	ff 75 f4             	pushl  -0xc(%ebp)
  801804:	e8 4d f9 ff ff       	call   801156 <fd_close>
		return r;
  801809:	83 c4 10             	add    $0x10,%esp
  80180c:	89 da                	mov    %ebx,%edx
  80180e:	eb 17                	jmp    801827 <open+0x86>
	}

	return fd2num(fd);
  801810:	83 ec 0c             	sub    $0xc,%esp
  801813:	ff 75 f4             	pushl  -0xc(%ebp)
  801816:	e8 1c f8 ff ff       	call   801037 <fd2num>
  80181b:	89 c2                	mov    %eax,%edx
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	eb 05                	jmp    801827 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801822:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801827:	89 d0                	mov    %edx,%eax
  801829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801834:	ba 00 00 00 00       	mov    $0x0,%edx
  801839:	b8 08 00 00 00       	mov    $0x8,%eax
  80183e:	e8 a2 fd ff ff       	call   8015e5 <fsipc>
}
  801843:	c9                   	leave  
  801844:	c3                   	ret    

00801845 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801845:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801849:	7e 3a                	jle    801885 <writebuf+0x40>
};


static void
writebuf(struct printbuf *b)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	53                   	push   %ebx
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  801854:	ff 70 04             	pushl  0x4(%eax)
  801857:	8d 40 10             	lea    0x10(%eax),%eax
  80185a:	50                   	push   %eax
  80185b:	ff 33                	pushl  (%ebx)
  80185d:	e8 8a fb ff ff       	call   8013ec <write>
		if (result > 0)
  801862:	83 c4 10             	add    $0x10,%esp
  801865:	85 c0                	test   %eax,%eax
  801867:	7e 03                	jle    80186c <writebuf+0x27>
			b->result += result;
  801869:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80186c:	39 43 04             	cmp    %eax,0x4(%ebx)
  80186f:	74 10                	je     801881 <writebuf+0x3c>
			b->error = (result < 0 ? result : 0);
  801871:	85 c0                	test   %eax,%eax
  801873:	0f 9f c2             	setg   %dl
  801876:	0f b6 d2             	movzbl %dl,%edx
  801879:	83 ea 01             	sub    $0x1,%edx
  80187c:	21 d0                	and    %edx,%eax
  80187e:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801881:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801884:	c9                   	leave  
  801885:	f3 c3                	repz ret 

00801887 <putch>:

static void
putch(int ch, void *thunk)
{
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	53                   	push   %ebx
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801891:	8b 53 04             	mov    0x4(%ebx),%edx
  801894:	8d 42 01             	lea    0x1(%edx),%eax
  801897:	89 43 04             	mov    %eax,0x4(%ebx)
  80189a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189d:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8018a1:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018a6:	75 0e                	jne    8018b6 <putch+0x2f>
		writebuf(b);
  8018a8:	89 d8                	mov    %ebx,%eax
  8018aa:	e8 96 ff ff ff       	call   801845 <writebuf>
		b->idx = 0;
  8018af:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  8018b6:	83 c4 04             	add    $0x4,%esp
  8018b9:	5b                   	pop    %ebx
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c8:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018ce:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018d5:	00 00 00 
	b.result = 0;
  8018d8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018df:	00 00 00 
	b.error = 1;
  8018e2:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018e9:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018ec:	ff 75 10             	pushl  0x10(%ebp)
  8018ef:	ff 75 0c             	pushl  0xc(%ebp)
  8018f2:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018f8:	50                   	push   %eax
  8018f9:	68 87 18 80 00       	push   $0x801887
  8018fe:	e8 d5 eb ff ff       	call   8004d8 <vprintfmt>
	if (b.idx > 0)
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80190d:	7e 0b                	jle    80191a <vfprintf+0x5e>
		writebuf(&b);
  80190f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801915:	e8 2b ff ff ff       	call   801845 <writebuf>

	return (b.result ? b.result : b.error);
  80191a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801920:	85 c0                	test   %eax,%eax
  801922:	75 06                	jne    80192a <vfprintf+0x6e>
  801924:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    

0080192c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801932:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801935:	50                   	push   %eax
  801936:	ff 75 0c             	pushl  0xc(%ebp)
  801939:	ff 75 08             	pushl  0x8(%ebp)
  80193c:	e8 7b ff ff ff       	call   8018bc <vfprintf>
	va_end(ap);

	return cnt;
}
  801941:	c9                   	leave  
  801942:	c3                   	ret    

00801943 <printf>:

int
printf(const char *fmt, ...)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801949:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80194c:	50                   	push   %eax
  80194d:	ff 75 08             	pushl  0x8(%ebp)
  801950:	6a 01                	push   $0x1
  801952:	e8 65 ff ff ff       	call   8018bc <vfprintf>
	va_end(ap);

	return cnt;
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
  80195c:	56                   	push   %esi
  80195d:	53                   	push   %ebx
  80195e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801961:	83 ec 0c             	sub    $0xc,%esp
  801964:	ff 75 08             	pushl  0x8(%ebp)
  801967:	e8 db f6 ff ff       	call   801047 <fd2data>
  80196c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80196e:	83 c4 08             	add    $0x8,%esp
  801971:	68 9b 25 80 00       	push   $0x80259b
  801976:	53                   	push   %ebx
  801977:	e8 ae ef ff ff       	call   80092a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80197c:	8b 56 04             	mov    0x4(%esi),%edx
  80197f:	89 d0                	mov    %edx,%eax
  801981:	2b 06                	sub    (%esi),%eax
  801983:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801989:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801990:	00 00 00 
	stat->st_dev = &devpipe;
  801993:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80199a:	30 80 00 
	return 0;
}
  80199d:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a5:	5b                   	pop    %ebx
  8019a6:	5e                   	pop    %esi
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019b3:	53                   	push   %ebx
  8019b4:	6a 00                	push   $0x0
  8019b6:	e8 f1 f4 ff ff       	call   800eac <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019bb:	89 1c 24             	mov    %ebx,(%esp)
  8019be:	e8 84 f6 ff ff       	call   801047 <fd2data>
  8019c3:	83 c4 08             	add    $0x8,%esp
  8019c6:	50                   	push   %eax
  8019c7:	6a 00                	push   $0x0
  8019c9:	e8 de f4 ff ff       	call   800eac <sys_page_unmap>
}
  8019ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d1:	c9                   	leave  
  8019d2:	c3                   	ret    

008019d3 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	57                   	push   %edi
  8019d7:	56                   	push   %esi
  8019d8:	53                   	push   %ebx
  8019d9:	83 ec 1c             	sub    $0x1c,%esp
  8019dc:	89 c7                	mov    %eax,%edi
  8019de:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8019e0:	a1 04 44 80 00       	mov    0x804404,%eax
  8019e5:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019e8:	83 ec 0c             	sub    $0xc,%esp
  8019eb:	57                   	push   %edi
  8019ec:	e8 aa 03 00 00       	call   801d9b <pageref>
  8019f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019f4:	89 34 24             	mov    %esi,(%esp)
  8019f7:	e8 9f 03 00 00       	call   801d9b <pageref>
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a02:	0f 94 c0             	sete   %al
  801a05:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801a08:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a0e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a11:	39 cb                	cmp    %ecx,%ebx
  801a13:	74 15                	je     801a2a <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801a15:	8b 52 58             	mov    0x58(%edx),%edx
  801a18:	50                   	push   %eax
  801a19:	52                   	push   %edx
  801a1a:	53                   	push   %ebx
  801a1b:	68 a8 25 80 00       	push   $0x8025a8
  801a20:	e8 81 e9 ff ff       	call   8003a6 <cprintf>
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	eb b6                	jmp    8019e0 <_pipeisclosed+0xd>
	}
}
  801a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5f                   	pop    %edi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	57                   	push   %edi
  801a36:	56                   	push   %esi
  801a37:	53                   	push   %ebx
  801a38:	83 ec 28             	sub    $0x28,%esp
  801a3b:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801a3e:	56                   	push   %esi
  801a3f:	e8 03 f6 ff ff       	call   801047 <fd2data>
  801a44:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	bf 00 00 00 00       	mov    $0x0,%edi
  801a4e:	eb 4b                	jmp    801a9b <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801a50:	89 da                	mov    %ebx,%edx
  801a52:	89 f0                	mov    %esi,%eax
  801a54:	e8 7a ff ff ff       	call   8019d3 <_pipeisclosed>
  801a59:	85 c0                	test   %eax,%eax
  801a5b:	75 48                	jne    801aa5 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801a5d:	e8 a6 f3 ff ff       	call   800e08 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a62:	8b 43 04             	mov    0x4(%ebx),%eax
  801a65:	8b 0b                	mov    (%ebx),%ecx
  801a67:	8d 51 20             	lea    0x20(%ecx),%edx
  801a6a:	39 d0                	cmp    %edx,%eax
  801a6c:	73 e2                	jae    801a50 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a71:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a75:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a78:	89 c2                	mov    %eax,%edx
  801a7a:	c1 fa 1f             	sar    $0x1f,%edx
  801a7d:	89 d1                	mov    %edx,%ecx
  801a7f:	c1 e9 1b             	shr    $0x1b,%ecx
  801a82:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a85:	83 e2 1f             	and    $0x1f,%edx
  801a88:	29 ca                	sub    %ecx,%edx
  801a8a:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a8e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a92:	83 c0 01             	add    $0x1,%eax
  801a95:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a98:	83 c7 01             	add    $0x1,%edi
  801a9b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a9e:	75 c2                	jne    801a62 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801aa0:	8b 45 10             	mov    0x10(%ebp),%eax
  801aa3:	eb 05                	jmp    801aaa <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801aa5:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801aaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aad:	5b                   	pop    %ebx
  801aae:	5e                   	pop    %esi
  801aaf:	5f                   	pop    %edi
  801ab0:	5d                   	pop    %ebp
  801ab1:	c3                   	ret    

00801ab2 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	57                   	push   %edi
  801ab6:	56                   	push   %esi
  801ab7:	53                   	push   %ebx
  801ab8:	83 ec 18             	sub    $0x18,%esp
  801abb:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801abe:	57                   	push   %edi
  801abf:	e8 83 f5 ff ff       	call   801047 <fd2data>
  801ac4:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ace:	eb 3d                	jmp    801b0d <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801ad0:	85 db                	test   %ebx,%ebx
  801ad2:	74 04                	je     801ad8 <devpipe_read+0x26>
				return i;
  801ad4:	89 d8                	mov    %ebx,%eax
  801ad6:	eb 44                	jmp    801b1c <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801ad8:	89 f2                	mov    %esi,%edx
  801ada:	89 f8                	mov    %edi,%eax
  801adc:	e8 f2 fe ff ff       	call   8019d3 <_pipeisclosed>
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	75 32                	jne    801b17 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ae5:	e8 1e f3 ff ff       	call   800e08 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801aea:	8b 06                	mov    (%esi),%eax
  801aec:	3b 46 04             	cmp    0x4(%esi),%eax
  801aef:	74 df                	je     801ad0 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801af1:	99                   	cltd   
  801af2:	c1 ea 1b             	shr    $0x1b,%edx
  801af5:	01 d0                	add    %edx,%eax
  801af7:	83 e0 1f             	and    $0x1f,%eax
  801afa:	29 d0                	sub    %edx,%eax
  801afc:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b04:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801b07:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b0a:	83 c3 01             	add    $0x1,%ebx
  801b0d:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801b10:	75 d8                	jne    801aea <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801b12:	8b 45 10             	mov    0x10(%ebp),%eax
  801b15:	eb 05                	jmp    801b1c <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b17:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1f:	5b                   	pop    %ebx
  801b20:	5e                   	pop    %esi
  801b21:	5f                   	pop    %edi
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    

00801b24 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801b2c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b2f:	50                   	push   %eax
  801b30:	e8 29 f5 ff ff       	call   80105e <fd_alloc>
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	89 c2                	mov    %eax,%edx
  801b3a:	85 c0                	test   %eax,%eax
  801b3c:	0f 88 2c 01 00 00    	js     801c6e <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b42:	83 ec 04             	sub    $0x4,%esp
  801b45:	68 07 04 00 00       	push   $0x407
  801b4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b4d:	6a 00                	push   $0x0
  801b4f:	e8 d3 f2 ff ff       	call   800e27 <sys_page_alloc>
  801b54:	83 c4 10             	add    $0x10,%esp
  801b57:	89 c2                	mov    %eax,%edx
  801b59:	85 c0                	test   %eax,%eax
  801b5b:	0f 88 0d 01 00 00    	js     801c6e <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b67:	50                   	push   %eax
  801b68:	e8 f1 f4 ff ff       	call   80105e <fd_alloc>
  801b6d:	89 c3                	mov    %eax,%ebx
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	0f 88 e2 00 00 00    	js     801c5c <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b7a:	83 ec 04             	sub    $0x4,%esp
  801b7d:	68 07 04 00 00       	push   $0x407
  801b82:	ff 75 f0             	pushl  -0x10(%ebp)
  801b85:	6a 00                	push   $0x0
  801b87:	e8 9b f2 ff ff       	call   800e27 <sys_page_alloc>
  801b8c:	89 c3                	mov    %eax,%ebx
  801b8e:	83 c4 10             	add    $0x10,%esp
  801b91:	85 c0                	test   %eax,%eax
  801b93:	0f 88 c3 00 00 00    	js     801c5c <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801b99:	83 ec 0c             	sub    $0xc,%esp
  801b9c:	ff 75 f4             	pushl  -0xc(%ebp)
  801b9f:	e8 a3 f4 ff ff       	call   801047 <fd2data>
  801ba4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba6:	83 c4 0c             	add    $0xc,%esp
  801ba9:	68 07 04 00 00       	push   $0x407
  801bae:	50                   	push   %eax
  801baf:	6a 00                	push   $0x0
  801bb1:	e8 71 f2 ff ff       	call   800e27 <sys_page_alloc>
  801bb6:	89 c3                	mov    %eax,%ebx
  801bb8:	83 c4 10             	add    $0x10,%esp
  801bbb:	85 c0                	test   %eax,%eax
  801bbd:	0f 88 89 00 00 00    	js     801c4c <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bc3:	83 ec 0c             	sub    $0xc,%esp
  801bc6:	ff 75 f0             	pushl  -0x10(%ebp)
  801bc9:	e8 79 f4 ff ff       	call   801047 <fd2data>
  801bce:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bd5:	50                   	push   %eax
  801bd6:	6a 00                	push   $0x0
  801bd8:	56                   	push   %esi
  801bd9:	6a 00                	push   $0x0
  801bdb:	e8 8a f2 ff ff       	call   800e6a <sys_page_map>
  801be0:	89 c3                	mov    %eax,%ebx
  801be2:	83 c4 20             	add    $0x20,%esp
  801be5:	85 c0                	test   %eax,%eax
  801be7:	78 55                	js     801c3e <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801be9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf2:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801bfe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c04:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c07:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801c09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c0c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801c13:	83 ec 0c             	sub    $0xc,%esp
  801c16:	ff 75 f4             	pushl  -0xc(%ebp)
  801c19:	e8 19 f4 ff ff       	call   801037 <fd2num>
  801c1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c21:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c23:	83 c4 04             	add    $0x4,%esp
  801c26:	ff 75 f0             	pushl  -0x10(%ebp)
  801c29:	e8 09 f4 ff ff       	call   801037 <fd2num>
  801c2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c31:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	ba 00 00 00 00       	mov    $0x0,%edx
  801c3c:	eb 30                	jmp    801c6e <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801c3e:	83 ec 08             	sub    $0x8,%esp
  801c41:	56                   	push   %esi
  801c42:	6a 00                	push   $0x0
  801c44:	e8 63 f2 ff ff       	call   800eac <sys_page_unmap>
  801c49:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801c4c:	83 ec 08             	sub    $0x8,%esp
  801c4f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c52:	6a 00                	push   $0x0
  801c54:	e8 53 f2 ff ff       	call   800eac <sys_page_unmap>
  801c59:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801c5c:	83 ec 08             	sub    $0x8,%esp
  801c5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c62:	6a 00                	push   $0x0
  801c64:	e8 43 f2 ff ff       	call   800eac <sys_page_unmap>
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801c6e:	89 d0                	mov    %edx,%eax
  801c70:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c73:	5b                   	pop    %ebx
  801c74:	5e                   	pop    %esi
  801c75:	5d                   	pop    %ebp
  801c76:	c3                   	ret    

00801c77 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c80:	50                   	push   %eax
  801c81:	ff 75 08             	pushl  0x8(%ebp)
  801c84:	e8 24 f4 ff ff       	call   8010ad <fd_lookup>
  801c89:	89 c2                	mov    %eax,%edx
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	85 d2                	test   %edx,%edx
  801c90:	78 18                	js     801caa <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801c92:	83 ec 0c             	sub    $0xc,%esp
  801c95:	ff 75 f4             	pushl  -0xc(%ebp)
  801c98:	e8 aa f3 ff ff       	call   801047 <fd2data>
	return _pipeisclosed(fd, p);
  801c9d:	89 c2                	mov    %eax,%edx
  801c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca2:	e8 2c fd ff ff       	call   8019d3 <_pipeisclosed>
  801ca7:	83 c4 10             	add    $0x10,%esp
}
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	56                   	push   %esi
  801cb0:	53                   	push   %ebx
  801cb1:	8b 75 08             	mov    0x8(%ebp),%esi
  801cb4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801cba:	85 f6                	test   %esi,%esi
  801cbc:	74 06                	je     801cc4 <ipc_recv+0x18>
  801cbe:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801cc4:	85 db                	test   %ebx,%ebx
  801cc6:	74 06                	je     801cce <ipc_recv+0x22>
  801cc8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801cce:	83 f8 01             	cmp    $0x1,%eax
  801cd1:	19 d2                	sbb    %edx,%edx
  801cd3:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801cd5:	83 ec 0c             	sub    $0xc,%esp
  801cd8:	50                   	push   %eax
  801cd9:	e8 f9 f2 ff ff       	call   800fd7 <sys_ipc_recv>
  801cde:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	85 d2                	test   %edx,%edx
  801ce5:	75 24                	jne    801d0b <ipc_recv+0x5f>
	if (from_env_store)
  801ce7:	85 f6                	test   %esi,%esi
  801ce9:	74 0a                	je     801cf5 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801ceb:	a1 04 44 80 00       	mov    0x804404,%eax
  801cf0:	8b 40 70             	mov    0x70(%eax),%eax
  801cf3:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801cf5:	85 db                	test   %ebx,%ebx
  801cf7:	74 0a                	je     801d03 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801cf9:	a1 04 44 80 00       	mov    0x804404,%eax
  801cfe:	8b 40 74             	mov    0x74(%eax),%eax
  801d01:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801d03:	a1 04 44 80 00       	mov    0x804404,%eax
  801d08:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801d0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5e                   	pop    %esi
  801d10:	5d                   	pop    %ebp
  801d11:	c3                   	ret    

00801d12 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	57                   	push   %edi
  801d16:	56                   	push   %esi
  801d17:	53                   	push   %ebx
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801d24:	83 fb 01             	cmp    $0x1,%ebx
  801d27:	19 c0                	sbb    %eax,%eax
  801d29:	09 c3                	or     %eax,%ebx
  801d2b:	eb 1c                	jmp    801d49 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801d2d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d30:	74 12                	je     801d44 <ipc_send+0x32>
  801d32:	50                   	push   %eax
  801d33:	68 dc 25 80 00       	push   $0x8025dc
  801d38:	6a 36                	push   $0x36
  801d3a:	68 f3 25 80 00       	push   $0x8025f3
  801d3f:	e8 89 e5 ff ff       	call   8002cd <_panic>
		sys_yield();
  801d44:	e8 bf f0 ff ff       	call   800e08 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801d49:	ff 75 14             	pushl  0x14(%ebp)
  801d4c:	53                   	push   %ebx
  801d4d:	56                   	push   %esi
  801d4e:	57                   	push   %edi
  801d4f:	e8 60 f2 ff ff       	call   800fb4 <sys_ipc_try_send>
		if (ret == 0) break;
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	85 c0                	test   %eax,%eax
  801d59:	75 d2                	jne    801d2d <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801d5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d5e:	5b                   	pop    %ebx
  801d5f:	5e                   	pop    %esi
  801d60:	5f                   	pop    %edi
  801d61:	5d                   	pop    %ebp
  801d62:	c3                   	ret    

00801d63 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
  801d66:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d69:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d6e:	6b d0 78             	imul   $0x78,%eax,%edx
  801d71:	83 c2 50             	add    $0x50,%edx
  801d74:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801d7a:	39 ca                	cmp    %ecx,%edx
  801d7c:	75 0d                	jne    801d8b <ipc_find_env+0x28>
			return envs[i].env_id;
  801d7e:	6b c0 78             	imul   $0x78,%eax,%eax
  801d81:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801d86:	8b 40 08             	mov    0x8(%eax),%eax
  801d89:	eb 0e                	jmp    801d99 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801d8b:	83 c0 01             	add    $0x1,%eax
  801d8e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d93:	75 d9                	jne    801d6e <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801d95:	66 b8 00 00          	mov    $0x0,%ax
}
  801d99:	5d                   	pop    %ebp
  801d9a:	c3                   	ret    

00801d9b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801da1:	89 d0                	mov    %edx,%eax
  801da3:	c1 e8 16             	shr    $0x16,%eax
  801da6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801dad:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801db2:	f6 c1 01             	test   $0x1,%cl
  801db5:	74 1d                	je     801dd4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801db7:	c1 ea 0c             	shr    $0xc,%edx
  801dba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801dc1:	f6 c2 01             	test   $0x1,%dl
  801dc4:	74 0e                	je     801dd4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801dc6:	c1 ea 0c             	shr    $0xc,%edx
  801dc9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801dd0:	ef 
  801dd1:	0f b7 c0             	movzwl %ax,%eax
}
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
  801dd6:	66 90                	xchg   %ax,%ax
  801dd8:	66 90                	xchg   %ax,%ax
  801dda:	66 90                	xchg   %ax,%ax
  801ddc:	66 90                	xchg   %ax,%ax
  801dde:	66 90                	xchg   %ax,%ax

00801de0 <__udivdi3>:
  801de0:	55                   	push   %ebp
  801de1:	57                   	push   %edi
  801de2:	56                   	push   %esi
  801de3:	83 ec 10             	sub    $0x10,%esp
  801de6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801dea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801dee:	8b 74 24 24          	mov    0x24(%esp),%esi
  801df2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801df6:	85 d2                	test   %edx,%edx
  801df8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801dfc:	89 34 24             	mov    %esi,(%esp)
  801dff:	89 c8                	mov    %ecx,%eax
  801e01:	75 35                	jne    801e38 <__udivdi3+0x58>
  801e03:	39 f1                	cmp    %esi,%ecx
  801e05:	0f 87 bd 00 00 00    	ja     801ec8 <__udivdi3+0xe8>
  801e0b:	85 c9                	test   %ecx,%ecx
  801e0d:	89 cd                	mov    %ecx,%ebp
  801e0f:	75 0b                	jne    801e1c <__udivdi3+0x3c>
  801e11:	b8 01 00 00 00       	mov    $0x1,%eax
  801e16:	31 d2                	xor    %edx,%edx
  801e18:	f7 f1                	div    %ecx
  801e1a:	89 c5                	mov    %eax,%ebp
  801e1c:	89 f0                	mov    %esi,%eax
  801e1e:	31 d2                	xor    %edx,%edx
  801e20:	f7 f5                	div    %ebp
  801e22:	89 c6                	mov    %eax,%esi
  801e24:	89 f8                	mov    %edi,%eax
  801e26:	f7 f5                	div    %ebp
  801e28:	89 f2                	mov    %esi,%edx
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	5e                   	pop    %esi
  801e2e:	5f                   	pop    %edi
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    
  801e31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e38:	3b 14 24             	cmp    (%esp),%edx
  801e3b:	77 7b                	ja     801eb8 <__udivdi3+0xd8>
  801e3d:	0f bd f2             	bsr    %edx,%esi
  801e40:	83 f6 1f             	xor    $0x1f,%esi
  801e43:	0f 84 97 00 00 00    	je     801ee0 <__udivdi3+0x100>
  801e49:	bd 20 00 00 00       	mov    $0x20,%ebp
  801e4e:	89 d7                	mov    %edx,%edi
  801e50:	89 f1                	mov    %esi,%ecx
  801e52:	29 f5                	sub    %esi,%ebp
  801e54:	d3 e7                	shl    %cl,%edi
  801e56:	89 c2                	mov    %eax,%edx
  801e58:	89 e9                	mov    %ebp,%ecx
  801e5a:	d3 ea                	shr    %cl,%edx
  801e5c:	89 f1                	mov    %esi,%ecx
  801e5e:	09 fa                	or     %edi,%edx
  801e60:	8b 3c 24             	mov    (%esp),%edi
  801e63:	d3 e0                	shl    %cl,%eax
  801e65:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e73:	89 fa                	mov    %edi,%edx
  801e75:	d3 ea                	shr    %cl,%edx
  801e77:	89 f1                	mov    %esi,%ecx
  801e79:	d3 e7                	shl    %cl,%edi
  801e7b:	89 e9                	mov    %ebp,%ecx
  801e7d:	d3 e8                	shr    %cl,%eax
  801e7f:	09 c7                	or     %eax,%edi
  801e81:	89 f8                	mov    %edi,%eax
  801e83:	f7 74 24 08          	divl   0x8(%esp)
  801e87:	89 d5                	mov    %edx,%ebp
  801e89:	89 c7                	mov    %eax,%edi
  801e8b:	f7 64 24 0c          	mull   0xc(%esp)
  801e8f:	39 d5                	cmp    %edx,%ebp
  801e91:	89 14 24             	mov    %edx,(%esp)
  801e94:	72 11                	jb     801ea7 <__udivdi3+0xc7>
  801e96:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e9a:	89 f1                	mov    %esi,%ecx
  801e9c:	d3 e2                	shl    %cl,%edx
  801e9e:	39 c2                	cmp    %eax,%edx
  801ea0:	73 5e                	jae    801f00 <__udivdi3+0x120>
  801ea2:	3b 2c 24             	cmp    (%esp),%ebp
  801ea5:	75 59                	jne    801f00 <__udivdi3+0x120>
  801ea7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801eaa:	31 f6                	xor    %esi,%esi
  801eac:	89 f2                	mov    %esi,%edx
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	5e                   	pop    %esi
  801eb2:	5f                   	pop    %edi
  801eb3:	5d                   	pop    %ebp
  801eb4:	c3                   	ret    
  801eb5:	8d 76 00             	lea    0x0(%esi),%esi
  801eb8:	31 f6                	xor    %esi,%esi
  801eba:	31 c0                	xor    %eax,%eax
  801ebc:	89 f2                	mov    %esi,%edx
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    
  801ec5:	8d 76 00             	lea    0x0(%esi),%esi
  801ec8:	89 f2                	mov    %esi,%edx
  801eca:	31 f6                	xor    %esi,%esi
  801ecc:	89 f8                	mov    %edi,%eax
  801ece:	f7 f1                	div    %ecx
  801ed0:	89 f2                	mov    %esi,%edx
  801ed2:	83 c4 10             	add    $0x10,%esp
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    
  801ed9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ee0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ee4:	76 0b                	jbe    801ef1 <__udivdi3+0x111>
  801ee6:	31 c0                	xor    %eax,%eax
  801ee8:	3b 14 24             	cmp    (%esp),%edx
  801eeb:	0f 83 37 ff ff ff    	jae    801e28 <__udivdi3+0x48>
  801ef1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ef6:	e9 2d ff ff ff       	jmp    801e28 <__udivdi3+0x48>
  801efb:	90                   	nop
  801efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f00:	89 f8                	mov    %edi,%eax
  801f02:	31 f6                	xor    %esi,%esi
  801f04:	e9 1f ff ff ff       	jmp    801e28 <__udivdi3+0x48>
  801f09:	66 90                	xchg   %ax,%ax
  801f0b:	66 90                	xchg   %ax,%ax
  801f0d:	66 90                	xchg   %ax,%ax
  801f0f:	90                   	nop

00801f10 <__umoddi3>:
  801f10:	55                   	push   %ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	83 ec 20             	sub    $0x20,%esp
  801f16:	8b 44 24 34          	mov    0x34(%esp),%eax
  801f1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f22:	89 c6                	mov    %eax,%esi
  801f24:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801f2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801f30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f38:	89 74 24 18          	mov    %esi,0x18(%esp)
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	89 c2                	mov    %eax,%edx
  801f40:	75 1e                	jne    801f60 <__umoddi3+0x50>
  801f42:	39 f7                	cmp    %esi,%edi
  801f44:	76 52                	jbe    801f98 <__umoddi3+0x88>
  801f46:	89 c8                	mov    %ecx,%eax
  801f48:	89 f2                	mov    %esi,%edx
  801f4a:	f7 f7                	div    %edi
  801f4c:	89 d0                	mov    %edx,%eax
  801f4e:	31 d2                	xor    %edx,%edx
  801f50:	83 c4 20             	add    $0x20,%esp
  801f53:	5e                   	pop    %esi
  801f54:	5f                   	pop    %edi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    
  801f57:	89 f6                	mov    %esi,%esi
  801f59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801f60:	39 f0                	cmp    %esi,%eax
  801f62:	77 5c                	ja     801fc0 <__umoddi3+0xb0>
  801f64:	0f bd e8             	bsr    %eax,%ebp
  801f67:	83 f5 1f             	xor    $0x1f,%ebp
  801f6a:	75 64                	jne    801fd0 <__umoddi3+0xc0>
  801f6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801f70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801f74:	0f 86 f6 00 00 00    	jbe    802070 <__umoddi3+0x160>
  801f7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801f7e:	0f 82 ec 00 00 00    	jb     802070 <__umoddi3+0x160>
  801f84:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f88:	8b 54 24 18          	mov    0x18(%esp),%edx
  801f8c:	83 c4 20             	add    $0x20,%esp
  801f8f:	5e                   	pop    %esi
  801f90:	5f                   	pop    %edi
  801f91:	5d                   	pop    %ebp
  801f92:	c3                   	ret    
  801f93:	90                   	nop
  801f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f98:	85 ff                	test   %edi,%edi
  801f9a:	89 fd                	mov    %edi,%ebp
  801f9c:	75 0b                	jne    801fa9 <__umoddi3+0x99>
  801f9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801fa3:	31 d2                	xor    %edx,%edx
  801fa5:	f7 f7                	div    %edi
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801fad:	31 d2                	xor    %edx,%edx
  801faf:	f7 f5                	div    %ebp
  801fb1:	89 c8                	mov    %ecx,%eax
  801fb3:	f7 f5                	div    %ebp
  801fb5:	eb 95                	jmp    801f4c <__umoddi3+0x3c>
  801fb7:	89 f6                	mov    %esi,%esi
  801fb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801fc0:	89 c8                	mov    %ecx,%eax
  801fc2:	89 f2                	mov    %esi,%edx
  801fc4:	83 c4 20             	add    $0x20,%esp
  801fc7:	5e                   	pop    %esi
  801fc8:	5f                   	pop    %edi
  801fc9:	5d                   	pop    %ebp
  801fca:	c3                   	ret    
  801fcb:	90                   	nop
  801fcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd0:	b8 20 00 00 00       	mov    $0x20,%eax
  801fd5:	89 e9                	mov    %ebp,%ecx
  801fd7:	29 e8                	sub    %ebp,%eax
  801fd9:	d3 e2                	shl    %cl,%edx
  801fdb:	89 c7                	mov    %eax,%edi
  801fdd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801fe1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e8                	shr    %cl,%eax
  801fe9:	89 c1                	mov    %eax,%ecx
  801feb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801fef:	09 d1                	or     %edx,%ecx
  801ff1:	89 fa                	mov    %edi,%edx
  801ff3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ff7:	89 e9                	mov    %ebp,%ecx
  801ff9:	d3 e0                	shl    %cl,%eax
  801ffb:	89 f9                	mov    %edi,%ecx
  801ffd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802001:	89 f0                	mov    %esi,%eax
  802003:	d3 e8                	shr    %cl,%eax
  802005:	89 e9                	mov    %ebp,%ecx
  802007:	89 c7                	mov    %eax,%edi
  802009:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80200d:	d3 e6                	shl    %cl,%esi
  80200f:	89 d1                	mov    %edx,%ecx
  802011:	89 fa                	mov    %edi,%edx
  802013:	d3 e8                	shr    %cl,%eax
  802015:	89 e9                	mov    %ebp,%ecx
  802017:	09 f0                	or     %esi,%eax
  802019:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80201d:	f7 74 24 10          	divl   0x10(%esp)
  802021:	d3 e6                	shl    %cl,%esi
  802023:	89 d1                	mov    %edx,%ecx
  802025:	f7 64 24 0c          	mull   0xc(%esp)
  802029:	39 d1                	cmp    %edx,%ecx
  80202b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80202f:	89 d7                	mov    %edx,%edi
  802031:	89 c6                	mov    %eax,%esi
  802033:	72 0a                	jb     80203f <__umoddi3+0x12f>
  802035:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802039:	73 10                	jae    80204b <__umoddi3+0x13b>
  80203b:	39 d1                	cmp    %edx,%ecx
  80203d:	75 0c                	jne    80204b <__umoddi3+0x13b>
  80203f:	89 d7                	mov    %edx,%edi
  802041:	89 c6                	mov    %eax,%esi
  802043:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802047:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80204b:	89 ca                	mov    %ecx,%edx
  80204d:	89 e9                	mov    %ebp,%ecx
  80204f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802053:	29 f0                	sub    %esi,%eax
  802055:	19 fa                	sbb    %edi,%edx
  802057:	d3 e8                	shr    %cl,%eax
  802059:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80205e:	89 d7                	mov    %edx,%edi
  802060:	d3 e7                	shl    %cl,%edi
  802062:	89 e9                	mov    %ebp,%ecx
  802064:	09 f8                	or     %edi,%eax
  802066:	d3 ea                	shr    %cl,%edx
  802068:	83 c4 20             	add    $0x20,%esp
  80206b:	5e                   	pop    %esi
  80206c:	5f                   	pop    %edi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    
  80206f:	90                   	nop
  802070:	8b 74 24 10          	mov    0x10(%esp),%esi
  802074:	29 f9                	sub    %edi,%ecx
  802076:	19 c6                	sbb    %eax,%esi
  802078:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80207c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802080:	e9 ff fe ff ff       	jmp    801f84 <__umoddi3+0x74>
