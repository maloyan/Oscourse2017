
obj/user/evilhello:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	// try to print the kernel entry point as a string!  mua ha ha!
	sys_cputs((char*)0xf010000c, 100);
  800039:	6a 64                	push   $0x64
  80003b:	68 0c 00 10 f0       	push   $0xf010000c
  800040:	e8 65 00 00 00       	call   8000aa <sys_cputs>
  800045:	83 c4 10             	add    $0x10,%esp
}
  800048:	c9                   	leave  
  800049:	c3                   	ret    

0080004a <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 78             	imul   $0x78,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
  800086:	83 c4 10             	add    $0x10,%esp
#endif
}
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 a7 04 00 00       	call   800542 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
  8000a5:	83 c4 10             	add    $0x10,%esp
}
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7e 17                	jle    800120 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 0a 1e 80 00       	push   $0x801e0a
  800114:	6a 23                	push   $0x23
  800116:	68 27 1e 80 00       	push   $0x801e27
  80011b:	e8 3b 0f 00 00       	call   80105b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5f                   	pop    %edi
  800126:	5d                   	pop    %ebp
  800127:	c3                   	ret    

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	b8 04 00 00 00       	mov    $0x4,%eax
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	8b 55 08             	mov    0x8(%ebp),%edx
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7e 17                	jle    8001a1 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 0a 1e 80 00       	push   $0x801e0a
  800195:	6a 23                	push   $0x23
  800197:	68 27 1e 80 00       	push   $0x801e27
  80019c:	e8 ba 0e 00 00       	call   80105b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a4:	5b                   	pop    %ebx
  8001a5:	5e                   	pop    %esi
  8001a6:	5f                   	pop    %edi
  8001a7:	5d                   	pop    %ebp
  8001a8:	c3                   	ret    

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 17                	jle    8001e3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 0a 1e 80 00       	push   $0x801e0a
  8001d7:	6a 23                	push   $0x23
  8001d9:	68 27 1e 80 00       	push   $0x801e27
  8001de:	e8 78 0e 00 00       	call   80105b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5e                   	pop    %esi
  8001e8:	5f                   	pop    %edi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	8b 55 08             	mov    0x8(%ebp),%edx
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7e 17                	jle    800225 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 0a 1e 80 00       	push   $0x801e0a
  800219:	6a 23                	push   $0x23
  80021b:	68 27 1e 80 00       	push   $0x801e27
  800220:	e8 36 0e 00 00       	call   80105b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800225:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800228:	5b                   	pop    %ebx
  800229:	5e                   	pop    %esi
  80022a:	5f                   	pop    %edi
  80022b:	5d                   	pop    %ebp
  80022c:	c3                   	ret    

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	b8 08 00 00 00       	mov    $0x8,%eax
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	8b 55 08             	mov    0x8(%ebp),%edx
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7e 17                	jle    800267 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 0a 1e 80 00       	push   $0x801e0a
  80025b:	6a 23                	push   $0x23
  80025d:	68 27 1e 80 00       	push   $0x801e27
  800262:	e8 f4 0d 00 00       	call   80105b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026a:	5b                   	pop    %ebx
  80026b:	5e                   	pop    %esi
  80026c:	5f                   	pop    %edi
  80026d:	5d                   	pop    %ebp
  80026e:	c3                   	ret    

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	8b 55 08             	mov    0x8(%ebp),%edx
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7e 17                	jle    8002a9 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 0a 1e 80 00       	push   $0x801e0a
  80029d:	6a 23                	push   $0x23
  80029f:	68 27 1e 80 00       	push   $0x801e27
  8002a4:	e8 b2 0d 00 00       	call   80105b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ac:	5b                   	pop    %ebx
  8002ad:	5e                   	pop    %esi
  8002ae:	5f                   	pop    %edi
  8002af:	5d                   	pop    %ebp
  8002b0:	c3                   	ret    

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7e 17                	jle    8002eb <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	50                   	push   %eax
  8002d8:	6a 0a                	push   $0xa
  8002da:	68 0a 1e 80 00       	push   $0x801e0a
  8002df:	6a 23                	push   $0x23
  8002e1:	68 27 1e 80 00       	push   $0x801e27
  8002e6:	e8 70 0d 00 00       	call   80105b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f9:	be 00 00 00 00       	mov    $0x0,%esi
  8002fe:	b8 0c 00 00 00       	mov    $0xc,%eax
  800303:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	b8 0d 00 00 00       	mov    $0xd,%eax
  800329:	8b 55 08             	mov    0x8(%ebp),%edx
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7e 17                	jle    80034f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800338:	83 ec 0c             	sub    $0xc,%esp
  80033b:	50                   	push   %eax
  80033c:	6a 0d                	push   $0xd
  80033e:	68 0a 1e 80 00       	push   $0x801e0a
  800343:	6a 23                	push   $0x23
  800345:	68 27 1e 80 00       	push   $0x801e27
  80034a:	e8 0c 0d 00 00       	call   80105b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800352:	5b                   	pop    %ebx
  800353:	5e                   	pop    %esi
  800354:	5f                   	pop    %edi
  800355:	5d                   	pop    %ebp
  800356:	c3                   	ret    

00800357 <sys_gettime>:

int sys_gettime(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	05 00 00 00 30       	add    $0x30000000,%eax
  800381:	c1 e8 0c             	shr    $0xc,%eax
}
  800384:	5d                   	pop    %ebp
  800385:	c3                   	ret    

00800386 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800391:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800396:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80039b:	5d                   	pop    %ebp
  80039c:	c3                   	ret    

0080039d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80039d:	55                   	push   %ebp
  80039e:	89 e5                	mov    %esp,%ebp
  8003a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 16             	shr    $0x16,%edx
  8003ad:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	74 11                	je     8003ca <fd_alloc+0x2d>
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	c1 ea 0c             	shr    $0xc,%edx
  8003be:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c5:	f6 c2 01             	test   $0x1,%dl
  8003c8:	75 09                	jne    8003d3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ca:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d1:	eb 17                	jmp    8003ea <fd_alloc+0x4d>
  8003d3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003dd:	75 c9                	jne    8003a8 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003df:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ea:	5d                   	pop    %ebp
  8003eb:	c3                   	ret    

008003ec <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f2:	83 f8 1f             	cmp    $0x1f,%eax
  8003f5:	77 36                	ja     80042d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f7:	c1 e0 0c             	shl    $0xc,%eax
  8003fa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 16             	shr    $0x16,%edx
  800404:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 24                	je     800434 <fd_lookup+0x48>
  800410:	89 c2                	mov    %eax,%edx
  800412:	c1 ea 0c             	shr    $0xc,%edx
  800415:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041c:	f6 c2 01             	test   $0x1,%dl
  80041f:	74 1a                	je     80043b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800421:	8b 55 0c             	mov    0xc(%ebp),%edx
  800424:	89 02                	mov    %eax,(%edx)
	return 0;
  800426:	b8 00 00 00 00       	mov    $0x0,%eax
  80042b:	eb 13                	jmp    800440 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800432:	eb 0c                	jmp    800440 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800434:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800439:	eb 05                	jmp    800440 <fd_lookup+0x54>
  80043b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800440:	5d                   	pop    %ebp
  800441:	c3                   	ret    

00800442 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800442:	55                   	push   %ebp
  800443:	89 e5                	mov    %esp,%ebp
  800445:	83 ec 08             	sub    $0x8,%esp
  800448:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044b:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800450:	eb 13                	jmp    800465 <dev_lookup+0x23>
  800452:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800455:	39 08                	cmp    %ecx,(%eax)
  800457:	75 0c                	jne    800465 <dev_lookup+0x23>
			*dev = devtab[i];
  800459:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80045c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	eb 2e                	jmp    800493 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800465:	8b 02                	mov    (%edx),%eax
  800467:	85 c0                	test   %eax,%eax
  800469:	75 e7                	jne    800452 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046b:	a1 04 40 80 00       	mov    0x804004,%eax
  800470:	8b 40 48             	mov    0x48(%eax),%eax
  800473:	83 ec 04             	sub    $0x4,%esp
  800476:	51                   	push   %ecx
  800477:	50                   	push   %eax
  800478:	68 38 1e 80 00       	push   $0x801e38
  80047d:	e8 b2 0c 00 00       	call   801134 <cprintf>
	*dev = 0;
  800482:	8b 45 0c             	mov    0xc(%ebp),%eax
  800485:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80048b:	83 c4 10             	add    $0x10,%esp
  80048e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800493:	c9                   	leave  
  800494:	c3                   	ret    

00800495 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	56                   	push   %esi
  800499:	53                   	push   %ebx
  80049a:	83 ec 10             	sub    $0x10,%esp
  80049d:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a6:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004a7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ad:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b0:	50                   	push   %eax
  8004b1:	e8 36 ff ff ff       	call   8003ec <fd_lookup>
  8004b6:	83 c4 08             	add    $0x8,%esp
  8004b9:	85 c0                	test   %eax,%eax
  8004bb:	78 05                	js     8004c2 <fd_close+0x2d>
	    || fd != fd2)
  8004bd:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c0:	74 0b                	je     8004cd <fd_close+0x38>
		return (must_exist ? r : 0);
  8004c2:	80 fb 01             	cmp    $0x1,%bl
  8004c5:	19 d2                	sbb    %edx,%edx
  8004c7:	f7 d2                	not    %edx
  8004c9:	21 d0                	and    %edx,%eax
  8004cb:	eb 41                	jmp    80050e <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d3:	50                   	push   %eax
  8004d4:	ff 36                	pushl  (%esi)
  8004d6:	e8 67 ff ff ff       	call   800442 <dev_lookup>
  8004db:	89 c3                	mov    %eax,%ebx
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	85 c0                	test   %eax,%eax
  8004e2:	78 1a                	js     8004fe <fd_close+0x69>
		if (dev->dev_close)
  8004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004ea:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	74 0b                	je     8004fe <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8004f3:	83 ec 0c             	sub    $0xc,%esp
  8004f6:	56                   	push   %esi
  8004f7:	ff d0                	call   *%eax
  8004f9:	89 c3                	mov    %eax,%ebx
  8004fb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fe:	83 ec 08             	sub    $0x8,%esp
  800501:	56                   	push   %esi
  800502:	6a 00                	push   $0x0
  800504:	e8 e2 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	89 d8                	mov    %ebx,%eax
}
  80050e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800511:	5b                   	pop    %ebx
  800512:	5e                   	pop    %esi
  800513:	5d                   	pop    %ebp
  800514:	c3                   	ret    

00800515 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800515:	55                   	push   %ebp
  800516:	89 e5                	mov    %esp,%ebp
  800518:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80051b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051e:	50                   	push   %eax
  80051f:	ff 75 08             	pushl  0x8(%ebp)
  800522:	e8 c5 fe ff ff       	call   8003ec <fd_lookup>
  800527:	89 c2                	mov    %eax,%edx
  800529:	83 c4 08             	add    $0x8,%esp
  80052c:	85 d2                	test   %edx,%edx
  80052e:	78 10                	js     800540 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	6a 01                	push   $0x1
  800535:	ff 75 f4             	pushl  -0xc(%ebp)
  800538:	e8 58 ff ff ff       	call   800495 <fd_close>
  80053d:	83 c4 10             	add    $0x10,%esp
}
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <close_all>:

void
close_all(void)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	53                   	push   %ebx
  800546:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800549:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054e:	83 ec 0c             	sub    $0xc,%esp
  800551:	53                   	push   %ebx
  800552:	e8 be ff ff ff       	call   800515 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800557:	83 c3 01             	add    $0x1,%ebx
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	83 fb 20             	cmp    $0x20,%ebx
  800560:	75 ec                	jne    80054e <close_all+0xc>
		close(i);
}
  800562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800565:	c9                   	leave  
  800566:	c3                   	ret    

