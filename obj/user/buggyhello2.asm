
obj/user/buggyhello2:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
  800049:	83 c4 10             	add    $0x10,%esp
}
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 78             	imul   $0x78,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
  80008a:	83 c4 10             	add    $0x10,%esp
#endif
}
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 a7 04 00 00       	call   800546 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
  8000a9:	83 c4 10             	add    $0x10,%esp
}
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 18 1e 80 00       	push   $0x801e18
  800118:	6a 23                	push   $0x23
  80011a:	68 35 1e 80 00       	push   $0x801e35
  80011f:	e8 3b 0f 00 00       	call   80105f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 18 1e 80 00       	push   $0x801e18
  800199:	6a 23                	push   $0x23
  80019b:	68 35 1e 80 00       	push   $0x801e35
  8001a0:	e8 ba 0e 00 00       	call   80105f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 18 1e 80 00       	push   $0x801e18
  8001db:	6a 23                	push   $0x23
  8001dd:	68 35 1e 80 00       	push   $0x801e35
  8001e2:	e8 78 0e 00 00       	call   80105f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 18 1e 80 00       	push   $0x801e18
  80021d:	6a 23                	push   $0x23
  80021f:	68 35 1e 80 00       	push   $0x801e35
  800224:	e8 36 0e 00 00       	call   80105f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 18 1e 80 00       	push   $0x801e18
  80025f:	6a 23                	push   $0x23
  800261:	68 35 1e 80 00       	push   $0x801e35
  800266:	e8 f4 0d 00 00       	call   80105f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 18 1e 80 00       	push   $0x801e18
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 35 1e 80 00       	push   $0x801e35
  8002a8:	e8 b2 0d 00 00       	call   80105f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 18 1e 80 00       	push   $0x801e18
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 35 1e 80 00       	push   $0x801e35
  8002ea:	e8 70 0d 00 00       	call   80105f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 18 1e 80 00       	push   $0x801e18
  800347:	6a 23                	push   $0x23
  800349:	68 35 1e 80 00       	push   $0x801e35
  80034e:	e8 0c 0d 00 00       	call   80105f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <sys_gettime>:

int sys_gettime(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	05 00 00 00 30       	add    $0x30000000,%eax
  800385:	c1 e8 0c             	shr    $0xc,%eax
}
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80038d:	8b 45 08             	mov    0x8(%ebp),%eax
  800390:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800395:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80039a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003ac:	89 c2                	mov    %eax,%edx
  8003ae:	c1 ea 16             	shr    $0x16,%edx
  8003b1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b8:	f6 c2 01             	test   $0x1,%dl
  8003bb:	74 11                	je     8003ce <fd_alloc+0x2d>
  8003bd:	89 c2                	mov    %eax,%edx
  8003bf:	c1 ea 0c             	shr    $0xc,%edx
  8003c2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c9:	f6 c2 01             	test   $0x1,%dl
  8003cc:	75 09                	jne    8003d7 <fd_alloc+0x36>
			*fd_store = fd;
  8003ce:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d5:	eb 17                	jmp    8003ee <fd_alloc+0x4d>
  8003d7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003dc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e1:	75 c9                	jne    8003ac <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003e3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003ee:	5d                   	pop    %ebp
  8003ef:	c3                   	ret    

008003f0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003f6:	83 f8 1f             	cmp    $0x1f,%eax
  8003f9:	77 36                	ja     800431 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003fb:	c1 e0 0c             	shl    $0xc,%eax
  8003fe:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800403:	89 c2                	mov    %eax,%edx
  800405:	c1 ea 16             	shr    $0x16,%edx
  800408:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040f:	f6 c2 01             	test   $0x1,%dl
  800412:	74 24                	je     800438 <fd_lookup+0x48>
  800414:	89 c2                	mov    %eax,%edx
  800416:	c1 ea 0c             	shr    $0xc,%edx
  800419:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800420:	f6 c2 01             	test   $0x1,%dl
  800423:	74 1a                	je     80043f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800425:	8b 55 0c             	mov    0xc(%ebp),%edx
  800428:	89 02                	mov    %eax,(%edx)
	return 0;
  80042a:	b8 00 00 00 00       	mov    $0x0,%eax
  80042f:	eb 13                	jmp    800444 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 0c                	jmp    800444 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043d:	eb 05                	jmp    800444 <fd_lookup+0x54>
  80043f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800444:	5d                   	pop    %ebp
  800445:	c3                   	ret    

00800446 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800446:	55                   	push   %ebp
  800447:	89 e5                	mov    %esp,%ebp
  800449:	83 ec 08             	sub    $0x8,%esp
  80044c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80044f:	ba c0 1e 80 00       	mov    $0x801ec0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800454:	eb 13                	jmp    800469 <dev_lookup+0x23>
  800456:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800459:	39 08                	cmp    %ecx,(%eax)
  80045b:	75 0c                	jne    800469 <dev_lookup+0x23>
			*dev = devtab[i];
  80045d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800460:	89 01                	mov    %eax,(%ecx)
			return 0;
  800462:	b8 00 00 00 00       	mov    $0x0,%eax
  800467:	eb 2e                	jmp    800497 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800469:	8b 02                	mov    (%edx),%eax
  80046b:	85 c0                	test   %eax,%eax
  80046d:	75 e7                	jne    800456 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046f:	a1 04 40 80 00       	mov    0x804004,%eax
  800474:	8b 40 48             	mov    0x48(%eax),%eax
  800477:	83 ec 04             	sub    $0x4,%esp
  80047a:	51                   	push   %ecx
  80047b:	50                   	push   %eax
  80047c:	68 44 1e 80 00       	push   $0x801e44
  800481:	e8 b2 0c 00 00       	call   801138 <cprintf>
	*dev = 0;
  800486:	8b 45 0c             	mov    0xc(%ebp),%eax
  800489:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80048f:	83 c4 10             	add    $0x10,%esp
  800492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800497:	c9                   	leave  
  800498:	c3                   	ret    

00800499 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	56                   	push   %esi
  80049d:	53                   	push   %ebx
  80049e:	83 ec 10             	sub    $0x10,%esp
  8004a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004aa:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004ab:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004b1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004b4:	50                   	push   %eax
  8004b5:	e8 36 ff ff ff       	call   8003f0 <fd_lookup>
  8004ba:	83 c4 08             	add    $0x8,%esp
  8004bd:	85 c0                	test   %eax,%eax
  8004bf:	78 05                	js     8004c6 <fd_close+0x2d>
	    || fd != fd2)
  8004c1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004c4:	74 0b                	je     8004d1 <fd_close+0x38>
		return (must_exist ? r : 0);
  8004c6:	80 fb 01             	cmp    $0x1,%bl
  8004c9:	19 d2                	sbb    %edx,%edx
  8004cb:	f7 d2                	not    %edx
  8004cd:	21 d0                	and    %edx,%eax
  8004cf:	eb 41                	jmp    800512 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d7:	50                   	push   %eax
  8004d8:	ff 36                	pushl  (%esi)
  8004da:	e8 67 ff ff ff       	call   800446 <dev_lookup>
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
  8004e4:	85 c0                	test   %eax,%eax
  8004e6:	78 1a                	js     800502 <fd_close+0x69>
		if (dev->dev_close)
  8004e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004eb:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004ee:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004f3:	85 c0                	test   %eax,%eax
  8004f5:	74 0b                	je     800502 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8004f7:	83 ec 0c             	sub    $0xc,%esp
  8004fa:	56                   	push   %esi
  8004fb:	ff d0                	call   *%eax
  8004fd:	89 c3                	mov    %eax,%ebx
  8004ff:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800502:	83 ec 08             	sub    $0x8,%esp
  800505:	56                   	push   %esi
  800506:	6a 00                	push   $0x0
  800508:	e8 e2 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80050d:	83 c4 10             	add    $0x10,%esp
  800510:	89 d8                	mov    %ebx,%eax
}
  800512:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800515:	5b                   	pop    %ebx
  800516:	5e                   	pop    %esi
  800517:	5d                   	pop    %ebp
  800518:	c3                   	ret    

00800519 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800519:	55                   	push   %ebp
  80051a:	89 e5                	mov    %esp,%ebp
  80051c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80051f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800522:	50                   	push   %eax
  800523:	ff 75 08             	pushl  0x8(%ebp)
  800526:	e8 c5 fe ff ff       	call   8003f0 <fd_lookup>
  80052b:	89 c2                	mov    %eax,%edx
  80052d:	83 c4 08             	add    $0x8,%esp
  800530:	85 d2                	test   %edx,%edx
  800532:	78 10                	js     800544 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800534:	83 ec 08             	sub    $0x8,%esp
  800537:	6a 01                	push   $0x1
  800539:	ff 75 f4             	pushl  -0xc(%ebp)
  80053c:	e8 58 ff ff ff       	call   800499 <fd_close>
  800541:	83 c4 10             	add    $0x10,%esp
}
  800544:	c9                   	leave  
  800545:	c3                   	ret    

00800546 <close_all>:

void
close_all(void)
{
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	53                   	push   %ebx
  80054a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80054d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800552:	83 ec 0c             	sub    $0xc,%esp
  800555:	53                   	push   %ebx
  800556:	e8 be ff ff ff       	call   800519 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80055b:	83 c3 01             	add    $0x1,%ebx
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	83 fb 20             	cmp    $0x20,%ebx
  800564:	75 ec                	jne    800552 <close_all+0xc>
		close(i);
}
  800566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800569:	c9                   	leave  
  80056a:	c3                   	ret    

0080056b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80056b:	55                   	push   %ebp
  80056c:	89 e5                	mov    %esp,%ebp
  80056e:	57                   	push   %edi
  80056f:	56                   	push   %esi
  800570:	53                   	push   %ebx
  800571:	83 ec 2c             	sub    $0x2c,%esp
  800574:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800577:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80057a:	50                   	push   %eax
  80057b:	ff 75 08             	pushl  0x8(%ebp)
  80057e:	e8 6d fe ff ff       	call   8003f0 <fd_lookup>
  800583:	89 c2                	mov    %eax,%edx
  800585:	83 c4 08             	add    $0x8,%esp
  800588:	85 d2                	test   %edx,%edx
  80058a:	0f 88 c1 00 00 00    	js     800651 <dup+0xe6>
		return r;
	close(newfdnum);
  800590:	83 ec 0c             	sub    $0xc,%esp
  800593:	56                   	push   %esi
  800594:	e8 80 ff ff ff       	call   800519 <close>

	newfd = INDEX2FD(newfdnum);
  800599:	89 f3                	mov    %esi,%ebx
  80059b:	c1 e3 0c             	shl    $0xc,%ebx
  80059e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005a4:	83 c4 04             	add    $0x4,%esp
  8005a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005aa:	e8 db fd ff ff       	call   80038a <fd2data>
  8005af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005b1:	89 1c 24             	mov    %ebx,(%esp)
  8005b4:	e8 d1 fd ff ff       	call   80038a <fd2data>
  8005b9:	83 c4 10             	add    $0x10,%esp
  8005bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005bf:	89 f8                	mov    %edi,%eax
  8005c1:	c1 e8 16             	shr    $0x16,%eax
  8005c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005cb:	a8 01                	test   $0x1,%al
  8005cd:	74 37                	je     800606 <dup+0x9b>
  8005cf:	89 f8                	mov    %edi,%eax
  8005d1:	c1 e8 0c             	shr    $0xc,%eax
  8005d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005db:	f6 c2 01             	test   $0x1,%dl
  8005de:	74 26                	je     800606 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005f3:	6a 00                	push   $0x0
  8005f5:	57                   	push   %edi
  8005f6:	6a 00                	push   $0x0
  8005f8:	e8 b0 fb ff ff       	call   8001ad <sys_page_map>
  8005fd:	89 c7                	mov    %eax,%edi
  8005ff:	83 c4 20             	add    $0x20,%esp
  800602:	85 c0                	test   %eax,%eax
  800604:	78 2e                	js     800634 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800606:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800609:	89 d0                	mov    %edx,%eax
  80060b:	c1 e8 0c             	shr    $0xc,%eax
  80060e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800615:	83 ec 0c             	sub    $0xc,%esp
  800618:	25 07 0e 00 00       	and    $0xe07,%eax
  80061d:	50                   	push   %eax
  80061e:	53                   	push   %ebx
  80061f:	6a 00                	push   $0x0
  800621:	52                   	push   %edx
  800622:	6a 00                	push   $0x0
  800624:	e8 84 fb ff ff       	call   8001ad <sys_page_map>
  800629:	89 c7                	mov    %eax,%edi
  80062b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80062e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800630:	85 ff                	test   %edi,%edi
  800632:	79 1d                	jns    800651 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800634:	83 ec 08             	sub    $0x8,%esp
  800637:	53                   	push   %ebx
  800638:	6a 00                	push   $0x0
  80063a:	e8 b0 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	ff 75 d4             	pushl  -0x2c(%ebp)
  800645:	6a 00                	push   $0x0
  800647:	e8 a3 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	89 f8                	mov    %edi,%eax
}
  800651:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800654:	5b                   	pop    %ebx
  800655:	5e                   	pop    %esi
  800656:	5f                   	pop    %edi
  800657:	5d                   	pop    %ebp
  800658:	c3                   	ret    

