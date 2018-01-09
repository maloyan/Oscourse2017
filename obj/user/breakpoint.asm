
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	56                   	push   %esi
  80003d:	53                   	push   %ebx
  80003e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800041:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800044:	e8 ce 00 00 00       	call   800117 <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	6b c0 78             	imul   $0x78,%eax,%eax
  800051:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800056:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005b:	85 db                	test   %ebx,%ebx
  80005d:	7e 07                	jle    800066 <libmain+0x2d>
		binaryname = argv[0];
  80005f:	8b 06                	mov    (%esi),%eax
  800061:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800066:	83 ec 08             	sub    $0x8,%esp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	e8 c3 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800070:	e8 0a 00 00 00       	call   80007f <exit>
  800075:	83 c4 10             	add    $0x10,%esp
#endif
}
  800078:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007b:	5b                   	pop    %ebx
  80007c:	5e                   	pop    %esi
  80007d:	5d                   	pop    %ebp
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800085:	e8 a7 04 00 00       	call   800531 <close_all>
	sys_env_destroy(0);
  80008a:	83 ec 0c             	sub    $0xc,%esp
  80008d:	6a 00                	push   $0x0
  80008f:	e8 42 00 00 00       	call   8000d6 <sys_env_destroy>
  800094:	83 c4 10             	add    $0x10,%esp
}
  800097:	c9                   	leave  
  800098:	c3                   	ret    

00800099 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	57                   	push   %edi
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80009f:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000aa:	89 c3                	mov    %eax,%ebx
  8000ac:	89 c7                	mov    %eax,%edi
  8000ae:	89 c6                	mov    %eax,%esi
  8000b0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b2:	5b                   	pop    %ebx
  8000b3:	5e                   	pop    %esi
  8000b4:	5f                   	pop    %edi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c7:	89 d1                	mov    %edx,%ecx
  8000c9:	89 d3                	mov    %edx,%ebx
  8000cb:	89 d7                	mov    %edx,%edi
  8000cd:	89 d6                	mov    %edx,%esi
  8000cf:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d1:	5b                   	pop    %ebx
  8000d2:	5e                   	pop    %esi
  8000d3:	5f                   	pop    %edi
  8000d4:	5d                   	pop    %ebp
  8000d5:	c3                   	ret    

008000d6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	57                   	push   %edi
  8000da:	56                   	push   %esi
  8000db:	53                   	push   %ebx
  8000dc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	89 cb                	mov    %ecx,%ebx
  8000ee:	89 cf                	mov    %ecx,%edi
  8000f0:	89 ce                	mov    %ecx,%esi
  8000f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f4:	85 c0                	test   %eax,%eax
  8000f6:	7e 17                	jle    80010f <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f8:	83 ec 0c             	sub    $0xc,%esp
  8000fb:	50                   	push   %eax
  8000fc:	6a 03                	push   $0x3
  8000fe:	68 0a 1e 80 00       	push   $0x801e0a
  800103:	6a 23                	push   $0x23
  800105:	68 27 1e 80 00       	push   $0x801e27
  80010a:	e8 3b 0f 00 00       	call   80104a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800112:	5b                   	pop    %ebx
  800113:	5e                   	pop    %esi
  800114:	5f                   	pop    %edi
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    

00800117 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800117:	55                   	push   %ebp
  800118:	89 e5                	mov    %esp,%ebp
  80011a:	57                   	push   %edi
  80011b:	56                   	push   %esi
  80011c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 02 00 00 00       	mov    $0x2,%eax
  800127:	89 d1                	mov    %edx,%ecx
  800129:	89 d3                	mov    %edx,%ebx
  80012b:	89 d7                	mov    %edx,%edi
  80012d:	89 d6                	mov    %edx,%esi
  80012f:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5f                   	pop    %edi
  800134:	5d                   	pop    %ebp
  800135:	c3                   	ret    

00800136 <sys_yield>:

void
sys_yield(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 0b 00 00 00       	mov    $0xb,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015e:	be 00 00 00 00       	mov    $0x0,%esi
  800163:	b8 04 00 00 00       	mov    $0x4,%eax
  800168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016b:	8b 55 08             	mov    0x8(%ebp),%edx
  80016e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800171:	89 f7                	mov    %esi,%edi
  800173:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800175:	85 c0                	test   %eax,%eax
  800177:	7e 17                	jle    800190 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	50                   	push   %eax
  80017d:	6a 04                	push   $0x4
  80017f:	68 0a 1e 80 00       	push   $0x801e0a
  800184:	6a 23                	push   $0x23
  800186:	68 27 1e 80 00       	push   $0x801e27
  80018b:	e8 ba 0e 00 00       	call   80104a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800190:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800193:	5b                   	pop    %ebx
  800194:	5e                   	pop    %esi
  800195:	5f                   	pop    %edi
  800196:	5d                   	pop    %ebp
  800197:	c3                   	ret    

00800198 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800198:	55                   	push   %ebp
  800199:	89 e5                	mov    %esp,%ebp
  80019b:	57                   	push   %edi
  80019c:	56                   	push   %esi
  80019d:	53                   	push   %ebx
  80019e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001af:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b2:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b7:	85 c0                	test   %eax,%eax
  8001b9:	7e 17                	jle    8001d2 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	50                   	push   %eax
  8001bf:	6a 05                	push   $0x5
  8001c1:	68 0a 1e 80 00       	push   $0x801e0a
  8001c6:	6a 23                	push   $0x23
  8001c8:	68 27 1e 80 00       	push   $0x801e27
  8001cd:	e8 78 0e 00 00       	call   80104a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d5:	5b                   	pop    %ebx
  8001d6:	5e                   	pop    %esi
  8001d7:	5f                   	pop    %edi
  8001d8:	5d                   	pop    %ebp
  8001d9:	c3                   	ret    

008001da <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001da:	55                   	push   %ebp
  8001db:	89 e5                	mov    %esp,%ebp
  8001dd:	57                   	push   %edi
  8001de:	56                   	push   %esi
  8001df:	53                   	push   %ebx
  8001e0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e8:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f3:	89 df                	mov    %ebx,%edi
  8001f5:	89 de                	mov    %ebx,%esi
  8001f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001f9:	85 c0                	test   %eax,%eax
  8001fb:	7e 17                	jle    800214 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fd:	83 ec 0c             	sub    $0xc,%esp
  800200:	50                   	push   %eax
  800201:	6a 06                	push   $0x6
  800203:	68 0a 1e 80 00       	push   $0x801e0a
  800208:	6a 23                	push   $0x23
  80020a:	68 27 1e 80 00       	push   $0x801e27
  80020f:	e8 36 0e 00 00       	call   80104a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800214:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800217:	5b                   	pop    %ebx
  800218:	5e                   	pop    %esi
  800219:	5f                   	pop    %edi
  80021a:	5d                   	pop    %ebp
  80021b:	c3                   	ret    

0080021c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021c:	55                   	push   %ebp
  80021d:	89 e5                	mov    %esp,%ebp
  80021f:	57                   	push   %edi
  800220:	56                   	push   %esi
  800221:	53                   	push   %ebx
  800222:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 17                	jle    800256 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	83 ec 0c             	sub    $0xc,%esp
  800242:	50                   	push   %eax
  800243:	6a 08                	push   $0x8
  800245:	68 0a 1e 80 00       	push   $0x801e0a
  80024a:	6a 23                	push   $0x23
  80024c:	68 27 1e 80 00       	push   $0x801e27
  800251:	e8 f4 0d 00 00       	call   80104a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800256:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800259:	5b                   	pop    %ebx
  80025a:	5e                   	pop    %esi
  80025b:	5f                   	pop    %edi
  80025c:	5d                   	pop    %ebp
  80025d:	c3                   	ret    

0080025e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	57                   	push   %edi
  800262:	56                   	push   %esi
  800263:	53                   	push   %ebx
  800264:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800267:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026c:	b8 09 00 00 00       	mov    $0x9,%eax
  800271:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800274:	8b 55 08             	mov    0x8(%ebp),%edx
  800277:	89 df                	mov    %ebx,%edi
  800279:	89 de                	mov    %ebx,%esi
  80027b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027d:	85 c0                	test   %eax,%eax
  80027f:	7e 17                	jle    800298 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800281:	83 ec 0c             	sub    $0xc,%esp
  800284:	50                   	push   %eax
  800285:	6a 09                	push   $0x9
  800287:	68 0a 1e 80 00       	push   $0x801e0a
  80028c:	6a 23                	push   $0x23
  80028e:	68 27 1e 80 00       	push   $0x801e27
  800293:	e8 b2 0d 00 00       	call   80104a <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800298:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029b:	5b                   	pop    %ebx
  80029c:	5e                   	pop    %esi
  80029d:	5f                   	pop    %edi
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 17                	jle    8002da <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	83 ec 0c             	sub    $0xc,%esp
  8002c6:	50                   	push   %eax
  8002c7:	6a 0a                	push   $0xa
  8002c9:	68 0a 1e 80 00       	push   $0x801e0a
  8002ce:	6a 23                	push   $0x23
  8002d0:	68 27 1e 80 00       	push   $0x801e27
  8002d5:	e8 70 0d 00 00       	call   80104a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dd:	5b                   	pop    %ebx
  8002de:	5e                   	pop    %esi
  8002df:	5f                   	pop    %edi
  8002e0:	5d                   	pop    %ebp
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e2:	55                   	push   %ebp
  8002e3:	89 e5                	mov    %esp,%ebp
  8002e5:	57                   	push   %edi
  8002e6:	56                   	push   %esi
  8002e7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e8:	be 00 00 00 00       	mov    $0x0,%esi
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fe:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    

00800305 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800305:	55                   	push   %ebp
  800306:	89 e5                	mov    %esp,%ebp
  800308:	57                   	push   %edi
  800309:	56                   	push   %esi
  80030a:	53                   	push   %ebx
  80030b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	89 cb                	mov    %ecx,%ebx
  80031d:	89 cf                	mov    %ecx,%edi
  80031f:	89 ce                	mov    %ecx,%esi
  800321:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800323:	85 c0                	test   %eax,%eax
  800325:	7e 17                	jle    80033e <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800327:	83 ec 0c             	sub    $0xc,%esp
  80032a:	50                   	push   %eax
  80032b:	6a 0d                	push   $0xd
  80032d:	68 0a 1e 80 00       	push   $0x801e0a
  800332:	6a 23                	push   $0x23
  800334:	68 27 1e 80 00       	push   $0x801e27
  800339:	e8 0c 0d 00 00       	call   80104a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800341:	5b                   	pop    %ebx
  800342:	5e                   	pop    %esi
  800343:	5f                   	pop    %edi
  800344:	5d                   	pop    %ebp
  800345:	c3                   	ret    

00800346 <sys_gettime>:

int sys_gettime(void)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034c:	ba 00 00 00 00       	mov    $0x0,%edx
  800351:	b8 0e 00 00 00       	mov    $0xe,%eax
  800356:	89 d1                	mov    %edx,%ecx
  800358:	89 d3                	mov    %edx,%ebx
  80035a:	89 d7                	mov    %edx,%edi
  80035c:	89 d6                	mov    %edx,%esi
  80035e:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800360:	5b                   	pop    %ebx
  800361:	5e                   	pop    %esi
  800362:	5f                   	pop    %edi
  800363:	5d                   	pop    %ebp
  800364:	c3                   	ret    

00800365 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800365:	55                   	push   %ebp
  800366:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800368:	8b 45 08             	mov    0x8(%ebp),%eax
  80036b:	05 00 00 00 30       	add    $0x30000000,%eax
  800370:	c1 e8 0c             	shr    $0xc,%eax
}
  800373:	5d                   	pop    %ebp
  800374:	c3                   	ret    

00800375 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800380:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800385:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038a:	5d                   	pop    %ebp
  80038b:	c3                   	ret    

0080038c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800392:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 16             	shr    $0x16,%edx
  80039c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 11                	je     8003b9 <fd_alloc+0x2d>
  8003a8:	89 c2                	mov    %eax,%edx
  8003aa:	c1 ea 0c             	shr    $0xc,%edx
  8003ad:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b4:	f6 c2 01             	test   $0x1,%dl
  8003b7:	75 09                	jne    8003c2 <fd_alloc+0x36>
			*fd_store = fd;
  8003b9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c0:	eb 17                	jmp    8003d9 <fd_alloc+0x4d>
  8003c2:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c7:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cc:	75 c9                	jne    800397 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003ce:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d4:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003d9:	5d                   	pop    %ebp
  8003da:	c3                   	ret    

008003db <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003db:	55                   	push   %ebp
  8003dc:	89 e5                	mov    %esp,%ebp
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e1:	83 f8 1f             	cmp    $0x1f,%eax
  8003e4:	77 36                	ja     80041c <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e6:	c1 e0 0c             	shl    $0xc,%eax
  8003e9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 16             	shr    $0x16,%edx
  8003f3:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 24                	je     800423 <fd_lookup+0x48>
  8003ff:	89 c2                	mov    %eax,%edx
  800401:	c1 ea 0c             	shr    $0xc,%edx
  800404:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040b:	f6 c2 01             	test   $0x1,%dl
  80040e:	74 1a                	je     80042a <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800410:	8b 55 0c             	mov    0xc(%ebp),%edx
  800413:	89 02                	mov    %eax,(%edx)
	return 0;
  800415:	b8 00 00 00 00       	mov    $0x0,%eax
  80041a:	eb 13                	jmp    80042f <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800421:	eb 0c                	jmp    80042f <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800428:	eb 05                	jmp    80042f <fd_lookup+0x54>
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80042f:	5d                   	pop    %ebp
  800430:	c3                   	ret    

00800431 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043a:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80043f:	eb 13                	jmp    800454 <dev_lookup+0x23>
  800441:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800444:	39 08                	cmp    %ecx,(%eax)
  800446:	75 0c                	jne    800454 <dev_lookup+0x23>
			*dev = devtab[i];
  800448:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044d:	b8 00 00 00 00       	mov    $0x0,%eax
  800452:	eb 2e                	jmp    800482 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800454:	8b 02                	mov    (%edx),%eax
  800456:	85 c0                	test   %eax,%eax
  800458:	75 e7                	jne    800441 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045a:	a1 04 40 80 00       	mov    0x804004,%eax
  80045f:	8b 40 48             	mov    0x48(%eax),%eax
  800462:	83 ec 04             	sub    $0x4,%esp
  800465:	51                   	push   %ecx
  800466:	50                   	push   %eax
  800467:	68 38 1e 80 00       	push   $0x801e38
  80046c:	e8 b2 0c 00 00       	call   801123 <cprintf>
	*dev = 0;
  800471:	8b 45 0c             	mov    0xc(%ebp),%eax
  800474:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800482:	c9                   	leave  
  800483:	c3                   	ret    