00800567 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800567:	55                   	push   %ebp
  800568:	89 e5                	mov    %esp,%ebp
  80056a:	57                   	push   %edi
  80056b:	56                   	push   %esi
  80056c:	53                   	push   %ebx
  80056d:	83 ec 2c             	sub    $0x2c,%esp
  800570:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800573:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800576:	50                   	push   %eax
  800577:	ff 75 08             	pushl  0x8(%ebp)
  80057a:	e8 6d fe ff ff       	call   8003ec <fd_lookup>
  80057f:	89 c2                	mov    %eax,%edx
  800581:	83 c4 08             	add    $0x8,%esp
  800584:	85 d2                	test   %edx,%edx
  800586:	0f 88 c1 00 00 00    	js     80064d <dup+0xe6>
		return r;
	close(newfdnum);
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	56                   	push   %esi
  800590:	e8 80 ff ff ff       	call   800515 <close>

	newfd = INDEX2FD(newfdnum);
  800595:	89 f3                	mov    %esi,%ebx
  800597:	c1 e3 0c             	shl    $0xc,%ebx
  80059a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005a0:	83 c4 04             	add    $0x4,%esp
  8005a3:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a6:	e8 db fd ff ff       	call   800386 <fd2data>
  8005ab:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005ad:	89 1c 24             	mov    %ebx,(%esp)
  8005b0:	e8 d1 fd ff ff       	call   800386 <fd2data>
  8005b5:	83 c4 10             	add    $0x10,%esp
  8005b8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005bb:	89 f8                	mov    %edi,%eax
  8005bd:	c1 e8 16             	shr    $0x16,%eax
  8005c0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c7:	a8 01                	test   $0x1,%al
  8005c9:	74 37                	je     800602 <dup+0x9b>
  8005cb:	89 f8                	mov    %edi,%eax
  8005cd:	c1 e8 0c             	shr    $0xc,%eax
  8005d0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d7:	f6 c2 01             	test   $0x1,%dl
  8005da:	74 26                	je     800602 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ef:	6a 00                	push   $0x0
  8005f1:	57                   	push   %edi
  8005f2:	6a 00                	push   $0x0
  8005f4:	e8 b0 fb ff ff       	call   8001a9 <sys_page_map>
  8005f9:	89 c7                	mov    %eax,%edi
  8005fb:	83 c4 20             	add    $0x20,%esp
  8005fe:	85 c0                	test   %eax,%eax
  800600:	78 2e                	js     800630 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800605:	89 d0                	mov    %edx,%eax
  800607:	c1 e8 0c             	shr    $0xc,%eax
  80060a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	25 07 0e 00 00       	and    $0xe07,%eax
  800619:	50                   	push   %eax
  80061a:	53                   	push   %ebx
  80061b:	6a 00                	push   $0x0
  80061d:	52                   	push   %edx
  80061e:	6a 00                	push   $0x0
  800620:	e8 84 fb ff ff       	call   8001a9 <sys_page_map>
  800625:	89 c7                	mov    %eax,%edi
  800627:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80062a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80062c:	85 ff                	test   %edi,%edi
  80062e:	79 1d                	jns    80064d <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 00                	push   $0x0
  800636:	e8 b0 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800641:	6a 00                	push   $0x0
  800643:	e8 a3 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	89 f8                	mov    %edi,%eax
}
  80064d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800650:	5b                   	pop    %ebx
  800651:	5e                   	pop    %esi
  800652:	5f                   	pop    %edi
  800653:	5d                   	pop    %ebp
  800654:	c3                   	ret    

00800655 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800655:	55                   	push   %ebp
  800656:	89 e5                	mov    %esp,%ebp
  800658:	53                   	push   %ebx
  800659:	83 ec 14             	sub    $0x14,%esp
  80065c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80065f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800662:	50                   	push   %eax
  800663:	53                   	push   %ebx
  800664:	e8 83 fd ff ff       	call   8003ec <fd_lookup>
  800669:	83 c4 08             	add    $0x8,%esp
  80066c:	89 c2                	mov    %eax,%edx
  80066e:	85 c0                	test   %eax,%eax
  800670:	78 6d                	js     8006df <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800678:	50                   	push   %eax
  800679:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80067c:	ff 30                	pushl  (%eax)
  80067e:	e8 bf fd ff ff       	call   800442 <dev_lookup>
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	85 c0                	test   %eax,%eax
  800688:	78 4c                	js     8006d6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068d:	8b 42 08             	mov    0x8(%edx),%eax
  800690:	83 e0 03             	and    $0x3,%eax
  800693:	83 f8 01             	cmp    $0x1,%eax
  800696:	75 21                	jne    8006b9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800698:	a1 04 40 80 00       	mov    0x804004,%eax
  80069d:	8b 40 48             	mov    0x48(%eax),%eax
  8006a0:	83 ec 04             	sub    $0x4,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	50                   	push   %eax
  8006a5:	68 79 1e 80 00       	push   $0x801e79
  8006aa:	e8 85 0a 00 00       	call   801134 <cprintf>
		return -E_INVAL;
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b7:	eb 26                	jmp    8006df <read+0x8a>
	}
	if (!dev->dev_read)
  8006b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006bc:	8b 40 08             	mov    0x8(%eax),%eax
  8006bf:	85 c0                	test   %eax,%eax
  8006c1:	74 17                	je     8006da <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c3:	83 ec 04             	sub    $0x4,%esp
  8006c6:	ff 75 10             	pushl  0x10(%ebp)
  8006c9:	ff 75 0c             	pushl  0xc(%ebp)
  8006cc:	52                   	push   %edx
  8006cd:	ff d0                	call   *%eax
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	eb 09                	jmp    8006df <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d6:	89 c2                	mov    %eax,%edx
  8006d8:	eb 05                	jmp    8006df <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006df:	89 d0                	mov    %edx,%eax
  8006e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e4:	c9                   	leave  
  8006e5:	c3                   	ret    

008006e6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e6:	55                   	push   %ebp
  8006e7:	89 e5                	mov    %esp,%ebp
  8006e9:	57                   	push   %edi
  8006ea:	56                   	push   %esi
  8006eb:	53                   	push   %ebx
  8006ec:	83 ec 0c             	sub    $0xc,%esp
  8006ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fa:	eb 21                	jmp    80071d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fc:	83 ec 04             	sub    $0x4,%esp
  8006ff:	89 f0                	mov    %esi,%eax
  800701:	29 d8                	sub    %ebx,%eax
  800703:	50                   	push   %eax
  800704:	89 d8                	mov    %ebx,%eax
  800706:	03 45 0c             	add    0xc(%ebp),%eax
  800709:	50                   	push   %eax
  80070a:	57                   	push   %edi
  80070b:	e8 45 ff ff ff       	call   800655 <read>
		if (m < 0)
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	85 c0                	test   %eax,%eax
  800715:	78 0c                	js     800723 <readn+0x3d>
			return m;
		if (m == 0)
  800717:	85 c0                	test   %eax,%eax
  800719:	74 06                	je     800721 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071b:	01 c3                	add    %eax,%ebx
  80071d:	39 f3                	cmp    %esi,%ebx
  80071f:	72 db                	jb     8006fc <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800721:	89 d8                	mov    %ebx,%eax
}
  800723:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5f                   	pop    %edi
  800729:	5d                   	pop    %ebp
  80072a:	c3                   	ret    

0080072b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	53                   	push   %ebx
  80072f:	83 ec 14             	sub    $0x14,%esp
  800732:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800735:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	53                   	push   %ebx
  80073a:	e8 ad fc ff ff       	call   8003ec <fd_lookup>
  80073f:	83 c4 08             	add    $0x8,%esp
  800742:	89 c2                	mov    %eax,%edx
  800744:	85 c0                	test   %eax,%eax
  800746:	78 68                	js     8007b0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800748:	83 ec 08             	sub    $0x8,%esp
  80074b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074e:	50                   	push   %eax
  80074f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800752:	ff 30                	pushl  (%eax)
  800754:	e8 e9 fc ff ff       	call   800442 <dev_lookup>
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	85 c0                	test   %eax,%eax
  80075e:	78 47                	js     8007a7 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800760:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800763:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800767:	75 21                	jne    80078a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800769:	a1 04 40 80 00       	mov    0x804004,%eax
  80076e:	8b 40 48             	mov    0x48(%eax),%eax
  800771:	83 ec 04             	sub    $0x4,%esp
  800774:	53                   	push   %ebx
  800775:	50                   	push   %eax
  800776:	68 95 1e 80 00       	push   $0x801e95
  80077b:	e8 b4 09 00 00       	call   801134 <cprintf>
		return -E_INVAL;
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800788:	eb 26                	jmp    8007b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078d:	8b 52 0c             	mov    0xc(%edx),%edx
  800790:	85 d2                	test   %edx,%edx
  800792:	74 17                	je     8007ab <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800794:	83 ec 04             	sub    $0x4,%esp
  800797:	ff 75 10             	pushl  0x10(%ebp)
  80079a:	ff 75 0c             	pushl  0xc(%ebp)
  80079d:	50                   	push   %eax
  80079e:	ff d2                	call   *%edx
  8007a0:	89 c2                	mov    %eax,%edx
  8007a2:	83 c4 10             	add    $0x10,%esp
  8007a5:	eb 09                	jmp    8007b0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a7:	89 c2                	mov    %eax,%edx
  8007a9:	eb 05                	jmp    8007b0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007ab:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007b0:	89 d0                	mov    %edx,%eax
  8007b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b5:	c9                   	leave  
  8007b6:	c3                   	ret    

008007b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b7:	55                   	push   %ebp
  8007b8:	89 e5                	mov    %esp,%ebp
  8007ba:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007bd:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c0:	50                   	push   %eax
  8007c1:	ff 75 08             	pushl  0x8(%ebp)
  8007c4:	e8 23 fc ff ff       	call   8003ec <fd_lookup>
  8007c9:	83 c4 08             	add    $0x8,%esp
  8007cc:	85 c0                	test   %eax,%eax
  8007ce:	78 0e                	js     8007de <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	83 ec 14             	sub    $0x14,%esp
  8007e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ed:	50                   	push   %eax
  8007ee:	53                   	push   %ebx
  8007ef:	e8 f8 fb ff ff       	call   8003ec <fd_lookup>
  8007f4:	83 c4 08             	add    $0x8,%esp
  8007f7:	89 c2                	mov    %eax,%edx
  8007f9:	85 c0                	test   %eax,%eax
  8007fb:	78 65                	js     800862 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800803:	50                   	push   %eax
  800804:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800807:	ff 30                	pushl  (%eax)
  800809:	e8 34 fc ff ff       	call   800442 <dev_lookup>
  80080e:	83 c4 10             	add    $0x10,%esp
  800811:	85 c0                	test   %eax,%eax
  800813:	78 44                	js     800859 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800815:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800818:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80081c:	75 21                	jne    80083f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800823:	8b 40 48             	mov    0x48(%eax),%eax
  800826:	83 ec 04             	sub    $0x4,%esp
  800829:	53                   	push   %ebx
  80082a:	50                   	push   %eax
  80082b:	68 58 1e 80 00       	push   $0x801e58
  800830:	e8 ff 08 00 00       	call   801134 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083d:	eb 23                	jmp    800862 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800842:	8b 52 18             	mov    0x18(%edx),%edx
  800845:	85 d2                	test   %edx,%edx
  800847:	74 14                	je     80085d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800849:	83 ec 08             	sub    $0x8,%esp
  80084c:	ff 75 0c             	pushl  0xc(%ebp)
  80084f:	50                   	push   %eax
  800850:	ff d2                	call   *%edx
  800852:	89 c2                	mov    %eax,%edx
  800854:	83 c4 10             	add    $0x10,%esp
  800857:	eb 09                	jmp    800862 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800859:	89 c2                	mov    %eax,%edx
  80085b:	eb 05                	jmp    800862 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800862:	89 d0                	mov    %edx,%eax
  800864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800867:	c9                   	leave  
  800868:	c3                   	ret    

00800869 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	53                   	push   %ebx
  80086d:	83 ec 14             	sub    $0x14,%esp
  800870:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800873:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800876:	50                   	push   %eax
  800877:	ff 75 08             	pushl  0x8(%ebp)
  80087a:	e8 6d fb ff ff       	call   8003ec <fd_lookup>
  80087f:	83 c4 08             	add    $0x8,%esp
  800882:	89 c2                	mov    %eax,%edx
  800884:	85 c0                	test   %eax,%eax
  800886:	78 58                	js     8008e0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800888:	83 ec 08             	sub    $0x8,%esp
  80088b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088e:	50                   	push   %eax
  80088f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800892:	ff 30                	pushl  (%eax)
  800894:	e8 a9 fb ff ff       	call   800442 <dev_lookup>
  800899:	83 c4 10             	add    $0x10,%esp
  80089c:	85 c0                	test   %eax,%eax
  80089e:	78 37                	js     8008d7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a7:	74 32                	je     8008db <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b3:	00 00 00 
	stat->st_isdir = 0;
  8008b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008bd:	00 00 00 
	stat->st_dev = dev;
  8008c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	53                   	push   %ebx
  8008ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8008cd:	ff 50 14             	call   *0x14(%eax)
  8008d0:	89 c2                	mov    %eax,%edx
  8008d2:	83 c4 10             	add    $0x10,%esp
  8008d5:	eb 09                	jmp    8008e0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d7:	89 c2                	mov    %eax,%edx
  8008d9:	eb 05                	jmp    8008e0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008db:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e0:	89 d0                	mov    %edx,%eax
  8008e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e5:	c9                   	leave  
  8008e6:	c3                   	ret    

