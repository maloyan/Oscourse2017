
obj/user/memlayout:     file format elf32-i386


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
  80002c:	e8 53 02 00 00       	call   800284 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <memlayout>:
#define PTE_SHARE 0x400
#endif    // PTE_SHARE

void
memlayout(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 40             	sub    $0x40,%esp
	int total_p = 0;
	int total_u = 0;
	int total_w = 0;
	int total_cow = 0;

	cprintf("EID: %d, PEID: %d\n", thisenv->env_id, thisenv->env_parent_id);
  80003c:	a1 04 40 80 00       	mov    0x804004,%eax
  800041:	8b 50 4c             	mov    0x4c(%eax),%edx
  800044:	8b 40 48             	mov    0x48(%eax),%eax
  800047:	52                   	push   %edx
  800048:	50                   	push   %eax
  800049:	68 cc 23 80 00       	push   $0x8023cc
  80004e:	e8 6a 03 00 00       	call   8003bd <cprintf>
	cprintf("pgdir: %p, uvpd: %p, uvpt: %p\n",
			thisenv->env_pgdir, uvpd, uvpt);
  800053:	a1 04 40 80 00       	mov    0x804004,%eax
	int total_u = 0;
	int total_w = 0;
	int total_cow = 0;

	cprintf("EID: %d, PEID: %d\n", thisenv->env_id, thisenv->env_parent_id);
	cprintf("pgdir: %p, uvpd: %p, uvpt: %p\n",
  800058:	8b 40 5c             	mov    0x5c(%eax),%eax
  80005b:	68 00 00 40 ef       	push   $0xef400000
  800060:	68 00 d0 7b ef       	push   $0xef7bd000
  800065:	50                   	push   %eax
  800066:	68 74 24 80 00       	push   $0x802474
  80006b:	e8 4d 03 00 00       	call   8003bd <cprintf>
  800070:	c7 45 c0 00 00 40 ef 	movl   $0xef400000,-0x40(%ebp)
  800077:	83 c4 20             	add    $0x20,%esp
	pte_t *pgtab;
	int i, j;
	int total_p = 0;
	int total_u = 0;
	int total_w = 0;
	int total_cow = 0;
  80007a:	c7 45 c8 00 00 00 00 	movl   $0x0,-0x38(%ebp)
{
	pte_t *pgtab;
	int i, j;
	int total_p = 0;
	int total_u = 0;
	int total_w = 0;
  800081:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
memlayout(void)
{
	pte_t *pgtab;
	int i, j;
	int total_p = 0;
	int total_u = 0;
  800088:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
void
memlayout(void)
{
	pte_t *pgtab;
	int i, j;
	int total_p = 0;
  80008f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

	cprintf("EID: %d, PEID: %d\n", thisenv->env_id, thisenv->env_parent_id);
	cprintf("pgdir: %p, uvpd: %p, uvpt: %p\n",
			thisenv->env_pgdir, uvpd, uvpt);

	for (i = 0; i < NPDENTRIES; i++) {
  800096:	c7 45 c4 00 00 00 00 	movl   $0x0,-0x3c(%ebp)
		if ((uvpd[i] & PTE_P) == 0)
  80009d:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8000a0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8000a7:	a8 01                	test   $0x1,%al
  8000a9:	0f 84 c0 00 00 00    	je     80016f <memlayout+0x13c>
			continue;
		if (i >= PDX(KERNBASE))
  8000af:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  8000b2:	3d bf 03 00 00       	cmp    $0x3bf,%eax
  8000b7:	0f 87 cb 00 00 00    	ja     800188 <memlayout+0x155>
		pgtab = (pte_t *)uvpt + i * NPTENTRIES;
		for (j = 0; j < NPTENTRIES; j++) {
			if (pgtab[j] == 0)
				continue;
			cprintf("[%p] %p -> %08x: %c %c %c |%s%s\n",
					pgtab + j, PGADDR(i, j, 0), pgtab[j],
  8000bd:	c1 e0 16             	shl    $0x16,%eax
  8000c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8000c3:	8b 75 c0             	mov    -0x40(%ebp),%esi
		if ((uvpd[i] & PTE_P) == 0)
			continue;
		if (i >= PDX(KERNBASE))
			break;
		pgtab = (pte_t *)uvpt + i * NPTENTRIES;
		for (j = 0; j < NPTENTRIES; j++) {
  8000c6:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pgtab[j] == 0)
  8000cb:	89 f2                	mov    %esi,%edx
  8000cd:	8b 06                	mov    (%esi),%eax
  8000cf:	85 c0                	test   %eax,%eax
  8000d1:	0f 84 86 00 00 00    	je     80015d <memlayout+0x12a>
				continue;
			cprintf("[%p] %p -> %08x: %c %c %c |%s%s\n",
  8000d7:	c7 45 e4 c0 23 80 00 	movl   $0x8023c0,-0x1c(%ebp)
  8000de:	f6 c4 04             	test   $0x4,%ah
  8000e1:	75 07                	jne    8000ea <memlayout+0xb7>
  8000e3:	c7 45 e4 f5 23 80 00 	movl   $0x8023f5,-0x1c(%ebp)
  8000ea:	c7 45 e0 f5 23 80 00 	movl   $0x8023f5,-0x20(%ebp)
  8000f1:	f6 c4 08             	test   $0x8,%ah
  8000f4:	74 0b                	je     800101 <memlayout+0xce>
					pgtab + j, PGADDR(i, j, 0), pgtab[j],
					(pgtab[j] & PTE_P) ? total_p++, 'P' : '-',
					(pgtab[j] & PTE_U) ? total_u++, 'U' : '-',
					(pgtab[j] & PTE_W) ? total_w++, 'W' : '-',
					(pgtab[j] & PTE_COW) ? total_cow++, " COW" : "",
  8000f6:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
			break;
		pgtab = (pte_t *)uvpt + i * NPTENTRIES;
		for (j = 0; j < NPTENTRIES; j++) {
			if (pgtab[j] == 0)
				continue;
			cprintf("[%p] %p -> %08x: %c %c %c |%s%s\n",
  8000fa:	c7 45 e0 c7 23 80 00 	movl   $0x8023c7,-0x20(%ebp)
  800101:	bf 2d 00 00 00       	mov    $0x2d,%edi
  800106:	a8 02                	test   $0x2,%al
  800108:	74 08                	je     800112 <memlayout+0xdf>
					pgtab + j, PGADDR(i, j, 0), pgtab[j],
					(pgtab[j] & PTE_P) ? total_p++, 'P' : '-',
					(pgtab[j] & PTE_U) ? total_u++, 'U' : '-',
					(pgtab[j] & PTE_W) ? total_w++, 'W' : '-',
  80010a:	83 45 cc 01          	addl   $0x1,-0x34(%ebp)
			break;
		pgtab = (pte_t *)uvpt + i * NPTENTRIES;
		for (j = 0; j < NPTENTRIES; j++) {
			if (pgtab[j] == 0)
				continue;
			cprintf("[%p] %p -> %08x: %c %c %c |%s%s\n",
  80010e:	66 bf 57 00          	mov    $0x57,%di
  800112:	b9 2d 00 00 00       	mov    $0x2d,%ecx
  800117:	a8 04                	test   $0x4,%al
  800119:	74 06                	je     800121 <memlayout+0xee>
					pgtab + j, PGADDR(i, j, 0), pgtab[j],
					(pgtab[j] & PTE_P) ? total_p++, 'P' : '-',
					(pgtab[j] & PTE_U) ? total_u++, 'U' : '-',
  80011b:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
			break;
		pgtab = (pte_t *)uvpt + i * NPTENTRIES;
		for (j = 0; j < NPTENTRIES; j++) {
			if (pgtab[j] == 0)
				continue;
			cprintf("[%p] %p -> %08x: %c %c %c |%s%s\n",
  80011f:	b1 55                	mov    $0x55,%cl
  800121:	c7 45 dc 2d 00 00 00 	movl   $0x2d,-0x24(%ebp)
  800128:	a8 01                	test   $0x1,%al
  80012a:	74 0b                	je     800137 <memlayout+0x104>
					pgtab + j, PGADDR(i, j, 0), pgtab[j],
					(pgtab[j] & PTE_P) ? total_p++, 'P' : '-',
  80012c:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
			break;
		pgtab = (pte_t *)uvpt + i * NPTENTRIES;
		for (j = 0; j < NPTENTRIES; j++) {
			if (pgtab[j] == 0)
				continue;
			cprintf("[%p] %p -> %08x: %c %c %c |%s%s\n",
  800130:	c7 45 dc 50 00 00 00 	movl   $0x50,-0x24(%ebp)
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80013d:	ff 75 e0             	pushl  -0x20(%ebp)
  800140:	57                   	push   %edi
  800141:	51                   	push   %ecx
  800142:	ff 75 dc             	pushl  -0x24(%ebp)
  800145:	50                   	push   %eax
					pgtab + j, PGADDR(i, j, 0), pgtab[j],
  800146:	89 d8                	mov    %ebx,%eax
  800148:	c1 e0 0c             	shl    $0xc,%eax
  80014b:	0b 45 d8             	or     -0x28(%ebp),%eax
			break;
		pgtab = (pte_t *)uvpt + i * NPTENTRIES;
		for (j = 0; j < NPTENTRIES; j++) {
			if (pgtab[j] == 0)
				continue;
			cprintf("[%p] %p -> %08x: %c %c %c |%s%s\n",
  80014e:	50                   	push   %eax
  80014f:	52                   	push   %edx
  800150:	68 94 24 80 00       	push   $0x802494
  800155:	e8 63 02 00 00       	call   8003bd <cprintf>
  80015a:	83 c4 30             	add    $0x30,%esp
		if ((uvpd[i] & PTE_P) == 0)
			continue;
		if (i >= PDX(KERNBASE))
			break;
		pgtab = (pte_t *)uvpt + i * NPTENTRIES;
		for (j = 0; j < NPTENTRIES; j++) {
  80015d:	83 c3 01             	add    $0x1,%ebx
  800160:	83 c6 04             	add    $0x4,%esi
  800163:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  800169:	0f 85 5c ff ff ff    	jne    8000cb <memlayout+0x98>

	cprintf("EID: %d, PEID: %d\n", thisenv->env_id, thisenv->env_parent_id);
	cprintf("pgdir: %p, uvpd: %p, uvpt: %p\n",
			thisenv->env_pgdir, uvpd, uvpt);

	for (i = 0; i < NPDENTRIES; i++) {
  80016f:	83 45 c4 01          	addl   $0x1,-0x3c(%ebp)
  800173:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  800176:	81 45 c0 00 10 00 00 	addl   $0x1000,-0x40(%ebp)
  80017d:	3d 00 04 00 00       	cmp    $0x400,%eax
  800182:	0f 85 15 ff ff ff    	jne    80009d <memlayout+0x6a>
					(pgtab[j] & PTE_COW) ? total_cow++, " COW" : "",
					(pgtab[j] & PTE_SHARE) ? " SHARE" : "");
		}
	}

	cprintf("Memory usage summary:\n");
  800188:	83 ec 0c             	sub    $0xc,%esp
  80018b:	68 df 23 80 00       	push   $0x8023df
  800190:	e8 28 02 00 00       	call   8003bd <cprintf>
	cprintf("  PTE_P: %d\n", total_p);
  800195:	83 c4 08             	add    $0x8,%esp
  800198:	ff 75 d4             	pushl  -0x2c(%ebp)
  80019b:	68 f6 23 80 00       	push   $0x8023f6
  8001a0:	e8 18 02 00 00       	call   8003bd <cprintf>
	cprintf("  PTE_U: %d\n", total_u);
  8001a5:	83 c4 08             	add    $0x8,%esp
  8001a8:	ff 75 d0             	pushl  -0x30(%ebp)
  8001ab:	68 03 24 80 00       	push   $0x802403
  8001b0:	e8 08 02 00 00       	call   8003bd <cprintf>
	cprintf("  PTE_W: %d\n", total_w);
  8001b5:	83 c4 08             	add    $0x8,%esp
  8001b8:	ff 75 cc             	pushl  -0x34(%ebp)
  8001bb:	68 10 24 80 00       	push   $0x802410
  8001c0:	e8 f8 01 00 00       	call   8003bd <cprintf>
	cprintf("  PTE_COW: %d\n", total_cow);
  8001c5:	83 c4 08             	add    $0x8,%esp
  8001c8:	ff 75 c8             	pushl  -0x38(%ebp)
  8001cb:	68 1d 24 80 00       	push   $0x80241d
  8001d0:	e8 e8 01 00 00       	call   8003bd <cprintf>
  8001d5:	83 c4 10             	add    $0x10,%esp
}
  8001d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001db:	5b                   	pop    %ebx
  8001dc:	5e                   	pop    %esi
  8001dd:	5f                   	pop    %edi
  8001de:	5d                   	pop    %ebp
  8001df:	c3                   	ret    

008001e0 <umain>:

void
umain(int argc, char *argv[])
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	53                   	push   %ebx
  8001e4:	83 ec 14             	sub    $0x14,%esp
	envid_t ceid;
	int pipefd[2];
	int res;

	memlayout();
  8001e7:	e8 47 fe ff ff       	call   800033 <memlayout>

	res = pipe(pipefd);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 1f 1a 00 00       	call   801c17 <pipe>
	if (res < 0)
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	85 c0                	test   %eax,%eax
  8001fd:	79 14                	jns    800213 <umain+0x33>
		panic("pipe() failed\n");
  8001ff:	83 ec 04             	sub    $0x4,%esp
  800202:	68 2c 24 80 00       	push   $0x80242c
  800207:	6a 3d                	push   $0x3d
  800209:	68 3b 24 80 00       	push   $0x80243b
  80020e:	e8 d1 00 00 00       	call   8002e4 <_panic>
	ceid = fork();
  800213:	e8 3d 0e 00 00       	call   801055 <fork>
	if (ceid < 0)
  800218:	85 c0                	test   %eax,%eax
  80021a:	79 14                	jns    800230 <umain+0x50>
		panic("fork() failed\n");
  80021c:	83 ec 04             	sub    $0x4,%esp
  80021f:	68 4c 24 80 00       	push   $0x80244c
  800224:	6a 40                	push   $0x40
  800226:	68 3b 24 80 00       	push   $0x80243b
  80022b:	e8 b4 00 00 00       	call   8002e4 <_panic>

	if (ceid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 36                	jne    80026a <umain+0x8a>
		// Child environment
		int i;
		cprintf("\n");
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	68 f4 23 80 00       	push   $0x8023f4
  80023c:	e8 7c 01 00 00       	call   8003bd <cprintf>
  800241:	83 c4 10             	add    $0x10,%esp
  800244:	bb 00 90 01 00       	mov    $0x19000,%ebx
		for (i = 0; i < 102400; i++)
			sys_yield();
  800249:	e8 de 0a 00 00       	call   800d2c <sys_yield>

	if (ceid == 0) {
		// Child environment
		int i;
		cprintf("\n");
		for (i = 0; i < 102400; i++)
  80024e:	83 eb 01             	sub    $0x1,%ebx
  800251:	75 f6                	jne    800249 <umain+0x69>
			sys_yield();
		cprintf("==== Child\n");
  800253:	83 ec 0c             	sub    $0xc,%esp
  800256:	68 5b 24 80 00       	push   $0x80245b
  80025b:	e8 5d 01 00 00       	call   8003bd <cprintf>
		memlayout();
  800260:	e8 ce fd ff ff       	call   800033 <memlayout>
		return;
  800265:	83 c4 10             	add    $0x10,%esp
  800268:	eb 15                	jmp    80027f <umain+0x9f>
	}

	cprintf("==== Parent\n");
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	68 67 24 80 00       	push   $0x802467
  800272:	e8 46 01 00 00       	call   8003bd <cprintf>
	memlayout();
  800277:	e8 b7 fd ff ff       	call   800033 <memlayout>
  80027c:	83 c4 10             	add    $0x10,%esp

}
  80027f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800282:	c9                   	leave  
  800283:	c3                   	ret    

00800284 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	56                   	push   %esi
  800288:	53                   	push   %ebx
  800289:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80028c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80028f:	e8 79 0a 00 00       	call   800d0d <sys_getenvid>
  800294:	25 ff 03 00 00       	and    $0x3ff,%eax
  800299:	6b c0 78             	imul   $0x78,%eax,%eax
  80029c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002a1:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002a6:	85 db                	test   %ebx,%ebx
  8002a8:	7e 07                	jle    8002b1 <libmain+0x2d>
		binaryname = argv[0];
  8002aa:	8b 06                	mov    (%esi),%eax
  8002ac:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002b1:	83 ec 08             	sub    $0x8,%esp
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	e8 25 ff ff ff       	call   8001e0 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8002bb:	e8 0a 00 00 00       	call   8002ca <exit>
  8002c0:	83 c4 10             	add    $0x10,%esp
#endif
}
  8002c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c6:	5b                   	pop    %ebx
  8002c7:	5e                   	pop    %esi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    

008002ca <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002ca:	55                   	push   %ebp
  8002cb:	89 e5                	mov    %esp,%ebp
  8002cd:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002d0:	e8 35 11 00 00       	call   80140a <close_all>
	sys_env_destroy(0);
  8002d5:	83 ec 0c             	sub    $0xc,%esp
  8002d8:	6a 00                	push   $0x0
  8002da:	e8 ed 09 00 00       	call   800ccc <sys_env_destroy>
  8002df:	83 c4 10             	add    $0x10,%esp
}
  8002e2:	c9                   	leave  
  8002e3:	c3                   	ret    

008002e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002e4:	55                   	push   %ebp
  8002e5:	89 e5                	mov    %esp,%ebp
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002ec:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002f2:	e8 16 0a 00 00       	call   800d0d <sys_getenvid>
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	ff 75 0c             	pushl  0xc(%ebp)
  8002fd:	ff 75 08             	pushl  0x8(%ebp)
  800300:	56                   	push   %esi
  800301:	50                   	push   %eax
  800302:	68 c0 24 80 00       	push   $0x8024c0
  800307:	e8 b1 00 00 00       	call   8003bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80030c:	83 c4 18             	add    $0x18,%esp
  80030f:	53                   	push   %ebx
  800310:	ff 75 10             	pushl  0x10(%ebp)
  800313:	e8 54 00 00 00       	call   80036c <vcprintf>
	cprintf("\n");
  800318:	c7 04 24 f4 23 80 00 	movl   $0x8023f4,(%esp)
  80031f:	e8 99 00 00 00       	call   8003bd <cprintf>
  800324:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800327:	cc                   	int3   
  800328:	eb fd                	jmp    800327 <_panic+0x43>

0080032a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
  80032d:	53                   	push   %ebx
  80032e:	83 ec 04             	sub    $0x4,%esp
  800331:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800334:	8b 13                	mov    (%ebx),%edx
  800336:	8d 42 01             	lea    0x1(%edx),%eax
  800339:	89 03                	mov    %eax,(%ebx)
  80033b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80033e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800342:	3d ff 00 00 00       	cmp    $0xff,%eax
  800347:	75 1a                	jne    800363 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800349:	83 ec 08             	sub    $0x8,%esp
  80034c:	68 ff 00 00 00       	push   $0xff
  800351:	8d 43 08             	lea    0x8(%ebx),%eax
  800354:	50                   	push   %eax
  800355:	e8 35 09 00 00       	call   800c8f <sys_cputs>
		b->idx = 0;
  80035a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800360:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800363:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800367:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800375:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80037c:	00 00 00 
	b.cnt = 0;
  80037f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800386:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800389:	ff 75 0c             	pushl  0xc(%ebp)
  80038c:	ff 75 08             	pushl  0x8(%ebp)
  80038f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800395:	50                   	push   %eax
  800396:	68 2a 03 80 00       	push   $0x80032a
  80039b:	e8 4f 01 00 00       	call   8004ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003a0:	83 c4 08             	add    $0x8,%esp
  8003a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003af:	50                   	push   %eax
  8003b0:	e8 da 08 00 00       	call   800c8f <sys_cputs>

	return b.cnt;
}
  8003b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003bb:	c9                   	leave  
  8003bc:	c3                   	ret    

008003bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003c6:	50                   	push   %eax
  8003c7:	ff 75 08             	pushl  0x8(%ebp)
  8003ca:	e8 9d ff ff ff       	call   80036c <vcprintf>
	va_end(ap);

	return cnt;
}
  8003cf:	c9                   	leave  
  8003d0:	c3                   	ret    

008003d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	57                   	push   %edi
  8003d5:	56                   	push   %esi
  8003d6:	53                   	push   %ebx
  8003d7:	83 ec 1c             	sub    $0x1c,%esp
  8003da:	89 c7                	mov    %eax,%edi
  8003dc:	89 d6                	mov    %edx,%esi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e4:	89 d1                	mov    %edx,%ecx
  8003e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ef:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003f5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003fc:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8003ff:	72 05                	jb     800406 <printnum+0x35>
  800401:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800404:	77 3e                	ja     800444 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800406:	83 ec 0c             	sub    $0xc,%esp
  800409:	ff 75 18             	pushl  0x18(%ebp)
  80040c:	83 eb 01             	sub    $0x1,%ebx
  80040f:	53                   	push   %ebx
  800410:	50                   	push   %eax
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	ff 75 e4             	pushl  -0x1c(%ebp)
  800417:	ff 75 e0             	pushl  -0x20(%ebp)
  80041a:	ff 75 dc             	pushl  -0x24(%ebp)
  80041d:	ff 75 d8             	pushl  -0x28(%ebp)
  800420:	e8 cb 1c 00 00       	call   8020f0 <__udivdi3>
  800425:	83 c4 18             	add    $0x18,%esp
  800428:	52                   	push   %edx
  800429:	50                   	push   %eax
  80042a:	89 f2                	mov    %esi,%edx
  80042c:	89 f8                	mov    %edi,%eax
  80042e:	e8 9e ff ff ff       	call   8003d1 <printnum>
  800433:	83 c4 20             	add    $0x20,%esp
  800436:	eb 13                	jmp    80044b <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	56                   	push   %esi
  80043c:	ff 75 18             	pushl  0x18(%ebp)
  80043f:	ff d7                	call   *%edi
  800441:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800444:	83 eb 01             	sub    $0x1,%ebx
  800447:	85 db                	test   %ebx,%ebx
  800449:	7f ed                	jg     800438 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80044b:	83 ec 08             	sub    $0x8,%esp
  80044e:	56                   	push   %esi
  80044f:	83 ec 04             	sub    $0x4,%esp
  800452:	ff 75 e4             	pushl  -0x1c(%ebp)
  800455:	ff 75 e0             	pushl  -0x20(%ebp)
  800458:	ff 75 dc             	pushl  -0x24(%ebp)
  80045b:	ff 75 d8             	pushl  -0x28(%ebp)
  80045e:	e8 bd 1d 00 00       	call   802220 <__umoddi3>
  800463:	83 c4 14             	add    $0x14,%esp
  800466:	0f be 80 e3 24 80 00 	movsbl 0x8024e3(%eax),%eax
  80046d:	50                   	push   %eax
  80046e:	ff d7                	call   *%edi
  800470:	83 c4 10             	add    $0x10,%esp
}
  800473:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800476:	5b                   	pop    %ebx
  800477:	5e                   	pop    %esi
  800478:	5f                   	pop    %edi
  800479:	5d                   	pop    %ebp
  80047a:	c3                   	ret    

0080047b <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80047b:	55                   	push   %ebp
  80047c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80047e:	83 fa 01             	cmp    $0x1,%edx
  800481:	7e 0e                	jle    800491 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800483:	8b 10                	mov    (%eax),%edx
  800485:	8d 4a 08             	lea    0x8(%edx),%ecx
  800488:	89 08                	mov    %ecx,(%eax)
  80048a:	8b 02                	mov    (%edx),%eax
  80048c:	8b 52 04             	mov    0x4(%edx),%edx
  80048f:	eb 22                	jmp    8004b3 <getuint+0x38>
	else if (lflag)
  800491:	85 d2                	test   %edx,%edx
  800493:	74 10                	je     8004a5 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800495:	8b 10                	mov    (%eax),%edx
  800497:	8d 4a 04             	lea    0x4(%edx),%ecx
  80049a:	89 08                	mov    %ecx,(%eax)
  80049c:	8b 02                	mov    (%edx),%eax
  80049e:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a3:	eb 0e                	jmp    8004b3 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 02                	mov    (%edx),%eax
  8004ae:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004b3:	5d                   	pop    %ebp
  8004b4:	c3                   	ret    

008004b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004b5:	55                   	push   %ebp
  8004b6:	89 e5                	mov    %esp,%ebp
  8004b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004bf:	8b 10                	mov    (%eax),%edx
  8004c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c4:	73 0a                	jae    8004d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c9:	89 08                	mov    %ecx,(%eax)
  8004cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ce:	88 02                	mov    %al,(%edx)
}
  8004d0:	5d                   	pop    %ebp
  8004d1:	c3                   	ret    

008004d2 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004db:	50                   	push   %eax
  8004dc:	ff 75 10             	pushl  0x10(%ebp)
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 05 00 00 00       	call   8004ef <vprintfmt>
	va_end(ap);
  8004ea:	83 c4 10             	add    $0x10,%esp
}
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	57                   	push   %edi
  8004f3:	56                   	push   %esi
  8004f4:	53                   	push   %ebx
  8004f5:	83 ec 2c             	sub    $0x2c,%esp
  8004f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800501:	eb 12                	jmp    800515 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800503:	85 c0                	test   %eax,%eax
  800505:	0f 84 8d 03 00 00    	je     800898 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	53                   	push   %ebx
  80050f:	50                   	push   %eax
  800510:	ff d6                	call   *%esi
  800512:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800515:	83 c7 01             	add    $0x1,%edi
  800518:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051c:	83 f8 25             	cmp    $0x25,%eax
  80051f:	75 e2                	jne    800503 <vprintfmt+0x14>
  800521:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800525:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80052c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800533:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80053a:	ba 00 00 00 00       	mov    $0x0,%edx
  80053f:	eb 07                	jmp    800548 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800544:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8d 47 01             	lea    0x1(%edi),%eax
  80054b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80054e:	0f b6 07             	movzbl (%edi),%eax
  800551:	0f b6 c8             	movzbl %al,%ecx
  800554:	83 e8 23             	sub    $0x23,%eax
  800557:	3c 55                	cmp    $0x55,%al
  800559:	0f 87 1e 03 00 00    	ja     80087d <vprintfmt+0x38e>
  80055f:	0f b6 c0             	movzbl %al,%eax
  800562:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80056c:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800570:	eb d6                	jmp    800548 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800575:	b8 00 00 00 00       	mov    $0x0,%eax
  80057a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80057d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800580:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800584:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800587:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80058a:	83 fa 09             	cmp    $0x9,%edx
  80058d:	77 38                	ja     8005c7 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80058f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800592:	eb e9                	jmp    80057d <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 48 04             	lea    0x4(%eax),%ecx
  80059a:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a5:	eb 26                	jmp    8005cd <vprintfmt+0xde>
  8005a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005aa:	89 c8                	mov    %ecx,%eax
  8005ac:	c1 f8 1f             	sar    $0x1f,%eax
  8005af:	f7 d0                	not    %eax
  8005b1:	21 c1                	and    %eax,%ecx
  8005b3:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b9:	eb 8d                	jmp    800548 <vprintfmt+0x59>
  8005bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c5:	eb 81                	jmp    800548 <vprintfmt+0x59>
  8005c7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 89 71 ff ff ff    	jns    800548 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e4:	e9 5f ff ff ff       	jmp    800548 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e9:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ef:	e9 54 ff ff ff       	jmp    800548 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 50 04             	lea    0x4(%eax),%edx
  8005fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fd:	83 ec 08             	sub    $0x8,%esp
  800600:	53                   	push   %ebx
  800601:	ff 30                	pushl  (%eax)
  800603:	ff d6                	call   *%esi
			break;
  800605:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060b:	e9 05 ff ff ff       	jmp    800515 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 50 04             	lea    0x4(%eax),%edx
  800616:	89 55 14             	mov    %edx,0x14(%ebp)
  800619:	8b 00                	mov    (%eax),%eax
  80061b:	99                   	cltd   
  80061c:	31 d0                	xor    %edx,%eax
  80061e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800620:	83 f8 0f             	cmp    $0xf,%eax
  800623:	7f 0b                	jg     800630 <vprintfmt+0x141>
  800625:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  80062c:	85 d2                	test   %edx,%edx
  80062e:	75 18                	jne    800648 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800630:	50                   	push   %eax
  800631:	68 fb 24 80 00       	push   $0x8024fb
  800636:	53                   	push   %ebx
  800637:	56                   	push   %esi
  800638:	e8 95 fe ff ff       	call   8004d2 <printfmt>
  80063d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800643:	e9 cd fe ff ff       	jmp    800515 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 81 29 80 00       	push   $0x802981
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 7d fe ff ff       	call   8004d2 <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800658:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065b:	e9 b5 fe ff ff       	jmp    800515 <vprintfmt+0x26>
  800660:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800663:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800666:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 50 04             	lea    0x4(%eax),%edx
  80066f:	89 55 14             	mov    %edx,0x14(%ebp)
  800672:	8b 38                	mov    (%eax),%edi
  800674:	85 ff                	test   %edi,%edi
  800676:	75 05                	jne    80067d <vprintfmt+0x18e>
				p = "(null)";
  800678:	bf f4 24 80 00       	mov    $0x8024f4,%edi
			if (width > 0 && padc != '-')
  80067d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800681:	0f 84 91 00 00 00    	je     800718 <vprintfmt+0x229>
  800687:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80068b:	0f 8e 95 00 00 00    	jle    800726 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	51                   	push   %ecx
  800695:	57                   	push   %edi
  800696:	e8 85 02 00 00       	call   800920 <strnlen>
  80069b:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80069e:	29 c1                	sub    %eax,%ecx
  8006a0:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	eb 0f                	jmp    8006c3 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f ed                	jg     8006b4 <vprintfmt+0x1c5>
  8006c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ca:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006cd:	89 c8                	mov    %ecx,%eax
  8006cf:	c1 f8 1f             	sar    $0x1f,%eax
  8006d2:	f7 d0                	not    %eax
  8006d4:	21 c8                	and    %ecx,%eax
  8006d6:	29 c1                	sub    %eax,%ecx
  8006d8:	89 75 08             	mov    %esi,0x8(%ebp)
  8006db:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006de:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e1:	89 cb                	mov    %ecx,%ebx
  8006e3:	eb 4d                	jmp    800732 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e9:	74 1b                	je     800706 <vprintfmt+0x217>
  8006eb:	0f be c0             	movsbl %al,%eax
  8006ee:	83 e8 20             	sub    $0x20,%eax
  8006f1:	83 f8 5e             	cmp    $0x5e,%eax
  8006f4:	76 10                	jbe    800706 <vprintfmt+0x217>
					putch('?', putdat);
  8006f6:	83 ec 08             	sub    $0x8,%esp
  8006f9:	ff 75 0c             	pushl  0xc(%ebp)
  8006fc:	6a 3f                	push   $0x3f
  8006fe:	ff 55 08             	call   *0x8(%ebp)
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb 0d                	jmp    800713 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800706:	83 ec 08             	sub    $0x8,%esp
  800709:	ff 75 0c             	pushl  0xc(%ebp)
  80070c:	52                   	push   %edx
  80070d:	ff 55 08             	call   *0x8(%ebp)
  800710:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800713:	83 eb 01             	sub    $0x1,%ebx
  800716:	eb 1a                	jmp    800732 <vprintfmt+0x243>
  800718:	89 75 08             	mov    %esi,0x8(%ebp)
  80071b:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800721:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800724:	eb 0c                	jmp    800732 <vprintfmt+0x243>
  800726:	89 75 08             	mov    %esi,0x8(%ebp)
  800729:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80072f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800732:	83 c7 01             	add    $0x1,%edi
  800735:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800739:	0f be d0             	movsbl %al,%edx
  80073c:	85 d2                	test   %edx,%edx
  80073e:	74 23                	je     800763 <vprintfmt+0x274>
  800740:	85 f6                	test   %esi,%esi
  800742:	78 a1                	js     8006e5 <vprintfmt+0x1f6>
  800744:	83 ee 01             	sub    $0x1,%esi
  800747:	79 9c                	jns    8006e5 <vprintfmt+0x1f6>
  800749:	89 df                	mov    %ebx,%edi
  80074b:	8b 75 08             	mov    0x8(%ebp),%esi
  80074e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800751:	eb 18                	jmp    80076b <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800753:	83 ec 08             	sub    $0x8,%esp
  800756:	53                   	push   %ebx
  800757:	6a 20                	push   $0x20
  800759:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075b:	83 ef 01             	sub    $0x1,%edi
  80075e:	83 c4 10             	add    $0x10,%esp
  800761:	eb 08                	jmp    80076b <vprintfmt+0x27c>
  800763:	89 df                	mov    %ebx,%edi
  800765:	8b 75 08             	mov    0x8(%ebp),%esi
  800768:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076b:	85 ff                	test   %edi,%edi
  80076d:	7f e4                	jg     800753 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800772:	e9 9e fd ff ff       	jmp    800515 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800777:	83 fa 01             	cmp    $0x1,%edx
  80077a:	7e 16                	jle    800792 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80077c:	8b 45 14             	mov    0x14(%ebp),%eax
  80077f:	8d 50 08             	lea    0x8(%eax),%edx
  800782:	89 55 14             	mov    %edx,0x14(%ebp)
  800785:	8b 50 04             	mov    0x4(%eax),%edx
  800788:	8b 00                	mov    (%eax),%eax
  80078a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800790:	eb 32                	jmp    8007c4 <vprintfmt+0x2d5>
	else if (lflag)
  800792:	85 d2                	test   %edx,%edx
  800794:	74 18                	je     8007ae <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800796:	8b 45 14             	mov    0x14(%ebp),%eax
  800799:	8d 50 04             	lea    0x4(%eax),%edx
  80079c:	89 55 14             	mov    %edx,0x14(%ebp)
  80079f:	8b 00                	mov    (%eax),%eax
  8007a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a4:	89 c1                	mov    %eax,%ecx
  8007a6:	c1 f9 1f             	sar    $0x1f,%ecx
  8007a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007ac:	eb 16                	jmp    8007c4 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8007ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b1:	8d 50 04             	lea    0x4(%eax),%edx
  8007b4:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b7:	8b 00                	mov    (%eax),%eax
  8007b9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007bc:	89 c1                	mov    %eax,%ecx
  8007be:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c1:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007c4:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007c7:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ca:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007cf:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007d3:	79 74                	jns    800849 <vprintfmt+0x35a>
				putch('-', putdat);
  8007d5:	83 ec 08             	sub    $0x8,%esp
  8007d8:	53                   	push   %ebx
  8007d9:	6a 2d                	push   $0x2d
  8007db:	ff d6                	call   *%esi
				num = -(long long) num;
  8007dd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007e0:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8007e3:	f7 d8                	neg    %eax
  8007e5:	83 d2 00             	adc    $0x0,%edx
  8007e8:	f7 da                	neg    %edx
  8007ea:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8007ed:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8007f2:	eb 55                	jmp    800849 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8007f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f7:	e8 7f fc ff ff       	call   80047b <getuint>
			base = 10;
  8007fc:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800801:	eb 46                	jmp    800849 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800803:	8d 45 14             	lea    0x14(%ebp),%eax
  800806:	e8 70 fc ff ff       	call   80047b <getuint>
			base = 8;
  80080b:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800810:	eb 37                	jmp    800849 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800812:	83 ec 08             	sub    $0x8,%esp
  800815:	53                   	push   %ebx
  800816:	6a 30                	push   $0x30
  800818:	ff d6                	call   *%esi
			putch('x', putdat);
  80081a:	83 c4 08             	add    $0x8,%esp
  80081d:	53                   	push   %ebx
  80081e:	6a 78                	push   $0x78
  800820:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800822:	8b 45 14             	mov    0x14(%ebp),%eax
  800825:	8d 50 04             	lea    0x4(%eax),%edx
  800828:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80082b:	8b 00                	mov    (%eax),%eax
  80082d:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800832:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800835:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  80083a:	eb 0d                	jmp    800849 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80083c:	8d 45 14             	lea    0x14(%ebp),%eax
  80083f:	e8 37 fc ff ff       	call   80047b <getuint>
			base = 16;
  800844:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800849:	83 ec 0c             	sub    $0xc,%esp
  80084c:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800850:	57                   	push   %edi
  800851:	ff 75 e0             	pushl  -0x20(%ebp)
  800854:	51                   	push   %ecx
  800855:	52                   	push   %edx
  800856:	50                   	push   %eax
  800857:	89 da                	mov    %ebx,%edx
  800859:	89 f0                	mov    %esi,%eax
  80085b:	e8 71 fb ff ff       	call   8003d1 <printnum>
			break;
  800860:	83 c4 20             	add    $0x20,%esp
  800863:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800866:	e9 aa fc ff ff       	jmp    800515 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80086b:	83 ec 08             	sub    $0x8,%esp
  80086e:	53                   	push   %ebx
  80086f:	51                   	push   %ecx
  800870:	ff d6                	call   *%esi
			break;
  800872:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800875:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800878:	e9 98 fc ff ff       	jmp    800515 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80087d:	83 ec 08             	sub    $0x8,%esp
  800880:	53                   	push   %ebx
  800881:	6a 25                	push   $0x25
  800883:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800885:	83 c4 10             	add    $0x10,%esp
  800888:	eb 03                	jmp    80088d <vprintfmt+0x39e>
  80088a:	83 ef 01             	sub    $0x1,%edi
  80088d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800891:	75 f7                	jne    80088a <vprintfmt+0x39b>
  800893:	e9 7d fc ff ff       	jmp    800515 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800898:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80089b:	5b                   	pop    %ebx
  80089c:	5e                   	pop    %esi
  80089d:	5f                   	pop    %edi
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	83 ec 18             	sub    $0x18,%esp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008af:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008b6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008bd:	85 c0                	test   %eax,%eax
  8008bf:	74 26                	je     8008e7 <vsnprintf+0x47>
  8008c1:	85 d2                	test   %edx,%edx
  8008c3:	7e 22                	jle    8008e7 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008c5:	ff 75 14             	pushl  0x14(%ebp)
  8008c8:	ff 75 10             	pushl  0x10(%ebp)
  8008cb:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ce:	50                   	push   %eax
  8008cf:	68 b5 04 80 00       	push   $0x8004b5
  8008d4:	e8 16 fc ff ff       	call   8004ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008dc:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008df:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e2:	83 c4 10             	add    $0x10,%esp
  8008e5:	eb 05                	jmp    8008ec <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8008e7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8008ec:	c9                   	leave  
  8008ed:	c3                   	ret    

008008ee <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008ee:	55                   	push   %ebp
  8008ef:	89 e5                	mov    %esp,%ebp
  8008f1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008f4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008f7:	50                   	push   %eax
  8008f8:	ff 75 10             	pushl  0x10(%ebp)
  8008fb:	ff 75 0c             	pushl  0xc(%ebp)
  8008fe:	ff 75 08             	pushl  0x8(%ebp)
  800901:	e8 9a ff ff ff       	call   8008a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    

00800908 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
  800913:	eb 03                	jmp    800918 <strlen+0x10>
		n++;
  800915:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800918:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80091c:	75 f7                	jne    800915 <strlen+0xd>
		n++;
	return n;
}
  80091e:	5d                   	pop    %ebp
  80091f:	c3                   	ret    

00800920 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800926:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800929:	ba 00 00 00 00       	mov    $0x0,%edx
  80092e:	eb 03                	jmp    800933 <strnlen+0x13>
		n++;
  800930:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800933:	39 c2                	cmp    %eax,%edx
  800935:	74 08                	je     80093f <strnlen+0x1f>
  800937:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80093b:	75 f3                	jne    800930 <strnlen+0x10>
  80093d:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80093f:	5d                   	pop    %ebp
  800940:	c3                   	ret    

00800941 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	53                   	push   %ebx
  800945:	8b 45 08             	mov    0x8(%ebp),%eax
  800948:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80094b:	89 c2                	mov    %eax,%edx
  80094d:	83 c2 01             	add    $0x1,%edx
  800950:	83 c1 01             	add    $0x1,%ecx
  800953:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800957:	88 5a ff             	mov    %bl,-0x1(%edx)
  80095a:	84 db                	test   %bl,%bl
  80095c:	75 ef                	jne    80094d <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80095e:	5b                   	pop    %ebx
  80095f:	5d                   	pop    %ebp
  800960:	c3                   	ret    

00800961 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	53                   	push   %ebx
  800965:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800968:	53                   	push   %ebx
  800969:	e8 9a ff ff ff       	call   800908 <strlen>
  80096e:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800971:	ff 75 0c             	pushl  0xc(%ebp)
  800974:	01 d8                	add    %ebx,%eax
  800976:	50                   	push   %eax
  800977:	e8 c5 ff ff ff       	call   800941 <strcpy>
	return dst;
}
  80097c:	89 d8                	mov    %ebx,%eax
  80097e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800983:	55                   	push   %ebp
  800984:	89 e5                	mov    %esp,%ebp
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	8b 75 08             	mov    0x8(%ebp),%esi
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098e:	89 f3                	mov    %esi,%ebx
  800990:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800993:	89 f2                	mov    %esi,%edx
  800995:	eb 0f                	jmp    8009a6 <strncpy+0x23>
		*dst++ = *src;
  800997:	83 c2 01             	add    $0x1,%edx
  80099a:	0f b6 01             	movzbl (%ecx),%eax
  80099d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a0:	80 39 01             	cmpb   $0x1,(%ecx)
  8009a3:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a6:	39 da                	cmp    %ebx,%edx
  8009a8:	75 ed                	jne    800997 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009aa:	89 f0                	mov    %esi,%eax
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    

008009b0 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	56                   	push   %esi
  8009b4:	53                   	push   %ebx
  8009b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8009b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009bb:	8b 55 10             	mov    0x10(%ebp),%edx
  8009be:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c0:	85 d2                	test   %edx,%edx
  8009c2:	74 21                	je     8009e5 <strlcpy+0x35>
  8009c4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009c8:	89 f2                	mov    %esi,%edx
  8009ca:	eb 09                	jmp    8009d5 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009cc:	83 c2 01             	add    $0x1,%edx
  8009cf:	83 c1 01             	add    $0x1,%ecx
  8009d2:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d5:	39 c2                	cmp    %eax,%edx
  8009d7:	74 09                	je     8009e2 <strlcpy+0x32>
  8009d9:	0f b6 19             	movzbl (%ecx),%ebx
  8009dc:	84 db                	test   %bl,%bl
  8009de:	75 ec                	jne    8009cc <strlcpy+0x1c>
  8009e0:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009e2:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009e5:	29 f0                	sub    %esi,%eax
}
  8009e7:	5b                   	pop    %ebx
  8009e8:	5e                   	pop    %esi
  8009e9:	5d                   	pop    %ebp
  8009ea:	c3                   	ret    

008009eb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009f4:	eb 06                	jmp    8009fc <strcmp+0x11>
		p++, q++;
  8009f6:	83 c1 01             	add    $0x1,%ecx
  8009f9:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009fc:	0f b6 01             	movzbl (%ecx),%eax
  8009ff:	84 c0                	test   %al,%al
  800a01:	74 04                	je     800a07 <strcmp+0x1c>
  800a03:	3a 02                	cmp    (%edx),%al
  800a05:	74 ef                	je     8009f6 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a07:	0f b6 c0             	movzbl %al,%eax
  800a0a:	0f b6 12             	movzbl (%edx),%edx
  800a0d:	29 d0                	sub    %edx,%eax
}
  800a0f:	5d                   	pop    %ebp
  800a10:	c3                   	ret    

00800a11 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	53                   	push   %ebx
  800a15:	8b 45 08             	mov    0x8(%ebp),%eax
  800a18:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a1b:	89 c3                	mov    %eax,%ebx
  800a1d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a20:	eb 06                	jmp    800a28 <strncmp+0x17>
		n--, p++, q++;
  800a22:	83 c0 01             	add    $0x1,%eax
  800a25:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a28:	39 d8                	cmp    %ebx,%eax
  800a2a:	74 15                	je     800a41 <strncmp+0x30>
  800a2c:	0f b6 08             	movzbl (%eax),%ecx
  800a2f:	84 c9                	test   %cl,%cl
  800a31:	74 04                	je     800a37 <strncmp+0x26>
  800a33:	3a 0a                	cmp    (%edx),%cl
  800a35:	74 eb                	je     800a22 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a37:	0f b6 00             	movzbl (%eax),%eax
  800a3a:	0f b6 12             	movzbl (%edx),%edx
  800a3d:	29 d0                	sub    %edx,%eax
  800a3f:	eb 05                	jmp    800a46 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a41:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a46:	5b                   	pop    %ebx
  800a47:	5d                   	pop    %ebp
  800a48:	c3                   	ret    

00800a49 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a53:	eb 07                	jmp    800a5c <strchr+0x13>
		if (*s == c)
  800a55:	38 ca                	cmp    %cl,%dl
  800a57:	74 0f                	je     800a68 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a59:	83 c0 01             	add    $0x1,%eax
  800a5c:	0f b6 10             	movzbl (%eax),%edx
  800a5f:	84 d2                	test   %dl,%dl
  800a61:	75 f2                	jne    800a55 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6a:	55                   	push   %ebp
  800a6b:	89 e5                	mov    %esp,%ebp
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a74:	eb 03                	jmp    800a79 <strfind+0xf>
  800a76:	83 c0 01             	add    $0x1,%eax
  800a79:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a7c:	84 d2                	test   %dl,%dl
  800a7e:	74 04                	je     800a84 <strfind+0x1a>
  800a80:	38 ca                	cmp    %cl,%dl
  800a82:	75 f2                	jne    800a76 <strfind+0xc>
			break;
	return (char *) s;
}
  800a84:	5d                   	pop    %ebp
  800a85:	c3                   	ret    

00800a86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a86:	55                   	push   %ebp
  800a87:	89 e5                	mov    %esp,%ebp
  800a89:	57                   	push   %edi
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
  800a8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800a92:	85 c9                	test   %ecx,%ecx
  800a94:	74 36                	je     800acc <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a96:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9c:	75 28                	jne    800ac6 <memset+0x40>
  800a9e:	f6 c1 03             	test   $0x3,%cl
  800aa1:	75 23                	jne    800ac6 <memset+0x40>
		c &= 0xFF;
  800aa3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa7:	89 d3                	mov    %edx,%ebx
  800aa9:	c1 e3 08             	shl    $0x8,%ebx
  800aac:	89 d6                	mov    %edx,%esi
  800aae:	c1 e6 18             	shl    $0x18,%esi
  800ab1:	89 d0                	mov    %edx,%eax
  800ab3:	c1 e0 10             	shl    $0x10,%eax
  800ab6:	09 f0                	or     %esi,%eax
  800ab8:	09 c2                	or     %eax,%edx
  800aba:	89 d0                	mov    %edx,%eax
  800abc:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800abe:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ac1:	fc                   	cld    
  800ac2:	f3 ab                	rep stos %eax,%es:(%edi)
  800ac4:	eb 06                	jmp    800acc <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac9:	fc                   	cld    
  800aca:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800acc:	89 f8                	mov    %edi,%eax
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5f                   	pop    %edi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    

00800ad3 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	57                   	push   %edi
  800ad7:	56                   	push   %esi
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae1:	39 c6                	cmp    %eax,%esi
  800ae3:	73 35                	jae    800b1a <memmove+0x47>
  800ae5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae8:	39 d0                	cmp    %edx,%eax
  800aea:	73 2e                	jae    800b1a <memmove+0x47>
		s += n;
		d += n;
  800aec:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800aef:	89 d6                	mov    %edx,%esi
  800af1:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800af9:	75 13                	jne    800b0e <memmove+0x3b>
  800afb:	f6 c1 03             	test   $0x3,%cl
  800afe:	75 0e                	jne    800b0e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b00:	83 ef 04             	sub    $0x4,%edi
  800b03:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b06:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b09:	fd                   	std    
  800b0a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b0c:	eb 09                	jmp    800b17 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b0e:	83 ef 01             	sub    $0x1,%edi
  800b11:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b14:	fd                   	std    
  800b15:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b17:	fc                   	cld    
  800b18:	eb 1d                	jmp    800b37 <memmove+0x64>
  800b1a:	89 f2                	mov    %esi,%edx
  800b1c:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1e:	f6 c2 03             	test   $0x3,%dl
  800b21:	75 0f                	jne    800b32 <memmove+0x5f>
  800b23:	f6 c1 03             	test   $0x3,%cl
  800b26:	75 0a                	jne    800b32 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b28:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b2b:	89 c7                	mov    %eax,%edi
  800b2d:	fc                   	cld    
  800b2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b30:	eb 05                	jmp    800b37 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b32:	89 c7                	mov    %eax,%edi
  800b34:	fc                   	cld    
  800b35:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b3e:	ff 75 10             	pushl  0x10(%ebp)
  800b41:	ff 75 0c             	pushl  0xc(%ebp)
  800b44:	ff 75 08             	pushl  0x8(%ebp)
  800b47:	e8 87 ff ff ff       	call   800ad3 <memmove>
}
  800b4c:	c9                   	leave  
  800b4d:	c3                   	ret    

00800b4e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	8b 45 08             	mov    0x8(%ebp),%eax
  800b56:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b59:	89 c6                	mov    %eax,%esi
  800b5b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5e:	eb 1a                	jmp    800b7a <memcmp+0x2c>
		if (*s1 != *s2)
  800b60:	0f b6 08             	movzbl (%eax),%ecx
  800b63:	0f b6 1a             	movzbl (%edx),%ebx
  800b66:	38 d9                	cmp    %bl,%cl
  800b68:	74 0a                	je     800b74 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800b6a:	0f b6 c1             	movzbl %cl,%eax
  800b6d:	0f b6 db             	movzbl %bl,%ebx
  800b70:	29 d8                	sub    %ebx,%eax
  800b72:	eb 0f                	jmp    800b83 <memcmp+0x35>
		s1++, s2++;
  800b74:	83 c0 01             	add    $0x1,%eax
  800b77:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7a:	39 f0                	cmp    %esi,%eax
  800b7c:	75 e2                	jne    800b60 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800b7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    

00800b87 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b90:	89 c2                	mov    %eax,%edx
  800b92:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b95:	eb 07                	jmp    800b9e <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b97:	38 08                	cmp    %cl,(%eax)
  800b99:	74 07                	je     800ba2 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b9b:	83 c0 01             	add    $0x1,%eax
  800b9e:	39 d0                	cmp    %edx,%eax
  800ba0:	72 f5                	jb     800b97 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba2:	5d                   	pop    %ebp
  800ba3:	c3                   	ret    

00800ba4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	57                   	push   %edi
  800ba8:	56                   	push   %esi
  800ba9:	53                   	push   %ebx
  800baa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb0:	eb 03                	jmp    800bb5 <strtol+0x11>
		s++;
  800bb2:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb5:	0f b6 01             	movzbl (%ecx),%eax
  800bb8:	3c 09                	cmp    $0x9,%al
  800bba:	74 f6                	je     800bb2 <strtol+0xe>
  800bbc:	3c 20                	cmp    $0x20,%al
  800bbe:	74 f2                	je     800bb2 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc0:	3c 2b                	cmp    $0x2b,%al
  800bc2:	75 0a                	jne    800bce <strtol+0x2a>
		s++;
  800bc4:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800bc7:	bf 00 00 00 00       	mov    $0x0,%edi
  800bcc:	eb 10                	jmp    800bde <strtol+0x3a>
  800bce:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800bd3:	3c 2d                	cmp    $0x2d,%al
  800bd5:	75 07                	jne    800bde <strtol+0x3a>
		s++, neg = 1;
  800bd7:	8d 49 01             	lea    0x1(%ecx),%ecx
  800bda:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bde:	85 db                	test   %ebx,%ebx
  800be0:	0f 94 c0             	sete   %al
  800be3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800be9:	75 19                	jne    800c04 <strtol+0x60>
  800beb:	80 39 30             	cmpb   $0x30,(%ecx)
  800bee:	75 14                	jne    800c04 <strtol+0x60>
  800bf0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf4:	0f 85 8a 00 00 00    	jne    800c84 <strtol+0xe0>
		s += 2, base = 16;
  800bfa:	83 c1 02             	add    $0x2,%ecx
  800bfd:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c02:	eb 16                	jmp    800c1a <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c04:	84 c0                	test   %al,%al
  800c06:	74 12                	je     800c1a <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c08:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0d:	80 39 30             	cmpb   $0x30,(%ecx)
  800c10:	75 08                	jne    800c1a <strtol+0x76>
		s++, base = 8;
  800c12:	83 c1 01             	add    $0x1,%ecx
  800c15:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800c1f:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c22:	0f b6 11             	movzbl (%ecx),%edx
  800c25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c28:	89 f3                	mov    %esi,%ebx
  800c2a:	80 fb 09             	cmp    $0x9,%bl
  800c2d:	77 08                	ja     800c37 <strtol+0x93>
			dig = *s - '0';
  800c2f:	0f be d2             	movsbl %dl,%edx
  800c32:	83 ea 30             	sub    $0x30,%edx
  800c35:	eb 22                	jmp    800c59 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c37:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c3a:	89 f3                	mov    %esi,%ebx
  800c3c:	80 fb 19             	cmp    $0x19,%bl
  800c3f:	77 08                	ja     800c49 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c41:	0f be d2             	movsbl %dl,%edx
  800c44:	83 ea 57             	sub    $0x57,%edx
  800c47:	eb 10                	jmp    800c59 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c49:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c4c:	89 f3                	mov    %esi,%ebx
  800c4e:	80 fb 19             	cmp    $0x19,%bl
  800c51:	77 16                	ja     800c69 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c53:	0f be d2             	movsbl %dl,%edx
  800c56:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c59:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c5c:	7d 0f                	jge    800c6d <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c5e:	83 c1 01             	add    $0x1,%ecx
  800c61:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c65:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800c67:	eb b9                	jmp    800c22 <strtol+0x7e>
  800c69:	89 c2                	mov    %eax,%edx
  800c6b:	eb 02                	jmp    800c6f <strtol+0xcb>
  800c6d:	89 c2                	mov    %eax,%edx

	if (endptr)
  800c6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c73:	74 05                	je     800c7a <strtol+0xd6>
		*endptr = (char *) s;
  800c75:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c78:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c7a:	85 ff                	test   %edi,%edi
  800c7c:	74 0c                	je     800c8a <strtol+0xe6>
  800c7e:	89 d0                	mov    %edx,%eax
  800c80:	f7 d8                	neg    %eax
  800c82:	eb 06                	jmp    800c8a <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c84:	84 c0                	test   %al,%al
  800c86:	75 8a                	jne    800c12 <strtol+0x6e>
  800c88:	eb 90                	jmp    800c1a <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c95:	b8 00 00 00 00       	mov    $0x0,%eax
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca0:	89 c3                	mov    %eax,%ebx
  800ca2:	89 c7                	mov    %eax,%edi
  800ca4:	89 c6                	mov    %eax,%esi
  800ca6:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    

00800cad <sys_cgetc>:

int
sys_cgetc(void)
{
  800cad:	55                   	push   %ebp
  800cae:	89 e5                	mov    %esp,%ebp
  800cb0:	57                   	push   %edi
  800cb1:	56                   	push   %esi
  800cb2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb8:	b8 01 00 00 00       	mov    $0x1,%eax
  800cbd:	89 d1                	mov    %edx,%ecx
  800cbf:	89 d3                	mov    %edx,%ebx
  800cc1:	89 d7                	mov    %edx,%edi
  800cc3:	89 d6                	mov    %edx,%esi
  800cc5:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cda:	b8 03 00 00 00       	mov    $0x3,%eax
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	89 cb                	mov    %ecx,%ebx
  800ce4:	89 cf                	mov    %ecx,%edi
  800ce6:	89 ce                	mov    %ecx,%esi
  800ce8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7e 17                	jle    800d05 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cee:	83 ec 0c             	sub    $0xc,%esp
  800cf1:	50                   	push   %eax
  800cf2:	6a 03                	push   $0x3
  800cf4:	68 1f 28 80 00       	push   $0x80281f
  800cf9:	6a 23                	push   $0x23
  800cfb:	68 3c 28 80 00       	push   $0x80283c
  800d00:	e8 df f5 ff ff       	call   8002e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d08:	5b                   	pop    %ebx
  800d09:	5e                   	pop    %esi
  800d0a:	5f                   	pop    %edi
  800d0b:	5d                   	pop    %ebp
  800d0c:	c3                   	ret    

00800d0d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0d:	55                   	push   %ebp
  800d0e:	89 e5                	mov    %esp,%ebp
  800d10:	57                   	push   %edi
  800d11:	56                   	push   %esi
  800d12:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	ba 00 00 00 00       	mov    $0x0,%edx
  800d18:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1d:	89 d1                	mov    %edx,%ecx
  800d1f:	89 d3                	mov    %edx,%ebx
  800d21:	89 d7                	mov    %edx,%edi
  800d23:	89 d6                	mov    %edx,%esi
  800d25:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d27:	5b                   	pop    %ebx
  800d28:	5e                   	pop    %esi
  800d29:	5f                   	pop    %edi
  800d2a:	5d                   	pop    %ebp
  800d2b:	c3                   	ret    

00800d2c <sys_yield>:

void
sys_yield(void)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	57                   	push   %edi
  800d30:	56                   	push   %esi
  800d31:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d32:	ba 00 00 00 00       	mov    $0x0,%edx
  800d37:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d3c:	89 d1                	mov    %edx,%ecx
  800d3e:	89 d3                	mov    %edx,%ebx
  800d40:	89 d7                	mov    %edx,%edi
  800d42:	89 d6                	mov    %edx,%esi
  800d44:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d54:	be 00 00 00 00       	mov    $0x0,%esi
  800d59:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d67:	89 f7                	mov    %esi,%edi
  800d69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 17                	jle    800d86 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	50                   	push   %eax
  800d73:	6a 04                	push   $0x4
  800d75:	68 1f 28 80 00       	push   $0x80281f
  800d7a:	6a 23                	push   $0x23
  800d7c:	68 3c 28 80 00       	push   $0x80283c
  800d81:	e8 5e f5 ff ff       	call   8002e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d89:	5b                   	pop    %ebx
  800d8a:	5e                   	pop    %esi
  800d8b:	5f                   	pop    %edi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	57                   	push   %edi
  800d92:	56                   	push   %esi
  800d93:	53                   	push   %ebx
  800d94:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d97:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9f:	8b 55 08             	mov    0x8(%ebp),%edx
  800da2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da5:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da8:	8b 75 18             	mov    0x18(%ebp),%esi
  800dab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7e 17                	jle    800dc8 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db1:	83 ec 0c             	sub    $0xc,%esp
  800db4:	50                   	push   %eax
  800db5:	6a 05                	push   $0x5
  800db7:	68 1f 28 80 00       	push   $0x80281f
  800dbc:	6a 23                	push   $0x23
  800dbe:	68 3c 28 80 00       	push   $0x80283c
  800dc3:	e8 1c f5 ff ff       	call   8002e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcb:	5b                   	pop    %ebx
  800dcc:	5e                   	pop    %esi
  800dcd:	5f                   	pop    %edi
  800dce:	5d                   	pop    %ebp
  800dcf:	c3                   	ret    

00800dd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
  800dd6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dde:	b8 06 00 00 00       	mov    $0x6,%eax
  800de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de6:	8b 55 08             	mov    0x8(%ebp),%edx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 de                	mov    %ebx,%esi
  800ded:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800def:	85 c0                	test   %eax,%eax
  800df1:	7e 17                	jle    800e0a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	50                   	push   %eax
  800df7:	6a 06                	push   $0x6
  800df9:	68 1f 28 80 00       	push   $0x80281f
  800dfe:	6a 23                	push   $0x23
  800e00:	68 3c 28 80 00       	push   $0x80283c
  800e05:	e8 da f4 ff ff       	call   8002e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0d:	5b                   	pop    %ebx
  800e0e:	5e                   	pop    %esi
  800e0f:	5f                   	pop    %edi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e20:	b8 08 00 00 00       	mov    $0x8,%eax
  800e25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e28:	8b 55 08             	mov    0x8(%ebp),%edx
  800e2b:	89 df                	mov    %ebx,%edi
  800e2d:	89 de                	mov    %ebx,%esi
  800e2f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e31:	85 c0                	test   %eax,%eax
  800e33:	7e 17                	jle    800e4c <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e35:	83 ec 0c             	sub    $0xc,%esp
  800e38:	50                   	push   %eax
  800e39:	6a 08                	push   $0x8
  800e3b:	68 1f 28 80 00       	push   $0x80281f
  800e40:	6a 23                	push   $0x23
  800e42:	68 3c 28 80 00       	push   $0x80283c
  800e47:	e8 98 f4 ff ff       	call   8002e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4f:	5b                   	pop    %ebx
  800e50:	5e                   	pop    %esi
  800e51:	5f                   	pop    %edi
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	57                   	push   %edi
  800e58:	56                   	push   %esi
  800e59:	53                   	push   %ebx
  800e5a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e62:	b8 09 00 00 00       	mov    $0x9,%eax
  800e67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6d:	89 df                	mov    %ebx,%edi
  800e6f:	89 de                	mov    %ebx,%esi
  800e71:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e73:	85 c0                	test   %eax,%eax
  800e75:	7e 17                	jle    800e8e <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e77:	83 ec 0c             	sub    $0xc,%esp
  800e7a:	50                   	push   %eax
  800e7b:	6a 09                	push   $0x9
  800e7d:	68 1f 28 80 00       	push   $0x80281f
  800e82:	6a 23                	push   $0x23
  800e84:	68 3c 28 80 00       	push   $0x80283c
  800e89:	e8 56 f4 ff ff       	call   8002e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	57                   	push   %edi
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eac:	8b 55 08             	mov    0x8(%ebp),%edx
  800eaf:	89 df                	mov    %ebx,%edi
  800eb1:	89 de                	mov    %ebx,%esi
  800eb3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb5:	85 c0                	test   %eax,%eax
  800eb7:	7e 17                	jle    800ed0 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb9:	83 ec 0c             	sub    $0xc,%esp
  800ebc:	50                   	push   %eax
  800ebd:	6a 0a                	push   $0xa
  800ebf:	68 1f 28 80 00       	push   $0x80281f
  800ec4:	6a 23                	push   $0x23
  800ec6:	68 3c 28 80 00       	push   $0x80283c
  800ecb:	e8 14 f4 ff ff       	call   8002e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    

00800ed8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	be 00 00 00 00       	mov    $0x0,%esi
  800ee3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef4:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f11:	89 cb                	mov    %ecx,%ebx
  800f13:	89 cf                	mov    %ecx,%edi
  800f15:	89 ce                	mov    %ecx,%esi
  800f17:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	7e 17                	jle    800f34 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1d:	83 ec 0c             	sub    $0xc,%esp
  800f20:	50                   	push   %eax
  800f21:	6a 0d                	push   $0xd
  800f23:	68 1f 28 80 00       	push   $0x80281f
  800f28:	6a 23                	push   $0x23
  800f2a:	68 3c 28 80 00       	push   $0x80283c
  800f2f:	e8 b0 f3 ff ff       	call   8002e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f37:	5b                   	pop    %ebx
  800f38:	5e                   	pop    %esi
  800f39:	5f                   	pop    %edi
  800f3a:	5d                   	pop    %ebp
  800f3b:	c3                   	ret    

00800f3c <sys_gettime>:

int sys_gettime(void)
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	57                   	push   %edi
  800f40:	56                   	push   %esi
  800f41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f42:	ba 00 00 00 00       	mov    $0x0,%edx
  800f47:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f4c:	89 d1                	mov    %edx,%ecx
  800f4e:	89 d3                	mov    %edx,%ebx
  800f50:	89 d7                	mov    %edx,%edi
  800f52:	89 d6                	mov    %edx,%esi
  800f54:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5f                   	pop    %edi
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	53                   	push   %ebx
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  800f65:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800f67:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  800f6b:	74 2e                	je     800f9b <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  800f6d:	89 c2                	mov    %eax,%edx
  800f6f:	c1 ea 16             	shr    $0x16,%edx
  800f72:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800f79:	f6 c2 01             	test   $0x1,%dl
  800f7c:	74 1d                	je     800f9b <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  800f7e:	89 c2                	mov    %eax,%edx
  800f80:	c1 ea 0c             	shr    $0xc,%edx
  800f83:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  800f8a:	f6 c1 01             	test   $0x1,%cl
  800f8d:	74 0c                	je     800f9b <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  800f8f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  800f96:	f6 c6 08             	test   $0x8,%dh
  800f99:	75 14                	jne    800faf <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	68 4a 28 80 00       	push   $0x80284a
  800fa3:	6a 28                	push   $0x28
  800fa5:	68 5c 28 80 00       	push   $0x80285c
  800faa:	e8 35 f3 ff ff       	call   8002e4 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  800faf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fb4:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	6a 07                	push   $0x7
  800fbb:	68 00 f0 7f 00       	push   $0x7ff000
  800fc0:	6a 00                	push   $0x0
  800fc2:	e8 84 fd ff ff       	call   800d4b <sys_page_alloc>
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	79 14                	jns    800fe2 <pgfault+0x87>
		panic("sys_page_alloc");
  800fce:	83 ec 04             	sub    $0x4,%esp
  800fd1:	68 67 28 80 00       	push   $0x802867
  800fd6:	6a 2c                	push   $0x2c
  800fd8:	68 5c 28 80 00       	push   $0x80285c
  800fdd:	e8 02 f3 ff ff       	call   8002e4 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  800fe2:	83 ec 04             	sub    $0x4,%esp
  800fe5:	68 00 10 00 00       	push   $0x1000
  800fea:	53                   	push   %ebx
  800feb:	68 00 f0 7f 00       	push   $0x7ff000
  800ff0:	e8 46 fb ff ff       	call   800b3b <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  800ff5:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800ffc:	53                   	push   %ebx
  800ffd:	6a 00                	push   $0x0
  800fff:	68 00 f0 7f 00       	push   $0x7ff000
  801004:	6a 00                	push   $0x0
  801006:	e8 83 fd ff ff       	call   800d8e <sys_page_map>
  80100b:	83 c4 20             	add    $0x20,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	79 14                	jns    801026 <pgfault+0xcb>
		panic("sys_page_map");
  801012:	83 ec 04             	sub    $0x4,%esp
  801015:	68 76 28 80 00       	push   $0x802876
  80101a:	6a 2f                	push   $0x2f
  80101c:	68 5c 28 80 00       	push   $0x80285c
  801021:	e8 be f2 ff ff       	call   8002e4 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  801026:	83 ec 08             	sub    $0x8,%esp
  801029:	68 00 f0 7f 00       	push   $0x7ff000
  80102e:	6a 00                	push   $0x0
  801030:	e8 9b fd ff ff       	call   800dd0 <sys_page_unmap>
  801035:	83 c4 10             	add    $0x10,%esp
  801038:	85 c0                	test   %eax,%eax
  80103a:	79 14                	jns    801050 <pgfault+0xf5>
		panic("sys_page_unmap");
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	68 83 28 80 00       	push   $0x802883
  801044:	6a 31                	push   $0x31
  801046:	68 5c 28 80 00       	push   $0x80285c
  80104b:	e8 94 f2 ff ff       	call   8002e4 <_panic>
	return;
}
  801050:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	57                   	push   %edi
  801059:	56                   	push   %esi
  80105a:	53                   	push   %ebx
  80105b:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  80105e:	68 5b 0f 80 00       	push   $0x800f5b
  801063:	e8 bb 0e 00 00       	call   801f23 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  801068:	b8 07 00 00 00       	mov    $0x7,%eax
  80106d:	cd 30                	int    $0x30
  80106f:	89 c7                	mov    %eax,%edi
  801071:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	75 21                	jne    80109c <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  80107b:	e8 8d fc ff ff       	call   800d0d <sys_getenvid>
  801080:	25 ff 03 00 00       	and    $0x3ff,%eax
  801085:	6b c0 78             	imul   $0x78,%eax,%eax
  801088:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80108d:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801092:	b8 00 00 00 00       	mov    $0x0,%eax
  801097:	e9 80 01 00 00       	jmp    80121c <fork+0x1c7>
	}
	if (envid < 0)
  80109c:	85 c0                	test   %eax,%eax
  80109e:	79 12                	jns    8010b2 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  8010a0:	50                   	push   %eax
  8010a1:	68 92 28 80 00       	push   $0x802892
  8010a6:	6a 70                	push   $0x70
  8010a8:	68 5c 28 80 00       	push   $0x80285c
  8010ad:	e8 32 f2 ff ff       	call   8002e4 <_panic>
  8010b2:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  8010b7:	89 d8                	mov    %ebx,%eax
  8010b9:	c1 e8 16             	shr    $0x16,%eax
  8010bc:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010c3:	a8 01                	test   $0x1,%al
  8010c5:	0f 84 de 00 00 00    	je     8011a9 <fork+0x154>
  8010cb:	89 de                	mov    %ebx,%esi
  8010cd:	c1 ee 0c             	shr    $0xc,%esi
  8010d0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010d7:	a8 01                	test   $0x1,%al
  8010d9:	0f 84 ca 00 00 00    	je     8011a9 <fork+0x154>
  8010df:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010e6:	a8 04                	test   $0x4,%al
  8010e8:	0f 84 bb 00 00 00    	je     8011a9 <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  8010ee:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  8010f5:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  8010f8:	f6 c4 04             	test   $0x4,%ah
  8010fb:	74 34                	je     801131 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	25 07 0e 00 00       	and    $0xe07,%eax
  801105:	50                   	push   %eax
  801106:	56                   	push   %esi
  801107:	ff 75 e4             	pushl  -0x1c(%ebp)
  80110a:	56                   	push   %esi
  80110b:	6a 00                	push   $0x0
  80110d:	e8 7c fc ff ff       	call   800d8e <sys_page_map>
  801112:	83 c4 20             	add    $0x20,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	0f 84 8c 00 00 00    	je     8011a9 <fork+0x154>
        	panic("duppage share");
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	68 a2 28 80 00       	push   $0x8028a2
  801125:	6a 48                	push   $0x48
  801127:	68 5c 28 80 00       	push   $0x80285c
  80112c:	e8 b3 f1 ff ff       	call   8002e4 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  801131:	a9 02 08 00 00       	test   $0x802,%eax
  801136:	74 5d                	je     801195 <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801138:	83 ec 0c             	sub    $0xc,%esp
  80113b:	68 05 08 00 00       	push   $0x805
  801140:	56                   	push   %esi
  801141:	ff 75 e4             	pushl  -0x1c(%ebp)
  801144:	56                   	push   %esi
  801145:	6a 00                	push   $0x0
  801147:	e8 42 fc ff ff       	call   800d8e <sys_page_map>
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	85 c0                	test   %eax,%eax
  801151:	79 14                	jns    801167 <fork+0x112>
			panic("error");
  801153:	83 ec 04             	sub    $0x4,%esp
  801156:	68 10 25 80 00       	push   $0x802510
  80115b:	6a 4b                	push   $0x4b
  80115d:	68 5c 28 80 00       	push   $0x80285c
  801162:	e8 7d f1 ff ff       	call   8002e4 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  801167:	83 ec 0c             	sub    $0xc,%esp
  80116a:	68 05 08 00 00       	push   $0x805
  80116f:	56                   	push   %esi
  801170:	6a 00                	push   $0x0
  801172:	56                   	push   %esi
  801173:	6a 00                	push   $0x0
  801175:	e8 14 fc ff ff       	call   800d8e <sys_page_map>
  80117a:	83 c4 20             	add    $0x20,%esp
  80117d:	85 c0                	test   %eax,%eax
  80117f:	79 28                	jns    8011a9 <fork+0x154>
			panic("error");
  801181:	83 ec 04             	sub    $0x4,%esp
  801184:	68 10 25 80 00       	push   $0x802510
  801189:	6a 4d                	push   $0x4d
  80118b:	68 5c 28 80 00       	push   $0x80285c
  801190:	e8 4f f1 ff ff       	call   8002e4 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  801195:	83 ec 0c             	sub    $0xc,%esp
  801198:	6a 05                	push   $0x5
  80119a:	56                   	push   %esi
  80119b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119e:	56                   	push   %esi
  80119f:	6a 00                	push   $0x0
  8011a1:	e8 e8 fb ff ff       	call   800d8e <sys_page_map>
  8011a6:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8011a9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011af:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  8011b5:	0f 85 fc fe ff ff    	jne    8010b7 <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	6a 07                	push   $0x7
  8011c0:	68 00 f0 7f ee       	push   $0xee7ff000
  8011c5:	57                   	push   %edi
  8011c6:	e8 80 fb ff ff       	call   800d4b <sys_page_alloc>
  8011cb:	83 c4 10             	add    $0x10,%esp
  8011ce:	85 c0                	test   %eax,%eax
  8011d0:	79 14                	jns    8011e6 <fork+0x191>
		panic("1");
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	68 b0 28 80 00       	push   $0x8028b0
  8011da:	6a 78                	push   $0x78
  8011dc:	68 5c 28 80 00       	push   $0x80285c
  8011e1:	e8 fe f0 ff ff       	call   8002e4 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011e6:	83 ec 08             	sub    $0x8,%esp
  8011e9:	68 92 1f 80 00       	push   $0x801f92
  8011ee:	57                   	push   %edi
  8011ef:	e8 a2 fc ff ff       	call   800e96 <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  8011f4:	83 c4 08             	add    $0x8,%esp
  8011f7:	6a 02                	push   $0x2
  8011f9:	57                   	push   %edi
  8011fa:	e8 13 fc ff ff       	call   800e12 <sys_env_set_status>
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	85 c0                	test   %eax,%eax
  801204:	79 14                	jns    80121a <fork+0x1c5>
		panic("sys_env_set_status");
  801206:	83 ec 04             	sub    $0x4,%esp
  801209:	68 b2 28 80 00       	push   $0x8028b2
  80120e:	6a 7d                	push   $0x7d
  801210:	68 5c 28 80 00       	push   $0x80285c
  801215:	e8 ca f0 ff ff       	call   8002e4 <_panic>

	return envid;
  80121a:	89 f8                	mov    %edi,%eax
}
  80121c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5f                   	pop    %edi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <sfork>:

// Challenge!
int
sfork(void)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80122a:	68 c5 28 80 00       	push   $0x8028c5
  80122f:	68 86 00 00 00       	push   $0x86
  801234:	68 5c 28 80 00       	push   $0x80285c
  801239:	e8 a6 f0 ff ff       	call   8002e4 <_panic>

0080123e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801241:	8b 45 08             	mov    0x8(%ebp),%eax
  801244:	05 00 00 00 30       	add    $0x30000000,%eax
  801249:	c1 e8 0c             	shr    $0xc,%eax
}
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    

0080124e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801251:	8b 45 08             	mov    0x8(%ebp),%eax
  801254:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801259:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80125e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801263:	5d                   	pop    %ebp
  801264:	c3                   	ret    

00801265 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80126b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801270:	89 c2                	mov    %eax,%edx
  801272:	c1 ea 16             	shr    $0x16,%edx
  801275:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80127c:	f6 c2 01             	test   $0x1,%dl
  80127f:	74 11                	je     801292 <fd_alloc+0x2d>
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 0c             	shr    $0xc,%edx
  801286:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	75 09                	jne    80129b <fd_alloc+0x36>
			*fd_store = fd;
  801292:	89 01                	mov    %eax,(%ecx)
			return 0;
  801294:	b8 00 00 00 00       	mov    $0x0,%eax
  801299:	eb 17                	jmp    8012b2 <fd_alloc+0x4d>
  80129b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012a0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012a5:	75 c9                	jne    801270 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012a7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012ad:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    

008012b4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012b4:	55                   	push   %ebp
  8012b5:	89 e5                	mov    %esp,%ebp
  8012b7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012ba:	83 f8 1f             	cmp    $0x1f,%eax
  8012bd:	77 36                	ja     8012f5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012bf:	c1 e0 0c             	shl    $0xc,%eax
  8012c2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012c7:	89 c2                	mov    %eax,%edx
  8012c9:	c1 ea 16             	shr    $0x16,%edx
  8012cc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012d3:	f6 c2 01             	test   $0x1,%dl
  8012d6:	74 24                	je     8012fc <fd_lookup+0x48>
  8012d8:	89 c2                	mov    %eax,%edx
  8012da:	c1 ea 0c             	shr    $0xc,%edx
  8012dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012e4:	f6 c2 01             	test   $0x1,%dl
  8012e7:	74 1a                	je     801303 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012ec:	89 02                	mov    %eax,(%edx)
	return 0;
  8012ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f3:	eb 13                	jmp    801308 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012fa:	eb 0c                	jmp    801308 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8012fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801301:	eb 05                	jmp    801308 <fd_lookup+0x54>
  801303:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    

0080130a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80130a:	55                   	push   %ebp
  80130b:	89 e5                	mov    %esp,%ebp
  80130d:	83 ec 08             	sub    $0x8,%esp
  801310:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801313:	ba 58 29 80 00       	mov    $0x802958,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801318:	eb 13                	jmp    80132d <dev_lookup+0x23>
  80131a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80131d:	39 08                	cmp    %ecx,(%eax)
  80131f:	75 0c                	jne    80132d <dev_lookup+0x23>
			*dev = devtab[i];
  801321:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801324:	89 01                	mov    %eax,(%ecx)
			return 0;
  801326:	b8 00 00 00 00       	mov    $0x0,%eax
  80132b:	eb 2e                	jmp    80135b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80132d:	8b 02                	mov    (%edx),%eax
  80132f:	85 c0                	test   %eax,%eax
  801331:	75 e7                	jne    80131a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801333:	a1 04 40 80 00       	mov    0x804004,%eax
  801338:	8b 40 48             	mov    0x48(%eax),%eax
  80133b:	83 ec 04             	sub    $0x4,%esp
  80133e:	51                   	push   %ecx
  80133f:	50                   	push   %eax
  801340:	68 dc 28 80 00       	push   $0x8028dc
  801345:	e8 73 f0 ff ff       	call   8003bd <cprintf>
	*dev = 0;
  80134a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80134d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	56                   	push   %esi
  801361:	53                   	push   %ebx
  801362:	83 ec 10             	sub    $0x10,%esp
  801365:	8b 75 08             	mov    0x8(%ebp),%esi
  801368:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80136b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136e:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80136f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801375:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801378:	50                   	push   %eax
  801379:	e8 36 ff ff ff       	call   8012b4 <fd_lookup>
  80137e:	83 c4 08             	add    $0x8,%esp
  801381:	85 c0                	test   %eax,%eax
  801383:	78 05                	js     80138a <fd_close+0x2d>
	    || fd != fd2)
  801385:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801388:	74 0b                	je     801395 <fd_close+0x38>
		return (must_exist ? r : 0);
  80138a:	80 fb 01             	cmp    $0x1,%bl
  80138d:	19 d2                	sbb    %edx,%edx
  80138f:	f7 d2                	not    %edx
  801391:	21 d0                	and    %edx,%eax
  801393:	eb 41                	jmp    8013d6 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801395:	83 ec 08             	sub    $0x8,%esp
  801398:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	ff 36                	pushl  (%esi)
  80139e:	e8 67 ff ff ff       	call   80130a <dev_lookup>
  8013a3:	89 c3                	mov    %eax,%ebx
  8013a5:	83 c4 10             	add    $0x10,%esp
  8013a8:	85 c0                	test   %eax,%eax
  8013aa:	78 1a                	js     8013c6 <fd_close+0x69>
		if (dev->dev_close)
  8013ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013af:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013b2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	74 0b                	je     8013c6 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	56                   	push   %esi
  8013bf:	ff d0                	call   *%eax
  8013c1:	89 c3                	mov    %eax,%ebx
  8013c3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	56                   	push   %esi
  8013ca:	6a 00                	push   $0x0
  8013cc:	e8 ff f9 ff ff       	call   800dd0 <sys_page_unmap>
	return r;
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	89 d8                	mov    %ebx,%eax
}
  8013d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5d                   	pop    %ebp
  8013dc:	c3                   	ret    