00800484 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800484:	55                   	push   %ebp
  800485:	89 e5                	mov    %esp,%ebp
  800487:	56                   	push   %esi
  800488:	53                   	push   %ebx
  800489:	83 ec 10             	sub    $0x10,%esp
  80048c:	8b 75 08             	mov    0x8(%ebp),%esi
  80048f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800492:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800495:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800496:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80049c:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	50                   	push   %eax
  8004a0:	e8 36 ff ff ff       	call   8003db <fd_lookup>
  8004a5:	83 c4 08             	add    $0x8,%esp
  8004a8:	85 c0                	test   %eax,%eax
  8004aa:	78 05                	js     8004b1 <fd_close+0x2d>
	    || fd != fd2)
  8004ac:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004af:	74 0b                	je     8004bc <fd_close+0x38>
		return (must_exist ? r : 0);
  8004b1:	80 fb 01             	cmp    $0x1,%bl
  8004b4:	19 d2                	sbb    %edx,%edx
  8004b6:	f7 d2                	not    %edx
  8004b8:	21 d0                	and    %edx,%eax
  8004ba:	eb 41                	jmp    8004fd <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c2:	50                   	push   %eax
  8004c3:	ff 36                	pushl  (%esi)
  8004c5:	e8 67 ff ff ff       	call   800431 <dev_lookup>
  8004ca:	89 c3                	mov    %eax,%ebx
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	78 1a                	js     8004ed <fd_close+0x69>
		if (dev->dev_close)
  8004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004de:	85 c0                	test   %eax,%eax
  8004e0:	74 0b                	je     8004ed <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8004e2:	83 ec 0c             	sub    $0xc,%esp
  8004e5:	56                   	push   %esi
  8004e6:	ff d0                	call   *%eax
  8004e8:	89 c3                	mov    %eax,%ebx
  8004ea:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ed:	83 ec 08             	sub    $0x8,%esp
  8004f0:	56                   	push   %esi
  8004f1:	6a 00                	push   $0x0
  8004f3:	e8 e2 fc ff ff       	call   8001da <sys_page_unmap>
	return r;
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	89 d8                	mov    %ebx,%eax
}
  8004fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800500:	5b                   	pop    %ebx
  800501:	5e                   	pop    %esi
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050d:	50                   	push   %eax
  80050e:	ff 75 08             	pushl  0x8(%ebp)
  800511:	e8 c5 fe ff ff       	call   8003db <fd_lookup>
  800516:	89 c2                	mov    %eax,%edx
  800518:	83 c4 08             	add    $0x8,%esp
  80051b:	85 d2                	test   %edx,%edx
  80051d:	78 10                	js     80052f <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	6a 01                	push   $0x1
  800524:	ff 75 f4             	pushl  -0xc(%ebp)
  800527:	e8 58 ff ff ff       	call   800484 <fd_close>
  80052c:	83 c4 10             	add    $0x10,%esp
}
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <close_all>:

void
close_all(void)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	53                   	push   %ebx
  800535:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053d:	83 ec 0c             	sub    $0xc,%esp
  800540:	53                   	push   %ebx
  800541:	e8 be ff ff ff       	call   800504 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800546:	83 c3 01             	add    $0x1,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	83 fb 20             	cmp    $0x20,%ebx
  80054f:	75 ec                	jne    80053d <close_all+0xc>
		close(i);
}
  800551:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800554:	c9                   	leave  
  800555:	c3                   	ret    

00800556 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800556:	55                   	push   %ebp
  800557:	89 e5                	mov    %esp,%ebp
  800559:	57                   	push   %edi
  80055a:	56                   	push   %esi
  80055b:	53                   	push   %ebx
  80055c:	83 ec 2c             	sub    $0x2c,%esp
  80055f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800562:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800565:	50                   	push   %eax
  800566:	ff 75 08             	pushl  0x8(%ebp)
  800569:	e8 6d fe ff ff       	call   8003db <fd_lookup>
  80056e:	89 c2                	mov    %eax,%edx
  800570:	83 c4 08             	add    $0x8,%esp
  800573:	85 d2                	test   %edx,%edx
  800575:	0f 88 c1 00 00 00    	js     80063c <dup+0xe6>
		return r;
	close(newfdnum);
  80057b:	83 ec 0c             	sub    $0xc,%esp
  80057e:	56                   	push   %esi
  80057f:	e8 80 ff ff ff       	call   800504 <close>

	newfd = INDEX2FD(newfdnum);
  800584:	89 f3                	mov    %esi,%ebx
  800586:	c1 e3 0c             	shl    $0xc,%ebx
  800589:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80058f:	83 c4 04             	add    $0x4,%esp
  800592:	ff 75 e4             	pushl  -0x1c(%ebp)
  800595:	e8 db fd ff ff       	call   800375 <fd2data>
  80059a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80059c:	89 1c 24             	mov    %ebx,(%esp)
  80059f:	e8 d1 fd ff ff       	call   800375 <fd2data>
  8005a4:	83 c4 10             	add    $0x10,%esp
  8005a7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005aa:	89 f8                	mov    %edi,%eax
  8005ac:	c1 e8 16             	shr    $0x16,%eax
  8005af:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b6:	a8 01                	test   $0x1,%al
  8005b8:	74 37                	je     8005f1 <dup+0x9b>
  8005ba:	89 f8                	mov    %edi,%eax
  8005bc:	c1 e8 0c             	shr    $0xc,%eax
  8005bf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c6:	f6 c2 01             	test   $0x1,%dl
  8005c9:	74 26                	je     8005f1 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d2:	83 ec 0c             	sub    $0xc,%esp
  8005d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005da:	50                   	push   %eax
  8005db:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005de:	6a 00                	push   $0x0
  8005e0:	57                   	push   %edi
  8005e1:	6a 00                	push   $0x0
  8005e3:	e8 b0 fb ff ff       	call   800198 <sys_page_map>
  8005e8:	89 c7                	mov    %eax,%edi
  8005ea:	83 c4 20             	add    $0x20,%esp
  8005ed:	85 c0                	test   %eax,%eax
  8005ef:	78 2e                	js     80061f <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f4:	89 d0                	mov    %edx,%eax
  8005f6:	c1 e8 0c             	shr    $0xc,%eax
  8005f9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800600:	83 ec 0c             	sub    $0xc,%esp
  800603:	25 07 0e 00 00       	and    $0xe07,%eax
  800608:	50                   	push   %eax
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	52                   	push   %edx
  80060d:	6a 00                	push   $0x0
  80060f:	e8 84 fb ff ff       	call   800198 <sys_page_map>
  800614:	89 c7                	mov    %eax,%edi
  800616:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800619:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061b:	85 ff                	test   %edi,%edi
  80061d:	79 1d                	jns    80063c <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80061f:	83 ec 08             	sub    $0x8,%esp
  800622:	53                   	push   %ebx
  800623:	6a 00                	push   $0x0
  800625:	e8 b0 fb ff ff       	call   8001da <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062a:	83 c4 08             	add    $0x8,%esp
  80062d:	ff 75 d4             	pushl  -0x2c(%ebp)
  800630:	6a 00                	push   $0x0
  800632:	e8 a3 fb ff ff       	call   8001da <sys_page_unmap>
	return r;
  800637:	83 c4 10             	add    $0x10,%esp
  80063a:	89 f8                	mov    %edi,%eax
}
  80063c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063f:	5b                   	pop    %ebx
  800640:	5e                   	pop    %esi
  800641:	5f                   	pop    %edi
  800642:	5d                   	pop    %ebp
  800643:	c3                   	ret    

00800644 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800644:	55                   	push   %ebp
  800645:	89 e5                	mov    %esp,%ebp
  800647:	53                   	push   %ebx
  800648:	83 ec 14             	sub    $0x14,%esp
  80064b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800651:	50                   	push   %eax
  800652:	53                   	push   %ebx
  800653:	e8 83 fd ff ff       	call   8003db <fd_lookup>
  800658:	83 c4 08             	add    $0x8,%esp
  80065b:	89 c2                	mov    %eax,%edx
  80065d:	85 c0                	test   %eax,%eax
  80065f:	78 6d                	js     8006ce <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800661:	83 ec 08             	sub    $0x8,%esp
  800664:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800667:	50                   	push   %eax
  800668:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066b:	ff 30                	pushl  (%eax)
  80066d:	e8 bf fd ff ff       	call   800431 <dev_lookup>
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	85 c0                	test   %eax,%eax
  800677:	78 4c                	js     8006c5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800679:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80067c:	8b 42 08             	mov    0x8(%edx),%eax
  80067f:	83 e0 03             	and    $0x3,%eax
  800682:	83 f8 01             	cmp    $0x1,%eax
  800685:	75 21                	jne    8006a8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800687:	a1 04 40 80 00       	mov    0x804004,%eax
  80068c:	8b 40 48             	mov    0x48(%eax),%eax
  80068f:	83 ec 04             	sub    $0x4,%esp
  800692:	53                   	push   %ebx
  800693:	50                   	push   %eax
  800694:	68 79 1e 80 00       	push   $0x801e79
  800699:	e8 85 0a 00 00       	call   801123 <cprintf>
		return -E_INVAL;
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a6:	eb 26                	jmp    8006ce <read+0x8a>
	}
	if (!dev->dev_read)
  8006a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ab:	8b 40 08             	mov    0x8(%eax),%eax
  8006ae:	85 c0                	test   %eax,%eax
  8006b0:	74 17                	je     8006c9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b2:	83 ec 04             	sub    $0x4,%esp
  8006b5:	ff 75 10             	pushl  0x10(%ebp)
  8006b8:	ff 75 0c             	pushl  0xc(%ebp)
  8006bb:	52                   	push   %edx
  8006bc:	ff d0                	call   *%eax
  8006be:	89 c2                	mov    %eax,%edx
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	eb 09                	jmp    8006ce <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c5:	89 c2                	mov    %eax,%edx
  8006c7:	eb 05                	jmp    8006ce <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ce:	89 d0                	mov    %edx,%eax
  8006d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d3:	c9                   	leave  
  8006d4:	c3                   	ret    

008006d5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	57                   	push   %edi
  8006d9:	56                   	push   %esi
  8006da:	53                   	push   %ebx
  8006db:	83 ec 0c             	sub    $0xc,%esp
  8006de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e9:	eb 21                	jmp    80070c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006eb:	83 ec 04             	sub    $0x4,%esp
  8006ee:	89 f0                	mov    %esi,%eax
  8006f0:	29 d8                	sub    %ebx,%eax
  8006f2:	50                   	push   %eax
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	03 45 0c             	add    0xc(%ebp),%eax
  8006f8:	50                   	push   %eax
  8006f9:	57                   	push   %edi
  8006fa:	e8 45 ff ff ff       	call   800644 <read>
		if (m < 0)
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	85 c0                	test   %eax,%eax
  800704:	78 0c                	js     800712 <readn+0x3d>
			return m;
		if (m == 0)
  800706:	85 c0                	test   %eax,%eax
  800708:	74 06                	je     800710 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070a:	01 c3                	add    %eax,%ebx
  80070c:	39 f3                	cmp    %esi,%ebx
  80070e:	72 db                	jb     8006eb <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800710:	89 d8                	mov    %ebx,%eax
}
  800712:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800715:	5b                   	pop    %ebx
  800716:	5e                   	pop    %esi
  800717:	5f                   	pop    %edi
  800718:	5d                   	pop    %ebp
  800719:	c3                   	ret    

0080071a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071a:	55                   	push   %ebp
  80071b:	89 e5                	mov    %esp,%ebp
  80071d:	53                   	push   %ebx
  80071e:	83 ec 14             	sub    $0x14,%esp
  800721:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800724:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	53                   	push   %ebx
  800729:	e8 ad fc ff ff       	call   8003db <fd_lookup>
  80072e:	83 c4 08             	add    $0x8,%esp
  800731:	89 c2                	mov    %eax,%edx
  800733:	85 c0                	test   %eax,%eax
  800735:	78 68                	js     80079f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800737:	83 ec 08             	sub    $0x8,%esp
  80073a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800741:	ff 30                	pushl  (%eax)
  800743:	e8 e9 fc ff ff       	call   800431 <dev_lookup>
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	85 c0                	test   %eax,%eax
  80074d:	78 47                	js     800796 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80074f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800752:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800756:	75 21                	jne    800779 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800758:	a1 04 40 80 00       	mov    0x804004,%eax
  80075d:	8b 40 48             	mov    0x48(%eax),%eax
  800760:	83 ec 04             	sub    $0x4,%esp
  800763:	53                   	push   %ebx
  800764:	50                   	push   %eax
  800765:	68 95 1e 80 00       	push   $0x801e95
  80076a:	e8 b4 09 00 00       	call   801123 <cprintf>
		return -E_INVAL;
  80076f:	83 c4 10             	add    $0x10,%esp
  800772:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800777:	eb 26                	jmp    80079f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800779:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077c:	8b 52 0c             	mov    0xc(%edx),%edx
  80077f:	85 d2                	test   %edx,%edx
  800781:	74 17                	je     80079a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800783:	83 ec 04             	sub    $0x4,%esp
  800786:	ff 75 10             	pushl  0x10(%ebp)
  800789:	ff 75 0c             	pushl  0xc(%ebp)
  80078c:	50                   	push   %eax
  80078d:	ff d2                	call   *%edx
  80078f:	89 c2                	mov    %eax,%edx
  800791:	83 c4 10             	add    $0x10,%esp
  800794:	eb 09                	jmp    80079f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800796:	89 c2                	mov    %eax,%edx
  800798:	eb 05                	jmp    80079f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80079f:	89 d0                	mov    %edx,%eax
  8007a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a4:	c9                   	leave  
  8007a5:	c3                   	ret    