008008e7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	56                   	push   %esi
  8008eb:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	6a 00                	push   $0x0
  8008f1:	ff 75 08             	pushl  0x8(%ebp)
  8008f4:	e8 e7 01 00 00       	call   800ae0 <open>
  8008f9:	89 c3                	mov    %eax,%ebx
  8008fb:	83 c4 10             	add    $0x10,%esp
  8008fe:	85 db                	test   %ebx,%ebx
  800900:	78 1b                	js     80091d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	ff 75 0c             	pushl  0xc(%ebp)
  800908:	53                   	push   %ebx
  800909:	e8 5b ff ff ff       	call   800869 <fstat>
  80090e:	89 c6                	mov    %eax,%esi
	close(fd);
  800910:	89 1c 24             	mov    %ebx,(%esp)
  800913:	e8 fd fb ff ff       	call   800515 <close>
	return r;
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	89 f0                	mov    %esi,%eax
}
  80091d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	89 c6                	mov    %eax,%esi
  80092b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800934:	75 12                	jne    800948 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800936:	83 ec 0c             	sub    $0xc,%esp
  800939:	6a 03                	push   $0x3
  80093b:	e8 7d 11 00 00       	call   801abd <ipc_find_env>
  800940:	a3 00 40 80 00       	mov    %eax,0x804000
  800945:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800948:	6a 07                	push   $0x7
  80094a:	68 00 50 80 00       	push   $0x805000
  80094f:	56                   	push   %esi
  800950:	ff 35 00 40 80 00    	pushl  0x804000
  800956:	e8 11 11 00 00       	call   801a6c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095b:	83 c4 0c             	add    $0xc,%esp
  80095e:	6a 00                	push   $0x0
  800960:	53                   	push   %ebx
  800961:	6a 00                	push   $0x0
  800963:	e8 9e 10 00 00       	call   801a06 <ipc_recv>
}
  800968:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096b:	5b                   	pop    %ebx
  80096c:	5e                   	pop    %esi
  80096d:	5d                   	pop    %ebp
  80096e:	c3                   	ret    

0080096f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800980:	8b 45 0c             	mov    0xc(%ebp),%eax
  800983:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800988:	ba 00 00 00 00       	mov    $0x0,%edx
  80098d:	b8 02 00 00 00       	mov    $0x2,%eax
  800992:	e8 8d ff ff ff       	call   800924 <fsipc>
}
  800997:	c9                   	leave  
  800998:	c3                   	ret    

00800999 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800999:	55                   	push   %ebp
  80099a:	89 e5                	mov    %esp,%ebp
  80099c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b4:	e8 6b ff ff ff       	call   800924 <fsipc>
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	53                   	push   %ebx
  8009bf:	83 ec 04             	sub    $0x4,%esp
  8009c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009da:	e8 45 ff ff ff       	call   800924 <fsipc>
  8009df:	89 c2                	mov    %eax,%edx
  8009e1:	85 d2                	test   %edx,%edx
  8009e3:	78 2c                	js     800a11 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e5:	83 ec 08             	sub    $0x8,%esp
  8009e8:	68 00 50 80 00       	push   $0x805000
  8009ed:	53                   	push   %ebx
  8009ee:	e8 c5 0c 00 00       	call   8016b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fe:	a1 84 50 80 00       	mov    0x805084,%eax
  800a03:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a09:	83 c4 10             	add    $0x10,%esp
  800a0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	83 ec 08             	sub    $0x8,%esp
  800a1c:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a22:	8b 52 0c             	mov    0xc(%edx),%edx
  800a25:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a2b:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a30:	76 05                	jbe    800a37 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a32:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a37:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a3c:	83 ec 04             	sub    $0x4,%esp
  800a3f:	50                   	push   %eax
  800a40:	ff 75 0c             	pushl  0xc(%ebp)
  800a43:	68 08 50 80 00       	push   $0x805008
  800a48:	e8 fd 0d 00 00       	call   80184a <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a52:	b8 04 00 00 00       	mov    $0x4,%eax
  800a57:	e8 c8 fe ff ff       	call   800924 <fsipc>
	return write;
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a66:	8b 45 08             	mov    0x8(%ebp),%eax
  800a69:	8b 40 0c             	mov    0xc(%eax),%eax
  800a6c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a71:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a77:	ba 00 00 00 00       	mov    $0x0,%edx
  800a7c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a81:	e8 9e fe ff ff       	call   800924 <fsipc>
  800a86:	89 c3                	mov    %eax,%ebx
  800a88:	85 c0                	test   %eax,%eax
  800a8a:	78 4b                	js     800ad7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a8c:	39 c6                	cmp    %eax,%esi
  800a8e:	73 16                	jae    800aa6 <devfile_read+0x48>
  800a90:	68 c4 1e 80 00       	push   $0x801ec4
  800a95:	68 cb 1e 80 00       	push   $0x801ecb
  800a9a:	6a 7c                	push   $0x7c
  800a9c:	68 e0 1e 80 00       	push   $0x801ee0
  800aa1:	e8 b5 05 00 00       	call   80105b <_panic>
	assert(r <= PGSIZE);
  800aa6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aab:	7e 16                	jle    800ac3 <devfile_read+0x65>
  800aad:	68 eb 1e 80 00       	push   $0x801eeb
  800ab2:	68 cb 1e 80 00       	push   $0x801ecb
  800ab7:	6a 7d                	push   $0x7d
  800ab9:	68 e0 1e 80 00       	push   $0x801ee0
  800abe:	e8 98 05 00 00       	call   80105b <_panic>
	memmove(buf, &fsipcbuf, r);
  800ac3:	83 ec 04             	sub    $0x4,%esp
  800ac6:	50                   	push   %eax
  800ac7:	68 00 50 80 00       	push   $0x805000
  800acc:	ff 75 0c             	pushl  0xc(%ebp)
  800acf:	e8 76 0d 00 00       	call   80184a <memmove>
	return r;
  800ad4:	83 c4 10             	add    $0x10,%esp
}
  800ad7:	89 d8                	mov    %ebx,%eax
  800ad9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800adc:	5b                   	pop    %ebx
  800add:	5e                   	pop    %esi
  800ade:	5d                   	pop    %ebp
  800adf:	c3                   	ret    

00800ae0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae0:	55                   	push   %ebp
  800ae1:	89 e5                	mov    %esp,%ebp
  800ae3:	53                   	push   %ebx
  800ae4:	83 ec 20             	sub    $0x20,%esp
  800ae7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aea:	53                   	push   %ebx
  800aeb:	e8 8f 0b 00 00       	call   80167f <strlen>
  800af0:	83 c4 10             	add    $0x10,%esp
  800af3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af8:	7f 67                	jg     800b61 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afa:	83 ec 0c             	sub    $0xc,%esp
  800afd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b00:	50                   	push   %eax
  800b01:	e8 97 f8 ff ff       	call   80039d <fd_alloc>
  800b06:	83 c4 10             	add    $0x10,%esp
		return r;
  800b09:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	78 57                	js     800b66 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	53                   	push   %ebx
  800b13:	68 00 50 80 00       	push   $0x805000
  800b18:	e8 9b 0b 00 00       	call   8016b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b20:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b25:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b28:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2d:	e8 f2 fd ff ff       	call   800924 <fsipc>
  800b32:	89 c3                	mov    %eax,%ebx
  800b34:	83 c4 10             	add    $0x10,%esp
  800b37:	85 c0                	test   %eax,%eax
  800b39:	79 14                	jns    800b4f <open+0x6f>
		fd_close(fd, 0);
  800b3b:	83 ec 08             	sub    $0x8,%esp
  800b3e:	6a 00                	push   $0x0
  800b40:	ff 75 f4             	pushl  -0xc(%ebp)
  800b43:	e8 4d f9 ff ff       	call   800495 <fd_close>
		return r;
  800b48:	83 c4 10             	add    $0x10,%esp
  800b4b:	89 da                	mov    %ebx,%edx
  800b4d:	eb 17                	jmp    800b66 <open+0x86>
	}

	return fd2num(fd);
  800b4f:	83 ec 0c             	sub    $0xc,%esp
  800b52:	ff 75 f4             	pushl  -0xc(%ebp)
  800b55:	e8 1c f8 ff ff       	call   800376 <fd2num>
  800b5a:	89 c2                	mov    %eax,%edx
  800b5c:	83 c4 10             	add    $0x10,%esp
  800b5f:	eb 05                	jmp    800b66 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b61:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b66:	89 d0                	mov    %edx,%eax
  800b68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6b:	c9                   	leave  
  800b6c:	c3                   	ret    

00800b6d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b6d:	55                   	push   %ebp
  800b6e:	89 e5                	mov    %esp,%ebp
  800b70:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b73:	ba 00 00 00 00       	mov    $0x0,%edx
  800b78:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7d:	e8 a2 fd ff ff       	call   800924 <fsipc>
}
  800b82:	c9                   	leave  
  800b83:	c3                   	ret    

00800b84 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	56                   	push   %esi
  800b88:	53                   	push   %ebx
  800b89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b8c:	83 ec 0c             	sub    $0xc,%esp
  800b8f:	ff 75 08             	pushl  0x8(%ebp)
  800b92:	e8 ef f7 ff ff       	call   800386 <fd2data>
  800b97:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b99:	83 c4 08             	add    $0x8,%esp
  800b9c:	68 f7 1e 80 00       	push   $0x801ef7
  800ba1:	53                   	push   %ebx
  800ba2:	e8 11 0b 00 00       	call   8016b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba7:	8b 56 04             	mov    0x4(%esi),%edx
  800baa:	89 d0                	mov    %edx,%eax
  800bac:	2b 06                	sub    (%esi),%eax
  800bae:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bbb:	00 00 00 
	stat->st_dev = &devpipe;
  800bbe:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc5:	30 80 00 
	return 0;
}
  800bc8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd0:	5b                   	pop    %ebx
  800bd1:	5e                   	pop    %esi
  800bd2:	5d                   	pop    %ebp
  800bd3:	c3                   	ret    

00800bd4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd4:	55                   	push   %ebp
  800bd5:	89 e5                	mov    %esp,%ebp
  800bd7:	53                   	push   %ebx
  800bd8:	83 ec 0c             	sub    $0xc,%esp
  800bdb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bde:	53                   	push   %ebx
  800bdf:	6a 00                	push   $0x0
  800be1:	e8 05 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be6:	89 1c 24             	mov    %ebx,(%esp)
  800be9:	e8 98 f7 ff ff       	call   800386 <fd2data>
  800bee:	83 c4 08             	add    $0x8,%esp
  800bf1:	50                   	push   %eax
  800bf2:	6a 00                	push   $0x0
  800bf4:	e8 f2 f5 ff ff       	call   8001eb <sys_page_unmap>
}
  800bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfc:	c9                   	leave  
  800bfd:	c3                   	ret    

00800bfe <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 1c             	sub    $0x1c,%esp
  800c07:	89 c7                	mov    %eax,%edi
  800c09:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c0b:	a1 04 40 80 00       	mov    0x804004,%eax
  800c10:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c13:	83 ec 0c             	sub    $0xc,%esp
  800c16:	57                   	push   %edi
  800c17:	e8 d9 0e 00 00       	call   801af5 <pageref>
  800c1c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c1f:	89 34 24             	mov    %esi,(%esp)
  800c22:	e8 ce 0e 00 00       	call   801af5 <pageref>
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c2d:	0f 94 c0             	sete   %al
  800c30:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c33:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c39:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c3c:	39 cb                	cmp    %ecx,%ebx
  800c3e:	74 15                	je     800c55 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c40:	8b 52 58             	mov    0x58(%edx),%edx
  800c43:	50                   	push   %eax
  800c44:	52                   	push   %edx
  800c45:	53                   	push   %ebx
  800c46:	68 04 1f 80 00       	push   $0x801f04
  800c4b:	e8 e4 04 00 00       	call   801134 <cprintf>
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	eb b6                	jmp    800c0b <_pipeisclosed+0xd>
	}
}
  800c55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 28             	sub    $0x28,%esp
  800c66:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c69:	56                   	push   %esi
  800c6a:	e8 17 f7 ff ff       	call   800386 <fd2data>
  800c6f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c71:	83 c4 10             	add    $0x10,%esp
  800c74:	bf 00 00 00 00       	mov    $0x0,%edi
  800c79:	eb 4b                	jmp    800cc6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7b:	89 da                	mov    %ebx,%edx
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	e8 7a ff ff ff       	call   800bfe <_pipeisclosed>
  800c84:	85 c0                	test   %eax,%eax
  800c86:	75 48                	jne    800cd0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c88:	e8 ba f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c90:	8b 0b                	mov    (%ebx),%ecx
  800c92:	8d 51 20             	lea    0x20(%ecx),%edx
  800c95:	39 d0                	cmp    %edx,%eax
  800c97:	73 e2                	jae    800c7b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca3:	89 c2                	mov    %eax,%edx
  800ca5:	c1 fa 1f             	sar    $0x1f,%edx
  800ca8:	89 d1                	mov    %edx,%ecx
  800caa:	c1 e9 1b             	shr    $0x1b,%ecx
  800cad:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb0:	83 e2 1f             	and    $0x1f,%edx
  800cb3:	29 ca                	sub    %ecx,%edx
  800cb5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cbd:	83 c0 01             	add    $0x1,%eax
  800cc0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc3:	83 c7 01             	add    $0x1,%edi
  800cc6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc9:	75 c2                	jne    800c8d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ccb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cce:	eb 05                	jmp    800cd5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd8:	5b                   	pop    %ebx
  800cd9:	5e                   	pop    %esi
  800cda:	5f                   	pop    %edi
  800cdb:	5d                   	pop    %ebp
  800cdc:	c3                   	ret    

