
obj/user/dumbfork:     file format elf32-i386


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
  80002c:	e8 a2 01 00 00       	call   8001d3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 50 0c 00 00       	call   800c9a <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	79 12                	jns    800063 <duppage+0x30>
		panic("sys_page_alloc: %i", r);
  800051:	50                   	push   %eax
  800052:	68 80 1f 80 00       	push   $0x801f80
  800057:	6a 20                	push   $0x20
  800059:	68 93 1f 80 00       	push   $0x801f93
  80005e:	e8 d0 01 00 00       	call   800233 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800063:	83 ec 0c             	sub    $0xc,%esp
  800066:	6a 07                	push   $0x7
  800068:	68 00 00 40 00       	push   $0x400000
  80006d:	6a 00                	push   $0x0
  80006f:	53                   	push   %ebx
  800070:	56                   	push   %esi
  800071:	e8 67 0c 00 00       	call   800cdd <sys_page_map>
  800076:	83 c4 20             	add    $0x20,%esp
  800079:	85 c0                	test   %eax,%eax
  80007b:	79 12                	jns    80008f <duppage+0x5c>
		panic("sys_page_map: %i", r);
  80007d:	50                   	push   %eax
  80007e:	68 a3 1f 80 00       	push   $0x801fa3
  800083:	6a 22                	push   $0x22
  800085:	68 93 1f 80 00       	push   $0x801f93
  80008a:	e8 a4 01 00 00       	call   800233 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  80008f:	83 ec 04             	sub    $0x4,%esp
  800092:	68 00 10 00 00       	push   $0x1000
  800097:	53                   	push   %ebx
  800098:	68 00 00 40 00       	push   $0x400000
  80009d:	e8 80 09 00 00       	call   800a22 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000a2:	83 c4 08             	add    $0x8,%esp
  8000a5:	68 00 00 40 00       	push   $0x400000
  8000aa:	6a 00                	push   $0x0
  8000ac:	e8 6e 0c 00 00       	call   800d1f <sys_page_unmap>
  8000b1:	83 c4 10             	add    $0x10,%esp
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	79 12                	jns    8000ca <duppage+0x97>
		panic("sys_page_unmap: %i", r);
  8000b8:	50                   	push   %eax
  8000b9:	68 b4 1f 80 00       	push   $0x801fb4
  8000be:	6a 25                	push   $0x25
  8000c0:	68 93 1f 80 00       	push   $0x801f93
  8000c5:	e8 69 01 00 00       	call   800233 <_panic>
}
  8000ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5d                   	pop    %ebp
  8000d0:	c3                   	ret    

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	56                   	push   %esi
  8000d5:	53                   	push   %ebx
  8000d6:	83 ec 10             	sub    $0x10,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  8000d9:	b8 07 00 00 00       	mov    $0x7,%eax
  8000de:	cd 30                	int    $0x30
  8000e0:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e2:	85 c0                	test   %eax,%eax
  8000e4:	79 12                	jns    8000f8 <dumbfork+0x27>
		panic("sys_exofork: %i", envid);
  8000e6:	50                   	push   %eax
  8000e7:	68 c7 1f 80 00       	push   $0x801fc7
  8000ec:	6a 37                	push   $0x37
  8000ee:	68 93 1f 80 00       	push   $0x801f93
  8000f3:	e8 3b 01 00 00       	call   800233 <_panic>
  8000f8:	89 c6                	mov    %eax,%esi
	if (envid == 0) {
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	75 1e                	jne    80011c <dumbfork+0x4b>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000fe:	e8 59 0b 00 00       	call   800c5c <sys_getenvid>
  800103:	25 ff 03 00 00       	and    $0x3ff,%eax
  800108:	6b c0 78             	imul   $0x78,%eax,%eax
  80010b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800110:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800115:	b8 00 00 00 00       	mov    $0x0,%eax
  80011a:	eb 60                	jmp    80017c <dumbfork+0xab>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80011c:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800123:	eb 14                	jmp    800139 <dumbfork+0x68>
		duppage(envid, addr);
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	52                   	push   %edx
  800129:	56                   	push   %esi
  80012a:	e8 04 ff ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80012f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  800136:	83 c4 10             	add    $0x10,%esp
  800139:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80013c:	81 fa 00 60 80 00    	cmp    $0x806000,%edx
  800142:	72 e1                	jb     800125 <dumbfork+0x54>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800144:	83 ec 08             	sub    $0x8,%esp
  800147:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80014a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80014f:	50                   	push   %eax
  800150:	53                   	push   %ebx
  800151:	e8 dd fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	6a 02                	push   $0x2
  80015b:	53                   	push   %ebx
  80015c:	e8 00 0c 00 00       	call   800d61 <sys_env_set_status>
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	85 c0                	test   %eax,%eax
  800166:	79 12                	jns    80017a <dumbfork+0xa9>
		panic("sys_env_set_status: %i", r);
  800168:	50                   	push   %eax
  800169:	68 d7 1f 80 00       	push   $0x801fd7
  80016e:	6a 4c                	push   $0x4c
  800170:	68 93 1f 80 00       	push   $0x801f93
  800175:	e8 b9 00 00 00       	call   800233 <_panic>

	return envid;
  80017a:	89 d8                	mov    %ebx,%eax
}
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	56                   	push   %esi
  800187:	53                   	push   %ebx
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  800188:	e8 44 ff ff ff       	call   8000d1 <dumbfork>
  80018d:	89 c6                	mov    %eax,%esi

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80018f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800194:	eb 26                	jmp    8001bc <umain+0x39>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800196:	ba f4 1f 80 00       	mov    $0x801ff4,%edx
  80019b:	eb 05                	jmp    8001a2 <umain+0x1f>
  80019d:	ba ee 1f 80 00       	mov    $0x801fee,%edx
  8001a2:	83 ec 04             	sub    $0x4,%esp
  8001a5:	52                   	push   %edx
  8001a6:	53                   	push   %ebx
  8001a7:	68 fb 1f 80 00       	push   $0x801ffb
  8001ac:	e8 5b 01 00 00       	call   80030c <cprintf>
		sys_yield();
  8001b1:	e8 c5 0a 00 00       	call   800c7b <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001b6:	83 c3 01             	add    $0x1,%ebx
  8001b9:	83 c4 10             	add    $0x10,%esp
  8001bc:	85 f6                	test   %esi,%esi
  8001be:	74 07                	je     8001c7 <umain+0x44>
  8001c0:	83 fb 09             	cmp    $0x9,%ebx
  8001c3:	7e d1                	jle    800196 <umain+0x13>
  8001c5:	eb 05                	jmp    8001cc <umain+0x49>
  8001c7:	83 fb 13             	cmp    $0x13,%ebx
  8001ca:	7e d1                	jle    80019d <umain+0x1a>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  8001cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5d                   	pop    %ebp
  8001d2:	c3                   	ret    

008001d3 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	56                   	push   %esi
  8001d7:	53                   	push   %ebx
  8001d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001db:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8001de:	e8 79 0a 00 00       	call   800c5c <sys_getenvid>
  8001e3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e8:	6b c0 78             	imul   $0x78,%eax,%eax
  8001eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001f0:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f5:	85 db                	test   %ebx,%ebx
  8001f7:	7e 07                	jle    800200 <libmain+0x2d>
		binaryname = argv[0];
  8001f9:	8b 06                	mov    (%esi),%eax
  8001fb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800200:	83 ec 08             	sub    $0x8,%esp
  800203:	56                   	push   %esi
  800204:	53                   	push   %ebx
  800205:	e8 79 ff ff ff       	call   800183 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80020a:	e8 0a 00 00 00       	call   800219 <exit>
  80020f:	83 c4 10             	add    $0x10,%esp
#endif
}
  800212:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021f:	e8 52 0e 00 00       	call   801076 <close_all>
	sys_env_destroy(0);
  800224:	83 ec 0c             	sub    $0xc,%esp
  800227:	6a 00                	push   $0x0
  800229:	e8 ed 09 00 00       	call   800c1b <sys_env_destroy>
  80022e:	83 c4 10             	add    $0x10,%esp
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800238:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80023b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800241:	e8 16 0a 00 00       	call   800c5c <sys_getenvid>
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	ff 75 0c             	pushl  0xc(%ebp)
  80024c:	ff 75 08             	pushl  0x8(%ebp)
  80024f:	56                   	push   %esi
  800250:	50                   	push   %eax
  800251:	68 18 20 80 00       	push   $0x802018
  800256:	e8 b1 00 00 00       	call   80030c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80025b:	83 c4 18             	add    $0x18,%esp
  80025e:	53                   	push   %ebx
  80025f:	ff 75 10             	pushl  0x10(%ebp)
  800262:	e8 54 00 00 00       	call   8002bb <vcprintf>
	cprintf("\n");
  800267:	c7 04 24 0b 20 80 00 	movl   $0x80200b,(%esp)
  80026e:	e8 99 00 00 00       	call   80030c <cprintf>
  800273:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800276:	cc                   	int3   
  800277:	eb fd                	jmp    800276 <_panic+0x43>

00800279 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	53                   	push   %ebx
  80027d:	83 ec 04             	sub    $0x4,%esp
  800280:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800283:	8b 13                	mov    (%ebx),%edx
  800285:	8d 42 01             	lea    0x1(%edx),%eax
  800288:	89 03                	mov    %eax,(%ebx)
  80028a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800291:	3d ff 00 00 00       	cmp    $0xff,%eax
  800296:	75 1a                	jne    8002b2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800298:	83 ec 08             	sub    $0x8,%esp
  80029b:	68 ff 00 00 00       	push   $0xff
  8002a0:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a3:	50                   	push   %eax
  8002a4:	e8 35 09 00 00       	call   800bde <sys_cputs>
		b->idx = 0;
  8002a9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002af:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8002b2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002b9:	c9                   	leave  
  8002ba:	c3                   	ret    

008002bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cb:	00 00 00 
	b.cnt = 0;
  8002ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d8:	ff 75 0c             	pushl  0xc(%ebp)
  8002db:	ff 75 08             	pushl  0x8(%ebp)
  8002de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e4:	50                   	push   %eax
  8002e5:	68 79 02 80 00       	push   $0x800279
  8002ea:	e8 4f 01 00 00       	call   80043e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ef:	83 c4 08             	add    $0x8,%esp
  8002f2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fe:	50                   	push   %eax
  8002ff:	e8 da 08 00 00       	call   800bde <sys_cputs>

	return b.cnt;
}
  800304:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800312:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800315:	50                   	push   %eax
  800316:	ff 75 08             	pushl  0x8(%ebp)
  800319:	e8 9d ff ff ff       	call   8002bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 1c             	sub    $0x1c,%esp
  800329:	89 c7                	mov    %eax,%edi
  80032b:	89 d6                	mov    %edx,%esi
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	8b 55 0c             	mov    0xc(%ebp),%edx
  800333:	89 d1                	mov    %edx,%ecx
  800335:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800338:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80033b:	8b 45 10             	mov    0x10(%ebp),%eax
  80033e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800341:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800344:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80034e:	72 05                	jb     800355 <printnum+0x35>
  800350:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800353:	77 3e                	ja     800393 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800355:	83 ec 0c             	sub    $0xc,%esp
  800358:	ff 75 18             	pushl  0x18(%ebp)
  80035b:	83 eb 01             	sub    $0x1,%ebx
  80035e:	53                   	push   %ebx
  80035f:	50                   	push   %eax
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	ff 75 e4             	pushl  -0x1c(%ebp)
  800366:	ff 75 e0             	pushl  -0x20(%ebp)
  800369:	ff 75 dc             	pushl  -0x24(%ebp)
  80036c:	ff 75 d8             	pushl  -0x28(%ebp)
  80036f:	e8 4c 19 00 00       	call   801cc0 <__udivdi3>
  800374:	83 c4 18             	add    $0x18,%esp
  800377:	52                   	push   %edx
  800378:	50                   	push   %eax
  800379:	89 f2                	mov    %esi,%edx
  80037b:	89 f8                	mov    %edi,%eax
  80037d:	e8 9e ff ff ff       	call   800320 <printnum>
  800382:	83 c4 20             	add    $0x20,%esp
  800385:	eb 13                	jmp    80039a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800387:	83 ec 08             	sub    $0x8,%esp
  80038a:	56                   	push   %esi
  80038b:	ff 75 18             	pushl  0x18(%ebp)
  80038e:	ff d7                	call   *%edi
  800390:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800393:	83 eb 01             	sub    $0x1,%ebx
  800396:	85 db                	test   %ebx,%ebx
  800398:	7f ed                	jg     800387 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80039a:	83 ec 08             	sub    $0x8,%esp
  80039d:	56                   	push   %esi
  80039e:	83 ec 04             	sub    $0x4,%esp
  8003a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8003a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8003aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8003ad:	e8 3e 1a 00 00       	call   801df0 <__umoddi3>
  8003b2:	83 c4 14             	add    $0x14,%esp
  8003b5:	0f be 80 3b 20 80 00 	movsbl 0x80203b(%eax),%eax
  8003bc:	50                   	push   %eax
  8003bd:	ff d7                	call   *%edi
  8003bf:	83 c4 10             	add    $0x10,%esp
}
  8003c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c5:	5b                   	pop    %ebx
  8003c6:	5e                   	pop    %esi
  8003c7:	5f                   	pop    %edi
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003cd:	83 fa 01             	cmp    $0x1,%edx
  8003d0:	7e 0e                	jle    8003e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003d2:	8b 10                	mov    (%eax),%edx
  8003d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d7:	89 08                	mov    %ecx,(%eax)
  8003d9:	8b 02                	mov    (%edx),%eax
  8003db:	8b 52 04             	mov    0x4(%edx),%edx
  8003de:	eb 22                	jmp    800402 <getuint+0x38>
	else if (lflag)
  8003e0:	85 d2                	test   %edx,%edx
  8003e2:	74 10                	je     8003f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e4:	8b 10                	mov    (%eax),%edx
  8003e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e9:	89 08                	mov    %ecx,(%eax)
  8003eb:	8b 02                	mov    (%edx),%eax
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f2:	eb 0e                	jmp    800402 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f4:	8b 10                	mov    (%eax),%edx
  8003f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f9:	89 08                	mov    %ecx,(%eax)
  8003fb:	8b 02                	mov    (%edx),%eax
  8003fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800402:	5d                   	pop    %ebp
  800403:	c3                   	ret    

00800404 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800404:	55                   	push   %ebp
  800405:	89 e5                	mov    %esp,%ebp
  800407:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80040a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040e:	8b 10                	mov    (%eax),%edx
  800410:	3b 50 04             	cmp    0x4(%eax),%edx
  800413:	73 0a                	jae    80041f <sprintputch+0x1b>
		*b->buf++ = ch;
  800415:	8d 4a 01             	lea    0x1(%edx),%ecx
  800418:	89 08                	mov    %ecx,(%eax)
  80041a:	8b 45 08             	mov    0x8(%ebp),%eax
  80041d:	88 02                	mov    %al,(%edx)
}
  80041f:	5d                   	pop    %ebp
  800420:	c3                   	ret    