00800659 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	53                   	push   %ebx
  80065d:	83 ec 14             	sub    $0x14,%esp
  800660:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800663:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800666:	50                   	push   %eax
  800667:	53                   	push   %ebx
  800668:	e8 83 fd ff ff       	call   8003f0 <fd_lookup>
  80066d:	83 c4 08             	add    $0x8,%esp
  800670:	89 c2                	mov    %eax,%edx
  800672:	85 c0                	test   %eax,%eax
  800674:	78 6d                	js     8006e3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800676:	83 ec 08             	sub    $0x8,%esp
  800679:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80067c:	50                   	push   %eax
  80067d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800680:	ff 30                	pushl  (%eax)
  800682:	e8 bf fd ff ff       	call   800446 <dev_lookup>
  800687:	83 c4 10             	add    $0x10,%esp
  80068a:	85 c0                	test   %eax,%eax
  80068c:	78 4c                	js     8006da <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80068e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800691:	8b 42 08             	mov    0x8(%edx),%eax
  800694:	83 e0 03             	and    $0x3,%eax
  800697:	83 f8 01             	cmp    $0x1,%eax
  80069a:	75 21                	jne    8006bd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80069c:	a1 04 40 80 00       	mov    0x804004,%eax
  8006a1:	8b 40 48             	mov    0x48(%eax),%eax
  8006a4:	83 ec 04             	sub    $0x4,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	50                   	push   %eax
  8006a9:	68 85 1e 80 00       	push   $0x801e85
  8006ae:	e8 85 0a 00 00       	call   801138 <cprintf>
		return -E_INVAL;
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006bb:	eb 26                	jmp    8006e3 <read+0x8a>
	}
	if (!dev->dev_read)
  8006bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c0:	8b 40 08             	mov    0x8(%eax),%eax
  8006c3:	85 c0                	test   %eax,%eax
  8006c5:	74 17                	je     8006de <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c7:	83 ec 04             	sub    $0x4,%esp
  8006ca:	ff 75 10             	pushl  0x10(%ebp)
  8006cd:	ff 75 0c             	pushl  0xc(%ebp)
  8006d0:	52                   	push   %edx
  8006d1:	ff d0                	call   *%eax
  8006d3:	89 c2                	mov    %eax,%edx
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	eb 09                	jmp    8006e3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006da:	89 c2                	mov    %eax,%edx
  8006dc:	eb 05                	jmp    8006e3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006e3:	89 d0                	mov    %edx,%eax
  8006e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e8:	c9                   	leave  
  8006e9:	c3                   	ret    

008006ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006ea:	55                   	push   %ebp
  8006eb:	89 e5                	mov    %esp,%ebp
  8006ed:	57                   	push   %edi
  8006ee:	56                   	push   %esi
  8006ef:	53                   	push   %ebx
  8006f0:	83 ec 0c             	sub    $0xc,%esp
  8006f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fe:	eb 21                	jmp    800721 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800700:	83 ec 04             	sub    $0x4,%esp
  800703:	89 f0                	mov    %esi,%eax
  800705:	29 d8                	sub    %ebx,%eax
  800707:	50                   	push   %eax
  800708:	89 d8                	mov    %ebx,%eax
  80070a:	03 45 0c             	add    0xc(%ebp),%eax
  80070d:	50                   	push   %eax
  80070e:	57                   	push   %edi
  80070f:	e8 45 ff ff ff       	call   800659 <read>
		if (m < 0)
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	85 c0                	test   %eax,%eax
  800719:	78 0c                	js     800727 <readn+0x3d>
			return m;
		if (m == 0)
  80071b:	85 c0                	test   %eax,%eax
  80071d:	74 06                	je     800725 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071f:	01 c3                	add    %eax,%ebx
  800721:	39 f3                	cmp    %esi,%ebx
  800723:	72 db                	jb     800700 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800725:	89 d8                	mov    %ebx,%eax
}
  800727:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072a:	5b                   	pop    %ebx
  80072b:	5e                   	pop    %esi
  80072c:	5f                   	pop    %edi
  80072d:	5d                   	pop    %ebp
  80072e:	c3                   	ret    

0080072f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	53                   	push   %ebx
  800733:	83 ec 14             	sub    $0x14,%esp
  800736:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800739:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80073c:	50                   	push   %eax
  80073d:	53                   	push   %ebx
  80073e:	e8 ad fc ff ff       	call   8003f0 <fd_lookup>
  800743:	83 c4 08             	add    $0x8,%esp
  800746:	89 c2                	mov    %eax,%edx
  800748:	85 c0                	test   %eax,%eax
  80074a:	78 68                	js     8007b4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800752:	50                   	push   %eax
  800753:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800756:	ff 30                	pushl  (%eax)
  800758:	e8 e9 fc ff ff       	call   800446 <dev_lookup>
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	85 c0                	test   %eax,%eax
  800762:	78 47                	js     8007ab <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800764:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800767:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80076b:	75 21                	jne    80078e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80076d:	a1 04 40 80 00       	mov    0x804004,%eax
  800772:	8b 40 48             	mov    0x48(%eax),%eax
  800775:	83 ec 04             	sub    $0x4,%esp
  800778:	53                   	push   %ebx
  800779:	50                   	push   %eax
  80077a:	68 a1 1e 80 00       	push   $0x801ea1
  80077f:	e8 b4 09 00 00       	call   801138 <cprintf>
		return -E_INVAL;
  800784:	83 c4 10             	add    $0x10,%esp
  800787:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80078c:	eb 26                	jmp    8007b4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800791:	8b 52 0c             	mov    0xc(%edx),%edx
  800794:	85 d2                	test   %edx,%edx
  800796:	74 17                	je     8007af <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800798:	83 ec 04             	sub    $0x4,%esp
  80079b:	ff 75 10             	pushl  0x10(%ebp)
  80079e:	ff 75 0c             	pushl  0xc(%ebp)
  8007a1:	50                   	push   %eax
  8007a2:	ff d2                	call   *%edx
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	83 c4 10             	add    $0x10,%esp
  8007a9:	eb 09                	jmp    8007b4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ab:	89 c2                	mov    %eax,%edx
  8007ad:	eb 05                	jmp    8007b4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007af:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007b4:	89 d0                	mov    %edx,%eax
  8007b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <seek>:

int
seek(int fdnum, off_t offset)
{
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007c1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	ff 75 08             	pushl  0x8(%ebp)
  8007c8:	e8 23 fc ff ff       	call   8003f0 <fd_lookup>
  8007cd:	83 c4 08             	add    $0x8,%esp
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	78 0e                	js     8007e2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007da:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007e4:	55                   	push   %ebp
  8007e5:	89 e5                	mov    %esp,%ebp
  8007e7:	53                   	push   %ebx
  8007e8:	83 ec 14             	sub    $0x14,%esp
  8007eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007f1:	50                   	push   %eax
  8007f2:	53                   	push   %ebx
  8007f3:	e8 f8 fb ff ff       	call   8003f0 <fd_lookup>
  8007f8:	83 c4 08             	add    $0x8,%esp
  8007fb:	89 c2                	mov    %eax,%edx
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	78 65                	js     800866 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800807:	50                   	push   %eax
  800808:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080b:	ff 30                	pushl  (%eax)
  80080d:	e8 34 fc ff ff       	call   800446 <dev_lookup>
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	85 c0                	test   %eax,%eax
  800817:	78 44                	js     80085d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80081c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800820:	75 21                	jne    800843 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800822:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800827:	8b 40 48             	mov    0x48(%eax),%eax
  80082a:	83 ec 04             	sub    $0x4,%esp
  80082d:	53                   	push   %ebx
  80082e:	50                   	push   %eax
  80082f:	68 64 1e 80 00       	push   $0x801e64
  800834:	e8 ff 08 00 00       	call   801138 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800839:	83 c4 10             	add    $0x10,%esp
  80083c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800841:	eb 23                	jmp    800866 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800843:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800846:	8b 52 18             	mov    0x18(%edx),%edx
  800849:	85 d2                	test   %edx,%edx
  80084b:	74 14                	je     800861 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80084d:	83 ec 08             	sub    $0x8,%esp
  800850:	ff 75 0c             	pushl  0xc(%ebp)
  800853:	50                   	push   %eax
  800854:	ff d2                	call   *%edx
  800856:	89 c2                	mov    %eax,%edx
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	eb 09                	jmp    800866 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085d:	89 c2                	mov    %eax,%edx
  80085f:	eb 05                	jmp    800866 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800861:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800866:	89 d0                	mov    %edx,%eax
  800868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    

0080086d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80086d:	55                   	push   %ebp
  80086e:	89 e5                	mov    %esp,%ebp
  800870:	53                   	push   %ebx
  800871:	83 ec 14             	sub    $0x14,%esp
  800874:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800877:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80087a:	50                   	push   %eax
  80087b:	ff 75 08             	pushl  0x8(%ebp)
  80087e:	e8 6d fb ff ff       	call   8003f0 <fd_lookup>
  800883:	83 c4 08             	add    $0x8,%esp
  800886:	89 c2                	mov    %eax,%edx
  800888:	85 c0                	test   %eax,%eax
  80088a:	78 58                	js     8008e4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800892:	50                   	push   %eax
  800893:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800896:	ff 30                	pushl  (%eax)
  800898:	e8 a9 fb ff ff       	call   800446 <dev_lookup>
  80089d:	83 c4 10             	add    $0x10,%esp
  8008a0:	85 c0                	test   %eax,%eax
  8008a2:	78 37                	js     8008db <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008ab:	74 32                	je     8008df <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ad:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008b0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b7:	00 00 00 
	stat->st_isdir = 0;
  8008ba:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008c1:	00 00 00 
	stat->st_dev = dev;
  8008c4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ca:	83 ec 08             	sub    $0x8,%esp
  8008cd:	53                   	push   %ebx
  8008ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8008d1:	ff 50 14             	call   *0x14(%eax)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	83 c4 10             	add    $0x10,%esp
  8008d9:	eb 09                	jmp    8008e4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008db:	89 c2                	mov    %eax,%edx
  8008dd:	eb 05                	jmp    8008e4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008e4:	89 d0                	mov    %edx,%eax
  8008e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e9:	c9                   	leave  
  8008ea:	c3                   	ret    

008008eb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008eb:	55                   	push   %ebp
  8008ec:	89 e5                	mov    %esp,%ebp
  8008ee:	56                   	push   %esi
  8008ef:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	6a 00                	push   $0x0
  8008f5:	ff 75 08             	pushl  0x8(%ebp)
  8008f8:	e8 e7 01 00 00       	call   800ae4 <open>
  8008fd:	89 c3                	mov    %eax,%ebx
  8008ff:	83 c4 10             	add    $0x10,%esp
  800902:	85 db                	test   %ebx,%ebx
  800904:	78 1b                	js     800921 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800906:	83 ec 08             	sub    $0x8,%esp
  800909:	ff 75 0c             	pushl  0xc(%ebp)
  80090c:	53                   	push   %ebx
  80090d:	e8 5b ff ff ff       	call   80086d <fstat>
  800912:	89 c6                	mov    %eax,%esi
	close(fd);
  800914:	89 1c 24             	mov    %ebx,(%esp)
  800917:	e8 fd fb ff ff       	call   800519 <close>
	return r;
  80091c:	83 c4 10             	add    $0x10,%esp
  80091f:	89 f0                	mov    %esi,%eax
}
  800921:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800924:	5b                   	pop    %ebx
  800925:	5e                   	pop    %esi
  800926:	5d                   	pop    %ebp
  800927:	c3                   	ret    

00800928 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800928:	55                   	push   %ebp
  800929:	89 e5                	mov    %esp,%ebp
  80092b:	56                   	push   %esi
  80092c:	53                   	push   %ebx
  80092d:	89 c6                	mov    %eax,%esi
  80092f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800931:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800938:	75 12                	jne    80094c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80093a:	83 ec 0c             	sub    $0xc,%esp
  80093d:	6a 03                	push   $0x3
  80093f:	e8 7d 11 00 00       	call   801ac1 <ipc_find_env>
  800944:	a3 00 40 80 00       	mov    %eax,0x804000
  800949:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80094c:	6a 07                	push   $0x7
  80094e:	68 00 50 80 00       	push   $0x805000
  800953:	56                   	push   %esi
  800954:	ff 35 00 40 80 00    	pushl  0x804000
  80095a:	e8 11 11 00 00       	call   801a70 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095f:	83 c4 0c             	add    $0xc,%esp
  800962:	6a 00                	push   $0x0
  800964:	53                   	push   %ebx
  800965:	6a 00                	push   $0x0
  800967:	e8 9e 10 00 00       	call   801a0a <ipc_recv>
}
  80096c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096f:	5b                   	pop    %ebx
  800970:	5e                   	pop    %esi
  800971:	5d                   	pop    %ebp
  800972:	c3                   	ret    