00800cdd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cdd:	55                   	push   %ebp
  800cde:	89 e5                	mov    %esp,%ebp
  800ce0:	57                   	push   %edi
  800ce1:	56                   	push   %esi
  800ce2:	53                   	push   %ebx
  800ce3:	83 ec 18             	sub    $0x18,%esp
  800ce6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce9:	57                   	push   %edi
  800cea:	e8 97 f6 ff ff       	call   800386 <fd2data>
  800cef:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf1:	83 c4 10             	add    $0x10,%esp
  800cf4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf9:	eb 3d                	jmp    800d38 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cfb:	85 db                	test   %ebx,%ebx
  800cfd:	74 04                	je     800d03 <devpipe_read+0x26>
				return i;
  800cff:	89 d8                	mov    %ebx,%eax
  800d01:	eb 44                	jmp    800d47 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d03:	89 f2                	mov    %esi,%edx
  800d05:	89 f8                	mov    %edi,%eax
  800d07:	e8 f2 fe ff ff       	call   800bfe <_pipeisclosed>
  800d0c:	85 c0                	test   %eax,%eax
  800d0e:	75 32                	jne    800d42 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d10:	e8 32 f4 ff ff       	call   800147 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d15:	8b 06                	mov    (%esi),%eax
  800d17:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1a:	74 df                	je     800cfb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d1c:	99                   	cltd   
  800d1d:	c1 ea 1b             	shr    $0x1b,%edx
  800d20:	01 d0                	add    %edx,%eax
  800d22:	83 e0 1f             	and    $0x1f,%eax
  800d25:	29 d0                	sub    %edx,%eax
  800d27:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d32:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d35:	83 c3 01             	add    $0x1,%ebx
  800d38:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3b:	75 d8                	jne    800d15 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d3d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d40:	eb 05                	jmp    800d47 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d42:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4a:	5b                   	pop    %ebx
  800d4b:	5e                   	pop    %esi
  800d4c:	5f                   	pop    %edi
  800d4d:	5d                   	pop    %ebp
  800d4e:	c3                   	ret    

00800d4f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d4f:	55                   	push   %ebp
  800d50:	89 e5                	mov    %esp,%ebp
  800d52:	56                   	push   %esi
  800d53:	53                   	push   %ebx
  800d54:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5a:	50                   	push   %eax
  800d5b:	e8 3d f6 ff ff       	call   80039d <fd_alloc>
  800d60:	83 c4 10             	add    $0x10,%esp
  800d63:	89 c2                	mov    %eax,%edx
  800d65:	85 c0                	test   %eax,%eax
  800d67:	0f 88 2c 01 00 00    	js     800e99 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	68 07 04 00 00       	push   $0x407
  800d75:	ff 75 f4             	pushl  -0xc(%ebp)
  800d78:	6a 00                	push   $0x0
  800d7a:	e8 e7 f3 ff ff       	call   800166 <sys_page_alloc>
  800d7f:	83 c4 10             	add    $0x10,%esp
  800d82:	89 c2                	mov    %eax,%edx
  800d84:	85 c0                	test   %eax,%eax
  800d86:	0f 88 0d 01 00 00    	js     800e99 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d92:	50                   	push   %eax
  800d93:	e8 05 f6 ff ff       	call   80039d <fd_alloc>
  800d98:	89 c3                	mov    %eax,%ebx
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	85 c0                	test   %eax,%eax
  800d9f:	0f 88 e2 00 00 00    	js     800e87 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da5:	83 ec 04             	sub    $0x4,%esp
  800da8:	68 07 04 00 00       	push   $0x407
  800dad:	ff 75 f0             	pushl  -0x10(%ebp)
  800db0:	6a 00                	push   $0x0
  800db2:	e8 af f3 ff ff       	call   800166 <sys_page_alloc>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	0f 88 c3 00 00 00    	js     800e87 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dca:	e8 b7 f5 ff ff       	call   800386 <fd2data>
  800dcf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd1:	83 c4 0c             	add    $0xc,%esp
  800dd4:	68 07 04 00 00       	push   $0x407
  800dd9:	50                   	push   %eax
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 85 f3 ff ff       	call   800166 <sys_page_alloc>
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	0f 88 89 00 00 00    	js     800e77 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dee:	83 ec 0c             	sub    $0xc,%esp
  800df1:	ff 75 f0             	pushl  -0x10(%ebp)
  800df4:	e8 8d f5 ff ff       	call   800386 <fd2data>
  800df9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e00:	50                   	push   %eax
  800e01:	6a 00                	push   $0x0
  800e03:	56                   	push   %esi
  800e04:	6a 00                	push   $0x0
  800e06:	e8 9e f3 ff ff       	call   8001a9 <sys_page_map>
  800e0b:	89 c3                	mov    %eax,%ebx
  800e0d:	83 c4 20             	add    $0x20,%esp
  800e10:	85 c0                	test   %eax,%eax
  800e12:	78 55                	js     800e69 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e14:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e22:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e29:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e32:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e37:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e3e:	83 ec 0c             	sub    $0xc,%esp
  800e41:	ff 75 f4             	pushl  -0xc(%ebp)
  800e44:	e8 2d f5 ff ff       	call   800376 <fd2num>
  800e49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4e:	83 c4 04             	add    $0x4,%esp
  800e51:	ff 75 f0             	pushl  -0x10(%ebp)
  800e54:	e8 1d f5 ff ff       	call   800376 <fd2num>
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	ba 00 00 00 00       	mov    $0x0,%edx
  800e67:	eb 30                	jmp    800e99 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e69:	83 ec 08             	sub    $0x8,%esp
  800e6c:	56                   	push   %esi
  800e6d:	6a 00                	push   $0x0
  800e6f:	e8 77 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e74:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e77:	83 ec 08             	sub    $0x8,%esp
  800e7a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7d:	6a 00                	push   $0x0
  800e7f:	e8 67 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e84:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e87:	83 ec 08             	sub    $0x8,%esp
  800e8a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8d:	6a 00                	push   $0x0
  800e8f:	e8 57 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e99:	89 d0                	mov    %edx,%eax
  800e9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eab:	50                   	push   %eax
  800eac:	ff 75 08             	pushl  0x8(%ebp)
  800eaf:	e8 38 f5 ff ff       	call   8003ec <fd_lookup>
  800eb4:	89 c2                	mov    %eax,%edx
  800eb6:	83 c4 10             	add    $0x10,%esp
  800eb9:	85 d2                	test   %edx,%edx
  800ebb:	78 18                	js     800ed5 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ebd:	83 ec 0c             	sub    $0xc,%esp
  800ec0:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec3:	e8 be f4 ff ff       	call   800386 <fd2data>
	return _pipeisclosed(fd, p);
  800ec8:	89 c2                	mov    %eax,%edx
  800eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ecd:	e8 2c fd ff ff       	call   800bfe <_pipeisclosed>
  800ed2:	83 c4 10             	add    $0x10,%esp
}
  800ed5:	c9                   	leave  
  800ed6:	c3                   	ret    

00800ed7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
  800edf:	5d                   	pop    %ebp
  800ee0:	c3                   	ret    

00800ee1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee7:	68 35 1f 80 00       	push   $0x801f35
  800eec:	ff 75 0c             	pushl  0xc(%ebp)
  800eef:	e8 c4 07 00 00       	call   8016b8 <strcpy>
	return 0;
}
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef9:	c9                   	leave  
  800efa:	c3                   	ret    

00800efb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f07:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f0c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f12:	eb 2e                	jmp    800f42 <devcons_write+0x47>
		m = n - tot;
  800f14:	8b 55 10             	mov    0x10(%ebp),%edx
  800f17:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f19:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f1e:	83 fa 7f             	cmp    $0x7f,%edx
  800f21:	77 02                	ja     800f25 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f23:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	56                   	push   %esi
  800f29:	03 45 0c             	add    0xc(%ebp),%eax
  800f2c:	50                   	push   %eax
  800f2d:	57                   	push   %edi
  800f2e:	e8 17 09 00 00       	call   80184a <memmove>
		sys_cputs(buf, m);
  800f33:	83 c4 08             	add    $0x8,%esp
  800f36:	56                   	push   %esi
  800f37:	57                   	push   %edi
  800f38:	e8 6d f1 ff ff       	call   8000aa <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3d:	01 f3                	add    %esi,%ebx
  800f3f:	83 c4 10             	add    $0x10,%esp
  800f42:	89 d8                	mov    %ebx,%eax
  800f44:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f47:	72 cb                	jb     800f14 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f57:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f5c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f60:	75 07                	jne    800f69 <devcons_read+0x18>
  800f62:	eb 28                	jmp    800f8c <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f64:	e8 de f1 ff ff       	call   800147 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f69:	e8 5a f1 ff ff       	call   8000c8 <sys_cgetc>
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	74 f2                	je     800f64 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f72:	85 c0                	test   %eax,%eax
  800f74:	78 16                	js     800f8c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f76:	83 f8 04             	cmp    $0x4,%eax
  800f79:	74 0c                	je     800f87 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7e:	88 02                	mov    %al,(%edx)
	return 1;
  800f80:	b8 01 00 00 00       	mov    $0x1,%eax
  800f85:	eb 05                	jmp    800f8c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f87:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    

00800f8e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f94:	8b 45 08             	mov    0x8(%ebp),%eax
  800f97:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f9a:	6a 01                	push   $0x1
  800f9c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9f:	50                   	push   %eax
  800fa0:	e8 05 f1 ff ff       	call   8000aa <sys_cputs>
  800fa5:	83 c4 10             	add    $0x10,%esp
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <getchar>:

int
getchar(void)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb0:	6a 01                	push   $0x1
  800fb2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb5:	50                   	push   %eax
  800fb6:	6a 00                	push   $0x0
  800fb8:	e8 98 f6 ff ff       	call   800655 <read>
	if (r < 0)
  800fbd:	83 c4 10             	add    $0x10,%esp
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	78 0f                	js     800fd3 <getchar+0x29>
		return r;
	if (r < 1)
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	7e 06                	jle    800fce <getchar+0x24>
		return -E_EOF;
	return c;
  800fc8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fcc:	eb 05                	jmp    800fd3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fce:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd3:	c9                   	leave  
  800fd4:	c3                   	ret    

00800fd5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd5:	55                   	push   %ebp
  800fd6:	89 e5                	mov    %esp,%ebp
  800fd8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fde:	50                   	push   %eax
  800fdf:	ff 75 08             	pushl  0x8(%ebp)
  800fe2:	e8 05 f4 ff ff       	call   8003ec <fd_lookup>
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	78 11                	js     800fff <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff7:	39 10                	cmp    %edx,(%eax)
  800ff9:	0f 94 c0             	sete   %al
  800ffc:	0f b6 c0             	movzbl %al,%eax
}
  800fff:	c9                   	leave  
  801000:	c3                   	ret    

00801001 <opencons>:

int
opencons(void)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801007:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100a:	50                   	push   %eax
  80100b:	e8 8d f3 ff ff       	call   80039d <fd_alloc>
  801010:	83 c4 10             	add    $0x10,%esp
		return r;
  801013:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801015:	85 c0                	test   %eax,%eax
  801017:	78 3e                	js     801057 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801019:	83 ec 04             	sub    $0x4,%esp
  80101c:	68 07 04 00 00       	push   $0x407
  801021:	ff 75 f4             	pushl  -0xc(%ebp)
  801024:	6a 00                	push   $0x0
  801026:	e8 3b f1 ff ff       	call   800166 <sys_page_alloc>
  80102b:	83 c4 10             	add    $0x10,%esp
		return r;
  80102e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801030:	85 c0                	test   %eax,%eax
  801032:	78 23                	js     801057 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801034:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80103a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80103f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801042:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	50                   	push   %eax
  80104d:	e8 24 f3 ff ff       	call   800376 <fd2num>
  801052:	89 c2                	mov    %eax,%edx
  801054:	83 c4 10             	add    $0x10,%esp
}
  801057:	89 d0                	mov    %edx,%eax
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	56                   	push   %esi
  80105f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801060:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801063:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801069:	e8 ba f0 ff ff       	call   800128 <sys_getenvid>
  80106e:	83 ec 0c             	sub    $0xc,%esp
  801071:	ff 75 0c             	pushl  0xc(%ebp)
  801074:	ff 75 08             	pushl  0x8(%ebp)
  801077:	56                   	push   %esi
  801078:	50                   	push   %eax
  801079:	68 44 1f 80 00       	push   $0x801f44
  80107e:	e8 b1 00 00 00       	call   801134 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801083:	83 c4 18             	add    $0x18,%esp
  801086:	53                   	push   %ebx
  801087:	ff 75 10             	pushl  0x10(%ebp)
  80108a:	e8 54 00 00 00       	call   8010e3 <vcprintf>
	cprintf("\n");
  80108f:	c7 04 24 93 1e 80 00 	movl   $0x801e93,(%esp)
  801096:	e8 99 00 00 00       	call   801134 <cprintf>
  80109b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109e:	cc                   	int3   
  80109f:	eb fd                	jmp    80109e <_panic+0x43>

008010a1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a1:	55                   	push   %ebp
  8010a2:	89 e5                	mov    %esp,%ebp
  8010a4:	53                   	push   %ebx
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010ab:	8b 13                	mov    (%ebx),%edx
  8010ad:	8d 42 01             	lea    0x1(%edx),%eax
  8010b0:	89 03                	mov    %eax,(%ebx)
  8010b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010be:	75 1a                	jne    8010da <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c0:	83 ec 08             	sub    $0x8,%esp
  8010c3:	68 ff 00 00 00       	push   $0xff
  8010c8:	8d 43 08             	lea    0x8(%ebx),%eax
  8010cb:	50                   	push   %eax
  8010cc:	e8 d9 ef ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  8010d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010da:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e1:	c9                   	leave  
  8010e2:	c3                   	ret    