00800421 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800427:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80042a:	50                   	push   %eax
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	ff 75 0c             	pushl  0xc(%ebp)
  800431:	ff 75 08             	pushl  0x8(%ebp)
  800434:	e8 05 00 00 00       	call   80043e <vprintfmt>
	va_end(ap);
  800439:	83 c4 10             	add    $0x10,%esp
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	57                   	push   %edi
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
  800444:	83 ec 2c             	sub    $0x2c,%esp
  800447:	8b 75 08             	mov    0x8(%ebp),%esi
  80044a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80044d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800450:	eb 12                	jmp    800464 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800452:	85 c0                	test   %eax,%eax
  800454:	0f 84 8d 03 00 00    	je     8007e7 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	50                   	push   %eax
  80045f:	ff d6                	call   *%esi
  800461:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800464:	83 c7 01             	add    $0x1,%edi
  800467:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80046b:	83 f8 25             	cmp    $0x25,%eax
  80046e:	75 e2                	jne    800452 <vprintfmt+0x14>
  800470:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800474:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80047b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800482:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800489:	ba 00 00 00 00       	mov    $0x0,%edx
  80048e:	eb 07                	jmp    800497 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800490:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800493:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8d 47 01             	lea    0x1(%edi),%eax
  80049a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049d:	0f b6 07             	movzbl (%edi),%eax
  8004a0:	0f b6 c8             	movzbl %al,%ecx
  8004a3:	83 e8 23             	sub    $0x23,%eax
  8004a6:	3c 55                	cmp    $0x55,%al
  8004a8:	0f 87 1e 03 00 00    	ja     8007cc <vprintfmt+0x38e>
  8004ae:	0f b6 c0             	movzbl %al,%eax
  8004b1:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8004bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8004bf:	eb d6                	jmp    800497 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004cf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8004d3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8004d6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8004d9:	83 fa 09             	cmp    $0x9,%edx
  8004dc:	77 38                	ja     800516 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8004e1:	eb e9                	jmp    8004cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8004e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8004f4:	eb 26                	jmp    80051c <vprintfmt+0xde>
  8004f6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f9:	89 c8                	mov    %ecx,%eax
  8004fb:	c1 f8 1f             	sar    $0x1f,%eax
  8004fe:	f7 d0                	not    %eax
  800500:	21 c1                	and    %eax,%ecx
  800502:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800505:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800508:	eb 8d                	jmp    800497 <vprintfmt+0x59>
  80050a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80050d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800514:	eb 81                	jmp    800497 <vprintfmt+0x59>
  800516:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800519:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80051c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800520:	0f 89 71 ff ff ff    	jns    800497 <vprintfmt+0x59>
				width = precision, precision = -1;
  800526:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800529:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800533:	e9 5f ff ff ff       	jmp    800497 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800538:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80053e:	e9 54 ff ff ff       	jmp    800497 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 50 04             	lea    0x4(%eax),%edx
  800549:	89 55 14             	mov    %edx,0x14(%ebp)
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	53                   	push   %ebx
  800550:	ff 30                	pushl  (%eax)
  800552:	ff d6                	call   *%esi
			break;
  800554:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80055a:	e9 05 ff ff ff       	jmp    800464 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 50 04             	lea    0x4(%eax),%edx
  800565:	89 55 14             	mov    %edx,0x14(%ebp)
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	99                   	cltd   
  80056b:	31 d0                	xor    %edx,%eax
  80056d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056f:	83 f8 0f             	cmp    $0xf,%eax
  800572:	7f 0b                	jg     80057f <vprintfmt+0x141>
  800574:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  80057b:	85 d2                	test   %edx,%edx
  80057d:	75 18                	jne    800597 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80057f:	50                   	push   %eax
  800580:	68 53 20 80 00       	push   $0x802053
  800585:	53                   	push   %ebx
  800586:	56                   	push   %esi
  800587:	e8 95 fe ff ff       	call   800421 <printfmt>
  80058c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800592:	e9 cd fe ff ff       	jmp    800464 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800597:	52                   	push   %edx
  800598:	68 31 24 80 00       	push   $0x802431
  80059d:	53                   	push   %ebx
  80059e:	56                   	push   %esi
  80059f:	e8 7d fe ff ff       	call   800421 <printfmt>
  8005a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005aa:	e9 b5 fe ff ff       	jmp    800464 <vprintfmt+0x26>
  8005af:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005b2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 50 04             	lea    0x4(%eax),%edx
  8005be:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c1:	8b 38                	mov    (%eax),%edi
  8005c3:	85 ff                	test   %edi,%edi
  8005c5:	75 05                	jne    8005cc <vprintfmt+0x18e>
				p = "(null)";
  8005c7:	bf 4c 20 80 00       	mov    $0x80204c,%edi
			if (width > 0 && padc != '-')
  8005cc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8005d0:	0f 84 91 00 00 00    	je     800667 <vprintfmt+0x229>
  8005d6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8005da:	0f 8e 95 00 00 00    	jle    800675 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005e0:	83 ec 08             	sub    $0x8,%esp
  8005e3:	51                   	push   %ecx
  8005e4:	57                   	push   %edi
  8005e5:	e8 85 02 00 00       	call   80086f <strnlen>
  8005ea:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005ed:	29 c1                	sub    %eax,%ecx
  8005ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005f2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005f5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8005f9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005fc:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ff:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	eb 0f                	jmp    800612 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800603:	83 ec 08             	sub    $0x8,%esp
  800606:	53                   	push   %ebx
  800607:	ff 75 e0             	pushl  -0x20(%ebp)
  80060a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060c:	83 ef 01             	sub    $0x1,%edi
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	85 ff                	test   %edi,%edi
  800614:	7f ed                	jg     800603 <vprintfmt+0x1c5>
  800616:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800619:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80061c:	89 c8                	mov    %ecx,%eax
  80061e:	c1 f8 1f             	sar    $0x1f,%eax
  800621:	f7 d0                	not    %eax
  800623:	21 c8                	and    %ecx,%eax
  800625:	29 c1                	sub    %eax,%ecx
  800627:	89 75 08             	mov    %esi,0x8(%ebp)
  80062a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80062d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800630:	89 cb                	mov    %ecx,%ebx
  800632:	eb 4d                	jmp    800681 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800634:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800638:	74 1b                	je     800655 <vprintfmt+0x217>
  80063a:	0f be c0             	movsbl %al,%eax
  80063d:	83 e8 20             	sub    $0x20,%eax
  800640:	83 f8 5e             	cmp    $0x5e,%eax
  800643:	76 10                	jbe    800655 <vprintfmt+0x217>
					putch('?', putdat);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	ff 75 0c             	pushl  0xc(%ebp)
  80064b:	6a 3f                	push   $0x3f
  80064d:	ff 55 08             	call   *0x8(%ebp)
  800650:	83 c4 10             	add    $0x10,%esp
  800653:	eb 0d                	jmp    800662 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	52                   	push   %edx
  80065c:	ff 55 08             	call   *0x8(%ebp)
  80065f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800662:	83 eb 01             	sub    $0x1,%ebx
  800665:	eb 1a                	jmp    800681 <vprintfmt+0x243>
  800667:	89 75 08             	mov    %esi,0x8(%ebp)
  80066a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80066d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800670:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800673:	eb 0c                	jmp    800681 <vprintfmt+0x243>
  800675:	89 75 08             	mov    %esi,0x8(%ebp)
  800678:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80067b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80067e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800681:	83 c7 01             	add    $0x1,%edi
  800684:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800688:	0f be d0             	movsbl %al,%edx
  80068b:	85 d2                	test   %edx,%edx
  80068d:	74 23                	je     8006b2 <vprintfmt+0x274>
  80068f:	85 f6                	test   %esi,%esi
  800691:	78 a1                	js     800634 <vprintfmt+0x1f6>
  800693:	83 ee 01             	sub    $0x1,%esi
  800696:	79 9c                	jns    800634 <vprintfmt+0x1f6>
  800698:	89 df                	mov    %ebx,%edi
  80069a:	8b 75 08             	mov    0x8(%ebp),%esi
  80069d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006a0:	eb 18                	jmp    8006ba <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	53                   	push   %ebx
  8006a6:	6a 20                	push   $0x20
  8006a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006aa:	83 ef 01             	sub    $0x1,%edi
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	eb 08                	jmp    8006ba <vprintfmt+0x27c>
  8006b2:	89 df                	mov    %ebx,%edi
  8006b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8006ba:	85 ff                	test   %edi,%edi
  8006bc:	7f e4                	jg     8006a2 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006c1:	e9 9e fd ff ff       	jmp    800464 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c6:	83 fa 01             	cmp    $0x1,%edx
  8006c9:	7e 16                	jle    8006e1 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8006cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ce:	8d 50 08             	lea    0x8(%eax),%edx
  8006d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d4:	8b 50 04             	mov    0x4(%eax),%edx
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006dc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006df:	eb 32                	jmp    800713 <vprintfmt+0x2d5>
	else if (lflag)
  8006e1:	85 d2                	test   %edx,%edx
  8006e3:	74 18                	je     8006fd <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8d 50 04             	lea    0x4(%eax),%edx
  8006eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ee:	8b 00                	mov    (%eax),%eax
  8006f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f3:	89 c1                	mov    %eax,%ecx
  8006f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8006f8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006fb:	eb 16                	jmp    800713 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8d 50 04             	lea    0x4(%eax),%edx
  800703:	89 55 14             	mov    %edx,0x14(%ebp)
  800706:	8b 00                	mov    (%eax),%eax
  800708:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80070b:	89 c1                	mov    %eax,%ecx
  80070d:	c1 f9 1f             	sar    $0x1f,%ecx
  800710:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800713:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800716:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800719:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80071e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800722:	79 74                	jns    800798 <vprintfmt+0x35a>
				putch('-', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	53                   	push   %ebx
  800728:	6a 2d                	push   $0x2d
  80072a:	ff d6                	call   *%esi
				num = -(long long) num;
  80072c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80072f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800732:	f7 d8                	neg    %eax
  800734:	83 d2 00             	adc    $0x0,%edx
  800737:	f7 da                	neg    %edx
  800739:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80073c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800741:	eb 55                	jmp    800798 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800743:	8d 45 14             	lea    0x14(%ebp),%eax
  800746:	e8 7f fc ff ff       	call   8003ca <getuint>
			base = 10;
  80074b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800750:	eb 46                	jmp    800798 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800752:	8d 45 14             	lea    0x14(%ebp),%eax
  800755:	e8 70 fc ff ff       	call   8003ca <getuint>
			base = 8;
  80075a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80075f:	eb 37                	jmp    800798 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800761:	83 ec 08             	sub    $0x8,%esp
  800764:	53                   	push   %ebx
  800765:	6a 30                	push   $0x30
  800767:	ff d6                	call   *%esi
			putch('x', putdat);
  800769:	83 c4 08             	add    $0x8,%esp
  80076c:	53                   	push   %ebx
  80076d:	6a 78                	push   $0x78
  80076f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800771:	8b 45 14             	mov    0x14(%ebp),%eax
  800774:	8d 50 04             	lea    0x4(%eax),%edx
  800777:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80077a:	8b 00                	mov    (%eax),%eax
  80077c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800781:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800784:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800789:	eb 0d                	jmp    800798 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80078b:	8d 45 14             	lea    0x14(%ebp),%eax
  80078e:	e8 37 fc ff ff       	call   8003ca <getuint>
			base = 16;
  800793:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800798:	83 ec 0c             	sub    $0xc,%esp
  80079b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80079f:	57                   	push   %edi
  8007a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007a3:	51                   	push   %ecx
  8007a4:	52                   	push   %edx
  8007a5:	50                   	push   %eax
  8007a6:	89 da                	mov    %ebx,%edx
  8007a8:	89 f0                	mov    %esi,%eax
  8007aa:	e8 71 fb ff ff       	call   800320 <printnum>
			break;
  8007af:	83 c4 20             	add    $0x20,%esp
  8007b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b5:	e9 aa fc ff ff       	jmp    800464 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007ba:	83 ec 08             	sub    $0x8,%esp
  8007bd:	53                   	push   %ebx
  8007be:	51                   	push   %ecx
  8007bf:	ff d6                	call   *%esi
			break;
  8007c1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8007c7:	e9 98 fc ff ff       	jmp    800464 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007cc:	83 ec 08             	sub    $0x8,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	6a 25                	push   $0x25
  8007d2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 03                	jmp    8007dc <vprintfmt+0x39e>
  8007d9:	83 ef 01             	sub    $0x1,%edi
  8007dc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8007e0:	75 f7                	jne    8007d9 <vprintfmt+0x39b>
  8007e2:	e9 7d fc ff ff       	jmp    800464 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8007e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5f                   	pop    %edi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	83 ec 18             	sub    $0x18,%esp
  8007f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800802:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80080c:	85 c0                	test   %eax,%eax
  80080e:	74 26                	je     800836 <vsnprintf+0x47>
  800810:	85 d2                	test   %edx,%edx
  800812:	7e 22                	jle    800836 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800814:	ff 75 14             	pushl  0x14(%ebp)
  800817:	ff 75 10             	pushl  0x10(%ebp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	50                   	push   %eax
  80081e:	68 04 04 80 00       	push   $0x800404
  800823:	e8 16 fc ff ff       	call   80043e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800828:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80082b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80082e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	eb 05                	jmp    80083b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800836:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80083b:	c9                   	leave  
  80083c:	c3                   	ret    

0080083d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800843:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800846:	50                   	push   %eax
  800847:	ff 75 10             	pushl  0x10(%ebp)
  80084a:	ff 75 0c             	pushl  0xc(%ebp)
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 9a ff ff ff       	call   8007ef <vsnprintf>
	va_end(ap);

	return rc;
}
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80085d:	b8 00 00 00 00       	mov    $0x0,%eax
  800862:	eb 03                	jmp    800867 <strlen+0x10>
		n++;
  800864:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800867:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80086b:	75 f7                	jne    800864 <strlen+0xd>
		n++;
	return n;
}
  80086d:	5d                   	pop    %ebp
  80086e:	c3                   	ret    

0080086f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800875:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800878:	ba 00 00 00 00       	mov    $0x0,%edx
  80087d:	eb 03                	jmp    800882 <strnlen+0x13>
		n++;
  80087f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800882:	39 c2                	cmp    %eax,%edx
  800884:	74 08                	je     80088e <strnlen+0x1f>
  800886:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80088a:	75 f3                	jne    80087f <strnlen+0x10>
  80088c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80088e:	5d                   	pop    %ebp
  80088f:	c3                   	ret    