008013dd <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e6:	50                   	push   %eax
  8013e7:	ff 75 08             	pushl  0x8(%ebp)
  8013ea:	e8 c5 fe ff ff       	call   8012b4 <fd_lookup>
  8013ef:	89 c2                	mov    %eax,%edx
  8013f1:	83 c4 08             	add    $0x8,%esp
  8013f4:	85 d2                	test   %edx,%edx
  8013f6:	78 10                	js     801408 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	6a 01                	push   $0x1
  8013fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801400:	e8 58 ff ff ff       	call   80135d <fd_close>
  801405:	83 c4 10             	add    $0x10,%esp
}
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <close_all>:

void
close_all(void)
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	53                   	push   %ebx
  80140e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801411:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801416:	83 ec 0c             	sub    $0xc,%esp
  801419:	53                   	push   %ebx
  80141a:	e8 be ff ff ff       	call   8013dd <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80141f:	83 c3 01             	add    $0x1,%ebx
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	83 fb 20             	cmp    $0x20,%ebx
  801428:	75 ec                	jne    801416 <close_all+0xc>
		close(i);
}
  80142a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    

0080142f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	57                   	push   %edi
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	83 ec 2c             	sub    $0x2c,%esp
  801438:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80143b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	ff 75 08             	pushl  0x8(%ebp)
  801442:	e8 6d fe ff ff       	call   8012b4 <fd_lookup>
  801447:	89 c2                	mov    %eax,%edx
  801449:	83 c4 08             	add    $0x8,%esp
  80144c:	85 d2                	test   %edx,%edx
  80144e:	0f 88 c1 00 00 00    	js     801515 <dup+0xe6>
		return r;
	close(newfdnum);
  801454:	83 ec 0c             	sub    $0xc,%esp
  801457:	56                   	push   %esi
  801458:	e8 80 ff ff ff       	call   8013dd <close>

	newfd = INDEX2FD(newfdnum);
  80145d:	89 f3                	mov    %esi,%ebx
  80145f:	c1 e3 0c             	shl    $0xc,%ebx
  801462:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801468:	83 c4 04             	add    $0x4,%esp
  80146b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80146e:	e8 db fd ff ff       	call   80124e <fd2data>
  801473:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801475:	89 1c 24             	mov    %ebx,(%esp)
  801478:	e8 d1 fd ff ff       	call   80124e <fd2data>
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801483:	89 f8                	mov    %edi,%eax
  801485:	c1 e8 16             	shr    $0x16,%eax
  801488:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80148f:	a8 01                	test   $0x1,%al
  801491:	74 37                	je     8014ca <dup+0x9b>
  801493:	89 f8                	mov    %edi,%eax
  801495:	c1 e8 0c             	shr    $0xc,%eax
  801498:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80149f:	f6 c2 01             	test   $0x1,%dl
  8014a2:	74 26                	je     8014ca <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8014b3:	50                   	push   %eax
  8014b4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014b7:	6a 00                	push   $0x0
  8014b9:	57                   	push   %edi
  8014ba:	6a 00                	push   $0x0
  8014bc:	e8 cd f8 ff ff       	call   800d8e <sys_page_map>
  8014c1:	89 c7                	mov    %eax,%edi
  8014c3:	83 c4 20             	add    $0x20,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 2e                	js     8014f8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8014cd:	89 d0                	mov    %edx,%eax
  8014cf:	c1 e8 0c             	shr    $0xc,%eax
  8014d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014e1:	50                   	push   %eax
  8014e2:	53                   	push   %ebx
  8014e3:	6a 00                	push   $0x0
  8014e5:	52                   	push   %edx
  8014e6:	6a 00                	push   $0x0
  8014e8:	e8 a1 f8 ff ff       	call   800d8e <sys_page_map>
  8014ed:	89 c7                	mov    %eax,%edi
  8014ef:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8014f2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014f4:	85 ff                	test   %edi,%edi
  8014f6:	79 1d                	jns    801515 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8014f8:	83 ec 08             	sub    $0x8,%esp
  8014fb:	53                   	push   %ebx
  8014fc:	6a 00                	push   $0x0
  8014fe:	e8 cd f8 ff ff       	call   800dd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801503:	83 c4 08             	add    $0x8,%esp
  801506:	ff 75 d4             	pushl  -0x2c(%ebp)
  801509:	6a 00                	push   $0x0
  80150b:	e8 c0 f8 ff ff       	call   800dd0 <sys_page_unmap>
	return r;
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	89 f8                	mov    %edi,%eax
}
  801515:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801518:	5b                   	pop    %ebx
  801519:	5e                   	pop    %esi
  80151a:	5f                   	pop    %edi
  80151b:	5d                   	pop    %ebp
  80151c:	c3                   	ret    