008010e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010ec:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f3:	00 00 00 
	b.cnt = 0;
  8010f6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010fd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801100:	ff 75 0c             	pushl  0xc(%ebp)
  801103:	ff 75 08             	pushl  0x8(%ebp)
  801106:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80110c:	50                   	push   %eax
  80110d:	68 a1 10 80 00       	push   $0x8010a1
  801112:	e8 4f 01 00 00       	call   801266 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801117:	83 c4 08             	add    $0x8,%esp
  80111a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801120:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801126:	50                   	push   %eax
  801127:	e8 7e ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  80112c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801132:	c9                   	leave  
  801133:	c3                   	ret    

00801134 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801134:	55                   	push   %ebp
  801135:	89 e5                	mov    %esp,%ebp
  801137:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80113a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113d:	50                   	push   %eax
  80113e:	ff 75 08             	pushl  0x8(%ebp)
  801141:	e8 9d ff ff ff       	call   8010e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801146:	c9                   	leave  
  801147:	c3                   	ret    

00801148 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801148:	55                   	push   %ebp
  801149:	89 e5                	mov    %esp,%ebp
  80114b:	57                   	push   %edi
  80114c:	56                   	push   %esi
  80114d:	53                   	push   %ebx
  80114e:	83 ec 1c             	sub    $0x1c,%esp
  801151:	89 c7                	mov    %eax,%edi
  801153:	89 d6                	mov    %edx,%esi
  801155:	8b 45 08             	mov    0x8(%ebp),%eax
  801158:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115b:	89 d1                	mov    %edx,%ecx
  80115d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801160:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801163:	8b 45 10             	mov    0x10(%ebp),%eax
  801166:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801169:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80116c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801173:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801176:	72 05                	jb     80117d <printnum+0x35>
  801178:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80117b:	77 3e                	ja     8011bb <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117d:	83 ec 0c             	sub    $0xc,%esp
  801180:	ff 75 18             	pushl  0x18(%ebp)
  801183:	83 eb 01             	sub    $0x1,%ebx
  801186:	53                   	push   %ebx
  801187:	50                   	push   %eax
  801188:	83 ec 08             	sub    $0x8,%esp
  80118b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118e:	ff 75 e0             	pushl  -0x20(%ebp)
  801191:	ff 75 dc             	pushl  -0x24(%ebp)
  801194:	ff 75 d8             	pushl  -0x28(%ebp)
  801197:	e8 94 09 00 00       	call   801b30 <__udivdi3>
  80119c:	83 c4 18             	add    $0x18,%esp
  80119f:	52                   	push   %edx
  8011a0:	50                   	push   %eax
  8011a1:	89 f2                	mov    %esi,%edx
  8011a3:	89 f8                	mov    %edi,%eax
  8011a5:	e8 9e ff ff ff       	call   801148 <printnum>
  8011aa:	83 c4 20             	add    $0x20,%esp
  8011ad:	eb 13                	jmp    8011c2 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011af:	83 ec 08             	sub    $0x8,%esp
  8011b2:	56                   	push   %esi
  8011b3:	ff 75 18             	pushl  0x18(%ebp)
  8011b6:	ff d7                	call   *%edi
  8011b8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011bb:	83 eb 01             	sub    $0x1,%ebx
  8011be:	85 db                	test   %ebx,%ebx
  8011c0:	7f ed                	jg     8011af <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c2:	83 ec 08             	sub    $0x8,%esp
  8011c5:	56                   	push   %esi
  8011c6:	83 ec 04             	sub    $0x4,%esp
  8011c9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011cf:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d5:	e8 86 0a 00 00       	call   801c60 <__umoddi3>
  8011da:	83 c4 14             	add    $0x14,%esp
  8011dd:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011e4:	50                   	push   %eax
  8011e5:	ff d7                	call   *%edi
  8011e7:	83 c4 10             	add    $0x10,%esp
}
  8011ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ed:	5b                   	pop    %ebx
  8011ee:	5e                   	pop    %esi
  8011ef:	5f                   	pop    %edi
  8011f0:	5d                   	pop    %ebp
  8011f1:	c3                   	ret    

008011f2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f5:	83 fa 01             	cmp    $0x1,%edx
  8011f8:	7e 0e                	jle    801208 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011fa:	8b 10                	mov    (%eax),%edx
  8011fc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ff:	89 08                	mov    %ecx,(%eax)
  801201:	8b 02                	mov    (%edx),%eax
  801203:	8b 52 04             	mov    0x4(%edx),%edx
  801206:	eb 22                	jmp    80122a <getuint+0x38>
	else if (lflag)
  801208:	85 d2                	test   %edx,%edx
  80120a:	74 10                	je     80121c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80120c:	8b 10                	mov    (%eax),%edx
  80120e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801211:	89 08                	mov    %ecx,(%eax)
  801213:	8b 02                	mov    (%edx),%eax
  801215:	ba 00 00 00 00       	mov    $0x0,%edx
  80121a:	eb 0e                	jmp    80122a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80121c:	8b 10                	mov    (%eax),%edx
  80121e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801221:	89 08                	mov    %ecx,(%eax)
  801223:	8b 02                	mov    (%edx),%eax
  801225:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80122a:	5d                   	pop    %ebp
  80122b:	c3                   	ret    

0080122c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80122c:	55                   	push   %ebp
  80122d:	89 e5                	mov    %esp,%ebp
  80122f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801232:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801236:	8b 10                	mov    (%eax),%edx
  801238:	3b 50 04             	cmp    0x4(%eax),%edx
  80123b:	73 0a                	jae    801247 <sprintputch+0x1b>
		*b->buf++ = ch;
  80123d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801240:	89 08                	mov    %ecx,(%eax)
  801242:	8b 45 08             	mov    0x8(%ebp),%eax
  801245:	88 02                	mov    %al,(%edx)
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80124f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801252:	50                   	push   %eax
  801253:	ff 75 10             	pushl  0x10(%ebp)
  801256:	ff 75 0c             	pushl  0xc(%ebp)
  801259:	ff 75 08             	pushl  0x8(%ebp)
  80125c:	e8 05 00 00 00       	call   801266 <vprintfmt>
	va_end(ap);
  801261:	83 c4 10             	add    $0x10,%esp
}
  801264:	c9                   	leave  
  801265:	c3                   	ret    

00801266 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801266:	55                   	push   %ebp
  801267:	89 e5                	mov    %esp,%ebp
  801269:	57                   	push   %edi
  80126a:	56                   	push   %esi
  80126b:	53                   	push   %ebx
  80126c:	83 ec 2c             	sub    $0x2c,%esp
  80126f:	8b 75 08             	mov    0x8(%ebp),%esi
  801272:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801275:	8b 7d 10             	mov    0x10(%ebp),%edi
  801278:	eb 12                	jmp    80128c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80127a:	85 c0                	test   %eax,%eax
  80127c:	0f 84 8d 03 00 00    	je     80160f <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	53                   	push   %ebx
  801286:	50                   	push   %eax
  801287:	ff d6                	call   *%esi
  801289:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80128c:	83 c7 01             	add    $0x1,%edi
  80128f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801293:	83 f8 25             	cmp    $0x25,%eax
  801296:	75 e2                	jne    80127a <vprintfmt+0x14>
  801298:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80129c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012aa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b6:	eb 07                	jmp    8012bf <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012bb:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bf:	8d 47 01             	lea    0x1(%edi),%eax
  8012c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c5:	0f b6 07             	movzbl (%edi),%eax
  8012c8:	0f b6 c8             	movzbl %al,%ecx
  8012cb:	83 e8 23             	sub    $0x23,%eax
  8012ce:	3c 55                	cmp    $0x55,%al
  8012d0:	0f 87 1e 03 00 00    	ja     8015f4 <vprintfmt+0x38e>
  8012d6:	0f b6 c0             	movzbl %al,%eax
  8012d9:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012e7:	eb d6                	jmp    8012bf <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012f4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012f7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012fb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012fe:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801301:	83 fa 09             	cmp    $0x9,%edx
  801304:	77 38                	ja     80133e <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801306:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801309:	eb e9                	jmp    8012f4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80130b:	8b 45 14             	mov    0x14(%ebp),%eax
  80130e:	8d 48 04             	lea    0x4(%eax),%ecx
  801311:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801314:	8b 00                	mov    (%eax),%eax
  801316:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80131c:	eb 26                	jmp    801344 <vprintfmt+0xde>
  80131e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801321:	89 c8                	mov    %ecx,%eax
  801323:	c1 f8 1f             	sar    $0x1f,%eax
  801326:	f7 d0                	not    %eax
  801328:	21 c1                	and    %eax,%ecx
  80132a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801330:	eb 8d                	jmp    8012bf <vprintfmt+0x59>
  801332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801335:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80133c:	eb 81                	jmp    8012bf <vprintfmt+0x59>
  80133e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801341:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801344:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801348:	0f 89 71 ff ff ff    	jns    8012bf <vprintfmt+0x59>
				width = precision, precision = -1;
  80134e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801351:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801354:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80135b:	e9 5f ff ff ff       	jmp    8012bf <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801360:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801366:	e9 54 ff ff ff       	jmp    8012bf <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80136b:	8b 45 14             	mov    0x14(%ebp),%eax
  80136e:	8d 50 04             	lea    0x4(%eax),%edx
  801371:	89 55 14             	mov    %edx,0x14(%ebp)
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	53                   	push   %ebx
  801378:	ff 30                	pushl  (%eax)
  80137a:	ff d6                	call   *%esi
			break;
  80137c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801382:	e9 05 ff ff ff       	jmp    80128c <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  801387:	8b 45 14             	mov    0x14(%ebp),%eax
  80138a:	8d 50 04             	lea    0x4(%eax),%edx
  80138d:	89 55 14             	mov    %edx,0x14(%ebp)
  801390:	8b 00                	mov    (%eax),%eax
  801392:	99                   	cltd   
  801393:	31 d0                	xor    %edx,%eax
  801395:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801397:	83 f8 0f             	cmp    $0xf,%eax
  80139a:	7f 0b                	jg     8013a7 <vprintfmt+0x141>
  80139c:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013a3:	85 d2                	test   %edx,%edx
  8013a5:	75 18                	jne    8013bf <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8013a7:	50                   	push   %eax
  8013a8:	68 7f 1f 80 00       	push   $0x801f7f
  8013ad:	53                   	push   %ebx
  8013ae:	56                   	push   %esi
  8013af:	e8 95 fe ff ff       	call   801249 <printfmt>
  8013b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ba:	e9 cd fe ff ff       	jmp    80128c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013bf:	52                   	push   %edx
  8013c0:	68 dd 1e 80 00       	push   $0x801edd
  8013c5:	53                   	push   %ebx
  8013c6:	56                   	push   %esi
  8013c7:	e8 7d fe ff ff       	call   801249 <printfmt>
  8013cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d2:	e9 b5 fe ff ff       	jmp    80128c <vprintfmt+0x26>
  8013d7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013dd:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e3:	8d 50 04             	lea    0x4(%eax),%edx
  8013e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e9:	8b 38                	mov    (%eax),%edi
  8013eb:	85 ff                	test   %edi,%edi
  8013ed:	75 05                	jne    8013f4 <vprintfmt+0x18e>
				p = "(null)";
  8013ef:	bf 78 1f 80 00       	mov    $0x801f78,%edi
			if (width > 0 && padc != '-')
  8013f4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013f8:	0f 84 91 00 00 00    	je     80148f <vprintfmt+0x229>
  8013fe:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801402:	0f 8e 95 00 00 00    	jle    80149d <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	51                   	push   %ecx
  80140c:	57                   	push   %edi
  80140d:	e8 85 02 00 00       	call   801697 <strnlen>
  801412:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801415:	29 c1                	sub    %eax,%ecx
  801417:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80141a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80141d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801421:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801424:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801427:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801429:	eb 0f                	jmp    80143a <vprintfmt+0x1d4>
					putch(padc, putdat);
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	53                   	push   %ebx
  80142f:	ff 75 e0             	pushl  -0x20(%ebp)
  801432:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801434:	83 ef 01             	sub    $0x1,%edi
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	85 ff                	test   %edi,%edi
  80143c:	7f ed                	jg     80142b <vprintfmt+0x1c5>
  80143e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801441:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801444:	89 c8                	mov    %ecx,%eax
  801446:	c1 f8 1f             	sar    $0x1f,%eax
  801449:	f7 d0                	not    %eax
  80144b:	21 c8                	and    %ecx,%eax
  80144d:	29 c1                	sub    %eax,%ecx
  80144f:	89 75 08             	mov    %esi,0x8(%ebp)
  801452:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801455:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801458:	89 cb                	mov    %ecx,%ebx
  80145a:	eb 4d                	jmp    8014a9 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80145c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801460:	74 1b                	je     80147d <vprintfmt+0x217>
  801462:	0f be c0             	movsbl %al,%eax
  801465:	83 e8 20             	sub    $0x20,%eax
  801468:	83 f8 5e             	cmp    $0x5e,%eax
  80146b:	76 10                	jbe    80147d <vprintfmt+0x217>
					putch('?', putdat);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	ff 75 0c             	pushl  0xc(%ebp)
  801473:	6a 3f                	push   $0x3f
  801475:	ff 55 08             	call   *0x8(%ebp)
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	eb 0d                	jmp    80148a <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80147d:	83 ec 08             	sub    $0x8,%esp
  801480:	ff 75 0c             	pushl  0xc(%ebp)
  801483:	52                   	push   %edx
  801484:	ff 55 08             	call   *0x8(%ebp)
  801487:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148a:	83 eb 01             	sub    $0x1,%ebx
  80148d:	eb 1a                	jmp    8014a9 <vprintfmt+0x243>
  80148f:	89 75 08             	mov    %esi,0x8(%ebp)
  801492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801498:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149b:	eb 0c                	jmp    8014a9 <vprintfmt+0x243>
  80149d:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a9:	83 c7 01             	add    $0x1,%edi
  8014ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b0:	0f be d0             	movsbl %al,%edx
  8014b3:	85 d2                	test   %edx,%edx
  8014b5:	74 23                	je     8014da <vprintfmt+0x274>
  8014b7:	85 f6                	test   %esi,%esi
  8014b9:	78 a1                	js     80145c <vprintfmt+0x1f6>
  8014bb:	83 ee 01             	sub    $0x1,%esi
  8014be:	79 9c                	jns    80145c <vprintfmt+0x1f6>
  8014c0:	89 df                	mov    %ebx,%edi
  8014c2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c8:	eb 18                	jmp    8014e2 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ca:	83 ec 08             	sub    $0x8,%esp
  8014cd:	53                   	push   %ebx
  8014ce:	6a 20                	push   $0x20
  8014d0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014d2:	83 ef 01             	sub    $0x1,%edi
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 08                	jmp    8014e2 <vprintfmt+0x27c>
  8014da:	89 df                	mov    %ebx,%edi
  8014dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e2:	85 ff                	test   %edi,%edi
  8014e4:	7f e4                	jg     8014ca <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e9:	e9 9e fd ff ff       	jmp    80128c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014ee:	83 fa 01             	cmp    $0x1,%edx
  8014f1:	7e 16                	jle    801509 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f6:	8d 50 08             	lea    0x8(%eax),%edx
  8014f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fc:	8b 50 04             	mov    0x4(%eax),%edx
  8014ff:	8b 00                	mov    (%eax),%eax
  801501:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801504:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801507:	eb 32                	jmp    80153b <vprintfmt+0x2d5>
	else if (lflag)
  801509:	85 d2                	test   %edx,%edx
  80150b:	74 18                	je     801525 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80150d:	8b 45 14             	mov    0x14(%ebp),%eax
  801510:	8d 50 04             	lea    0x4(%eax),%edx
  801513:	89 55 14             	mov    %edx,0x14(%ebp)
  801516:	8b 00                	mov    (%eax),%eax
  801518:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151b:	89 c1                	mov    %eax,%ecx
  80151d:	c1 f9 1f             	sar    $0x1f,%ecx
  801520:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801523:	eb 16                	jmp    80153b <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801525:	8b 45 14             	mov    0x14(%ebp),%eax
  801528:	8d 50 04             	lea    0x4(%eax),%edx
  80152b:	89 55 14             	mov    %edx,0x14(%ebp)
  80152e:	8b 00                	mov    (%eax),%eax
  801530:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801533:	89 c1                	mov    %eax,%ecx
  801535:	c1 f9 1f             	sar    $0x1f,%ecx
  801538:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80153b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80153e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801541:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801546:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80154a:	79 74                	jns    8015c0 <vprintfmt+0x35a>
				putch('-', putdat);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	53                   	push   %ebx
  801550:	6a 2d                	push   $0x2d
  801552:	ff d6                	call   *%esi
				num = -(long long) num;
  801554:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801557:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80155a:	f7 d8                	neg    %eax
  80155c:	83 d2 00             	adc    $0x0,%edx
  80155f:	f7 da                	neg    %edx
  801561:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801564:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801569:	eb 55                	jmp    8015c0 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80156b:	8d 45 14             	lea    0x14(%ebp),%eax
  80156e:	e8 7f fc ff ff       	call   8011f2 <getuint>
			base = 10;
  801573:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801578:	eb 46                	jmp    8015c0 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80157a:	8d 45 14             	lea    0x14(%ebp),%eax
  80157d:	e8 70 fc ff ff       	call   8011f2 <getuint>
			base = 8;
  801582:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801587:	eb 37                	jmp    8015c0 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  801589:	83 ec 08             	sub    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 30                	push   $0x30
  80158f:	ff d6                	call   *%esi
			putch('x', putdat);
  801591:	83 c4 08             	add    $0x8,%esp
  801594:	53                   	push   %ebx
  801595:	6a 78                	push   $0x78
  801597:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801599:	8b 45 14             	mov    0x14(%ebp),%eax
  80159c:	8d 50 04             	lea    0x4(%eax),%edx
  80159f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a2:	8b 00                	mov    (%eax),%eax
  8015a4:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a9:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015ac:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b1:	eb 0d                	jmp    8015c0 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b6:	e8 37 fc ff ff       	call   8011f2 <getuint>
			base = 16;
  8015bb:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c0:	83 ec 0c             	sub    $0xc,%esp
  8015c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c7:	57                   	push   %edi
  8015c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cb:	51                   	push   %ecx
  8015cc:	52                   	push   %edx
  8015cd:	50                   	push   %eax
  8015ce:	89 da                	mov    %ebx,%edx
  8015d0:	89 f0                	mov    %esi,%eax
  8015d2:	e8 71 fb ff ff       	call   801148 <printnum>
			break;
  8015d7:	83 c4 20             	add    $0x20,%esp
  8015da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015dd:	e9 aa fc ff ff       	jmp    80128c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	53                   	push   %ebx
  8015e6:	51                   	push   %ecx
  8015e7:	ff d6                	call   *%esi
			break;
  8015e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ef:	e9 98 fc ff ff       	jmp    80128c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	53                   	push   %ebx
  8015f8:	6a 25                	push   $0x25
  8015fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	eb 03                	jmp    801604 <vprintfmt+0x39e>
  801601:	83 ef 01             	sub    $0x1,%edi
  801604:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801608:	75 f7                	jne    801601 <vprintfmt+0x39b>
  80160a:	e9 7d fc ff ff       	jmp    80128c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80160f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801612:	5b                   	pop    %ebx
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    

