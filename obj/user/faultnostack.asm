
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 80 03 80 00       	push   $0x800380
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
  80004f:	83 c4 10             	add    $0x10,%esp
}
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 78             	imul   $0x78,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
  800090:	83 c4 10             	add    $0x10,%esp
#endif
}
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 cf 04 00 00       	call   800574 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
  8000af:	83 c4 10             	add    $0x10,%esp
}
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	8b 55 08             	mov    0x8(%ebp),%edx
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7e 17                	jle    80012a <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 ca 1e 80 00       	push   $0x801eca
  80011e:	6a 23                	push   $0x23
  800120:	68 e7 1e 80 00       	push   $0x801ee7
  800125:	e8 63 0f 00 00       	call   80108d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7e 17                	jle    8001ab <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 ca 1e 80 00       	push   $0x801eca
  80019f:	6a 23                	push   $0x23
  8001a1:	68 e7 1e 80 00       	push   $0x801ee7
  8001a6:	e8 e2 0e 00 00       	call   80108d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ae:	5b                   	pop    %ebx
  8001af:	5e                   	pop    %esi
  8001b0:	5f                   	pop    %edi
  8001b1:	5d                   	pop    %ebp
  8001b2:	c3                   	ret    

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7e 17                	jle    8001ed <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 ca 1e 80 00       	push   $0x801eca
  8001e1:	6a 23                	push   $0x23
  8001e3:	68 e7 1e 80 00       	push   $0x801ee7
  8001e8:	e8 a0 0e 00 00       	call   80108d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f0:	5b                   	pop    %ebx
  8001f1:	5e                   	pop    %esi
  8001f2:	5f                   	pop    %edi
  8001f3:	5d                   	pop    %ebp
  8001f4:	c3                   	ret    

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020b:	8b 55 08             	mov    0x8(%ebp),%edx
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7e 17                	jle    80022f <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 ca 1e 80 00       	push   $0x801eca
  800223:	6a 23                	push   $0x23
  800225:	68 e7 1e 80 00       	push   $0x801ee7
  80022a:	e8 5e 0e 00 00       	call   80108d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800232:	5b                   	pop    %ebx
  800233:	5e                   	pop    %esi
  800234:	5f                   	pop    %edi
  800235:	5d                   	pop    %ebp
  800236:	c3                   	ret    

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024d:	8b 55 08             	mov    0x8(%ebp),%edx
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7e 17                	jle    800271 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 ca 1e 80 00       	push   $0x801eca
  800265:	6a 23                	push   $0x23
  800267:	68 e7 1e 80 00       	push   $0x801ee7
  80026c:	e8 1c 0e 00 00       	call   80108d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800274:	5b                   	pop    %ebx
  800275:	5e                   	pop    %esi
  800276:	5f                   	pop    %edi
  800277:	5d                   	pop    %ebp
  800278:	c3                   	ret    

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028f:	8b 55 08             	mov    0x8(%ebp),%edx
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7e 17                	jle    8002b3 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 ca 1e 80 00       	push   $0x801eca
  8002a7:	6a 23                	push   $0x23
  8002a9:	68 e7 1e 80 00       	push   $0x801ee7
  8002ae:	e8 da 0d 00 00       	call   80108d <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b6:	5b                   	pop    %ebx
  8002b7:	5e                   	pop    %esi
  8002b8:	5f                   	pop    %edi
  8002b9:	5d                   	pop    %ebp
  8002ba:	c3                   	ret    

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7e 17                	jle    8002f5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002de:	83 ec 0c             	sub    $0xc,%esp
  8002e1:	50                   	push   %eax
  8002e2:	6a 0a                	push   $0xa
  8002e4:	68 ca 1e 80 00       	push   $0x801eca
  8002e9:	6a 23                	push   $0x23
  8002eb:	68 e7 1e 80 00       	push   $0x801ee7
  8002f0:	e8 98 0d 00 00       	call   80108d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f8:	5b                   	pop    %ebx
  8002f9:	5e                   	pop    %esi
  8002fa:	5f                   	pop    %edi
  8002fb:	5d                   	pop    %ebp
  8002fc:	c3                   	ret    

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800303:	be 00 00 00 00       	mov    $0x0,%esi
  800308:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	b8 0d 00 00 00       	mov    $0xd,%eax
  800333:	8b 55 08             	mov    0x8(%ebp),%edx
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7e 17                	jle    800359 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800342:	83 ec 0c             	sub    $0xc,%esp
  800345:	50                   	push   %eax
  800346:	6a 0d                	push   $0xd
  800348:	68 ca 1e 80 00       	push   $0x801eca
  80034d:	6a 23                	push   $0x23
  80034f:	68 e7 1e 80 00       	push   $0x801ee7
  800354:	e8 34 0d 00 00       	call   80108d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800359:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_gettime>:

int sys_gettime(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800371:	89 d1                	mov    %edx,%ecx
  800373:	89 d3                	mov    %edx,%ebx
  800375:	89 d7                	mov    %edx,%edi
  800377:	89 d6                	mov    %edx,%esi
  800379:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800380:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800381:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  800386:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800388:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  80038b:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  80038d:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  800391:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  800395:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  800396:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  800399:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  80039b:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  80039e:	83 c4 04             	add    $0x4,%esp
	popal 
  8003a1:	61                   	popa   
	addl $4, %esp 
  8003a2:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  8003a5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  8003a6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  8003a7:	c3                   	ret    

008003a8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a8:	55                   	push   %ebp
  8003a9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ae:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003be:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8003c3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003cd:	5d                   	pop    %ebp
  8003ce:	c3                   	ret    

008003cf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003cf:	55                   	push   %ebp
  8003d0:	89 e5                	mov    %esp,%ebp
  8003d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003d5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003da:	89 c2                	mov    %eax,%edx
  8003dc:	c1 ea 16             	shr    $0x16,%edx
  8003df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e6:	f6 c2 01             	test   $0x1,%dl
  8003e9:	74 11                	je     8003fc <fd_alloc+0x2d>
  8003eb:	89 c2                	mov    %eax,%edx
  8003ed:	c1 ea 0c             	shr    $0xc,%edx
  8003f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f7:	f6 c2 01             	test   $0x1,%dl
  8003fa:	75 09                	jne    800405 <fd_alloc+0x36>
			*fd_store = fd;
  8003fc:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800403:	eb 17                	jmp    80041c <fd_alloc+0x4d>
  800405:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80040a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80040f:	75 c9                	jne    8003da <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800411:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800417:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  80041c:	5d                   	pop    %ebp
  80041d:	c3                   	ret    

0080041e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800424:	83 f8 1f             	cmp    $0x1f,%eax
  800427:	77 36                	ja     80045f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800429:	c1 e0 0c             	shl    $0xc,%eax
  80042c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800431:	89 c2                	mov    %eax,%edx
  800433:	c1 ea 16             	shr    $0x16,%edx
  800436:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80043d:	f6 c2 01             	test   $0x1,%dl
  800440:	74 24                	je     800466 <fd_lookup+0x48>
  800442:	89 c2                	mov    %eax,%edx
  800444:	c1 ea 0c             	shr    $0xc,%edx
  800447:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044e:	f6 c2 01             	test   $0x1,%dl
  800451:	74 1a                	je     80046d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800453:	8b 55 0c             	mov    0xc(%ebp),%edx
  800456:	89 02                	mov    %eax,(%edx)
	return 0;
  800458:	b8 00 00 00 00       	mov    $0x0,%eax
  80045d:	eb 13                	jmp    800472 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800464:	eb 0c                	jmp    800472 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046b:	eb 05                	jmp    800472 <fd_lookup+0x54>
  80046d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800472:	5d                   	pop    %ebp
  800473:	c3                   	ret    

00800474 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800474:	55                   	push   %ebp
  800475:	89 e5                	mov    %esp,%ebp
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80047d:	ba 74 1f 80 00       	mov    $0x801f74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800482:	eb 13                	jmp    800497 <dev_lookup+0x23>
  800484:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800487:	39 08                	cmp    %ecx,(%eax)
  800489:	75 0c                	jne    800497 <dev_lookup+0x23>
			*dev = devtab[i];
  80048b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80048e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	eb 2e                	jmp    8004c5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800497:	8b 02                	mov    (%edx),%eax
  800499:	85 c0                	test   %eax,%eax
  80049b:	75 e7                	jne    800484 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80049d:	a1 04 40 80 00       	mov    0x804004,%eax
  8004a2:	8b 40 48             	mov    0x48(%eax),%eax
  8004a5:	83 ec 04             	sub    $0x4,%esp
  8004a8:	51                   	push   %ecx
  8004a9:	50                   	push   %eax
  8004aa:	68 f8 1e 80 00       	push   $0x801ef8
  8004af:	e8 b2 0c 00 00       	call   801166 <cprintf>
	*dev = 0;
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004c5:	c9                   	leave  
  8004c6:	c3                   	ret    

008004c7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004c7:	55                   	push   %ebp
  8004c8:	89 e5                	mov    %esp,%ebp
  8004ca:	56                   	push   %esi
  8004cb:	53                   	push   %ebx
  8004cc:	83 ec 10             	sub    $0x10,%esp
  8004cf:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d8:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004df:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e2:	50                   	push   %eax
  8004e3:	e8 36 ff ff ff       	call   80041e <fd_lookup>
  8004e8:	83 c4 08             	add    $0x8,%esp
  8004eb:	85 c0                	test   %eax,%eax
  8004ed:	78 05                	js     8004f4 <fd_close+0x2d>
	    || fd != fd2)
  8004ef:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004f2:	74 0b                	je     8004ff <fd_close+0x38>
		return (must_exist ? r : 0);
  8004f4:	80 fb 01             	cmp    $0x1,%bl
  8004f7:	19 d2                	sbb    %edx,%edx
  8004f9:	f7 d2                	not    %edx
  8004fb:	21 d0                	and    %edx,%eax
  8004fd:	eb 41                	jmp    800540 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800505:	50                   	push   %eax
  800506:	ff 36                	pushl  (%esi)
  800508:	e8 67 ff ff ff       	call   800474 <dev_lookup>
  80050d:	89 c3                	mov    %eax,%ebx
  80050f:	83 c4 10             	add    $0x10,%esp
  800512:	85 c0                	test   %eax,%eax
  800514:	78 1a                	js     800530 <fd_close+0x69>
		if (dev->dev_close)
  800516:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800519:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  80051c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800521:	85 c0                	test   %eax,%eax
  800523:	74 0b                	je     800530 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  800525:	83 ec 0c             	sub    $0xc,%esp
  800528:	56                   	push   %esi
  800529:	ff d0                	call   *%eax
  80052b:	89 c3                	mov    %eax,%ebx
  80052d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	56                   	push   %esi
  800534:	6a 00                	push   $0x0
  800536:	e8 ba fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	89 d8                	mov    %ebx,%eax
}
  800540:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800543:	5b                   	pop    %ebx
  800544:	5e                   	pop    %esi
  800545:	5d                   	pop    %ebp
  800546:	c3                   	ret    

00800547 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800550:	50                   	push   %eax
  800551:	ff 75 08             	pushl  0x8(%ebp)
  800554:	e8 c5 fe ff ff       	call   80041e <fd_lookup>
  800559:	89 c2                	mov    %eax,%edx
  80055b:	83 c4 08             	add    $0x8,%esp
  80055e:	85 d2                	test   %edx,%edx
  800560:	78 10                	js     800572 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	6a 01                	push   $0x1
  800567:	ff 75 f4             	pushl  -0xc(%ebp)
  80056a:	e8 58 ff ff ff       	call   8004c7 <fd_close>
  80056f:	83 c4 10             	add    $0x10,%esp
}
  800572:	c9                   	leave  
  800573:	c3                   	ret    

00800574 <close_all>:

void
close_all(void)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	53                   	push   %ebx
  800578:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80057b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800580:	83 ec 0c             	sub    $0xc,%esp
  800583:	53                   	push   %ebx
  800584:	e8 be ff ff ff       	call   800547 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800589:	83 c3 01             	add    $0x1,%ebx
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	83 fb 20             	cmp    $0x20,%ebx
  800592:	75 ec                	jne    800580 <close_all+0xc>
		close(i);
}
  800594:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800597:	c9                   	leave  
  800598:	c3                   	ret    