0080151d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80151d:	55                   	push   %ebp
  80151e:	89 e5                	mov    %esp,%ebp
  801520:	53                   	push   %ebx
  801521:	83 ec 14             	sub    $0x14,%esp
  801524:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801527:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80152a:	50                   	push   %eax
  80152b:	53                   	push   %ebx
  80152c:	e8 83 fd ff ff       	call   8012b4 <fd_lookup>
  801531:	83 c4 08             	add    $0x8,%esp
  801534:	89 c2                	mov    %eax,%edx
  801536:	85 c0                	test   %eax,%eax
  801538:	78 6d                	js     8015a7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801544:	ff 30                	pushl  (%eax)
  801546:	e8 bf fd ff ff       	call   80130a <dev_lookup>
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 4c                	js     80159e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801552:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801555:	8b 42 08             	mov    0x8(%edx),%eax
  801558:	83 e0 03             	and    $0x3,%eax
  80155b:	83 f8 01             	cmp    $0x1,%eax
  80155e:	75 21                	jne    801581 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801560:	a1 04 40 80 00       	mov    0x804004,%eax
  801565:	8b 40 48             	mov    0x48(%eax),%eax
  801568:	83 ec 04             	sub    $0x4,%esp
  80156b:	53                   	push   %ebx
  80156c:	50                   	push   %eax
  80156d:	68 1d 29 80 00       	push   $0x80291d
  801572:	e8 46 ee ff ff       	call   8003bd <cprintf>
		return -E_INVAL;
  801577:	83 c4 10             	add    $0x10,%esp
  80157a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80157f:	eb 26                	jmp    8015a7 <read+0x8a>
	}
	if (!dev->dev_read)
  801581:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801584:	8b 40 08             	mov    0x8(%eax),%eax
  801587:	85 c0                	test   %eax,%eax
  801589:	74 17                	je     8015a2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	ff 75 10             	pushl  0x10(%ebp)
  801591:	ff 75 0c             	pushl  0xc(%ebp)
  801594:	52                   	push   %edx
  801595:	ff d0                	call   *%eax
  801597:	89 c2                	mov    %eax,%edx
  801599:	83 c4 10             	add    $0x10,%esp
  80159c:	eb 09                	jmp    8015a7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	eb 05                	jmp    8015a7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015a2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015a7:	89 d0                	mov    %edx,%eax
  8015a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ae:	55                   	push   %ebp
  8015af:	89 e5                	mov    %esp,%ebp
  8015b1:	57                   	push   %edi
  8015b2:	56                   	push   %esi
  8015b3:	53                   	push   %ebx
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ba:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015bd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c2:	eb 21                	jmp    8015e5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c4:	83 ec 04             	sub    $0x4,%esp
  8015c7:	89 f0                	mov    %esi,%eax
  8015c9:	29 d8                	sub    %ebx,%eax
  8015cb:	50                   	push   %eax
  8015cc:	89 d8                	mov    %ebx,%eax
  8015ce:	03 45 0c             	add    0xc(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	57                   	push   %edi
  8015d3:	e8 45 ff ff ff       	call   80151d <read>
		if (m < 0)
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 0c                	js     8015eb <readn+0x3d>
			return m;
		if (m == 0)
  8015df:	85 c0                	test   %eax,%eax
  8015e1:	74 06                	je     8015e9 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e3:	01 c3                	add    %eax,%ebx
  8015e5:	39 f3                	cmp    %esi,%ebx
  8015e7:	72 db                	jb     8015c4 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8015e9:	89 d8                	mov    %ebx,%eax
}
  8015eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5f                   	pop    %edi
  8015f1:	5d                   	pop    %ebp
  8015f2:	c3                   	ret    