00801617 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 18             	sub    $0x18,%esp
  80161d:	8b 45 08             	mov    0x8(%ebp),%eax
  801620:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801623:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801626:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801634:	85 c0                	test   %eax,%eax
  801636:	74 26                	je     80165e <vsnprintf+0x47>
  801638:	85 d2                	test   %edx,%edx
  80163a:	7e 22                	jle    80165e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80163c:	ff 75 14             	pushl  0x14(%ebp)
  80163f:	ff 75 10             	pushl  0x10(%ebp)
  801642:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	68 2c 12 80 00       	push   $0x80122c
  80164b:	e8 16 fc ff ff       	call   801266 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801650:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801653:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801656:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	eb 05                	jmp    801663 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80165e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80166b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166e:	50                   	push   %eax
  80166f:	ff 75 10             	pushl  0x10(%ebp)
  801672:	ff 75 0c             	pushl  0xc(%ebp)
  801675:	ff 75 08             	pushl  0x8(%ebp)
  801678:	e8 9a ff ff ff       	call   801617 <vsnprintf>
	va_end(ap);

	return rc;
}
  80167d:	c9                   	leave  
  80167e:	c3                   	ret    

0080167f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801685:	b8 00 00 00 00       	mov    $0x0,%eax
  80168a:	eb 03                	jmp    80168f <strlen+0x10>
		n++;
  80168c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801693:	75 f7                	jne    80168c <strlen+0xd>
		n++;
	return n;
}
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    

00801697 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801697:	55                   	push   %ebp
  801698:	89 e5                	mov    %esp,%ebp
  80169a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a5:	eb 03                	jmp    8016aa <strnlen+0x13>
		n++;
  8016a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016aa:	39 c2                	cmp    %eax,%edx
  8016ac:	74 08                	je     8016b6 <strnlen+0x1f>
  8016ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b2:	75 f3                	jne    8016a7 <strnlen+0x10>
  8016b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	53                   	push   %ebx
  8016bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c2:	89 c2                	mov    %eax,%edx
  8016c4:	83 c2 01             	add    $0x1,%edx
  8016c7:	83 c1 01             	add    $0x1,%ecx
  8016ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d1:	84 db                	test   %bl,%bl
  8016d3:	75 ef                	jne    8016c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d5:	5b                   	pop    %ebx
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    

008016d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016df:	53                   	push   %ebx
  8016e0:	e8 9a ff ff ff       	call   80167f <strlen>
  8016e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e8:	ff 75 0c             	pushl  0xc(%ebp)
  8016eb:	01 d8                	add    %ebx,%eax
  8016ed:	50                   	push   %eax
  8016ee:	e8 c5 ff ff ff       	call   8016b8 <strcpy>
	return dst;
}
  8016f3:	89 d8                	mov    %ebx,%eax
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
  8016ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801702:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801705:	89 f3                	mov    %esi,%ebx
  801707:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170a:	89 f2                	mov    %esi,%edx
  80170c:	eb 0f                	jmp    80171d <strncpy+0x23>
		*dst++ = *src;
  80170e:	83 c2 01             	add    $0x1,%edx
  801711:	0f b6 01             	movzbl (%ecx),%eax
  801714:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801717:	80 39 01             	cmpb   $0x1,(%ecx)
  80171a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171d:	39 da                	cmp    %ebx,%edx
  80171f:	75 ed                	jne    80170e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801721:	89 f0                	mov    %esi,%eax
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	8b 75 08             	mov    0x8(%ebp),%esi
  80172f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801732:	8b 55 10             	mov    0x10(%ebp),%edx
  801735:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801737:	85 d2                	test   %edx,%edx
  801739:	74 21                	je     80175c <strlcpy+0x35>
  80173b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173f:	89 f2                	mov    %esi,%edx
  801741:	eb 09                	jmp    80174c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801743:	83 c2 01             	add    $0x1,%edx
  801746:	83 c1 01             	add    $0x1,%ecx
  801749:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80174c:	39 c2                	cmp    %eax,%edx
  80174e:	74 09                	je     801759 <strlcpy+0x32>
  801750:	0f b6 19             	movzbl (%ecx),%ebx
  801753:	84 db                	test   %bl,%bl
  801755:	75 ec                	jne    801743 <strlcpy+0x1c>
  801757:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801759:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80175c:	29 f0                	sub    %esi,%eax
}
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801768:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176b:	eb 06                	jmp    801773 <strcmp+0x11>
		p++, q++;
  80176d:	83 c1 01             	add    $0x1,%ecx
  801770:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801773:	0f b6 01             	movzbl (%ecx),%eax
  801776:	84 c0                	test   %al,%al
  801778:	74 04                	je     80177e <strcmp+0x1c>
  80177a:	3a 02                	cmp    (%edx),%al
  80177c:	74 ef                	je     80176d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177e:	0f b6 c0             	movzbl %al,%eax
  801781:	0f b6 12             	movzbl (%edx),%edx
  801784:	29 d0                	sub    %edx,%eax
}
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801792:	89 c3                	mov    %eax,%ebx
  801794:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801797:	eb 06                	jmp    80179f <strncmp+0x17>
		n--, p++, q++;
  801799:	83 c0 01             	add    $0x1,%eax
  80179c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179f:	39 d8                	cmp    %ebx,%eax
  8017a1:	74 15                	je     8017b8 <strncmp+0x30>
  8017a3:	0f b6 08             	movzbl (%eax),%ecx
  8017a6:	84 c9                	test   %cl,%cl
  8017a8:	74 04                	je     8017ae <strncmp+0x26>
  8017aa:	3a 0a                	cmp    (%edx),%cl
  8017ac:	74 eb                	je     801799 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ae:	0f b6 00             	movzbl (%eax),%eax
  8017b1:	0f b6 12             	movzbl (%edx),%edx
  8017b4:	29 d0                	sub    %edx,%eax
  8017b6:	eb 05                	jmp    8017bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017bd:	5b                   	pop    %ebx
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    