00800890 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	53                   	push   %ebx
  800894:	8b 45 08             	mov    0x8(%ebp),%eax
  800897:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80089a:	89 c2                	mov    %eax,%edx
  80089c:	83 c2 01             	add    $0x1,%edx
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8008a6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a9:	84 db                	test   %bl,%bl
  8008ab:	75 ef                	jne    80089c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	53                   	push   %ebx
  8008b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008b7:	53                   	push   %ebx
  8008b8:	e8 9a ff ff ff       	call   800857 <strlen>
  8008bd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8008c0:	ff 75 0c             	pushl  0xc(%ebp)
  8008c3:	01 d8                	add    %ebx,%eax
  8008c5:	50                   	push   %eax
  8008c6:	e8 c5 ff ff ff       	call   800890 <strcpy>
	return dst;
}
  8008cb:	89 d8                	mov    %ebx,%eax
  8008cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d0:	c9                   	leave  
  8008d1:	c3                   	ret    

008008d2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8008da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008dd:	89 f3                	mov    %esi,%ebx
  8008df:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e2:	89 f2                	mov    %esi,%edx
  8008e4:	eb 0f                	jmp    8008f5 <strncpy+0x23>
		*dst++ = *src;
  8008e6:	83 c2 01             	add    $0x1,%edx
  8008e9:	0f b6 01             	movzbl (%ecx),%eax
  8008ec:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008ef:	80 39 01             	cmpb   $0x1,(%ecx)
  8008f2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f5:	39 da                	cmp    %ebx,%edx
  8008f7:	75 ed                	jne    8008e6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f9:	89 f0                	mov    %esi,%eax
  8008fb:	5b                   	pop    %ebx
  8008fc:	5e                   	pop    %esi
  8008fd:	5d                   	pop    %ebp
  8008fe:	c3                   	ret    

008008ff <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008ff:	55                   	push   %ebp
  800900:	89 e5                	mov    %esp,%ebp
  800902:	56                   	push   %esi
  800903:	53                   	push   %ebx
  800904:	8b 75 08             	mov    0x8(%ebp),%esi
  800907:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090a:	8b 55 10             	mov    0x10(%ebp),%edx
  80090d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80090f:	85 d2                	test   %edx,%edx
  800911:	74 21                	je     800934 <strlcpy+0x35>
  800913:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800917:	89 f2                	mov    %esi,%edx
  800919:	eb 09                	jmp    800924 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80091b:	83 c2 01             	add    $0x1,%edx
  80091e:	83 c1 01             	add    $0x1,%ecx
  800921:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800924:	39 c2                	cmp    %eax,%edx
  800926:	74 09                	je     800931 <strlcpy+0x32>
  800928:	0f b6 19             	movzbl (%ecx),%ebx
  80092b:	84 db                	test   %bl,%bl
  80092d:	75 ec                	jne    80091b <strlcpy+0x1c>
  80092f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800931:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800934:	29 f0                	sub    %esi,%eax
}
  800936:	5b                   	pop    %ebx
  800937:	5e                   	pop    %esi
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800940:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800943:	eb 06                	jmp    80094b <strcmp+0x11>
		p++, q++;
  800945:	83 c1 01             	add    $0x1,%ecx
  800948:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094b:	0f b6 01             	movzbl (%ecx),%eax
  80094e:	84 c0                	test   %al,%al
  800950:	74 04                	je     800956 <strcmp+0x1c>
  800952:	3a 02                	cmp    (%edx),%al
  800954:	74 ef                	je     800945 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800956:	0f b6 c0             	movzbl %al,%eax
  800959:	0f b6 12             	movzbl (%edx),%edx
  80095c:	29 d0                	sub    %edx,%eax
}
  80095e:	5d                   	pop    %ebp
  80095f:	c3                   	ret    

00800960 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	53                   	push   %ebx
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096a:	89 c3                	mov    %eax,%ebx
  80096c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80096f:	eb 06                	jmp    800977 <strncmp+0x17>
		n--, p++, q++;
  800971:	83 c0 01             	add    $0x1,%eax
  800974:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800977:	39 d8                	cmp    %ebx,%eax
  800979:	74 15                	je     800990 <strncmp+0x30>
  80097b:	0f b6 08             	movzbl (%eax),%ecx
  80097e:	84 c9                	test   %cl,%cl
  800980:	74 04                	je     800986 <strncmp+0x26>
  800982:	3a 0a                	cmp    (%edx),%cl
  800984:	74 eb                	je     800971 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800986:	0f b6 00             	movzbl (%eax),%eax
  800989:	0f b6 12             	movzbl (%edx),%edx
  80098c:	29 d0                	sub    %edx,%eax
  80098e:	eb 05                	jmp    800995 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800990:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800995:	5b                   	pop    %ebx
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a2:	eb 07                	jmp    8009ab <strchr+0x13>
		if (*s == c)
  8009a4:	38 ca                	cmp    %cl,%dl
  8009a6:	74 0f                	je     8009b7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009a8:	83 c0 01             	add    $0x1,%eax
  8009ab:	0f b6 10             	movzbl (%eax),%edx
  8009ae:	84 d2                	test   %dl,%dl
  8009b0:	75 f2                	jne    8009a4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c3:	eb 03                	jmp    8009c8 <strfind+0xf>
  8009c5:	83 c0 01             	add    $0x1,%eax
  8009c8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8009cb:	84 d2                	test   %dl,%dl
  8009cd:	74 04                	je     8009d3 <strfind+0x1a>
  8009cf:	38 ca                	cmp    %cl,%dl
  8009d1:	75 f2                	jne    8009c5 <strfind+0xc>
			break;
	return (char *) s;
}
  8009d3:	5d                   	pop    %ebp
  8009d4:	c3                   	ret    

008009d5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d5:	55                   	push   %ebp
  8009d6:	89 e5                	mov    %esp,%ebp
  8009d8:	57                   	push   %edi
  8009d9:	56                   	push   %esi
  8009da:	53                   	push   %ebx
  8009db:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009de:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8009e1:	85 c9                	test   %ecx,%ecx
  8009e3:	74 36                	je     800a1b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009e5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009eb:	75 28                	jne    800a15 <memset+0x40>
  8009ed:	f6 c1 03             	test   $0x3,%cl
  8009f0:	75 23                	jne    800a15 <memset+0x40>
		c &= 0xFF;
  8009f2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009f6:	89 d3                	mov    %edx,%ebx
  8009f8:	c1 e3 08             	shl    $0x8,%ebx
  8009fb:	89 d6                	mov    %edx,%esi
  8009fd:	c1 e6 18             	shl    $0x18,%esi
  800a00:	89 d0                	mov    %edx,%eax
  800a02:	c1 e0 10             	shl    $0x10,%eax
  800a05:	09 f0                	or     %esi,%eax
  800a07:	09 c2                	or     %eax,%edx
  800a09:	89 d0                	mov    %edx,%eax
  800a0b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a0d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800a10:	fc                   	cld    
  800a11:	f3 ab                	rep stos %eax,%es:(%edi)
  800a13:	eb 06                	jmp    800a1b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a18:	fc                   	cld    
  800a19:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a1b:	89 f8                	mov    %edi,%eax
  800a1d:	5b                   	pop    %ebx
  800a1e:	5e                   	pop    %esi
  800a1f:	5f                   	pop    %edi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	57                   	push   %edi
  800a26:	56                   	push   %esi
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a2d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a30:	39 c6                	cmp    %eax,%esi
  800a32:	73 35                	jae    800a69 <memmove+0x47>
  800a34:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a37:	39 d0                	cmp    %edx,%eax
  800a39:	73 2e                	jae    800a69 <memmove+0x47>
		s += n;
		d += n;
  800a3b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800a3e:	89 d6                	mov    %edx,%esi
  800a40:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a42:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a48:	75 13                	jne    800a5d <memmove+0x3b>
  800a4a:	f6 c1 03             	test   $0x3,%cl
  800a4d:	75 0e                	jne    800a5d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a4f:	83 ef 04             	sub    $0x4,%edi
  800a52:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a55:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800a58:	fd                   	std    
  800a59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a5b:	eb 09                	jmp    800a66 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a5d:	83 ef 01             	sub    $0x1,%edi
  800a60:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a63:	fd                   	std    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a66:	fc                   	cld    
  800a67:	eb 1d                	jmp    800a86 <memmove+0x64>
  800a69:	89 f2                	mov    %esi,%edx
  800a6b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6d:	f6 c2 03             	test   $0x3,%dl
  800a70:	75 0f                	jne    800a81 <memmove+0x5f>
  800a72:	f6 c1 03             	test   $0x3,%cl
  800a75:	75 0a                	jne    800a81 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a77:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800a7a:	89 c7                	mov    %eax,%edi
  800a7c:	fc                   	cld    
  800a7d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a7f:	eb 05                	jmp    800a86 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a81:	89 c7                	mov    %eax,%edi
  800a83:	fc                   	cld    
  800a84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a86:	5e                   	pop    %esi
  800a87:	5f                   	pop    %edi
  800a88:	5d                   	pop    %ebp
  800a89:	c3                   	ret    

00800a8a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a8a:	55                   	push   %ebp
  800a8b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800a8d:	ff 75 10             	pushl  0x10(%ebp)
  800a90:	ff 75 0c             	pushl  0xc(%ebp)
  800a93:	ff 75 08             	pushl  0x8(%ebp)
  800a96:	e8 87 ff ff ff       	call   800a22 <memmove>
}
  800a9b:	c9                   	leave  
  800a9c:	c3                   	ret    

00800a9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a9d:	55                   	push   %ebp
  800a9e:	89 e5                	mov    %esp,%ebp
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa8:	89 c6                	mov    %eax,%esi
  800aaa:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aad:	eb 1a                	jmp    800ac9 <memcmp+0x2c>
		if (*s1 != *s2)
  800aaf:	0f b6 08             	movzbl (%eax),%ecx
  800ab2:	0f b6 1a             	movzbl (%edx),%ebx
  800ab5:	38 d9                	cmp    %bl,%cl
  800ab7:	74 0a                	je     800ac3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ab9:	0f b6 c1             	movzbl %cl,%eax
  800abc:	0f b6 db             	movzbl %bl,%ebx
  800abf:	29 d8                	sub    %ebx,%eax
  800ac1:	eb 0f                	jmp    800ad2 <memcmp+0x35>
		s1++, s2++;
  800ac3:	83 c0 01             	add    $0x1,%eax
  800ac6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ac9:	39 f0                	cmp    %esi,%eax
  800acb:	75 e2                	jne    800aaf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800acd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad2:	5b                   	pop    %ebx
  800ad3:	5e                   	pop    %esi
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	8b 45 08             	mov    0x8(%ebp),%eax
  800adc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800adf:	89 c2                	mov    %eax,%edx
  800ae1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ae4:	eb 07                	jmp    800aed <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ae6:	38 08                	cmp    %cl,(%eax)
  800ae8:	74 07                	je     800af1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800aea:	83 c0 01             	add    $0x1,%eax
  800aed:	39 d0                	cmp    %edx,%eax
  800aef:	72 f5                	jb     800ae6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800afc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800aff:	eb 03                	jmp    800b04 <strtol+0x11>
		s++;
  800b01:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b04:	0f b6 01             	movzbl (%ecx),%eax
  800b07:	3c 09                	cmp    $0x9,%al
  800b09:	74 f6                	je     800b01 <strtol+0xe>
  800b0b:	3c 20                	cmp    $0x20,%al
  800b0d:	74 f2                	je     800b01 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b0f:	3c 2b                	cmp    $0x2b,%al
  800b11:	75 0a                	jne    800b1d <strtol+0x2a>
		s++;
  800b13:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800b16:	bf 00 00 00 00       	mov    $0x0,%edi
  800b1b:	eb 10                	jmp    800b2d <strtol+0x3a>
  800b1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800b22:	3c 2d                	cmp    $0x2d,%al
  800b24:	75 07                	jne    800b2d <strtol+0x3a>
		s++, neg = 1;
  800b26:	8d 49 01             	lea    0x1(%ecx),%ecx
  800b29:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b2d:	85 db                	test   %ebx,%ebx
  800b2f:	0f 94 c0             	sete   %al
  800b32:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b38:	75 19                	jne    800b53 <strtol+0x60>
  800b3a:	80 39 30             	cmpb   $0x30,(%ecx)
  800b3d:	75 14                	jne    800b53 <strtol+0x60>
  800b3f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b43:	0f 85 8a 00 00 00    	jne    800bd3 <strtol+0xe0>
		s += 2, base = 16;
  800b49:	83 c1 02             	add    $0x2,%ecx
  800b4c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b51:	eb 16                	jmp    800b69 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b53:	84 c0                	test   %al,%al
  800b55:	74 12                	je     800b69 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b57:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b5c:	80 39 30             	cmpb   $0x30,(%ecx)
  800b5f:	75 08                	jne    800b69 <strtol+0x76>
		s++, base = 8;
  800b61:	83 c1 01             	add    $0x1,%ecx
  800b64:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800b69:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b71:	0f b6 11             	movzbl (%ecx),%edx
  800b74:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b77:	89 f3                	mov    %esi,%ebx
  800b79:	80 fb 09             	cmp    $0x9,%bl
  800b7c:	77 08                	ja     800b86 <strtol+0x93>
			dig = *s - '0';
  800b7e:	0f be d2             	movsbl %dl,%edx
  800b81:	83 ea 30             	sub    $0x30,%edx
  800b84:	eb 22                	jmp    800ba8 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800b86:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b89:	89 f3                	mov    %esi,%ebx
  800b8b:	80 fb 19             	cmp    $0x19,%bl
  800b8e:	77 08                	ja     800b98 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800b90:	0f be d2             	movsbl %dl,%edx
  800b93:	83 ea 57             	sub    $0x57,%edx
  800b96:	eb 10                	jmp    800ba8 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800b98:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b9b:	89 f3                	mov    %esi,%ebx
  800b9d:	80 fb 19             	cmp    $0x19,%bl
  800ba0:	77 16                	ja     800bb8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ba2:	0f be d2             	movsbl %dl,%edx
  800ba5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ba8:	3b 55 10             	cmp    0x10(%ebp),%edx
  800bab:	7d 0f                	jge    800bbc <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800bad:	83 c1 01             	add    $0x1,%ecx
  800bb0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800bb4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800bb6:	eb b9                	jmp    800b71 <strtol+0x7e>
  800bb8:	89 c2                	mov    %eax,%edx
  800bba:	eb 02                	jmp    800bbe <strtol+0xcb>
  800bbc:	89 c2                	mov    %eax,%edx

	if (endptr)
  800bbe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc2:	74 05                	je     800bc9 <strtol+0xd6>
		*endptr = (char *) s;
  800bc4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bc7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800bc9:	85 ff                	test   %edi,%edi
  800bcb:	74 0c                	je     800bd9 <strtol+0xe6>
  800bcd:	89 d0                	mov    %edx,%eax
  800bcf:	f7 d8                	neg    %eax
  800bd1:	eb 06                	jmp    800bd9 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd3:	84 c0                	test   %al,%al
  800bd5:	75 8a                	jne    800b61 <strtol+0x6e>
  800bd7:	eb 90                	jmp    800b69 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    