00800973 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800984:	8b 45 0c             	mov    0xc(%ebp),%eax
  800987:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 02 00 00 00       	mov    $0x2,%eax
  800996:	e8 8d ff ff ff       	call   800928 <fsipc>
}
  80099b:	c9                   	leave  
  80099c:	c3                   	ret    

0080099d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b3:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b8:	e8 6b ff ff ff       	call   800928 <fsipc>
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	83 ec 04             	sub    $0x4,%esp
  8009c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cc:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d9:	b8 05 00 00 00       	mov    $0x5,%eax
  8009de:	e8 45 ff ff ff       	call   800928 <fsipc>
  8009e3:	89 c2                	mov    %eax,%edx
  8009e5:	85 d2                	test   %edx,%edx
  8009e7:	78 2c                	js     800a15 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e9:	83 ec 08             	sub    $0x8,%esp
  8009ec:	68 00 50 80 00       	push   $0x805000
  8009f1:	53                   	push   %ebx
  8009f2:	e8 c5 0c 00 00       	call   8016bc <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009fc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a02:	a1 84 50 80 00       	mov    0x805084,%eax
  800a07:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a0d:	83 c4 10             	add    $0x10,%esp
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	83 ec 08             	sub    $0x8,%esp
  800a20:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a23:	8b 55 08             	mov    0x8(%ebp),%edx
  800a26:	8b 52 0c             	mov    0xc(%edx),%edx
  800a29:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a2f:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a34:	76 05                	jbe    800a3b <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a36:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a3b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a40:	83 ec 04             	sub    $0x4,%esp
  800a43:	50                   	push   %eax
  800a44:	ff 75 0c             	pushl  0xc(%ebp)
  800a47:	68 08 50 80 00       	push   $0x805008
  800a4c:	e8 fd 0d 00 00       	call   80184e <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a51:	ba 00 00 00 00       	mov    $0x0,%edx
  800a56:	b8 04 00 00 00       	mov    $0x4,%eax
  800a5b:	e8 c8 fe ff ff       	call   800928 <fsipc>
	return write;
}
  800a60:	c9                   	leave  
  800a61:	c3                   	ret    

00800a62 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a62:	55                   	push   %ebp
  800a63:	89 e5                	mov    %esp,%ebp
  800a65:	56                   	push   %esi
  800a66:	53                   	push   %ebx
  800a67:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a70:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a75:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a80:	b8 03 00 00 00       	mov    $0x3,%eax
  800a85:	e8 9e fe ff ff       	call   800928 <fsipc>
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	85 c0                	test   %eax,%eax
  800a8e:	78 4b                	js     800adb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a90:	39 c6                	cmp    %eax,%esi
  800a92:	73 16                	jae    800aaa <devfile_read+0x48>
  800a94:	68 d0 1e 80 00       	push   $0x801ed0
  800a99:	68 d7 1e 80 00       	push   $0x801ed7
  800a9e:	6a 7c                	push   $0x7c
  800aa0:	68 ec 1e 80 00       	push   $0x801eec
  800aa5:	e8 b5 05 00 00       	call   80105f <_panic>
	assert(r <= PGSIZE);
  800aaa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aaf:	7e 16                	jle    800ac7 <devfile_read+0x65>
  800ab1:	68 f7 1e 80 00       	push   $0x801ef7
  800ab6:	68 d7 1e 80 00       	push   $0x801ed7
  800abb:	6a 7d                	push   $0x7d
  800abd:	68 ec 1e 80 00       	push   $0x801eec
  800ac2:	e8 98 05 00 00       	call   80105f <_panic>
	memmove(buf, &fsipcbuf, r);
  800ac7:	83 ec 04             	sub    $0x4,%esp
  800aca:	50                   	push   %eax
  800acb:	68 00 50 80 00       	push   $0x805000
  800ad0:	ff 75 0c             	pushl  0xc(%ebp)
  800ad3:	e8 76 0d 00 00       	call   80184e <memmove>
	return r;
  800ad8:	83 c4 10             	add    $0x10,%esp
}
  800adb:	89 d8                	mov    %ebx,%eax
  800add:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5d                   	pop    %ebp
  800ae3:	c3                   	ret    

00800ae4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ae4:	55                   	push   %ebp
  800ae5:	89 e5                	mov    %esp,%ebp
  800ae7:	53                   	push   %ebx
  800ae8:	83 ec 20             	sub    $0x20,%esp
  800aeb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800aee:	53                   	push   %ebx
  800aef:	e8 8f 0b 00 00       	call   801683 <strlen>
  800af4:	83 c4 10             	add    $0x10,%esp
  800af7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800afc:	7f 67                	jg     800b65 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afe:	83 ec 0c             	sub    $0xc,%esp
  800b01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b04:	50                   	push   %eax
  800b05:	e8 97 f8 ff ff       	call   8003a1 <fd_alloc>
  800b0a:	83 c4 10             	add    $0x10,%esp
		return r;
  800b0d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b0f:	85 c0                	test   %eax,%eax
  800b11:	78 57                	js     800b6a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b13:	83 ec 08             	sub    $0x8,%esp
  800b16:	53                   	push   %ebx
  800b17:	68 00 50 80 00       	push   $0x805000
  800b1c:	e8 9b 0b 00 00       	call   8016bc <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b21:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b24:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b29:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b31:	e8 f2 fd ff ff       	call   800928 <fsipc>
  800b36:	89 c3                	mov    %eax,%ebx
  800b38:	83 c4 10             	add    $0x10,%esp
  800b3b:	85 c0                	test   %eax,%eax
  800b3d:	79 14                	jns    800b53 <open+0x6f>
		fd_close(fd, 0);
  800b3f:	83 ec 08             	sub    $0x8,%esp
  800b42:	6a 00                	push   $0x0
  800b44:	ff 75 f4             	pushl  -0xc(%ebp)
  800b47:	e8 4d f9 ff ff       	call   800499 <fd_close>
		return r;
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	89 da                	mov    %ebx,%edx
  800b51:	eb 17                	jmp    800b6a <open+0x86>
	}

	return fd2num(fd);
  800b53:	83 ec 0c             	sub    $0xc,%esp
  800b56:	ff 75 f4             	pushl  -0xc(%ebp)
  800b59:	e8 1c f8 ff ff       	call   80037a <fd2num>
  800b5e:	89 c2                	mov    %eax,%edx
  800b60:	83 c4 10             	add    $0x10,%esp
  800b63:	eb 05                	jmp    800b6a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b65:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b6a:	89 d0                	mov    %edx,%eax
  800b6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b6f:	c9                   	leave  
  800b70:	c3                   	ret    

00800b71 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b81:	e8 a2 fd ff ff       	call   800928 <fsipc>
}
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	56                   	push   %esi
  800b8c:	53                   	push   %ebx
  800b8d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	ff 75 08             	pushl  0x8(%ebp)
  800b96:	e8 ef f7 ff ff       	call   80038a <fd2data>
  800b9b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b9d:	83 c4 08             	add    $0x8,%esp
  800ba0:	68 03 1f 80 00       	push   $0x801f03
  800ba5:	53                   	push   %ebx
  800ba6:	e8 11 0b 00 00       	call   8016bc <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bab:	8b 56 04             	mov    0x4(%esi),%edx
  800bae:	89 d0                	mov    %edx,%eax
  800bb0:	2b 06                	sub    (%esi),%eax
  800bb2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bbf:	00 00 00 
	stat->st_dev = &devpipe;
  800bc2:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800bc9:	30 80 00 
	return 0;
}
  800bcc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bd4:	5b                   	pop    %ebx
  800bd5:	5e                   	pop    %esi
  800bd6:	5d                   	pop    %ebp
  800bd7:	c3                   	ret    

00800bd8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800be2:	53                   	push   %ebx
  800be3:	6a 00                	push   $0x0
  800be5:	e8 05 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bea:	89 1c 24             	mov    %ebx,(%esp)
  800bed:	e8 98 f7 ff ff       	call   80038a <fd2data>
  800bf2:	83 c4 08             	add    $0x8,%esp
  800bf5:	50                   	push   %eax
  800bf6:	6a 00                	push   $0x0
  800bf8:	e8 f2 f5 ff ff       	call   8001ef <sys_page_unmap>
}
  800bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 1c             	sub    $0x1c,%esp
  800c0b:	89 c7                	mov    %eax,%edi
  800c0d:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c0f:	a1 04 40 80 00       	mov    0x804004,%eax
  800c14:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c17:	83 ec 0c             	sub    $0xc,%esp
  800c1a:	57                   	push   %edi
  800c1b:	e8 d9 0e 00 00       	call   801af9 <pageref>
  800c20:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c23:	89 34 24             	mov    %esi,(%esp)
  800c26:	e8 ce 0e 00 00       	call   801af9 <pageref>
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c31:	0f 94 c0             	sete   %al
  800c34:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c37:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c3d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c40:	39 cb                	cmp    %ecx,%ebx
  800c42:	74 15                	je     800c59 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c44:	8b 52 58             	mov    0x58(%edx),%edx
  800c47:	50                   	push   %eax
  800c48:	52                   	push   %edx
  800c49:	53                   	push   %ebx
  800c4a:	68 10 1f 80 00       	push   $0x801f10
  800c4f:	e8 e4 04 00 00       	call   801138 <cprintf>
  800c54:	83 c4 10             	add    $0x10,%esp
  800c57:	eb b6                	jmp    800c0f <_pipeisclosed+0xd>
	}
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 28             	sub    $0x28,%esp
  800c6a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c6d:	56                   	push   %esi
  800c6e:	e8 17 f7 ff ff       	call   80038a <fd2data>
  800c73:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7d:	eb 4b                	jmp    800cca <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c7f:	89 da                	mov    %ebx,%edx
  800c81:	89 f0                	mov    %esi,%eax
  800c83:	e8 7a ff ff ff       	call   800c02 <_pipeisclosed>
  800c88:	85 c0                	test   %eax,%eax
  800c8a:	75 48                	jne    800cd4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c8c:	e8 ba f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c91:	8b 43 04             	mov    0x4(%ebx),%eax
  800c94:	8b 0b                	mov    (%ebx),%ecx
  800c96:	8d 51 20             	lea    0x20(%ecx),%edx
  800c99:	39 d0                	cmp    %edx,%eax
  800c9b:	73 e2                	jae    800c7f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca7:	89 c2                	mov    %eax,%edx
  800ca9:	c1 fa 1f             	sar    $0x1f,%edx
  800cac:	89 d1                	mov    %edx,%ecx
  800cae:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb4:	83 e2 1f             	and    $0x1f,%edx
  800cb7:	29 ca                	sub    %ecx,%edx
  800cb9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc1:	83 c0 01             	add    $0x1,%eax
  800cc4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc7:	83 c7 01             	add    $0x1,%edi
  800cca:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ccd:	75 c2                	jne    800c91 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ccf:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd2:	eb 05                	jmp    800cd9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdc:	5b                   	pop    %ebx
  800cdd:	5e                   	pop    %esi
  800cde:	5f                   	pop    %edi
  800cdf:	5d                   	pop    %ebp
  800ce0:	c3                   	ret    