008007a6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ac:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007af:	50                   	push   %eax
  8007b0:	ff 75 08             	pushl  0x8(%ebp)
  8007b3:	e8 23 fc ff ff       	call   8003db <fd_lookup>
  8007b8:	83 c4 08             	add    $0x8,%esp
  8007bb:	85 c0                	test   %eax,%eax
  8007bd:	78 0e                	js     8007cd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007cd:	c9                   	leave  
  8007ce:	c3                   	ret    

008007cf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	53                   	push   %ebx
  8007d3:	83 ec 14             	sub    $0x14,%esp
  8007d6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	53                   	push   %ebx
  8007de:	e8 f8 fb ff ff       	call   8003db <fd_lookup>
  8007e3:	83 c4 08             	add    $0x8,%esp
  8007e6:	89 c2                	mov    %eax,%edx
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	78 65                	js     800851 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ec:	83 ec 08             	sub    $0x8,%esp
  8007ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f2:	50                   	push   %eax
  8007f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f6:	ff 30                	pushl  (%eax)
  8007f8:	e8 34 fc ff ff       	call   800431 <dev_lookup>
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	85 c0                	test   %eax,%eax
  800802:	78 44                	js     800848 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800804:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800807:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080b:	75 21                	jne    80082e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080d:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800812:	8b 40 48             	mov    0x48(%eax),%eax
  800815:	83 ec 04             	sub    $0x4,%esp
  800818:	53                   	push   %ebx
  800819:	50                   	push   %eax
  80081a:	68 58 1e 80 00       	push   $0x801e58
  80081f:	e8 ff 08 00 00       	call   801123 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800824:	83 c4 10             	add    $0x10,%esp
  800827:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082c:	eb 23                	jmp    800851 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80082e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800831:	8b 52 18             	mov    0x18(%edx),%edx
  800834:	85 d2                	test   %edx,%edx
  800836:	74 14                	je     80084c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	ff 75 0c             	pushl  0xc(%ebp)
  80083e:	50                   	push   %eax
  80083f:	ff d2                	call   *%edx
  800841:	89 c2                	mov    %eax,%edx
  800843:	83 c4 10             	add    $0x10,%esp
  800846:	eb 09                	jmp    800851 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800848:	89 c2                	mov    %eax,%edx
  80084a:	eb 05                	jmp    800851 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80084c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800851:	89 d0                	mov    %edx,%eax
  800853:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800856:	c9                   	leave  
  800857:	c3                   	ret    

00800858 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	53                   	push   %ebx
  80085c:	83 ec 14             	sub    $0x14,%esp
  80085f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800862:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800865:	50                   	push   %eax
  800866:	ff 75 08             	pushl  0x8(%ebp)
  800869:	e8 6d fb ff ff       	call   8003db <fd_lookup>
  80086e:	83 c4 08             	add    $0x8,%esp
  800871:	89 c2                	mov    %eax,%edx
  800873:	85 c0                	test   %eax,%eax
  800875:	78 58                	js     8008cf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800877:	83 ec 08             	sub    $0x8,%esp
  80087a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087d:	50                   	push   %eax
  80087e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800881:	ff 30                	pushl  (%eax)
  800883:	e8 a9 fb ff ff       	call   800431 <dev_lookup>
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	85 c0                	test   %eax,%eax
  80088d:	78 37                	js     8008c6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80088f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800892:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800896:	74 32                	je     8008ca <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800898:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a2:	00 00 00 
	stat->st_isdir = 0;
  8008a5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ac:	00 00 00 
	stat->st_dev = dev;
  8008af:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	53                   	push   %ebx
  8008b9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008bc:	ff 50 14             	call   *0x14(%eax)
  8008bf:	89 c2                	mov    %eax,%edx
  8008c1:	83 c4 10             	add    $0x10,%esp
  8008c4:	eb 09                	jmp    8008cf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c6:	89 c2                	mov    %eax,%edx
  8008c8:	eb 05                	jmp    8008cf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008cf:	89 d0                	mov    %edx,%eax
  8008d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    

008008d6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d6:	55                   	push   %ebp
  8008d7:	89 e5                	mov    %esp,%ebp
  8008d9:	56                   	push   %esi
  8008da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008db:	83 ec 08             	sub    $0x8,%esp
  8008de:	6a 00                	push   $0x0
  8008e0:	ff 75 08             	pushl  0x8(%ebp)
  8008e3:	e8 e7 01 00 00       	call   800acf <open>
  8008e8:	89 c3                	mov    %eax,%ebx
  8008ea:	83 c4 10             	add    $0x10,%esp
  8008ed:	85 db                	test   %ebx,%ebx
  8008ef:	78 1b                	js     80090c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f1:	83 ec 08             	sub    $0x8,%esp
  8008f4:	ff 75 0c             	pushl  0xc(%ebp)
  8008f7:	53                   	push   %ebx
  8008f8:	e8 5b ff ff ff       	call   800858 <fstat>
  8008fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ff:	89 1c 24             	mov    %ebx,(%esp)
  800902:	e8 fd fb ff ff       	call   800504 <close>
	return r;
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	89 f0                	mov    %esi,%eax
}
  80090c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090f:	5b                   	pop    %ebx
  800910:	5e                   	pop    %esi
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    

00800913 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	89 c6                	mov    %eax,%esi
  80091a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80091c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800923:	75 12                	jne    800937 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800925:	83 ec 0c             	sub    $0xc,%esp
  800928:	6a 03                	push   $0x3
  80092a:	e8 7d 11 00 00       	call   801aac <ipc_find_env>
  80092f:	a3 00 40 80 00       	mov    %eax,0x804000
  800934:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800937:	6a 07                	push   $0x7
  800939:	68 00 50 80 00       	push   $0x805000
  80093e:	56                   	push   %esi
  80093f:	ff 35 00 40 80 00    	pushl  0x804000
  800945:	e8 11 11 00 00       	call   801a5b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094a:	83 c4 0c             	add    $0xc,%esp
  80094d:	6a 00                	push   $0x0
  80094f:	53                   	push   %ebx
  800950:	6a 00                	push   $0x0
  800952:	e8 9e 10 00 00       	call   8019f5 <ipc_recv>
}
  800957:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095a:	5b                   	pop    %ebx
  80095b:	5e                   	pop    %esi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 40 0c             	mov    0xc(%eax),%eax
  80096a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80096f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800972:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800977:	ba 00 00 00 00       	mov    $0x0,%edx
  80097c:	b8 02 00 00 00       	mov    $0x2,%eax
  800981:	e8 8d ff ff ff       	call   800913 <fsipc>
}
  800986:	c9                   	leave  
  800987:	c3                   	ret    

00800988 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	8b 40 0c             	mov    0xc(%eax),%eax
  800994:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800999:	ba 00 00 00 00       	mov    $0x0,%edx
  80099e:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a3:	e8 6b ff ff ff       	call   800913 <fsipc>
}
  8009a8:	c9                   	leave  
  8009a9:	c3                   	ret    

008009aa <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	53                   	push   %ebx
  8009ae:	83 ec 04             	sub    $0x4,%esp
  8009b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ba:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c9:	e8 45 ff ff ff       	call   800913 <fsipc>
  8009ce:	89 c2                	mov    %eax,%edx
  8009d0:	85 d2                	test   %edx,%edx
  8009d2:	78 2c                	js     800a00 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d4:	83 ec 08             	sub    $0x8,%esp
  8009d7:	68 00 50 80 00       	push   $0x805000
  8009dc:	53                   	push   %ebx
  8009dd:	e8 c5 0c 00 00       	call   8016a7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e2:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ed:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f8:	83 c4 10             	add    $0x10,%esp
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a03:	c9                   	leave  
  800a04:	c3                   	ret    

00800a05 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800a11:	8b 52 0c             	mov    0xc(%edx),%edx
  800a14:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a1a:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a1f:	76 05                	jbe    800a26 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a21:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a26:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a2b:	83 ec 04             	sub    $0x4,%esp
  800a2e:	50                   	push   %eax
  800a2f:	ff 75 0c             	pushl  0xc(%ebp)
  800a32:	68 08 50 80 00       	push   $0x805008
  800a37:	e8 fd 0d 00 00       	call   801839 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a41:	b8 04 00 00 00       	mov    $0x4,%eax
  800a46:	e8 c8 fe ff ff       	call   800913 <fsipc>
	return write;
}
  800a4b:	c9                   	leave  
  800a4c:	c3                   	ret    

00800a4d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a4d:	55                   	push   %ebp
  800a4e:	89 e5                	mov    %esp,%ebp
  800a50:	56                   	push   %esi
  800a51:	53                   	push   %ebx
  800a52:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a55:	8b 45 08             	mov    0x8(%ebp),%eax
  800a58:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a60:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a66:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6b:	b8 03 00 00 00       	mov    $0x3,%eax
  800a70:	e8 9e fe ff ff       	call   800913 <fsipc>
  800a75:	89 c3                	mov    %eax,%ebx
  800a77:	85 c0                	test   %eax,%eax
  800a79:	78 4b                	js     800ac6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a7b:	39 c6                	cmp    %eax,%esi
  800a7d:	73 16                	jae    800a95 <devfile_read+0x48>
  800a7f:	68 c4 1e 80 00       	push   $0x801ec4
  800a84:	68 cb 1e 80 00       	push   $0x801ecb
  800a89:	6a 7c                	push   $0x7c
  800a8b:	68 e0 1e 80 00       	push   $0x801ee0
  800a90:	e8 b5 05 00 00       	call   80104a <_panic>
	assert(r <= PGSIZE);
  800a95:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9a:	7e 16                	jle    800ab2 <devfile_read+0x65>
  800a9c:	68 eb 1e 80 00       	push   $0x801eeb
  800aa1:	68 cb 1e 80 00       	push   $0x801ecb
  800aa6:	6a 7d                	push   $0x7d
  800aa8:	68 e0 1e 80 00       	push   $0x801ee0
  800aad:	e8 98 05 00 00       	call   80104a <_panic>
	memmove(buf, &fsipcbuf, r);
  800ab2:	83 ec 04             	sub    $0x4,%esp
  800ab5:	50                   	push   %eax
  800ab6:	68 00 50 80 00       	push   $0x805000
  800abb:	ff 75 0c             	pushl  0xc(%ebp)
  800abe:	e8 76 0d 00 00       	call   801839 <memmove>
	return r;
  800ac3:	83 c4 10             	add    $0x10,%esp
}
  800ac6:	89 d8                	mov    %ebx,%eax
  800ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    

00800acf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800acf:	55                   	push   %ebp
  800ad0:	89 e5                	mov    %esp,%ebp
  800ad2:	53                   	push   %ebx
  800ad3:	83 ec 20             	sub    $0x20,%esp
  800ad6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ad9:	53                   	push   %ebx
  800ada:	e8 8f 0b 00 00       	call   80166e <strlen>
  800adf:	83 c4 10             	add    $0x10,%esp
  800ae2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae7:	7f 67                	jg     800b50 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae9:	83 ec 0c             	sub    $0xc,%esp
  800aec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aef:	50                   	push   %eax
  800af0:	e8 97 f8 ff ff       	call   80038c <fd_alloc>
  800af5:	83 c4 10             	add    $0x10,%esp
		return r;
  800af8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afa:	85 c0                	test   %eax,%eax
  800afc:	78 57                	js     800b55 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800afe:	83 ec 08             	sub    $0x8,%esp
  800b01:	53                   	push   %ebx
  800b02:	68 00 50 80 00       	push   $0x805000
  800b07:	e8 9b 0b 00 00       	call   8016a7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b14:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b17:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1c:	e8 f2 fd ff ff       	call   800913 <fsipc>
  800b21:	89 c3                	mov    %eax,%ebx
  800b23:	83 c4 10             	add    $0x10,%esp
  800b26:	85 c0                	test   %eax,%eax
  800b28:	79 14                	jns    800b3e <open+0x6f>
		fd_close(fd, 0);
  800b2a:	83 ec 08             	sub    $0x8,%esp
  800b2d:	6a 00                	push   $0x0
  800b2f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b32:	e8 4d f9 ff ff       	call   800484 <fd_close>
		return r;
  800b37:	83 c4 10             	add    $0x10,%esp
  800b3a:	89 da                	mov    %ebx,%edx
  800b3c:	eb 17                	jmp    800b55 <open+0x86>
	}

	return fd2num(fd);
  800b3e:	83 ec 0c             	sub    $0xc,%esp
  800b41:	ff 75 f4             	pushl  -0xc(%ebp)
  800b44:	e8 1c f8 ff ff       	call   800365 <fd2num>
  800b49:	89 c2                	mov    %eax,%edx
  800b4b:	83 c4 10             	add    $0x10,%esp
  800b4e:	eb 05                	jmp    800b55 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b50:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b55:	89 d0                	mov    %edx,%eax
  800b57:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5a:	c9                   	leave  
  800b5b:	c3                   	ret    

00800b5c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6c:	e8 a2 fd ff ff       	call   800913 <fsipc>
}
  800b71:	c9                   	leave  
  800b72:	c3                   	ret    

00800b73 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7b:	83 ec 0c             	sub    $0xc,%esp
  800b7e:	ff 75 08             	pushl  0x8(%ebp)
  800b81:	e8 ef f7 ff ff       	call   800375 <fd2data>
  800b86:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b88:	83 c4 08             	add    $0x8,%esp
  800b8b:	68 f7 1e 80 00       	push   $0x801ef7
  800b90:	53                   	push   %ebx
  800b91:	e8 11 0b 00 00       	call   8016a7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b96:	8b 56 04             	mov    0x4(%esi),%edx
  800b99:	89 d0                	mov    %edx,%eax
  800b9b:	2b 06                	sub    (%esi),%eax
  800b9d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800baa:	00 00 00 
	stat->st_dev = &devpipe;
  800bad:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb4:	30 80 00 
	return 0;
}
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bbf:	5b                   	pop    %ebx
  800bc0:	5e                   	pop    %esi
  800bc1:	5d                   	pop    %ebp
  800bc2:	c3                   	ret    