00800599 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800599:	55                   	push   %ebp
  80059a:	89 e5                	mov    %esp,%ebp
  80059c:	57                   	push   %edi
  80059d:	56                   	push   %esi
  80059e:	53                   	push   %ebx
  80059f:	83 ec 2c             	sub    $0x2c,%esp
  8005a2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a8:	50                   	push   %eax
  8005a9:	ff 75 08             	pushl  0x8(%ebp)
  8005ac:	e8 6d fe ff ff       	call   80041e <fd_lookup>
  8005b1:	89 c2                	mov    %eax,%edx
  8005b3:	83 c4 08             	add    $0x8,%esp
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	0f 88 c1 00 00 00    	js     80067f <dup+0xe6>
		return r;
	close(newfdnum);
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	56                   	push   %esi
  8005c2:	e8 80 ff ff ff       	call   800547 <close>

	newfd = INDEX2FD(newfdnum);
  8005c7:	89 f3                	mov    %esi,%ebx
  8005c9:	c1 e3 0c             	shl    $0xc,%ebx
  8005cc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005d2:	83 c4 04             	add    $0x4,%esp
  8005d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005d8:	e8 db fd ff ff       	call   8003b8 <fd2data>
  8005dd:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005df:	89 1c 24             	mov    %ebx,(%esp)
  8005e2:	e8 d1 fd ff ff       	call   8003b8 <fd2data>
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ed:	89 f8                	mov    %edi,%eax
  8005ef:	c1 e8 16             	shr    $0x16,%eax
  8005f2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f9:	a8 01                	test   $0x1,%al
  8005fb:	74 37                	je     800634 <dup+0x9b>
  8005fd:	89 f8                	mov    %edi,%eax
  8005ff:	c1 e8 0c             	shr    $0xc,%eax
  800602:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800609:	f6 c2 01             	test   $0x1,%dl
  80060c:	74 26                	je     800634 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80060e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800615:	83 ec 0c             	sub    $0xc,%esp
  800618:	25 07 0e 00 00       	and    $0xe07,%eax
  80061d:	50                   	push   %eax
  80061e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800621:	6a 00                	push   $0x0
  800623:	57                   	push   %edi
  800624:	6a 00                	push   $0x0
  800626:	e8 88 fb ff ff       	call   8001b3 <sys_page_map>
  80062b:	89 c7                	mov    %eax,%edi
  80062d:	83 c4 20             	add    $0x20,%esp
  800630:	85 c0                	test   %eax,%eax
  800632:	78 2e                	js     800662 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800634:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800637:	89 d0                	mov    %edx,%eax
  800639:	c1 e8 0c             	shr    $0xc,%eax
  80063c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800643:	83 ec 0c             	sub    $0xc,%esp
  800646:	25 07 0e 00 00       	and    $0xe07,%eax
  80064b:	50                   	push   %eax
  80064c:	53                   	push   %ebx
  80064d:	6a 00                	push   $0x0
  80064f:	52                   	push   %edx
  800650:	6a 00                	push   $0x0
  800652:	e8 5c fb ff ff       	call   8001b3 <sys_page_map>
  800657:	89 c7                	mov    %eax,%edi
  800659:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80065c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80065e:	85 ff                	test   %edi,%edi
  800660:	79 1d                	jns    80067f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	6a 00                	push   $0x0
  800668:	e8 88 fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80066d:	83 c4 08             	add    $0x8,%esp
  800670:	ff 75 d4             	pushl  -0x2c(%ebp)
  800673:	6a 00                	push   $0x0
  800675:	e8 7b fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	89 f8                	mov    %edi,%eax
}
  80067f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800682:	5b                   	pop    %ebx
  800683:	5e                   	pop    %esi
  800684:	5f                   	pop    %edi
  800685:	5d                   	pop    %ebp
  800686:	c3                   	ret    

00800687 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	53                   	push   %ebx
  80068b:	83 ec 14             	sub    $0x14,%esp
  80068e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800691:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800694:	50                   	push   %eax
  800695:	53                   	push   %ebx
  800696:	e8 83 fd ff ff       	call   80041e <fd_lookup>
  80069b:	83 c4 08             	add    $0x8,%esp
  80069e:	89 c2                	mov    %eax,%edx
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	78 6d                	js     800711 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006aa:	50                   	push   %eax
  8006ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8006ae:	ff 30                	pushl  (%eax)
  8006b0:	e8 bf fd ff ff       	call   800474 <dev_lookup>
  8006b5:	83 c4 10             	add    $0x10,%esp
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	78 4c                	js     800708 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006bf:	8b 42 08             	mov    0x8(%edx),%eax
  8006c2:	83 e0 03             	and    $0x3,%eax
  8006c5:	83 f8 01             	cmp    $0x1,%eax
  8006c8:	75 21                	jne    8006eb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8006cf:	8b 40 48             	mov    0x48(%eax),%eax
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	50                   	push   %eax
  8006d7:	68 39 1f 80 00       	push   $0x801f39
  8006dc:	e8 85 0a 00 00       	call   801166 <cprintf>
		return -E_INVAL;
  8006e1:	83 c4 10             	add    $0x10,%esp
  8006e4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006e9:	eb 26                	jmp    800711 <read+0x8a>
	}
	if (!dev->dev_read)
  8006eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ee:	8b 40 08             	mov    0x8(%eax),%eax
  8006f1:	85 c0                	test   %eax,%eax
  8006f3:	74 17                	je     80070c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	ff 75 10             	pushl  0x10(%ebp)
  8006fb:	ff 75 0c             	pushl  0xc(%ebp)
  8006fe:	52                   	push   %edx
  8006ff:	ff d0                	call   *%eax
  800701:	89 c2                	mov    %eax,%edx
  800703:	83 c4 10             	add    $0x10,%esp
  800706:	eb 09                	jmp    800711 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800708:	89 c2                	mov    %eax,%edx
  80070a:	eb 05                	jmp    800711 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80070c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800711:	89 d0                	mov    %edx,%eax
  800713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800716:	c9                   	leave  
  800717:	c3                   	ret    

00800718 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	57                   	push   %edi
  80071c:	56                   	push   %esi
  80071d:	53                   	push   %ebx
  80071e:	83 ec 0c             	sub    $0xc,%esp
  800721:	8b 7d 08             	mov    0x8(%ebp),%edi
  800724:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800727:	bb 00 00 00 00       	mov    $0x0,%ebx
  80072c:	eb 21                	jmp    80074f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80072e:	83 ec 04             	sub    $0x4,%esp
  800731:	89 f0                	mov    %esi,%eax
  800733:	29 d8                	sub    %ebx,%eax
  800735:	50                   	push   %eax
  800736:	89 d8                	mov    %ebx,%eax
  800738:	03 45 0c             	add    0xc(%ebp),%eax
  80073b:	50                   	push   %eax
  80073c:	57                   	push   %edi
  80073d:	e8 45 ff ff ff       	call   800687 <read>
		if (m < 0)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	85 c0                	test   %eax,%eax
  800747:	78 0c                	js     800755 <readn+0x3d>
			return m;
		if (m == 0)
  800749:	85 c0                	test   %eax,%eax
  80074b:	74 06                	je     800753 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80074d:	01 c3                	add    %eax,%ebx
  80074f:	39 f3                	cmp    %esi,%ebx
  800751:	72 db                	jb     80072e <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800753:	89 d8                	mov    %ebx,%eax
}
  800755:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800758:	5b                   	pop    %ebx
  800759:	5e                   	pop    %esi
  80075a:	5f                   	pop    %edi
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	53                   	push   %ebx
  800761:	83 ec 14             	sub    $0x14,%esp
  800764:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800767:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80076a:	50                   	push   %eax
  80076b:	53                   	push   %ebx
  80076c:	e8 ad fc ff ff       	call   80041e <fd_lookup>
  800771:	83 c4 08             	add    $0x8,%esp
  800774:	89 c2                	mov    %eax,%edx
  800776:	85 c0                	test   %eax,%eax
  800778:	78 68                	js     8007e2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077a:	83 ec 08             	sub    $0x8,%esp
  80077d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800780:	50                   	push   %eax
  800781:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800784:	ff 30                	pushl  (%eax)
  800786:	e8 e9 fc ff ff       	call   800474 <dev_lookup>
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	85 c0                	test   %eax,%eax
  800790:	78 47                	js     8007d9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800795:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800799:	75 21                	jne    8007bc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80079b:	a1 04 40 80 00       	mov    0x804004,%eax
  8007a0:	8b 40 48             	mov    0x48(%eax),%eax
  8007a3:	83 ec 04             	sub    $0x4,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	50                   	push   %eax
  8007a8:	68 55 1f 80 00       	push   $0x801f55
  8007ad:	e8 b4 09 00 00       	call   801166 <cprintf>
		return -E_INVAL;
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007ba:	eb 26                	jmp    8007e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007bf:	8b 52 0c             	mov    0xc(%edx),%edx
  8007c2:	85 d2                	test   %edx,%edx
  8007c4:	74 17                	je     8007dd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c6:	83 ec 04             	sub    $0x4,%esp
  8007c9:	ff 75 10             	pushl  0x10(%ebp)
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	50                   	push   %eax
  8007d0:	ff d2                	call   *%edx
  8007d2:	89 c2                	mov    %eax,%edx
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	eb 09                	jmp    8007e2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d9:	89 c2                	mov    %eax,%edx
  8007db:	eb 05                	jmp    8007e2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007dd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007e2:	89 d0                	mov    %edx,%eax
  8007e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e7:	c9                   	leave  
  8007e8:	c3                   	ret    

008007e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e9:	55                   	push   %ebp
  8007ea:	89 e5                	mov    %esp,%ebp
  8007ec:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ef:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	ff 75 08             	pushl  0x8(%ebp)
  8007f6:	e8 23 fc ff ff       	call   80041e <fd_lookup>
  8007fb:	83 c4 08             	add    $0x8,%esp
  8007fe:	85 c0                	test   %eax,%eax
  800800:	78 0e                	js     800810 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800802:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
  800808:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80080b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800810:	c9                   	leave  
  800811:	c3                   	ret    

00800812 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800812:	55                   	push   %ebp
  800813:	89 e5                	mov    %esp,%ebp
  800815:	53                   	push   %ebx
  800816:	83 ec 14             	sub    $0x14,%esp
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	53                   	push   %ebx
  800821:	e8 f8 fb ff ff       	call   80041e <fd_lookup>
  800826:	83 c4 08             	add    $0x8,%esp
  800829:	89 c2                	mov    %eax,%edx
  80082b:	85 c0                	test   %eax,%eax
  80082d:	78 65                	js     800894 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800835:	50                   	push   %eax
  800836:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800839:	ff 30                	pushl  (%eax)
  80083b:	e8 34 fc ff ff       	call   800474 <dev_lookup>
  800840:	83 c4 10             	add    $0x10,%esp
  800843:	85 c0                	test   %eax,%eax
  800845:	78 44                	js     80088b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80084e:	75 21                	jne    800871 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800850:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800855:	8b 40 48             	mov    0x48(%eax),%eax
  800858:	83 ec 04             	sub    $0x4,%esp
  80085b:	53                   	push   %ebx
  80085c:	50                   	push   %eax
  80085d:	68 18 1f 80 00       	push   $0x801f18
  800862:	e8 ff 08 00 00       	call   801166 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800867:	83 c4 10             	add    $0x10,%esp
  80086a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80086f:	eb 23                	jmp    800894 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800871:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800874:	8b 52 18             	mov    0x18(%edx),%edx
  800877:	85 d2                	test   %edx,%edx
  800879:	74 14                	je     80088f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	ff 75 0c             	pushl  0xc(%ebp)
  800881:	50                   	push   %eax
  800882:	ff d2                	call   *%edx
  800884:	89 c2                	mov    %eax,%edx
  800886:	83 c4 10             	add    $0x10,%esp
  800889:	eb 09                	jmp    800894 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088b:	89 c2                	mov    %eax,%edx
  80088d:	eb 05                	jmp    800894 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80088f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800894:	89 d0                	mov    %edx,%eax
  800896:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800899:	c9                   	leave  
  80089a:	c3                   	ret    

0080089b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	83 ec 14             	sub    $0x14,%esp
  8008a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008a5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a8:	50                   	push   %eax
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 6d fb ff ff       	call   80041e <fd_lookup>
  8008b1:	83 c4 08             	add    $0x8,%esp
  8008b4:	89 c2                	mov    %eax,%edx
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 58                	js     800912 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c0:	50                   	push   %eax
  8008c1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008c4:	ff 30                	pushl  (%eax)
  8008c6:	e8 a9 fb ff ff       	call   800474 <dev_lookup>
  8008cb:	83 c4 10             	add    $0x10,%esp
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	78 37                	js     800909 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008d5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d9:	74 32                	je     80090d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008db:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008de:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008e5:	00 00 00 
	stat->st_isdir = 0;
  8008e8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ef:	00 00 00 
	stat->st_dev = dev;
  8008f2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	53                   	push   %ebx
  8008fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ff:	ff 50 14             	call   *0x14(%eax)
  800902:	89 c2                	mov    %eax,%edx
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	eb 09                	jmp    800912 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800909:	89 c2                	mov    %eax,%edx
  80090b:	eb 05                	jmp    800912 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80090d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800912:	89 d0                	mov    %edx,%eax
  800914:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800917:	c9                   	leave  
  800918:	c3                   	ret    

00800919 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800919:	55                   	push   %ebp
  80091a:	89 e5                	mov    %esp,%ebp
  80091c:	56                   	push   %esi
  80091d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80091e:	83 ec 08             	sub    $0x8,%esp
  800921:	6a 00                	push   $0x0
  800923:	ff 75 08             	pushl  0x8(%ebp)
  800926:	e8 e7 01 00 00       	call   800b12 <open>
  80092b:	89 c3                	mov    %eax,%ebx
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	85 db                	test   %ebx,%ebx
  800932:	78 1b                	js     80094f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800934:	83 ec 08             	sub    $0x8,%esp
  800937:	ff 75 0c             	pushl  0xc(%ebp)
  80093a:	53                   	push   %ebx
  80093b:	e8 5b ff ff ff       	call   80089b <fstat>
  800940:	89 c6                	mov    %eax,%esi
	close(fd);
  800942:	89 1c 24             	mov    %ebx,(%esp)
  800945:	e8 fd fb ff ff       	call   800547 <close>
	return r;
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	89 f0                	mov    %esi,%eax
}
  80094f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	89 c6                	mov    %eax,%esi
  80095d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80095f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800966:	75 12                	jne    80097a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800968:	83 ec 0c             	sub    $0xc,%esp
  80096b:	6a 03                	push   $0x3
  80096d:	e8 ec 11 00 00       	call   801b5e <ipc_find_env>
  800972:	a3 00 40 80 00       	mov    %eax,0x804000
  800977:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80097a:	6a 07                	push   $0x7
  80097c:	68 00 50 80 00       	push   $0x805000
  800981:	56                   	push   %esi
  800982:	ff 35 00 40 80 00    	pushl  0x804000
  800988:	e8 80 11 00 00       	call   801b0d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80098d:	83 c4 0c             	add    $0xc,%esp
  800990:	6a 00                	push   $0x0
  800992:	53                   	push   %ebx
  800993:	6a 00                	push   $0x0
  800995:	e8 0d 11 00 00       	call   801aa7 <ipc_recv>
}
  80099a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80099d:	5b                   	pop    %ebx
  80099e:	5e                   	pop    %esi
  80099f:	5d                   	pop    %ebp
  8009a0:	c3                   	ret    