008015f3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	53                   	push   %ebx
  8015f7:	83 ec 14             	sub    $0x14,%esp
  8015fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801600:	50                   	push   %eax
  801601:	53                   	push   %ebx
  801602:	e8 ad fc ff ff       	call   8012b4 <fd_lookup>
  801607:	83 c4 08             	add    $0x8,%esp
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	85 c0                	test   %eax,%eax
  80160e:	78 68                	js     801678 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80161a:	ff 30                	pushl  (%eax)
  80161c:	e8 e9 fc ff ff       	call   80130a <dev_lookup>
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	85 c0                	test   %eax,%eax
  801626:	78 47                	js     80166f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801628:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80162b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80162f:	75 21                	jne    801652 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801631:	a1 04 40 80 00       	mov    0x804004,%eax
  801636:	8b 40 48             	mov    0x48(%eax),%eax
  801639:	83 ec 04             	sub    $0x4,%esp
  80163c:	53                   	push   %ebx
  80163d:	50                   	push   %eax
  80163e:	68 39 29 80 00       	push   $0x802939
  801643:	e8 75 ed ff ff       	call   8003bd <cprintf>
		return -E_INVAL;
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801650:	eb 26                	jmp    801678 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801652:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801655:	8b 52 0c             	mov    0xc(%edx),%edx
  801658:	85 d2                	test   %edx,%edx
  80165a:	74 17                	je     801673 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80165c:	83 ec 04             	sub    $0x4,%esp
  80165f:	ff 75 10             	pushl  0x10(%ebp)
  801662:	ff 75 0c             	pushl  0xc(%ebp)
  801665:	50                   	push   %eax
  801666:	ff d2                	call   *%edx
  801668:	89 c2                	mov    %eax,%edx
  80166a:	83 c4 10             	add    $0x10,%esp
  80166d:	eb 09                	jmp    801678 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80166f:	89 c2                	mov    %eax,%edx
  801671:	eb 05                	jmp    801678 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801673:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801678:	89 d0                	mov    %edx,%eax
  80167a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <seek>:

int
seek(int fdnum, off_t offset)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801685:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801688:	50                   	push   %eax
  801689:	ff 75 08             	pushl  0x8(%ebp)
  80168c:	e8 23 fc ff ff       	call   8012b4 <fd_lookup>
  801691:	83 c4 08             	add    $0x8,%esp
  801694:	85 c0                	test   %eax,%eax
  801696:	78 0e                	js     8016a6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801698:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80169b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80169e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a6:	c9                   	leave  
  8016a7:	c3                   	ret    

008016a8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	53                   	push   %ebx
  8016ac:	83 ec 14             	sub    $0x14,%esp
  8016af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b5:	50                   	push   %eax
  8016b6:	53                   	push   %ebx
  8016b7:	e8 f8 fb ff ff       	call   8012b4 <fd_lookup>
  8016bc:	83 c4 08             	add    $0x8,%esp
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 65                	js     80172a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016cf:	ff 30                	pushl  (%eax)
  8016d1:	e8 34 fc ff ff       	call   80130a <dev_lookup>
  8016d6:	83 c4 10             	add    $0x10,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 44                	js     801721 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016e4:	75 21                	jne    801707 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016e6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016eb:	8b 40 48             	mov    0x48(%eax),%eax
  8016ee:	83 ec 04             	sub    $0x4,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	50                   	push   %eax
  8016f3:	68 fc 28 80 00       	push   $0x8028fc
  8016f8:	e8 c0 ec ff ff       	call   8003bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801705:	eb 23                	jmp    80172a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801707:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170a:	8b 52 18             	mov    0x18(%edx),%edx
  80170d:	85 d2                	test   %edx,%edx
  80170f:	74 14                	je     801725 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801711:	83 ec 08             	sub    $0x8,%esp
  801714:	ff 75 0c             	pushl  0xc(%ebp)
  801717:	50                   	push   %eax
  801718:	ff d2                	call   *%edx
  80171a:	89 c2                	mov    %eax,%edx
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	eb 09                	jmp    80172a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801721:	89 c2                	mov    %eax,%edx
  801723:	eb 05                	jmp    80172a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801725:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80172a:	89 d0                	mov    %edx,%eax
  80172c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	53                   	push   %ebx
  801735:	83 ec 14             	sub    $0x14,%esp
  801738:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80173e:	50                   	push   %eax
  80173f:	ff 75 08             	pushl  0x8(%ebp)
  801742:	e8 6d fb ff ff       	call   8012b4 <fd_lookup>
  801747:	83 c4 08             	add    $0x8,%esp
  80174a:	89 c2                	mov    %eax,%edx
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 58                	js     8017a8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175a:	ff 30                	pushl  (%eax)
  80175c:	e8 a9 fb ff ff       	call   80130a <dev_lookup>
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 37                	js     80179f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801768:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80176f:	74 32                	je     8017a3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801771:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801774:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177b:	00 00 00 
	stat->st_isdir = 0;
  80177e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801785:	00 00 00 
	stat->st_dev = dev;
  801788:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80178e:	83 ec 08             	sub    $0x8,%esp
  801791:	53                   	push   %ebx
  801792:	ff 75 f0             	pushl  -0x10(%ebp)
  801795:	ff 50 14             	call   *0x14(%eax)
  801798:	89 c2                	mov    %eax,%edx
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	eb 09                	jmp    8017a8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80179f:	89 c2                	mov    %eax,%edx
  8017a1:	eb 05                	jmp    8017a8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017a8:	89 d0                	mov    %edx,%eax
  8017aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ad:	c9                   	leave  
  8017ae:	c3                   	ret    