00800ce1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	57                   	push   %edi
  800ce5:	56                   	push   %esi
  800ce6:	53                   	push   %ebx
  800ce7:	83 ec 18             	sub    $0x18,%esp
  800cea:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ced:	57                   	push   %edi
  800cee:	e8 97 f6 ff ff       	call   80038a <fd2data>
  800cf3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cf5:	83 c4 10             	add    $0x10,%esp
  800cf8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cfd:	eb 3d                	jmp    800d3c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	74 04                	je     800d07 <devpipe_read+0x26>
				return i;
  800d03:	89 d8                	mov    %ebx,%eax
  800d05:	eb 44                	jmp    800d4b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d07:	89 f2                	mov    %esi,%edx
  800d09:	89 f8                	mov    %edi,%eax
  800d0b:	e8 f2 fe ff ff       	call   800c02 <_pipeisclosed>
  800d10:	85 c0                	test   %eax,%eax
  800d12:	75 32                	jne    800d46 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d14:	e8 32 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d19:	8b 06                	mov    (%esi),%eax
  800d1b:	3b 46 04             	cmp    0x4(%esi),%eax
  800d1e:	74 df                	je     800cff <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d20:	99                   	cltd   
  800d21:	c1 ea 1b             	shr    $0x1b,%edx
  800d24:	01 d0                	add    %edx,%eax
  800d26:	83 e0 1f             	and    $0x1f,%eax
  800d29:	29 d0                	sub    %edx,%eax
  800d2b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d36:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d39:	83 c3 01             	add    $0x1,%ebx
  800d3c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d3f:	75 d8                	jne    800d19 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d41:	8b 45 10             	mov    0x10(%ebp),%eax
  800d44:	eb 05                	jmp    800d4b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d46:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4e:	5b                   	pop    %ebx
  800d4f:	5e                   	pop    %esi
  800d50:	5f                   	pop    %edi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d5e:	50                   	push   %eax
  800d5f:	e8 3d f6 ff ff       	call   8003a1 <fd_alloc>
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	89 c2                	mov    %eax,%edx
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	0f 88 2c 01 00 00    	js     800e9d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d71:	83 ec 04             	sub    $0x4,%esp
  800d74:	68 07 04 00 00       	push   $0x407
  800d79:	ff 75 f4             	pushl  -0xc(%ebp)
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 e7 f3 ff ff       	call   80016a <sys_page_alloc>
  800d83:	83 c4 10             	add    $0x10,%esp
  800d86:	89 c2                	mov    %eax,%edx
  800d88:	85 c0                	test   %eax,%eax
  800d8a:	0f 88 0d 01 00 00    	js     800e9d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d96:	50                   	push   %eax
  800d97:	e8 05 f6 ff ff       	call   8003a1 <fd_alloc>
  800d9c:	89 c3                	mov    %eax,%ebx
  800d9e:	83 c4 10             	add    $0x10,%esp
  800da1:	85 c0                	test   %eax,%eax
  800da3:	0f 88 e2 00 00 00    	js     800e8b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da9:	83 ec 04             	sub    $0x4,%esp
  800dac:	68 07 04 00 00       	push   $0x407
  800db1:	ff 75 f0             	pushl  -0x10(%ebp)
  800db4:	6a 00                	push   $0x0
  800db6:	e8 af f3 ff ff       	call   80016a <sys_page_alloc>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	0f 88 c3 00 00 00    	js     800e8b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dce:	e8 b7 f5 ff ff       	call   80038a <fd2data>
  800dd3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd5:	83 c4 0c             	add    $0xc,%esp
  800dd8:	68 07 04 00 00       	push   $0x407
  800ddd:	50                   	push   %eax
  800dde:	6a 00                	push   $0x0
  800de0:	e8 85 f3 ff ff       	call   80016a <sys_page_alloc>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 10             	add    $0x10,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	0f 88 89 00 00 00    	js     800e7b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df2:	83 ec 0c             	sub    $0xc,%esp
  800df5:	ff 75 f0             	pushl  -0x10(%ebp)
  800df8:	e8 8d f5 ff ff       	call   80038a <fd2data>
  800dfd:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e04:	50                   	push   %eax
  800e05:	6a 00                	push   $0x0
  800e07:	56                   	push   %esi
  800e08:	6a 00                	push   $0x0
  800e0a:	e8 9e f3 ff ff       	call   8001ad <sys_page_map>
  800e0f:	89 c3                	mov    %eax,%ebx
  800e11:	83 c4 20             	add    $0x20,%esp
  800e14:	85 c0                	test   %eax,%eax
  800e16:	78 55                	js     800e6d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e18:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e1e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e21:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e26:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e2d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e36:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e42:	83 ec 0c             	sub    $0xc,%esp
  800e45:	ff 75 f4             	pushl  -0xc(%ebp)
  800e48:	e8 2d f5 ff ff       	call   80037a <fd2num>
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e52:	83 c4 04             	add    $0x4,%esp
  800e55:	ff 75 f0             	pushl  -0x10(%ebp)
  800e58:	e8 1d f5 ff ff       	call   80037a <fd2num>
  800e5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e60:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6b:	eb 30                	jmp    800e9d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	56                   	push   %esi
  800e71:	6a 00                	push   $0x0
  800e73:	e8 77 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e78:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e81:	6a 00                	push   $0x0
  800e83:	e8 67 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e88:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e8b:	83 ec 08             	sub    $0x8,%esp
  800e8e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e91:	6a 00                	push   $0x0
  800e93:	e8 57 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e98:	83 c4 10             	add    $0x10,%esp
  800e9b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e9d:	89 d0                	mov    %edx,%eax
  800e9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5d                   	pop    %ebp
  800ea5:	c3                   	ret    

00800ea6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800eac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eaf:	50                   	push   %eax
  800eb0:	ff 75 08             	pushl  0x8(%ebp)
  800eb3:	e8 38 f5 ff ff       	call   8003f0 <fd_lookup>
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	85 d2                	test   %edx,%edx
  800ebf:	78 18                	js     800ed9 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ec1:	83 ec 0c             	sub    $0xc,%esp
  800ec4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec7:	e8 be f4 ff ff       	call   80038a <fd2data>
	return _pipeisclosed(fd, p);
  800ecc:	89 c2                	mov    %eax,%edx
  800ece:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed1:	e8 2c fd ff ff       	call   800c02 <_pipeisclosed>
  800ed6:	83 c4 10             	add    $0x10,%esp
}
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eeb:	68 41 1f 80 00       	push   $0x801f41
  800ef0:	ff 75 0c             	pushl  0xc(%ebp)
  800ef3:	e8 c4 07 00 00       	call   8016bc <strcpy>
	return 0;
}
  800ef8:	b8 00 00 00 00       	mov    $0x0,%eax
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	57                   	push   %edi
  800f03:	56                   	push   %esi
  800f04:	53                   	push   %ebx
  800f05:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0b:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f10:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f16:	eb 2e                	jmp    800f46 <devcons_write+0x47>
		m = n - tot;
  800f18:	8b 55 10             	mov    0x10(%ebp),%edx
  800f1b:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f1d:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f22:	83 fa 7f             	cmp    $0x7f,%edx
  800f25:	77 02                	ja     800f29 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f27:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f29:	83 ec 04             	sub    $0x4,%esp
  800f2c:	56                   	push   %esi
  800f2d:	03 45 0c             	add    0xc(%ebp),%eax
  800f30:	50                   	push   %eax
  800f31:	57                   	push   %edi
  800f32:	e8 17 09 00 00       	call   80184e <memmove>
		sys_cputs(buf, m);
  800f37:	83 c4 08             	add    $0x8,%esp
  800f3a:	56                   	push   %esi
  800f3b:	57                   	push   %edi
  800f3c:	e8 6d f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f41:	01 f3                	add    %esi,%ebx
  800f43:	83 c4 10             	add    $0x10,%esp
  800f46:	89 d8                	mov    %ebx,%eax
  800f48:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f4b:	72 cb                	jb     800f18 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f5b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f64:	75 07                	jne    800f6d <devcons_read+0x18>
  800f66:	eb 28                	jmp    800f90 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f68:	e8 de f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f6d:	e8 5a f1 ff ff       	call   8000cc <sys_cgetc>
  800f72:	85 c0                	test   %eax,%eax
  800f74:	74 f2                	je     800f68 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f76:	85 c0                	test   %eax,%eax
  800f78:	78 16                	js     800f90 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f7a:	83 f8 04             	cmp    $0x4,%eax
  800f7d:	74 0c                	je     800f8b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f82:	88 02                	mov    %al,(%edx)
	return 1;
  800f84:	b8 01 00 00 00       	mov    $0x1,%eax
  800f89:	eb 05                	jmp    800f90 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f8b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f90:	c9                   	leave  
  800f91:	c3                   	ret    

00800f92 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f98:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f9e:	6a 01                	push   $0x1
  800fa0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa3:	50                   	push   %eax
  800fa4:	e8 05 f1 ff ff       	call   8000ae <sys_cputs>
  800fa9:	83 c4 10             	add    $0x10,%esp
}
  800fac:	c9                   	leave  
  800fad:	c3                   	ret    

00800fae <getchar>:

int
getchar(void)
{
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fb4:	6a 01                	push   $0x1
  800fb6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb9:	50                   	push   %eax
  800fba:	6a 00                	push   $0x0
  800fbc:	e8 98 f6 ff ff       	call   800659 <read>
	if (r < 0)
  800fc1:	83 c4 10             	add    $0x10,%esp
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	78 0f                	js     800fd7 <getchar+0x29>
		return r;
	if (r < 1)
  800fc8:	85 c0                	test   %eax,%eax
  800fca:	7e 06                	jle    800fd2 <getchar+0x24>
		return -E_EOF;
	return c;
  800fcc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fd0:	eb 05                	jmp    800fd7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fd2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    

00800fd9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe2:	50                   	push   %eax
  800fe3:	ff 75 08             	pushl  0x8(%ebp)
  800fe6:	e8 05 f4 ff ff       	call   8003f0 <fd_lookup>
  800feb:	83 c4 10             	add    $0x10,%esp
  800fee:	85 c0                	test   %eax,%eax
  800ff0:	78 11                	js     801003 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff5:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800ffb:	39 10                	cmp    %edx,(%eax)
  800ffd:	0f 94 c0             	sete   %al
  801000:	0f b6 c0             	movzbl %al,%eax
}
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <opencons>:

int
opencons(void)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100e:	50                   	push   %eax
  80100f:	e8 8d f3 ff ff       	call   8003a1 <fd_alloc>
  801014:	83 c4 10             	add    $0x10,%esp
		return r;
  801017:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 3e                	js     80105b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101d:	83 ec 04             	sub    $0x4,%esp
  801020:	68 07 04 00 00       	push   $0x407
  801025:	ff 75 f4             	pushl  -0xc(%ebp)
  801028:	6a 00                	push   $0x0
  80102a:	e8 3b f1 ff ff       	call   80016a <sys_page_alloc>
  80102f:	83 c4 10             	add    $0x10,%esp
		return r;
  801032:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801034:	85 c0                	test   %eax,%eax
  801036:	78 23                	js     80105b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801038:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80103e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801041:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801043:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801046:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	50                   	push   %eax
  801051:	e8 24 f3 ff ff       	call   80037a <fd2num>
  801056:	89 c2                	mov    %eax,%edx
  801058:	83 c4 10             	add    $0x10,%esp
}
  80105b:	89 d0                	mov    %edx,%eax
  80105d:	c9                   	leave  
  80105e:	c3                   	ret    

0080105f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80105f:	55                   	push   %ebp
  801060:	89 e5                	mov    %esp,%ebp
  801062:	56                   	push   %esi
  801063:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801064:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801067:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80106d:	e8 ba f0 ff ff       	call   80012c <sys_getenvid>
  801072:	83 ec 0c             	sub    $0xc,%esp
  801075:	ff 75 0c             	pushl  0xc(%ebp)
  801078:	ff 75 08             	pushl  0x8(%ebp)
  80107b:	56                   	push   %esi
  80107c:	50                   	push   %eax
  80107d:	68 50 1f 80 00       	push   $0x801f50
  801082:	e8 b1 00 00 00       	call   801138 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801087:	83 c4 18             	add    $0x18,%esp
  80108a:	53                   	push   %ebx
  80108b:	ff 75 10             	pushl  0x10(%ebp)
  80108e:	e8 54 00 00 00       	call   8010e7 <vcprintf>
	cprintf("\n");
  801093:	c7 04 24 0c 1e 80 00 	movl   $0x801e0c,(%esp)
  80109a:	e8 99 00 00 00       	call   801138 <cprintf>
  80109f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010a2:	cc                   	int3   
  8010a3:	eb fd                	jmp    8010a2 <_panic+0x43>

008010a5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 04             	sub    $0x4,%esp
  8010ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010af:	8b 13                	mov    (%ebx),%edx
  8010b1:	8d 42 01             	lea    0x1(%edx),%eax
  8010b4:	89 03                	mov    %eax,(%ebx)
  8010b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010bd:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010c2:	75 1a                	jne    8010de <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010c4:	83 ec 08             	sub    $0x8,%esp
  8010c7:	68 ff 00 00 00       	push   $0xff
  8010cc:	8d 43 08             	lea    0x8(%ebx),%eax
  8010cf:	50                   	push   %eax
  8010d0:	e8 d9 ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010d5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010db:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010de:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f7:	00 00 00 
	b.cnt = 0;
  8010fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801101:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801104:	ff 75 0c             	pushl  0xc(%ebp)
  801107:	ff 75 08             	pushl  0x8(%ebp)
  80110a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	68 a5 10 80 00       	push   $0x8010a5
  801116:	e8 4f 01 00 00       	call   80126a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80111b:	83 c4 08             	add    $0x8,%esp
  80111e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801124:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	e8 7e ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  801130:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80113e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801141:	50                   	push   %eax
  801142:	ff 75 08             	pushl  0x8(%ebp)
  801145:	e8 9d ff ff ff       	call   8010e7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80114a:	c9                   	leave  
  80114b:	c3                   	ret    