008009a1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009b5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8009c4:	e8 8d ff ff ff       	call   800956 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009e6:	e8 6b ff ff ff       	call   800956 <fsipc>
}
  8009eb:	c9                   	leave  
  8009ec:	c3                   	ret    

008009ed <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ed:	55                   	push   %ebp
  8009ee:	89 e5                	mov    %esp,%ebp
  8009f0:	53                   	push   %ebx
  8009f1:	83 ec 04             	sub    $0x4,%esp
  8009f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	b8 05 00 00 00       	mov    $0x5,%eax
  800a0c:	e8 45 ff ff ff       	call   800956 <fsipc>
  800a11:	89 c2                	mov    %eax,%edx
  800a13:	85 d2                	test   %edx,%edx
  800a15:	78 2c                	js     800a43 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a17:	83 ec 08             	sub    $0x8,%esp
  800a1a:	68 00 50 80 00       	push   $0x805000
  800a1f:	53                   	push   %ebx
  800a20:	e8 c5 0c 00 00       	call   8016ea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a25:	a1 80 50 80 00       	mov    0x805080,%eax
  800a2a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a30:	a1 84 50 80 00       	mov    0x805084,%eax
  800a35:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a3b:	83 c4 10             	add    $0x10,%esp
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	83 ec 08             	sub    $0x8,%esp
  800a4e:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a51:	8b 55 08             	mov    0x8(%ebp),%edx
  800a54:	8b 52 0c             	mov    0xc(%edx),%edx
  800a57:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a5d:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a62:	76 05                	jbe    800a69 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a64:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a69:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a6e:	83 ec 04             	sub    $0x4,%esp
  800a71:	50                   	push   %eax
  800a72:	ff 75 0c             	pushl  0xc(%ebp)
  800a75:	68 08 50 80 00       	push   $0x805008
  800a7a:	e8 fd 0d 00 00       	call   80187c <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a84:	b8 04 00 00 00       	mov    $0x4,%eax
  800a89:	e8 c8 fe ff ff       	call   800956 <fsipc>
	return write;
}
  800a8e:	c9                   	leave  
  800a8f:	c3                   	ret    

00800a90 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a90:	55                   	push   %ebp
  800a91:	89 e5                	mov    %esp,%ebp
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a98:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9b:	8b 40 0c             	mov    0xc(%eax),%eax
  800a9e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aa9:	ba 00 00 00 00       	mov    $0x0,%edx
  800aae:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab3:	e8 9e fe ff ff       	call   800956 <fsipc>
  800ab8:	89 c3                	mov    %eax,%ebx
  800aba:	85 c0                	test   %eax,%eax
  800abc:	78 4b                	js     800b09 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800abe:	39 c6                	cmp    %eax,%esi
  800ac0:	73 16                	jae    800ad8 <devfile_read+0x48>
  800ac2:	68 84 1f 80 00       	push   $0x801f84
  800ac7:	68 8b 1f 80 00       	push   $0x801f8b
  800acc:	6a 7c                	push   $0x7c
  800ace:	68 a0 1f 80 00       	push   $0x801fa0
  800ad3:	e8 b5 05 00 00       	call   80108d <_panic>
	assert(r <= PGSIZE);
  800ad8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800add:	7e 16                	jle    800af5 <devfile_read+0x65>
  800adf:	68 ab 1f 80 00       	push   $0x801fab
  800ae4:	68 8b 1f 80 00       	push   $0x801f8b
  800ae9:	6a 7d                	push   $0x7d
  800aeb:	68 a0 1f 80 00       	push   $0x801fa0
  800af0:	e8 98 05 00 00       	call   80108d <_panic>
	memmove(buf, &fsipcbuf, r);
  800af5:	83 ec 04             	sub    $0x4,%esp
  800af8:	50                   	push   %eax
  800af9:	68 00 50 80 00       	push   $0x805000
  800afe:	ff 75 0c             	pushl  0xc(%ebp)
  800b01:	e8 76 0d 00 00       	call   80187c <memmove>
	return r;
  800b06:	83 c4 10             	add    $0x10,%esp
}
  800b09:	89 d8                	mov    %ebx,%eax
  800b0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	53                   	push   %ebx
  800b16:	83 ec 20             	sub    $0x20,%esp
  800b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b1c:	53                   	push   %ebx
  800b1d:	e8 8f 0b 00 00       	call   8016b1 <strlen>
  800b22:	83 c4 10             	add    $0x10,%esp
  800b25:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b2a:	7f 67                	jg     800b93 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b2c:	83 ec 0c             	sub    $0xc,%esp
  800b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b32:	50                   	push   %eax
  800b33:	e8 97 f8 ff ff       	call   8003cf <fd_alloc>
  800b38:	83 c4 10             	add    $0x10,%esp
		return r;
  800b3b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	78 57                	js     800b98 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b41:	83 ec 08             	sub    $0x8,%esp
  800b44:	53                   	push   %ebx
  800b45:	68 00 50 80 00       	push   $0x805000
  800b4a:	e8 9b 0b 00 00       	call   8016ea <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b52:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b57:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b5a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b5f:	e8 f2 fd ff ff       	call   800956 <fsipc>
  800b64:	89 c3                	mov    %eax,%ebx
  800b66:	83 c4 10             	add    $0x10,%esp
  800b69:	85 c0                	test   %eax,%eax
  800b6b:	79 14                	jns    800b81 <open+0x6f>
		fd_close(fd, 0);
  800b6d:	83 ec 08             	sub    $0x8,%esp
  800b70:	6a 00                	push   $0x0
  800b72:	ff 75 f4             	pushl  -0xc(%ebp)
  800b75:	e8 4d f9 ff ff       	call   8004c7 <fd_close>
		return r;
  800b7a:	83 c4 10             	add    $0x10,%esp
  800b7d:	89 da                	mov    %ebx,%edx
  800b7f:	eb 17                	jmp    800b98 <open+0x86>
	}

	return fd2num(fd);
  800b81:	83 ec 0c             	sub    $0xc,%esp
  800b84:	ff 75 f4             	pushl  -0xc(%ebp)
  800b87:	e8 1c f8 ff ff       	call   8003a8 <fd2num>
  800b8c:	89 c2                	mov    %eax,%edx
  800b8e:	83 c4 10             	add    $0x10,%esp
  800b91:	eb 05                	jmp    800b98 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b93:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b98:	89 d0                	mov    %edx,%eax
  800b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  800baa:	b8 08 00 00 00       	mov    $0x8,%eax
  800baf:	e8 a2 fd ff ff       	call   800956 <fsipc>
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	ff 75 08             	pushl  0x8(%ebp)
  800bc4:	e8 ef f7 ff ff       	call   8003b8 <fd2data>
  800bc9:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bcb:	83 c4 08             	add    $0x8,%esp
  800bce:	68 b7 1f 80 00       	push   $0x801fb7
  800bd3:	53                   	push   %ebx
  800bd4:	e8 11 0b 00 00       	call   8016ea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bd9:	8b 56 04             	mov    0x4(%esi),%edx
  800bdc:	89 d0                	mov    %edx,%eax
  800bde:	2b 06                	sub    (%esi),%eax
  800be0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800be6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bed:	00 00 00 
	stat->st_dev = &devpipe;
  800bf0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bf7:	30 80 00 
	return 0;
}
  800bfa:	b8 00 00 00 00       	mov    $0x0,%eax
  800bff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 0c             	sub    $0xc,%esp
  800c0d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800c10:	53                   	push   %ebx
  800c11:	6a 00                	push   $0x0
  800c13:	e8 dd f5 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c18:	89 1c 24             	mov    %ebx,(%esp)
  800c1b:	e8 98 f7 ff ff       	call   8003b8 <fd2data>
  800c20:	83 c4 08             	add    $0x8,%esp
  800c23:	50                   	push   %eax
  800c24:	6a 00                	push   $0x0
  800c26:	e8 ca f5 ff ff       	call   8001f5 <sys_page_unmap>
}
  800c2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c2e:	c9                   	leave  
  800c2f:	c3                   	ret    

00800c30 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	57                   	push   %edi
  800c34:	56                   	push   %esi
  800c35:	53                   	push   %ebx
  800c36:	83 ec 1c             	sub    $0x1c,%esp
  800c39:	89 c7                	mov    %eax,%edi
  800c3b:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c3d:	a1 04 40 80 00       	mov    0x804004,%eax
  800c42:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c45:	83 ec 0c             	sub    $0xc,%esp
  800c48:	57                   	push   %edi
  800c49:	e8 48 0f 00 00       	call   801b96 <pageref>
  800c4e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c51:	89 34 24             	mov    %esi,(%esp)
  800c54:	e8 3d 0f 00 00       	call   801b96 <pageref>
  800c59:	83 c4 10             	add    $0x10,%esp
  800c5c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c5f:	0f 94 c0             	sete   %al
  800c62:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c65:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c6b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c6e:	39 cb                	cmp    %ecx,%ebx
  800c70:	74 15                	je     800c87 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c72:	8b 52 58             	mov    0x58(%edx),%edx
  800c75:	50                   	push   %eax
  800c76:	52                   	push   %edx
  800c77:	53                   	push   %ebx
  800c78:	68 c4 1f 80 00       	push   $0x801fc4
  800c7d:	e8 e4 04 00 00       	call   801166 <cprintf>
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	eb b6                	jmp    800c3d <_pipeisclosed+0xd>
	}
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    

00800c8f <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 28             	sub    $0x28,%esp
  800c98:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c9b:	56                   	push   %esi
  800c9c:	e8 17 f7 ff ff       	call   8003b8 <fd2data>
  800ca1:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca3:	83 c4 10             	add    $0x10,%esp
  800ca6:	bf 00 00 00 00       	mov    $0x0,%edi
  800cab:	eb 4b                	jmp    800cf8 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800cad:	89 da                	mov    %ebx,%edx
  800caf:	89 f0                	mov    %esi,%eax
  800cb1:	e8 7a ff ff ff       	call   800c30 <_pipeisclosed>
  800cb6:	85 c0                	test   %eax,%eax
  800cb8:	75 48                	jne    800d02 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800cba:	e8 92 f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800cbf:	8b 43 04             	mov    0x4(%ebx),%eax
  800cc2:	8b 0b                	mov    (%ebx),%ecx
  800cc4:	8d 51 20             	lea    0x20(%ecx),%edx
  800cc7:	39 d0                	cmp    %edx,%eax
  800cc9:	73 e2                	jae    800cad <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cd2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cd5:	89 c2                	mov    %eax,%edx
  800cd7:	c1 fa 1f             	sar    $0x1f,%edx
  800cda:	89 d1                	mov    %edx,%ecx
  800cdc:	c1 e9 1b             	shr    $0x1b,%ecx
  800cdf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ce2:	83 e2 1f             	and    $0x1f,%edx
  800ce5:	29 ca                	sub    %ecx,%edx
  800ce7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ceb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cef:	83 c0 01             	add    $0x1,%eax
  800cf2:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf5:	83 c7 01             	add    $0x1,%edi
  800cf8:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cfb:	75 c2                	jne    800cbf <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cfd:	8b 45 10             	mov    0x10(%ebp),%eax
  800d00:	eb 05                	jmp    800d07 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d02:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0a:	5b                   	pop    %ebx
  800d0b:	5e                   	pop    %esi
  800d0c:	5f                   	pop    %edi
  800d0d:	5d                   	pop    %ebp
  800d0e:	c3                   	ret    