00800bc3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	53                   	push   %ebx
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bcd:	53                   	push   %ebx
  800bce:	6a 00                	push   $0x0
  800bd0:	e8 05 f6 ff ff       	call   8001da <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd5:	89 1c 24             	mov    %ebx,(%esp)
  800bd8:	e8 98 f7 ff ff       	call   800375 <fd2data>
  800bdd:	83 c4 08             	add    $0x8,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 00                	push   $0x0
  800be3:	e8 f2 f5 ff ff       	call   8001da <sys_page_unmap>
}
  800be8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	57                   	push   %edi
  800bf1:	56                   	push   %esi
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 1c             	sub    $0x1c,%esp
  800bf6:	89 c7                	mov    %eax,%edi
  800bf8:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bfa:	a1 04 40 80 00       	mov    0x804004,%eax
  800bff:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	57                   	push   %edi
  800c06:	e8 d9 0e 00 00       	call   801ae4 <pageref>
  800c0b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0e:	89 34 24             	mov    %esi,(%esp)
  800c11:	e8 ce 0e 00 00       	call   801ae4 <pageref>
  800c16:	83 c4 10             	add    $0x10,%esp
  800c19:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1c:	0f 94 c0             	sete   %al
  800c1f:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c22:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c2b:	39 cb                	cmp    %ecx,%ebx
  800c2d:	74 15                	je     800c44 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c2f:	8b 52 58             	mov    0x58(%edx),%edx
  800c32:	50                   	push   %eax
  800c33:	52                   	push   %edx
  800c34:	53                   	push   %ebx
  800c35:	68 04 1f 80 00       	push   $0x801f04
  800c3a:	e8 e4 04 00 00       	call   801123 <cprintf>
  800c3f:	83 c4 10             	add    $0x10,%esp
  800c42:	eb b6                	jmp    800bfa <_pipeisclosed+0xd>
	}
}
  800c44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 28             	sub    $0x28,%esp
  800c55:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c58:	56                   	push   %esi
  800c59:	e8 17 f7 ff ff       	call   800375 <fd2data>
  800c5e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	bf 00 00 00 00       	mov    $0x0,%edi
  800c68:	eb 4b                	jmp    800cb5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c6a:	89 da                	mov    %ebx,%edx
  800c6c:	89 f0                	mov    %esi,%eax
  800c6e:	e8 7a ff ff ff       	call   800bed <_pipeisclosed>
  800c73:	85 c0                	test   %eax,%eax
  800c75:	75 48                	jne    800cbf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c77:	e8 ba f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c7f:	8b 0b                	mov    (%ebx),%ecx
  800c81:	8d 51 20             	lea    0x20(%ecx),%edx
  800c84:	39 d0                	cmp    %edx,%eax
  800c86:	73 e2                	jae    800c6a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c88:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c92:	89 c2                	mov    %eax,%edx
  800c94:	c1 fa 1f             	sar    $0x1f,%edx
  800c97:	89 d1                	mov    %edx,%ecx
  800c99:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9f:	83 e2 1f             	and    $0x1f,%edx
  800ca2:	29 ca                	sub    %ecx,%edx
  800ca4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cac:	83 c0 01             	add    $0x1,%eax
  800caf:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb2:	83 c7 01             	add    $0x1,%edi
  800cb5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb8:	75 c2                	jne    800c7c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cba:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbd:	eb 05                	jmp    800cc4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cbf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc7:	5b                   	pop    %ebx
  800cc8:	5e                   	pop    %esi
  800cc9:	5f                   	pop    %edi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 18             	sub    $0x18,%esp
  800cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd8:	57                   	push   %edi
  800cd9:	e8 97 f6 ff ff       	call   800375 <fd2data>
  800cde:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	eb 3d                	jmp    800d27 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cea:	85 db                	test   %ebx,%ebx
  800cec:	74 04                	je     800cf2 <devpipe_read+0x26>
				return i;
  800cee:	89 d8                	mov    %ebx,%eax
  800cf0:	eb 44                	jmp    800d36 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cf2:	89 f2                	mov    %esi,%edx
  800cf4:	89 f8                	mov    %edi,%eax
  800cf6:	e8 f2 fe ff ff       	call   800bed <_pipeisclosed>
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	75 32                	jne    800d31 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cff:	e8 32 f4 ff ff       	call   800136 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d04:	8b 06                	mov    (%esi),%eax
  800d06:	3b 46 04             	cmp    0x4(%esi),%eax
  800d09:	74 df                	je     800cea <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d0b:	99                   	cltd   
  800d0c:	c1 ea 1b             	shr    $0x1b,%edx
  800d0f:	01 d0                	add    %edx,%eax
  800d11:	83 e0 1f             	and    $0x1f,%eax
  800d14:	29 d0                	sub    %edx,%eax
  800d16:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d21:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d24:	83 c3 01             	add    $0x1,%ebx
  800d27:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d2a:	75 d8                	jne    800d04 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d2c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d2f:	eb 05                	jmp    800d36 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d31:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    

00800d3e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	56                   	push   %esi
  800d42:	53                   	push   %ebx
  800d43:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d49:	50                   	push   %eax
  800d4a:	e8 3d f6 ff ff       	call   80038c <fd_alloc>
  800d4f:	83 c4 10             	add    $0x10,%esp
  800d52:	89 c2                	mov    %eax,%edx
  800d54:	85 c0                	test   %eax,%eax
  800d56:	0f 88 2c 01 00 00    	js     800e88 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5c:	83 ec 04             	sub    $0x4,%esp
  800d5f:	68 07 04 00 00       	push   $0x407
  800d64:	ff 75 f4             	pushl  -0xc(%ebp)
  800d67:	6a 00                	push   $0x0
  800d69:	e8 e7 f3 ff ff       	call   800155 <sys_page_alloc>
  800d6e:	83 c4 10             	add    $0x10,%esp
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	85 c0                	test   %eax,%eax
  800d75:	0f 88 0d 01 00 00    	js     800e88 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d81:	50                   	push   %eax
  800d82:	e8 05 f6 ff ff       	call   80038c <fd_alloc>
  800d87:	89 c3                	mov    %eax,%ebx
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	0f 88 e2 00 00 00    	js     800e76 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d94:	83 ec 04             	sub    $0x4,%esp
  800d97:	68 07 04 00 00       	push   $0x407
  800d9c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9f:	6a 00                	push   $0x0
  800da1:	e8 af f3 ff ff       	call   800155 <sys_page_alloc>
  800da6:	89 c3                	mov    %eax,%ebx
  800da8:	83 c4 10             	add    $0x10,%esp
  800dab:	85 c0                	test   %eax,%eax
  800dad:	0f 88 c3 00 00 00    	js     800e76 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	ff 75 f4             	pushl  -0xc(%ebp)
  800db9:	e8 b7 f5 ff ff       	call   800375 <fd2data>
  800dbe:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc0:	83 c4 0c             	add    $0xc,%esp
  800dc3:	68 07 04 00 00       	push   $0x407
  800dc8:	50                   	push   %eax
  800dc9:	6a 00                	push   $0x0
  800dcb:	e8 85 f3 ff ff       	call   800155 <sys_page_alloc>
  800dd0:	89 c3                	mov    %eax,%ebx
  800dd2:	83 c4 10             	add    $0x10,%esp
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	0f 88 89 00 00 00    	js     800e66 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddd:	83 ec 0c             	sub    $0xc,%esp
  800de0:	ff 75 f0             	pushl  -0x10(%ebp)
  800de3:	e8 8d f5 ff ff       	call   800375 <fd2data>
  800de8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800def:	50                   	push   %eax
  800df0:	6a 00                	push   $0x0
  800df2:	56                   	push   %esi
  800df3:	6a 00                	push   $0x0
  800df5:	e8 9e f3 ff ff       	call   800198 <sys_page_map>
  800dfa:	89 c3                	mov    %eax,%ebx
  800dfc:	83 c4 20             	add    $0x20,%esp
  800dff:	85 c0                	test   %eax,%eax
  800e01:	78 55                	js     800e58 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0c:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e11:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e18:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e21:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e26:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e2d:	83 ec 0c             	sub    $0xc,%esp
  800e30:	ff 75 f4             	pushl  -0xc(%ebp)
  800e33:	e8 2d f5 ff ff       	call   800365 <fd2num>
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3d:	83 c4 04             	add    $0x4,%esp
  800e40:	ff 75 f0             	pushl  -0x10(%ebp)
  800e43:	e8 1d f5 ff ff       	call   800365 <fd2num>
  800e48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	ba 00 00 00 00       	mov    $0x0,%edx
  800e56:	eb 30                	jmp    800e88 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	56                   	push   %esi
  800e5c:	6a 00                	push   $0x0
  800e5e:	e8 77 f3 ff ff       	call   8001da <sys_page_unmap>
  800e63:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6c:	6a 00                	push   $0x0
  800e6e:	e8 67 f3 ff ff       	call   8001da <sys_page_unmap>
  800e73:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7c:	6a 00                	push   $0x0
  800e7e:	e8 57 f3 ff ff       	call   8001da <sys_page_unmap>
  800e83:	83 c4 10             	add    $0x10,%esp
  800e86:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e88:	89 d0                	mov    %edx,%eax
  800e8a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5d                   	pop    %ebp
  800e90:	c3                   	ret    

00800e91 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9a:	50                   	push   %eax
  800e9b:	ff 75 08             	pushl  0x8(%ebp)
  800e9e:	e8 38 f5 ff ff       	call   8003db <fd_lookup>
  800ea3:	89 c2                	mov    %eax,%edx
  800ea5:	83 c4 10             	add    $0x10,%esp
  800ea8:	85 d2                	test   %edx,%edx
  800eaa:	78 18                	js     800ec4 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eac:	83 ec 0c             	sub    $0xc,%esp
  800eaf:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb2:	e8 be f4 ff ff       	call   800375 <fd2data>
	return _pipeisclosed(fd, p);
  800eb7:	89 c2                	mov    %eax,%edx
  800eb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebc:	e8 2c fd ff ff       	call   800bed <_pipeisclosed>
  800ec1:	83 c4 10             	add    $0x10,%esp
}
  800ec4:	c9                   	leave  
  800ec5:	c3                   	ret    

00800ec6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec6:	55                   	push   %ebp
  800ec7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ec9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ece:	5d                   	pop    %ebp
  800ecf:	c3                   	ret    

00800ed0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed6:	68 35 1f 80 00       	push   $0x801f35
  800edb:	ff 75 0c             	pushl  0xc(%ebp)
  800ede:	e8 c4 07 00 00       	call   8016a7 <strcpy>
	return 0;
}
  800ee3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	57                   	push   %edi
  800eee:	56                   	push   %esi
  800eef:	53                   	push   %ebx
  800ef0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef6:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f01:	eb 2e                	jmp    800f31 <devcons_write+0x47>
		m = n - tot;
  800f03:	8b 55 10             	mov    0x10(%ebp),%edx
  800f06:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f08:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f0d:	83 fa 7f             	cmp    $0x7f,%edx
  800f10:	77 02                	ja     800f14 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f12:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	56                   	push   %esi
  800f18:	03 45 0c             	add    0xc(%ebp),%eax
  800f1b:	50                   	push   %eax
  800f1c:	57                   	push   %edi
  800f1d:	e8 17 09 00 00       	call   801839 <memmove>
		sys_cputs(buf, m);
  800f22:	83 c4 08             	add    $0x8,%esp
  800f25:	56                   	push   %esi
  800f26:	57                   	push   %edi
  800f27:	e8 6d f1 ff ff       	call   800099 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2c:	01 f3                	add    %esi,%ebx
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	89 d8                	mov    %ebx,%eax
  800f33:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f36:	72 cb                	jb     800f03 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3b:	5b                   	pop    %ebx
  800f3c:	5e                   	pop    %esi
  800f3d:	5f                   	pop    %edi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f4b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f4f:	75 07                	jne    800f58 <devcons_read+0x18>
  800f51:	eb 28                	jmp    800f7b <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f53:	e8 de f1 ff ff       	call   800136 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f58:	e8 5a f1 ff ff       	call   8000b7 <sys_cgetc>
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	74 f2                	je     800f53 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f61:	85 c0                	test   %eax,%eax
  800f63:	78 16                	js     800f7b <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f65:	83 f8 04             	cmp    $0x4,%eax
  800f68:	74 0c                	je     800f76 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6d:	88 02                	mov    %al,(%edx)
	return 1;
  800f6f:	b8 01 00 00 00       	mov    $0x1,%eax
  800f74:	eb 05                	jmp    800f7b <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f76:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f89:	6a 01                	push   $0x1
  800f8b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8e:	50                   	push   %eax
  800f8f:	e8 05 f1 ff ff       	call   800099 <sys_cputs>
  800f94:	83 c4 10             	add    $0x10,%esp
}
  800f97:	c9                   	leave  
  800f98:	c3                   	ret    

00800f99 <getchar>:

int
getchar(void)
{
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f9f:	6a 01                	push   $0x1
  800fa1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa4:	50                   	push   %eax
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 98 f6 ff ff       	call   800644 <read>
	if (r < 0)
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 0f                	js     800fc2 <getchar+0x29>
		return r;
	if (r < 1)
  800fb3:	85 c0                	test   %eax,%eax
  800fb5:	7e 06                	jle    800fbd <getchar+0x24>
		return -E_EOF;
	return c;
  800fb7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fbb:	eb 05                	jmp    800fc2 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fbd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    

00800fc4 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fc4:	55                   	push   %ebp
  800fc5:	89 e5                	mov    %esp,%ebp
  800fc7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcd:	50                   	push   %eax
  800fce:	ff 75 08             	pushl  0x8(%ebp)
  800fd1:	e8 05 f4 ff ff       	call   8003db <fd_lookup>
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 11                	js     800fee <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe6:	39 10                	cmp    %edx,(%eax)
  800fe8:	0f 94 c0             	sete   %al
  800feb:	0f b6 c0             	movzbl %al,%eax
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <opencons>:

int
opencons(void)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	e8 8d f3 ff ff       	call   80038c <fd_alloc>
  800fff:	83 c4 10             	add    $0x10,%esp
		return r;
  801002:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801004:	85 c0                	test   %eax,%eax
  801006:	78 3e                	js     801046 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801008:	83 ec 04             	sub    $0x4,%esp
  80100b:	68 07 04 00 00       	push   $0x407
  801010:	ff 75 f4             	pushl  -0xc(%ebp)
  801013:	6a 00                	push   $0x0
  801015:	e8 3b f1 ff ff       	call   800155 <sys_page_alloc>
  80101a:	83 c4 10             	add    $0x10,%esp
		return r;
  80101d:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101f:	85 c0                	test   %eax,%eax
  801021:	78 23                	js     801046 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801023:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801029:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102c:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801031:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801038:	83 ec 0c             	sub    $0xc,%esp
  80103b:	50                   	push   %eax
  80103c:	e8 24 f3 ff ff       	call   800365 <fd2num>
  801041:	89 c2                	mov    %eax,%edx
  801043:	83 c4 10             	add    $0x10,%esp
}
  801046:	89 d0                	mov    %edx,%eax
  801048:	c9                   	leave  
  801049:	c3                   	ret    