00800bde <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800bde:	55                   	push   %ebp
  800bdf:	89 e5                	mov    %esp,%ebp
  800be1:	57                   	push   %edi
  800be2:	56                   	push   %esi
  800be3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be4:	b8 00 00 00 00       	mov    $0x0,%eax
  800be9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bec:	8b 55 08             	mov    0x8(%ebp),%edx
  800bef:	89 c3                	mov    %eax,%ebx
  800bf1:	89 c7                	mov    %eax,%edi
  800bf3:	89 c6                	mov    %eax,%esi
  800bf5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5e                   	pop    %esi
  800bf9:	5f                   	pop    %edi
  800bfa:	5d                   	pop    %ebp
  800bfb:	c3                   	ret    

00800bfc <sys_cgetc>:

int
sys_cgetc(void)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	57                   	push   %edi
  800c00:	56                   	push   %esi
  800c01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	b8 01 00 00 00       	mov    $0x1,%eax
  800c0c:	89 d1                	mov    %edx,%ecx
  800c0e:	89 d3                	mov    %edx,%ebx
  800c10:	89 d7                	mov    %edx,%edi
  800c12:	89 d6                	mov    %edx,%esi
  800c14:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c24:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c29:	b8 03 00 00 00       	mov    $0x3,%eax
  800c2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c31:	89 cb                	mov    %ecx,%ebx
  800c33:	89 cf                	mov    %ecx,%edi
  800c35:	89 ce                	mov    %ecx,%esi
  800c37:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c39:	85 c0                	test   %eax,%eax
  800c3b:	7e 17                	jle    800c54 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	50                   	push   %eax
  800c41:	6a 03                	push   $0x3
  800c43:	68 5f 23 80 00       	push   $0x80235f
  800c48:	6a 23                	push   $0x23
  800c4a:	68 7c 23 80 00       	push   $0x80237c
  800c4f:	e8 df f5 ff ff       	call   800233 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c57:	5b                   	pop    %ebx
  800c58:	5e                   	pop    %esi
  800c59:	5f                   	pop    %edi
  800c5a:	5d                   	pop    %ebp
  800c5b:	c3                   	ret    

00800c5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	57                   	push   %edi
  800c60:	56                   	push   %esi
  800c61:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c62:	ba 00 00 00 00       	mov    $0x0,%edx
  800c67:	b8 02 00 00 00       	mov    $0x2,%eax
  800c6c:	89 d1                	mov    %edx,%ecx
  800c6e:	89 d3                	mov    %edx,%ebx
  800c70:	89 d7                	mov    %edx,%edi
  800c72:	89 d6                	mov    %edx,%esi
  800c74:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c76:	5b                   	pop    %ebx
  800c77:	5e                   	pop    %esi
  800c78:	5f                   	pop    %edi
  800c79:	5d                   	pop    %ebp
  800c7a:	c3                   	ret    

00800c7b <sys_yield>:

void
sys_yield(void)
{
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c81:	ba 00 00 00 00       	mov    $0x0,%edx
  800c86:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c8b:	89 d1                	mov    %edx,%ecx
  800c8d:	89 d3                	mov    %edx,%ebx
  800c8f:	89 d7                	mov    %edx,%edi
  800c91:	89 d6                	mov    %edx,%esi
  800c93:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    

00800c9a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ca3:	be 00 00 00 00       	mov    $0x0,%esi
  800ca8:	b8 04 00 00 00       	mov    $0x4,%eax
  800cad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cb6:	89 f7                	mov    %esi,%edi
  800cb8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	7e 17                	jle    800cd5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	6a 04                	push   $0x4
  800cc4:	68 5f 23 80 00       	push   $0x80235f
  800cc9:	6a 23                	push   $0x23
  800ccb:	68 7c 23 80 00       	push   $0x80237c
  800cd0:	e8 5e f5 ff ff       	call   800233 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf7:	8b 75 18             	mov    0x18(%ebp),%esi
  800cfa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7e 17                	jle    800d17 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	83 ec 0c             	sub    $0xc,%esp
  800d03:	50                   	push   %eax
  800d04:	6a 05                	push   $0x5
  800d06:	68 5f 23 80 00       	push   $0x80235f
  800d0b:	6a 23                	push   $0x23
  800d0d:	68 7c 23 80 00       	push   $0x80237c
  800d12:	e8 1c f5 ff ff       	call   800233 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1a:	5b                   	pop    %ebx
  800d1b:	5e                   	pop    %esi
  800d1c:	5f                   	pop    %edi
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	89 df                	mov    %ebx,%edi
  800d3a:	89 de                	mov    %ebx,%esi
  800d3c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	7e 17                	jle    800d59 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	50                   	push   %eax
  800d46:	6a 06                	push   $0x6
  800d48:	68 5f 23 80 00       	push   $0x80235f
  800d4d:	6a 23                	push   $0x23
  800d4f:	68 7c 23 80 00       	push   $0x80237c
  800d54:	e8 da f4 ff ff       	call   800233 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6f:	b8 08 00 00 00       	mov    $0x8,%eax
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	89 df                	mov    %ebx,%edi
  800d7c:	89 de                	mov    %ebx,%esi
  800d7e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	7e 17                	jle    800d9b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	50                   	push   %eax
  800d88:	6a 08                	push   $0x8
  800d8a:	68 5f 23 80 00       	push   $0x80235f
  800d8f:	6a 23                	push   $0x23
  800d91:	68 7c 23 80 00       	push   $0x80237c
  800d96:	e8 98 f4 ff ff       	call   800233 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db1:	b8 09 00 00 00       	mov    $0x9,%eax
  800db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dbc:	89 df                	mov    %ebx,%edi
  800dbe:	89 de                	mov    %ebx,%esi
  800dc0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7e 17                	jle    800ddd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 09                	push   $0x9
  800dcc:	68 5f 23 80 00       	push   $0x80235f
  800dd1:	6a 23                	push   $0x23
  800dd3:	68 7c 23 80 00       	push   $0x80237c
  800dd8:	e8 56 f4 ff ff       	call   800233 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ddd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
  800deb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfe:	89 df                	mov    %ebx,%edi
  800e00:	89 de                	mov    %ebx,%esi
  800e02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e04:	85 c0                	test   %eax,%eax
  800e06:	7e 17                	jle    800e1f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	50                   	push   %eax
  800e0c:	6a 0a                	push   $0xa
  800e0e:	68 5f 23 80 00       	push   $0x80235f
  800e13:	6a 23                	push   $0x23
  800e15:	68 7c 23 80 00       	push   $0x80237c
  800e1a:	e8 14 f4 ff ff       	call   800233 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e22:	5b                   	pop    %ebx
  800e23:	5e                   	pop    %esi
  800e24:	5f                   	pop    %edi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    

00800e27 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2d:	be 00 00 00 00       	mov    $0x0,%esi
  800e32:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e40:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e43:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	57                   	push   %edi
  800e4e:	56                   	push   %esi
  800e4f:	53                   	push   %ebx
  800e50:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e53:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e58:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e60:	89 cb                	mov    %ecx,%ebx
  800e62:	89 cf                	mov    %ecx,%edi
  800e64:	89 ce                	mov    %ecx,%esi
  800e66:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e68:	85 c0                	test   %eax,%eax
  800e6a:	7e 17                	jle    800e83 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	50                   	push   %eax
  800e70:	6a 0d                	push   $0xd
  800e72:	68 5f 23 80 00       	push   $0x80235f
  800e77:	6a 23                	push   $0x23
  800e79:	68 7c 23 80 00       	push   $0x80237c
  800e7e:	e8 b0 f3 ff ff       	call   800233 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e86:	5b                   	pop    %ebx
  800e87:	5e                   	pop    %esi
  800e88:	5f                   	pop    %edi
  800e89:	5d                   	pop    %ebp
  800e8a:	c3                   	ret    

00800e8b <sys_gettime>:

int sys_gettime(void)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	57                   	push   %edi
  800e8f:	56                   	push   %esi
  800e90:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e91:	ba 00 00 00 00       	mov    $0x0,%edx
  800e96:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e9b:	89 d1                	mov    %edx,%ecx
  800e9d:	89 d3                	mov    %edx,%ebx
  800e9f:	89 d7                	mov    %edx,%edi
  800ea1:	89 d6                	mov    %edx,%esi
  800ea3:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800ea5:	5b                   	pop    %ebx
  800ea6:	5e                   	pop    %esi
  800ea7:	5f                   	pop    %edi
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ead:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb0:	05 00 00 00 30       	add    $0x30000000,%eax
  800eb5:	c1 e8 0c             	shr    $0xc,%eax
}
  800eb8:	5d                   	pop    %ebp
  800eb9:	c3                   	ret    

00800eba <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ebd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec0:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800ec5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eca:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800edc:	89 c2                	mov    %eax,%edx
  800ede:	c1 ea 16             	shr    $0x16,%edx
  800ee1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ee8:	f6 c2 01             	test   $0x1,%dl
  800eeb:	74 11                	je     800efe <fd_alloc+0x2d>
  800eed:	89 c2                	mov    %eax,%edx
  800eef:	c1 ea 0c             	shr    $0xc,%edx
  800ef2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ef9:	f6 c2 01             	test   $0x1,%dl
  800efc:	75 09                	jne    800f07 <fd_alloc+0x36>
			*fd_store = fd;
  800efe:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
  800f05:	eb 17                	jmp    800f1e <fd_alloc+0x4d>
  800f07:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800f0c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f11:	75 c9                	jne    800edc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800f13:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800f19:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800f1e:	5d                   	pop    %ebp
  800f1f:	c3                   	ret    

00800f20 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f26:	83 f8 1f             	cmp    $0x1f,%eax
  800f29:	77 36                	ja     800f61 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f2b:	c1 e0 0c             	shl    $0xc,%eax
  800f2e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f33:	89 c2                	mov    %eax,%edx
  800f35:	c1 ea 16             	shr    $0x16,%edx
  800f38:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f3f:	f6 c2 01             	test   $0x1,%dl
  800f42:	74 24                	je     800f68 <fd_lookup+0x48>
  800f44:	89 c2                	mov    %eax,%edx
  800f46:	c1 ea 0c             	shr    $0xc,%edx
  800f49:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f50:	f6 c2 01             	test   $0x1,%dl
  800f53:	74 1a                	je     800f6f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f55:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f58:	89 02                	mov    %eax,(%edx)
	return 0;
  800f5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f5f:	eb 13                	jmp    800f74 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f61:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f66:	eb 0c                	jmp    800f74 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800f68:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f6d:	eb 05                	jmp    800f74 <fd_lookup+0x54>
  800f6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	83 ec 08             	sub    $0x8,%esp
  800f7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f7f:	ba 08 24 80 00       	mov    $0x802408,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f84:	eb 13                	jmp    800f99 <dev_lookup+0x23>
  800f86:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f89:	39 08                	cmp    %ecx,(%eax)
  800f8b:	75 0c                	jne    800f99 <dev_lookup+0x23>
			*dev = devtab[i];
  800f8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f90:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f92:	b8 00 00 00 00       	mov    $0x0,%eax
  800f97:	eb 2e                	jmp    800fc7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f99:	8b 02                	mov    (%edx),%eax
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	75 e7                	jne    800f86 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f9f:	a1 04 40 80 00       	mov    0x804004,%eax
  800fa4:	8b 40 48             	mov    0x48(%eax),%eax
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	51                   	push   %ecx
  800fab:	50                   	push   %eax
  800fac:	68 8c 23 80 00       	push   $0x80238c
  800fb1:	e8 56 f3 ff ff       	call   80030c <cprintf>
	*dev = 0;
  800fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800fbf:	83 c4 10             	add    $0x10,%esp
  800fc2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	56                   	push   %esi
  800fcd:	53                   	push   %ebx
  800fce:	83 ec 10             	sub    $0x10,%esp
  800fd1:	8b 75 08             	mov    0x8(%ebp),%esi
  800fd4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fda:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800fdb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800fe1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800fe4:	50                   	push   %eax
  800fe5:	e8 36 ff ff ff       	call   800f20 <fd_lookup>
  800fea:	83 c4 08             	add    $0x8,%esp
  800fed:	85 c0                	test   %eax,%eax
  800fef:	78 05                	js     800ff6 <fd_close+0x2d>
	    || fd != fd2)
  800ff1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ff4:	74 0b                	je     801001 <fd_close+0x38>
		return (must_exist ? r : 0);
  800ff6:	80 fb 01             	cmp    $0x1,%bl
  800ff9:	19 d2                	sbb    %edx,%edx
  800ffb:	f7 d2                	not    %edx
  800ffd:	21 d0                	and    %edx,%eax
  800fff:	eb 41                	jmp    801042 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801001:	83 ec 08             	sub    $0x8,%esp
  801004:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801007:	50                   	push   %eax
  801008:	ff 36                	pushl  (%esi)
  80100a:	e8 67 ff ff ff       	call   800f76 <dev_lookup>
  80100f:	89 c3                	mov    %eax,%ebx
  801011:	83 c4 10             	add    $0x10,%esp
  801014:	85 c0                	test   %eax,%eax
  801016:	78 1a                	js     801032 <fd_close+0x69>
		if (dev->dev_close)
  801018:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80101b:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80101e:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801023:	85 c0                	test   %eax,%eax
  801025:	74 0b                	je     801032 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  801027:	83 ec 0c             	sub    $0xc,%esp
  80102a:	56                   	push   %esi
  80102b:	ff d0                	call   *%eax
  80102d:	89 c3                	mov    %eax,%ebx
  80102f:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801032:	83 ec 08             	sub    $0x8,%esp
  801035:	56                   	push   %esi
  801036:	6a 00                	push   $0x0
  801038:	e8 e2 fc ff ff       	call   800d1f <sys_page_unmap>
	return r;
  80103d:	83 c4 10             	add    $0x10,%esp
  801040:	89 d8                	mov    %ebx,%eax
}
  801042:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80104f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801052:	50                   	push   %eax
  801053:	ff 75 08             	pushl  0x8(%ebp)
  801056:	e8 c5 fe ff ff       	call   800f20 <fd_lookup>
  80105b:	89 c2                	mov    %eax,%edx
  80105d:	83 c4 08             	add    $0x8,%esp
  801060:	85 d2                	test   %edx,%edx
  801062:	78 10                	js     801074 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801064:	83 ec 08             	sub    $0x8,%esp
  801067:	6a 01                	push   $0x1
  801069:	ff 75 f4             	pushl  -0xc(%ebp)
  80106c:	e8 58 ff ff ff       	call   800fc9 <fd_close>
  801071:	83 c4 10             	add    $0x10,%esp
}
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <close_all>:

void
close_all(void)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	53                   	push   %ebx
  80107a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80107d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801082:	83 ec 0c             	sub    $0xc,%esp
  801085:	53                   	push   %ebx
  801086:	e8 be ff ff ff       	call   801049 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80108b:	83 c3 01             	add    $0x1,%ebx
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	83 fb 20             	cmp    $0x20,%ebx
  801094:	75 ec                	jne    801082 <close_all+0xc>
		close(i);
}
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 2c             	sub    $0x2c,%esp
  8010a4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010a7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010aa:	50                   	push   %eax
  8010ab:	ff 75 08             	pushl  0x8(%ebp)
  8010ae:	e8 6d fe ff ff       	call   800f20 <fd_lookup>
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	83 c4 08             	add    $0x8,%esp
  8010b8:	85 d2                	test   %edx,%edx
  8010ba:	0f 88 c1 00 00 00    	js     801181 <dup+0xe6>
		return r;
	close(newfdnum);
  8010c0:	83 ec 0c             	sub    $0xc,%esp
  8010c3:	56                   	push   %esi
  8010c4:	e8 80 ff ff ff       	call   801049 <close>

	newfd = INDEX2FD(newfdnum);
  8010c9:	89 f3                	mov    %esi,%ebx
  8010cb:	c1 e3 0c             	shl    $0xc,%ebx
  8010ce:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8010d4:	83 c4 04             	add    $0x4,%esp
  8010d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010da:	e8 db fd ff ff       	call   800eba <fd2data>
  8010df:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8010e1:	89 1c 24             	mov    %ebx,(%esp)
  8010e4:	e8 d1 fd ff ff       	call   800eba <fd2data>
  8010e9:	83 c4 10             	add    $0x10,%esp
  8010ec:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8010ef:	89 f8                	mov    %edi,%eax
  8010f1:	c1 e8 16             	shr    $0x16,%eax
  8010f4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010fb:	a8 01                	test   $0x1,%al
  8010fd:	74 37                	je     801136 <dup+0x9b>
  8010ff:	89 f8                	mov    %edi,%eax
  801101:	c1 e8 0c             	shr    $0xc,%eax
  801104:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80110b:	f6 c2 01             	test   $0x1,%dl
  80110e:	74 26                	je     801136 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801110:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801117:	83 ec 0c             	sub    $0xc,%esp
  80111a:	25 07 0e 00 00       	and    $0xe07,%eax
  80111f:	50                   	push   %eax
  801120:	ff 75 d4             	pushl  -0x2c(%ebp)
  801123:	6a 00                	push   $0x0
  801125:	57                   	push   %edi
  801126:	6a 00                	push   $0x0
  801128:	e8 b0 fb ff ff       	call   800cdd <sys_page_map>
  80112d:	89 c7                	mov    %eax,%edi
  80112f:	83 c4 20             	add    $0x20,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	78 2e                	js     801164 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801136:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801139:	89 d0                	mov    %edx,%eax
  80113b:	c1 e8 0c             	shr    $0xc,%eax
  80113e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801145:	83 ec 0c             	sub    $0xc,%esp
  801148:	25 07 0e 00 00       	and    $0xe07,%eax
  80114d:	50                   	push   %eax
  80114e:	53                   	push   %ebx
  80114f:	6a 00                	push   $0x0
  801151:	52                   	push   %edx
  801152:	6a 00                	push   $0x0
  801154:	e8 84 fb ff ff       	call   800cdd <sys_page_map>
  801159:	89 c7                	mov    %eax,%edi
  80115b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80115e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801160:	85 ff                	test   %edi,%edi
  801162:	79 1d                	jns    801181 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	53                   	push   %ebx
  801168:	6a 00                	push   $0x0
  80116a:	e8 b0 fb ff ff       	call   800d1f <sys_page_unmap>
	sys_page_unmap(0, nva);
  80116f:	83 c4 08             	add    $0x8,%esp
  801172:	ff 75 d4             	pushl  -0x2c(%ebp)
  801175:	6a 00                	push   $0x0
  801177:	e8 a3 fb ff ff       	call   800d1f <sys_page_unmap>
	return r;
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	89 f8                	mov    %edi,%eax
}
  801181:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801184:	5b                   	pop    %ebx
  801185:	5e                   	pop    %esi
  801186:	5f                   	pop    %edi
  801187:	5d                   	pop    %ebp
  801188:	c3                   	ret    

00801189 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	53                   	push   %ebx
  80118d:	83 ec 14             	sub    $0x14,%esp
  801190:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801193:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801196:	50                   	push   %eax
  801197:	53                   	push   %ebx
  801198:	e8 83 fd ff ff       	call   800f20 <fd_lookup>
  80119d:	83 c4 08             	add    $0x8,%esp
  8011a0:	89 c2                	mov    %eax,%edx
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 6d                	js     801213 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ac:	50                   	push   %eax
  8011ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b0:	ff 30                	pushl  (%eax)
  8011b2:	e8 bf fd ff ff       	call   800f76 <dev_lookup>
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 4c                	js     80120a <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011be:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011c1:	8b 42 08             	mov    0x8(%edx),%eax
  8011c4:	83 e0 03             	and    $0x3,%eax
  8011c7:	83 f8 01             	cmp    $0x1,%eax
  8011ca:	75 21                	jne    8011ed <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8011cc:	a1 04 40 80 00       	mov    0x804004,%eax
  8011d1:	8b 40 48             	mov    0x48(%eax),%eax
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	53                   	push   %ebx
  8011d8:	50                   	push   %eax
  8011d9:	68 cd 23 80 00       	push   $0x8023cd
  8011de:	e8 29 f1 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  8011e3:	83 c4 10             	add    $0x10,%esp
  8011e6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011eb:	eb 26                	jmp    801213 <read+0x8a>
	}
	if (!dev->dev_read)
  8011ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011f0:	8b 40 08             	mov    0x8(%eax),%eax
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	74 17                	je     80120e <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	ff 75 10             	pushl  0x10(%ebp)
  8011fd:	ff 75 0c             	pushl  0xc(%ebp)
  801200:	52                   	push   %edx
  801201:	ff d0                	call   *%eax
  801203:	89 c2                	mov    %eax,%edx
  801205:	83 c4 10             	add    $0x10,%esp
  801208:	eb 09                	jmp    801213 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	eb 05                	jmp    801213 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80120e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801213:	89 d0                	mov    %edx,%eax
  801215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801218:	c9                   	leave  
  801219:	c3                   	ret    

0080121a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80121a:	55                   	push   %ebp
  80121b:	89 e5                	mov    %esp,%ebp
  80121d:	57                   	push   %edi
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	83 ec 0c             	sub    $0xc,%esp
  801223:	8b 7d 08             	mov    0x8(%ebp),%edi
  801226:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80122e:	eb 21                	jmp    801251 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801230:	83 ec 04             	sub    $0x4,%esp
  801233:	89 f0                	mov    %esi,%eax
  801235:	29 d8                	sub    %ebx,%eax
  801237:	50                   	push   %eax
  801238:	89 d8                	mov    %ebx,%eax
  80123a:	03 45 0c             	add    0xc(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	57                   	push   %edi
  80123f:	e8 45 ff ff ff       	call   801189 <read>
		if (m < 0)
  801244:	83 c4 10             	add    $0x10,%esp
  801247:	85 c0                	test   %eax,%eax
  801249:	78 0c                	js     801257 <readn+0x3d>
			return m;
		if (m == 0)
  80124b:	85 c0                	test   %eax,%eax
  80124d:	74 06                	je     801255 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80124f:	01 c3                	add    %eax,%ebx
  801251:	39 f3                	cmp    %esi,%ebx
  801253:	72 db                	jb     801230 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801255:	89 d8                	mov    %ebx,%eax
}
  801257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125a:	5b                   	pop    %ebx
  80125b:	5e                   	pop    %esi
  80125c:	5f                   	pop    %edi
  80125d:	5d                   	pop    %ebp
  80125e:	c3                   	ret    

0080125f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125f:	55                   	push   %ebp
  801260:	89 e5                	mov    %esp,%ebp
  801262:	53                   	push   %ebx
  801263:	83 ec 14             	sub    $0x14,%esp
  801266:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801269:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126c:	50                   	push   %eax
  80126d:	53                   	push   %ebx
  80126e:	e8 ad fc ff ff       	call   800f20 <fd_lookup>
  801273:	83 c4 08             	add    $0x8,%esp
  801276:	89 c2                	mov    %eax,%edx
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 68                	js     8012e4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127c:	83 ec 08             	sub    $0x8,%esp
  80127f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801286:	ff 30                	pushl  (%eax)
  801288:	e8 e9 fc ff ff       	call   800f76 <dev_lookup>
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 47                	js     8012db <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801294:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801297:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80129b:	75 21                	jne    8012be <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80129d:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a2:	8b 40 48             	mov    0x48(%eax),%eax
  8012a5:	83 ec 04             	sub    $0x4,%esp
  8012a8:	53                   	push   %ebx
  8012a9:	50                   	push   %eax
  8012aa:	68 e9 23 80 00       	push   $0x8023e9
  8012af:	e8 58 f0 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012bc:	eb 26                	jmp    8012e4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012be:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c1:	8b 52 0c             	mov    0xc(%edx),%edx
  8012c4:	85 d2                	test   %edx,%edx
  8012c6:	74 17                	je     8012df <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012c8:	83 ec 04             	sub    $0x4,%esp
  8012cb:	ff 75 10             	pushl  0x10(%ebp)
  8012ce:	ff 75 0c             	pushl  0xc(%ebp)
  8012d1:	50                   	push   %eax
  8012d2:	ff d2                	call   *%edx
  8012d4:	89 c2                	mov    %eax,%edx
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	eb 09                	jmp    8012e4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012db:	89 c2                	mov    %eax,%edx
  8012dd:	eb 05                	jmp    8012e4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8012df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8012e4:	89 d0                	mov    %edx,%eax
  8012e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    

008012eb <seek>:

int
seek(int fdnum, off_t offset)
{
  8012eb:	55                   	push   %ebp
  8012ec:	89 e5                	mov    %esp,%ebp
  8012ee:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012f1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012f4:	50                   	push   %eax
  8012f5:	ff 75 08             	pushl  0x8(%ebp)
  8012f8:	e8 23 fc ff ff       	call   800f20 <fd_lookup>
  8012fd:	83 c4 08             	add    $0x8,%esp
  801300:	85 c0                	test   %eax,%eax
  801302:	78 0e                	js     801312 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801304:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801307:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801312:	c9                   	leave  
  801313:	c3                   	ret    

00801314 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801314:	55                   	push   %ebp
  801315:	89 e5                	mov    %esp,%ebp
  801317:	53                   	push   %ebx
  801318:	83 ec 14             	sub    $0x14,%esp
  80131b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	53                   	push   %ebx
  801323:	e8 f8 fb ff ff       	call   800f20 <fd_lookup>
  801328:	83 c4 08             	add    $0x8,%esp
  80132b:	89 c2                	mov    %eax,%edx
  80132d:	85 c0                	test   %eax,%eax
  80132f:	78 65                	js     801396 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80133b:	ff 30                	pushl  (%eax)
  80133d:	e8 34 fc ff ff       	call   800f76 <dev_lookup>
  801342:	83 c4 10             	add    $0x10,%esp
  801345:	85 c0                	test   %eax,%eax
  801347:	78 44                	js     80138d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801349:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801350:	75 21                	jne    801373 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801352:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801357:	8b 40 48             	mov    0x48(%eax),%eax
  80135a:	83 ec 04             	sub    $0x4,%esp
  80135d:	53                   	push   %ebx
  80135e:	50                   	push   %eax
  80135f:	68 ac 23 80 00       	push   $0x8023ac
  801364:	e8 a3 ef ff ff       	call   80030c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801369:	83 c4 10             	add    $0x10,%esp
  80136c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801371:	eb 23                	jmp    801396 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801373:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801376:	8b 52 18             	mov    0x18(%edx),%edx
  801379:	85 d2                	test   %edx,%edx
  80137b:	74 14                	je     801391 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	ff 75 0c             	pushl  0xc(%ebp)
  801383:	50                   	push   %eax
  801384:	ff d2                	call   *%edx
  801386:	89 c2                	mov    %eax,%edx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	eb 09                	jmp    801396 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138d:	89 c2                	mov    %eax,%edx
  80138f:	eb 05                	jmp    801396 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801391:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801396:	89 d0                	mov    %edx,%eax
  801398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	53                   	push   %ebx
  8013a1:	83 ec 14             	sub    $0x14,%esp
  8013a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013aa:	50                   	push   %eax
  8013ab:	ff 75 08             	pushl  0x8(%ebp)
  8013ae:	e8 6d fb ff ff       	call   800f20 <fd_lookup>
  8013b3:	83 c4 08             	add    $0x8,%esp
  8013b6:	89 c2                	mov    %eax,%edx
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 58                	js     801414 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bc:	83 ec 08             	sub    $0x8,%esp
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c6:	ff 30                	pushl  (%eax)
  8013c8:	e8 a9 fb ff ff       	call   800f76 <dev_lookup>
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	78 37                	js     80140b <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8013d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013db:	74 32                	je     80140f <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013dd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e7:	00 00 00 
	stat->st_isdir = 0;
  8013ea:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f1:	00 00 00 
	stat->st_dev = dev;
  8013f4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013fa:	83 ec 08             	sub    $0x8,%esp
  8013fd:	53                   	push   %ebx
  8013fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801401:	ff 50 14             	call   *0x14(%eax)
  801404:	89 c2                	mov    %eax,%edx
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	eb 09                	jmp    801414 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140b:	89 c2                	mov    %eax,%edx
  80140d:	eb 05                	jmp    801414 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80140f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801414:	89 d0                	mov    %edx,%eax
  801416:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801419:	c9                   	leave  
  80141a:	c3                   	ret    

0080141b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80141b:	55                   	push   %ebp
  80141c:	89 e5                	mov    %esp,%ebp
  80141e:	56                   	push   %esi
  80141f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801420:	83 ec 08             	sub    $0x8,%esp
  801423:	6a 00                	push   $0x0
  801425:	ff 75 08             	pushl  0x8(%ebp)
  801428:	e8 e7 01 00 00       	call   801614 <open>
  80142d:	89 c3                	mov    %eax,%ebx
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 db                	test   %ebx,%ebx
  801434:	78 1b                	js     801451 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801436:	83 ec 08             	sub    $0x8,%esp
  801439:	ff 75 0c             	pushl  0xc(%ebp)
  80143c:	53                   	push   %ebx
  80143d:	e8 5b ff ff ff       	call   80139d <fstat>
  801442:	89 c6                	mov    %eax,%esi
	close(fd);
  801444:	89 1c 24             	mov    %ebx,(%esp)
  801447:	e8 fd fb ff ff       	call   801049 <close>
	return r;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	89 f0                	mov    %esi,%eax
}
  801451:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5d                   	pop    %ebp
  801457:	c3                   	ret    