00800d0f <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800d0f:	55                   	push   %ebp
  800d10:	89 e5                	mov    %esp,%ebp
  800d12:	57                   	push   %edi
  800d13:	56                   	push   %esi
  800d14:	53                   	push   %ebx
  800d15:	83 ec 18             	sub    $0x18,%esp
  800d18:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d1b:	57                   	push   %edi
  800d1c:	e8 97 f6 ff ff       	call   8003b8 <fd2data>
  800d21:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d23:	83 c4 10             	add    $0x10,%esp
  800d26:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2b:	eb 3d                	jmp    800d6a <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d2d:	85 db                	test   %ebx,%ebx
  800d2f:	74 04                	je     800d35 <devpipe_read+0x26>
				return i;
  800d31:	89 d8                	mov    %ebx,%eax
  800d33:	eb 44                	jmp    800d79 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d35:	89 f2                	mov    %esi,%edx
  800d37:	89 f8                	mov    %edi,%eax
  800d39:	e8 f2 fe ff ff       	call   800c30 <_pipeisclosed>
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	75 32                	jne    800d74 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d42:	e8 0a f4 ff ff       	call   800151 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d47:	8b 06                	mov    (%esi),%eax
  800d49:	3b 46 04             	cmp    0x4(%esi),%eax
  800d4c:	74 df                	je     800d2d <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d4e:	99                   	cltd   
  800d4f:	c1 ea 1b             	shr    $0x1b,%edx
  800d52:	01 d0                	add    %edx,%eax
  800d54:	83 e0 1f             	and    $0x1f,%eax
  800d57:	29 d0                	sub    %edx,%eax
  800d59:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d5e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d61:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d64:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d67:	83 c3 01             	add    $0x1,%ebx
  800d6a:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d6d:	75 d8                	jne    800d47 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800d72:	eb 05                	jmp    800d79 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d74:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	56                   	push   %esi
  800d85:	53                   	push   %ebx
  800d86:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d8c:	50                   	push   %eax
  800d8d:	e8 3d f6 ff ff       	call   8003cf <fd_alloc>
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	85 c0                	test   %eax,%eax
  800d99:	0f 88 2c 01 00 00    	js     800ecb <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9f:	83 ec 04             	sub    $0x4,%esp
  800da2:	68 07 04 00 00       	push   $0x407
  800da7:	ff 75 f4             	pushl  -0xc(%ebp)
  800daa:	6a 00                	push   $0x0
  800dac:	e8 bf f3 ff ff       	call   800170 <sys_page_alloc>
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	89 c2                	mov    %eax,%edx
  800db6:	85 c0                	test   %eax,%eax
  800db8:	0f 88 0d 01 00 00    	js     800ecb <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800dbe:	83 ec 0c             	sub    $0xc,%esp
  800dc1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dc4:	50                   	push   %eax
  800dc5:	e8 05 f6 ff ff       	call   8003cf <fd_alloc>
  800dca:	89 c3                	mov    %eax,%ebx
  800dcc:	83 c4 10             	add    $0x10,%esp
  800dcf:	85 c0                	test   %eax,%eax
  800dd1:	0f 88 e2 00 00 00    	js     800eb9 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd7:	83 ec 04             	sub    $0x4,%esp
  800dda:	68 07 04 00 00       	push   $0x407
  800ddf:	ff 75 f0             	pushl  -0x10(%ebp)
  800de2:	6a 00                	push   $0x0
  800de4:	e8 87 f3 ff ff       	call   800170 <sys_page_alloc>
  800de9:	89 c3                	mov    %eax,%ebx
  800deb:	83 c4 10             	add    $0x10,%esp
  800dee:	85 c0                	test   %eax,%eax
  800df0:	0f 88 c3 00 00 00    	js     800eb9 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800df6:	83 ec 0c             	sub    $0xc,%esp
  800df9:	ff 75 f4             	pushl  -0xc(%ebp)
  800dfc:	e8 b7 f5 ff ff       	call   8003b8 <fd2data>
  800e01:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e03:	83 c4 0c             	add    $0xc,%esp
  800e06:	68 07 04 00 00       	push   $0x407
  800e0b:	50                   	push   %eax
  800e0c:	6a 00                	push   $0x0
  800e0e:	e8 5d f3 ff ff       	call   800170 <sys_page_alloc>
  800e13:	89 c3                	mov    %eax,%ebx
  800e15:	83 c4 10             	add    $0x10,%esp
  800e18:	85 c0                	test   %eax,%eax
  800e1a:	0f 88 89 00 00 00    	js     800ea9 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e20:	83 ec 0c             	sub    $0xc,%esp
  800e23:	ff 75 f0             	pushl  -0x10(%ebp)
  800e26:	e8 8d f5 ff ff       	call   8003b8 <fd2data>
  800e2b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e32:	50                   	push   %eax
  800e33:	6a 00                	push   $0x0
  800e35:	56                   	push   %esi
  800e36:	6a 00                	push   $0x0
  800e38:	e8 76 f3 ff ff       	call   8001b3 <sys_page_map>
  800e3d:	89 c3                	mov    %eax,%ebx
  800e3f:	83 c4 20             	add    $0x20,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	78 55                	js     800e9b <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e46:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e4f:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e54:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e5b:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e64:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e66:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e69:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e70:	83 ec 0c             	sub    $0xc,%esp
  800e73:	ff 75 f4             	pushl  -0xc(%ebp)
  800e76:	e8 2d f5 ff ff       	call   8003a8 <fd2num>
  800e7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e80:	83 c4 04             	add    $0x4,%esp
  800e83:	ff 75 f0             	pushl  -0x10(%ebp)
  800e86:	e8 1d f5 ff ff       	call   8003a8 <fd2num>
  800e8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e8e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	ba 00 00 00 00       	mov    $0x0,%edx
  800e99:	eb 30                	jmp    800ecb <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	56                   	push   %esi
  800e9f:	6a 00                	push   $0x0
  800ea1:	e8 4f f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ea6:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	ff 75 f0             	pushl  -0x10(%ebp)
  800eaf:	6a 00                	push   $0x0
  800eb1:	e8 3f f3 ff ff       	call   8001f5 <sys_page_unmap>
  800eb6:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800eb9:	83 ec 08             	sub    $0x8,%esp
  800ebc:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebf:	6a 00                	push   $0x0
  800ec1:	e8 2f f3 ff ff       	call   8001f5 <sys_page_unmap>
  800ec6:	83 c4 10             	add    $0x10,%esp
  800ec9:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5d                   	pop    %ebp
  800ed3:	c3                   	ret    

00800ed4 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800edd:	50                   	push   %eax
  800ede:	ff 75 08             	pushl  0x8(%ebp)
  800ee1:	e8 38 f5 ff ff       	call   80041e <fd_lookup>
  800ee6:	89 c2                	mov    %eax,%edx
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	85 d2                	test   %edx,%edx
  800eed:	78 18                	js     800f07 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eef:	83 ec 0c             	sub    $0xc,%esp
  800ef2:	ff 75 f4             	pushl  -0xc(%ebp)
  800ef5:	e8 be f4 ff ff       	call   8003b8 <fd2data>
	return _pipeisclosed(fd, p);
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eff:	e8 2c fd ff ff       	call   800c30 <_pipeisclosed>
  800f04:	83 c4 10             	add    $0x10,%esp
}
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800f0c:	b8 00 00 00 00       	mov    $0x0,%eax
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f19:	68 f5 1f 80 00       	push   $0x801ff5
  800f1e:	ff 75 0c             	pushl  0xc(%ebp)
  800f21:	e8 c4 07 00 00       	call   8016ea <strcpy>
	return 0;
}
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	57                   	push   %edi
  800f31:	56                   	push   %esi
  800f32:	53                   	push   %ebx
  800f33:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f39:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f3e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f44:	eb 2e                	jmp    800f74 <devcons_write+0x47>
		m = n - tot;
  800f46:	8b 55 10             	mov    0x10(%ebp),%edx
  800f49:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f4b:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f50:	83 fa 7f             	cmp    $0x7f,%edx
  800f53:	77 02                	ja     800f57 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f55:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f57:	83 ec 04             	sub    $0x4,%esp
  800f5a:	56                   	push   %esi
  800f5b:	03 45 0c             	add    0xc(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	57                   	push   %edi
  800f60:	e8 17 09 00 00       	call   80187c <memmove>
		sys_cputs(buf, m);
  800f65:	83 c4 08             	add    $0x8,%esp
  800f68:	56                   	push   %esi
  800f69:	57                   	push   %edi
  800f6a:	e8 45 f1 ff ff       	call   8000b4 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f6f:	01 f3                	add    %esi,%ebx
  800f71:	83 c4 10             	add    $0x10,%esp
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f79:	72 cb                	jb     800f46 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f89:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f92:	75 07                	jne    800f9b <devcons_read+0x18>
  800f94:	eb 28                	jmp    800fbe <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f96:	e8 b6 f1 ff ff       	call   800151 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f9b:	e8 32 f1 ff ff       	call   8000d2 <sys_cgetc>
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	74 f2                	je     800f96 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 16                	js     800fbe <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800fa8:	83 f8 04             	cmp    $0x4,%eax
  800fab:	74 0c                	je     800fb9 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800fad:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fb0:	88 02                	mov    %al,(%edx)
	return 1;
  800fb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800fb7:	eb 05                	jmp    800fbe <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fb9:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fbe:	c9                   	leave  
  800fbf:	c3                   	ret    

00800fc0 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fc6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc9:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fcc:	6a 01                	push   $0x1
  800fce:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd1:	50                   	push   %eax
  800fd2:	e8 dd f0 ff ff       	call   8000b4 <sys_cputs>
  800fd7:	83 c4 10             	add    $0x10,%esp
}
  800fda:	c9                   	leave  
  800fdb:	c3                   	ret    

00800fdc <getchar>:

int
getchar(void)
{
  800fdc:	55                   	push   %ebp
  800fdd:	89 e5                	mov    %esp,%ebp
  800fdf:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fe2:	6a 01                	push   $0x1
  800fe4:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fe7:	50                   	push   %eax
  800fe8:	6a 00                	push   $0x0
  800fea:	e8 98 f6 ff ff       	call   800687 <read>
	if (r < 0)
  800fef:	83 c4 10             	add    $0x10,%esp
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 0f                	js     801005 <getchar+0x29>
		return r;
	if (r < 1)
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	7e 06                	jle    801000 <getchar+0x24>
		return -E_EOF;
	return c;
  800ffa:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800ffe:	eb 05                	jmp    801005 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801000:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80100d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801010:	50                   	push   %eax
  801011:	ff 75 08             	pushl  0x8(%ebp)
  801014:	e8 05 f4 ff ff       	call   80041e <fd_lookup>
  801019:	83 c4 10             	add    $0x10,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 11                	js     801031 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801023:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801029:	39 10                	cmp    %edx,(%eax)
  80102b:	0f 94 c0             	sete   %al
  80102e:	0f b6 c0             	movzbl %al,%eax
}
  801031:	c9                   	leave  
  801032:	c3                   	ret    

00801033 <opencons>:

int
opencons(void)
{
  801033:	55                   	push   %ebp
  801034:	89 e5                	mov    %esp,%ebp
  801036:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801039:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80103c:	50                   	push   %eax
  80103d:	e8 8d f3 ff ff       	call   8003cf <fd_alloc>
  801042:	83 c4 10             	add    $0x10,%esp
		return r;
  801045:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801047:	85 c0                	test   %eax,%eax
  801049:	78 3e                	js     801089 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	68 07 04 00 00       	push   $0x407
  801053:	ff 75 f4             	pushl  -0xc(%ebp)
  801056:	6a 00                	push   $0x0
  801058:	e8 13 f1 ff ff       	call   800170 <sys_page_alloc>
  80105d:	83 c4 10             	add    $0x10,%esp
		return r;
  801060:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801062:	85 c0                	test   %eax,%eax
  801064:	78 23                	js     801089 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801066:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80106c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80106f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801071:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801074:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80107b:	83 ec 0c             	sub    $0xc,%esp
  80107e:	50                   	push   %eax
  80107f:	e8 24 f3 ff ff       	call   8003a8 <fd2num>
  801084:	89 c2                	mov    %eax,%edx
  801086:	83 c4 10             	add    $0x10,%esp
}
  801089:	89 d0                	mov    %edx,%eax
  80108b:	c9                   	leave  
  80108c:	c3                   	ret    

0080108d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
  801090:	56                   	push   %esi
  801091:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801092:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801095:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80109b:	e8 92 f0 ff ff       	call   800132 <sys_getenvid>
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	ff 75 0c             	pushl  0xc(%ebp)
  8010a6:	ff 75 08             	pushl  0x8(%ebp)
  8010a9:	56                   	push   %esi
  8010aa:	50                   	push   %eax
  8010ab:	68 04 20 80 00       	push   $0x802004
  8010b0:	e8 b1 00 00 00       	call   801166 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8010b5:	83 c4 18             	add    $0x18,%esp
  8010b8:	53                   	push   %ebx
  8010b9:	ff 75 10             	pushl  0x10(%ebp)
  8010bc:	e8 54 00 00 00       	call   801115 <vcprintf>
	cprintf("\n");
  8010c1:	c7 04 24 53 1f 80 00 	movl   $0x801f53,(%esp)
  8010c8:	e8 99 00 00 00       	call   801166 <cprintf>
  8010cd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010d0:	cc                   	int3   
  8010d1:	eb fd                	jmp    8010d0 <_panic+0x43>

008010d3 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010dd:	8b 13                	mov    (%ebx),%edx
  8010df:	8d 42 01             	lea    0x1(%edx),%eax
  8010e2:	89 03                	mov    %eax,(%ebx)
  8010e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010e7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010eb:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010f0:	75 1a                	jne    80110c <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010f2:	83 ec 08             	sub    $0x8,%esp
  8010f5:	68 ff 00 00 00       	push   $0xff
  8010fa:	8d 43 08             	lea    0x8(%ebx),%eax
  8010fd:	50                   	push   %eax
  8010fe:	e8 b1 ef ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  801103:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801109:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80110c:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801110:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801113:	c9                   	leave  
  801114:	c3                   	ret    

00801115 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80111e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801125:	00 00 00 
	b.cnt = 0;
  801128:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80112f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801132:	ff 75 0c             	pushl  0xc(%ebp)
  801135:	ff 75 08             	pushl  0x8(%ebp)
  801138:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80113e:	50                   	push   %eax
  80113f:	68 d3 10 80 00       	push   $0x8010d3
  801144:	e8 4f 01 00 00       	call   801298 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801149:	83 c4 08             	add    $0x8,%esp
  80114c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801152:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801158:	50                   	push   %eax
  801159:	e8 56 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  80115e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801164:	c9                   	leave  
  801165:	c3                   	ret    

00801166 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801166:	55                   	push   %ebp
  801167:	89 e5                	mov    %esp,%ebp
  801169:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80116c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80116f:	50                   	push   %eax
  801170:	ff 75 08             	pushl  0x8(%ebp)
  801173:	e8 9d ff ff ff       	call   801115 <vcprintf>
	va_end(ap);

	return cnt;
}
  801178:	c9                   	leave  
  801179:	c3                   	ret    