0080104a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80104a:	55                   	push   %ebp
  80104b:	89 e5                	mov    %esp,%ebp
  80104d:	56                   	push   %esi
  80104e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80104f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801052:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801058:	e8 ba f0 ff ff       	call   800117 <sys_getenvid>
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	ff 75 0c             	pushl  0xc(%ebp)
  801063:	ff 75 08             	pushl  0x8(%ebp)
  801066:	56                   	push   %esi
  801067:	50                   	push   %eax
  801068:	68 44 1f 80 00       	push   $0x801f44
  80106d:	e8 b1 00 00 00       	call   801123 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801072:	83 c4 18             	add    $0x18,%esp
  801075:	53                   	push   %ebx
  801076:	ff 75 10             	pushl  0x10(%ebp)
  801079:	e8 54 00 00 00       	call   8010d2 <vcprintf>
	cprintf("\n");
  80107e:	c7 04 24 93 1e 80 00 	movl   $0x801e93,(%esp)
  801085:	e8 99 00 00 00       	call   801123 <cprintf>
  80108a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108d:	cc                   	int3   
  80108e:	eb fd                	jmp    80108d <_panic+0x43>

00801090 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	53                   	push   %ebx
  801094:	83 ec 04             	sub    $0x4,%esp
  801097:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80109a:	8b 13                	mov    (%ebx),%edx
  80109c:	8d 42 01             	lea    0x1(%edx),%eax
  80109f:	89 03                	mov    %eax,(%ebx)
  8010a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ad:	75 1a                	jne    8010c9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010af:	83 ec 08             	sub    $0x8,%esp
  8010b2:	68 ff 00 00 00       	push   $0xff
  8010b7:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ba:	50                   	push   %eax
  8010bb:	e8 d9 ef ff ff       	call   800099 <sys_cputs>
		b->idx = 0;
  8010c0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010c9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d0:	c9                   	leave  
  8010d1:	c3                   	ret    

008010d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010db:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010e2:	00 00 00 
	b.cnt = 0;
  8010e5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ec:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ef:	ff 75 0c             	pushl  0xc(%ebp)
  8010f2:	ff 75 08             	pushl  0x8(%ebp)
  8010f5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010fb:	50                   	push   %eax
  8010fc:	68 90 10 80 00       	push   $0x801090
  801101:	e8 4f 01 00 00       	call   801255 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801106:	83 c4 08             	add    $0x8,%esp
  801109:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80110f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801115:	50                   	push   %eax
  801116:	e8 7e ef ff ff       	call   800099 <sys_cputs>

	return b.cnt;
}
  80111b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801121:	c9                   	leave  
  801122:	c3                   	ret    

00801123 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801129:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80112c:	50                   	push   %eax
  80112d:	ff 75 08             	pushl  0x8(%ebp)
  801130:	e8 9d ff ff ff       	call   8010d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  801135:	c9                   	leave  
  801136:	c3                   	ret    

00801137 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801137:	55                   	push   %ebp
  801138:	89 e5                	mov    %esp,%ebp
  80113a:	57                   	push   %edi
  80113b:	56                   	push   %esi
  80113c:	53                   	push   %ebx
  80113d:	83 ec 1c             	sub    $0x1c,%esp
  801140:	89 c7                	mov    %eax,%edi
  801142:	89 d6                	mov    %edx,%esi
  801144:	8b 45 08             	mov    0x8(%ebp),%eax
  801147:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114a:	89 d1                	mov    %edx,%ecx
  80114c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80114f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801152:	8b 45 10             	mov    0x10(%ebp),%eax
  801155:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801158:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80115b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801162:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801165:	72 05                	jb     80116c <printnum+0x35>
  801167:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80116a:	77 3e                	ja     8011aa <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	ff 75 18             	pushl  0x18(%ebp)
  801172:	83 eb 01             	sub    $0x1,%ebx
  801175:	53                   	push   %ebx
  801176:	50                   	push   %eax
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117d:	ff 75 e0             	pushl  -0x20(%ebp)
  801180:	ff 75 dc             	pushl  -0x24(%ebp)
  801183:	ff 75 d8             	pushl  -0x28(%ebp)
  801186:	e8 95 09 00 00       	call   801b20 <__udivdi3>
  80118b:	83 c4 18             	add    $0x18,%esp
  80118e:	52                   	push   %edx
  80118f:	50                   	push   %eax
  801190:	89 f2                	mov    %esi,%edx
  801192:	89 f8                	mov    %edi,%eax
  801194:	e8 9e ff ff ff       	call   801137 <printnum>
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	eb 13                	jmp    8011b1 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	56                   	push   %esi
  8011a2:	ff 75 18             	pushl  0x18(%ebp)
  8011a5:	ff d7                	call   *%edi
  8011a7:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011aa:	83 eb 01             	sub    $0x1,%ebx
  8011ad:	85 db                	test   %ebx,%ebx
  8011af:	7f ed                	jg     80119e <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b1:	83 ec 08             	sub    $0x8,%esp
  8011b4:	56                   	push   %esi
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011be:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c4:	e8 87 0a 00 00       	call   801c50 <__umoddi3>
  8011c9:	83 c4 14             	add    $0x14,%esp
  8011cc:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff d7                	call   *%edi
  8011d6:	83 c4 10             	add    $0x10,%esp
}
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    

008011e1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011e1:	55                   	push   %ebp
  8011e2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e4:	83 fa 01             	cmp    $0x1,%edx
  8011e7:	7e 0e                	jle    8011f7 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011e9:	8b 10                	mov    (%eax),%edx
  8011eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ee:	89 08                	mov    %ecx,(%eax)
  8011f0:	8b 02                	mov    (%edx),%eax
  8011f2:	8b 52 04             	mov    0x4(%edx),%edx
  8011f5:	eb 22                	jmp    801219 <getuint+0x38>
	else if (lflag)
  8011f7:	85 d2                	test   %edx,%edx
  8011f9:	74 10                	je     80120b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011fb:	8b 10                	mov    (%eax),%edx
  8011fd:	8d 4a 04             	lea    0x4(%edx),%ecx
  801200:	89 08                	mov    %ecx,(%eax)
  801202:	8b 02                	mov    (%edx),%eax
  801204:	ba 00 00 00 00       	mov    $0x0,%edx
  801209:	eb 0e                	jmp    801219 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80120b:	8b 10                	mov    (%eax),%edx
  80120d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801210:	89 08                	mov    %ecx,(%eax)
  801212:	8b 02                	mov    (%edx),%eax
  801214:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    

0080121b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801221:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801225:	8b 10                	mov    (%eax),%edx
  801227:	3b 50 04             	cmp    0x4(%eax),%edx
  80122a:	73 0a                	jae    801236 <sprintputch+0x1b>
		*b->buf++ = ch;
  80122c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80122f:	89 08                	mov    %ecx,(%eax)
  801231:	8b 45 08             	mov    0x8(%ebp),%eax
  801234:	88 02                	mov    %al,(%edx)
}
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    

00801238 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80123e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801241:	50                   	push   %eax
  801242:	ff 75 10             	pushl  0x10(%ebp)
  801245:	ff 75 0c             	pushl  0xc(%ebp)
  801248:	ff 75 08             	pushl  0x8(%ebp)
  80124b:	e8 05 00 00 00       	call   801255 <vprintfmt>
	va_end(ap);
  801250:	83 c4 10             	add    $0x10,%esp
}
  801253:	c9                   	leave  
  801254:	c3                   	ret    