008017af <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	56                   	push   %esi
  8017b3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017b4:	83 ec 08             	sub    $0x8,%esp
  8017b7:	6a 00                	push   $0x0
  8017b9:	ff 75 08             	pushl  0x8(%ebp)
  8017bc:	e8 e7 01 00 00       	call   8019a8 <open>
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	83 c4 10             	add    $0x10,%esp
  8017c6:	85 db                	test   %ebx,%ebx
  8017c8:	78 1b                	js     8017e5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017ca:	83 ec 08             	sub    $0x8,%esp
  8017cd:	ff 75 0c             	pushl  0xc(%ebp)
  8017d0:	53                   	push   %ebx
  8017d1:	e8 5b ff ff ff       	call   801731 <fstat>
  8017d6:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d8:	89 1c 24             	mov    %ebx,(%esp)
  8017db:	e8 fd fb ff ff       	call   8013dd <close>
	return r;
  8017e0:	83 c4 10             	add    $0x10,%esp
  8017e3:	89 f0                	mov    %esi,%eax
}
  8017e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e8:	5b                   	pop    %ebx
  8017e9:	5e                   	pop    %esi
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	56                   	push   %esi
  8017f0:	53                   	push   %ebx
  8017f1:	89 c6                	mov    %eax,%esi
  8017f3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8017fc:	75 12                	jne    801810 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017fe:	83 ec 0c             	sub    $0xc,%esp
  801801:	6a 03                	push   $0x3
  801803:	e8 69 08 00 00       	call   802071 <ipc_find_env>
  801808:	a3 00 40 80 00       	mov    %eax,0x804000
  80180d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801810:	6a 07                	push   $0x7
  801812:	68 00 50 80 00       	push   $0x805000
  801817:	56                   	push   %esi
  801818:	ff 35 00 40 80 00    	pushl  0x804000
  80181e:	e8 fd 07 00 00       	call   802020 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801823:	83 c4 0c             	add    $0xc,%esp
  801826:	6a 00                	push   $0x0
  801828:	53                   	push   %ebx
  801829:	6a 00                	push   $0x0
  80182b:	e8 8a 07 00 00       	call   801fba <ipc_recv>
}
  801830:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801833:	5b                   	pop    %ebx
  801834:	5e                   	pop    %esi
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183d:	8b 45 08             	mov    0x8(%ebp),%eax
  801840:	8b 40 0c             	mov    0xc(%eax),%eax
  801843:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801848:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801850:	ba 00 00 00 00       	mov    $0x0,%edx
  801855:	b8 02 00 00 00       	mov    $0x2,%eax
  80185a:	e8 8d ff ff ff       	call   8017ec <fsipc>
}
  80185f:	c9                   	leave  
  801860:	c3                   	ret    

00801861 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801861:	55                   	push   %ebp
  801862:	89 e5                	mov    %esp,%ebp
  801864:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801867:	8b 45 08             	mov    0x8(%ebp),%eax
  80186a:	8b 40 0c             	mov    0xc(%eax),%eax
  80186d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801872:	ba 00 00 00 00       	mov    $0x0,%edx
  801877:	b8 06 00 00 00       	mov    $0x6,%eax
  80187c:	e8 6b ff ff ff       	call   8017ec <fsipc>
}
  801881:	c9                   	leave  
  801882:	c3                   	ret    

00801883 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801883:	55                   	push   %ebp
  801884:	89 e5                	mov    %esp,%ebp
  801886:	53                   	push   %ebx
  801887:	83 ec 04             	sub    $0x4,%esp
  80188a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80188d:	8b 45 08             	mov    0x8(%ebp),%eax
  801890:	8b 40 0c             	mov    0xc(%eax),%eax
  801893:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801898:	ba 00 00 00 00       	mov    $0x0,%edx
  80189d:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a2:	e8 45 ff ff ff       	call   8017ec <fsipc>
  8018a7:	89 c2                	mov    %eax,%edx
  8018a9:	85 d2                	test   %edx,%edx
  8018ab:	78 2c                	js     8018d9 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018ad:	83 ec 08             	sub    $0x8,%esp
  8018b0:	68 00 50 80 00       	push   $0x805000
  8018b5:	53                   	push   %ebx
  8018b6:	e8 86 f0 ff ff       	call   800941 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018bb:	a1 80 50 80 00       	mov    0x805080,%eax
  8018c0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c6:	a1 84 50 80 00       	mov    0x805084,%eax
  8018cb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	83 ec 08             	sub    $0x8,%esp
  8018e4:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8018e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8018ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ed:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8018f3:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8018f8:	76 05                	jbe    8018ff <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8018fa:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8018ff:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801904:	83 ec 04             	sub    $0x4,%esp
  801907:	50                   	push   %eax
  801908:	ff 75 0c             	pushl  0xc(%ebp)
  80190b:	68 08 50 80 00       	push   $0x805008
  801910:	e8 be f1 ff ff       	call   800ad3 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801915:	ba 00 00 00 00       	mov    $0x0,%edx
  80191a:	b8 04 00 00 00       	mov    $0x4,%eax
  80191f:	e8 c8 fe ff ff       	call   8017ec <fsipc>
	return write;
}
  801924:	c9                   	leave  
  801925:	c3                   	ret    

00801926 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
  80192b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801939:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80193f:	ba 00 00 00 00       	mov    $0x0,%edx
  801944:	b8 03 00 00 00       	mov    $0x3,%eax
  801949:	e8 9e fe ff ff       	call   8017ec <fsipc>
  80194e:	89 c3                	mov    %eax,%ebx
  801950:	85 c0                	test   %eax,%eax
  801952:	78 4b                	js     80199f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801954:	39 c6                	cmp    %eax,%esi
  801956:	73 16                	jae    80196e <devfile_read+0x48>
  801958:	68 68 29 80 00       	push   $0x802968
  80195d:	68 6f 29 80 00       	push   $0x80296f
  801962:	6a 7c                	push   $0x7c
  801964:	68 84 29 80 00       	push   $0x802984
  801969:	e8 76 e9 ff ff       	call   8002e4 <_panic>
	assert(r <= PGSIZE);
  80196e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801973:	7e 16                	jle    80198b <devfile_read+0x65>
  801975:	68 8f 29 80 00       	push   $0x80298f
  80197a:	68 6f 29 80 00       	push   $0x80296f
  80197f:	6a 7d                	push   $0x7d
  801981:	68 84 29 80 00       	push   $0x802984
  801986:	e8 59 e9 ff ff       	call   8002e4 <_panic>
	memmove(buf, &fsipcbuf, r);
  80198b:	83 ec 04             	sub    $0x4,%esp
  80198e:	50                   	push   %eax
  80198f:	68 00 50 80 00       	push   $0x805000
  801994:	ff 75 0c             	pushl  0xc(%ebp)
  801997:	e8 37 f1 ff ff       	call   800ad3 <memmove>
	return r;
  80199c:	83 c4 10             	add    $0x10,%esp
}
  80199f:	89 d8                	mov    %ebx,%eax
  8019a1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019a4:	5b                   	pop    %ebx
  8019a5:	5e                   	pop    %esi
  8019a6:	5d                   	pop    %ebp
  8019a7:	c3                   	ret    

008019a8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019a8:	55                   	push   %ebp
  8019a9:	89 e5                	mov    %esp,%ebp
  8019ab:	53                   	push   %ebx
  8019ac:	83 ec 20             	sub    $0x20,%esp
  8019af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019b2:	53                   	push   %ebx
  8019b3:	e8 50 ef ff ff       	call   800908 <strlen>
  8019b8:	83 c4 10             	add    $0x10,%esp
  8019bb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019c0:	7f 67                	jg     801a29 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019c2:	83 ec 0c             	sub    $0xc,%esp
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	e8 97 f8 ff ff       	call   801265 <fd_alloc>
  8019ce:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 57                	js     801a2e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8019d7:	83 ec 08             	sub    $0x8,%esp
  8019da:	53                   	push   %ebx
  8019db:	68 00 50 80 00       	push   $0x805000
  8019e0:	e8 5c ef ff ff       	call   800941 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019ed:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019f0:	b8 01 00 00 00       	mov    $0x1,%eax
  8019f5:	e8 f2 fd ff ff       	call   8017ec <fsipc>
  8019fa:	89 c3                	mov    %eax,%ebx
  8019fc:	83 c4 10             	add    $0x10,%esp
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	79 14                	jns    801a17 <open+0x6f>
		fd_close(fd, 0);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	6a 00                	push   $0x0
  801a08:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0b:	e8 4d f9 ff ff       	call   80135d <fd_close>
		return r;
  801a10:	83 c4 10             	add    $0x10,%esp
  801a13:	89 da                	mov    %ebx,%edx
  801a15:	eb 17                	jmp    801a2e <open+0x86>
	}

	return fd2num(fd);
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801a1d:	e8 1c f8 ff ff       	call   80123e <fd2num>
  801a22:	89 c2                	mov    %eax,%edx
  801a24:	83 c4 10             	add    $0x10,%esp
  801a27:	eb 05                	jmp    801a2e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a29:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a2e:	89 d0                	mov    %edx,%eax
  801a30:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a40:	b8 08 00 00 00       	mov    $0x8,%eax
  801a45:	e8 a2 fd ff ff       	call   8017ec <fsipc>
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a4c:	55                   	push   %ebp
  801a4d:	89 e5                	mov    %esp,%ebp
  801a4f:	56                   	push   %esi
  801a50:	53                   	push   %ebx
  801a51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	ff 75 08             	pushl  0x8(%ebp)
  801a5a:	e8 ef f7 ff ff       	call   80124e <fd2data>
  801a5f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a61:	83 c4 08             	add    $0x8,%esp
  801a64:	68 9b 29 80 00       	push   $0x80299b
  801a69:	53                   	push   %ebx
  801a6a:	e8 d2 ee ff ff       	call   800941 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a6f:	8b 56 04             	mov    0x4(%esi),%edx
  801a72:	89 d0                	mov    %edx,%eax
  801a74:	2b 06                	sub    (%esi),%eax
  801a76:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a7c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a83:	00 00 00 
	stat->st_dev = &devpipe;
  801a86:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a8d:	30 80 00 
	return 0;
}
  801a90:	b8 00 00 00 00       	mov    $0x0,%eax
  801a95:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a98:	5b                   	pop    %ebx
  801a99:	5e                   	pop    %esi
  801a9a:	5d                   	pop    %ebp
  801a9b:	c3                   	ret    