0080117a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80117a:	55                   	push   %ebp
  80117b:	89 e5                	mov    %esp,%ebp
  80117d:	57                   	push   %edi
  80117e:	56                   	push   %esi
  80117f:	53                   	push   %ebx
  801180:	83 ec 1c             	sub    $0x1c,%esp
  801183:	89 c7                	mov    %eax,%edi
  801185:	89 d6                	mov    %edx,%esi
  801187:	8b 45 08             	mov    0x8(%ebp),%eax
  80118a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118d:	89 d1                	mov    %edx,%ecx
  80118f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801192:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801195:	8b 45 10             	mov    0x10(%ebp),%eax
  801198:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80119b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80119e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8011a5:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8011a8:	72 05                	jb     8011af <printnum+0x35>
  8011aa:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8011ad:	77 3e                	ja     8011ed <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	ff 75 18             	pushl  0x18(%ebp)
  8011b5:	83 eb 01             	sub    $0x1,%ebx
  8011b8:	53                   	push   %ebx
  8011b9:	50                   	push   %eax
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c9:	e8 12 0a 00 00       	call   801be0 <__udivdi3>
  8011ce:	83 c4 18             	add    $0x18,%esp
  8011d1:	52                   	push   %edx
  8011d2:	50                   	push   %eax
  8011d3:	89 f2                	mov    %esi,%edx
  8011d5:	89 f8                	mov    %edi,%eax
  8011d7:	e8 9e ff ff ff       	call   80117a <printnum>
  8011dc:	83 c4 20             	add    $0x20,%esp
  8011df:	eb 13                	jmp    8011f4 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	56                   	push   %esi
  8011e5:	ff 75 18             	pushl  0x18(%ebp)
  8011e8:	ff d7                	call   *%edi
  8011ea:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ed:	83 eb 01             	sub    $0x1,%ebx
  8011f0:	85 db                	test   %ebx,%ebx
  8011f2:	7f ed                	jg     8011e1 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011f4:	83 ec 08             	sub    $0x8,%esp
  8011f7:	56                   	push   %esi
  8011f8:	83 ec 04             	sub    $0x4,%esp
  8011fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801201:	ff 75 dc             	pushl  -0x24(%ebp)
  801204:	ff 75 d8             	pushl  -0x28(%ebp)
  801207:	e8 04 0b 00 00       	call   801d10 <__umoddi3>
  80120c:	83 c4 14             	add    $0x14,%esp
  80120f:	0f be 80 27 20 80 00 	movsbl 0x802027(%eax),%eax
  801216:	50                   	push   %eax
  801217:	ff d7                	call   *%edi
  801219:	83 c4 10             	add    $0x10,%esp
}
  80121c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121f:	5b                   	pop    %ebx
  801220:	5e                   	pop    %esi
  801221:	5f                   	pop    %edi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801227:	83 fa 01             	cmp    $0x1,%edx
  80122a:	7e 0e                	jle    80123a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80122c:	8b 10                	mov    (%eax),%edx
  80122e:	8d 4a 08             	lea    0x8(%edx),%ecx
  801231:	89 08                	mov    %ecx,(%eax)
  801233:	8b 02                	mov    (%edx),%eax
  801235:	8b 52 04             	mov    0x4(%edx),%edx
  801238:	eb 22                	jmp    80125c <getuint+0x38>
	else if (lflag)
  80123a:	85 d2                	test   %edx,%edx
  80123c:	74 10                	je     80124e <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80123e:	8b 10                	mov    (%eax),%edx
  801240:	8d 4a 04             	lea    0x4(%edx),%ecx
  801243:	89 08                	mov    %ecx,(%eax)
  801245:	8b 02                	mov    (%edx),%eax
  801247:	ba 00 00 00 00       	mov    $0x0,%edx
  80124c:	eb 0e                	jmp    80125c <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80124e:	8b 10                	mov    (%eax),%edx
  801250:	8d 4a 04             	lea    0x4(%edx),%ecx
  801253:	89 08                	mov    %ecx,(%eax)
  801255:	8b 02                	mov    (%edx),%eax
  801257:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    

0080125e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801264:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801268:	8b 10                	mov    (%eax),%edx
  80126a:	3b 50 04             	cmp    0x4(%eax),%edx
  80126d:	73 0a                	jae    801279 <sprintputch+0x1b>
		*b->buf++ = ch;
  80126f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801272:	89 08                	mov    %ecx,(%eax)
  801274:	8b 45 08             	mov    0x8(%ebp),%eax
  801277:	88 02                	mov    %al,(%edx)
}
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801281:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801284:	50                   	push   %eax
  801285:	ff 75 10             	pushl  0x10(%ebp)
  801288:	ff 75 0c             	pushl  0xc(%ebp)
  80128b:	ff 75 08             	pushl  0x8(%ebp)
  80128e:	e8 05 00 00 00       	call   801298 <vprintfmt>
	va_end(ap);
  801293:	83 c4 10             	add    $0x10,%esp
}
  801296:	c9                   	leave  
  801297:	c3                   	ret    

00801298 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801298:	55                   	push   %ebp
  801299:	89 e5                	mov    %esp,%ebp
  80129b:	57                   	push   %edi
  80129c:	56                   	push   %esi
  80129d:	53                   	push   %ebx
  80129e:	83 ec 2c             	sub    $0x2c,%esp
  8012a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8012a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012aa:	eb 12                	jmp    8012be <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8012ac:	85 c0                	test   %eax,%eax
  8012ae:	0f 84 8d 03 00 00    	je     801641 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8012b4:	83 ec 08             	sub    $0x8,%esp
  8012b7:	53                   	push   %ebx
  8012b8:	50                   	push   %eax
  8012b9:	ff d6                	call   *%esi
  8012bb:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012be:	83 c7 01             	add    $0x1,%edi
  8012c1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012c5:	83 f8 25             	cmp    $0x25,%eax
  8012c8:	75 e2                	jne    8012ac <vprintfmt+0x14>
  8012ca:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012ce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012d5:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012dc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8012e8:	eb 07                	jmp    8012f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ed:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f1:	8d 47 01             	lea    0x1(%edi),%eax
  8012f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f7:	0f b6 07             	movzbl (%edi),%eax
  8012fa:	0f b6 c8             	movzbl %al,%ecx
  8012fd:	83 e8 23             	sub    $0x23,%eax
  801300:	3c 55                	cmp    $0x55,%al
  801302:	0f 87 1e 03 00 00    	ja     801626 <vprintfmt+0x38e>
  801308:	0f b6 c0             	movzbl %al,%eax
  80130b:	ff 24 85 80 21 80 00 	jmp    *0x802180(,%eax,4)
  801312:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801315:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801319:	eb d6                	jmp    8012f1 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131e:	b8 00 00 00 00       	mov    $0x0,%eax
  801323:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801326:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801329:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  80132d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801330:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801333:	83 fa 09             	cmp    $0x9,%edx
  801336:	77 38                	ja     801370 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801338:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80133b:	eb e9                	jmp    801326 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80133d:	8b 45 14             	mov    0x14(%ebp),%eax
  801340:	8d 48 04             	lea    0x4(%eax),%ecx
  801343:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801346:	8b 00                	mov    (%eax),%eax
  801348:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80134e:	eb 26                	jmp    801376 <vprintfmt+0xde>
  801350:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801353:	89 c8                	mov    %ecx,%eax
  801355:	c1 f8 1f             	sar    $0x1f,%eax
  801358:	f7 d0                	not    %eax
  80135a:	21 c1                	and    %eax,%ecx
  80135c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801362:	eb 8d                	jmp    8012f1 <vprintfmt+0x59>
  801364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801367:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80136e:	eb 81                	jmp    8012f1 <vprintfmt+0x59>
  801370:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801373:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801376:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80137a:	0f 89 71 ff ff ff    	jns    8012f1 <vprintfmt+0x59>
				width = precision, precision = -1;
  801380:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801383:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801386:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80138d:	e9 5f ff ff ff       	jmp    8012f1 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801392:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801395:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801398:	e9 54 ff ff ff       	jmp    8012f1 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80139d:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a0:	8d 50 04             	lea    0x4(%eax),%edx
  8013a3:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	53                   	push   %ebx
  8013aa:	ff 30                	pushl  (%eax)
  8013ac:	ff d6                	call   *%esi
			break;
  8013ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8013b4:	e9 05 ff ff ff       	jmp    8012be <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8013b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bc:	8d 50 04             	lea    0x4(%eax),%edx
  8013bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c2:	8b 00                	mov    (%eax),%eax
  8013c4:	99                   	cltd   
  8013c5:	31 d0                	xor    %edx,%eax
  8013c7:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013c9:	83 f8 0f             	cmp    $0xf,%eax
  8013cc:	7f 0b                	jg     8013d9 <vprintfmt+0x141>
  8013ce:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  8013d5:	85 d2                	test   %edx,%edx
  8013d7:	75 18                	jne    8013f1 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8013d9:	50                   	push   %eax
  8013da:	68 3f 20 80 00       	push   $0x80203f
  8013df:	53                   	push   %ebx
  8013e0:	56                   	push   %esi
  8013e1:	e8 95 fe ff ff       	call   80127b <printfmt>
  8013e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ec:	e9 cd fe ff ff       	jmp    8012be <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013f1:	52                   	push   %edx
  8013f2:	68 9d 1f 80 00       	push   $0x801f9d
  8013f7:	53                   	push   %ebx
  8013f8:	56                   	push   %esi
  8013f9:	e8 7d fe ff ff       	call   80127b <printfmt>
  8013fe:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801404:	e9 b5 fe ff ff       	jmp    8012be <vprintfmt+0x26>
  801409:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80140c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80140f:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801412:	8b 45 14             	mov    0x14(%ebp),%eax
  801415:	8d 50 04             	lea    0x4(%eax),%edx
  801418:	89 55 14             	mov    %edx,0x14(%ebp)
  80141b:	8b 38                	mov    (%eax),%edi
  80141d:	85 ff                	test   %edi,%edi
  80141f:	75 05                	jne    801426 <vprintfmt+0x18e>
				p = "(null)";
  801421:	bf 38 20 80 00       	mov    $0x802038,%edi
			if (width > 0 && padc != '-')
  801426:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80142a:	0f 84 91 00 00 00    	je     8014c1 <vprintfmt+0x229>
  801430:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801434:	0f 8e 95 00 00 00    	jle    8014cf <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  80143a:	83 ec 08             	sub    $0x8,%esp
  80143d:	51                   	push   %ecx
  80143e:	57                   	push   %edi
  80143f:	e8 85 02 00 00       	call   8016c9 <strnlen>
  801444:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801447:	29 c1                	sub    %eax,%ecx
  801449:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80144c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80144f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801453:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801456:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801459:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80145b:	eb 0f                	jmp    80146c <vprintfmt+0x1d4>
					putch(padc, putdat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	53                   	push   %ebx
  801461:	ff 75 e0             	pushl  -0x20(%ebp)
  801464:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801466:	83 ef 01             	sub    $0x1,%edi
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 ff                	test   %edi,%edi
  80146e:	7f ed                	jg     80145d <vprintfmt+0x1c5>
  801470:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801473:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801476:	89 c8                	mov    %ecx,%eax
  801478:	c1 f8 1f             	sar    $0x1f,%eax
  80147b:	f7 d0                	not    %eax
  80147d:	21 c8                	and    %ecx,%eax
  80147f:	29 c1                	sub    %eax,%ecx
  801481:	89 75 08             	mov    %esi,0x8(%ebp)
  801484:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801487:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148a:	89 cb                	mov    %ecx,%ebx
  80148c:	eb 4d                	jmp    8014db <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80148e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801492:	74 1b                	je     8014af <vprintfmt+0x217>
  801494:	0f be c0             	movsbl %al,%eax
  801497:	83 e8 20             	sub    $0x20,%eax
  80149a:	83 f8 5e             	cmp    $0x5e,%eax
  80149d:	76 10                	jbe    8014af <vprintfmt+0x217>
					putch('?', putdat);
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	ff 75 0c             	pushl  0xc(%ebp)
  8014a5:	6a 3f                	push   $0x3f
  8014a7:	ff 55 08             	call   *0x8(%ebp)
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	eb 0d                	jmp    8014bc <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8014af:	83 ec 08             	sub    $0x8,%esp
  8014b2:	ff 75 0c             	pushl  0xc(%ebp)
  8014b5:	52                   	push   %edx
  8014b6:	ff 55 08             	call   *0x8(%ebp)
  8014b9:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014bc:	83 eb 01             	sub    $0x1,%ebx
  8014bf:	eb 1a                	jmp    8014db <vprintfmt+0x243>
  8014c1:	89 75 08             	mov    %esi,0x8(%ebp)
  8014c4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014c7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014cd:	eb 0c                	jmp    8014db <vprintfmt+0x243>
  8014cf:	89 75 08             	mov    %esi,0x8(%ebp)
  8014d2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014d5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014d8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014db:	83 c7 01             	add    $0x1,%edi
  8014de:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014e2:	0f be d0             	movsbl %al,%edx
  8014e5:	85 d2                	test   %edx,%edx
  8014e7:	74 23                	je     80150c <vprintfmt+0x274>
  8014e9:	85 f6                	test   %esi,%esi
  8014eb:	78 a1                	js     80148e <vprintfmt+0x1f6>
  8014ed:	83 ee 01             	sub    $0x1,%esi
  8014f0:	79 9c                	jns    80148e <vprintfmt+0x1f6>
  8014f2:	89 df                	mov    %ebx,%edi
  8014f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014fa:	eb 18                	jmp    801514 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	53                   	push   %ebx
  801500:	6a 20                	push   $0x20
  801502:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801504:	83 ef 01             	sub    $0x1,%edi
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	eb 08                	jmp    801514 <vprintfmt+0x27c>
  80150c:	89 df                	mov    %ebx,%edi
  80150e:	8b 75 08             	mov    0x8(%ebp),%esi
  801511:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801514:	85 ff                	test   %edi,%edi
  801516:	7f e4                	jg     8014fc <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801518:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80151b:	e9 9e fd ff ff       	jmp    8012be <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801520:	83 fa 01             	cmp    $0x1,%edx
  801523:	7e 16                	jle    80153b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  801525:	8b 45 14             	mov    0x14(%ebp),%eax
  801528:	8d 50 08             	lea    0x8(%eax),%edx
  80152b:	89 55 14             	mov    %edx,0x14(%ebp)
  80152e:	8b 50 04             	mov    0x4(%eax),%edx
  801531:	8b 00                	mov    (%eax),%eax
  801533:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801536:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801539:	eb 32                	jmp    80156d <vprintfmt+0x2d5>
	else if (lflag)
  80153b:	85 d2                	test   %edx,%edx
  80153d:	74 18                	je     801557 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80153f:	8b 45 14             	mov    0x14(%ebp),%eax
  801542:	8d 50 04             	lea    0x4(%eax),%edx
  801545:	89 55 14             	mov    %edx,0x14(%ebp)
  801548:	8b 00                	mov    (%eax),%eax
  80154a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154d:	89 c1                	mov    %eax,%ecx
  80154f:	c1 f9 1f             	sar    $0x1f,%ecx
  801552:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801555:	eb 16                	jmp    80156d <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801557:	8b 45 14             	mov    0x14(%ebp),%eax
  80155a:	8d 50 04             	lea    0x4(%eax),%edx
  80155d:	89 55 14             	mov    %edx,0x14(%ebp)
  801560:	8b 00                	mov    (%eax),%eax
  801562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801565:	89 c1                	mov    %eax,%ecx
  801567:	c1 f9 1f             	sar    $0x1f,%ecx
  80156a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80156d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801570:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801573:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801578:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80157c:	79 74                	jns    8015f2 <vprintfmt+0x35a>
				putch('-', putdat);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	53                   	push   %ebx
  801582:	6a 2d                	push   $0x2d
  801584:	ff d6                	call   *%esi
				num = -(long long) num;
  801586:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801589:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80158c:	f7 d8                	neg    %eax
  80158e:	83 d2 00             	adc    $0x0,%edx
  801591:	f7 da                	neg    %edx
  801593:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801596:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80159b:	eb 55                	jmp    8015f2 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80159d:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a0:	e8 7f fc ff ff       	call   801224 <getuint>
			base = 10;
  8015a5:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8015aa:	eb 46                	jmp    8015f2 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8015ac:	8d 45 14             	lea    0x14(%ebp),%eax
  8015af:	e8 70 fc ff ff       	call   801224 <getuint>
			base = 8;
  8015b4:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015b9:	eb 37                	jmp    8015f2 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8015bb:	83 ec 08             	sub    $0x8,%esp
  8015be:	53                   	push   %ebx
  8015bf:	6a 30                	push   $0x30
  8015c1:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c3:	83 c4 08             	add    $0x8,%esp
  8015c6:	53                   	push   %ebx
  8015c7:	6a 78                	push   $0x78
  8015c9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ce:	8d 50 04             	lea    0x4(%eax),%edx
  8015d1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015d4:	8b 00                	mov    (%eax),%eax
  8015d6:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015db:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015de:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015e3:	eb 0d                	jmp    8015f2 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015e5:	8d 45 14             	lea    0x14(%ebp),%eax
  8015e8:	e8 37 fc ff ff       	call   801224 <getuint>
			base = 16;
  8015ed:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015f9:	57                   	push   %edi
  8015fa:	ff 75 e0             	pushl  -0x20(%ebp)
  8015fd:	51                   	push   %ecx
  8015fe:	52                   	push   %edx
  8015ff:	50                   	push   %eax
  801600:	89 da                	mov    %ebx,%edx
  801602:	89 f0                	mov    %esi,%eax
  801604:	e8 71 fb ff ff       	call   80117a <printnum>
			break;
  801609:	83 c4 20             	add    $0x20,%esp
  80160c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80160f:	e9 aa fc ff ff       	jmp    8012be <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801614:	83 ec 08             	sub    $0x8,%esp
  801617:	53                   	push   %ebx
  801618:	51                   	push   %ecx
  801619:	ff d6                	call   *%esi
			break;
  80161b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801621:	e9 98 fc ff ff       	jmp    8012be <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801626:	83 ec 08             	sub    $0x8,%esp
  801629:	53                   	push   %ebx
  80162a:	6a 25                	push   $0x25
  80162c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80162e:	83 c4 10             	add    $0x10,%esp
  801631:	eb 03                	jmp    801636 <vprintfmt+0x39e>
  801633:	83 ef 01             	sub    $0x1,%edi
  801636:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80163a:	75 f7                	jne    801633 <vprintfmt+0x39b>
  80163c:	e9 7d fc ff ff       	jmp    8012be <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801641:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801644:	5b                   	pop    %ebx
  801645:	5e                   	pop    %esi
  801646:	5f                   	pop    %edi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	83 ec 18             	sub    $0x18,%esp
  80164f:	8b 45 08             	mov    0x8(%ebp),%eax
  801652:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801655:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801658:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80165c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80165f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801666:	85 c0                	test   %eax,%eax
  801668:	74 26                	je     801690 <vsnprintf+0x47>
  80166a:	85 d2                	test   %edx,%edx
  80166c:	7e 22                	jle    801690 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80166e:	ff 75 14             	pushl  0x14(%ebp)
  801671:	ff 75 10             	pushl  0x10(%ebp)
  801674:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	68 5e 12 80 00       	push   $0x80125e
  80167d:	e8 16 fc ff ff       	call   801298 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801682:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801685:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	eb 05                	jmp    801695 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801690:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801695:	c9                   	leave  
  801696:	c3                   	ret    

00801697 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80169d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016a0:	50                   	push   %eax
  8016a1:	ff 75 10             	pushl  0x10(%ebp)
  8016a4:	ff 75 0c             	pushl  0xc(%ebp)
  8016a7:	ff 75 08             	pushl  0x8(%ebp)
  8016aa:	e8 9a ff ff ff       	call   801649 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016af:	c9                   	leave  
  8016b0:	c3                   	ret    

008016b1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bc:	eb 03                	jmp    8016c1 <strlen+0x10>
		n++;
  8016be:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016c5:	75 f7                	jne    8016be <strlen+0xd>
		n++;
	return n;
}
  8016c7:	5d                   	pop    %ebp
  8016c8:	c3                   	ret    