00801255 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	57                   	push   %edi
  801259:	56                   	push   %esi
  80125a:	53                   	push   %ebx
  80125b:	83 ec 2c             	sub    $0x2c,%esp
  80125e:	8b 75 08             	mov    0x8(%ebp),%esi
  801261:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801264:	8b 7d 10             	mov    0x10(%ebp),%edi
  801267:	eb 12                	jmp    80127b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801269:	85 c0                	test   %eax,%eax
  80126b:	0f 84 8d 03 00 00    	je     8015fe <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  801271:	83 ec 08             	sub    $0x8,%esp
  801274:	53                   	push   %ebx
  801275:	50                   	push   %eax
  801276:	ff d6                	call   *%esi
  801278:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80127b:	83 c7 01             	add    $0x1,%edi
  80127e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801282:	83 f8 25             	cmp    $0x25,%eax
  801285:	75 e2                	jne    801269 <vprintfmt+0x14>
  801287:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80128b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801292:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801299:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a5:	eb 07                	jmp    8012ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012aa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ae:	8d 47 01             	lea    0x1(%edi),%eax
  8012b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b4:	0f b6 07             	movzbl (%edi),%eax
  8012b7:	0f b6 c8             	movzbl %al,%ecx
  8012ba:	83 e8 23             	sub    $0x23,%eax
  8012bd:	3c 55                	cmp    $0x55,%al
  8012bf:	0f 87 1e 03 00 00    	ja     8015e3 <vprintfmt+0x38e>
  8012c5:	0f b6 c0             	movzbl %al,%eax
  8012c8:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012d2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012d6:	eb d6                	jmp    8012ae <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012db:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012e3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012e6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012ea:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012ed:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012f0:	83 fa 09             	cmp    $0x9,%edx
  8012f3:	77 38                	ja     80132d <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f5:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012f8:	eb e9                	jmp    8012e3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fd:	8d 48 04             	lea    0x4(%eax),%ecx
  801300:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801303:	8b 00                	mov    (%eax),%eax
  801305:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80130b:	eb 26                	jmp    801333 <vprintfmt+0xde>
  80130d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801310:	89 c8                	mov    %ecx,%eax
  801312:	c1 f8 1f             	sar    $0x1f,%eax
  801315:	f7 d0                	not    %eax
  801317:	21 c1                	and    %eax,%ecx
  801319:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131f:	eb 8d                	jmp    8012ae <vprintfmt+0x59>
  801321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801324:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80132b:	eb 81                	jmp    8012ae <vprintfmt+0x59>
  80132d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801330:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801333:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801337:	0f 89 71 ff ff ff    	jns    8012ae <vprintfmt+0x59>
				width = precision, precision = -1;
  80133d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801343:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80134a:	e9 5f ff ff ff       	jmp    8012ae <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80134f:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801355:	e9 54 ff ff ff       	jmp    8012ae <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80135a:	8b 45 14             	mov    0x14(%ebp),%eax
  80135d:	8d 50 04             	lea    0x4(%eax),%edx
  801360:	89 55 14             	mov    %edx,0x14(%ebp)
  801363:	83 ec 08             	sub    $0x8,%esp
  801366:	53                   	push   %ebx
  801367:	ff 30                	pushl  (%eax)
  801369:	ff d6                	call   *%esi
			break;
  80136b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801371:	e9 05 ff ff ff       	jmp    80127b <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  801376:	8b 45 14             	mov    0x14(%ebp),%eax
  801379:	8d 50 04             	lea    0x4(%eax),%edx
  80137c:	89 55 14             	mov    %edx,0x14(%ebp)
  80137f:	8b 00                	mov    (%eax),%eax
  801381:	99                   	cltd   
  801382:	31 d0                	xor    %edx,%eax
  801384:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801386:	83 f8 0f             	cmp    $0xf,%eax
  801389:	7f 0b                	jg     801396 <vprintfmt+0x141>
  80138b:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  801392:	85 d2                	test   %edx,%edx
  801394:	75 18                	jne    8013ae <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  801396:	50                   	push   %eax
  801397:	68 7f 1f 80 00       	push   $0x801f7f
  80139c:	53                   	push   %ebx
  80139d:	56                   	push   %esi
  80139e:	e8 95 fe ff ff       	call   801238 <printfmt>
  8013a3:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a9:	e9 cd fe ff ff       	jmp    80127b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013ae:	52                   	push   %edx
  8013af:	68 dd 1e 80 00       	push   $0x801edd
  8013b4:	53                   	push   %ebx
  8013b5:	56                   	push   %esi
  8013b6:	e8 7d fe ff ff       	call   801238 <printfmt>
  8013bb:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c1:	e9 b5 fe ff ff       	jmp    80127b <vprintfmt+0x26>
  8013c6:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cc:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d2:	8d 50 04             	lea    0x4(%eax),%edx
  8013d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d8:	8b 38                	mov    (%eax),%edi
  8013da:	85 ff                	test   %edi,%edi
  8013dc:	75 05                	jne    8013e3 <vprintfmt+0x18e>
				p = "(null)";
  8013de:	bf 78 1f 80 00       	mov    $0x801f78,%edi
			if (width > 0 && padc != '-')
  8013e3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e7:	0f 84 91 00 00 00    	je     80147e <vprintfmt+0x229>
  8013ed:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8013f1:	0f 8e 95 00 00 00    	jle    80148c <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	51                   	push   %ecx
  8013fb:	57                   	push   %edi
  8013fc:	e8 85 02 00 00       	call   801686 <strnlen>
  801401:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801404:	29 c1                	sub    %eax,%ecx
  801406:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801409:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80140c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801410:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801413:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801416:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801418:	eb 0f                	jmp    801429 <vprintfmt+0x1d4>
					putch(padc, putdat);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	53                   	push   %ebx
  80141e:	ff 75 e0             	pushl  -0x20(%ebp)
  801421:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801423:	83 ef 01             	sub    $0x1,%edi
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	85 ff                	test   %edi,%edi
  80142b:	7f ed                	jg     80141a <vprintfmt+0x1c5>
  80142d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801430:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801433:	89 c8                	mov    %ecx,%eax
  801435:	c1 f8 1f             	sar    $0x1f,%eax
  801438:	f7 d0                	not    %eax
  80143a:	21 c8                	and    %ecx,%eax
  80143c:	29 c1                	sub    %eax,%ecx
  80143e:	89 75 08             	mov    %esi,0x8(%ebp)
  801441:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801444:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801447:	89 cb                	mov    %ecx,%ebx
  801449:	eb 4d                	jmp    801498 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80144b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80144f:	74 1b                	je     80146c <vprintfmt+0x217>
  801451:	0f be c0             	movsbl %al,%eax
  801454:	83 e8 20             	sub    $0x20,%eax
  801457:	83 f8 5e             	cmp    $0x5e,%eax
  80145a:	76 10                	jbe    80146c <vprintfmt+0x217>
					putch('?', putdat);
  80145c:	83 ec 08             	sub    $0x8,%esp
  80145f:	ff 75 0c             	pushl  0xc(%ebp)
  801462:	6a 3f                	push   $0x3f
  801464:	ff 55 08             	call   *0x8(%ebp)
  801467:	83 c4 10             	add    $0x10,%esp
  80146a:	eb 0d                	jmp    801479 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80146c:	83 ec 08             	sub    $0x8,%esp
  80146f:	ff 75 0c             	pushl  0xc(%ebp)
  801472:	52                   	push   %edx
  801473:	ff 55 08             	call   *0x8(%ebp)
  801476:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801479:	83 eb 01             	sub    $0x1,%ebx
  80147c:	eb 1a                	jmp    801498 <vprintfmt+0x243>
  80147e:	89 75 08             	mov    %esi,0x8(%ebp)
  801481:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801484:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801487:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80148a:	eb 0c                	jmp    801498 <vprintfmt+0x243>
  80148c:	89 75 08             	mov    %esi,0x8(%ebp)
  80148f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801492:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801495:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801498:	83 c7 01             	add    $0x1,%edi
  80149b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80149f:	0f be d0             	movsbl %al,%edx
  8014a2:	85 d2                	test   %edx,%edx
  8014a4:	74 23                	je     8014c9 <vprintfmt+0x274>
  8014a6:	85 f6                	test   %esi,%esi
  8014a8:	78 a1                	js     80144b <vprintfmt+0x1f6>
  8014aa:	83 ee 01             	sub    $0x1,%esi
  8014ad:	79 9c                	jns    80144b <vprintfmt+0x1f6>
  8014af:	89 df                	mov    %ebx,%edi
  8014b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b7:	eb 18                	jmp    8014d1 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	53                   	push   %ebx
  8014bd:	6a 20                	push   $0x20
  8014bf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014c1:	83 ef 01             	sub    $0x1,%edi
  8014c4:	83 c4 10             	add    $0x10,%esp
  8014c7:	eb 08                	jmp    8014d1 <vprintfmt+0x27c>
  8014c9:	89 df                	mov    %ebx,%edi
  8014cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8014ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d1:	85 ff                	test   %edi,%edi
  8014d3:	7f e4                	jg     8014b9 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d8:	e9 9e fd ff ff       	jmp    80127b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014dd:	83 fa 01             	cmp    $0x1,%edx
  8014e0:	7e 16                	jle    8014f8 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e5:	8d 50 08             	lea    0x8(%eax),%edx
  8014e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8014eb:	8b 50 04             	mov    0x4(%eax),%edx
  8014ee:	8b 00                	mov    (%eax),%eax
  8014f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f6:	eb 32                	jmp    80152a <vprintfmt+0x2d5>
	else if (lflag)
  8014f8:	85 d2                	test   %edx,%edx
  8014fa:	74 18                	je     801514 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8014fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ff:	8d 50 04             	lea    0x4(%eax),%edx
  801502:	89 55 14             	mov    %edx,0x14(%ebp)
  801505:	8b 00                	mov    (%eax),%eax
  801507:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150a:	89 c1                	mov    %eax,%ecx
  80150c:	c1 f9 1f             	sar    $0x1f,%ecx
  80150f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801512:	eb 16                	jmp    80152a <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801514:	8b 45 14             	mov    0x14(%ebp),%eax
  801517:	8d 50 04             	lea    0x4(%eax),%edx
  80151a:	89 55 14             	mov    %edx,0x14(%ebp)
  80151d:	8b 00                	mov    (%eax),%eax
  80151f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801522:	89 c1                	mov    %eax,%ecx
  801524:	c1 f9 1f             	sar    $0x1f,%ecx
  801527:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80152a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80152d:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801530:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801535:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801539:	79 74                	jns    8015af <vprintfmt+0x35a>
				putch('-', putdat);
  80153b:	83 ec 08             	sub    $0x8,%esp
  80153e:	53                   	push   %ebx
  80153f:	6a 2d                	push   $0x2d
  801541:	ff d6                	call   *%esi
				num = -(long long) num;
  801543:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801546:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801549:	f7 d8                	neg    %eax
  80154b:	83 d2 00             	adc    $0x0,%edx
  80154e:	f7 da                	neg    %edx
  801550:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801553:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801558:	eb 55                	jmp    8015af <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80155a:	8d 45 14             	lea    0x14(%ebp),%eax
  80155d:	e8 7f fc ff ff       	call   8011e1 <getuint>
			base = 10;
  801562:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801567:	eb 46                	jmp    8015af <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801569:	8d 45 14             	lea    0x14(%ebp),%eax
  80156c:	e8 70 fc ff ff       	call   8011e1 <getuint>
			base = 8;
  801571:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801576:	eb 37                	jmp    8015af <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  801578:	83 ec 08             	sub    $0x8,%esp
  80157b:	53                   	push   %ebx
  80157c:	6a 30                	push   $0x30
  80157e:	ff d6                	call   *%esi
			putch('x', putdat);
  801580:	83 c4 08             	add    $0x8,%esp
  801583:	53                   	push   %ebx
  801584:	6a 78                	push   $0x78
  801586:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801588:	8b 45 14             	mov    0x14(%ebp),%eax
  80158b:	8d 50 04             	lea    0x4(%eax),%edx
  80158e:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801591:	8b 00                	mov    (%eax),%eax
  801593:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801598:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80159b:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015a0:	eb 0d                	jmp    8015af <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015a2:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a5:	e8 37 fc ff ff       	call   8011e1 <getuint>
			base = 16;
  8015aa:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015b6:	57                   	push   %edi
  8015b7:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ba:	51                   	push   %ecx
  8015bb:	52                   	push   %edx
  8015bc:	50                   	push   %eax
  8015bd:	89 da                	mov    %ebx,%edx
  8015bf:	89 f0                	mov    %esi,%eax
  8015c1:	e8 71 fb ff ff       	call   801137 <printnum>
			break;
  8015c6:	83 c4 20             	add    $0x20,%esp
  8015c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015cc:	e9 aa fc ff ff       	jmp    80127b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	53                   	push   %ebx
  8015d5:	51                   	push   %ecx
  8015d6:	ff d6                	call   *%esi
			break;
  8015d8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015de:	e9 98 fc ff ff       	jmp    80127b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015e3:	83 ec 08             	sub    $0x8,%esp
  8015e6:	53                   	push   %ebx
  8015e7:	6a 25                	push   $0x25
  8015e9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	eb 03                	jmp    8015f3 <vprintfmt+0x39e>
  8015f0:	83 ef 01             	sub    $0x1,%edi
  8015f3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015f7:	75 f7                	jne    8015f0 <vprintfmt+0x39b>
  8015f9:	e9 7d fc ff ff       	jmp    80127b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801601:	5b                   	pop    %ebx
  801602:	5e                   	pop    %esi
  801603:	5f                   	pop    %edi
  801604:	5d                   	pop    %ebp
  801605:	c3                   	ret    

00801606 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801606:	55                   	push   %ebp
  801607:	89 e5                	mov    %esp,%ebp
  801609:	83 ec 18             	sub    $0x18,%esp
  80160c:	8b 45 08             	mov    0x8(%ebp),%eax
  80160f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801612:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801615:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801619:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80161c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801623:	85 c0                	test   %eax,%eax
  801625:	74 26                	je     80164d <vsnprintf+0x47>
  801627:	85 d2                	test   %edx,%edx
  801629:	7e 22                	jle    80164d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80162b:	ff 75 14             	pushl  0x14(%ebp)
  80162e:	ff 75 10             	pushl  0x10(%ebp)
  801631:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801634:	50                   	push   %eax
  801635:	68 1b 12 80 00       	push   $0x80121b
  80163a:	e8 16 fc ff ff       	call   801255 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80163f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801642:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801645:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801648:	83 c4 10             	add    $0x10,%esp
  80164b:	eb 05                	jmp    801652 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80164d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801652:	c9                   	leave  
  801653:	c3                   	ret    

00801654 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80165d:	50                   	push   %eax
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	ff 75 08             	pushl  0x8(%ebp)
  801667:	e8 9a ff ff ff       	call   801606 <vsnprintf>
	va_end(ap);

	return rc;
}
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801674:	b8 00 00 00 00       	mov    $0x0,%eax
  801679:	eb 03                	jmp    80167e <strlen+0x10>
		n++;
  80167b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80167e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801682:	75 f7                	jne    80167b <strlen+0xd>
		n++;
	return n;
}
  801684:	5d                   	pop    %ebp
  801685:	c3                   	ret    

00801686 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80168f:	ba 00 00 00 00       	mov    $0x0,%edx
  801694:	eb 03                	jmp    801699 <strnlen+0x13>
		n++;
  801696:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801699:	39 c2                	cmp    %eax,%edx
  80169b:	74 08                	je     8016a5 <strnlen+0x1f>
  80169d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016a1:	75 f3                	jne    801696 <strnlen+0x10>
  8016a3:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016a5:	5d                   	pop    %ebp
  8016a6:	c3                   	ret    

008016a7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a7:	55                   	push   %ebp
  8016a8:	89 e5                	mov    %esp,%ebp
  8016aa:	53                   	push   %ebx
  8016ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b1:	89 c2                	mov    %eax,%edx
  8016b3:	83 c2 01             	add    $0x1,%edx
  8016b6:	83 c1 01             	add    $0x1,%ecx
  8016b9:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016bd:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c0:	84 db                	test   %bl,%bl
  8016c2:	75 ef                	jne    8016b3 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016c4:	5b                   	pop    %ebx
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	53                   	push   %ebx
  8016cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016ce:	53                   	push   %ebx
  8016cf:	e8 9a ff ff ff       	call   80166e <strlen>
  8016d4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016d7:	ff 75 0c             	pushl  0xc(%ebp)
  8016da:	01 d8                	add    %ebx,%eax
  8016dc:	50                   	push   %eax
  8016dd:	e8 c5 ff ff ff       	call   8016a7 <strcpy>
	return dst;
}
  8016e2:	89 d8                	mov    %ebx,%eax
  8016e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e7:	c9                   	leave  
  8016e8:	c3                   	ret    

008016e9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	56                   	push   %esi
  8016ed:	53                   	push   %ebx
  8016ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f4:	89 f3                	mov    %esi,%ebx
  8016f6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f9:	89 f2                	mov    %esi,%edx
  8016fb:	eb 0f                	jmp    80170c <strncpy+0x23>
		*dst++ = *src;
  8016fd:	83 c2 01             	add    $0x1,%edx
  801700:	0f b6 01             	movzbl (%ecx),%eax
  801703:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801706:	80 39 01             	cmpb   $0x1,(%ecx)
  801709:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170c:	39 da                	cmp    %ebx,%edx
  80170e:	75 ed                	jne    8016fd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801710:	89 f0                	mov    %esi,%eax
  801712:	5b                   	pop    %ebx
  801713:	5e                   	pop    %esi
  801714:	5d                   	pop    %ebp
  801715:	c3                   	ret    

00801716 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	56                   	push   %esi
  80171a:	53                   	push   %ebx
  80171b:	8b 75 08             	mov    0x8(%ebp),%esi
  80171e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801721:	8b 55 10             	mov    0x10(%ebp),%edx
  801724:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801726:	85 d2                	test   %edx,%edx
  801728:	74 21                	je     80174b <strlcpy+0x35>
  80172a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80172e:	89 f2                	mov    %esi,%edx
  801730:	eb 09                	jmp    80173b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801732:	83 c2 01             	add    $0x1,%edx
  801735:	83 c1 01             	add    $0x1,%ecx
  801738:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80173b:	39 c2                	cmp    %eax,%edx
  80173d:	74 09                	je     801748 <strlcpy+0x32>
  80173f:	0f b6 19             	movzbl (%ecx),%ebx
  801742:	84 db                	test   %bl,%bl
  801744:	75 ec                	jne    801732 <strlcpy+0x1c>
  801746:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801748:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80174b:	29 f0                	sub    %esi,%eax
}
  80174d:	5b                   	pop    %ebx
  80174e:	5e                   	pop    %esi
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801757:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175a:	eb 06                	jmp    801762 <strcmp+0x11>
		p++, q++;
  80175c:	83 c1 01             	add    $0x1,%ecx
  80175f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801762:	0f b6 01             	movzbl (%ecx),%eax
  801765:	84 c0                	test   %al,%al
  801767:	74 04                	je     80176d <strcmp+0x1c>
  801769:	3a 02                	cmp    (%edx),%al
  80176b:	74 ef                	je     80175c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80176d:	0f b6 c0             	movzbl %al,%eax
  801770:	0f b6 12             	movzbl (%edx),%edx
  801773:	29 d0                	sub    %edx,%eax
}
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	53                   	push   %ebx
  80177b:	8b 45 08             	mov    0x8(%ebp),%eax
  80177e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801781:	89 c3                	mov    %eax,%ebx
  801783:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801786:	eb 06                	jmp    80178e <strncmp+0x17>
		n--, p++, q++;
  801788:	83 c0 01             	add    $0x1,%eax
  80178b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80178e:	39 d8                	cmp    %ebx,%eax
  801790:	74 15                	je     8017a7 <strncmp+0x30>
  801792:	0f b6 08             	movzbl (%eax),%ecx
  801795:	84 c9                	test   %cl,%cl
  801797:	74 04                	je     80179d <strncmp+0x26>
  801799:	3a 0a                	cmp    (%edx),%cl
  80179b:	74 eb                	je     801788 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80179d:	0f b6 00             	movzbl (%eax),%eax
  8017a0:	0f b6 12             	movzbl (%edx),%edx
  8017a3:	29 d0                	sub    %edx,%eax
  8017a5:	eb 05                	jmp    8017ac <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017a7:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ac:	5b                   	pop    %ebx
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017b9:	eb 07                	jmp    8017c2 <strchr+0x13>
		if (*s == c)
  8017bb:	38 ca                	cmp    %cl,%dl
  8017bd:	74 0f                	je     8017ce <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017bf:	83 c0 01             	add    $0x1,%eax
  8017c2:	0f b6 10             	movzbl (%eax),%edx
  8017c5:	84 d2                	test   %dl,%dl
  8017c7:	75 f2                	jne    8017bb <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    