00801a9c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	53                   	push   %ebx
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801aa6:	53                   	push   %ebx
  801aa7:	6a 00                	push   $0x0
  801aa9:	e8 22 f3 ff ff       	call   800dd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aae:	89 1c 24             	mov    %ebx,(%esp)
  801ab1:	e8 98 f7 ff ff       	call   80124e <fd2data>
  801ab6:	83 c4 08             	add    $0x8,%esp
  801ab9:	50                   	push   %eax
  801aba:	6a 00                	push   $0x0
  801abc:	e8 0f f3 ff ff       	call   800dd0 <sys_page_unmap>
}
  801ac1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	57                   	push   %edi
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	83 ec 1c             	sub    $0x1c,%esp
  801acf:	89 c7                	mov    %eax,%edi
  801ad1:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801ad3:	a1 04 40 80 00       	mov    0x804004,%eax
  801ad8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801adb:	83 ec 0c             	sub    $0xc,%esp
  801ade:	57                   	push   %edi
  801adf:	e8 c5 05 00 00       	call   8020a9 <pageref>
  801ae4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ae7:	89 34 24             	mov    %esi,(%esp)
  801aea:	e8 ba 05 00 00       	call   8020a9 <pageref>
  801aef:	83 c4 10             	add    $0x10,%esp
  801af2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801af5:	0f 94 c0             	sete   %al
  801af8:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801afb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b01:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b04:	39 cb                	cmp    %ecx,%ebx
  801b06:	74 15                	je     801b1d <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801b08:	8b 52 58             	mov    0x58(%edx),%edx
  801b0b:	50                   	push   %eax
  801b0c:	52                   	push   %edx
  801b0d:	53                   	push   %ebx
  801b0e:	68 a8 29 80 00       	push   $0x8029a8
  801b13:	e8 a5 e8 ff ff       	call   8003bd <cprintf>
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	eb b6                	jmp    801ad3 <_pipeisclosed+0xd>
	}
}
  801b1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b20:	5b                   	pop    %ebx
  801b21:	5e                   	pop    %esi
  801b22:	5f                   	pop    %edi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	57                   	push   %edi
  801b29:	56                   	push   %esi
  801b2a:	53                   	push   %ebx
  801b2b:	83 ec 28             	sub    $0x28,%esp
  801b2e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b31:	56                   	push   %esi
  801b32:	e8 17 f7 ff ff       	call   80124e <fd2data>
  801b37:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b39:	83 c4 10             	add    $0x10,%esp
  801b3c:	bf 00 00 00 00       	mov    $0x0,%edi
  801b41:	eb 4b                	jmp    801b8e <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b43:	89 da                	mov    %ebx,%edx
  801b45:	89 f0                	mov    %esi,%eax
  801b47:	e8 7a ff ff ff       	call   801ac6 <_pipeisclosed>
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	75 48                	jne    801b98 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b50:	e8 d7 f1 ff ff       	call   800d2c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b55:	8b 43 04             	mov    0x4(%ebx),%eax
  801b58:	8b 0b                	mov    (%ebx),%ecx
  801b5a:	8d 51 20             	lea    0x20(%ecx),%edx
  801b5d:	39 d0                	cmp    %edx,%eax
  801b5f:	73 e2                	jae    801b43 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b64:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b68:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b6b:	89 c2                	mov    %eax,%edx
  801b6d:	c1 fa 1f             	sar    $0x1f,%edx
  801b70:	89 d1                	mov    %edx,%ecx
  801b72:	c1 e9 1b             	shr    $0x1b,%ecx
  801b75:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b78:	83 e2 1f             	and    $0x1f,%edx
  801b7b:	29 ca                	sub    %ecx,%edx
  801b7d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b81:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b85:	83 c0 01             	add    $0x1,%eax
  801b88:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b8b:	83 c7 01             	add    $0x1,%edi
  801b8e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b91:	75 c2                	jne    801b55 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b93:	8b 45 10             	mov    0x10(%ebp),%eax
  801b96:	eb 05                	jmp    801b9d <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b98:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	57                   	push   %edi
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	83 ec 18             	sub    $0x18,%esp
  801bae:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bb1:	57                   	push   %edi
  801bb2:	e8 97 f6 ff ff       	call   80124e <fd2data>
  801bb7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bc1:	eb 3d                	jmp    801c00 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801bc3:	85 db                	test   %ebx,%ebx
  801bc5:	74 04                	je     801bcb <devpipe_read+0x26>
				return i;
  801bc7:	89 d8                	mov    %ebx,%eax
  801bc9:	eb 44                	jmp    801c0f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801bcb:	89 f2                	mov    %esi,%edx
  801bcd:	89 f8                	mov    %edi,%eax
  801bcf:	e8 f2 fe ff ff       	call   801ac6 <_pipeisclosed>
  801bd4:	85 c0                	test   %eax,%eax
  801bd6:	75 32                	jne    801c0a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801bd8:	e8 4f f1 ff ff       	call   800d2c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801bdd:	8b 06                	mov    (%esi),%eax
  801bdf:	3b 46 04             	cmp    0x4(%esi),%eax
  801be2:	74 df                	je     801bc3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be4:	99                   	cltd   
  801be5:	c1 ea 1b             	shr    $0x1b,%edx
  801be8:	01 d0                	add    %edx,%eax
  801bea:	83 e0 1f             	and    $0x1f,%eax
  801bed:	29 d0                	sub    %edx,%eax
  801bef:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf7:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bfa:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfd:	83 c3 01             	add    $0x1,%ebx
  801c00:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c03:	75 d8                	jne    801bdd <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c05:	8b 45 10             	mov    0x10(%ebp),%eax
  801c08:	eb 05                	jmp    801c0f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c0a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	56                   	push   %esi
  801c1b:	53                   	push   %ebx
  801c1c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	e8 3d f6 ff ff       	call   801265 <fd_alloc>
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	89 c2                	mov    %eax,%edx
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 2c 01 00 00    	js     801d61 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c35:	83 ec 04             	sub    $0x4,%esp
  801c38:	68 07 04 00 00       	push   $0x407
  801c3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c40:	6a 00                	push   $0x0
  801c42:	e8 04 f1 ff ff       	call   800d4b <sys_page_alloc>
  801c47:	83 c4 10             	add    $0x10,%esp
  801c4a:	89 c2                	mov    %eax,%edx
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 0d 01 00 00    	js     801d61 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c54:	83 ec 0c             	sub    $0xc,%esp
  801c57:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c5a:	50                   	push   %eax
  801c5b:	e8 05 f6 ff ff       	call   801265 <fd_alloc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	0f 88 e2 00 00 00    	js     801d4f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6d:	83 ec 04             	sub    $0x4,%esp
  801c70:	68 07 04 00 00       	push   $0x407
  801c75:	ff 75 f0             	pushl  -0x10(%ebp)
  801c78:	6a 00                	push   $0x0
  801c7a:	e8 cc f0 ff ff       	call   800d4b <sys_page_alloc>
  801c7f:	89 c3                	mov    %eax,%ebx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	85 c0                	test   %eax,%eax
  801c86:	0f 88 c3 00 00 00    	js     801d4f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c8c:	83 ec 0c             	sub    $0xc,%esp
  801c8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c92:	e8 b7 f5 ff ff       	call   80124e <fd2data>
  801c97:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c99:	83 c4 0c             	add    $0xc,%esp
  801c9c:	68 07 04 00 00       	push   $0x407
  801ca1:	50                   	push   %eax
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 a2 f0 ff ff       	call   800d4b <sys_page_alloc>
  801ca9:	89 c3                	mov    %eax,%ebx
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	0f 88 89 00 00 00    	js     801d3f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	ff 75 f0             	pushl  -0x10(%ebp)
  801cbc:	e8 8d f5 ff ff       	call   80124e <fd2data>
  801cc1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cc8:	50                   	push   %eax
  801cc9:	6a 00                	push   $0x0
  801ccb:	56                   	push   %esi
  801ccc:	6a 00                	push   $0x0
  801cce:	e8 bb f0 ff ff       	call   800d8e <sys_page_map>
  801cd3:	89 c3                	mov    %eax,%ebx
  801cd5:	83 c4 20             	add    $0x20,%esp
  801cd8:	85 c0                	test   %eax,%eax
  801cda:	78 55                	js     801d31 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801cdc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cea:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cf1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cf7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cfa:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cfc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cff:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d06:	83 ec 0c             	sub    $0xc,%esp
  801d09:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0c:	e8 2d f5 ff ff       	call   80123e <fd2num>
  801d11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d14:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d16:	83 c4 04             	add    $0x4,%esp
  801d19:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1c:	e8 1d f5 ff ff       	call   80123e <fd2num>
  801d21:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d24:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d27:	83 c4 10             	add    $0x10,%esp
  801d2a:	ba 00 00 00 00       	mov    $0x0,%edx
  801d2f:	eb 30                	jmp    801d61 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d31:	83 ec 08             	sub    $0x8,%esp
  801d34:	56                   	push   %esi
  801d35:	6a 00                	push   $0x0
  801d37:	e8 94 f0 ff ff       	call   800dd0 <sys_page_unmap>
  801d3c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d3f:	83 ec 08             	sub    $0x8,%esp
  801d42:	ff 75 f0             	pushl  -0x10(%ebp)
  801d45:	6a 00                	push   $0x0
  801d47:	e8 84 f0 ff ff       	call   800dd0 <sys_page_unmap>
  801d4c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d4f:	83 ec 08             	sub    $0x8,%esp
  801d52:	ff 75 f4             	pushl  -0xc(%ebp)
  801d55:	6a 00                	push   $0x0
  801d57:	e8 74 f0 ff ff       	call   800dd0 <sys_page_unmap>
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d61:	89 d0                	mov    %edx,%eax
  801d63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d66:	5b                   	pop    %ebx
  801d67:	5e                   	pop    %esi
  801d68:	5d                   	pop    %ebp
  801d69:	c3                   	ret    

00801d6a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d70:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d73:	50                   	push   %eax
  801d74:	ff 75 08             	pushl  0x8(%ebp)
  801d77:	e8 38 f5 ff ff       	call   8012b4 <fd_lookup>
  801d7c:	89 c2                	mov    %eax,%edx
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	85 d2                	test   %edx,%edx
  801d83:	78 18                	js     801d9d <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d85:	83 ec 0c             	sub    $0xc,%esp
  801d88:	ff 75 f4             	pushl  -0xc(%ebp)
  801d8b:	e8 be f4 ff ff       	call   80124e <fd2data>
	return _pipeisclosed(fd, p);
  801d90:	89 c2                	mov    %eax,%edx
  801d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d95:	e8 2c fd ff ff       	call   801ac6 <_pipeisclosed>
  801d9a:	83 c4 10             	add    $0x10,%esp
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801da2:	b8 00 00 00 00       	mov    $0x0,%eax
  801da7:	5d                   	pop    %ebp
  801da8:	c3                   	ret    

00801da9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801daf:	68 d9 29 80 00       	push   $0x8029d9
  801db4:	ff 75 0c             	pushl  0xc(%ebp)
  801db7:	e8 85 eb ff ff       	call   800941 <strcpy>
	return 0;
}
  801dbc:	b8 00 00 00 00       	mov    $0x0,%eax
  801dc1:	c9                   	leave  
  801dc2:	c3                   	ret    

00801dc3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dc3:	55                   	push   %ebp
  801dc4:	89 e5                	mov    %esp,%ebp
  801dc6:	57                   	push   %edi
  801dc7:	56                   	push   %esi
  801dc8:	53                   	push   %ebx
  801dc9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dcf:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801dd4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dda:	eb 2e                	jmp    801e0a <devcons_write+0x47>
		m = n - tot;
  801ddc:	8b 55 10             	mov    0x10(%ebp),%edx
  801ddf:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801de1:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801de6:	83 fa 7f             	cmp    $0x7f,%edx
  801de9:	77 02                	ja     801ded <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801deb:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801ded:	83 ec 04             	sub    $0x4,%esp
  801df0:	56                   	push   %esi
  801df1:	03 45 0c             	add    0xc(%ebp),%eax
  801df4:	50                   	push   %eax
  801df5:	57                   	push   %edi
  801df6:	e8 d8 ec ff ff       	call   800ad3 <memmove>
		sys_cputs(buf, m);
  801dfb:	83 c4 08             	add    $0x8,%esp
  801dfe:	56                   	push   %esi
  801dff:	57                   	push   %edi
  801e00:	e8 8a ee ff ff       	call   800c8f <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e05:	01 f3                	add    %esi,%ebx
  801e07:	83 c4 10             	add    $0x10,%esp
  801e0a:	89 d8                	mov    %ebx,%eax
  801e0c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801e0f:	72 cb                	jb     801ddc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    

00801e19 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e19:	55                   	push   %ebp
  801e1a:	89 e5                	mov    %esp,%ebp
  801e1c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801e1f:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801e24:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e28:	75 07                	jne    801e31 <devcons_read+0x18>
  801e2a:	eb 28                	jmp    801e54 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e2c:	e8 fb ee ff ff       	call   800d2c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e31:	e8 77 ee ff ff       	call   800cad <sys_cgetc>
  801e36:	85 c0                	test   %eax,%eax
  801e38:	74 f2                	je     801e2c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e3a:	85 c0                	test   %eax,%eax
  801e3c:	78 16                	js     801e54 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e3e:	83 f8 04             	cmp    $0x4,%eax
  801e41:	74 0c                	je     801e4f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e46:	88 02                	mov    %al,(%edx)
	return 1;
  801e48:	b8 01 00 00 00       	mov    $0x1,%eax
  801e4d:	eb 05                	jmp    801e54 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e4f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e54:	c9                   	leave  
  801e55:	c3                   	ret    

00801e56 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e56:	55                   	push   %ebp
  801e57:	89 e5                	mov    %esp,%ebp
  801e59:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e62:	6a 01                	push   $0x1
  801e64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e67:	50                   	push   %eax
  801e68:	e8 22 ee ff ff       	call   800c8f <sys_cputs>
  801e6d:	83 c4 10             	add    $0x10,%esp
}
  801e70:	c9                   	leave  
  801e71:	c3                   	ret    

00801e72 <getchar>:

int
getchar(void)
{
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e78:	6a 01                	push   $0x1
  801e7a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e7d:	50                   	push   %eax
  801e7e:	6a 00                	push   $0x0
  801e80:	e8 98 f6 ff ff       	call   80151d <read>
	if (r < 0)
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	78 0f                	js     801e9b <getchar+0x29>
		return r;
	if (r < 1)
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	7e 06                	jle    801e96 <getchar+0x24>
		return -E_EOF;
	return c;
  801e90:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e94:	eb 05                	jmp    801e9b <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e96:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e9b:	c9                   	leave  
  801e9c:	c3                   	ret    

00801e9d <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e9d:	55                   	push   %ebp
  801e9e:	89 e5                	mov    %esp,%ebp
  801ea0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea6:	50                   	push   %eax
  801ea7:	ff 75 08             	pushl  0x8(%ebp)
  801eaa:	e8 05 f4 ff ff       	call   8012b4 <fd_lookup>
  801eaf:	83 c4 10             	add    $0x10,%esp
  801eb2:	85 c0                	test   %eax,%eax
  801eb4:	78 11                	js     801ec7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ebf:	39 10                	cmp    %edx,(%eax)
  801ec1:	0f 94 c0             	sete   %al
  801ec4:	0f b6 c0             	movzbl %al,%eax
}
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <opencons>:

int
opencons(void)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ecf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed2:	50                   	push   %eax
  801ed3:	e8 8d f3 ff ff       	call   801265 <fd_alloc>
  801ed8:	83 c4 10             	add    $0x10,%esp
		return r;
  801edb:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801edd:	85 c0                	test   %eax,%eax
  801edf:	78 3e                	js     801f1f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ee1:	83 ec 04             	sub    $0x4,%esp
  801ee4:	68 07 04 00 00       	push   $0x407
  801ee9:	ff 75 f4             	pushl  -0xc(%ebp)
  801eec:	6a 00                	push   $0x0
  801eee:	e8 58 ee ff ff       	call   800d4b <sys_page_alloc>
  801ef3:	83 c4 10             	add    $0x10,%esp
		return r;
  801ef6:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ef8:	85 c0                	test   %eax,%eax
  801efa:	78 23                	js     801f1f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801efc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	50                   	push   %eax
  801f15:	e8 24 f3 ff ff       	call   80123e <fd2num>
  801f1a:	89 c2                	mov    %eax,%edx
  801f1c:	83 c4 10             	add    $0x10,%esp
}
  801f1f:	89 d0                	mov    %edx,%eax
  801f21:	c9                   	leave  
  801f22:	c3                   	ret    

00801f23 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f23:	55                   	push   %ebp
  801f24:	89 e5                	mov    %esp,%ebp
  801f26:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801f29:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801f30:	75 2c                	jne    801f5e <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801f32:	83 ec 04             	sub    $0x4,%esp
  801f35:	6a 07                	push   $0x7
  801f37:	68 00 f0 7f ee       	push   $0xee7ff000
  801f3c:	6a 00                	push   $0x0
  801f3e:	e8 08 ee ff ff       	call   800d4b <sys_page_alloc>
  801f43:	83 c4 10             	add    $0x10,%esp
  801f46:	85 c0                	test   %eax,%eax
  801f48:	79 14                	jns    801f5e <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801f4a:	83 ec 04             	sub    $0x4,%esp
  801f4d:	68 e8 29 80 00       	push   $0x8029e8
  801f52:	6a 1f                	push   $0x1f
  801f54:	68 4c 2a 80 00       	push   $0x802a4c
  801f59:	e8 86 e3 ff ff       	call   8002e4 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f61:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801f66:	83 ec 08             	sub    $0x8,%esp
  801f69:	68 92 1f 80 00       	push   $0x801f92
  801f6e:	6a 00                	push   $0x0
  801f70:	e8 21 ef ff ff       	call   800e96 <sys_env_set_pgfault_upcall>
  801f75:	83 c4 10             	add    $0x10,%esp
  801f78:	85 c0                	test   %eax,%eax
  801f7a:	79 14                	jns    801f90 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801f7c:	83 ec 04             	sub    $0x4,%esp
  801f7f:	68 14 2a 80 00       	push   $0x802a14
  801f84:	6a 25                	push   $0x25
  801f86:	68 4c 2a 80 00       	push   $0x802a4c
  801f8b:	e8 54 e3 ff ff       	call   8002e4 <_panic>
}
  801f90:	c9                   	leave  
  801f91:	c3                   	ret    

00801f92 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801f92:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801f93:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801f98:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801f9a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  801f9d:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  801f9f:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  801fa3:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  801fa7:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  801fa8:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  801fab:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  801fad:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  801fb0:	83 c4 04             	add    $0x4,%esp
	popal 
  801fb3:	61                   	popa   
	addl $4, %esp 
  801fb4:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  801fb7:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  801fb8:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  801fb9:	c3                   	ret    