008016c9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d7:	eb 03                	jmp    8016dc <strnlen+0x13>
		n++;
  8016d9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016dc:	39 c2                	cmp    %eax,%edx
  8016de:	74 08                	je     8016e8 <strnlen+0x1f>
  8016e0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016e4:	75 f3                	jne    8016d9 <strnlen+0x10>
  8016e6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e8:	5d                   	pop    %ebp
  8016e9:	c3                   	ret    

008016ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f4:	89 c2                	mov    %eax,%edx
  8016f6:	83 c2 01             	add    $0x1,%edx
  8016f9:	83 c1 01             	add    $0x1,%ecx
  8016fc:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801700:	88 5a ff             	mov    %bl,-0x1(%edx)
  801703:	84 db                	test   %bl,%bl
  801705:	75 ef                	jne    8016f6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801707:	5b                   	pop    %ebx
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80170a:	55                   	push   %ebp
  80170b:	89 e5                	mov    %esp,%ebp
  80170d:	53                   	push   %ebx
  80170e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801711:	53                   	push   %ebx
  801712:	e8 9a ff ff ff       	call   8016b1 <strlen>
  801717:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80171a:	ff 75 0c             	pushl  0xc(%ebp)
  80171d:	01 d8                	add    %ebx,%eax
  80171f:	50                   	push   %eax
  801720:	e8 c5 ff ff ff       	call   8016ea <strcpy>
	return dst;
}
  801725:	89 d8                	mov    %ebx,%eax
  801727:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80172a:	c9                   	leave  
  80172b:	c3                   	ret    

0080172c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	8b 75 08             	mov    0x8(%ebp),%esi
  801734:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801737:	89 f3                	mov    %esi,%ebx
  801739:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173c:	89 f2                	mov    %esi,%edx
  80173e:	eb 0f                	jmp    80174f <strncpy+0x23>
		*dst++ = *src;
  801740:	83 c2 01             	add    $0x1,%edx
  801743:	0f b6 01             	movzbl (%ecx),%eax
  801746:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801749:	80 39 01             	cmpb   $0x1,(%ecx)
  80174c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174f:	39 da                	cmp    %ebx,%edx
  801751:	75 ed                	jne    801740 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801753:	89 f0                	mov    %esi,%eax
  801755:	5b                   	pop    %ebx
  801756:	5e                   	pop    %esi
  801757:	5d                   	pop    %ebp
  801758:	c3                   	ret    

00801759 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801759:	55                   	push   %ebp
  80175a:	89 e5                	mov    %esp,%ebp
  80175c:	56                   	push   %esi
  80175d:	53                   	push   %ebx
  80175e:	8b 75 08             	mov    0x8(%ebp),%esi
  801761:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801764:	8b 55 10             	mov    0x10(%ebp),%edx
  801767:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801769:	85 d2                	test   %edx,%edx
  80176b:	74 21                	je     80178e <strlcpy+0x35>
  80176d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801771:	89 f2                	mov    %esi,%edx
  801773:	eb 09                	jmp    80177e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801775:	83 c2 01             	add    $0x1,%edx
  801778:	83 c1 01             	add    $0x1,%ecx
  80177b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80177e:	39 c2                	cmp    %eax,%edx
  801780:	74 09                	je     80178b <strlcpy+0x32>
  801782:	0f b6 19             	movzbl (%ecx),%ebx
  801785:	84 db                	test   %bl,%bl
  801787:	75 ec                	jne    801775 <strlcpy+0x1c>
  801789:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80178b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80178e:	29 f0                	sub    %esi,%eax
}
  801790:	5b                   	pop    %ebx
  801791:	5e                   	pop    %esi
  801792:	5d                   	pop    %ebp
  801793:	c3                   	ret    

00801794 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80179a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80179d:	eb 06                	jmp    8017a5 <strcmp+0x11>
		p++, q++;
  80179f:	83 c1 01             	add    $0x1,%ecx
  8017a2:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a5:	0f b6 01             	movzbl (%ecx),%eax
  8017a8:	84 c0                	test   %al,%al
  8017aa:	74 04                	je     8017b0 <strcmp+0x1c>
  8017ac:	3a 02                	cmp    (%edx),%al
  8017ae:	74 ef                	je     80179f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b0:	0f b6 c0             	movzbl %al,%eax
  8017b3:	0f b6 12             	movzbl (%edx),%edx
  8017b6:	29 d0                	sub    %edx,%eax
}
  8017b8:	5d                   	pop    %ebp
  8017b9:	c3                   	ret    

008017ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	53                   	push   %ebx
  8017be:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c4:	89 c3                	mov    %eax,%ebx
  8017c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c9:	eb 06                	jmp    8017d1 <strncmp+0x17>
		n--, p++, q++;
  8017cb:	83 c0 01             	add    $0x1,%eax
  8017ce:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017d1:	39 d8                	cmp    %ebx,%eax
  8017d3:	74 15                	je     8017ea <strncmp+0x30>
  8017d5:	0f b6 08             	movzbl (%eax),%ecx
  8017d8:	84 c9                	test   %cl,%cl
  8017da:	74 04                	je     8017e0 <strncmp+0x26>
  8017dc:	3a 0a                	cmp    (%edx),%cl
  8017de:	74 eb                	je     8017cb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017e0:	0f b6 00             	movzbl (%eax),%eax
  8017e3:	0f b6 12             	movzbl (%edx),%edx
  8017e6:	29 d0                	sub    %edx,%eax
  8017e8:	eb 05                	jmp    8017ef <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ef:	5b                   	pop    %ebx
  8017f0:	5d                   	pop    %ebp
  8017f1:	c3                   	ret    