0080114c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80114c:	55                   	push   %ebp
  80114d:	89 e5                	mov    %esp,%ebp
  80114f:	57                   	push   %edi
  801150:	56                   	push   %esi
  801151:	53                   	push   %ebx
  801152:	83 ec 1c             	sub    $0x1c,%esp
  801155:	89 c7                	mov    %eax,%edi
  801157:	89 d6                	mov    %edx,%esi
  801159:	8b 45 08             	mov    0x8(%ebp),%eax
  80115c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115f:	89 d1                	mov    %edx,%ecx
  801161:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801164:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801167:	8b 45 10             	mov    0x10(%ebp),%eax
  80116a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80116d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801170:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801177:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80117a:	72 05                	jb     801181 <printnum+0x35>
  80117c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80117f:	77 3e                	ja     8011bf <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801181:	83 ec 0c             	sub    $0xc,%esp
  801184:	ff 75 18             	pushl  0x18(%ebp)
  801187:	83 eb 01             	sub    $0x1,%ebx
  80118a:	53                   	push   %ebx
  80118b:	50                   	push   %eax
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801192:	ff 75 e0             	pushl  -0x20(%ebp)
  801195:	ff 75 dc             	pushl  -0x24(%ebp)
  801198:	ff 75 d8             	pushl  -0x28(%ebp)
  80119b:	e8 a0 09 00 00       	call   801b40 <__udivdi3>
  8011a0:	83 c4 18             	add    $0x18,%esp
  8011a3:	52                   	push   %edx
  8011a4:	50                   	push   %eax
  8011a5:	89 f2                	mov    %esi,%edx
  8011a7:	89 f8                	mov    %edi,%eax
  8011a9:	e8 9e ff ff ff       	call   80114c <printnum>
  8011ae:	83 c4 20             	add    $0x20,%esp
  8011b1:	eb 13                	jmp    8011c6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b3:	83 ec 08             	sub    $0x8,%esp
  8011b6:	56                   	push   %esi
  8011b7:	ff 75 18             	pushl  0x18(%ebp)
  8011ba:	ff d7                	call   *%edi
  8011bc:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011bf:	83 eb 01             	sub    $0x1,%ebx
  8011c2:	85 db                	test   %ebx,%ebx
  8011c4:	7f ed                	jg     8011b3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c6:	83 ec 08             	sub    $0x8,%esp
  8011c9:	56                   	push   %esi
  8011ca:	83 ec 04             	sub    $0x4,%esp
  8011cd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d9:	e8 92 0a 00 00       	call   801c70 <__umoddi3>
  8011de:	83 c4 14             	add    $0x14,%esp
  8011e1:	0f be 80 73 1f 80 00 	movsbl 0x801f73(%eax),%eax
  8011e8:	50                   	push   %eax
  8011e9:	ff d7                	call   *%edi
  8011eb:	83 c4 10             	add    $0x10,%esp
}
  8011ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f1:	5b                   	pop    %ebx
  8011f2:	5e                   	pop    %esi
  8011f3:	5f                   	pop    %edi
  8011f4:	5d                   	pop    %ebp
  8011f5:	c3                   	ret    

008011f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011f6:	55                   	push   %ebp
  8011f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f9:	83 fa 01             	cmp    $0x1,%edx
  8011fc:	7e 0e                	jle    80120c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011fe:	8b 10                	mov    (%eax),%edx
  801200:	8d 4a 08             	lea    0x8(%edx),%ecx
  801203:	89 08                	mov    %ecx,(%eax)
  801205:	8b 02                	mov    (%edx),%eax
  801207:	8b 52 04             	mov    0x4(%edx),%edx
  80120a:	eb 22                	jmp    80122e <getuint+0x38>
	else if (lflag)
  80120c:	85 d2                	test   %edx,%edx
  80120e:	74 10                	je     801220 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801210:	8b 10                	mov    (%eax),%edx
  801212:	8d 4a 04             	lea    0x4(%edx),%ecx
  801215:	89 08                	mov    %ecx,(%eax)
  801217:	8b 02                	mov    (%edx),%eax
  801219:	ba 00 00 00 00       	mov    $0x0,%edx
  80121e:	eb 0e                	jmp    80122e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801220:	8b 10                	mov    (%eax),%edx
  801222:	8d 4a 04             	lea    0x4(%edx),%ecx
  801225:	89 08                	mov    %ecx,(%eax)
  801227:	8b 02                	mov    (%edx),%eax
  801229:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801236:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80123a:	8b 10                	mov    (%eax),%edx
  80123c:	3b 50 04             	cmp    0x4(%eax),%edx
  80123f:	73 0a                	jae    80124b <sprintputch+0x1b>
		*b->buf++ = ch;
  801241:	8d 4a 01             	lea    0x1(%edx),%ecx
  801244:	89 08                	mov    %ecx,(%eax)
  801246:	8b 45 08             	mov    0x8(%ebp),%eax
  801249:	88 02                	mov    %al,(%edx)
}
  80124b:	5d                   	pop    %ebp
  80124c:	c3                   	ret    

0080124d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80124d:	55                   	push   %ebp
  80124e:	89 e5                	mov    %esp,%ebp
  801250:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801253:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801256:	50                   	push   %eax
  801257:	ff 75 10             	pushl  0x10(%ebp)
  80125a:	ff 75 0c             	pushl  0xc(%ebp)
  80125d:	ff 75 08             	pushl  0x8(%ebp)
  801260:	e8 05 00 00 00       	call   80126a <vprintfmt>
	va_end(ap);
  801265:	83 c4 10             	add    $0x10,%esp
}
  801268:	c9                   	leave  
  801269:	c3                   	ret    

0080126a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	57                   	push   %edi
  80126e:	56                   	push   %esi
  80126f:	53                   	push   %ebx
  801270:	83 ec 2c             	sub    $0x2c,%esp
  801273:	8b 75 08             	mov    0x8(%ebp),%esi
  801276:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801279:	8b 7d 10             	mov    0x10(%ebp),%edi
  80127c:	eb 12                	jmp    801290 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80127e:	85 c0                	test   %eax,%eax
  801280:	0f 84 8d 03 00 00    	je     801613 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  801286:	83 ec 08             	sub    $0x8,%esp
  801289:	53                   	push   %ebx
  80128a:	50                   	push   %eax
  80128b:	ff d6                	call   *%esi
  80128d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801290:	83 c7 01             	add    $0x1,%edi
  801293:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801297:	83 f8 25             	cmp    $0x25,%eax
  80129a:	75 e2                	jne    80127e <vprintfmt+0x14>
  80129c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012a0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ba:	eb 07                	jmp    8012c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012bf:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c3:	8d 47 01             	lea    0x1(%edi),%eax
  8012c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c9:	0f b6 07             	movzbl (%edi),%eax
  8012cc:	0f b6 c8             	movzbl %al,%ecx
  8012cf:	83 e8 23             	sub    $0x23,%eax
  8012d2:	3c 55                	cmp    $0x55,%al
  8012d4:	0f 87 1e 03 00 00    	ja     8015f8 <vprintfmt+0x38e>
  8012da:	0f b6 c0             	movzbl %al,%eax
  8012dd:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012eb:	eb d6                	jmp    8012c3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012fb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012ff:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801302:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801305:	83 fa 09             	cmp    $0x9,%edx
  801308:	77 38                	ja     801342 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80130a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80130d:	eb e9                	jmp    8012f8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80130f:	8b 45 14             	mov    0x14(%ebp),%eax
  801312:	8d 48 04             	lea    0x4(%eax),%ecx
  801315:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801318:	8b 00                	mov    (%eax),%eax
  80131a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801320:	eb 26                	jmp    801348 <vprintfmt+0xde>
  801322:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801325:	89 c8                	mov    %ecx,%eax
  801327:	c1 f8 1f             	sar    $0x1f,%eax
  80132a:	f7 d0                	not    %eax
  80132c:	21 c1                	and    %eax,%ecx
  80132e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801334:	eb 8d                	jmp    8012c3 <vprintfmt+0x59>
  801336:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801339:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801340:	eb 81                	jmp    8012c3 <vprintfmt+0x59>
  801342:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801345:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801348:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80134c:	0f 89 71 ff ff ff    	jns    8012c3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801352:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801355:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801358:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80135f:	e9 5f ff ff ff       	jmp    8012c3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801364:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80136a:	e9 54 ff ff ff       	jmp    8012c3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80136f:	8b 45 14             	mov    0x14(%ebp),%eax
  801372:	8d 50 04             	lea    0x4(%eax),%edx
  801375:	89 55 14             	mov    %edx,0x14(%ebp)
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	53                   	push   %ebx
  80137c:	ff 30                	pushl  (%eax)
  80137e:	ff d6                	call   *%esi
			break;
  801380:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801383:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801386:	e9 05 ff ff ff       	jmp    801290 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80138b:	8b 45 14             	mov    0x14(%ebp),%eax
  80138e:	8d 50 04             	lea    0x4(%eax),%edx
  801391:	89 55 14             	mov    %edx,0x14(%ebp)
  801394:	8b 00                	mov    (%eax),%eax
  801396:	99                   	cltd   
  801397:	31 d0                	xor    %edx,%eax
  801399:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80139b:	83 f8 0f             	cmp    $0xf,%eax
  80139e:	7f 0b                	jg     8013ab <vprintfmt+0x141>
  8013a0:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013a7:	85 d2                	test   %edx,%edx
  8013a9:	75 18                	jne    8013c3 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8013ab:	50                   	push   %eax
  8013ac:	68 8b 1f 80 00       	push   $0x801f8b
  8013b1:	53                   	push   %ebx
  8013b2:	56                   	push   %esi
  8013b3:	e8 95 fe ff ff       	call   80124d <printfmt>
  8013b8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013be:	e9 cd fe ff ff       	jmp    801290 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013c3:	52                   	push   %edx
  8013c4:	68 e9 1e 80 00       	push   $0x801ee9
  8013c9:	53                   	push   %ebx
  8013ca:	56                   	push   %esi
  8013cb:	e8 7d fe ff ff       	call   80124d <printfmt>
  8013d0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d6:	e9 b5 fe ff ff       	jmp    801290 <vprintfmt+0x26>
  8013db:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013e1:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e7:	8d 50 04             	lea    0x4(%eax),%edx
  8013ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ed:	8b 38                	mov    (%eax),%edi
  8013ef:	85 ff                	test   %edi,%edi
  8013f1:	75 05                	jne    8013f8 <vprintfmt+0x18e>
				p = "(null)";
  8013f3:	bf 84 1f 80 00       	mov    $0x801f84,%edi
			if (width > 0 && padc != '-')
  8013f8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013fc:	0f 84 91 00 00 00    	je     801493 <vprintfmt+0x229>
  801402:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801406:	0f 8e 95 00 00 00    	jle    8014a1 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	51                   	push   %ecx
  801410:	57                   	push   %edi
  801411:	e8 85 02 00 00       	call   80169b <strnlen>
  801416:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801419:	29 c1                	sub    %eax,%ecx
  80141b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80141e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801421:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801425:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801428:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80142b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80142d:	eb 0f                	jmp    80143e <vprintfmt+0x1d4>
					putch(padc, putdat);
  80142f:	83 ec 08             	sub    $0x8,%esp
  801432:	53                   	push   %ebx
  801433:	ff 75 e0             	pushl  -0x20(%ebp)
  801436:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801438:	83 ef 01             	sub    $0x1,%edi
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 ff                	test   %edi,%edi
  801440:	7f ed                	jg     80142f <vprintfmt+0x1c5>
  801442:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801445:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801448:	89 c8                	mov    %ecx,%eax
  80144a:	c1 f8 1f             	sar    $0x1f,%eax
  80144d:	f7 d0                	not    %eax
  80144f:	21 c8                	and    %ecx,%eax
  801451:	29 c1                	sub    %eax,%ecx
  801453:	89 75 08             	mov    %esi,0x8(%ebp)
  801456:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801459:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80145c:	89 cb                	mov    %ecx,%ebx
  80145e:	eb 4d                	jmp    8014ad <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801460:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801464:	74 1b                	je     801481 <vprintfmt+0x217>
  801466:	0f be c0             	movsbl %al,%eax
  801469:	83 e8 20             	sub    $0x20,%eax
  80146c:	83 f8 5e             	cmp    $0x5e,%eax
  80146f:	76 10                	jbe    801481 <vprintfmt+0x217>
					putch('?', putdat);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	6a 3f                	push   $0x3f
  801479:	ff 55 08             	call   *0x8(%ebp)
  80147c:	83 c4 10             	add    $0x10,%esp
  80147f:	eb 0d                	jmp    80148e <vprintfmt+0x224>
				else
					putch(ch, putdat);
  801481:	83 ec 08             	sub    $0x8,%esp
  801484:	ff 75 0c             	pushl  0xc(%ebp)
  801487:	52                   	push   %edx
  801488:	ff 55 08             	call   *0x8(%ebp)
  80148b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80148e:	83 eb 01             	sub    $0x1,%ebx
  801491:	eb 1a                	jmp    8014ad <vprintfmt+0x243>
  801493:	89 75 08             	mov    %esi,0x8(%ebp)
  801496:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801499:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80149c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149f:	eb 0c                	jmp    8014ad <vprintfmt+0x243>
  8014a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8014a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014ad:	83 c7 01             	add    $0x1,%edi
  8014b0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014b4:	0f be d0             	movsbl %al,%edx
  8014b7:	85 d2                	test   %edx,%edx
  8014b9:	74 23                	je     8014de <vprintfmt+0x274>
  8014bb:	85 f6                	test   %esi,%esi
  8014bd:	78 a1                	js     801460 <vprintfmt+0x1f6>
  8014bf:	83 ee 01             	sub    $0x1,%esi
  8014c2:	79 9c                	jns    801460 <vprintfmt+0x1f6>
  8014c4:	89 df                	mov    %ebx,%edi
  8014c6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014cc:	eb 18                	jmp    8014e6 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ce:	83 ec 08             	sub    $0x8,%esp
  8014d1:	53                   	push   %ebx
  8014d2:	6a 20                	push   $0x20
  8014d4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014d6:	83 ef 01             	sub    $0x1,%edi
  8014d9:	83 c4 10             	add    $0x10,%esp
  8014dc:	eb 08                	jmp    8014e6 <vprintfmt+0x27c>
  8014de:	89 df                	mov    %ebx,%edi
  8014e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e6:	85 ff                	test   %edi,%edi
  8014e8:	7f e4                	jg     8014ce <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014ed:	e9 9e fd ff ff       	jmp    801290 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014f2:	83 fa 01             	cmp    $0x1,%edx
  8014f5:	7e 16                	jle    80150d <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fa:	8d 50 08             	lea    0x8(%eax),%edx
  8014fd:	89 55 14             	mov    %edx,0x14(%ebp)
  801500:	8b 50 04             	mov    0x4(%eax),%edx
  801503:	8b 00                	mov    (%eax),%eax
  801505:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801508:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80150b:	eb 32                	jmp    80153f <vprintfmt+0x2d5>
	else if (lflag)
  80150d:	85 d2                	test   %edx,%edx
  80150f:	74 18                	je     801529 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  801511:	8b 45 14             	mov    0x14(%ebp),%eax
  801514:	8d 50 04             	lea    0x4(%eax),%edx
  801517:	89 55 14             	mov    %edx,0x14(%ebp)
  80151a:	8b 00                	mov    (%eax),%eax
  80151c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151f:	89 c1                	mov    %eax,%ecx
  801521:	c1 f9 1f             	sar    $0x1f,%ecx
  801524:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801527:	eb 16                	jmp    80153f <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801529:	8b 45 14             	mov    0x14(%ebp),%eax
  80152c:	8d 50 04             	lea    0x4(%eax),%edx
  80152f:	89 55 14             	mov    %edx,0x14(%ebp)
  801532:	8b 00                	mov    (%eax),%eax
  801534:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801537:	89 c1                	mov    %eax,%ecx
  801539:	c1 f9 1f             	sar    $0x1f,%ecx
  80153c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80153f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801542:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801545:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80154a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80154e:	79 74                	jns    8015c4 <vprintfmt+0x35a>
				putch('-', putdat);
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	53                   	push   %ebx
  801554:	6a 2d                	push   $0x2d
  801556:	ff d6                	call   *%esi
				num = -(long long) num;
  801558:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80155b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80155e:	f7 d8                	neg    %eax
  801560:	83 d2 00             	adc    $0x0,%edx
  801563:	f7 da                	neg    %edx
  801565:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801568:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80156d:	eb 55                	jmp    8015c4 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80156f:	8d 45 14             	lea    0x14(%ebp),%eax
  801572:	e8 7f fc ff ff       	call   8011f6 <getuint>
			base = 10;
  801577:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80157c:	eb 46                	jmp    8015c4 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80157e:	8d 45 14             	lea    0x14(%ebp),%eax
  801581:	e8 70 fc ff ff       	call   8011f6 <getuint>
			base = 8;
  801586:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80158b:	eb 37                	jmp    8015c4 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 30                	push   $0x30
  801593:	ff d6                	call   *%esi
			putch('x', putdat);
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	6a 78                	push   $0x78
  80159b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80159d:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a0:	8d 50 04             	lea    0x4(%eax),%edx
  8015a3:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015a6:	8b 00                	mov    (%eax),%eax
  8015a8:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015ad:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015b0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015b5:	eb 0d                	jmp    8015c4 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ba:	e8 37 fc ff ff       	call   8011f6 <getuint>
			base = 16;
  8015bf:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015c4:	83 ec 0c             	sub    $0xc,%esp
  8015c7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015cb:	57                   	push   %edi
  8015cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8015cf:	51                   	push   %ecx
  8015d0:	52                   	push   %edx
  8015d1:	50                   	push   %eax
  8015d2:	89 da                	mov    %ebx,%edx
  8015d4:	89 f0                	mov    %esi,%eax
  8015d6:	e8 71 fb ff ff       	call   80114c <printnum>
			break;
  8015db:	83 c4 20             	add    $0x20,%esp
  8015de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015e1:	e9 aa fc ff ff       	jmp    801290 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	53                   	push   %ebx
  8015ea:	51                   	push   %ecx
  8015eb:	ff d6                	call   *%esi
			break;
  8015ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015f3:	e9 98 fc ff ff       	jmp    801290 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	53                   	push   %ebx
  8015fc:	6a 25                	push   $0x25
  8015fe:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	eb 03                	jmp    801608 <vprintfmt+0x39e>
  801605:	83 ef 01             	sub    $0x1,%edi
  801608:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80160c:	75 f7                	jne    801605 <vprintfmt+0x39b>
  80160e:	e9 7d fc ff ff       	jmp    801290 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801613:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801616:	5b                   	pop    %ebx
  801617:	5e                   	pop    %esi
  801618:	5f                   	pop    %edi
  801619:	5d                   	pop    %ebp
  80161a:	c3                   	ret    