008017c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c0:	55                   	push   %ebp
  8017c1:	89 e5                	mov    %esp,%ebp
  8017c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ca:	eb 07                	jmp    8017d3 <strchr+0x13>
		if (*s == c)
  8017cc:	38 ca                	cmp    %cl,%dl
  8017ce:	74 0f                	je     8017df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d0:	83 c0 01             	add    $0x1,%eax
  8017d3:	0f b6 10             	movzbl (%eax),%edx
  8017d6:	84 d2                	test   %dl,%dl
  8017d8:	75 f2                	jne    8017cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017eb:	eb 03                	jmp    8017f0 <strfind+0xf>
  8017ed:	83 c0 01             	add    $0x1,%eax
  8017f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f3:	84 d2                	test   %dl,%dl
  8017f5:	74 04                	je     8017fb <strfind+0x1a>
  8017f7:	38 ca                	cmp    %cl,%dl
  8017f9:	75 f2                	jne    8017ed <strfind+0xc>
			break;
	return (char *) s;
}
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	57                   	push   %edi
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	8b 7d 08             	mov    0x8(%ebp),%edi
  801806:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  801809:	85 c9                	test   %ecx,%ecx
  80180b:	74 36                	je     801843 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801813:	75 28                	jne    80183d <memset+0x40>
  801815:	f6 c1 03             	test   $0x3,%cl
  801818:	75 23                	jne    80183d <memset+0x40>
		c &= 0xFF;
  80181a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181e:	89 d3                	mov    %edx,%ebx
  801820:	c1 e3 08             	shl    $0x8,%ebx
  801823:	89 d6                	mov    %edx,%esi
  801825:	c1 e6 18             	shl    $0x18,%esi
  801828:	89 d0                	mov    %edx,%eax
  80182a:	c1 e0 10             	shl    $0x10,%eax
  80182d:	09 f0                	or     %esi,%eax
  80182f:	09 c2                	or     %eax,%edx
  801831:	89 d0                	mov    %edx,%eax
  801833:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801835:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801838:	fc                   	cld    
  801839:	f3 ab                	rep stos %eax,%es:(%edi)
  80183b:	eb 06                	jmp    801843 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801840:	fc                   	cld    
  801841:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801843:	89 f8                	mov    %edi,%eax
  801845:	5b                   	pop    %ebx
  801846:	5e                   	pop    %esi
  801847:	5f                   	pop    %edi
  801848:	5d                   	pop    %ebp
  801849:	c3                   	ret    

0080184a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	57                   	push   %edi
  80184e:	56                   	push   %esi
  80184f:	8b 45 08             	mov    0x8(%ebp),%eax
  801852:	8b 75 0c             	mov    0xc(%ebp),%esi
  801855:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801858:	39 c6                	cmp    %eax,%esi
  80185a:	73 35                	jae    801891 <memmove+0x47>
  80185c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185f:	39 d0                	cmp    %edx,%eax
  801861:	73 2e                	jae    801891 <memmove+0x47>
		s += n;
		d += n;
  801863:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801866:	89 d6                	mov    %edx,%esi
  801868:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801870:	75 13                	jne    801885 <memmove+0x3b>
  801872:	f6 c1 03             	test   $0x3,%cl
  801875:	75 0e                	jne    801885 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801877:	83 ef 04             	sub    $0x4,%edi
  80187a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801880:	fd                   	std    
  801881:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801883:	eb 09                	jmp    80188e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801885:	83 ef 01             	sub    $0x1,%edi
  801888:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80188b:	fd                   	std    
  80188c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188e:	fc                   	cld    
  80188f:	eb 1d                	jmp    8018ae <memmove+0x64>
  801891:	89 f2                	mov    %esi,%edx
  801893:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801895:	f6 c2 03             	test   $0x3,%dl
  801898:	75 0f                	jne    8018a9 <memmove+0x5f>
  80189a:	f6 c1 03             	test   $0x3,%cl
  80189d:	75 0a                	jne    8018a9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80189f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018a2:	89 c7                	mov    %eax,%edi
  8018a4:	fc                   	cld    
  8018a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a7:	eb 05                	jmp    8018ae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a9:	89 c7                	mov    %eax,%edi
  8018ab:	fc                   	cld    
  8018ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ae:	5e                   	pop    %esi
  8018af:	5f                   	pop    %edi
  8018b0:	5d                   	pop    %ebp
  8018b1:	c3                   	ret    

008018b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b5:	ff 75 10             	pushl  0x10(%ebp)
  8018b8:	ff 75 0c             	pushl  0xc(%ebp)
  8018bb:	ff 75 08             	pushl  0x8(%ebp)
  8018be:	e8 87 ff ff ff       	call   80184a <memmove>
}
  8018c3:	c9                   	leave  
  8018c4:	c3                   	ret    

008018c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c5:	55                   	push   %ebp
  8018c6:	89 e5                	mov    %esp,%ebp
  8018c8:	56                   	push   %esi
  8018c9:	53                   	push   %ebx
  8018ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d0:	89 c6                	mov    %eax,%esi
  8018d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d5:	eb 1a                	jmp    8018f1 <memcmp+0x2c>
		if (*s1 != *s2)
  8018d7:	0f b6 08             	movzbl (%eax),%ecx
  8018da:	0f b6 1a             	movzbl (%edx),%ebx
  8018dd:	38 d9                	cmp    %bl,%cl
  8018df:	74 0a                	je     8018eb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e1:	0f b6 c1             	movzbl %cl,%eax
  8018e4:	0f b6 db             	movzbl %bl,%ebx
  8018e7:	29 d8                	sub    %ebx,%eax
  8018e9:	eb 0f                	jmp    8018fa <memcmp+0x35>
		s1++, s2++;
  8018eb:	83 c0 01             	add    $0x1,%eax
  8018ee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f1:	39 f0                	cmp    %esi,%eax
  8018f3:	75 e2                	jne    8018d7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fa:	5b                   	pop    %ebx
  8018fb:	5e                   	pop    %esi
  8018fc:	5d                   	pop    %ebp
  8018fd:	c3                   	ret    

008018fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801907:	89 c2                	mov    %eax,%edx
  801909:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80190c:	eb 07                	jmp    801915 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190e:	38 08                	cmp    %cl,(%eax)
  801910:	74 07                	je     801919 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801912:	83 c0 01             	add    $0x1,%eax
  801915:	39 d0                	cmp    %edx,%eax
  801917:	72 f5                	jb     80190e <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801919:	5d                   	pop    %ebp
  80191a:	c3                   	ret    

0080191b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	57                   	push   %edi
  80191f:	56                   	push   %esi
  801920:	53                   	push   %ebx
  801921:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801924:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801927:	eb 03                	jmp    80192c <strtol+0x11>
		s++;
  801929:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192c:	0f b6 01             	movzbl (%ecx),%eax
  80192f:	3c 09                	cmp    $0x9,%al
  801931:	74 f6                	je     801929 <strtol+0xe>
  801933:	3c 20                	cmp    $0x20,%al
  801935:	74 f2                	je     801929 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801937:	3c 2b                	cmp    $0x2b,%al
  801939:	75 0a                	jne    801945 <strtol+0x2a>
		s++;
  80193b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80193e:	bf 00 00 00 00       	mov    $0x0,%edi
  801943:	eb 10                	jmp    801955 <strtol+0x3a>
  801945:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80194a:	3c 2d                	cmp    $0x2d,%al
  80194c:	75 07                	jne    801955 <strtol+0x3a>
		s++, neg = 1;
  80194e:	8d 49 01             	lea    0x1(%ecx),%ecx
  801951:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801955:	85 db                	test   %ebx,%ebx
  801957:	0f 94 c0             	sete   %al
  80195a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801960:	75 19                	jne    80197b <strtol+0x60>
  801962:	80 39 30             	cmpb   $0x30,(%ecx)
  801965:	75 14                	jne    80197b <strtol+0x60>
  801967:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80196b:	0f 85 8a 00 00 00    	jne    8019fb <strtol+0xe0>
		s += 2, base = 16;
  801971:	83 c1 02             	add    $0x2,%ecx
  801974:	bb 10 00 00 00       	mov    $0x10,%ebx
  801979:	eb 16                	jmp    801991 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80197b:	84 c0                	test   %al,%al
  80197d:	74 12                	je     801991 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801984:	80 39 30             	cmpb   $0x30,(%ecx)
  801987:	75 08                	jne    801991 <strtol+0x76>
		s++, base = 8;
  801989:	83 c1 01             	add    $0x1,%ecx
  80198c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801991:	b8 00 00 00 00       	mov    $0x0,%eax
  801996:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801999:	0f b6 11             	movzbl (%ecx),%edx
  80199c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199f:	89 f3                	mov    %esi,%ebx
  8019a1:	80 fb 09             	cmp    $0x9,%bl
  8019a4:	77 08                	ja     8019ae <strtol+0x93>
			dig = *s - '0';
  8019a6:	0f be d2             	movsbl %dl,%edx
  8019a9:	83 ea 30             	sub    $0x30,%edx
  8019ac:	eb 22                	jmp    8019d0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019ae:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b1:	89 f3                	mov    %esi,%ebx
  8019b3:	80 fb 19             	cmp    $0x19,%bl
  8019b6:	77 08                	ja     8019c0 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019b8:	0f be d2             	movsbl %dl,%edx
  8019bb:	83 ea 57             	sub    $0x57,%edx
  8019be:	eb 10                	jmp    8019d0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019c0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c3:	89 f3                	mov    %esi,%ebx
  8019c5:	80 fb 19             	cmp    $0x19,%bl
  8019c8:	77 16                	ja     8019e0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019ca:	0f be d2             	movsbl %dl,%edx
  8019cd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d3:	7d 0f                	jge    8019e4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019d5:	83 c1 01             	add    $0x1,%ecx
  8019d8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019dc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019de:	eb b9                	jmp    801999 <strtol+0x7e>
  8019e0:	89 c2                	mov    %eax,%edx
  8019e2:	eb 02                	jmp    8019e6 <strtol+0xcb>
  8019e4:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019e6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ea:	74 05                	je     8019f1 <strtol+0xd6>
		*endptr = (char *) s;
  8019ec:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ef:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019f1:	85 ff                	test   %edi,%edi
  8019f3:	74 0c                	je     801a01 <strtol+0xe6>
  8019f5:	89 d0                	mov    %edx,%eax
  8019f7:	f7 d8                	neg    %eax
  8019f9:	eb 06                	jmp    801a01 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019fb:	84 c0                	test   %al,%al
  8019fd:	75 8a                	jne    801989 <strtol+0x6e>
  8019ff:	eb 90                	jmp    801991 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5f                   	pop    %edi
  801a04:	5d                   	pop    %ebp
  801a05:	c3                   	ret    

00801a06 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	56                   	push   %esi
  801a0a:	53                   	push   %ebx
  801a0b:	8b 75 08             	mov    0x8(%ebp),%esi
  801a0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a11:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a14:	85 f6                	test   %esi,%esi
  801a16:	74 06                	je     801a1e <ipc_recv+0x18>
  801a18:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a1e:	85 db                	test   %ebx,%ebx
  801a20:	74 06                	je     801a28 <ipc_recv+0x22>
  801a22:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a28:	83 f8 01             	cmp    $0x1,%eax
  801a2b:	19 d2                	sbb    %edx,%edx
  801a2d:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a2f:	83 ec 0c             	sub    $0xc,%esp
  801a32:	50                   	push   %eax
  801a33:	e8 de e8 ff ff       	call   800316 <sys_ipc_recv>
  801a38:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a3a:	83 c4 10             	add    $0x10,%esp
  801a3d:	85 d2                	test   %edx,%edx
  801a3f:	75 24                	jne    801a65 <ipc_recv+0x5f>
	if (from_env_store)
  801a41:	85 f6                	test   %esi,%esi
  801a43:	74 0a                	je     801a4f <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a45:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4a:	8b 40 70             	mov    0x70(%eax),%eax
  801a4d:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a4f:	85 db                	test   %ebx,%ebx
  801a51:	74 0a                	je     801a5d <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a53:	a1 04 40 80 00       	mov    0x804004,%eax
  801a58:	8b 40 74             	mov    0x74(%eax),%eax
  801a5b:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a5d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a62:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a68:	5b                   	pop    %ebx
  801a69:	5e                   	pop    %esi
  801a6a:	5d                   	pop    %ebp
  801a6b:	c3                   	ret    

00801a6c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	57                   	push   %edi
  801a70:	56                   	push   %esi
  801a71:	53                   	push   %ebx
  801a72:	83 ec 0c             	sub    $0xc,%esp
  801a75:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a78:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a7e:	83 fb 01             	cmp    $0x1,%ebx
  801a81:	19 c0                	sbb    %eax,%eax
  801a83:	09 c3                	or     %eax,%ebx
  801a85:	eb 1c                	jmp    801aa3 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a87:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8a:	74 12                	je     801a9e <ipc_send+0x32>
  801a8c:	50                   	push   %eax
  801a8d:	68 a0 22 80 00       	push   $0x8022a0
  801a92:	6a 36                	push   $0x36
  801a94:	68 b7 22 80 00       	push   $0x8022b7
  801a99:	e8 bd f5 ff ff       	call   80105b <_panic>
		sys_yield();
  801a9e:	e8 a4 e6 ff ff       	call   800147 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aa3:	ff 75 14             	pushl  0x14(%ebp)
  801aa6:	53                   	push   %ebx
  801aa7:	56                   	push   %esi
  801aa8:	57                   	push   %edi
  801aa9:	e8 45 e8 ff ff       	call   8002f3 <sys_ipc_try_send>
		if (ret == 0) break;
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	75 d2                	jne    801a87 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5f                   	pop    %edi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac8:	6b d0 78             	imul   $0x78,%eax,%edx
  801acb:	83 c2 50             	add    $0x50,%edx
  801ace:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ad4:	39 ca                	cmp    %ecx,%edx
  801ad6:	75 0d                	jne    801ae5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ad8:	6b c0 78             	imul   $0x78,%eax,%eax
  801adb:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ae0:	8b 40 08             	mov    0x8(%eax),%eax
  801ae3:	eb 0e                	jmp    801af3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae5:	83 c0 01             	add    $0x1,%eax
  801ae8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aed:	75 d9                	jne    801ac8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aef:	66 b8 00 00          	mov    $0x0,%ax
}
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afb:	89 d0                	mov    %edx,%eax
  801afd:	c1 e8 16             	shr    $0x16,%eax
  801b00:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0c:	f6 c1 01             	test   $0x1,%cl
  801b0f:	74 1d                	je     801b2e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b11:	c1 ea 0c             	shr    $0xc,%edx
  801b14:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1b:	f6 c2 01             	test   $0x1,%dl
  801b1e:	74 0e                	je     801b2e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b20:	c1 ea 0c             	shr    $0xc,%edx
  801b23:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2a:	ef 
  801b2b:	0f b7 c0             	movzwl %ax,%eax
}
  801b2e:	5d                   	pop    %ebp
  801b2f:	c3                   	ret    