008017d0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017da:	eb 03                	jmp    8017df <strfind+0xf>
  8017dc:	83 c0 01             	add    $0x1,%eax
  8017df:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017e2:	84 d2                	test   %dl,%dl
  8017e4:	74 04                	je     8017ea <strfind+0x1a>
  8017e6:	38 ca                	cmp    %cl,%dl
  8017e8:	75 f2                	jne    8017dc <strfind+0xc>
			break;
	return (char *) s;
}
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017ec:	55                   	push   %ebp
  8017ed:	89 e5                	mov    %esp,%ebp
  8017ef:	57                   	push   %edi
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
  8017f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8017f8:	85 c9                	test   %ecx,%ecx
  8017fa:	74 36                	je     801832 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017fc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801802:	75 28                	jne    80182c <memset+0x40>
  801804:	f6 c1 03             	test   $0x3,%cl
  801807:	75 23                	jne    80182c <memset+0x40>
		c &= 0xFF;
  801809:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80180d:	89 d3                	mov    %edx,%ebx
  80180f:	c1 e3 08             	shl    $0x8,%ebx
  801812:	89 d6                	mov    %edx,%esi
  801814:	c1 e6 18             	shl    $0x18,%esi
  801817:	89 d0                	mov    %edx,%eax
  801819:	c1 e0 10             	shl    $0x10,%eax
  80181c:	09 f0                	or     %esi,%eax
  80181e:	09 c2                	or     %eax,%edx
  801820:	89 d0                	mov    %edx,%eax
  801822:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801824:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801827:	fc                   	cld    
  801828:	f3 ab                	rep stos %eax,%es:(%edi)
  80182a:	eb 06                	jmp    801832 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80182c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182f:	fc                   	cld    
  801830:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801832:	89 f8                	mov    %edi,%eax
  801834:	5b                   	pop    %ebx
  801835:	5e                   	pop    %esi
  801836:	5f                   	pop    %edi
  801837:	5d                   	pop    %ebp
  801838:	c3                   	ret    

00801839 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801839:	55                   	push   %ebp
  80183a:	89 e5                	mov    %esp,%ebp
  80183c:	57                   	push   %edi
  80183d:	56                   	push   %esi
  80183e:	8b 45 08             	mov    0x8(%ebp),%eax
  801841:	8b 75 0c             	mov    0xc(%ebp),%esi
  801844:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801847:	39 c6                	cmp    %eax,%esi
  801849:	73 35                	jae    801880 <memmove+0x47>
  80184b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80184e:	39 d0                	cmp    %edx,%eax
  801850:	73 2e                	jae    801880 <memmove+0x47>
		s += n;
		d += n;
  801852:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801855:	89 d6                	mov    %edx,%esi
  801857:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801859:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80185f:	75 13                	jne    801874 <memmove+0x3b>
  801861:	f6 c1 03             	test   $0x3,%cl
  801864:	75 0e                	jne    801874 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801866:	83 ef 04             	sub    $0x4,%edi
  801869:	8d 72 fc             	lea    -0x4(%edx),%esi
  80186c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80186f:	fd                   	std    
  801870:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801872:	eb 09                	jmp    80187d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801874:	83 ef 01             	sub    $0x1,%edi
  801877:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80187a:	fd                   	std    
  80187b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80187d:	fc                   	cld    
  80187e:	eb 1d                	jmp    80189d <memmove+0x64>
  801880:	89 f2                	mov    %esi,%edx
  801882:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801884:	f6 c2 03             	test   $0x3,%dl
  801887:	75 0f                	jne    801898 <memmove+0x5f>
  801889:	f6 c1 03             	test   $0x3,%cl
  80188c:	75 0a                	jne    801898 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80188e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801891:	89 c7                	mov    %eax,%edi
  801893:	fc                   	cld    
  801894:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801896:	eb 05                	jmp    80189d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801898:	89 c7                	mov    %eax,%edi
  80189a:	fc                   	cld    
  80189b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80189d:	5e                   	pop    %esi
  80189e:	5f                   	pop    %edi
  80189f:	5d                   	pop    %ebp
  8018a0:	c3                   	ret    

008018a1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018a4:	ff 75 10             	pushl  0x10(%ebp)
  8018a7:	ff 75 0c             	pushl  0xc(%ebp)
  8018aa:	ff 75 08             	pushl  0x8(%ebp)
  8018ad:	e8 87 ff ff ff       	call   801839 <memmove>
}
  8018b2:	c9                   	leave  
  8018b3:	c3                   	ret    

008018b4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	56                   	push   %esi
  8018b8:	53                   	push   %ebx
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018bf:	89 c6                	mov    %eax,%esi
  8018c1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c4:	eb 1a                	jmp    8018e0 <memcmp+0x2c>
		if (*s1 != *s2)
  8018c6:	0f b6 08             	movzbl (%eax),%ecx
  8018c9:	0f b6 1a             	movzbl (%edx),%ebx
  8018cc:	38 d9                	cmp    %bl,%cl
  8018ce:	74 0a                	je     8018da <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018d0:	0f b6 c1             	movzbl %cl,%eax
  8018d3:	0f b6 db             	movzbl %bl,%ebx
  8018d6:	29 d8                	sub    %ebx,%eax
  8018d8:	eb 0f                	jmp    8018e9 <memcmp+0x35>
		s1++, s2++;
  8018da:	83 c0 01             	add    $0x1,%eax
  8018dd:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e0:	39 f0                	cmp    %esi,%eax
  8018e2:	75 e2                	jne    8018c6 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e9:	5b                   	pop    %ebx
  8018ea:	5e                   	pop    %esi
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    

008018ed <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018ed:	55                   	push   %ebp
  8018ee:	89 e5                	mov    %esp,%ebp
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018f6:	89 c2                	mov    %eax,%edx
  8018f8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018fb:	eb 07                	jmp    801904 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018fd:	38 08                	cmp    %cl,(%eax)
  8018ff:	74 07                	je     801908 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801901:	83 c0 01             	add    $0x1,%eax
  801904:	39 d0                	cmp    %edx,%eax
  801906:	72 f5                	jb     8018fd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801908:	5d                   	pop    %ebp
  801909:	c3                   	ret    

0080190a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	57                   	push   %edi
  80190e:	56                   	push   %esi
  80190f:	53                   	push   %ebx
  801910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801913:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801916:	eb 03                	jmp    80191b <strtol+0x11>
		s++;
  801918:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191b:	0f b6 01             	movzbl (%ecx),%eax
  80191e:	3c 09                	cmp    $0x9,%al
  801920:	74 f6                	je     801918 <strtol+0xe>
  801922:	3c 20                	cmp    $0x20,%al
  801924:	74 f2                	je     801918 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801926:	3c 2b                	cmp    $0x2b,%al
  801928:	75 0a                	jne    801934 <strtol+0x2a>
		s++;
  80192a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80192d:	bf 00 00 00 00       	mov    $0x0,%edi
  801932:	eb 10                	jmp    801944 <strtol+0x3a>
  801934:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801939:	3c 2d                	cmp    $0x2d,%al
  80193b:	75 07                	jne    801944 <strtol+0x3a>
		s++, neg = 1;
  80193d:	8d 49 01             	lea    0x1(%ecx),%ecx
  801940:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801944:	85 db                	test   %ebx,%ebx
  801946:	0f 94 c0             	sete   %al
  801949:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80194f:	75 19                	jne    80196a <strtol+0x60>
  801951:	80 39 30             	cmpb   $0x30,(%ecx)
  801954:	75 14                	jne    80196a <strtol+0x60>
  801956:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80195a:	0f 85 8a 00 00 00    	jne    8019ea <strtol+0xe0>
		s += 2, base = 16;
  801960:	83 c1 02             	add    $0x2,%ecx
  801963:	bb 10 00 00 00       	mov    $0x10,%ebx
  801968:	eb 16                	jmp    801980 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80196a:	84 c0                	test   %al,%al
  80196c:	74 12                	je     801980 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80196e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801973:	80 39 30             	cmpb   $0x30,(%ecx)
  801976:	75 08                	jne    801980 <strtol+0x76>
		s++, base = 8;
  801978:	83 c1 01             	add    $0x1,%ecx
  80197b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801980:	b8 00 00 00 00       	mov    $0x0,%eax
  801985:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801988:	0f b6 11             	movzbl (%ecx),%edx
  80198b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80198e:	89 f3                	mov    %esi,%ebx
  801990:	80 fb 09             	cmp    $0x9,%bl
  801993:	77 08                	ja     80199d <strtol+0x93>
			dig = *s - '0';
  801995:	0f be d2             	movsbl %dl,%edx
  801998:	83 ea 30             	sub    $0x30,%edx
  80199b:	eb 22                	jmp    8019bf <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  80199d:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019a0:	89 f3                	mov    %esi,%ebx
  8019a2:	80 fb 19             	cmp    $0x19,%bl
  8019a5:	77 08                	ja     8019af <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019a7:	0f be d2             	movsbl %dl,%edx
  8019aa:	83 ea 57             	sub    $0x57,%edx
  8019ad:	eb 10                	jmp    8019bf <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019af:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019b2:	89 f3                	mov    %esi,%ebx
  8019b4:	80 fb 19             	cmp    $0x19,%bl
  8019b7:	77 16                	ja     8019cf <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019b9:	0f be d2             	movsbl %dl,%edx
  8019bc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019bf:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019c2:	7d 0f                	jge    8019d3 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019c4:	83 c1 01             	add    $0x1,%ecx
  8019c7:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019cb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019cd:	eb b9                	jmp    801988 <strtol+0x7e>
  8019cf:	89 c2                	mov    %eax,%edx
  8019d1:	eb 02                	jmp    8019d5 <strtol+0xcb>
  8019d3:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019d9:	74 05                	je     8019e0 <strtol+0xd6>
		*endptr = (char *) s;
  8019db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019de:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019e0:	85 ff                	test   %edi,%edi
  8019e2:	74 0c                	je     8019f0 <strtol+0xe6>
  8019e4:	89 d0                	mov    %edx,%eax
  8019e6:	f7 d8                	neg    %eax
  8019e8:	eb 06                	jmp    8019f0 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ea:	84 c0                	test   %al,%al
  8019ec:	75 8a                	jne    801978 <strtol+0x6e>
  8019ee:	eb 90                	jmp    801980 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8019f0:	5b                   	pop    %ebx
  8019f1:	5e                   	pop    %esi
  8019f2:	5f                   	pop    %edi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    

008019f5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	56                   	push   %esi
  8019f9:	53                   	push   %ebx
  8019fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8019fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a00:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a03:	85 f6                	test   %esi,%esi
  801a05:	74 06                	je     801a0d <ipc_recv+0x18>
  801a07:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a0d:	85 db                	test   %ebx,%ebx
  801a0f:	74 06                	je     801a17 <ipc_recv+0x22>
  801a11:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a17:	83 f8 01             	cmp    $0x1,%eax
  801a1a:	19 d2                	sbb    %edx,%edx
  801a1c:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a1e:	83 ec 0c             	sub    $0xc,%esp
  801a21:	50                   	push   %eax
  801a22:	e8 de e8 ff ff       	call   800305 <sys_ipc_recv>
  801a27:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 d2                	test   %edx,%edx
  801a2e:	75 24                	jne    801a54 <ipc_recv+0x5f>
	if (from_env_store)
  801a30:	85 f6                	test   %esi,%esi
  801a32:	74 0a                	je     801a3e <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a34:	a1 04 40 80 00       	mov    0x804004,%eax
  801a39:	8b 40 70             	mov    0x70(%eax),%eax
  801a3c:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a3e:	85 db                	test   %ebx,%ebx
  801a40:	74 0a                	je     801a4c <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a42:	a1 04 40 80 00       	mov    0x804004,%eax
  801a47:	8b 40 74             	mov    0x74(%eax),%eax
  801a4a:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a4c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a51:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a57:	5b                   	pop    %ebx
  801a58:	5e                   	pop    %esi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a5b:	55                   	push   %ebp
  801a5c:	89 e5                	mov    %esp,%ebp
  801a5e:	57                   	push   %edi
  801a5f:	56                   	push   %esi
  801a60:	53                   	push   %ebx
  801a61:	83 ec 0c             	sub    $0xc,%esp
  801a64:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a67:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a6d:	83 fb 01             	cmp    $0x1,%ebx
  801a70:	19 c0                	sbb    %eax,%eax
  801a72:	09 c3                	or     %eax,%ebx
  801a74:	eb 1c                	jmp    801a92 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a79:	74 12                	je     801a8d <ipc_send+0x32>
  801a7b:	50                   	push   %eax
  801a7c:	68 a0 22 80 00       	push   $0x8022a0
  801a81:	6a 36                	push   $0x36
  801a83:	68 b7 22 80 00       	push   $0x8022b7
  801a88:	e8 bd f5 ff ff       	call   80104a <_panic>
		sys_yield();
  801a8d:	e8 a4 e6 ff ff       	call   800136 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a92:	ff 75 14             	pushl  0x14(%ebp)
  801a95:	53                   	push   %ebx
  801a96:	56                   	push   %esi
  801a97:	57                   	push   %edi
  801a98:	e8 45 e8 ff ff       	call   8002e2 <sys_ipc_try_send>
		if (ret == 0) break;
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	75 d2                	jne    801a76 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801aa4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa7:	5b                   	pop    %ebx
  801aa8:	5e                   	pop    %esi
  801aa9:	5f                   	pop    %edi
  801aaa:	5d                   	pop    %ebp
  801aab:	c3                   	ret    