0080161b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 18             	sub    $0x18,%esp
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801627:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80162a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80162e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801631:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801638:	85 c0                	test   %eax,%eax
  80163a:	74 26                	je     801662 <vsnprintf+0x47>
  80163c:	85 d2                	test   %edx,%edx
  80163e:	7e 22                	jle    801662 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801640:	ff 75 14             	pushl  0x14(%ebp)
  801643:	ff 75 10             	pushl  0x10(%ebp)
  801646:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	68 30 12 80 00       	push   $0x801230
  80164f:	e8 16 fc ff ff       	call   80126a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801654:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801657:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80165a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	eb 05                	jmp    801667 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801662:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801667:	c9                   	leave  
  801668:	c3                   	ret    

00801669 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80166f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801672:	50                   	push   %eax
  801673:	ff 75 10             	pushl  0x10(%ebp)
  801676:	ff 75 0c             	pushl  0xc(%ebp)
  801679:	ff 75 08             	pushl  0x8(%ebp)
  80167c:	e8 9a ff ff ff       	call   80161b <vsnprintf>
	va_end(ap);

	return rc;
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801689:	b8 00 00 00 00       	mov    $0x0,%eax
  80168e:	eb 03                	jmp    801693 <strlen+0x10>
		n++;
  801690:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801693:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801697:	75 f7                	jne    801690 <strlen+0xd>
		n++;
	return n;
}
  801699:	5d                   	pop    %ebp
  80169a:	c3                   	ret    

0080169b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80169b:	55                   	push   %ebp
  80169c:	89 e5                	mov    %esp,%ebp
  80169e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a1:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a9:	eb 03                	jmp    8016ae <strnlen+0x13>
		n++;
  8016ab:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ae:	39 c2                	cmp    %eax,%edx
  8016b0:	74 08                	je     8016ba <strnlen+0x1f>
  8016b2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016b6:	75 f3                	jne    8016ab <strnlen+0x10>
  8016b8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016c6:	89 c2                	mov    %eax,%edx
  8016c8:	83 c2 01             	add    $0x1,%edx
  8016cb:	83 c1 01             	add    $0x1,%ecx
  8016ce:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016d2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016d5:	84 db                	test   %bl,%bl
  8016d7:	75 ef                	jne    8016c8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d9:	5b                   	pop    %ebx
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	53                   	push   %ebx
  8016e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016e3:	53                   	push   %ebx
  8016e4:	e8 9a ff ff ff       	call   801683 <strlen>
  8016e9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016ec:	ff 75 0c             	pushl  0xc(%ebp)
  8016ef:	01 d8                	add    %ebx,%eax
  8016f1:	50                   	push   %eax
  8016f2:	e8 c5 ff ff ff       	call   8016bc <strcpy>
	return dst;
}
  8016f7:	89 d8                	mov    %ebx,%eax
  8016f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fc:	c9                   	leave  
  8016fd:	c3                   	ret    

008016fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	56                   	push   %esi
  801702:	53                   	push   %ebx
  801703:	8b 75 08             	mov    0x8(%ebp),%esi
  801706:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801709:	89 f3                	mov    %esi,%ebx
  80170b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170e:	89 f2                	mov    %esi,%edx
  801710:	eb 0f                	jmp    801721 <strncpy+0x23>
		*dst++ = *src;
  801712:	83 c2 01             	add    $0x1,%edx
  801715:	0f b6 01             	movzbl (%ecx),%eax
  801718:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80171b:	80 39 01             	cmpb   $0x1,(%ecx)
  80171e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801721:	39 da                	cmp    %ebx,%edx
  801723:	75 ed                	jne    801712 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801725:	89 f0                	mov    %esi,%eax
  801727:	5b                   	pop    %ebx
  801728:	5e                   	pop    %esi
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	56                   	push   %esi
  80172f:	53                   	push   %ebx
  801730:	8b 75 08             	mov    0x8(%ebp),%esi
  801733:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801736:	8b 55 10             	mov    0x10(%ebp),%edx
  801739:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80173b:	85 d2                	test   %edx,%edx
  80173d:	74 21                	je     801760 <strlcpy+0x35>
  80173f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801743:	89 f2                	mov    %esi,%edx
  801745:	eb 09                	jmp    801750 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801747:	83 c2 01             	add    $0x1,%edx
  80174a:	83 c1 01             	add    $0x1,%ecx
  80174d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801750:	39 c2                	cmp    %eax,%edx
  801752:	74 09                	je     80175d <strlcpy+0x32>
  801754:	0f b6 19             	movzbl (%ecx),%ebx
  801757:	84 db                	test   %bl,%bl
  801759:	75 ec                	jne    801747 <strlcpy+0x1c>
  80175b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80175d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801760:	29 f0                	sub    %esi,%eax
}
  801762:	5b                   	pop    %ebx
  801763:	5e                   	pop    %esi
  801764:	5d                   	pop    %ebp
  801765:	c3                   	ret    

00801766 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801766:	55                   	push   %ebp
  801767:	89 e5                	mov    %esp,%ebp
  801769:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176f:	eb 06                	jmp    801777 <strcmp+0x11>
		p++, q++;
  801771:	83 c1 01             	add    $0x1,%ecx
  801774:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801777:	0f b6 01             	movzbl (%ecx),%eax
  80177a:	84 c0                	test   %al,%al
  80177c:	74 04                	je     801782 <strcmp+0x1c>
  80177e:	3a 02                	cmp    (%edx),%al
  801780:	74 ef                	je     801771 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801782:	0f b6 c0             	movzbl %al,%eax
  801785:	0f b6 12             	movzbl (%edx),%edx
  801788:	29 d0                	sub    %edx,%eax
}
  80178a:	5d                   	pop    %ebp
  80178b:	c3                   	ret    

0080178c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178c:	55                   	push   %ebp
  80178d:	89 e5                	mov    %esp,%ebp
  80178f:	53                   	push   %ebx
  801790:	8b 45 08             	mov    0x8(%ebp),%eax
  801793:	8b 55 0c             	mov    0xc(%ebp),%edx
  801796:	89 c3                	mov    %eax,%ebx
  801798:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80179b:	eb 06                	jmp    8017a3 <strncmp+0x17>
		n--, p++, q++;
  80179d:	83 c0 01             	add    $0x1,%eax
  8017a0:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017a3:	39 d8                	cmp    %ebx,%eax
  8017a5:	74 15                	je     8017bc <strncmp+0x30>
  8017a7:	0f b6 08             	movzbl (%eax),%ecx
  8017aa:	84 c9                	test   %cl,%cl
  8017ac:	74 04                	je     8017b2 <strncmp+0x26>
  8017ae:	3a 0a                	cmp    (%edx),%cl
  8017b0:	74 eb                	je     80179d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b2:	0f b6 00             	movzbl (%eax),%eax
  8017b5:	0f b6 12             	movzbl (%edx),%edx
  8017b8:	29 d0                	sub    %edx,%eax
  8017ba:	eb 05                	jmp    8017c1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017bc:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017c1:	5b                   	pop    %ebx
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    