00801b30 <__udivdi3>:
  801b30:	55                   	push   %ebp
  801b31:	57                   	push   %edi
  801b32:	56                   	push   %esi
  801b33:	83 ec 10             	sub    $0x10,%esp
  801b36:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b3a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b3e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b46:	85 d2                	test   %edx,%edx
  801b48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b4c:	89 34 24             	mov    %esi,(%esp)
  801b4f:	89 c8                	mov    %ecx,%eax
  801b51:	75 35                	jne    801b88 <__udivdi3+0x58>
  801b53:	39 f1                	cmp    %esi,%ecx
  801b55:	0f 87 bd 00 00 00    	ja     801c18 <__udivdi3+0xe8>
  801b5b:	85 c9                	test   %ecx,%ecx
  801b5d:	89 cd                	mov    %ecx,%ebp
  801b5f:	75 0b                	jne    801b6c <__udivdi3+0x3c>
  801b61:	b8 01 00 00 00       	mov    $0x1,%eax
  801b66:	31 d2                	xor    %edx,%edx
  801b68:	f7 f1                	div    %ecx
  801b6a:	89 c5                	mov    %eax,%ebp
  801b6c:	89 f0                	mov    %esi,%eax
  801b6e:	31 d2                	xor    %edx,%edx
  801b70:	f7 f5                	div    %ebp
  801b72:	89 c6                	mov    %eax,%esi
  801b74:	89 f8                	mov    %edi,%eax
  801b76:	f7 f5                	div    %ebp
  801b78:	89 f2                	mov    %esi,%edx
  801b7a:	83 c4 10             	add    $0x10,%esp
  801b7d:	5e                   	pop    %esi
  801b7e:	5f                   	pop    %edi
  801b7f:	5d                   	pop    %ebp
  801b80:	c3                   	ret    
  801b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b88:	3b 14 24             	cmp    (%esp),%edx
  801b8b:	77 7b                	ja     801c08 <__udivdi3+0xd8>
  801b8d:	0f bd f2             	bsr    %edx,%esi
  801b90:	83 f6 1f             	xor    $0x1f,%esi
  801b93:	0f 84 97 00 00 00    	je     801c30 <__udivdi3+0x100>
  801b99:	bd 20 00 00 00       	mov    $0x20,%ebp
  801b9e:	89 d7                	mov    %edx,%edi
  801ba0:	89 f1                	mov    %esi,%ecx
  801ba2:	29 f5                	sub    %esi,%ebp
  801ba4:	d3 e7                	shl    %cl,%edi
  801ba6:	89 c2                	mov    %eax,%edx
  801ba8:	89 e9                	mov    %ebp,%ecx
  801baa:	d3 ea                	shr    %cl,%edx
  801bac:	89 f1                	mov    %esi,%ecx
  801bae:	09 fa                	or     %edi,%edx
  801bb0:	8b 3c 24             	mov    (%esp),%edi
  801bb3:	d3 e0                	shl    %cl,%eax
  801bb5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bb9:	89 e9                	mov    %ebp,%ecx
  801bbb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bbf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bc3:	89 fa                	mov    %edi,%edx
  801bc5:	d3 ea                	shr    %cl,%edx
  801bc7:	89 f1                	mov    %esi,%ecx
  801bc9:	d3 e7                	shl    %cl,%edi
  801bcb:	89 e9                	mov    %ebp,%ecx
  801bcd:	d3 e8                	shr    %cl,%eax
  801bcf:	09 c7                	or     %eax,%edi
  801bd1:	89 f8                	mov    %edi,%eax
  801bd3:	f7 74 24 08          	divl   0x8(%esp)
  801bd7:	89 d5                	mov    %edx,%ebp
  801bd9:	89 c7                	mov    %eax,%edi
  801bdb:	f7 64 24 0c          	mull   0xc(%esp)
  801bdf:	39 d5                	cmp    %edx,%ebp
  801be1:	89 14 24             	mov    %edx,(%esp)
  801be4:	72 11                	jb     801bf7 <__udivdi3+0xc7>
  801be6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801bea:	89 f1                	mov    %esi,%ecx
  801bec:	d3 e2                	shl    %cl,%edx
  801bee:	39 c2                	cmp    %eax,%edx
  801bf0:	73 5e                	jae    801c50 <__udivdi3+0x120>
  801bf2:	3b 2c 24             	cmp    (%esp),%ebp
  801bf5:	75 59                	jne    801c50 <__udivdi3+0x120>
  801bf7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801bfa:	31 f6                	xor    %esi,%esi
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    
  801c05:	8d 76 00             	lea    0x0(%esi),%esi
  801c08:	31 f6                	xor    %esi,%esi
  801c0a:	31 c0                	xor    %eax,%eax
  801c0c:	89 f2                	mov    %esi,%edx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    
  801c15:	8d 76 00             	lea    0x0(%esi),%esi
  801c18:	89 f2                	mov    %esi,%edx
  801c1a:	31 f6                	xor    %esi,%esi
  801c1c:	89 f8                	mov    %edi,%eax
  801c1e:	f7 f1                	div    %ecx
  801c20:	89 f2                	mov    %esi,%edx
  801c22:	83 c4 10             	add    $0x10,%esp
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c34:	76 0b                	jbe    801c41 <__udivdi3+0x111>
  801c36:	31 c0                	xor    %eax,%eax
  801c38:	3b 14 24             	cmp    (%esp),%edx
  801c3b:	0f 83 37 ff ff ff    	jae    801b78 <__udivdi3+0x48>
  801c41:	b8 01 00 00 00       	mov    $0x1,%eax
  801c46:	e9 2d ff ff ff       	jmp    801b78 <__udivdi3+0x48>
  801c4b:	90                   	nop
  801c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 f8                	mov    %edi,%eax
  801c52:	31 f6                	xor    %esi,%esi
  801c54:	e9 1f ff ff ff       	jmp    801b78 <__udivdi3+0x48>
  801c59:	66 90                	xchg   %ax,%ax
  801c5b:	66 90                	xchg   %ax,%ax
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

00801c60 <__umoddi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	83 ec 20             	sub    $0x20,%esp
  801c66:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c6a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c6e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c72:	89 c6                	mov    %eax,%esi
  801c74:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c78:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c7c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c80:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c84:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c88:	89 74 24 18          	mov    %esi,0x18(%esp)
  801c8c:	85 c0                	test   %eax,%eax
  801c8e:	89 c2                	mov    %eax,%edx
  801c90:	75 1e                	jne    801cb0 <__umoddi3+0x50>
  801c92:	39 f7                	cmp    %esi,%edi
  801c94:	76 52                	jbe    801ce8 <__umoddi3+0x88>
  801c96:	89 c8                	mov    %ecx,%eax
  801c98:	89 f2                	mov    %esi,%edx
  801c9a:	f7 f7                	div    %edi
  801c9c:	89 d0                	mov    %edx,%eax
  801c9e:	31 d2                	xor    %edx,%edx
  801ca0:	83 c4 20             	add    $0x20,%esp
  801ca3:	5e                   	pop    %esi
  801ca4:	5f                   	pop    %edi
  801ca5:	5d                   	pop    %ebp
  801ca6:	c3                   	ret    
  801ca7:	89 f6                	mov    %esi,%esi
  801ca9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cb0:	39 f0                	cmp    %esi,%eax
  801cb2:	77 5c                	ja     801d10 <__umoddi3+0xb0>
  801cb4:	0f bd e8             	bsr    %eax,%ebp
  801cb7:	83 f5 1f             	xor    $0x1f,%ebp
  801cba:	75 64                	jne    801d20 <__umoddi3+0xc0>
  801cbc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cc0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cc4:	0f 86 f6 00 00 00    	jbe    801dc0 <__umoddi3+0x160>
  801cca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cce:	0f 82 ec 00 00 00    	jb     801dc0 <__umoddi3+0x160>
  801cd4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cd8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cdc:	83 c4 20             	add    $0x20,%esp
  801cdf:	5e                   	pop    %esi
  801ce0:	5f                   	pop    %edi
  801ce1:	5d                   	pop    %ebp
  801ce2:	c3                   	ret    
  801ce3:	90                   	nop
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	85 ff                	test   %edi,%edi
  801cea:	89 fd                	mov    %edi,%ebp
  801cec:	75 0b                	jne    801cf9 <__umoddi3+0x99>
  801cee:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf3:	31 d2                	xor    %edx,%edx
  801cf5:	f7 f7                	div    %edi
  801cf7:	89 c5                	mov    %eax,%ebp
  801cf9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801cfd:	31 d2                	xor    %edx,%edx
  801cff:	f7 f5                	div    %ebp
  801d01:	89 c8                	mov    %ecx,%eax
  801d03:	f7 f5                	div    %ebp
  801d05:	eb 95                	jmp    801c9c <__umoddi3+0x3c>
  801d07:	89 f6                	mov    %esi,%esi
  801d09:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 20             	add    $0x20,%esp
  801d17:	5e                   	pop    %esi
  801d18:	5f                   	pop    %edi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    
  801d1b:	90                   	nop
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	b8 20 00 00 00       	mov    $0x20,%eax
  801d25:	89 e9                	mov    %ebp,%ecx
  801d27:	29 e8                	sub    %ebp,%eax
  801d29:	d3 e2                	shl    %cl,%edx
  801d2b:	89 c7                	mov    %eax,%edi
  801d2d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d31:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d35:	89 f9                	mov    %edi,%ecx
  801d37:	d3 e8                	shr    %cl,%eax
  801d39:	89 c1                	mov    %eax,%ecx
  801d3b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d3f:	09 d1                	or     %edx,%ecx
  801d41:	89 fa                	mov    %edi,%edx
  801d43:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d47:	89 e9                	mov    %ebp,%ecx
  801d49:	d3 e0                	shl    %cl,%eax
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d51:	89 f0                	mov    %esi,%eax
  801d53:	d3 e8                	shr    %cl,%eax
  801d55:	89 e9                	mov    %ebp,%ecx
  801d57:	89 c7                	mov    %eax,%edi
  801d59:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d5d:	d3 e6                	shl    %cl,%esi
  801d5f:	89 d1                	mov    %edx,%ecx
  801d61:	89 fa                	mov    %edi,%edx
  801d63:	d3 e8                	shr    %cl,%eax
  801d65:	89 e9                	mov    %ebp,%ecx
  801d67:	09 f0                	or     %esi,%eax
  801d69:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d6d:	f7 74 24 10          	divl   0x10(%esp)
  801d71:	d3 e6                	shl    %cl,%esi
  801d73:	89 d1                	mov    %edx,%ecx
  801d75:	f7 64 24 0c          	mull   0xc(%esp)
  801d79:	39 d1                	cmp    %edx,%ecx
  801d7b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d7f:	89 d7                	mov    %edx,%edi
  801d81:	89 c6                	mov    %eax,%esi
  801d83:	72 0a                	jb     801d8f <__umoddi3+0x12f>
  801d85:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801d89:	73 10                	jae    801d9b <__umoddi3+0x13b>
  801d8b:	39 d1                	cmp    %edx,%ecx
  801d8d:	75 0c                	jne    801d9b <__umoddi3+0x13b>
  801d8f:	89 d7                	mov    %edx,%edi
  801d91:	89 c6                	mov    %eax,%esi
  801d93:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801d97:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801d9b:	89 ca                	mov    %ecx,%edx
  801d9d:	89 e9                	mov    %ebp,%ecx
  801d9f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801da3:	29 f0                	sub    %esi,%eax
  801da5:	19 fa                	sbb    %edi,%edx
  801da7:	d3 e8                	shr    %cl,%eax
  801da9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dae:	89 d7                	mov    %edx,%edi
  801db0:	d3 e7                	shl    %cl,%edi
  801db2:	89 e9                	mov    %ebp,%ecx
  801db4:	09 f8                	or     %edi,%eax
  801db6:	d3 ea                	shr    %cl,%edx
  801db8:	83 c4 20             	add    $0x20,%esp
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    
  801dbf:	90                   	nop
  801dc0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801dc4:	29 f9                	sub    %edi,%ecx
  801dc6:	19 c6                	sbb    %eax,%esi
  801dc8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dcc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801dd0:	e9 ff fe ff ff       	jmp    801cd4 <__umoddi3+0x74>