008017f2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fc:	eb 07                	jmp    801805 <strchr+0x13>
		if (*s == c)
  8017fe:	38 ca                	cmp    %cl,%dl
  801800:	74 0f                	je     801811 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801802:	83 c0 01             	add    $0x1,%eax
  801805:	0f b6 10             	movzbl (%eax),%edx
  801808:	84 d2                	test   %dl,%dl
  80180a:	75 f2                	jne    8017fe <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80180c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	8b 45 08             	mov    0x8(%ebp),%eax
  801819:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181d:	eb 03                	jmp    801822 <strfind+0xf>
  80181f:	83 c0 01             	add    $0x1,%eax
  801822:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801825:	84 d2                	test   %dl,%dl
  801827:	74 04                	je     80182d <strfind+0x1a>
  801829:	38 ca                	cmp    %cl,%dl
  80182b:	75 f2                	jne    80181f <strfind+0xc>
			break;
	return (char *) s;
}
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	57                   	push   %edi
  801833:	56                   	push   %esi
  801834:	53                   	push   %ebx
  801835:	8b 7d 08             	mov    0x8(%ebp),%edi
  801838:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  80183b:	85 c9                	test   %ecx,%ecx
  80183d:	74 36                	je     801875 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801845:	75 28                	jne    80186f <memset+0x40>
  801847:	f6 c1 03             	test   $0x3,%cl
  80184a:	75 23                	jne    80186f <memset+0x40>
		c &= 0xFF;
  80184c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801850:	89 d3                	mov    %edx,%ebx
  801852:	c1 e3 08             	shl    $0x8,%ebx
  801855:	89 d6                	mov    %edx,%esi
  801857:	c1 e6 18             	shl    $0x18,%esi
  80185a:	89 d0                	mov    %edx,%eax
  80185c:	c1 e0 10             	shl    $0x10,%eax
  80185f:	09 f0                	or     %esi,%eax
  801861:	09 c2                	or     %eax,%edx
  801863:	89 d0                	mov    %edx,%eax
  801865:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801867:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80186a:	fc                   	cld    
  80186b:	f3 ab                	rep stos %eax,%es:(%edi)
  80186d:	eb 06                	jmp    801875 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80186f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801872:	fc                   	cld    
  801873:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801875:	89 f8                	mov    %edi,%eax
  801877:	5b                   	pop    %ebx
  801878:	5e                   	pop    %esi
  801879:	5f                   	pop    %edi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	57                   	push   %edi
  801880:	56                   	push   %esi
  801881:	8b 45 08             	mov    0x8(%ebp),%eax
  801884:	8b 75 0c             	mov    0xc(%ebp),%esi
  801887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188a:	39 c6                	cmp    %eax,%esi
  80188c:	73 35                	jae    8018c3 <memmove+0x47>
  80188e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801891:	39 d0                	cmp    %edx,%eax
  801893:	73 2e                	jae    8018c3 <memmove+0x47>
		s += n;
		d += n;
  801895:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801898:	89 d6                	mov    %edx,%esi
  80189a:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80189c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a2:	75 13                	jne    8018b7 <memmove+0x3b>
  8018a4:	f6 c1 03             	test   $0x3,%cl
  8018a7:	75 0e                	jne    8018b7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018a9:	83 ef 04             	sub    $0x4,%edi
  8018ac:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018af:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8018b2:	fd                   	std    
  8018b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b5:	eb 09                	jmp    8018c0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018b7:	83 ef 01             	sub    $0x1,%edi
  8018ba:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018bd:	fd                   	std    
  8018be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018c0:	fc                   	cld    
  8018c1:	eb 1d                	jmp    8018e0 <memmove+0x64>
  8018c3:	89 f2                	mov    %esi,%edx
  8018c5:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c7:	f6 c2 03             	test   $0x3,%dl
  8018ca:	75 0f                	jne    8018db <memmove+0x5f>
  8018cc:	f6 c1 03             	test   $0x3,%cl
  8018cf:	75 0a                	jne    8018db <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018d1:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018d4:	89 c7                	mov    %eax,%edi
  8018d6:	fc                   	cld    
  8018d7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d9:	eb 05                	jmp    8018e0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018db:	89 c7                	mov    %eax,%edi
  8018dd:	fc                   	cld    
  8018de:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018e0:	5e                   	pop    %esi
  8018e1:	5f                   	pop    %edi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e7:	ff 75 10             	pushl  0x10(%ebp)
  8018ea:	ff 75 0c             	pushl  0xc(%ebp)
  8018ed:	ff 75 08             	pushl  0x8(%ebp)
  8018f0:	e8 87 ff ff ff       	call   80187c <memmove>
}
  8018f5:	c9                   	leave  
  8018f6:	c3                   	ret    

008018f7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
  8018fa:	56                   	push   %esi
  8018fb:	53                   	push   %ebx
  8018fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801902:	89 c6                	mov    %eax,%esi
  801904:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801907:	eb 1a                	jmp    801923 <memcmp+0x2c>
		if (*s1 != *s2)
  801909:	0f b6 08             	movzbl (%eax),%ecx
  80190c:	0f b6 1a             	movzbl (%edx),%ebx
  80190f:	38 d9                	cmp    %bl,%cl
  801911:	74 0a                	je     80191d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801913:	0f b6 c1             	movzbl %cl,%eax
  801916:	0f b6 db             	movzbl %bl,%ebx
  801919:	29 d8                	sub    %ebx,%eax
  80191b:	eb 0f                	jmp    80192c <memcmp+0x35>
		s1++, s2++;
  80191d:	83 c0 01             	add    $0x1,%eax
  801920:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801923:	39 f0                	cmp    %esi,%eax
  801925:	75 e2                	jne    801909 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192c:	5b                   	pop    %ebx
  80192d:	5e                   	pop    %esi
  80192e:	5d                   	pop    %ebp
  80192f:	c3                   	ret    

00801930 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	8b 45 08             	mov    0x8(%ebp),%eax
  801936:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801939:	89 c2                	mov    %eax,%edx
  80193b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80193e:	eb 07                	jmp    801947 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801940:	38 08                	cmp    %cl,(%eax)
  801942:	74 07                	je     80194b <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801944:	83 c0 01             	add    $0x1,%eax
  801947:	39 d0                	cmp    %edx,%eax
  801949:	72 f5                	jb     801940 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    

0080194d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194d:	55                   	push   %ebp
  80194e:	89 e5                	mov    %esp,%ebp
  801950:	57                   	push   %edi
  801951:	56                   	push   %esi
  801952:	53                   	push   %ebx
  801953:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801956:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801959:	eb 03                	jmp    80195e <strtol+0x11>
		s++;
  80195b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195e:	0f b6 01             	movzbl (%ecx),%eax
  801961:	3c 09                	cmp    $0x9,%al
  801963:	74 f6                	je     80195b <strtol+0xe>
  801965:	3c 20                	cmp    $0x20,%al
  801967:	74 f2                	je     80195b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801969:	3c 2b                	cmp    $0x2b,%al
  80196b:	75 0a                	jne    801977 <strtol+0x2a>
		s++;
  80196d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801970:	bf 00 00 00 00       	mov    $0x0,%edi
  801975:	eb 10                	jmp    801987 <strtol+0x3a>
  801977:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197c:	3c 2d                	cmp    $0x2d,%al
  80197e:	75 07                	jne    801987 <strtol+0x3a>
		s++, neg = 1;
  801980:	8d 49 01             	lea    0x1(%ecx),%ecx
  801983:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801987:	85 db                	test   %ebx,%ebx
  801989:	0f 94 c0             	sete   %al
  80198c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801992:	75 19                	jne    8019ad <strtol+0x60>
  801994:	80 39 30             	cmpb   $0x30,(%ecx)
  801997:	75 14                	jne    8019ad <strtol+0x60>
  801999:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80199d:	0f 85 8a 00 00 00    	jne    801a2d <strtol+0xe0>
		s += 2, base = 16;
  8019a3:	83 c1 02             	add    $0x2,%ecx
  8019a6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019ab:	eb 16                	jmp    8019c3 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019ad:	84 c0                	test   %al,%al
  8019af:	74 12                	je     8019c3 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019b1:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b6:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b9:	75 08                	jne    8019c3 <strtol+0x76>
		s++, base = 8;
  8019bb:	83 c1 01             	add    $0x1,%ecx
  8019be:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c8:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019cb:	0f b6 11             	movzbl (%ecx),%edx
  8019ce:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019d1:	89 f3                	mov    %esi,%ebx
  8019d3:	80 fb 09             	cmp    $0x9,%bl
  8019d6:	77 08                	ja     8019e0 <strtol+0x93>
			dig = *s - '0';
  8019d8:	0f be d2             	movsbl %dl,%edx
  8019db:	83 ea 30             	sub    $0x30,%edx
  8019de:	eb 22                	jmp    801a02 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019e0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019e3:	89 f3                	mov    %esi,%ebx
  8019e5:	80 fb 19             	cmp    $0x19,%bl
  8019e8:	77 08                	ja     8019f2 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019ea:	0f be d2             	movsbl %dl,%edx
  8019ed:	83 ea 57             	sub    $0x57,%edx
  8019f0:	eb 10                	jmp    801a02 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019f2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019f5:	89 f3                	mov    %esi,%ebx
  8019f7:	80 fb 19             	cmp    $0x19,%bl
  8019fa:	77 16                	ja     801a12 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019fc:	0f be d2             	movsbl %dl,%edx
  8019ff:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a02:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a05:	7d 0f                	jge    801a16 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801a07:	83 c1 01             	add    $0x1,%ecx
  801a0a:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a0e:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a10:	eb b9                	jmp    8019cb <strtol+0x7e>
  801a12:	89 c2                	mov    %eax,%edx
  801a14:	eb 02                	jmp    801a18 <strtol+0xcb>
  801a16:	89 c2                	mov    %eax,%edx

	if (endptr)
  801a18:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a1c:	74 05                	je     801a23 <strtol+0xd6>
		*endptr = (char *) s;
  801a1e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a21:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a23:	85 ff                	test   %edi,%edi
  801a25:	74 0c                	je     801a33 <strtol+0xe6>
  801a27:	89 d0                	mov    %edx,%eax
  801a29:	f7 d8                	neg    %eax
  801a2b:	eb 06                	jmp    801a33 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a2d:	84 c0                	test   %al,%al
  801a2f:	75 8a                	jne    8019bb <strtol+0x6e>
  801a31:	eb 90                	jmp    8019c3 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a33:	5b                   	pop    %ebx
  801a34:	5e                   	pop    %esi
  801a35:	5f                   	pop    %edi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  801a3e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801a45:	75 2c                	jne    801a73 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801a47:	83 ec 04             	sub    $0x4,%esp
  801a4a:	6a 07                	push   $0x7
  801a4c:	68 00 f0 7f ee       	push   $0xee7ff000
  801a51:	6a 00                	push   $0x0
  801a53:	e8 18 e7 ff ff       	call   800170 <sys_page_alloc>
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	79 14                	jns    801a73 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  801a5f:	83 ec 04             	sub    $0x4,%esp
  801a62:	68 60 23 80 00       	push   $0x802360
  801a67:	6a 1f                	push   $0x1f
  801a69:	68 c4 23 80 00       	push   $0x8023c4
  801a6e:	e8 1a f6 ff ff       	call   80108d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	a3 00 60 80 00       	mov    %eax,0x806000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  801a7b:	83 ec 08             	sub    $0x8,%esp
  801a7e:	68 80 03 80 00       	push   $0x800380
  801a83:	6a 00                	push   $0x0
  801a85:	e8 31 e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	79 14                	jns    801aa5 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  801a91:	83 ec 04             	sub    $0x4,%esp
  801a94:	68 8c 23 80 00       	push   $0x80238c
  801a99:	6a 25                	push   $0x25
  801a9b:	68 c4 23 80 00       	push   $0x8023c4
  801aa0:	e8 e8 f5 ff ff       	call   80108d <_panic>
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	8b 75 08             	mov    0x8(%ebp),%esi
  801aaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801ab5:	85 f6                	test   %esi,%esi
  801ab7:	74 06                	je     801abf <ipc_recv+0x18>
  801ab9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801abf:	85 db                	test   %ebx,%ebx
  801ac1:	74 06                	je     801ac9 <ipc_recv+0x22>
  801ac3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801ac9:	83 f8 01             	cmp    $0x1,%eax
  801acc:	19 d2                	sbb    %edx,%edx
  801ace:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801ad0:	83 ec 0c             	sub    $0xc,%esp
  801ad3:	50                   	push   %eax
  801ad4:	e8 47 e8 ff ff       	call   800320 <sys_ipc_recv>
  801ad9:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801adb:	83 c4 10             	add    $0x10,%esp
  801ade:	85 d2                	test   %edx,%edx
  801ae0:	75 24                	jne    801b06 <ipc_recv+0x5f>
	if (from_env_store)
  801ae2:	85 f6                	test   %esi,%esi
  801ae4:	74 0a                	je     801af0 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801ae6:	a1 04 40 80 00       	mov    0x804004,%eax
  801aeb:	8b 40 70             	mov    0x70(%eax),%eax
  801aee:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801af0:	85 db                	test   %ebx,%ebx
  801af2:	74 0a                	je     801afe <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801af4:	a1 04 40 80 00       	mov    0x804004,%eax
  801af9:	8b 40 74             	mov    0x74(%eax),%eax
  801afc:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801afe:	a1 04 40 80 00       	mov    0x804004,%eax
  801b03:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801b06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b09:	5b                   	pop    %ebx
  801b0a:	5e                   	pop    %esi
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    

00801b0d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	57                   	push   %edi
  801b11:	56                   	push   %esi
  801b12:	53                   	push   %ebx
  801b13:	83 ec 0c             	sub    $0xc,%esp
  801b16:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b19:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801b1f:	83 fb 01             	cmp    $0x1,%ebx
  801b22:	19 c0                	sbb    %eax,%eax
  801b24:	09 c3                	or     %eax,%ebx
  801b26:	eb 1c                	jmp    801b44 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801b28:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b2b:	74 12                	je     801b3f <ipc_send+0x32>
  801b2d:	50                   	push   %eax
  801b2e:	68 d2 23 80 00       	push   $0x8023d2
  801b33:	6a 36                	push   $0x36
  801b35:	68 e9 23 80 00       	push   $0x8023e9
  801b3a:	e8 4e f5 ff ff       	call   80108d <_panic>
		sys_yield();
  801b3f:	e8 0d e6 ff ff       	call   800151 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b44:	ff 75 14             	pushl  0x14(%ebp)
  801b47:	53                   	push   %ebx
  801b48:	56                   	push   %esi
  801b49:	57                   	push   %edi
  801b4a:	e8 ae e7 ff ff       	call   8002fd <sys_ipc_try_send>
		if (ret == 0) break;
  801b4f:	83 c4 10             	add    $0x10,%esp
  801b52:	85 c0                	test   %eax,%eax
  801b54:	75 d2                	jne    801b28 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b69:	6b d0 78             	imul   $0x78,%eax,%edx
  801b6c:	83 c2 50             	add    $0x50,%edx
  801b6f:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801b75:	39 ca                	cmp    %ecx,%edx
  801b77:	75 0d                	jne    801b86 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b79:	6b c0 78             	imul   $0x78,%eax,%eax
  801b7c:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b81:	8b 40 08             	mov    0x8(%eax),%eax
  801b84:	eb 0e                	jmp    801b94 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b86:	83 c0 01             	add    $0x1,%eax
  801b89:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b8e:	75 d9                	jne    801b69 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b90:	66 b8 00 00          	mov    $0x0,%ax
}
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b9c:	89 d0                	mov    %edx,%eax
  801b9e:	c1 e8 16             	shr    $0x16,%eax
  801ba1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801ba8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801bad:	f6 c1 01             	test   $0x1,%cl
  801bb0:	74 1d                	je     801bcf <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801bb2:	c1 ea 0c             	shr    $0xc,%edx
  801bb5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801bbc:	f6 c2 01             	test   $0x1,%dl
  801bbf:	74 0e                	je     801bcf <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bc1:	c1 ea 0c             	shr    $0xc,%edx
  801bc4:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bcb:	ef 
  801bcc:	0f b7 c0             	movzwl %ax,%eax
}
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    
  801bd1:	66 90                	xchg   %ax,%ax
  801bd3:	66 90                	xchg   %ax,%ax
  801bd5:	66 90                	xchg   %ax,%ax
  801bd7:	66 90                	xchg   %ax,%ax
  801bd9:	66 90                	xchg   %ax,%ax
  801bdb:	66 90                	xchg   %ax,%ax
  801bdd:	66 90                	xchg   %ax,%ax
  801bdf:	90                   	nop