00801aac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab7:	6b d0 78             	imul   $0x78,%eax,%edx
  801aba:	83 c2 50             	add    $0x50,%edx
  801abd:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ac3:	39 ca                	cmp    %ecx,%edx
  801ac5:	75 0d                	jne    801ad4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ac7:	6b c0 78             	imul   $0x78,%eax,%eax
  801aca:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801acf:	8b 40 08             	mov    0x8(%eax),%eax
  801ad2:	eb 0e                	jmp    801ae2 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad4:	83 c0 01             	add    $0x1,%eax
  801ad7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801adc:	75 d9                	jne    801ab7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ade:	66 b8 00 00          	mov    $0x0,%ax
}
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aea:	89 d0                	mov    %edx,%eax
  801aec:	c1 e8 16             	shr    $0x16,%eax
  801aef:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801af6:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afb:	f6 c1 01             	test   $0x1,%cl
  801afe:	74 1d                	je     801b1d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b00:	c1 ea 0c             	shr    $0xc,%edx
  801b03:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b0a:	f6 c2 01             	test   $0x1,%dl
  801b0d:	74 0e                	je     801b1d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b0f:	c1 ea 0c             	shr    $0xc,%edx
  801b12:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b19:	ef 
  801b1a:	0f b7 c0             	movzwl %ax,%eax
}
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    
  801b1f:	90                   	nop

00801b20 <__udivdi3>:
  801b20:	55                   	push   %ebp
  801b21:	57                   	push   %edi
  801b22:	56                   	push   %esi
  801b23:	83 ec 10             	sub    $0x10,%esp
  801b26:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b2a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b2e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b32:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b36:	85 d2                	test   %edx,%edx
  801b38:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b3c:	89 34 24             	mov    %esi,(%esp)
  801b3f:	89 c8                	mov    %ecx,%eax
  801b41:	75 35                	jne    801b78 <__udivdi3+0x58>
  801b43:	39 f1                	cmp    %esi,%ecx
  801b45:	0f 87 bd 00 00 00    	ja     801c08 <__udivdi3+0xe8>
  801b4b:	85 c9                	test   %ecx,%ecx
  801b4d:	89 cd                	mov    %ecx,%ebp
  801b4f:	75 0b                	jne    801b5c <__udivdi3+0x3c>
  801b51:	b8 01 00 00 00       	mov    $0x1,%eax
  801b56:	31 d2                	xor    %edx,%edx
  801b58:	f7 f1                	div    %ecx
  801b5a:	89 c5                	mov    %eax,%ebp
  801b5c:	89 f0                	mov    %esi,%eax
  801b5e:	31 d2                	xor    %edx,%edx
  801b60:	f7 f5                	div    %ebp
  801b62:	89 c6                	mov    %eax,%esi
  801b64:	89 f8                	mov    %edi,%eax
  801b66:	f7 f5                	div    %ebp
  801b68:	89 f2                	mov    %esi,%edx
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	5e                   	pop    %esi
  801b6e:	5f                   	pop    %edi
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    
  801b71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b78:	3b 14 24             	cmp    (%esp),%edx
  801b7b:	77 7b                	ja     801bf8 <__udivdi3+0xd8>
  801b7d:	0f bd f2             	bsr    %edx,%esi
  801b80:	83 f6 1f             	xor    $0x1f,%esi
  801b83:	0f 84 97 00 00 00    	je     801c20 <__udivdi3+0x100>
  801b89:	bd 20 00 00 00       	mov    $0x20,%ebp
  801b8e:	89 d7                	mov    %edx,%edi
  801b90:	89 f1                	mov    %esi,%ecx
  801b92:	29 f5                	sub    %esi,%ebp
  801b94:	d3 e7                	shl    %cl,%edi
  801b96:	89 c2                	mov    %eax,%edx
  801b98:	89 e9                	mov    %ebp,%ecx
  801b9a:	d3 ea                	shr    %cl,%edx
  801b9c:	89 f1                	mov    %esi,%ecx
  801b9e:	09 fa                	or     %edi,%edx
  801ba0:	8b 3c 24             	mov    (%esp),%edi
  801ba3:	d3 e0                	shl    %cl,%eax
  801ba5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ba9:	89 e9                	mov    %ebp,%ecx
  801bab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801baf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801bb3:	89 fa                	mov    %edi,%edx
  801bb5:	d3 ea                	shr    %cl,%edx
  801bb7:	89 f1                	mov    %esi,%ecx
  801bb9:	d3 e7                	shl    %cl,%edi
  801bbb:	89 e9                	mov    %ebp,%ecx
  801bbd:	d3 e8                	shr    %cl,%eax
  801bbf:	09 c7                	or     %eax,%edi
  801bc1:	89 f8                	mov    %edi,%eax
  801bc3:	f7 74 24 08          	divl   0x8(%esp)
  801bc7:	89 d5                	mov    %edx,%ebp
  801bc9:	89 c7                	mov    %eax,%edi
  801bcb:	f7 64 24 0c          	mull   0xc(%esp)
  801bcf:	39 d5                	cmp    %edx,%ebp
  801bd1:	89 14 24             	mov    %edx,(%esp)
  801bd4:	72 11                	jb     801be7 <__udivdi3+0xc7>
  801bd6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801bda:	89 f1                	mov    %esi,%ecx
  801bdc:	d3 e2                	shl    %cl,%edx
  801bde:	39 c2                	cmp    %eax,%edx
  801be0:	73 5e                	jae    801c40 <__udivdi3+0x120>
  801be2:	3b 2c 24             	cmp    (%esp),%ebp
  801be5:	75 59                	jne    801c40 <__udivdi3+0x120>
  801be7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801bea:	31 f6                	xor    %esi,%esi
  801bec:	89 f2                	mov    %esi,%edx
  801bee:	83 c4 10             	add    $0x10,%esp
  801bf1:	5e                   	pop    %esi
  801bf2:	5f                   	pop    %edi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    
  801bf5:	8d 76 00             	lea    0x0(%esi),%esi
  801bf8:	31 f6                	xor    %esi,%esi
  801bfa:	31 c0                	xor    %eax,%eax
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	83 c4 10             	add    $0x10,%esp
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    
  801c05:	8d 76 00             	lea    0x0(%esi),%esi
  801c08:	89 f2                	mov    %esi,%edx
  801c0a:	31 f6                	xor    %esi,%esi
  801c0c:	89 f8                	mov    %edi,%eax
  801c0e:	f7 f1                	div    %ecx
  801c10:	89 f2                	mov    %esi,%edx
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	5e                   	pop    %esi
  801c16:	5f                   	pop    %edi
  801c17:	5d                   	pop    %ebp
  801c18:	c3                   	ret    
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c24:	76 0b                	jbe    801c31 <__udivdi3+0x111>
  801c26:	31 c0                	xor    %eax,%eax
  801c28:	3b 14 24             	cmp    (%esp),%edx
  801c2b:	0f 83 37 ff ff ff    	jae    801b68 <__udivdi3+0x48>
  801c31:	b8 01 00 00 00       	mov    $0x1,%eax
  801c36:	e9 2d ff ff ff       	jmp    801b68 <__udivdi3+0x48>
  801c3b:	90                   	nop
  801c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 f8                	mov    %edi,%eax
  801c42:	31 f6                	xor    %esi,%esi
  801c44:	e9 1f ff ff ff       	jmp    801b68 <__udivdi3+0x48>
  801c49:	66 90                	xchg   %ax,%ax
  801c4b:	66 90                	xchg   %ax,%ax
  801c4d:	66 90                	xchg   %ax,%ax
  801c4f:	90                   	nop

00801c50 <__umoddi3>:
  801c50:	55                   	push   %ebp
  801c51:	57                   	push   %edi
  801c52:	56                   	push   %esi
  801c53:	83 ec 20             	sub    $0x20,%esp
  801c56:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c5a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c5e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c62:	89 c6                	mov    %eax,%esi
  801c64:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c68:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c6c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801c70:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801c74:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801c78:	89 74 24 18          	mov    %esi,0x18(%esp)
  801c7c:	85 c0                	test   %eax,%eax
  801c7e:	89 c2                	mov    %eax,%edx
  801c80:	75 1e                	jne    801ca0 <__umoddi3+0x50>
  801c82:	39 f7                	cmp    %esi,%edi
  801c84:	76 52                	jbe    801cd8 <__umoddi3+0x88>
  801c86:	89 c8                	mov    %ecx,%eax
  801c88:	89 f2                	mov    %esi,%edx
  801c8a:	f7 f7                	div    %edi
  801c8c:	89 d0                	mov    %edx,%eax
  801c8e:	31 d2                	xor    %edx,%edx
  801c90:	83 c4 20             	add    $0x20,%esp
  801c93:	5e                   	pop    %esi
  801c94:	5f                   	pop    %edi
  801c95:	5d                   	pop    %ebp
  801c96:	c3                   	ret    
  801c97:	89 f6                	mov    %esi,%esi
  801c99:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801ca0:	39 f0                	cmp    %esi,%eax
  801ca2:	77 5c                	ja     801d00 <__umoddi3+0xb0>
  801ca4:	0f bd e8             	bsr    %eax,%ebp
  801ca7:	83 f5 1f             	xor    $0x1f,%ebp
  801caa:	75 64                	jne    801d10 <__umoddi3+0xc0>
  801cac:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801cb0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801cb4:	0f 86 f6 00 00 00    	jbe    801db0 <__umoddi3+0x160>
  801cba:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cbe:	0f 82 ec 00 00 00    	jb     801db0 <__umoddi3+0x160>
  801cc4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cc8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801ccc:	83 c4 20             	add    $0x20,%esp
  801ccf:	5e                   	pop    %esi
  801cd0:	5f                   	pop    %edi
  801cd1:	5d                   	pop    %ebp
  801cd2:	c3                   	ret    
  801cd3:	90                   	nop
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	85 ff                	test   %edi,%edi
  801cda:	89 fd                	mov    %edi,%ebp
  801cdc:	75 0b                	jne    801ce9 <__umoddi3+0x99>
  801cde:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce3:	31 d2                	xor    %edx,%edx
  801ce5:	f7 f7                	div    %edi
  801ce7:	89 c5                	mov    %eax,%ebp
  801ce9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801ced:	31 d2                	xor    %edx,%edx
  801cef:	f7 f5                	div    %ebp
  801cf1:	89 c8                	mov    %ecx,%eax
  801cf3:	f7 f5                	div    %ebp
  801cf5:	eb 95                	jmp    801c8c <__umoddi3+0x3c>
  801cf7:	89 f6                	mov    %esi,%esi
  801cf9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d00:	89 c8                	mov    %ecx,%eax
  801d02:	89 f2                	mov    %esi,%edx
  801d04:	83 c4 20             	add    $0x20,%esp
  801d07:	5e                   	pop    %esi
  801d08:	5f                   	pop    %edi
  801d09:	5d                   	pop    %ebp
  801d0a:	c3                   	ret    
  801d0b:	90                   	nop
  801d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d10:	b8 20 00 00 00       	mov    $0x20,%eax
  801d15:	89 e9                	mov    %ebp,%ecx
  801d17:	29 e8                	sub    %ebp,%eax
  801d19:	d3 e2                	shl    %cl,%edx
  801d1b:	89 c7                	mov    %eax,%edi
  801d1d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d21:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d25:	89 f9                	mov    %edi,%ecx
  801d27:	d3 e8                	shr    %cl,%eax
  801d29:	89 c1                	mov    %eax,%ecx
  801d2b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d2f:	09 d1                	or     %edx,%ecx
  801d31:	89 fa                	mov    %edi,%edx
  801d33:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d37:	89 e9                	mov    %ebp,%ecx
  801d39:	d3 e0                	shl    %cl,%eax
  801d3b:	89 f9                	mov    %edi,%ecx
  801d3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d41:	89 f0                	mov    %esi,%eax
  801d43:	d3 e8                	shr    %cl,%eax
  801d45:	89 e9                	mov    %ebp,%ecx
  801d47:	89 c7                	mov    %eax,%edi
  801d49:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d4d:	d3 e6                	shl    %cl,%esi
  801d4f:	89 d1                	mov    %edx,%ecx
  801d51:	89 fa                	mov    %edi,%edx
  801d53:	d3 e8                	shr    %cl,%eax
  801d55:	89 e9                	mov    %ebp,%ecx
  801d57:	09 f0                	or     %esi,%eax
  801d59:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d5d:	f7 74 24 10          	divl   0x10(%esp)
  801d61:	d3 e6                	shl    %cl,%esi
  801d63:	89 d1                	mov    %edx,%ecx
  801d65:	f7 64 24 0c          	mull   0xc(%esp)
  801d69:	39 d1                	cmp    %edx,%ecx
  801d6b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d6f:	89 d7                	mov    %edx,%edi
  801d71:	89 c6                	mov    %eax,%esi
  801d73:	72 0a                	jb     801d7f <__umoddi3+0x12f>
  801d75:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801d79:	73 10                	jae    801d8b <__umoddi3+0x13b>
  801d7b:	39 d1                	cmp    %edx,%ecx
  801d7d:	75 0c                	jne    801d8b <__umoddi3+0x13b>
  801d7f:	89 d7                	mov    %edx,%edi
  801d81:	89 c6                	mov    %eax,%esi
  801d83:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801d87:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801d8b:	89 ca                	mov    %ecx,%edx
  801d8d:	89 e9                	mov    %ebp,%ecx
  801d8f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d93:	29 f0                	sub    %esi,%eax
  801d95:	19 fa                	sbb    %edi,%edx
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801d9e:	89 d7                	mov    %edx,%edi
  801da0:	d3 e7                	shl    %cl,%edi
  801da2:	89 e9                	mov    %ebp,%ecx
  801da4:	09 f8                	or     %edi,%eax
  801da6:	d3 ea                	shr    %cl,%edx
  801da8:	83 c4 20             	add    $0x20,%esp
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    
  801daf:	90                   	nop
  801db0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801db4:	29 f9                	sub    %edi,%ecx
  801db6:	19 c6                	sbb    %eax,%esi
  801db8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dbc:	89 74 24 18          	mov    %esi,0x18(%esp)
  801dc0:	e9 ff fe ff ff       	jmp    801cc4 <__umoddi3+0x74>