008017c4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c4:	55                   	push   %ebp
  8017c5:	89 e5                	mov    %esp,%ebp
  8017c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ca:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ce:	eb 07                	jmp    8017d7 <strchr+0x13>
		if (*s == c)
  8017d0:	38 ca                	cmp    %cl,%dl
  8017d2:	74 0f                	je     8017e3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017d4:	83 c0 01             	add    $0x1,%eax
  8017d7:	0f b6 10             	movzbl (%eax),%edx
  8017da:	84 d2                	test   %dl,%dl
  8017dc:	75 f2                	jne    8017d0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ef:	eb 03                	jmp    8017f4 <strfind+0xf>
  8017f1:	83 c0 01             	add    $0x1,%eax
  8017f4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f7:	84 d2                	test   %dl,%dl
  8017f9:	74 04                	je     8017ff <strfind+0x1a>
  8017fb:	38 ca                	cmp    %cl,%dl
  8017fd:	75 f2                	jne    8017f1 <strfind+0xc>
			break;
	return (char *) s;
}
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	57                   	push   %edi
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  80180d:	85 c9                	test   %ecx,%ecx
  80180f:	74 36                	je     801847 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801811:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801817:	75 28                	jne    801841 <memset+0x40>
  801819:	f6 c1 03             	test   $0x3,%cl
  80181c:	75 23                	jne    801841 <memset+0x40>
		c &= 0xFF;
  80181e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801822:	89 d3                	mov    %edx,%ebx
  801824:	c1 e3 08             	shl    $0x8,%ebx
  801827:	89 d6                	mov    %edx,%esi
  801829:	c1 e6 18             	shl    $0x18,%esi
  80182c:	89 d0                	mov    %edx,%eax
  80182e:	c1 e0 10             	shl    $0x10,%eax
  801831:	09 f0                	or     %esi,%eax
  801833:	09 c2                	or     %eax,%edx
  801835:	89 d0                	mov    %edx,%eax
  801837:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801839:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80183c:	fc                   	cld    
  80183d:	f3 ab                	rep stos %eax,%es:(%edi)
  80183f:	eb 06                	jmp    801847 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801841:	8b 45 0c             	mov    0xc(%ebp),%eax
  801844:	fc                   	cld    
  801845:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801847:	89 f8                	mov    %edi,%eax
  801849:	5b                   	pop    %ebx
  80184a:	5e                   	pop    %esi
  80184b:	5f                   	pop    %edi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	57                   	push   %edi
  801852:	56                   	push   %esi
  801853:	8b 45 08             	mov    0x8(%ebp),%eax
  801856:	8b 75 0c             	mov    0xc(%ebp),%esi
  801859:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80185c:	39 c6                	cmp    %eax,%esi
  80185e:	73 35                	jae    801895 <memmove+0x47>
  801860:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801863:	39 d0                	cmp    %edx,%eax
  801865:	73 2e                	jae    801895 <memmove+0x47>
		s += n;
		d += n;
  801867:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80186a:	89 d6                	mov    %edx,%esi
  80186c:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80186e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801874:	75 13                	jne    801889 <memmove+0x3b>
  801876:	f6 c1 03             	test   $0x3,%cl
  801879:	75 0e                	jne    801889 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80187b:	83 ef 04             	sub    $0x4,%edi
  80187e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801881:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801884:	fd                   	std    
  801885:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801887:	eb 09                	jmp    801892 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801889:	83 ef 01             	sub    $0x1,%edi
  80188c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80188f:	fd                   	std    
  801890:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801892:	fc                   	cld    
  801893:	eb 1d                	jmp    8018b2 <memmove+0x64>
  801895:	89 f2                	mov    %esi,%edx
  801897:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801899:	f6 c2 03             	test   $0x3,%dl
  80189c:	75 0f                	jne    8018ad <memmove+0x5f>
  80189e:	f6 c1 03             	test   $0x3,%cl
  8018a1:	75 0a                	jne    8018ad <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018a3:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018a6:	89 c7                	mov    %eax,%edi
  8018a8:	fc                   	cld    
  8018a9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ab:	eb 05                	jmp    8018b2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ad:	89 c7                	mov    %eax,%edi
  8018af:	fc                   	cld    
  8018b0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b2:	5e                   	pop    %esi
  8018b3:	5f                   	pop    %edi
  8018b4:	5d                   	pop    %ebp
  8018b5:	c3                   	ret    

008018b6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b9:	ff 75 10             	pushl  0x10(%ebp)
  8018bc:	ff 75 0c             	pushl  0xc(%ebp)
  8018bf:	ff 75 08             	pushl  0x8(%ebp)
  8018c2:	e8 87 ff ff ff       	call   80184e <memmove>
}
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	56                   	push   %esi
  8018cd:	53                   	push   %ebx
  8018ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d4:	89 c6                	mov    %eax,%esi
  8018d6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d9:	eb 1a                	jmp    8018f5 <memcmp+0x2c>
		if (*s1 != *s2)
  8018db:	0f b6 08             	movzbl (%eax),%ecx
  8018de:	0f b6 1a             	movzbl (%edx),%ebx
  8018e1:	38 d9                	cmp    %bl,%cl
  8018e3:	74 0a                	je     8018ef <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018e5:	0f b6 c1             	movzbl %cl,%eax
  8018e8:	0f b6 db             	movzbl %bl,%ebx
  8018eb:	29 d8                	sub    %ebx,%eax
  8018ed:	eb 0f                	jmp    8018fe <memcmp+0x35>
		s1++, s2++;
  8018ef:	83 c0 01             	add    $0x1,%eax
  8018f2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f5:	39 f0                	cmp    %esi,%eax
  8018f7:	75 e2                	jne    8018db <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018fe:	5b                   	pop    %ebx
  8018ff:	5e                   	pop    %esi
  801900:	5d                   	pop    %ebp
  801901:	c3                   	ret    

00801902 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	8b 45 08             	mov    0x8(%ebp),%eax
  801908:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80190b:	89 c2                	mov    %eax,%edx
  80190d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801910:	eb 07                	jmp    801919 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801912:	38 08                	cmp    %cl,(%eax)
  801914:	74 07                	je     80191d <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801916:	83 c0 01             	add    $0x1,%eax
  801919:	39 d0                	cmp    %edx,%eax
  80191b:	72 f5                	jb     801912 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80191d:	5d                   	pop    %ebp
  80191e:	c3                   	ret    

0080191f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80191f:	55                   	push   %ebp
  801920:	89 e5                	mov    %esp,%ebp
  801922:	57                   	push   %edi
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801928:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80192b:	eb 03                	jmp    801930 <strtol+0x11>
		s++;
  80192d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801930:	0f b6 01             	movzbl (%ecx),%eax
  801933:	3c 09                	cmp    $0x9,%al
  801935:	74 f6                	je     80192d <strtol+0xe>
  801937:	3c 20                	cmp    $0x20,%al
  801939:	74 f2                	je     80192d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80193b:	3c 2b                	cmp    $0x2b,%al
  80193d:	75 0a                	jne    801949 <strtol+0x2a>
		s++;
  80193f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801942:	bf 00 00 00 00       	mov    $0x0,%edi
  801947:	eb 10                	jmp    801959 <strtol+0x3a>
  801949:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80194e:	3c 2d                	cmp    $0x2d,%al
  801950:	75 07                	jne    801959 <strtol+0x3a>
		s++, neg = 1;
  801952:	8d 49 01             	lea    0x1(%ecx),%ecx
  801955:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801959:	85 db                	test   %ebx,%ebx
  80195b:	0f 94 c0             	sete   %al
  80195e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801964:	75 19                	jne    80197f <strtol+0x60>
  801966:	80 39 30             	cmpb   $0x30,(%ecx)
  801969:	75 14                	jne    80197f <strtol+0x60>
  80196b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80196f:	0f 85 8a 00 00 00    	jne    8019ff <strtol+0xe0>
		s += 2, base = 16;
  801975:	83 c1 02             	add    $0x2,%ecx
  801978:	bb 10 00 00 00       	mov    $0x10,%ebx
  80197d:	eb 16                	jmp    801995 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80197f:	84 c0                	test   %al,%al
  801981:	74 12                	je     801995 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801983:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801988:	80 39 30             	cmpb   $0x30,(%ecx)
  80198b:	75 08                	jne    801995 <strtol+0x76>
		s++, base = 8;
  80198d:	83 c1 01             	add    $0x1,%ecx
  801990:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
  80199a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80199d:	0f b6 11             	movzbl (%ecx),%edx
  8019a0:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019a3:	89 f3                	mov    %esi,%ebx
  8019a5:	80 fb 09             	cmp    $0x9,%bl
  8019a8:	77 08                	ja     8019b2 <strtol+0x93>
			dig = *s - '0';
  8019aa:	0f be d2             	movsbl %dl,%edx
  8019ad:	83 ea 30             	sub    $0x30,%edx
  8019b0:	eb 22                	jmp    8019d4 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019b2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019b5:	89 f3                	mov    %esi,%ebx
  8019b7:	80 fb 19             	cmp    $0x19,%bl
  8019ba:	77 08                	ja     8019c4 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019bc:	0f be d2             	movsbl %dl,%edx
  8019bf:	83 ea 57             	sub    $0x57,%edx
  8019c2:	eb 10                	jmp    8019d4 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019c4:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c7:	89 f3                	mov    %esi,%ebx
  8019c9:	80 fb 19             	cmp    $0x19,%bl
  8019cc:	77 16                	ja     8019e4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019ce:	0f be d2             	movsbl %dl,%edx
  8019d1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019d4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d7:	7d 0f                	jge    8019e8 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019d9:	83 c1 01             	add    $0x1,%ecx
  8019dc:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019e2:	eb b9                	jmp    80199d <strtol+0x7e>
  8019e4:	89 c2                	mov    %eax,%edx
  8019e6:	eb 02                	jmp    8019ea <strtol+0xcb>
  8019e8:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019ea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ee:	74 05                	je     8019f5 <strtol+0xd6>
		*endptr = (char *) s;
  8019f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019f5:	85 ff                	test   %edi,%edi
  8019f7:	74 0c                	je     801a05 <strtol+0xe6>
  8019f9:	89 d0                	mov    %edx,%eax
  8019fb:	f7 d8                	neg    %eax
  8019fd:	eb 06                	jmp    801a05 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ff:	84 c0                	test   %al,%al
  801a01:	75 8a                	jne    80198d <strtol+0x6e>
  801a03:	eb 90                	jmp    801995 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a05:	5b                   	pop    %ebx
  801a06:	5e                   	pop    %esi
  801a07:	5f                   	pop    %edi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    

00801a0a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
  801a0f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a15:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a18:	85 f6                	test   %esi,%esi
  801a1a:	74 06                	je     801a22 <ipc_recv+0x18>
  801a1c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a22:	85 db                	test   %ebx,%ebx
  801a24:	74 06                	je     801a2c <ipc_recv+0x22>
  801a26:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a2c:	83 f8 01             	cmp    $0x1,%eax
  801a2f:	19 d2                	sbb    %edx,%edx
  801a31:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	50                   	push   %eax
  801a37:	e8 de e8 ff ff       	call   80031a <sys_ipc_recv>
  801a3c:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 d2                	test   %edx,%edx
  801a43:	75 24                	jne    801a69 <ipc_recv+0x5f>
	if (from_env_store)
  801a45:	85 f6                	test   %esi,%esi
  801a47:	74 0a                	je     801a53 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a49:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4e:	8b 40 70             	mov    0x70(%eax),%eax
  801a51:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a53:	85 db                	test   %ebx,%ebx
  801a55:	74 0a                	je     801a61 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a57:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5c:	8b 40 74             	mov    0x74(%eax),%eax
  801a5f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a61:	a1 04 40 80 00       	mov    0x804004,%eax
  801a66:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5e                   	pop    %esi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 0c             	sub    $0xc,%esp
  801a79:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a82:	83 fb 01             	cmp    $0x1,%ebx
  801a85:	19 c0                	sbb    %eax,%eax
  801a87:	09 c3                	or     %eax,%ebx
  801a89:	eb 1c                	jmp    801aa7 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a8b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8e:	74 12                	je     801aa2 <ipc_send+0x32>
  801a90:	50                   	push   %eax
  801a91:	68 a0 22 80 00       	push   $0x8022a0
  801a96:	6a 36                	push   $0x36
  801a98:	68 b7 22 80 00       	push   $0x8022b7
  801a9d:	e8 bd f5 ff ff       	call   80105f <_panic>
		sys_yield();
  801aa2:	e8 a4 e6 ff ff       	call   80014b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aa7:	ff 75 14             	pushl  0x14(%ebp)
  801aaa:	53                   	push   %ebx
  801aab:	56                   	push   %esi
  801aac:	57                   	push   %edi
  801aad:	e8 45 e8 ff ff       	call   8002f7 <sys_ipc_try_send>
		if (ret == 0) break;
  801ab2:	83 c4 10             	add    $0x10,%esp
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	75 d2                	jne    801a8b <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5f                   	pop    %edi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801acc:	6b d0 78             	imul   $0x78,%eax,%edx
  801acf:	83 c2 50             	add    $0x50,%edx
  801ad2:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ad8:	39 ca                	cmp    %ecx,%edx
  801ada:	75 0d                	jne    801ae9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801adc:	6b c0 78             	imul   $0x78,%eax,%eax
  801adf:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ae4:	8b 40 08             	mov    0x8(%eax),%eax
  801ae7:	eb 0e                	jmp    801af7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae9:	83 c0 01             	add    $0x1,%eax
  801aec:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af1:	75 d9                	jne    801acc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af3:	66 b8 00 00          	mov    $0x0,%ax
}
  801af7:	5d                   	pop    %ebp
  801af8:	c3                   	ret    