00801458 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	56                   	push   %esi
  80145c:	53                   	push   %ebx
  80145d:	89 c6                	mov    %eax,%esi
  80145f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801461:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801468:	75 12                	jne    80147c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80146a:	83 ec 0c             	sub    $0xc,%esp
  80146d:	6a 03                	push   $0x3
  80146f:	e8 d2 07 00 00       	call   801c46 <ipc_find_env>
  801474:	a3 00 40 80 00       	mov    %eax,0x804000
  801479:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80147c:	6a 07                	push   $0x7
  80147e:	68 00 50 80 00       	push   $0x805000
  801483:	56                   	push   %esi
  801484:	ff 35 00 40 80 00    	pushl  0x804000
  80148a:	e8 66 07 00 00       	call   801bf5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80148f:	83 c4 0c             	add    $0xc,%esp
  801492:	6a 00                	push   $0x0
  801494:	53                   	push   %ebx
  801495:	6a 00                	push   $0x0
  801497:	e8 f3 06 00 00       	call   801b8f <ipc_recv>
}
  80149c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	8b 40 0c             	mov    0xc(%eax),%eax
  8014af:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b7:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c1:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c6:	e8 8d ff ff ff       	call   801458 <fsipc>
}
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    

008014cd <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014de:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e3:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e8:	e8 6b ff ff ff       	call   801458 <fsipc>
}
  8014ed:	c9                   	leave  
  8014ee:	c3                   	ret    

008014ef <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 04             	sub    $0x4,%esp
  8014f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fc:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ff:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801504:	ba 00 00 00 00       	mov    $0x0,%edx
  801509:	b8 05 00 00 00       	mov    $0x5,%eax
  80150e:	e8 45 ff ff ff       	call   801458 <fsipc>
  801513:	89 c2                	mov    %eax,%edx
  801515:	85 d2                	test   %edx,%edx
  801517:	78 2c                	js     801545 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801519:	83 ec 08             	sub    $0x8,%esp
  80151c:	68 00 50 80 00       	push   $0x805000
  801521:	53                   	push   %ebx
  801522:	e8 69 f3 ff ff       	call   800890 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801527:	a1 80 50 80 00       	mov    0x805080,%eax
  80152c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801532:	a1 84 50 80 00       	mov    0x805084,%eax
  801537:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801545:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801548:	c9                   	leave  
  801549:	c3                   	ret    

0080154a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80154a:	55                   	push   %ebp
  80154b:	89 e5                	mov    %esp,%ebp
  80154d:	83 ec 08             	sub    $0x8,%esp
  801550:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801553:	8b 55 08             	mov    0x8(%ebp),%edx
  801556:	8b 52 0c             	mov    0xc(%edx),%edx
  801559:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  80155f:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801564:	76 05                	jbe    80156b <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801566:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  80156b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801570:	83 ec 04             	sub    $0x4,%esp
  801573:	50                   	push   %eax
  801574:	ff 75 0c             	pushl  0xc(%ebp)
  801577:	68 08 50 80 00       	push   $0x805008
  80157c:	e8 a1 f4 ff ff       	call   800a22 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801581:	ba 00 00 00 00       	mov    $0x0,%edx
  801586:	b8 04 00 00 00       	mov    $0x4,%eax
  80158b:	e8 c8 fe ff ff       	call   801458 <fsipc>
	return write;
}
  801590:	c9                   	leave  
  801591:	c3                   	ret    

00801592 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801592:	55                   	push   %ebp
  801593:	89 e5                	mov    %esp,%ebp
  801595:	56                   	push   %esi
  801596:	53                   	push   %ebx
  801597:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80159a:	8b 45 08             	mov    0x8(%ebp),%eax
  80159d:	8b 40 0c             	mov    0xc(%eax),%eax
  8015a0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015a5:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b0:	b8 03 00 00 00       	mov    $0x3,%eax
  8015b5:	e8 9e fe ff ff       	call   801458 <fsipc>
  8015ba:	89 c3                	mov    %eax,%ebx
  8015bc:	85 c0                	test   %eax,%eax
  8015be:	78 4b                	js     80160b <devfile_read+0x79>
		return r;
	assert(r <= n);
  8015c0:	39 c6                	cmp    %eax,%esi
  8015c2:	73 16                	jae    8015da <devfile_read+0x48>
  8015c4:	68 18 24 80 00       	push   $0x802418
  8015c9:	68 1f 24 80 00       	push   $0x80241f
  8015ce:	6a 7c                	push   $0x7c
  8015d0:	68 34 24 80 00       	push   $0x802434
  8015d5:	e8 59 ec ff ff       	call   800233 <_panic>
	assert(r <= PGSIZE);
  8015da:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015df:	7e 16                	jle    8015f7 <devfile_read+0x65>
  8015e1:	68 3f 24 80 00       	push   $0x80243f
  8015e6:	68 1f 24 80 00       	push   $0x80241f
  8015eb:	6a 7d                	push   $0x7d
  8015ed:	68 34 24 80 00       	push   $0x802434
  8015f2:	e8 3c ec ff ff       	call   800233 <_panic>
	memmove(buf, &fsipcbuf, r);
  8015f7:	83 ec 04             	sub    $0x4,%esp
  8015fa:	50                   	push   %eax
  8015fb:	68 00 50 80 00       	push   $0x805000
  801600:	ff 75 0c             	pushl  0xc(%ebp)
  801603:	e8 1a f4 ff ff       	call   800a22 <memmove>
	return r;
  801608:	83 c4 10             	add    $0x10,%esp
}
  80160b:	89 d8                	mov    %ebx,%eax
  80160d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801610:	5b                   	pop    %ebx
  801611:	5e                   	pop    %esi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	53                   	push   %ebx
  801618:	83 ec 20             	sub    $0x20,%esp
  80161b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80161e:	53                   	push   %ebx
  80161f:	e8 33 f2 ff ff       	call   800857 <strlen>
  801624:	83 c4 10             	add    $0x10,%esp
  801627:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80162c:	7f 67                	jg     801695 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80162e:	83 ec 0c             	sub    $0xc,%esp
  801631:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	e8 97 f8 ff ff       	call   800ed1 <fd_alloc>
  80163a:	83 c4 10             	add    $0x10,%esp
		return r;
  80163d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80163f:	85 c0                	test   %eax,%eax
  801641:	78 57                	js     80169a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801643:	83 ec 08             	sub    $0x8,%esp
  801646:	53                   	push   %ebx
  801647:	68 00 50 80 00       	push   $0x805000
  80164c:	e8 3f f2 ff ff       	call   800890 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801651:	8b 45 0c             	mov    0xc(%ebp),%eax
  801654:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801659:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80165c:	b8 01 00 00 00       	mov    $0x1,%eax
  801661:	e8 f2 fd ff ff       	call   801458 <fsipc>
  801666:	89 c3                	mov    %eax,%ebx
  801668:	83 c4 10             	add    $0x10,%esp
  80166b:	85 c0                	test   %eax,%eax
  80166d:	79 14                	jns    801683 <open+0x6f>
		fd_close(fd, 0);
  80166f:	83 ec 08             	sub    $0x8,%esp
  801672:	6a 00                	push   $0x0
  801674:	ff 75 f4             	pushl  -0xc(%ebp)
  801677:	e8 4d f9 ff ff       	call   800fc9 <fd_close>
		return r;
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	89 da                	mov    %ebx,%edx
  801681:	eb 17                	jmp    80169a <open+0x86>
	}

	return fd2num(fd);
  801683:	83 ec 0c             	sub    $0xc,%esp
  801686:	ff 75 f4             	pushl  -0xc(%ebp)
  801689:	e8 1c f8 ff ff       	call   800eaa <fd2num>
  80168e:	89 c2                	mov    %eax,%edx
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	eb 05                	jmp    80169a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801695:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80169a:	89 d0                	mov    %edx,%eax
  80169c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8016b1:	e8 a2 fd ff ff       	call   801458 <fsipc>
}
  8016b6:	c9                   	leave  
  8016b7:	c3                   	ret    

008016b8 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016c0:	83 ec 0c             	sub    $0xc,%esp
  8016c3:	ff 75 08             	pushl  0x8(%ebp)
  8016c6:	e8 ef f7 ff ff       	call   800eba <fd2data>
  8016cb:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016cd:	83 c4 08             	add    $0x8,%esp
  8016d0:	68 4b 24 80 00       	push   $0x80244b
  8016d5:	53                   	push   %ebx
  8016d6:	e8 b5 f1 ff ff       	call   800890 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016db:	8b 56 04             	mov    0x4(%esi),%edx
  8016de:	89 d0                	mov    %edx,%eax
  8016e0:	2b 06                	sub    (%esi),%eax
  8016e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016ef:	00 00 00 
	stat->st_dev = &devpipe;
  8016f2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016f9:	30 80 00 
	return 0;
}
  8016fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801701:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801704:	5b                   	pop    %ebx
  801705:	5e                   	pop    %esi
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	53                   	push   %ebx
  80170c:	83 ec 0c             	sub    $0xc,%esp
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801712:	53                   	push   %ebx
  801713:	6a 00                	push   $0x0
  801715:	e8 05 f6 ff ff       	call   800d1f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80171a:	89 1c 24             	mov    %ebx,(%esp)
  80171d:	e8 98 f7 ff ff       	call   800eba <fd2data>
  801722:	83 c4 08             	add    $0x8,%esp
  801725:	50                   	push   %eax
  801726:	6a 00                	push   $0x0
  801728:	e8 f2 f5 ff ff       	call   800d1f <sys_page_unmap>
}
  80172d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801730:	c9                   	leave  
  801731:	c3                   	ret    

00801732 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801732:	55                   	push   %ebp
  801733:	89 e5                	mov    %esp,%ebp
  801735:	57                   	push   %edi
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	83 ec 1c             	sub    $0x1c,%esp
  80173b:	89 c7                	mov    %eax,%edi
  80173d:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80173f:	a1 04 40 80 00       	mov    0x804004,%eax
  801744:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801747:	83 ec 0c             	sub    $0xc,%esp
  80174a:	57                   	push   %edi
  80174b:	e8 2e 05 00 00       	call   801c7e <pageref>
  801750:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801753:	89 34 24             	mov    %esi,(%esp)
  801756:	e8 23 05 00 00       	call   801c7e <pageref>
  80175b:	83 c4 10             	add    $0x10,%esp
  80175e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801761:	0f 94 c0             	sete   %al
  801764:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801767:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80176d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801770:	39 cb                	cmp    %ecx,%ebx
  801772:	74 15                	je     801789 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801774:	8b 52 58             	mov    0x58(%edx),%edx
  801777:	50                   	push   %eax
  801778:	52                   	push   %edx
  801779:	53                   	push   %ebx
  80177a:	68 58 24 80 00       	push   $0x802458
  80177f:	e8 88 eb ff ff       	call   80030c <cprintf>
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	eb b6                	jmp    80173f <_pipeisclosed+0xd>
	}
}
  801789:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	5f                   	pop    %edi
  80178f:	5d                   	pop    %ebp
  801790:	c3                   	ret    

00801791 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	57                   	push   %edi
  801795:	56                   	push   %esi
  801796:	53                   	push   %ebx
  801797:	83 ec 28             	sub    $0x28,%esp
  80179a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80179d:	56                   	push   %esi
  80179e:	e8 17 f7 ff ff       	call   800eba <fd2data>
  8017a3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	bf 00 00 00 00       	mov    $0x0,%edi
  8017ad:	eb 4b                	jmp    8017fa <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8017af:	89 da                	mov    %ebx,%edx
  8017b1:	89 f0                	mov    %esi,%eax
  8017b3:	e8 7a ff ff ff       	call   801732 <_pipeisclosed>
  8017b8:	85 c0                	test   %eax,%eax
  8017ba:	75 48                	jne    801804 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8017bc:	e8 ba f4 ff ff       	call   800c7b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017c1:	8b 43 04             	mov    0x4(%ebx),%eax
  8017c4:	8b 0b                	mov    (%ebx),%ecx
  8017c6:	8d 51 20             	lea    0x20(%ecx),%edx
  8017c9:	39 d0                	cmp    %edx,%eax
  8017cb:	73 e2                	jae    8017af <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017d0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017d4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017d7:	89 c2                	mov    %eax,%edx
  8017d9:	c1 fa 1f             	sar    $0x1f,%edx
  8017dc:	89 d1                	mov    %edx,%ecx
  8017de:	c1 e9 1b             	shr    $0x1b,%ecx
  8017e1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017e4:	83 e2 1f             	and    $0x1f,%edx
  8017e7:	29 ca                	sub    %ecx,%edx
  8017e9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017ed:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8017f1:	83 c0 01             	add    $0x1,%eax
  8017f4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017f7:	83 c7 01             	add    $0x1,%edi
  8017fa:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017fd:	75 c2                	jne    8017c1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8017ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801802:	eb 05                	jmp    801809 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801804:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801809:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80180c:	5b                   	pop    %ebx
  80180d:	5e                   	pop    %esi
  80180e:	5f                   	pop    %edi
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	57                   	push   %edi
  801815:	56                   	push   %esi
  801816:	53                   	push   %ebx
  801817:	83 ec 18             	sub    $0x18,%esp
  80181a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80181d:	57                   	push   %edi
  80181e:	e8 97 f6 ff ff       	call   800eba <fd2data>
  801823:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	bb 00 00 00 00       	mov    $0x0,%ebx
  80182d:	eb 3d                	jmp    80186c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80182f:	85 db                	test   %ebx,%ebx
  801831:	74 04                	je     801837 <devpipe_read+0x26>
				return i;
  801833:	89 d8                	mov    %ebx,%eax
  801835:	eb 44                	jmp    80187b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801837:	89 f2                	mov    %esi,%edx
  801839:	89 f8                	mov    %edi,%eax
  80183b:	e8 f2 fe ff ff       	call   801732 <_pipeisclosed>
  801840:	85 c0                	test   %eax,%eax
  801842:	75 32                	jne    801876 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801844:	e8 32 f4 ff ff       	call   800c7b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801849:	8b 06                	mov    (%esi),%eax
  80184b:	3b 46 04             	cmp    0x4(%esi),%eax
  80184e:	74 df                	je     80182f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801850:	99                   	cltd   
  801851:	c1 ea 1b             	shr    $0x1b,%edx
  801854:	01 d0                	add    %edx,%eax
  801856:	83 e0 1f             	and    $0x1f,%eax
  801859:	29 d0                	sub    %edx,%eax
  80185b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801860:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801863:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801866:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801869:	83 c3 01             	add    $0x1,%ebx
  80186c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  80186f:	75 d8                	jne    801849 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801871:	8b 45 10             	mov    0x10(%ebp),%eax
  801874:	eb 05                	jmp    80187b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  80187b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5e                   	pop    %esi
  801880:	5f                   	pop    %edi
  801881:	5d                   	pop    %ebp
  801882:	c3                   	ret    