00801be0 <__udivdi3>:
  801be0:	55                   	push   %ebp
  801be1:	57                   	push   %edi
  801be2:	56                   	push   %esi
  801be3:	83 ec 10             	sub    $0x10,%esp
  801be6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801bea:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bee:	8b 74 24 24          	mov    0x24(%esp),%esi
  801bf2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801bf6:	85 d2                	test   %edx,%edx
  801bf8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bfc:	89 34 24             	mov    %esi,(%esp)
  801bff:	89 c8                	mov    %ecx,%eax
  801c01:	75 35                	jne    801c38 <__udivdi3+0x58>
  801c03:	39 f1                	cmp    %esi,%ecx
  801c05:	0f 87 bd 00 00 00    	ja     801cc8 <__udivdi3+0xe8>
  801c0b:	85 c9                	test   %ecx,%ecx
  801c0d:	89 cd                	mov    %ecx,%ebp
  801c0f:	75 0b                	jne    801c1c <__udivdi3+0x3c>
  801c11:	b8 01 00 00 00       	mov    $0x1,%eax
  801c16:	31 d2                	xor    %edx,%edx
  801c18:	f7 f1                	div    %ecx
  801c1a:	89 c5                	mov    %eax,%ebp
  801c1c:	89 f0                	mov    %esi,%eax
  801c1e:	31 d2                	xor    %edx,%edx
  801c20:	f7 f5                	div    %ebp
  801c22:	89 c6                	mov    %eax,%esi
  801c24:	89 f8                	mov    %edi,%eax
  801c26:	f7 f5                	div    %ebp
  801c28:	89 f2                	mov    %esi,%edx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	5e                   	pop    %esi
  801c2e:	5f                   	pop    %edi
  801c2f:	5d                   	pop    %ebp
  801c30:	c3                   	ret    
  801c31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c38:	3b 14 24             	cmp    (%esp),%edx
  801c3b:	77 7b                	ja     801cb8 <__udivdi3+0xd8>
  801c3d:	0f bd f2             	bsr    %edx,%esi
  801c40:	83 f6 1f             	xor    $0x1f,%esi
  801c43:	0f 84 97 00 00 00    	je     801ce0 <__udivdi3+0x100>
  801c49:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c4e:	89 d7                	mov    %edx,%edi
  801c50:	89 f1                	mov    %esi,%ecx
  801c52:	29 f5                	sub    %esi,%ebp
  801c54:	d3 e7                	shl    %cl,%edi
  801c56:	89 c2                	mov    %eax,%edx
  801c58:	89 e9                	mov    %ebp,%ecx
  801c5a:	d3 ea                	shr    %cl,%edx
  801c5c:	89 f1                	mov    %esi,%ecx
  801c5e:	09 fa                	or     %edi,%edx
  801c60:	8b 3c 24             	mov    (%esp),%edi
  801c63:	d3 e0                	shl    %cl,%eax
  801c65:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c69:	89 e9                	mov    %ebp,%ecx
  801c6b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c6f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c73:	89 fa                	mov    %edi,%edx
  801c75:	d3 ea                	shr    %cl,%edx
  801c77:	89 f1                	mov    %esi,%ecx
  801c79:	d3 e7                	shl    %cl,%edi
  801c7b:	89 e9                	mov    %ebp,%ecx
  801c7d:	d3 e8                	shr    %cl,%eax
  801c7f:	09 c7                	or     %eax,%edi
  801c81:	89 f8                	mov    %edi,%eax
  801c83:	f7 74 24 08          	divl   0x8(%esp)
  801c87:	89 d5                	mov    %edx,%ebp
  801c89:	89 c7                	mov    %eax,%edi
  801c8b:	f7 64 24 0c          	mull   0xc(%esp)
  801c8f:	39 d5                	cmp    %edx,%ebp
  801c91:	89 14 24             	mov    %edx,(%esp)
  801c94:	72 11                	jb     801ca7 <__udivdi3+0xc7>
  801c96:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c9a:	89 f1                	mov    %esi,%ecx
  801c9c:	d3 e2                	shl    %cl,%edx
  801c9e:	39 c2                	cmp    %eax,%edx
  801ca0:	73 5e                	jae    801d00 <__udivdi3+0x120>
  801ca2:	3b 2c 24             	cmp    (%esp),%ebp
  801ca5:	75 59                	jne    801d00 <__udivdi3+0x120>
  801ca7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801caa:	31 f6                	xor    %esi,%esi
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	31 f6                	xor    %esi,%esi
  801cba:	31 c0                	xor    %eax,%eax
  801cbc:	89 f2                	mov    %esi,%edx
  801cbe:	83 c4 10             	add    $0x10,%esp
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    
  801cc5:	8d 76 00             	lea    0x0(%esi),%esi
  801cc8:	89 f2                	mov    %esi,%edx
  801cca:	31 f6                	xor    %esi,%esi
  801ccc:	89 f8                	mov    %edi,%eax
  801cce:	f7 f1                	div    %ecx
  801cd0:	89 f2                	mov    %esi,%edx
  801cd2:	83 c4 10             	add    $0x10,%esp
  801cd5:	5e                   	pop    %esi
  801cd6:	5f                   	pop    %edi
  801cd7:	5d                   	pop    %ebp
  801cd8:	c3                   	ret    
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801ce4:	76 0b                	jbe    801cf1 <__udivdi3+0x111>
  801ce6:	31 c0                	xor    %eax,%eax
  801ce8:	3b 14 24             	cmp    (%esp),%edx
  801ceb:	0f 83 37 ff ff ff    	jae    801c28 <__udivdi3+0x48>
  801cf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf6:	e9 2d ff ff ff       	jmp    801c28 <__udivdi3+0x48>
  801cfb:	90                   	nop
  801cfc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 f8                	mov    %edi,%eax
  801d02:	31 f6                	xor    %esi,%esi
  801d04:	e9 1f ff ff ff       	jmp    801c28 <__udivdi3+0x48>
  801d09:	66 90                	xchg   %ax,%ax
  801d0b:	66 90                	xchg   %ax,%ax
  801d0d:	66 90                	xchg   %ax,%ax
  801d0f:	90                   	nop

00801d10 <__umoddi3>:
  801d10:	55                   	push   %ebp
  801d11:	57                   	push   %edi
  801d12:	56                   	push   %esi
  801d13:	83 ec 20             	sub    $0x20,%esp
  801d16:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d1a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d1e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d22:	89 c6                	mov    %eax,%esi
  801d24:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d28:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d2c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d30:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d34:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d38:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	75 1e                	jne    801d60 <__umoddi3+0x50>
  801d42:	39 f7                	cmp    %esi,%edi
  801d44:	76 52                	jbe    801d98 <__umoddi3+0x88>
  801d46:	89 c8                	mov    %ecx,%eax
  801d48:	89 f2                	mov    %esi,%edx
  801d4a:	f7 f7                	div    %edi
  801d4c:	89 d0                	mov    %edx,%eax
  801d4e:	31 d2                	xor    %edx,%edx
  801d50:	83 c4 20             	add    $0x20,%esp
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    
  801d57:	89 f6                	mov    %esi,%esi
  801d59:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d60:	39 f0                	cmp    %esi,%eax
  801d62:	77 5c                	ja     801dc0 <__umoddi3+0xb0>
  801d64:	0f bd e8             	bsr    %eax,%ebp
  801d67:	83 f5 1f             	xor    $0x1f,%ebp
  801d6a:	75 64                	jne    801dd0 <__umoddi3+0xc0>
  801d6c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d70:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d74:	0f 86 f6 00 00 00    	jbe    801e70 <__umoddi3+0x160>
  801d7a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d7e:	0f 82 ec 00 00 00    	jb     801e70 <__umoddi3+0x160>
  801d84:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d88:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d8c:	83 c4 20             	add    $0x20,%esp
  801d8f:	5e                   	pop    %esi
  801d90:	5f                   	pop    %edi
  801d91:	5d                   	pop    %ebp
  801d92:	c3                   	ret    
  801d93:	90                   	nop
  801d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d98:	85 ff                	test   %edi,%edi
  801d9a:	89 fd                	mov    %edi,%ebp
  801d9c:	75 0b                	jne    801da9 <__umoddi3+0x99>
  801d9e:	b8 01 00 00 00       	mov    $0x1,%eax
  801da3:	31 d2                	xor    %edx,%edx
  801da5:	f7 f7                	div    %edi
  801da7:	89 c5                	mov    %eax,%ebp
  801da9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801dad:	31 d2                	xor    %edx,%edx
  801daf:	f7 f5                	div    %ebp
  801db1:	89 c8                	mov    %ecx,%eax
  801db3:	f7 f5                	div    %ebp
  801db5:	eb 95                	jmp    801d4c <__umoddi3+0x3c>
  801db7:	89 f6                	mov    %esi,%esi
  801db9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	83 c4 20             	add    $0x20,%esp
  801dc7:	5e                   	pop    %esi
  801dc8:	5f                   	pop    %edi
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    
  801dcb:	90                   	nop
  801dcc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dd0:	b8 20 00 00 00       	mov    $0x20,%eax
  801dd5:	89 e9                	mov    %ebp,%ecx
  801dd7:	29 e8                	sub    %ebp,%eax
  801dd9:	d3 e2                	shl    %cl,%edx
  801ddb:	89 c7                	mov    %eax,%edi
  801ddd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801de1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801de5:	89 f9                	mov    %edi,%ecx
  801de7:	d3 e8                	shr    %cl,%eax
  801de9:	89 c1                	mov    %eax,%ecx
  801deb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801def:	09 d1                	or     %edx,%ecx
  801df1:	89 fa                	mov    %edi,%edx
  801df3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801df7:	89 e9                	mov    %ebp,%ecx
  801df9:	d3 e0                	shl    %cl,%eax
  801dfb:	89 f9                	mov    %edi,%ecx
  801dfd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	d3 e8                	shr    %cl,%eax
  801e05:	89 e9                	mov    %ebp,%ecx
  801e07:	89 c7                	mov    %eax,%edi
  801e09:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801e0d:	d3 e6                	shl    %cl,%esi
  801e0f:	89 d1                	mov    %edx,%ecx
  801e11:	89 fa                	mov    %edi,%edx
  801e13:	d3 e8                	shr    %cl,%eax
  801e15:	89 e9                	mov    %ebp,%ecx
  801e17:	09 f0                	or     %esi,%eax
  801e19:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e1d:	f7 74 24 10          	divl   0x10(%esp)
  801e21:	d3 e6                	shl    %cl,%esi
  801e23:	89 d1                	mov    %edx,%ecx
  801e25:	f7 64 24 0c          	mull   0xc(%esp)
  801e29:	39 d1                	cmp    %edx,%ecx
  801e2b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e2f:	89 d7                	mov    %edx,%edi
  801e31:	89 c6                	mov    %eax,%esi
  801e33:	72 0a                	jb     801e3f <__umoddi3+0x12f>
  801e35:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e39:	73 10                	jae    801e4b <__umoddi3+0x13b>
  801e3b:	39 d1                	cmp    %edx,%ecx
  801e3d:	75 0c                	jne    801e4b <__umoddi3+0x13b>
  801e3f:	89 d7                	mov    %edx,%edi
  801e41:	89 c6                	mov    %eax,%esi
  801e43:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e47:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e4b:	89 ca                	mov    %ecx,%edx
  801e4d:	89 e9                	mov    %ebp,%ecx
  801e4f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e53:	29 f0                	sub    %esi,%eax
  801e55:	19 fa                	sbb    %edi,%edx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e5e:	89 d7                	mov    %edx,%edi
  801e60:	d3 e7                	shl    %cl,%edi
  801e62:	89 e9                	mov    %ebp,%ecx
  801e64:	09 f8                	or     %edi,%eax
  801e66:	d3 ea                	shr    %cl,%edx
  801e68:	83 c4 20             	add    $0x20,%esp
  801e6b:	5e                   	pop    %esi
  801e6c:	5f                   	pop    %edi
  801e6d:	5d                   	pop    %ebp
  801e6e:	c3                   	ret    
  801e6f:	90                   	nop
  801e70:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e74:	29 f9                	sub    %edi,%ecx
  801e76:	19 c6                	sbb    %eax,%esi
  801e78:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e7c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e80:	e9 ff fe ff ff       	jmp    801d84 <__umoddi3+0x74>