00801af9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aff:	89 d0                	mov    %edx,%eax
  801b01:	c1 e8 16             	shr    $0x16,%eax
  801b04:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b10:	f6 c1 01             	test   $0x1,%cl
  801b13:	74 1d                	je     801b32 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b15:	c1 ea 0c             	shr    $0xc,%edx
  801b18:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1f:	f6 c2 01             	test   $0x1,%dl
  801b22:	74 0e                	je     801b32 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b24:	c1 ea 0c             	shr    $0xc,%edx
  801b27:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2e:	ef 
  801b2f:	0f b7 c0             	movzwl %ax,%eax
}
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    
  801b34:	66 90                	xchg   %ax,%ax
  801b36:	66 90                	xchg   %ax,%ax
  801b38:	66 90                	xchg   %ax,%ax
  801b3a:	66 90                	xchg   %ax,%ax
  801b3c:	66 90                	xchg   %ax,%ax
  801b3e:	66 90                	xchg   %ax,%ax

00801b40 <__udivdi3>:
  801b40:	55                   	push   %ebp
  801b41:	57                   	push   %edi
  801b42:	56                   	push   %esi
  801b43:	83 ec 10             	sub    $0x10,%esp
  801b46:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b4a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b4e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b52:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b56:	85 d2                	test   %edx,%edx
  801b58:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b5c:	89 34 24             	mov    %esi,(%esp)
  801b5f:	89 c8                	mov    %ecx,%eax
  801b61:	75 35                	jne    801b98 <__udivdi3+0x58>
  801b63:	39 f1                	cmp    %esi,%ecx
  801b65:	0f 87 bd 00 00 00    	ja     801c28 <__udivdi3+0xe8>
  801b6b:	85 c9                	test   %ecx,%ecx
  801b6d:	89 cd                	mov    %ecx,%ebp
  801b6f:	75 0b                	jne    801b7c <__udivdi3+0x3c>
  801b71:	b8 01 00 00 00       	mov    $0x1,%eax
  801b76:	31 d2                	xor    %edx,%edx
  801b78:	f7 f1                	div    %ecx
  801b7a:	89 c5                	mov    %eax,%ebp
  801b7c:	89 f0                	mov    %esi,%eax
  801b7e:	31 d2                	xor    %edx,%edx
  801b80:	f7 f5                	div    %ebp
  801b82:	89 c6                	mov    %eax,%esi
  801b84:	89 f8                	mov    %edi,%eax
  801b86:	f7 f5                	div    %ebp
  801b88:	89 f2                	mov    %esi,%edx
  801b8a:	83 c4 10             	add    $0x10,%esp
  801b8d:	5e                   	pop    %esi
  801b8e:	5f                   	pop    %edi
  801b8f:	5d                   	pop    %ebp
  801b90:	c3                   	ret    
  801b91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b98:	3b 14 24             	cmp    (%esp),%edx
  801b9b:	77 7b                	ja     801c18 <__udivdi3+0xd8>
  801b9d:	0f bd f2             	bsr    %edx,%esi
  801ba0:	83 f6 1f             	xor    $0x1f,%esi
  801ba3:	0f 84 97 00 00 00    	je     801c40 <__udivdi3+0x100>
  801ba9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bae:	89 d7                	mov    %edx,%edi
  801bb0:	89 f1                	mov    %esi,%ecx
  801bb2:	29 f5                	sub    %esi,%ebp
  801bb4:	d3 e7                	shl    %cl,%edi
  801bb6:	89 c2                	mov    %eax,%edx
  801bb8:	89 e9                	mov    %ebp,%ecx
  801bba:	d3 ea                	shr    %cl,%edx
  801bbc:	89 f1                	mov    %esi,%ecx
  801bbe:	09 fa                	or     %edi,%edx
  801bc0:	8b 3c 24             	mov    (%esp),%edi
  801bc3:	d3 e0                	shl    %cl,%eax
  801bc5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bc9:	89 e9                	mov    %ebp,%ecx
  801bcb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bcf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bd3:	89 fa                	mov    %edi,%edx
  801bd5:	d3 ea                	shr    %cl,%edx
  801bd7:	89 f1                	mov    %esi,%ecx
  801bd9:	d3 e7                	shl    %cl,%edi
  801bdb:	89 e9                	mov    %ebp,%ecx
  801bdd:	d3 e8                	shr    %cl,%eax
  801bdf:	09 c7                	or     %eax,%edi
  801be1:	89 f8                	mov    %edi,%eax
  801be3:	f7 74 24 08          	divl   0x8(%esp)
  801be7:	89 d5                	mov    %edx,%ebp
  801be9:	89 c7                	mov    %eax,%edi
  801beb:	f7 64 24 0c          	mull   0xc(%esp)
  801bef:	39 d5                	cmp    %edx,%ebp
  801bf1:	89 14 24             	mov    %edx,(%esp)
  801bf4:	72 11                	jb     801c07 <__udivdi3+0xc7>
  801bf6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801bfa:	89 f1                	mov    %esi,%ecx
  801bfc:	d3 e2                	shl    %cl,%edx
  801bfe:	39 c2                	cmp    %eax,%edx
  801c00:	73 5e                	jae    801c60 <__udivdi3+0x120>
  801c02:	3b 2c 24             	cmp    (%esp),%ebp
  801c05:	75 59                	jne    801c60 <__udivdi3+0x120>
  801c07:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c0a:	31 f6                	xor    %esi,%esi
  801c0c:	89 f2                	mov    %esi,%edx
  801c0e:	83 c4 10             	add    $0x10,%esp
  801c11:	5e                   	pop    %esi
  801c12:	5f                   	pop    %edi
  801c13:	5d                   	pop    %ebp
  801c14:	c3                   	ret    
  801c15:	8d 76 00             	lea    0x0(%esi),%esi
  801c18:	31 f6                	xor    %esi,%esi
  801c1a:	31 c0                	xor    %eax,%eax
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	89 f2                	mov    %esi,%edx
  801c2a:	31 f6                	xor    %esi,%esi
  801c2c:	89 f8                	mov    %edi,%eax
  801c2e:	f7 f1                	div    %ecx
  801c30:	89 f2                	mov    %esi,%edx
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	5e                   	pop    %esi
  801c36:	5f                   	pop    %edi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c44:	76 0b                	jbe    801c51 <__udivdi3+0x111>
  801c46:	31 c0                	xor    %eax,%eax
  801c48:	3b 14 24             	cmp    (%esp),%edx
  801c4b:	0f 83 37 ff ff ff    	jae    801b88 <__udivdi3+0x48>
  801c51:	b8 01 00 00 00       	mov    $0x1,%eax
  801c56:	e9 2d ff ff ff       	jmp    801b88 <__udivdi3+0x48>
  801c5b:	90                   	nop
  801c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c60:	89 f8                	mov    %edi,%eax
  801c62:	31 f6                	xor    %esi,%esi
  801c64:	e9 1f ff ff ff       	jmp    801b88 <__udivdi3+0x48>
  801c69:	66 90                	xchg   %ax,%ax
  801c6b:	66 90                	xchg   %ax,%ax
  801c6d:	66 90                	xchg   %ax,%ax
  801c6f:	90                   	nop

00801c70 <__umoddi3>:
  801c70:	55                   	push   %ebp
  801c71:	57                   	push   %edi
  801c72:	56                   	push   %esi
  801c73:	83 ec 20             	sub    $0x20,%esp
  801c76:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c7a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c7e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c82:	89 c6                	mov    %eax,%esi
  801c84:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c88:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c8c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c90:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c94:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c98:	89 74 24 18          	mov    %esi,0x18(%esp)
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	89 c2                	mov    %eax,%edx
  801ca0:	75 1e                	jne    801cc0 <__umoddi3+0x50>
  801ca2:	39 f7                	cmp    %esi,%edi
  801ca4:	76 52                	jbe    801cf8 <__umoddi3+0x88>
  801ca6:	89 c8                	mov    %ecx,%eax
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	f7 f7                	div    %edi
  801cac:	89 d0                	mov    %edx,%eax
  801cae:	31 d2                	xor    %edx,%edx
  801cb0:	83 c4 20             	add    $0x20,%esp
  801cb3:	5e                   	pop    %esi
  801cb4:	5f                   	pop    %edi
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    
  801cb7:	89 f6                	mov    %esi,%esi
  801cb9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cc0:	39 f0                	cmp    %esi,%eax
  801cc2:	77 5c                	ja     801d20 <__umoddi3+0xb0>
  801cc4:	0f bd e8             	bsr    %eax,%ebp
  801cc7:	83 f5 1f             	xor    $0x1f,%ebp
  801cca:	75 64                	jne    801d30 <__umoddi3+0xc0>
  801ccc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cd0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cd4:	0f 86 f6 00 00 00    	jbe    801dd0 <__umoddi3+0x160>
  801cda:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cde:	0f 82 ec 00 00 00    	jb     801dd0 <__umoddi3+0x160>
  801ce4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801ce8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cec:	83 c4 20             	add    $0x20,%esp
  801cef:	5e                   	pop    %esi
  801cf0:	5f                   	pop    %edi
  801cf1:	5d                   	pop    %ebp
  801cf2:	c3                   	ret    
  801cf3:	90                   	nop
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	85 ff                	test   %edi,%edi
  801cfa:	89 fd                	mov    %edi,%ebp
  801cfc:	75 0b                	jne    801d09 <__umoddi3+0x99>
  801cfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f7                	div    %edi
  801d07:	89 c5                	mov    %eax,%ebp
  801d09:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d0d:	31 d2                	xor    %edx,%edx
  801d0f:	f7 f5                	div    %ebp
  801d11:	89 c8                	mov    %ecx,%eax
  801d13:	f7 f5                	div    %ebp
  801d15:	eb 95                	jmp    801cac <__umoddi3+0x3c>
  801d17:	89 f6                	mov    %esi,%esi
  801d19:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 20             	add    $0x20,%esp
  801d27:	5e                   	pop    %esi
  801d28:	5f                   	pop    %edi
  801d29:	5d                   	pop    %ebp
  801d2a:	c3                   	ret    
  801d2b:	90                   	nop
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	b8 20 00 00 00       	mov    $0x20,%eax
  801d35:	89 e9                	mov    %ebp,%ecx
  801d37:	29 e8                	sub    %ebp,%eax
  801d39:	d3 e2                	shl    %cl,%edx
  801d3b:	89 c7                	mov    %eax,%edi
  801d3d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d41:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d45:	89 f9                	mov    %edi,%ecx
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 c1                	mov    %eax,%ecx
  801d4b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d4f:	09 d1                	or     %edx,%ecx
  801d51:	89 fa                	mov    %edi,%edx
  801d53:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d57:	89 e9                	mov    %ebp,%ecx
  801d59:	d3 e0                	shl    %cl,%eax
  801d5b:	89 f9                	mov    %edi,%ecx
  801d5d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d61:	89 f0                	mov    %esi,%eax
  801d63:	d3 e8                	shr    %cl,%eax
  801d65:	89 e9                	mov    %ebp,%ecx
  801d67:	89 c7                	mov    %eax,%edi
  801d69:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d6d:	d3 e6                	shl    %cl,%esi
  801d6f:	89 d1                	mov    %edx,%ecx
  801d71:	89 fa                	mov    %edi,%edx
  801d73:	d3 e8                	shr    %cl,%eax
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	09 f0                	or     %esi,%eax
  801d79:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d7d:	f7 74 24 10          	divl   0x10(%esp)
  801d81:	d3 e6                	shl    %cl,%esi
  801d83:	89 d1                	mov    %edx,%ecx
  801d85:	f7 64 24 0c          	mull   0xc(%esp)
  801d89:	39 d1                	cmp    %edx,%ecx
  801d8b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d8f:	89 d7                	mov    %edx,%edi
  801d91:	89 c6                	mov    %eax,%esi
  801d93:	72 0a                	jb     801d9f <__umoddi3+0x12f>
  801d95:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801d99:	73 10                	jae    801dab <__umoddi3+0x13b>
  801d9b:	39 d1                	cmp    %edx,%ecx
  801d9d:	75 0c                	jne    801dab <__umoddi3+0x13b>
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801da7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dab:	89 ca                	mov    %ecx,%edx
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801db3:	29 f0                	sub    %esi,%eax
  801db5:	19 fa                	sbb    %edi,%edx
  801db7:	d3 e8                	shr    %cl,%eax
  801db9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dbe:	89 d7                	mov    %edx,%edi
  801dc0:	d3 e7                	shl    %cl,%edi
  801dc2:	89 e9                	mov    %ebp,%ecx
  801dc4:	09 f8                	or     %edi,%eax
  801dc6:	d3 ea                	shr    %cl,%edx
  801dc8:	83 c4 20             	add    $0x20,%esp
  801dcb:	5e                   	pop    %esi
  801dcc:	5f                   	pop    %edi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    
  801dcf:	90                   	nop
  801dd0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801dd4:	29 f9                	sub    %edi,%ecx
  801dd6:	19 c6                	sbb    %eax,%esi
  801dd8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ddc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801de0:	e9 ff fe ff ff       	jmp    801ce4 <__umoddi3+0x74>