00801883 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	56                   	push   %esi
  801887:	53                   	push   %ebx
  801888:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  80188b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188e:	50                   	push   %eax
  80188f:	e8 3d f6 ff ff       	call   800ed1 <fd_alloc>
  801894:	83 c4 10             	add    $0x10,%esp
  801897:	89 c2                	mov    %eax,%edx
  801899:	85 c0                	test   %eax,%eax
  80189b:	0f 88 2c 01 00 00    	js     8019cd <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a1:	83 ec 04             	sub    $0x4,%esp
  8018a4:	68 07 04 00 00       	push   $0x407
  8018a9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ac:	6a 00                	push   $0x0
  8018ae:	e8 e7 f3 ff ff       	call   800c9a <sys_page_alloc>
  8018b3:	83 c4 10             	add    $0x10,%esp
  8018b6:	89 c2                	mov    %eax,%edx
  8018b8:	85 c0                	test   %eax,%eax
  8018ba:	0f 88 0d 01 00 00    	js     8019cd <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8018c0:	83 ec 0c             	sub    $0xc,%esp
  8018c3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c6:	50                   	push   %eax
  8018c7:	e8 05 f6 ff ff       	call   800ed1 <fd_alloc>
  8018cc:	89 c3                	mov    %eax,%ebx
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	85 c0                	test   %eax,%eax
  8018d3:	0f 88 e2 00 00 00    	js     8019bb <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d9:	83 ec 04             	sub    $0x4,%esp
  8018dc:	68 07 04 00 00       	push   $0x407
  8018e1:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e4:	6a 00                	push   $0x0
  8018e6:	e8 af f3 ff ff       	call   800c9a <sys_page_alloc>
  8018eb:	89 c3                	mov    %eax,%ebx
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	0f 88 c3 00 00 00    	js     8019bb <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8018f8:	83 ec 0c             	sub    $0xc,%esp
  8018fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8018fe:	e8 b7 f5 ff ff       	call   800eba <fd2data>
  801903:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801905:	83 c4 0c             	add    $0xc,%esp
  801908:	68 07 04 00 00       	push   $0x407
  80190d:	50                   	push   %eax
  80190e:	6a 00                	push   $0x0
  801910:	e8 85 f3 ff ff       	call   800c9a <sys_page_alloc>
  801915:	89 c3                	mov    %eax,%ebx
  801917:	83 c4 10             	add    $0x10,%esp
  80191a:	85 c0                	test   %eax,%eax
  80191c:	0f 88 89 00 00 00    	js     8019ab <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801922:	83 ec 0c             	sub    $0xc,%esp
  801925:	ff 75 f0             	pushl  -0x10(%ebp)
  801928:	e8 8d f5 ff ff       	call   800eba <fd2data>
  80192d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801934:	50                   	push   %eax
  801935:	6a 00                	push   $0x0
  801937:	56                   	push   %esi
  801938:	6a 00                	push   $0x0
  80193a:	e8 9e f3 ff ff       	call   800cdd <sys_page_map>
  80193f:	89 c3                	mov    %eax,%ebx
  801941:	83 c4 20             	add    $0x20,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	78 55                	js     80199d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801948:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80194e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801951:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801953:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801956:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80195d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801963:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801966:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801968:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	ff 75 f4             	pushl  -0xc(%ebp)
  801978:	e8 2d f5 ff ff       	call   800eaa <fd2num>
  80197d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801980:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801982:	83 c4 04             	add    $0x4,%esp
  801985:	ff 75 f0             	pushl  -0x10(%ebp)
  801988:	e8 1d f5 ff ff       	call   800eaa <fd2num>
  80198d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801990:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801993:	83 c4 10             	add    $0x10,%esp
  801996:	ba 00 00 00 00       	mov    $0x0,%edx
  80199b:	eb 30                	jmp    8019cd <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  80199d:	83 ec 08             	sub    $0x8,%esp
  8019a0:	56                   	push   %esi
  8019a1:	6a 00                	push   $0x0
  8019a3:	e8 77 f3 ff ff       	call   800d1f <sys_page_unmap>
  8019a8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b1:	6a 00                	push   $0x0
  8019b3:	e8 67 f3 ff ff       	call   800d1f <sys_page_unmap>
  8019b8:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	ff 75 f4             	pushl  -0xc(%ebp)
  8019c1:	6a 00                	push   $0x0
  8019c3:	e8 57 f3 ff ff       	call   800d1f <sys_page_unmap>
  8019c8:	83 c4 10             	add    $0x10,%esp
  8019cb:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8019cd:	89 d0                	mov    %edx,%eax
  8019cf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019d2:	5b                   	pop    %ebx
  8019d3:	5e                   	pop    %esi
  8019d4:	5d                   	pop    %ebp
  8019d5:	c3                   	ret    

008019d6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019df:	50                   	push   %eax
  8019e0:	ff 75 08             	pushl  0x8(%ebp)
  8019e3:	e8 38 f5 ff ff       	call   800f20 <fd_lookup>
  8019e8:	89 c2                	mov    %eax,%edx
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	85 d2                	test   %edx,%edx
  8019ef:	78 18                	js     801a09 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8019f1:	83 ec 0c             	sub    $0xc,%esp
  8019f4:	ff 75 f4             	pushl  -0xc(%ebp)
  8019f7:	e8 be f4 ff ff       	call   800eba <fd2data>
	return _pipeisclosed(fd, p);
  8019fc:	89 c2                	mov    %eax,%edx
  8019fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a01:	e8 2c fd ff ff       	call   801732 <_pipeisclosed>
  801a06:	83 c4 10             	add    $0x10,%esp
}
  801a09:	c9                   	leave  
  801a0a:	c3                   	ret    

00801a0b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a0b:	55                   	push   %ebp
  801a0c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801a0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    

00801a15 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a15:	55                   	push   %ebp
  801a16:	89 e5                	mov    %esp,%ebp
  801a18:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a1b:	68 8c 24 80 00       	push   $0x80248c
  801a20:	ff 75 0c             	pushl  0xc(%ebp)
  801a23:	e8 68 ee ff ff       	call   800890 <strcpy>
	return 0;
}
  801a28:	b8 00 00 00 00       	mov    $0x0,%eax
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	57                   	push   %edi
  801a33:	56                   	push   %esi
  801a34:	53                   	push   %ebx
  801a35:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a3b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a40:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a46:	eb 2e                	jmp    801a76 <devcons_write+0x47>
		m = n - tot;
  801a48:	8b 55 10             	mov    0x10(%ebp),%edx
  801a4b:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801a4d:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801a52:	83 fa 7f             	cmp    $0x7f,%edx
  801a55:	77 02                	ja     801a59 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801a57:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801a59:	83 ec 04             	sub    $0x4,%esp
  801a5c:	56                   	push   %esi
  801a5d:	03 45 0c             	add    0xc(%ebp),%eax
  801a60:	50                   	push   %eax
  801a61:	57                   	push   %edi
  801a62:	e8 bb ef ff ff       	call   800a22 <memmove>
		sys_cputs(buf, m);
  801a67:	83 c4 08             	add    $0x8,%esp
  801a6a:	56                   	push   %esi
  801a6b:	57                   	push   %edi
  801a6c:	e8 6d f1 ff ff       	call   800bde <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801a71:	01 f3                	add    %esi,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	89 d8                	mov    %ebx,%eax
  801a78:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a7b:	72 cb                	jb     801a48 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801a7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5f                   	pop    %edi
  801a83:	5d                   	pop    %ebp
  801a84:	c3                   	ret    

00801a85 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801a85:	55                   	push   %ebp
  801a86:	89 e5                	mov    %esp,%ebp
  801a88:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801a8b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801a90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a94:	75 07                	jne    801a9d <devcons_read+0x18>
  801a96:	eb 28                	jmp    801ac0 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801a98:	e8 de f1 ff ff       	call   800c7b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801a9d:	e8 5a f1 ff ff       	call   800bfc <sys_cgetc>
  801aa2:	85 c0                	test   %eax,%eax
  801aa4:	74 f2                	je     801a98 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801aa6:	85 c0                	test   %eax,%eax
  801aa8:	78 16                	js     801ac0 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801aaa:	83 f8 04             	cmp    $0x4,%eax
  801aad:	74 0c                	je     801abb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801aaf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ab2:	88 02                	mov    %al,(%edx)
	return 1;
  801ab4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab9:	eb 05                	jmp    801ac0 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801ac0:	c9                   	leave  
  801ac1:	c3                   	ret    

00801ac2 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  801acb:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ace:	6a 01                	push   $0x1
  801ad0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad3:	50                   	push   %eax
  801ad4:	e8 05 f1 ff ff       	call   800bde <sys_cputs>
  801ad9:	83 c4 10             	add    $0x10,%esp
}
  801adc:	c9                   	leave  
  801add:	c3                   	ret    

00801ade <getchar>:

int
getchar(void)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ae4:	6a 01                	push   $0x1
  801ae6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ae9:	50                   	push   %eax
  801aea:	6a 00                	push   $0x0
  801aec:	e8 98 f6 ff ff       	call   801189 <read>
	if (r < 0)
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 0f                	js     801b07 <getchar+0x29>
		return r;
	if (r < 1)
  801af8:	85 c0                	test   %eax,%eax
  801afa:	7e 06                	jle    801b02 <getchar+0x24>
		return -E_EOF;
	return c;
  801afc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801b00:	eb 05                	jmp    801b07 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801b02:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801b07:	c9                   	leave  
  801b08:	c3                   	ret    

00801b09 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801b09:	55                   	push   %ebp
  801b0a:	89 e5                	mov    %esp,%ebp
  801b0c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b12:	50                   	push   %eax
  801b13:	ff 75 08             	pushl  0x8(%ebp)
  801b16:	e8 05 f4 ff ff       	call   800f20 <fd_lookup>
  801b1b:	83 c4 10             	add    $0x10,%esp
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	78 11                	js     801b33 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b25:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b2b:	39 10                	cmp    %edx,(%eax)
  801b2d:	0f 94 c0             	sete   %al
  801b30:	0f b6 c0             	movzbl %al,%eax
}
  801b33:	c9                   	leave  
  801b34:	c3                   	ret    

00801b35 <opencons>:

int
opencons(void)
{
  801b35:	55                   	push   %ebp
  801b36:	89 e5                	mov    %esp,%ebp
  801b38:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b3e:	50                   	push   %eax
  801b3f:	e8 8d f3 ff ff       	call   800ed1 <fd_alloc>
  801b44:	83 c4 10             	add    $0x10,%esp
		return r;
  801b47:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 3e                	js     801b8b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b4d:	83 ec 04             	sub    $0x4,%esp
  801b50:	68 07 04 00 00       	push   $0x407
  801b55:	ff 75 f4             	pushl  -0xc(%ebp)
  801b58:	6a 00                	push   $0x0
  801b5a:	e8 3b f1 ff ff       	call   800c9a <sys_page_alloc>
  801b5f:	83 c4 10             	add    $0x10,%esp
		return r;
  801b62:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 23                	js     801b8b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801b68:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b71:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b73:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b76:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b7d:	83 ec 0c             	sub    $0xc,%esp
  801b80:	50                   	push   %eax
  801b81:	e8 24 f3 ff ff       	call   800eaa <fd2num>
  801b86:	89 c2                	mov    %eax,%edx
  801b88:	83 c4 10             	add    $0x10,%esp
}
  801b8b:	89 d0                	mov    %edx,%eax
  801b8d:	c9                   	leave  
  801b8e:	c3                   	ret    

00801b8f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b8f:	55                   	push   %ebp
  801b90:	89 e5                	mov    %esp,%ebp
  801b92:	56                   	push   %esi
  801b93:	53                   	push   %ebx
  801b94:	8b 75 08             	mov    0x8(%ebp),%esi
  801b97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801b9d:	85 f6                	test   %esi,%esi
  801b9f:	74 06                	je     801ba7 <ipc_recv+0x18>
  801ba1:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801ba7:	85 db                	test   %ebx,%ebx
  801ba9:	74 06                	je     801bb1 <ipc_recv+0x22>
  801bab:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801bb1:	83 f8 01             	cmp    $0x1,%eax
  801bb4:	19 d2                	sbb    %edx,%edx
  801bb6:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801bb8:	83 ec 0c             	sub    $0xc,%esp
  801bbb:	50                   	push   %eax
  801bbc:	e8 89 f2 ff ff       	call   800e4a <sys_ipc_recv>
  801bc1:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 d2                	test   %edx,%edx
  801bc8:	75 24                	jne    801bee <ipc_recv+0x5f>
	if (from_env_store)
  801bca:	85 f6                	test   %esi,%esi
  801bcc:	74 0a                	je     801bd8 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801bce:	a1 04 40 80 00       	mov    0x804004,%eax
  801bd3:	8b 40 70             	mov    0x70(%eax),%eax
  801bd6:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801bd8:	85 db                	test   %ebx,%ebx
  801bda:	74 0a                	je     801be6 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801bdc:	a1 04 40 80 00       	mov    0x804004,%eax
  801be1:	8b 40 74             	mov    0x74(%eax),%eax
  801be4:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801be6:	a1 04 40 80 00       	mov    0x804004,%eax
  801beb:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801bee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	57                   	push   %edi
  801bf9:	56                   	push   %esi
  801bfa:	53                   	push   %ebx
  801bfb:	83 ec 0c             	sub    $0xc,%esp
  801bfe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801c01:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c04:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801c07:	83 fb 01             	cmp    $0x1,%ebx
  801c0a:	19 c0                	sbb    %eax,%eax
  801c0c:	09 c3                	or     %eax,%ebx
  801c0e:	eb 1c                	jmp    801c2c <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801c10:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c13:	74 12                	je     801c27 <ipc_send+0x32>
  801c15:	50                   	push   %eax
  801c16:	68 98 24 80 00       	push   $0x802498
  801c1b:	6a 36                	push   $0x36
  801c1d:	68 af 24 80 00       	push   $0x8024af
  801c22:	e8 0c e6 ff ff       	call   800233 <_panic>
		sys_yield();
  801c27:	e8 4f f0 ff ff       	call   800c7b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801c2c:	ff 75 14             	pushl  0x14(%ebp)
  801c2f:	53                   	push   %ebx
  801c30:	56                   	push   %esi
  801c31:	57                   	push   %edi
  801c32:	e8 f0 f1 ff ff       	call   800e27 <sys_ipc_try_send>
		if (ret == 0) break;
  801c37:	83 c4 10             	add    $0x10,%esp
  801c3a:	85 c0                	test   %eax,%eax
  801c3c:	75 d2                	jne    801c10 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801c3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5f                   	pop    %edi
  801c44:	5d                   	pop    %ebp
  801c45:	c3                   	ret    