00801fba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fba:	55                   	push   %ebp
  801fbb:	89 e5                	mov    %esp,%ebp
  801fbd:	56                   	push   %esi
  801fbe:	53                   	push   %ebx
  801fbf:	8b 75 08             	mov    0x8(%ebp),%esi
  801fc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fc5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801fc8:	85 f6                	test   %esi,%esi
  801fca:	74 06                	je     801fd2 <ipc_recv+0x18>
  801fcc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801fd2:	85 db                	test   %ebx,%ebx
  801fd4:	74 06                	je     801fdc <ipc_recv+0x22>
  801fd6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801fdc:	83 f8 01             	cmp    $0x1,%eax
  801fdf:	19 d2                	sbb    %edx,%edx
  801fe1:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801fe3:	83 ec 0c             	sub    $0xc,%esp
  801fe6:	50                   	push   %eax
  801fe7:	e8 0f ef ff ff       	call   800efb <sys_ipc_recv>
  801fec:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801fee:	83 c4 10             	add    $0x10,%esp
  801ff1:	85 d2                	test   %edx,%edx
  801ff3:	75 24                	jne    802019 <ipc_recv+0x5f>
	if (from_env_store)
  801ff5:	85 f6                	test   %esi,%esi
  801ff7:	74 0a                	je     802003 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801ff9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ffe:	8b 40 70             	mov    0x70(%eax),%eax
  802001:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  802003:	85 db                	test   %ebx,%ebx
  802005:	74 0a                	je     802011 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  802007:	a1 04 40 80 00       	mov    0x804004,%eax
  80200c:	8b 40 74             	mov    0x74(%eax),%eax
  80200f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802011:	a1 04 40 80 00       	mov    0x804004,%eax
  802016:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  802019:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80201c:	5b                   	pop    %ebx
  80201d:	5e                   	pop    %esi
  80201e:	5d                   	pop    %ebp
  80201f:	c3                   	ret    

00802020 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	53                   	push   %ebx
  802026:	83 ec 0c             	sub    $0xc,%esp
  802029:	8b 7d 08             	mov    0x8(%ebp),%edi
  80202c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80202f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  802032:	83 fb 01             	cmp    $0x1,%ebx
  802035:	19 c0                	sbb    %eax,%eax
  802037:	09 c3                	or     %eax,%ebx
  802039:	eb 1c                	jmp    802057 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  80203b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80203e:	74 12                	je     802052 <ipc_send+0x32>
  802040:	50                   	push   %eax
  802041:	68 5a 2a 80 00       	push   $0x802a5a
  802046:	6a 36                	push   $0x36
  802048:	68 71 2a 80 00       	push   $0x802a71
  80204d:	e8 92 e2 ff ff       	call   8002e4 <_panic>
		sys_yield();
  802052:	e8 d5 ec ff ff       	call   800d2c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802057:	ff 75 14             	pushl  0x14(%ebp)
  80205a:	53                   	push   %ebx
  80205b:	56                   	push   %esi
  80205c:	57                   	push   %edi
  80205d:	e8 76 ee ff ff       	call   800ed8 <sys_ipc_try_send>
		if (ret == 0) break;
  802062:	83 c4 10             	add    $0x10,%esp
  802065:	85 c0                	test   %eax,%eax
  802067:	75 d2                	jne    80203b <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  802069:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80206c:	5b                   	pop    %ebx
  80206d:	5e                   	pop    %esi
  80206e:	5f                   	pop    %edi
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    

00802071 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802071:	55                   	push   %ebp
  802072:	89 e5                	mov    %esp,%ebp
  802074:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802077:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80207c:	6b d0 78             	imul   $0x78,%eax,%edx
  80207f:	83 c2 50             	add    $0x50,%edx
  802082:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  802088:	39 ca                	cmp    %ecx,%edx
  80208a:	75 0d                	jne    802099 <ipc_find_env+0x28>
			return envs[i].env_id;
  80208c:	6b c0 78             	imul   $0x78,%eax,%eax
  80208f:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802094:	8b 40 08             	mov    0x8(%eax),%eax
  802097:	eb 0e                	jmp    8020a7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802099:	83 c0 01             	add    $0x1,%eax
  80209c:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020a1:	75 d9                	jne    80207c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020a3:	66 b8 00 00          	mov    $0x0,%ax
}
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    

008020a9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020a9:	55                   	push   %ebp
  8020aa:	89 e5                	mov    %esp,%ebp
  8020ac:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020af:	89 d0                	mov    %edx,%eax
  8020b1:	c1 e8 16             	shr    $0x16,%eax
  8020b4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020bb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c0:	f6 c1 01             	test   $0x1,%cl
  8020c3:	74 1d                	je     8020e2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020c5:	c1 ea 0c             	shr    $0xc,%edx
  8020c8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020cf:	f6 c2 01             	test   $0x1,%dl
  8020d2:	74 0e                	je     8020e2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020d4:	c1 ea 0c             	shr    $0xc,%edx
  8020d7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020de:	ef 
  8020df:	0f b7 c0             	movzwl %ax,%eax
}
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    
  8020e4:	66 90                	xchg   %ax,%ax
  8020e6:	66 90                	xchg   %ax,%ax
  8020e8:	66 90                	xchg   %ax,%ax
  8020ea:	66 90                	xchg   %ax,%ax
  8020ec:	66 90                	xchg   %ax,%ax
  8020ee:	66 90                	xchg   %ax,%ax

008020f0 <__udivdi3>:
  8020f0:	55                   	push   %ebp
  8020f1:	57                   	push   %edi
  8020f2:	56                   	push   %esi
  8020f3:	83 ec 10             	sub    $0x10,%esp
  8020f6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8020fa:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8020fe:	8b 74 24 24          	mov    0x24(%esp),%esi
  802102:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802106:	85 d2                	test   %edx,%edx
  802108:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80210c:	89 34 24             	mov    %esi,(%esp)
  80210f:	89 c8                	mov    %ecx,%eax
  802111:	75 35                	jne    802148 <__udivdi3+0x58>
  802113:	39 f1                	cmp    %esi,%ecx
  802115:	0f 87 bd 00 00 00    	ja     8021d8 <__udivdi3+0xe8>
  80211b:	85 c9                	test   %ecx,%ecx
  80211d:	89 cd                	mov    %ecx,%ebp
  80211f:	75 0b                	jne    80212c <__udivdi3+0x3c>
  802121:	b8 01 00 00 00       	mov    $0x1,%eax
  802126:	31 d2                	xor    %edx,%edx
  802128:	f7 f1                	div    %ecx
  80212a:	89 c5                	mov    %eax,%ebp
  80212c:	89 f0                	mov    %esi,%eax
  80212e:	31 d2                	xor    %edx,%edx
  802130:	f7 f5                	div    %ebp
  802132:	89 c6                	mov    %eax,%esi
  802134:	89 f8                	mov    %edi,%eax
  802136:	f7 f5                	div    %ebp
  802138:	89 f2                	mov    %esi,%edx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	5e                   	pop    %esi
  80213e:	5f                   	pop    %edi
  80213f:	5d                   	pop    %ebp
  802140:	c3                   	ret    
  802141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802148:	3b 14 24             	cmp    (%esp),%edx
  80214b:	77 7b                	ja     8021c8 <__udivdi3+0xd8>
  80214d:	0f bd f2             	bsr    %edx,%esi
  802150:	83 f6 1f             	xor    $0x1f,%esi
  802153:	0f 84 97 00 00 00    	je     8021f0 <__udivdi3+0x100>
  802159:	bd 20 00 00 00       	mov    $0x20,%ebp
  80215e:	89 d7                	mov    %edx,%edi
  802160:	89 f1                	mov    %esi,%ecx
  802162:	29 f5                	sub    %esi,%ebp
  802164:	d3 e7                	shl    %cl,%edi
  802166:	89 c2                	mov    %eax,%edx
  802168:	89 e9                	mov    %ebp,%ecx
  80216a:	d3 ea                	shr    %cl,%edx
  80216c:	89 f1                	mov    %esi,%ecx
  80216e:	09 fa                	or     %edi,%edx
  802170:	8b 3c 24             	mov    (%esp),%edi
  802173:	d3 e0                	shl    %cl,%eax
  802175:	89 54 24 08          	mov    %edx,0x8(%esp)
  802179:	89 e9                	mov    %ebp,%ecx
  80217b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80217f:	8b 44 24 04          	mov    0x4(%esp),%eax
  802183:	89 fa                	mov    %edi,%edx
  802185:	d3 ea                	shr    %cl,%edx
  802187:	89 f1                	mov    %esi,%ecx
  802189:	d3 e7                	shl    %cl,%edi
  80218b:	89 e9                	mov    %ebp,%ecx
  80218d:	d3 e8                	shr    %cl,%eax
  80218f:	09 c7                	or     %eax,%edi
  802191:	89 f8                	mov    %edi,%eax
  802193:	f7 74 24 08          	divl   0x8(%esp)
  802197:	89 d5                	mov    %edx,%ebp
  802199:	89 c7                	mov    %eax,%edi
  80219b:	f7 64 24 0c          	mull   0xc(%esp)
  80219f:	39 d5                	cmp    %edx,%ebp
  8021a1:	89 14 24             	mov    %edx,(%esp)
  8021a4:	72 11                	jb     8021b7 <__udivdi3+0xc7>
  8021a6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021aa:	89 f1                	mov    %esi,%ecx
  8021ac:	d3 e2                	shl    %cl,%edx
  8021ae:	39 c2                	cmp    %eax,%edx
  8021b0:	73 5e                	jae    802210 <__udivdi3+0x120>
  8021b2:	3b 2c 24             	cmp    (%esp),%ebp
  8021b5:	75 59                	jne    802210 <__udivdi3+0x120>
  8021b7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021ba:	31 f6                	xor    %esi,%esi
  8021bc:	89 f2                	mov    %esi,%edx
  8021be:	83 c4 10             	add    $0x10,%esp
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	31 f6                	xor    %esi,%esi
  8021ca:	31 c0                	xor    %eax,%eax
  8021cc:	89 f2                	mov    %esi,%edx
  8021ce:	83 c4 10             	add    $0x10,%esp
  8021d1:	5e                   	pop    %esi
  8021d2:	5f                   	pop    %edi
  8021d3:	5d                   	pop    %ebp
  8021d4:	c3                   	ret    
  8021d5:	8d 76 00             	lea    0x0(%esi),%esi
  8021d8:	89 f2                	mov    %esi,%edx
  8021da:	31 f6                	xor    %esi,%esi
  8021dc:	89 f8                	mov    %edi,%eax
  8021de:	f7 f1                	div    %ecx
  8021e0:	89 f2                	mov    %esi,%edx
  8021e2:	83 c4 10             	add    $0x10,%esp
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8021f4:	76 0b                	jbe    802201 <__udivdi3+0x111>
  8021f6:	31 c0                	xor    %eax,%eax
  8021f8:	3b 14 24             	cmp    (%esp),%edx
  8021fb:	0f 83 37 ff ff ff    	jae    802138 <__udivdi3+0x48>
  802201:	b8 01 00 00 00       	mov    $0x1,%eax
  802206:	e9 2d ff ff ff       	jmp    802138 <__udivdi3+0x48>
  80220b:	90                   	nop
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 f8                	mov    %edi,%eax
  802212:	31 f6                	xor    %esi,%esi
  802214:	e9 1f ff ff ff       	jmp    802138 <__udivdi3+0x48>
  802219:	66 90                	xchg   %ax,%ax
  80221b:	66 90                	xchg   %ax,%ax
  80221d:	66 90                	xchg   %ax,%ax
  80221f:	90                   	nop

00802220 <__umoddi3>:
  802220:	55                   	push   %ebp
  802221:	57                   	push   %edi
  802222:	56                   	push   %esi
  802223:	83 ec 20             	sub    $0x20,%esp
  802226:	8b 44 24 34          	mov    0x34(%esp),%eax
  80222a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80222e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802232:	89 c6                	mov    %eax,%esi
  802234:	89 44 24 10          	mov    %eax,0x10(%esp)
  802238:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80223c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802240:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802244:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802248:	89 74 24 18          	mov    %esi,0x18(%esp)
  80224c:	85 c0                	test   %eax,%eax
  80224e:	89 c2                	mov    %eax,%edx
  802250:	75 1e                	jne    802270 <__umoddi3+0x50>
  802252:	39 f7                	cmp    %esi,%edi
  802254:	76 52                	jbe    8022a8 <__umoddi3+0x88>
  802256:	89 c8                	mov    %ecx,%eax
  802258:	89 f2                	mov    %esi,%edx
  80225a:	f7 f7                	div    %edi
  80225c:	89 d0                	mov    %edx,%eax
  80225e:	31 d2                	xor    %edx,%edx
  802260:	83 c4 20             	add    $0x20,%esp
  802263:	5e                   	pop    %esi
  802264:	5f                   	pop    %edi
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    
  802267:	89 f6                	mov    %esi,%esi
  802269:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802270:	39 f0                	cmp    %esi,%eax
  802272:	77 5c                	ja     8022d0 <__umoddi3+0xb0>
  802274:	0f bd e8             	bsr    %eax,%ebp
  802277:	83 f5 1f             	xor    $0x1f,%ebp
  80227a:	75 64                	jne    8022e0 <__umoddi3+0xc0>
  80227c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  802280:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  802284:	0f 86 f6 00 00 00    	jbe    802380 <__umoddi3+0x160>
  80228a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80228e:	0f 82 ec 00 00 00    	jb     802380 <__umoddi3+0x160>
  802294:	8b 44 24 14          	mov    0x14(%esp),%eax
  802298:	8b 54 24 18          	mov    0x18(%esp),%edx
  80229c:	83 c4 20             	add    $0x20,%esp
  80229f:	5e                   	pop    %esi
  8022a0:	5f                   	pop    %edi
  8022a1:	5d                   	pop    %ebp
  8022a2:	c3                   	ret    
  8022a3:	90                   	nop
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	85 ff                	test   %edi,%edi
  8022aa:	89 fd                	mov    %edi,%ebp
  8022ac:	75 0b                	jne    8022b9 <__umoddi3+0x99>
  8022ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8022b3:	31 d2                	xor    %edx,%edx
  8022b5:	f7 f7                	div    %edi
  8022b7:	89 c5                	mov    %eax,%ebp
  8022b9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022bd:	31 d2                	xor    %edx,%edx
  8022bf:	f7 f5                	div    %ebp
  8022c1:	89 c8                	mov    %ecx,%eax
  8022c3:	f7 f5                	div    %ebp
  8022c5:	eb 95                	jmp    80225c <__umoddi3+0x3c>
  8022c7:	89 f6                	mov    %esi,%esi
  8022c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	83 c4 20             	add    $0x20,%esp
  8022d7:	5e                   	pop    %esi
  8022d8:	5f                   	pop    %edi
  8022d9:	5d                   	pop    %ebp
  8022da:	c3                   	ret    
  8022db:	90                   	nop
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	b8 20 00 00 00       	mov    $0x20,%eax
  8022e5:	89 e9                	mov    %ebp,%ecx
  8022e7:	29 e8                	sub    %ebp,%eax
  8022e9:	d3 e2                	shl    %cl,%edx
  8022eb:	89 c7                	mov    %eax,%edi
  8022ed:	89 44 24 18          	mov    %eax,0x18(%esp)
  8022f1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022f5:	89 f9                	mov    %edi,%ecx
  8022f7:	d3 e8                	shr    %cl,%eax
  8022f9:	89 c1                	mov    %eax,%ecx
  8022fb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8022ff:	09 d1                	or     %edx,%ecx
  802301:	89 fa                	mov    %edi,%edx
  802303:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802307:	89 e9                	mov    %ebp,%ecx
  802309:	d3 e0                	shl    %cl,%eax
  80230b:	89 f9                	mov    %edi,%ecx
  80230d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802311:	89 f0                	mov    %esi,%eax
  802313:	d3 e8                	shr    %cl,%eax
  802315:	89 e9                	mov    %ebp,%ecx
  802317:	89 c7                	mov    %eax,%edi
  802319:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80231d:	d3 e6                	shl    %cl,%esi
  80231f:	89 d1                	mov    %edx,%ecx
  802321:	89 fa                	mov    %edi,%edx
  802323:	d3 e8                	shr    %cl,%eax
  802325:	89 e9                	mov    %ebp,%ecx
  802327:	09 f0                	or     %esi,%eax
  802329:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80232d:	f7 74 24 10          	divl   0x10(%esp)
  802331:	d3 e6                	shl    %cl,%esi
  802333:	89 d1                	mov    %edx,%ecx
  802335:	f7 64 24 0c          	mull   0xc(%esp)
  802339:	39 d1                	cmp    %edx,%ecx
  80233b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80233f:	89 d7                	mov    %edx,%edi
  802341:	89 c6                	mov    %eax,%esi
  802343:	72 0a                	jb     80234f <__umoddi3+0x12f>
  802345:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802349:	73 10                	jae    80235b <__umoddi3+0x13b>
  80234b:	39 d1                	cmp    %edx,%ecx
  80234d:	75 0c                	jne    80235b <__umoddi3+0x13b>
  80234f:	89 d7                	mov    %edx,%edi
  802351:	89 c6                	mov    %eax,%esi
  802353:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802357:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80235b:	89 ca                	mov    %ecx,%edx
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802363:	29 f0                	sub    %esi,%eax
  802365:	19 fa                	sbb    %edi,%edx
  802367:	d3 e8                	shr    %cl,%eax
  802369:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80236e:	89 d7                	mov    %edx,%edi
  802370:	d3 e7                	shl    %cl,%edi
  802372:	89 e9                	mov    %ebp,%ecx
  802374:	09 f8                	or     %edi,%eax
  802376:	d3 ea                	shr    %cl,%edx
  802378:	83 c4 20             	add    $0x20,%esp
  80237b:	5e                   	pop    %esi
  80237c:	5f                   	pop    %edi
  80237d:	5d                   	pop    %ebp
  80237e:	c3                   	ret    
  80237f:	90                   	nop
  802380:	8b 74 24 10          	mov    0x10(%esp),%esi
  802384:	29 f9                	sub    %edi,%ecx
  802386:	19 c6                	sbb    %eax,%esi
  802388:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80238c:	89 74 24 18          	mov    %esi,0x18(%esp)
  802390:	e9 ff fe ff ff       	jmp    802294 <__umoddi3+0x74>