00801c46 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c4c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c51:	6b d0 78             	imul   $0x78,%eax,%edx
  801c54:	83 c2 50             	add    $0x50,%edx
  801c57:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801c5d:	39 ca                	cmp    %ecx,%edx
  801c5f:	75 0d                	jne    801c6e <ipc_find_env+0x28>
			return envs[i].env_id;
  801c61:	6b c0 78             	imul   $0x78,%eax,%eax
  801c64:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801c69:	8b 40 08             	mov    0x8(%eax),%eax
  801c6c:	eb 0e                	jmp    801c7c <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c6e:	83 c0 01             	add    $0x1,%eax
  801c71:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c76:	75 d9                	jne    801c51 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c78:	66 b8 00 00          	mov    $0x0,%ax
}
  801c7c:	5d                   	pop    %ebp
  801c7d:	c3                   	ret    

00801c7e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c84:	89 d0                	mov    %edx,%eax
  801c86:	c1 e8 16             	shr    $0x16,%eax
  801c89:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c90:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c95:	f6 c1 01             	test   $0x1,%cl
  801c98:	74 1d                	je     801cb7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c9a:	c1 ea 0c             	shr    $0xc,%edx
  801c9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ca4:	f6 c2 01             	test   $0x1,%dl
  801ca7:	74 0e                	je     801cb7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ca9:	c1 ea 0c             	shr    $0xc,%edx
  801cac:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801cb3:	ef 
  801cb4:	0f b7 c0             	movzwl %ax,%eax
}
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    
  801cb9:	66 90                	xchg   %ax,%ax
  801cbb:	66 90                	xchg   %ax,%ax
  801cbd:	66 90                	xchg   %ax,%ax
  801cbf:	90                   	nop

00801cc0 <__udivdi3>:
  801cc0:	55                   	push   %ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	83 ec 10             	sub    $0x10,%esp
  801cc6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801cca:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801cce:	8b 74 24 24          	mov    0x24(%esp),%esi
  801cd2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801cd6:	85 d2                	test   %edx,%edx
  801cd8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801cdc:	89 34 24             	mov    %esi,(%esp)
  801cdf:	89 c8                	mov    %ecx,%eax
  801ce1:	75 35                	jne    801d18 <__udivdi3+0x58>
  801ce3:	39 f1                	cmp    %esi,%ecx
  801ce5:	0f 87 bd 00 00 00    	ja     801da8 <__udivdi3+0xe8>
  801ceb:	85 c9                	test   %ecx,%ecx
  801ced:	89 cd                	mov    %ecx,%ebp
  801cef:	75 0b                	jne    801cfc <__udivdi3+0x3c>
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	31 d2                	xor    %edx,%edx
  801cf8:	f7 f1                	div    %ecx
  801cfa:	89 c5                	mov    %eax,%ebp
  801cfc:	89 f0                	mov    %esi,%eax
  801cfe:	31 d2                	xor    %edx,%edx
  801d00:	f7 f5                	div    %ebp
  801d02:	89 c6                	mov    %eax,%esi
  801d04:	89 f8                	mov    %edi,%eax
  801d06:	f7 f5                	div    %ebp
  801d08:	89 f2                	mov    %esi,%edx
  801d0a:	83 c4 10             	add    $0x10,%esp
  801d0d:	5e                   	pop    %esi
  801d0e:	5f                   	pop    %edi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    
  801d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d18:	3b 14 24             	cmp    (%esp),%edx
  801d1b:	77 7b                	ja     801d98 <__udivdi3+0xd8>
  801d1d:	0f bd f2             	bsr    %edx,%esi
  801d20:	83 f6 1f             	xor    $0x1f,%esi
  801d23:	0f 84 97 00 00 00    	je     801dc0 <__udivdi3+0x100>
  801d29:	bd 20 00 00 00       	mov    $0x20,%ebp
  801d2e:	89 d7                	mov    %edx,%edi
  801d30:	89 f1                	mov    %esi,%ecx
  801d32:	29 f5                	sub    %esi,%ebp
  801d34:	d3 e7                	shl    %cl,%edi
  801d36:	89 c2                	mov    %eax,%edx
  801d38:	89 e9                	mov    %ebp,%ecx
  801d3a:	d3 ea                	shr    %cl,%edx
  801d3c:	89 f1                	mov    %esi,%ecx
  801d3e:	09 fa                	or     %edi,%edx
  801d40:	8b 3c 24             	mov    (%esp),%edi
  801d43:	d3 e0                	shl    %cl,%eax
  801d45:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d4f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d53:	89 fa                	mov    %edi,%edx
  801d55:	d3 ea                	shr    %cl,%edx
  801d57:	89 f1                	mov    %esi,%ecx
  801d59:	d3 e7                	shl    %cl,%edi
  801d5b:	89 e9                	mov    %ebp,%ecx
  801d5d:	d3 e8                	shr    %cl,%eax
  801d5f:	09 c7                	or     %eax,%edi
  801d61:	89 f8                	mov    %edi,%eax
  801d63:	f7 74 24 08          	divl   0x8(%esp)
  801d67:	89 d5                	mov    %edx,%ebp
  801d69:	89 c7                	mov    %eax,%edi
  801d6b:	f7 64 24 0c          	mull   0xc(%esp)
  801d6f:	39 d5                	cmp    %edx,%ebp
  801d71:	89 14 24             	mov    %edx,(%esp)
  801d74:	72 11                	jb     801d87 <__udivdi3+0xc7>
  801d76:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d7a:	89 f1                	mov    %esi,%ecx
  801d7c:	d3 e2                	shl    %cl,%edx
  801d7e:	39 c2                	cmp    %eax,%edx
  801d80:	73 5e                	jae    801de0 <__udivdi3+0x120>
  801d82:	3b 2c 24             	cmp    (%esp),%ebp
  801d85:	75 59                	jne    801de0 <__udivdi3+0x120>
  801d87:	8d 47 ff             	lea    -0x1(%edi),%eax
  801d8a:	31 f6                	xor    %esi,%esi
  801d8c:	89 f2                	mov    %esi,%edx
  801d8e:	83 c4 10             	add    $0x10,%esp
  801d91:	5e                   	pop    %esi
  801d92:	5f                   	pop    %edi
  801d93:	5d                   	pop    %ebp
  801d94:	c3                   	ret    
  801d95:	8d 76 00             	lea    0x0(%esi),%esi
  801d98:	31 f6                	xor    %esi,%esi
  801d9a:	31 c0                	xor    %eax,%eax
  801d9c:	89 f2                	mov    %esi,%edx
  801d9e:	83 c4 10             	add    $0x10,%esp
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	89 f2                	mov    %esi,%edx
  801daa:	31 f6                	xor    %esi,%esi
  801dac:	89 f8                	mov    %edi,%eax
  801dae:	f7 f1                	div    %ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	83 c4 10             	add    $0x10,%esp
  801db5:	5e                   	pop    %esi
  801db6:	5f                   	pop    %edi
  801db7:	5d                   	pop    %ebp
  801db8:	c3                   	ret    
  801db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801dc4:	76 0b                	jbe    801dd1 <__udivdi3+0x111>
  801dc6:	31 c0                	xor    %eax,%eax
  801dc8:	3b 14 24             	cmp    (%esp),%edx
  801dcb:	0f 83 37 ff ff ff    	jae    801d08 <__udivdi3+0x48>
  801dd1:	b8 01 00 00 00       	mov    $0x1,%eax
  801dd6:	e9 2d ff ff ff       	jmp    801d08 <__udivdi3+0x48>
  801ddb:	90                   	nop
  801ddc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801de0:	89 f8                	mov    %edi,%eax
  801de2:	31 f6                	xor    %esi,%esi
  801de4:	e9 1f ff ff ff       	jmp    801d08 <__udivdi3+0x48>
  801de9:	66 90                	xchg   %ax,%ax
  801deb:	66 90                	xchg   %ax,%ax
  801ded:	66 90                	xchg   %ax,%ax
  801def:	90                   	nop

00801df0 <__umoddi3>:
  801df0:	55                   	push   %ebp
  801df1:	57                   	push   %edi
  801df2:	56                   	push   %esi
  801df3:	83 ec 20             	sub    $0x20,%esp
  801df6:	8b 44 24 34          	mov    0x34(%esp),%eax
  801dfa:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801dfe:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801e02:	89 c6                	mov    %eax,%esi
  801e04:	89 44 24 10          	mov    %eax,0x10(%esp)
  801e08:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e0c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801e10:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e14:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e18:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e1c:	85 c0                	test   %eax,%eax
  801e1e:	89 c2                	mov    %eax,%edx
  801e20:	75 1e                	jne    801e40 <__umoddi3+0x50>
  801e22:	39 f7                	cmp    %esi,%edi
  801e24:	76 52                	jbe    801e78 <__umoddi3+0x88>
  801e26:	89 c8                	mov    %ecx,%eax
  801e28:	89 f2                	mov    %esi,%edx
  801e2a:	f7 f7                	div    %edi
  801e2c:	89 d0                	mov    %edx,%eax
  801e2e:	31 d2                	xor    %edx,%edx
  801e30:	83 c4 20             	add    $0x20,%esp
  801e33:	5e                   	pop    %esi
  801e34:	5f                   	pop    %edi
  801e35:	5d                   	pop    %ebp
  801e36:	c3                   	ret    
  801e37:	89 f6                	mov    %esi,%esi
  801e39:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801e40:	39 f0                	cmp    %esi,%eax
  801e42:	77 5c                	ja     801ea0 <__umoddi3+0xb0>
  801e44:	0f bd e8             	bsr    %eax,%ebp
  801e47:	83 f5 1f             	xor    $0x1f,%ebp
  801e4a:	75 64                	jne    801eb0 <__umoddi3+0xc0>
  801e4c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801e50:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801e54:	0f 86 f6 00 00 00    	jbe    801f50 <__umoddi3+0x160>
  801e5a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801e5e:	0f 82 ec 00 00 00    	jb     801f50 <__umoddi3+0x160>
  801e64:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e68:	8b 54 24 18          	mov    0x18(%esp),%edx
  801e6c:	83 c4 20             	add    $0x20,%esp
  801e6f:	5e                   	pop    %esi
  801e70:	5f                   	pop    %edi
  801e71:	5d                   	pop    %ebp
  801e72:	c3                   	ret    
  801e73:	90                   	nop
  801e74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e78:	85 ff                	test   %edi,%edi
  801e7a:	89 fd                	mov    %edi,%ebp
  801e7c:	75 0b                	jne    801e89 <__umoddi3+0x99>
  801e7e:	b8 01 00 00 00       	mov    $0x1,%eax
  801e83:	31 d2                	xor    %edx,%edx
  801e85:	f7 f7                	div    %edi
  801e87:	89 c5                	mov    %eax,%ebp
  801e89:	8b 44 24 10          	mov    0x10(%esp),%eax
  801e8d:	31 d2                	xor    %edx,%edx
  801e8f:	f7 f5                	div    %ebp
  801e91:	89 c8                	mov    %ecx,%eax
  801e93:	f7 f5                	div    %ebp
  801e95:	eb 95                	jmp    801e2c <__umoddi3+0x3c>
  801e97:	89 f6                	mov    %esi,%esi
  801e99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ea0:	89 c8                	mov    %ecx,%eax
  801ea2:	89 f2                	mov    %esi,%edx
  801ea4:	83 c4 20             	add    $0x20,%esp
  801ea7:	5e                   	pop    %esi
  801ea8:	5f                   	pop    %edi
  801ea9:	5d                   	pop    %ebp
  801eaa:	c3                   	ret    
  801eab:	90                   	nop
  801eac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801eb0:	b8 20 00 00 00       	mov    $0x20,%eax
  801eb5:	89 e9                	mov    %ebp,%ecx
  801eb7:	29 e8                	sub    %ebp,%eax
  801eb9:	d3 e2                	shl    %cl,%edx
  801ebb:	89 c7                	mov    %eax,%edi
  801ebd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801ec1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ec5:	89 f9                	mov    %edi,%ecx
  801ec7:	d3 e8                	shr    %cl,%eax
  801ec9:	89 c1                	mov    %eax,%ecx
  801ecb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ecf:	09 d1                	or     %edx,%ecx
  801ed1:	89 fa                	mov    %edi,%edx
  801ed3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801ed7:	89 e9                	mov    %ebp,%ecx
  801ed9:	d3 e0                	shl    %cl,%eax
  801edb:	89 f9                	mov    %edi,%ecx
  801edd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ee1:	89 f0                	mov    %esi,%eax
  801ee3:	d3 e8                	shr    %cl,%eax
  801ee5:	89 e9                	mov    %ebp,%ecx
  801ee7:	89 c7                	mov    %eax,%edi
  801ee9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801eed:	d3 e6                	shl    %cl,%esi
  801eef:	89 d1                	mov    %edx,%ecx
  801ef1:	89 fa                	mov    %edi,%edx
  801ef3:	d3 e8                	shr    %cl,%eax
  801ef5:	89 e9                	mov    %ebp,%ecx
  801ef7:	09 f0                	or     %esi,%eax
  801ef9:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801efd:	f7 74 24 10          	divl   0x10(%esp)
  801f01:	d3 e6                	shl    %cl,%esi
  801f03:	89 d1                	mov    %edx,%ecx
  801f05:	f7 64 24 0c          	mull   0xc(%esp)
  801f09:	39 d1                	cmp    %edx,%ecx
  801f0b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801f0f:	89 d7                	mov    %edx,%edi
  801f11:	89 c6                	mov    %eax,%esi
  801f13:	72 0a                	jb     801f1f <__umoddi3+0x12f>
  801f15:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801f19:	73 10                	jae    801f2b <__umoddi3+0x13b>
  801f1b:	39 d1                	cmp    %edx,%ecx
  801f1d:	75 0c                	jne    801f2b <__umoddi3+0x13b>
  801f1f:	89 d7                	mov    %edx,%edi
  801f21:	89 c6                	mov    %eax,%esi
  801f23:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801f27:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801f2b:	89 ca                	mov    %ecx,%edx
  801f2d:	89 e9                	mov    %ebp,%ecx
  801f2f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801f33:	29 f0                	sub    %esi,%eax
  801f35:	19 fa                	sbb    %edi,%edx
  801f37:	d3 e8                	shr    %cl,%eax
  801f39:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801f3e:	89 d7                	mov    %edx,%edi
  801f40:	d3 e7                	shl    %cl,%edi
  801f42:	89 e9                	mov    %ebp,%ecx
  801f44:	09 f8                	or     %edi,%eax
  801f46:	d3 ea                	shr    %cl,%edx
  801f48:	83 c4 20             	add    $0x20,%esp
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    
  801f4f:	90                   	nop
  801f50:	8b 74 24 10          	mov    0x10(%esp),%esi
  801f54:	29 f9                	sub    %edi,%ecx
  801f56:	19 c6                	sbb    %eax,%esi
  801f58:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f5c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801f60:	e9 ff fe ff ff       	jmp    801e64 <__umoddi3+0x74>
