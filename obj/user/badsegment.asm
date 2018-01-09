
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 78             	imul   $0x78,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
  80007a:	83 c4 10             	add    $0x10,%esp
#endif
}
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 a7 04 00 00       	call   800536 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
  800099:	83 c4 10             	add    $0x10,%esp
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 0a 1e 80 00       	push   $0x801e0a
  800108:	6a 23                	push   $0x23
  80010a:	68 27 1e 80 00       	push   $0x801e27
  80010f:	e8 3b 0f 00 00       	call   80104f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 0a 1e 80 00       	push   $0x801e0a
  800189:	6a 23                	push   $0x23
  80018b:	68 27 1e 80 00       	push   $0x801e27
  800190:	e8 ba 0e 00 00       	call   80104f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 0a 1e 80 00       	push   $0x801e0a
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 27 1e 80 00       	push   $0x801e27
  8001d2:	e8 78 0e 00 00       	call   80104f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 0a 1e 80 00       	push   $0x801e0a
  80020d:	6a 23                	push   $0x23
  80020f:	68 27 1e 80 00       	push   $0x801e27
  800214:	e8 36 0e 00 00       	call   80104f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 0a 1e 80 00       	push   $0x801e0a
  80024f:	6a 23                	push   $0x23
  800251:	68 27 1e 80 00       	push   $0x801e27
  800256:	e8 f4 0d 00 00       	call   80104f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 0a 1e 80 00       	push   $0x801e0a
  800291:	6a 23                	push   $0x23
  800293:	68 27 1e 80 00       	push   $0x801e27
  800298:	e8 b2 0d 00 00       	call   80104f <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 0a 1e 80 00       	push   $0x801e0a
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 27 1e 80 00       	push   $0x801e27
  8002da:	e8 70 0d 00 00       	call   80104f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 0a 1e 80 00       	push   $0x801e0a
  800337:	6a 23                	push   $0x23
  800339:	68 27 1e 80 00       	push   $0x801e27
  80033e:	e8 0c 0d 00 00       	call   80104f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <sys_gettime>:

int sys_gettime(void)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800351:	ba 00 00 00 00       	mov    $0x0,%edx
  800356:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035b:	89 d1                	mov    %edx,%ecx
  80035d:	89 d3                	mov    %edx,%ebx
  80035f:	89 d7                	mov    %edx,%edi
  800361:	89 d6                	mov    %edx,%esi
  800363:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800365:	5b                   	pop    %ebx
  800366:	5e                   	pop    %esi
  800367:	5f                   	pop    %edi
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036d:	8b 45 08             	mov    0x8(%ebp),%eax
  800370:	05 00 00 00 30       	add    $0x30000000,%eax
  800375:	c1 e8 0c             	shr    $0xc,%eax
}
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80037d:	8b 45 08             	mov    0x8(%ebp),%eax
  800380:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800385:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80038a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80039c:	89 c2                	mov    %eax,%edx
  80039e:	c1 ea 16             	shr    $0x16,%edx
  8003a1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a8:	f6 c2 01             	test   $0x1,%dl
  8003ab:	74 11                	je     8003be <fd_alloc+0x2d>
  8003ad:	89 c2                	mov    %eax,%edx
  8003af:	c1 ea 0c             	shr    $0xc,%edx
  8003b2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b9:	f6 c2 01             	test   $0x1,%dl
  8003bc:	75 09                	jne    8003c7 <fd_alloc+0x36>
			*fd_store = fd;
  8003be:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c5:	eb 17                	jmp    8003de <fd_alloc+0x4d>
  8003c7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003cc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d1:	75 c9                	jne    80039c <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e6:	83 f8 1f             	cmp    $0x1f,%eax
  8003e9:	77 36                	ja     800421 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003eb:	c1 e0 0c             	shl    $0xc,%eax
  8003ee:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003f3:	89 c2                	mov    %eax,%edx
  8003f5:	c1 ea 16             	shr    $0x16,%edx
  8003f8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ff:	f6 c2 01             	test   $0x1,%dl
  800402:	74 24                	je     800428 <fd_lookup+0x48>
  800404:	89 c2                	mov    %eax,%edx
  800406:	c1 ea 0c             	shr    $0xc,%edx
  800409:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800410:	f6 c2 01             	test   $0x1,%dl
  800413:	74 1a                	je     80042f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800415:	8b 55 0c             	mov    0xc(%ebp),%edx
  800418:	89 02                	mov    %eax,(%edx)
	return 0;
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	eb 13                	jmp    800434 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800421:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800426:	eb 0c                	jmp    800434 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800428:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042d:	eb 05                	jmp    800434 <fd_lookup+0x54>
  80042f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800434:	5d                   	pop    %ebp
  800435:	c3                   	ret    

00800436 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800436:	55                   	push   %ebp
  800437:	89 e5                	mov    %esp,%ebp
  800439:	83 ec 08             	sub    $0x8,%esp
  80043c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043f:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800444:	eb 13                	jmp    800459 <dev_lookup+0x23>
  800446:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800449:	39 08                	cmp    %ecx,(%eax)
  80044b:	75 0c                	jne    800459 <dev_lookup+0x23>
			*dev = devtab[i];
  80044d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800450:	89 01                	mov    %eax,(%ecx)
			return 0;
  800452:	b8 00 00 00 00       	mov    $0x0,%eax
  800457:	eb 2e                	jmp    800487 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800459:	8b 02                	mov    (%edx),%eax
  80045b:	85 c0                	test   %eax,%eax
  80045d:	75 e7                	jne    800446 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045f:	a1 04 40 80 00       	mov    0x804004,%eax
  800464:	8b 40 48             	mov    0x48(%eax),%eax
  800467:	83 ec 04             	sub    $0x4,%esp
  80046a:	51                   	push   %ecx
  80046b:	50                   	push   %eax
  80046c:	68 38 1e 80 00       	push   $0x801e38
  800471:	e8 b2 0c 00 00       	call   801128 <cprintf>
	*dev = 0;
  800476:	8b 45 0c             	mov    0xc(%ebp),%eax
  800479:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800487:	c9                   	leave  
  800488:	c3                   	ret    

00800489 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	56                   	push   %esi
  80048d:	53                   	push   %ebx
  80048e:	83 ec 10             	sub    $0x10,%esp
  800491:	8b 75 08             	mov    0x8(%ebp),%esi
  800494:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049a:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80049b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a1:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a4:	50                   	push   %eax
  8004a5:	e8 36 ff ff ff       	call   8003e0 <fd_lookup>
  8004aa:	83 c4 08             	add    $0x8,%esp
  8004ad:	85 c0                	test   %eax,%eax
  8004af:	78 05                	js     8004b6 <fd_close+0x2d>
	    || fd != fd2)
  8004b1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b4:	74 0b                	je     8004c1 <fd_close+0x38>
		return (must_exist ? r : 0);
  8004b6:	80 fb 01             	cmp    $0x1,%bl
  8004b9:	19 d2                	sbb    %edx,%edx
  8004bb:	f7 d2                	not    %edx
  8004bd:	21 d0                	and    %edx,%eax
  8004bf:	eb 41                	jmp    800502 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c7:	50                   	push   %eax
  8004c8:	ff 36                	pushl  (%esi)
  8004ca:	e8 67 ff ff ff       	call   800436 <dev_lookup>
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 1a                	js     8004f2 <fd_close+0x69>
		if (dev->dev_close)
  8004d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004db:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004de:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	74 0b                	je     8004f2 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8004e7:	83 ec 0c             	sub    $0xc,%esp
  8004ea:	56                   	push   %esi
  8004eb:	ff d0                	call   *%eax
  8004ed:	89 c3                	mov    %eax,%ebx
  8004ef:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	56                   	push   %esi
  8004f6:	6a 00                	push   $0x0
  8004f8:	e8 e2 fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	89 d8                	mov    %ebx,%eax
}
  800502:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800505:	5b                   	pop    %ebx
  800506:	5e                   	pop    %esi
  800507:	5d                   	pop    %ebp
  800508:	c3                   	ret    

00800509 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800509:	55                   	push   %ebp
  80050a:	89 e5                	mov    %esp,%ebp
  80050c:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800512:	50                   	push   %eax
  800513:	ff 75 08             	pushl  0x8(%ebp)
  800516:	e8 c5 fe ff ff       	call   8003e0 <fd_lookup>
  80051b:	89 c2                	mov    %eax,%edx
  80051d:	83 c4 08             	add    $0x8,%esp
  800520:	85 d2                	test   %edx,%edx
  800522:	78 10                	js     800534 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800524:	83 ec 08             	sub    $0x8,%esp
  800527:	6a 01                	push   $0x1
  800529:	ff 75 f4             	pushl  -0xc(%ebp)
  80052c:	e8 58 ff ff ff       	call   800489 <fd_close>
  800531:	83 c4 10             	add    $0x10,%esp
}
  800534:	c9                   	leave  
  800535:	c3                   	ret    

00800536 <close_all>:

void
close_all(void)
{
  800536:	55                   	push   %ebp
  800537:	89 e5                	mov    %esp,%ebp
  800539:	53                   	push   %ebx
  80053a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80053d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800542:	83 ec 0c             	sub    $0xc,%esp
  800545:	53                   	push   %ebx
  800546:	e8 be ff ff ff       	call   800509 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054b:	83 c3 01             	add    $0x1,%ebx
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	83 fb 20             	cmp    $0x20,%ebx
  800554:	75 ec                	jne    800542 <close_all+0xc>
		close(i);
}
  800556:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800559:	c9                   	leave  
  80055a:	c3                   	ret    

0080055b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055b:	55                   	push   %ebp
  80055c:	89 e5                	mov    %esp,%ebp
  80055e:	57                   	push   %edi
  80055f:	56                   	push   %esi
  800560:	53                   	push   %ebx
  800561:	83 ec 2c             	sub    $0x2c,%esp
  800564:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800567:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80056a:	50                   	push   %eax
  80056b:	ff 75 08             	pushl  0x8(%ebp)
  80056e:	e8 6d fe ff ff       	call   8003e0 <fd_lookup>
  800573:	89 c2                	mov    %eax,%edx
  800575:	83 c4 08             	add    $0x8,%esp
  800578:	85 d2                	test   %edx,%edx
  80057a:	0f 88 c1 00 00 00    	js     800641 <dup+0xe6>
		return r;
	close(newfdnum);
  800580:	83 ec 0c             	sub    $0xc,%esp
  800583:	56                   	push   %esi
  800584:	e8 80 ff ff ff       	call   800509 <close>

	newfd = INDEX2FD(newfdnum);
  800589:	89 f3                	mov    %esi,%ebx
  80058b:	c1 e3 0c             	shl    $0xc,%ebx
  80058e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800594:	83 c4 04             	add    $0x4,%esp
  800597:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059a:	e8 db fd ff ff       	call   80037a <fd2data>
  80059f:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a1:	89 1c 24             	mov    %ebx,(%esp)
  8005a4:	e8 d1 fd ff ff       	call   80037a <fd2data>
  8005a9:	83 c4 10             	add    $0x10,%esp
  8005ac:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005af:	89 f8                	mov    %edi,%eax
  8005b1:	c1 e8 16             	shr    $0x16,%eax
  8005b4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005bb:	a8 01                	test   $0x1,%al
  8005bd:	74 37                	je     8005f6 <dup+0x9b>
  8005bf:	89 f8                	mov    %edi,%eax
  8005c1:	c1 e8 0c             	shr    $0xc,%eax
  8005c4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005cb:	f6 c2 01             	test   $0x1,%dl
  8005ce:	74 26                	je     8005f6 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d7:	83 ec 0c             	sub    $0xc,%esp
  8005da:	25 07 0e 00 00       	and    $0xe07,%eax
  8005df:	50                   	push   %eax
  8005e0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e3:	6a 00                	push   $0x0
  8005e5:	57                   	push   %edi
  8005e6:	6a 00                	push   $0x0
  8005e8:	e8 b0 fb ff ff       	call   80019d <sys_page_map>
  8005ed:	89 c7                	mov    %eax,%edi
  8005ef:	83 c4 20             	add    $0x20,%esp
  8005f2:	85 c0                	test   %eax,%eax
  8005f4:	78 2e                	js     800624 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f9:	89 d0                	mov    %edx,%eax
  8005fb:	c1 e8 0c             	shr    $0xc,%eax
  8005fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800605:	83 ec 0c             	sub    $0xc,%esp
  800608:	25 07 0e 00 00       	and    $0xe07,%eax
  80060d:	50                   	push   %eax
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	52                   	push   %edx
  800612:	6a 00                	push   $0x0
  800614:	e8 84 fb ff ff       	call   80019d <sys_page_map>
  800619:	89 c7                	mov    %eax,%edi
  80061b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80061e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800620:	85 ff                	test   %edi,%edi
  800622:	79 1d                	jns    800641 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800624:	83 ec 08             	sub    $0x8,%esp
  800627:	53                   	push   %ebx
  800628:	6a 00                	push   $0x0
  80062a:	e8 b0 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062f:	83 c4 08             	add    $0x8,%esp
  800632:	ff 75 d4             	pushl  -0x2c(%ebp)
  800635:	6a 00                	push   $0x0
  800637:	e8 a3 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80063c:	83 c4 10             	add    $0x10,%esp
  80063f:	89 f8                	mov    %edi,%eax
}
  800641:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800644:	5b                   	pop    %ebx
  800645:	5e                   	pop    %esi
  800646:	5f                   	pop    %edi
  800647:	5d                   	pop    %ebp
  800648:	c3                   	ret    

00800649 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800649:	55                   	push   %ebp
  80064a:	89 e5                	mov    %esp,%ebp
  80064c:	53                   	push   %ebx
  80064d:	83 ec 14             	sub    $0x14,%esp
  800650:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800653:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800656:	50                   	push   %eax
  800657:	53                   	push   %ebx
  800658:	e8 83 fd ff ff       	call   8003e0 <fd_lookup>
  80065d:	83 c4 08             	add    $0x8,%esp
  800660:	89 c2                	mov    %eax,%edx
  800662:	85 c0                	test   %eax,%eax
  800664:	78 6d                	js     8006d3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80066c:	50                   	push   %eax
  80066d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800670:	ff 30                	pushl  (%eax)
  800672:	e8 bf fd ff ff       	call   800436 <dev_lookup>
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 4c                	js     8006ca <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800681:	8b 42 08             	mov    0x8(%edx),%eax
  800684:	83 e0 03             	and    $0x3,%eax
  800687:	83 f8 01             	cmp    $0x1,%eax
  80068a:	75 21                	jne    8006ad <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80068c:	a1 04 40 80 00       	mov    0x804004,%eax
  800691:	8b 40 48             	mov    0x48(%eax),%eax
  800694:	83 ec 04             	sub    $0x4,%esp
  800697:	53                   	push   %ebx
  800698:	50                   	push   %eax
  800699:	68 79 1e 80 00       	push   $0x801e79
  80069e:	e8 85 0a 00 00       	call   801128 <cprintf>
		return -E_INVAL;
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006ab:	eb 26                	jmp    8006d3 <read+0x8a>
	}
	if (!dev->dev_read)
  8006ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b0:	8b 40 08             	mov    0x8(%eax),%eax
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	74 17                	je     8006ce <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b7:	83 ec 04             	sub    $0x4,%esp
  8006ba:	ff 75 10             	pushl  0x10(%ebp)
  8006bd:	ff 75 0c             	pushl  0xc(%ebp)
  8006c0:	52                   	push   %edx
  8006c1:	ff d0                	call   *%eax
  8006c3:	89 c2                	mov    %eax,%edx
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	eb 09                	jmp    8006d3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ca:	89 c2                	mov    %eax,%edx
  8006cc:	eb 05                	jmp    8006d3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ce:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d3:	89 d0                	mov    %edx,%eax
  8006d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d8:	c9                   	leave  
  8006d9:	c3                   	ret    

008006da <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	57                   	push   %edi
  8006de:	56                   	push   %esi
  8006df:	53                   	push   %ebx
  8006e0:	83 ec 0c             	sub    $0xc,%esp
  8006e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ee:	eb 21                	jmp    800711 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f0:	83 ec 04             	sub    $0x4,%esp
  8006f3:	89 f0                	mov    %esi,%eax
  8006f5:	29 d8                	sub    %ebx,%eax
  8006f7:	50                   	push   %eax
  8006f8:	89 d8                	mov    %ebx,%eax
  8006fa:	03 45 0c             	add    0xc(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	57                   	push   %edi
  8006ff:	e8 45 ff ff ff       	call   800649 <read>
		if (m < 0)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	85 c0                	test   %eax,%eax
  800709:	78 0c                	js     800717 <readn+0x3d>
			return m;
		if (m == 0)
  80070b:	85 c0                	test   %eax,%eax
  80070d:	74 06                	je     800715 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070f:	01 c3                	add    %eax,%ebx
  800711:	39 f3                	cmp    %esi,%ebx
  800713:	72 db                	jb     8006f0 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800715:	89 d8                	mov    %ebx,%eax
}
  800717:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071a:	5b                   	pop    %ebx
  80071b:	5e                   	pop    %esi
  80071c:	5f                   	pop    %edi
  80071d:	5d                   	pop    %ebp
  80071e:	c3                   	ret    

0080071f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	53                   	push   %ebx
  800723:	83 ec 14             	sub    $0x14,%esp
  800726:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800729:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80072c:	50                   	push   %eax
  80072d:	53                   	push   %ebx
  80072e:	e8 ad fc ff ff       	call   8003e0 <fd_lookup>
  800733:	83 c4 08             	add    $0x8,%esp
  800736:	89 c2                	mov    %eax,%edx
  800738:	85 c0                	test   %eax,%eax
  80073a:	78 68                	js     8007a4 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800746:	ff 30                	pushl  (%eax)
  800748:	e8 e9 fc ff ff       	call   800436 <dev_lookup>
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 c0                	test   %eax,%eax
  800752:	78 47                	js     80079b <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800754:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800757:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80075b:	75 21                	jne    80077e <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075d:	a1 04 40 80 00       	mov    0x804004,%eax
  800762:	8b 40 48             	mov    0x48(%eax),%eax
  800765:	83 ec 04             	sub    $0x4,%esp
  800768:	53                   	push   %ebx
  800769:	50                   	push   %eax
  80076a:	68 95 1e 80 00       	push   $0x801e95
  80076f:	e8 b4 09 00 00       	call   801128 <cprintf>
		return -E_INVAL;
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80077c:	eb 26                	jmp    8007a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800781:	8b 52 0c             	mov    0xc(%edx),%edx
  800784:	85 d2                	test   %edx,%edx
  800786:	74 17                	je     80079f <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800788:	83 ec 04             	sub    $0x4,%esp
  80078b:	ff 75 10             	pushl  0x10(%ebp)
  80078e:	ff 75 0c             	pushl  0xc(%ebp)
  800791:	50                   	push   %eax
  800792:	ff d2                	call   *%edx
  800794:	89 c2                	mov    %eax,%edx
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	eb 09                	jmp    8007a4 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079b:	89 c2                	mov    %eax,%edx
  80079d:	eb 05                	jmp    8007a4 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a4:	89 d0                	mov    %edx,%eax
  8007a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b1:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	ff 75 08             	pushl  0x8(%ebp)
  8007b8:	e8 23 fc ff ff       	call   8003e0 <fd_lookup>
  8007bd:	83 c4 08             	add    $0x8,%esp
  8007c0:	85 c0                	test   %eax,%eax
  8007c2:	78 0e                	js     8007d2 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d2:	c9                   	leave  
  8007d3:	c3                   	ret    

008007d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	53                   	push   %ebx
  8007d8:	83 ec 14             	sub    $0x14,%esp
  8007db:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007de:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e1:	50                   	push   %eax
  8007e2:	53                   	push   %ebx
  8007e3:	e8 f8 fb ff ff       	call   8003e0 <fd_lookup>
  8007e8:	83 c4 08             	add    $0x8,%esp
  8007eb:	89 c2                	mov    %eax,%edx
  8007ed:	85 c0                	test   %eax,%eax
  8007ef:	78 65                	js     800856 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f7:	50                   	push   %eax
  8007f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fb:	ff 30                	pushl  (%eax)
  8007fd:	e8 34 fc ff ff       	call   800436 <dev_lookup>
  800802:	83 c4 10             	add    $0x10,%esp
  800805:	85 c0                	test   %eax,%eax
  800807:	78 44                	js     80084d <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800809:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80080c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800810:	75 21                	jne    800833 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800812:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800817:	8b 40 48             	mov    0x48(%eax),%eax
  80081a:	83 ec 04             	sub    $0x4,%esp
  80081d:	53                   	push   %ebx
  80081e:	50                   	push   %eax
  80081f:	68 58 1e 80 00       	push   $0x801e58
  800824:	e8 ff 08 00 00       	call   801128 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800831:	eb 23                	jmp    800856 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800833:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800836:	8b 52 18             	mov    0x18(%edx),%edx
  800839:	85 d2                	test   %edx,%edx
  80083b:	74 14                	je     800851 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80083d:	83 ec 08             	sub    $0x8,%esp
  800840:	ff 75 0c             	pushl  0xc(%ebp)
  800843:	50                   	push   %eax
  800844:	ff d2                	call   *%edx
  800846:	89 c2                	mov    %eax,%edx
  800848:	83 c4 10             	add    $0x10,%esp
  80084b:	eb 09                	jmp    800856 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084d:	89 c2                	mov    %eax,%edx
  80084f:	eb 05                	jmp    800856 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800851:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800856:	89 d0                	mov    %edx,%eax
  800858:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085b:	c9                   	leave  
  80085c:	c3                   	ret    

0080085d <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	53                   	push   %ebx
  800861:	83 ec 14             	sub    $0x14,%esp
  800864:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800867:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086a:	50                   	push   %eax
  80086b:	ff 75 08             	pushl  0x8(%ebp)
  80086e:	e8 6d fb ff ff       	call   8003e0 <fd_lookup>
  800873:	83 c4 08             	add    $0x8,%esp
  800876:	89 c2                	mov    %eax,%edx
  800878:	85 c0                	test   %eax,%eax
  80087a:	78 58                	js     8008d4 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800886:	ff 30                	pushl  (%eax)
  800888:	e8 a9 fb ff ff       	call   800436 <dev_lookup>
  80088d:	83 c4 10             	add    $0x10,%esp
  800890:	85 c0                	test   %eax,%eax
  800892:	78 37                	js     8008cb <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800894:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800897:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80089b:	74 32                	je     8008cf <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80089d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a7:	00 00 00 
	stat->st_isdir = 0;
  8008aa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b1:	00 00 00 
	stat->st_dev = dev;
  8008b4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	53                   	push   %ebx
  8008be:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c1:	ff 50 14             	call   *0x14(%eax)
  8008c4:	89 c2                	mov    %eax,%edx
  8008c6:	83 c4 10             	add    $0x10,%esp
  8008c9:	eb 09                	jmp    8008d4 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cb:	89 c2                	mov    %eax,%edx
  8008cd:	eb 05                	jmp    8008d4 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cf:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d4:	89 d0                	mov    %edx,%eax
  8008d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d9:	c9                   	leave  
  8008da:	c3                   	ret    

008008db <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	6a 00                	push   $0x0
  8008e5:	ff 75 08             	pushl  0x8(%ebp)
  8008e8:	e8 e7 01 00 00       	call   800ad4 <open>
  8008ed:	89 c3                	mov    %eax,%ebx
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	85 db                	test   %ebx,%ebx
  8008f4:	78 1b                	js     800911 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	ff 75 0c             	pushl  0xc(%ebp)
  8008fc:	53                   	push   %ebx
  8008fd:	e8 5b ff ff ff       	call   80085d <fstat>
  800902:	89 c6                	mov    %eax,%esi
	close(fd);
  800904:	89 1c 24             	mov    %ebx,(%esp)
  800907:	e8 fd fb ff ff       	call   800509 <close>
	return r;
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	89 f0                	mov    %esi,%eax
}
  800911:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800914:	5b                   	pop    %ebx
  800915:	5e                   	pop    %esi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	56                   	push   %esi
  80091c:	53                   	push   %ebx
  80091d:	89 c6                	mov    %eax,%esi
  80091f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800921:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800928:	75 12                	jne    80093c <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092a:	83 ec 0c             	sub    $0xc,%esp
  80092d:	6a 03                	push   $0x3
  80092f:	e8 7d 11 00 00       	call   801ab1 <ipc_find_env>
  800934:	a3 00 40 80 00       	mov    %eax,0x804000
  800939:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80093c:	6a 07                	push   $0x7
  80093e:	68 00 50 80 00       	push   $0x805000
  800943:	56                   	push   %esi
  800944:	ff 35 00 40 80 00    	pushl  0x804000
  80094a:	e8 11 11 00 00       	call   801a60 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094f:	83 c4 0c             	add    $0xc,%esp
  800952:	6a 00                	push   $0x0
  800954:	53                   	push   %ebx
  800955:	6a 00                	push   $0x0
  800957:	e8 9e 10 00 00       	call   8019fa <ipc_recv>
}
  80095c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095f:	5b                   	pop    %ebx
  800960:	5e                   	pop    %esi
  800961:	5d                   	pop    %ebp
  800962:	c3                   	ret    

00800963 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 40 0c             	mov    0xc(%eax),%eax
  80096f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800974:	8b 45 0c             	mov    0xc(%ebp),%eax
  800977:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80097c:	ba 00 00 00 00       	mov    $0x0,%edx
  800981:	b8 02 00 00 00       	mov    $0x2,%eax
  800986:	e8 8d ff ff ff       	call   800918 <fsipc>
}
  80098b:	c9                   	leave  
  80098c:	c3                   	ret    

0080098d <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 40 0c             	mov    0xc(%eax),%eax
  800999:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099e:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a8:	e8 6b ff ff ff       	call   800918 <fsipc>
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	53                   	push   %ebx
  8009b3:	83 ec 04             	sub    $0x4,%esp
  8009b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bc:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bf:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c9:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ce:	e8 45 ff ff ff       	call   800918 <fsipc>
  8009d3:	89 c2                	mov    %eax,%edx
  8009d5:	85 d2                	test   %edx,%edx
  8009d7:	78 2c                	js     800a05 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d9:	83 ec 08             	sub    $0x8,%esp
  8009dc:	68 00 50 80 00       	push   $0x805000
  8009e1:	53                   	push   %ebx
  8009e2:	e8 c5 0c 00 00       	call   8016ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009ec:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009fd:	83 c4 10             	add    $0x10,%esp
  800a00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a08:	c9                   	leave  
  800a09:	c3                   	ret    

00800a0a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a0a:	55                   	push   %ebp
  800a0b:	89 e5                	mov    %esp,%ebp
  800a0d:	83 ec 08             	sub    $0x8,%esp
  800a10:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
  800a16:	8b 52 0c             	mov    0xc(%edx),%edx
  800a19:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a1f:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a24:	76 05                	jbe    800a2b <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a26:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a2b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a30:	83 ec 04             	sub    $0x4,%esp
  800a33:	50                   	push   %eax
  800a34:	ff 75 0c             	pushl  0xc(%ebp)
  800a37:	68 08 50 80 00       	push   $0x805008
  800a3c:	e8 fd 0d 00 00       	call   80183e <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a41:	ba 00 00 00 00       	mov    $0x0,%edx
  800a46:	b8 04 00 00 00       	mov    $0x4,%eax
  800a4b:	e8 c8 fe ff ff       	call   800918 <fsipc>
	return write;
}
  800a50:	c9                   	leave  
  800a51:	c3                   	ret    

00800a52 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a52:	55                   	push   %ebp
  800a53:	89 e5                	mov    %esp,%ebp
  800a55:	56                   	push   %esi
  800a56:	53                   	push   %ebx
  800a57:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a5d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a60:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a65:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a70:	b8 03 00 00 00       	mov    $0x3,%eax
  800a75:	e8 9e fe ff ff       	call   800918 <fsipc>
  800a7a:	89 c3                	mov    %eax,%ebx
  800a7c:	85 c0                	test   %eax,%eax
  800a7e:	78 4b                	js     800acb <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a80:	39 c6                	cmp    %eax,%esi
  800a82:	73 16                	jae    800a9a <devfile_read+0x48>
  800a84:	68 c4 1e 80 00       	push   $0x801ec4
  800a89:	68 cb 1e 80 00       	push   $0x801ecb
  800a8e:	6a 7c                	push   $0x7c
  800a90:	68 e0 1e 80 00       	push   $0x801ee0
  800a95:	e8 b5 05 00 00       	call   80104f <_panic>
	assert(r <= PGSIZE);
  800a9a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9f:	7e 16                	jle    800ab7 <devfile_read+0x65>
  800aa1:	68 eb 1e 80 00       	push   $0x801eeb
  800aa6:	68 cb 1e 80 00       	push   $0x801ecb
  800aab:	6a 7d                	push   $0x7d
  800aad:	68 e0 1e 80 00       	push   $0x801ee0
  800ab2:	e8 98 05 00 00       	call   80104f <_panic>
	memmove(buf, &fsipcbuf, r);
  800ab7:	83 ec 04             	sub    $0x4,%esp
  800aba:	50                   	push   %eax
  800abb:	68 00 50 80 00       	push   $0x805000
  800ac0:	ff 75 0c             	pushl  0xc(%ebp)
  800ac3:	e8 76 0d 00 00       	call   80183e <memmove>
	return r;
  800ac8:	83 c4 10             	add    $0x10,%esp
}
  800acb:	89 d8                	mov    %ebx,%eax
  800acd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	53                   	push   %ebx
  800ad8:	83 ec 20             	sub    $0x20,%esp
  800adb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ade:	53                   	push   %ebx
  800adf:	e8 8f 0b 00 00       	call   801673 <strlen>
  800ae4:	83 c4 10             	add    $0x10,%esp
  800ae7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aec:	7f 67                	jg     800b55 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aee:	83 ec 0c             	sub    $0xc,%esp
  800af1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af4:	50                   	push   %eax
  800af5:	e8 97 f8 ff ff       	call   800391 <fd_alloc>
  800afa:	83 c4 10             	add    $0x10,%esp
		return r;
  800afd:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aff:	85 c0                	test   %eax,%eax
  800b01:	78 57                	js     800b5a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b03:	83 ec 08             	sub    $0x8,%esp
  800b06:	53                   	push   %ebx
  800b07:	68 00 50 80 00       	push   $0x805000
  800b0c:	e8 9b 0b 00 00       	call   8016ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b14:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b19:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	e8 f2 fd ff ff       	call   800918 <fsipc>
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	83 c4 10             	add    $0x10,%esp
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	79 14                	jns    800b43 <open+0x6f>
		fd_close(fd, 0);
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	6a 00                	push   $0x0
  800b34:	ff 75 f4             	pushl  -0xc(%ebp)
  800b37:	e8 4d f9 ff ff       	call   800489 <fd_close>
		return r;
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	89 da                	mov    %ebx,%edx
  800b41:	eb 17                	jmp    800b5a <open+0x86>
	}

	return fd2num(fd);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	ff 75 f4             	pushl  -0xc(%ebp)
  800b49:	e8 1c f8 ff ff       	call   80036a <fd2num>
  800b4e:	89 c2                	mov    %eax,%edx
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	eb 05                	jmp    800b5a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b55:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5a:	89 d0                	mov    %edx,%eax
  800b5c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b67:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b71:	e8 a2 fd ff ff       	call   800918 <fsipc>
}
  800b76:	c9                   	leave  
  800b77:	c3                   	ret    

00800b78 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	ff 75 08             	pushl  0x8(%ebp)
  800b86:	e8 ef f7 ff ff       	call   80037a <fd2data>
  800b8b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8d:	83 c4 08             	add    $0x8,%esp
  800b90:	68 f7 1e 80 00       	push   $0x801ef7
  800b95:	53                   	push   %ebx
  800b96:	e8 11 0b 00 00       	call   8016ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9b:	8b 56 04             	mov    0x4(%esi),%edx
  800b9e:	89 d0                	mov    %edx,%eax
  800ba0:	2b 06                	sub    (%esi),%eax
  800ba2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800baf:	00 00 00 
	stat->st_dev = &devpipe;
  800bb2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb9:	30 80 00 
	return 0;
}
  800bbc:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc4:	5b                   	pop    %ebx
  800bc5:	5e                   	pop    %esi
  800bc6:	5d                   	pop    %ebp
  800bc7:	c3                   	ret    

00800bc8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	53                   	push   %ebx
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd2:	53                   	push   %ebx
  800bd3:	6a 00                	push   $0x0
  800bd5:	e8 05 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bda:	89 1c 24             	mov    %ebx,(%esp)
  800bdd:	e8 98 f7 ff ff       	call   80037a <fd2data>
  800be2:	83 c4 08             	add    $0x8,%esp
  800be5:	50                   	push   %eax
  800be6:	6a 00                	push   $0x0
  800be8:	e8 f2 f5 ff ff       	call   8001df <sys_page_unmap>
}
  800bed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 1c             	sub    $0x1c,%esp
  800bfb:	89 c7                	mov    %eax,%edi
  800bfd:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bff:	a1 04 40 80 00       	mov    0x804004,%eax
  800c04:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c07:	83 ec 0c             	sub    $0xc,%esp
  800c0a:	57                   	push   %edi
  800c0b:	e8 d9 0e 00 00       	call   801ae9 <pageref>
  800c10:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c13:	89 34 24             	mov    %esi,(%esp)
  800c16:	e8 ce 0e 00 00       	call   801ae9 <pageref>
  800c1b:	83 c4 10             	add    $0x10,%esp
  800c1e:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c21:	0f 94 c0             	sete   %al
  800c24:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c27:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c2d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c30:	39 cb                	cmp    %ecx,%ebx
  800c32:	74 15                	je     800c49 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c34:	8b 52 58             	mov    0x58(%edx),%edx
  800c37:	50                   	push   %eax
  800c38:	52                   	push   %edx
  800c39:	53                   	push   %ebx
  800c3a:	68 04 1f 80 00       	push   $0x801f04
  800c3f:	e8 e4 04 00 00       	call   801128 <cprintf>
  800c44:	83 c4 10             	add    $0x10,%esp
  800c47:	eb b6                	jmp    800bff <_pipeisclosed+0xd>
	}
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 28             	sub    $0x28,%esp
  800c5a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c5d:	56                   	push   %esi
  800c5e:	e8 17 f7 ff ff       	call   80037a <fd2data>
  800c63:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c65:	83 c4 10             	add    $0x10,%esp
  800c68:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6d:	eb 4b                	jmp    800cba <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c6f:	89 da                	mov    %ebx,%edx
  800c71:	89 f0                	mov    %esi,%eax
  800c73:	e8 7a ff ff ff       	call   800bf2 <_pipeisclosed>
  800c78:	85 c0                	test   %eax,%eax
  800c7a:	75 48                	jne    800cc4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c7c:	e8 ba f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c81:	8b 43 04             	mov    0x4(%ebx),%eax
  800c84:	8b 0b                	mov    (%ebx),%ecx
  800c86:	8d 51 20             	lea    0x20(%ecx),%edx
  800c89:	39 d0                	cmp    %edx,%eax
  800c8b:	73 e2                	jae    800c6f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c90:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c94:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c97:	89 c2                	mov    %eax,%edx
  800c99:	c1 fa 1f             	sar    $0x1f,%edx
  800c9c:	89 d1                	mov    %edx,%ecx
  800c9e:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca4:	83 e2 1f             	and    $0x1f,%edx
  800ca7:	29 ca                	sub    %ecx,%edx
  800ca9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb1:	83 c0 01             	add    $0x1,%eax
  800cb4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb7:	83 c7 01             	add    $0x1,%edi
  800cba:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cbd:	75 c2                	jne    800c81 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cbf:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc2:	eb 05                	jmp    800cc9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 18             	sub    $0x18,%esp
  800cda:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cdd:	57                   	push   %edi
  800cde:	e8 97 f6 ff ff       	call   80037a <fd2data>
  800ce3:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce5:	83 c4 10             	add    $0x10,%esp
  800ce8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ced:	eb 3d                	jmp    800d2c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cef:	85 db                	test   %ebx,%ebx
  800cf1:	74 04                	je     800cf7 <devpipe_read+0x26>
				return i;
  800cf3:	89 d8                	mov    %ebx,%eax
  800cf5:	eb 44                	jmp    800d3b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cf7:	89 f2                	mov    %esi,%edx
  800cf9:	89 f8                	mov    %edi,%eax
  800cfb:	e8 f2 fe ff ff       	call   800bf2 <_pipeisclosed>
  800d00:	85 c0                	test   %eax,%eax
  800d02:	75 32                	jne    800d36 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d04:	e8 32 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d09:	8b 06                	mov    (%esi),%eax
  800d0b:	3b 46 04             	cmp    0x4(%esi),%eax
  800d0e:	74 df                	je     800cef <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d10:	99                   	cltd   
  800d11:	c1 ea 1b             	shr    $0x1b,%edx
  800d14:	01 d0                	add    %edx,%eax
  800d16:	83 e0 1f             	and    $0x1f,%eax
  800d19:	29 d0                	sub    %edx,%eax
  800d1b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d26:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d29:	83 c3 01             	add    $0x1,%ebx
  800d2c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d2f:	75 d8                	jne    800d09 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d31:	8b 45 10             	mov    0x10(%ebp),%eax
  800d34:	eb 05                	jmp    800d3b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d36:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3e:	5b                   	pop    %ebx
  800d3f:	5e                   	pop    %esi
  800d40:	5f                   	pop    %edi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d4e:	50                   	push   %eax
  800d4f:	e8 3d f6 ff ff       	call   800391 <fd_alloc>
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	89 c2                	mov    %eax,%edx
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	0f 88 2c 01 00 00    	js     800e8d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	68 07 04 00 00       	push   $0x407
  800d69:	ff 75 f4             	pushl  -0xc(%ebp)
  800d6c:	6a 00                	push   $0x0
  800d6e:	e8 e7 f3 ff ff       	call   80015a <sys_page_alloc>
  800d73:	83 c4 10             	add    $0x10,%esp
  800d76:	89 c2                	mov    %eax,%edx
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	0f 88 0d 01 00 00    	js     800e8d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d86:	50                   	push   %eax
  800d87:	e8 05 f6 ff ff       	call   800391 <fd_alloc>
  800d8c:	89 c3                	mov    %eax,%ebx
  800d8e:	83 c4 10             	add    $0x10,%esp
  800d91:	85 c0                	test   %eax,%eax
  800d93:	0f 88 e2 00 00 00    	js     800e7b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d99:	83 ec 04             	sub    $0x4,%esp
  800d9c:	68 07 04 00 00       	push   $0x407
  800da1:	ff 75 f0             	pushl  -0x10(%ebp)
  800da4:	6a 00                	push   $0x0
  800da6:	e8 af f3 ff ff       	call   80015a <sys_page_alloc>
  800dab:	89 c3                	mov    %eax,%ebx
  800dad:	83 c4 10             	add    $0x10,%esp
  800db0:	85 c0                	test   %eax,%eax
  800db2:	0f 88 c3 00 00 00    	js     800e7b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	ff 75 f4             	pushl  -0xc(%ebp)
  800dbe:	e8 b7 f5 ff ff       	call   80037a <fd2data>
  800dc3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc5:	83 c4 0c             	add    $0xc,%esp
  800dc8:	68 07 04 00 00       	push   $0x407
  800dcd:	50                   	push   %eax
  800dce:	6a 00                	push   $0x0
  800dd0:	e8 85 f3 ff ff       	call   80015a <sys_page_alloc>
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	83 c4 10             	add    $0x10,%esp
  800dda:	85 c0                	test   %eax,%eax
  800ddc:	0f 88 89 00 00 00    	js     800e6b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de2:	83 ec 0c             	sub    $0xc,%esp
  800de5:	ff 75 f0             	pushl  -0x10(%ebp)
  800de8:	e8 8d f5 ff ff       	call   80037a <fd2data>
  800ded:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df4:	50                   	push   %eax
  800df5:	6a 00                	push   $0x0
  800df7:	56                   	push   %esi
  800df8:	6a 00                	push   $0x0
  800dfa:	e8 9e f3 ff ff       	call   80019d <sys_page_map>
  800dff:	89 c3                	mov    %eax,%ebx
  800e01:	83 c4 20             	add    $0x20,%esp
  800e04:	85 c0                	test   %eax,%eax
  800e06:	78 55                	js     800e5d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e11:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e16:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e1d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e23:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e26:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e28:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	ff 75 f4             	pushl  -0xc(%ebp)
  800e38:	e8 2d f5 ff ff       	call   80036a <fd2num>
  800e3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e40:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e42:	83 c4 04             	add    $0x4,%esp
  800e45:	ff 75 f0             	pushl  -0x10(%ebp)
  800e48:	e8 1d f5 ff ff       	call   80036a <fd2num>
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5b:	eb 30                	jmp    800e8d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	56                   	push   %esi
  800e61:	6a 00                	push   $0x0
  800e63:	e8 77 f3 ff ff       	call   8001df <sys_page_unmap>
  800e68:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e71:	6a 00                	push   $0x0
  800e73:	e8 67 f3 ff ff       	call   8001df <sys_page_unmap>
  800e78:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e7b:	83 ec 08             	sub    $0x8,%esp
  800e7e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e81:	6a 00                	push   $0x0
  800e83:	e8 57 f3 ff ff       	call   8001df <sys_page_unmap>
  800e88:	83 c4 10             	add    $0x10,%esp
  800e8b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e8d:	89 d0                	mov    %edx,%eax
  800e8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e92:	5b                   	pop    %ebx
  800e93:	5e                   	pop    %esi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    

00800e96 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e96:	55                   	push   %ebp
  800e97:	89 e5                	mov    %esp,%ebp
  800e99:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e9c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9f:	50                   	push   %eax
  800ea0:	ff 75 08             	pushl  0x8(%ebp)
  800ea3:	e8 38 f5 ff ff       	call   8003e0 <fd_lookup>
  800ea8:	89 c2                	mov    %eax,%edx
  800eaa:	83 c4 10             	add    $0x10,%esp
  800ead:	85 d2                	test   %edx,%edx
  800eaf:	78 18                	js     800ec9 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eb1:	83 ec 0c             	sub    $0xc,%esp
  800eb4:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb7:	e8 be f4 ff ff       	call   80037a <fd2data>
	return _pipeisclosed(fd, p);
  800ebc:	89 c2                	mov    %eax,%edx
  800ebe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec1:	e8 2c fd ff ff       	call   800bf2 <_pipeisclosed>
  800ec6:	83 c4 10             	add    $0x10,%esp
}
  800ec9:	c9                   	leave  
  800eca:	c3                   	ret    

00800ecb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ecb:	55                   	push   %ebp
  800ecc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ece:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800edb:	68 35 1f 80 00       	push   $0x801f35
  800ee0:	ff 75 0c             	pushl  0xc(%ebp)
  800ee3:	e8 c4 07 00 00       	call   8016ac <strcpy>
	return 0;
}
  800ee8:	b8 00 00 00 00       	mov    $0x0,%eax
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800efb:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f00:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f06:	eb 2e                	jmp    800f36 <devcons_write+0x47>
		m = n - tot;
  800f08:	8b 55 10             	mov    0x10(%ebp),%edx
  800f0b:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f0d:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f12:	83 fa 7f             	cmp    $0x7f,%edx
  800f15:	77 02                	ja     800f19 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f17:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f19:	83 ec 04             	sub    $0x4,%esp
  800f1c:	56                   	push   %esi
  800f1d:	03 45 0c             	add    0xc(%ebp),%eax
  800f20:	50                   	push   %eax
  800f21:	57                   	push   %edi
  800f22:	e8 17 09 00 00       	call   80183e <memmove>
		sys_cputs(buf, m);
  800f27:	83 c4 08             	add    $0x8,%esp
  800f2a:	56                   	push   %esi
  800f2b:	57                   	push   %edi
  800f2c:	e8 6d f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f31:	01 f3                	add    %esi,%ebx
  800f33:	83 c4 10             	add    $0x10,%esp
  800f36:	89 d8                	mov    %ebx,%eax
  800f38:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f3b:	72 cb                	jb     800f08 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f4b:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f50:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f54:	75 07                	jne    800f5d <devcons_read+0x18>
  800f56:	eb 28                	jmp    800f80 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f58:	e8 de f1 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f5d:	e8 5a f1 ff ff       	call   8000bc <sys_cgetc>
  800f62:	85 c0                	test   %eax,%eax
  800f64:	74 f2                	je     800f58 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f66:	85 c0                	test   %eax,%eax
  800f68:	78 16                	js     800f80 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f6a:	83 f8 04             	cmp    $0x4,%eax
  800f6d:	74 0c                	je     800f7b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f6f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f72:	88 02                	mov    %al,(%edx)
	return 1;
  800f74:	b8 01 00 00 00       	mov    $0x1,%eax
  800f79:	eb 05                	jmp    800f80 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f7b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f80:	c9                   	leave  
  800f81:	c3                   	ret    

00800f82 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f8e:	6a 01                	push   $0x1
  800f90:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	e8 05 f1 ff ff       	call   80009e <sys_cputs>
  800f99:	83 c4 10             	add    $0x10,%esp
}
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <getchar>:

int
getchar(void)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fa4:	6a 01                	push   $0x1
  800fa6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa9:	50                   	push   %eax
  800faa:	6a 00                	push   $0x0
  800fac:	e8 98 f6 ff ff       	call   800649 <read>
	if (r < 0)
  800fb1:	83 c4 10             	add    $0x10,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 0f                	js     800fc7 <getchar+0x29>
		return r;
	if (r < 1)
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	7e 06                	jle    800fc2 <getchar+0x24>
		return -E_EOF;
	return c;
  800fbc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc0:	eb 05                	jmp    800fc7 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fc2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fc7:	c9                   	leave  
  800fc8:	c3                   	ret    

00800fc9 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd2:	50                   	push   %eax
  800fd3:	ff 75 08             	pushl  0x8(%ebp)
  800fd6:	e8 05 f4 ff ff       	call   8003e0 <fd_lookup>
  800fdb:	83 c4 10             	add    $0x10,%esp
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	78 11                	js     800ff3 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fe2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800feb:	39 10                	cmp    %edx,(%eax)
  800fed:	0f 94 c0             	sete   %al
  800ff0:	0f b6 c0             	movzbl %al,%eax
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <opencons>:

int
opencons(void)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffe:	50                   	push   %eax
  800fff:	e8 8d f3 ff ff       	call   800391 <fd_alloc>
  801004:	83 c4 10             	add    $0x10,%esp
		return r;
  801007:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	78 3e                	js     80104b <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	68 07 04 00 00       	push   $0x407
  801015:	ff 75 f4             	pushl  -0xc(%ebp)
  801018:	6a 00                	push   $0x0
  80101a:	e8 3b f1 ff ff       	call   80015a <sys_page_alloc>
  80101f:	83 c4 10             	add    $0x10,%esp
		return r;
  801022:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801024:	85 c0                	test   %eax,%eax
  801026:	78 23                	js     80104b <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801028:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801031:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801033:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801036:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80103d:	83 ec 0c             	sub    $0xc,%esp
  801040:	50                   	push   %eax
  801041:	e8 24 f3 ff ff       	call   80036a <fd2num>
  801046:	89 c2                	mov    %eax,%edx
  801048:	83 c4 10             	add    $0x10,%esp
}
  80104b:	89 d0                	mov    %edx,%eax
  80104d:	c9                   	leave  
  80104e:	c3                   	ret    

0080104f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	56                   	push   %esi
  801053:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801054:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801057:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80105d:	e8 ba f0 ff ff       	call   80011c <sys_getenvid>
  801062:	83 ec 0c             	sub    $0xc,%esp
  801065:	ff 75 0c             	pushl  0xc(%ebp)
  801068:	ff 75 08             	pushl  0x8(%ebp)
  80106b:	56                   	push   %esi
  80106c:	50                   	push   %eax
  80106d:	68 44 1f 80 00       	push   $0x801f44
  801072:	e8 b1 00 00 00       	call   801128 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801077:	83 c4 18             	add    $0x18,%esp
  80107a:	53                   	push   %ebx
  80107b:	ff 75 10             	pushl  0x10(%ebp)
  80107e:	e8 54 00 00 00       	call   8010d7 <vcprintf>
	cprintf("\n");
  801083:	c7 04 24 93 1e 80 00 	movl   $0x801e93,(%esp)
  80108a:	e8 99 00 00 00       	call   801128 <cprintf>
  80108f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801092:	cc                   	int3   
  801093:	eb fd                	jmp    801092 <_panic+0x43>

00801095 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	53                   	push   %ebx
  801099:	83 ec 04             	sub    $0x4,%esp
  80109c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80109f:	8b 13                	mov    (%ebx),%edx
  8010a1:	8d 42 01             	lea    0x1(%edx),%eax
  8010a4:	89 03                	mov    %eax,(%ebx)
  8010a6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010b2:	75 1a                	jne    8010ce <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010b4:	83 ec 08             	sub    $0x8,%esp
  8010b7:	68 ff 00 00 00       	push   $0xff
  8010bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8010bf:	50                   	push   %eax
  8010c0:	e8 d9 ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010cb:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ce:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010e7:	00 00 00 
	b.cnt = 0;
  8010ea:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f4:	ff 75 0c             	pushl  0xc(%ebp)
  8010f7:	ff 75 08             	pushl  0x8(%ebp)
  8010fa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801100:	50                   	push   %eax
  801101:	68 95 10 80 00       	push   $0x801095
  801106:	e8 4f 01 00 00       	call   80125a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80110b:	83 c4 08             	add    $0x8,%esp
  80110e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801114:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	e8 7e ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  801120:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801126:	c9                   	leave  
  801127:	c3                   	ret    

00801128 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801128:	55                   	push   %ebp
  801129:	89 e5                	mov    %esp,%ebp
  80112b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80112e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801131:	50                   	push   %eax
  801132:	ff 75 08             	pushl  0x8(%ebp)
  801135:	e8 9d ff ff ff       	call   8010d7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80113a:	c9                   	leave  
  80113b:	c3                   	ret    

0080113c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	57                   	push   %edi
  801140:	56                   	push   %esi
  801141:	53                   	push   %ebx
  801142:	83 ec 1c             	sub    $0x1c,%esp
  801145:	89 c7                	mov    %eax,%edi
  801147:	89 d6                	mov    %edx,%esi
  801149:	8b 45 08             	mov    0x8(%ebp),%eax
  80114c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114f:	89 d1                	mov    %edx,%ecx
  801151:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801154:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801157:	8b 45 10             	mov    0x10(%ebp),%eax
  80115a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80115d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801160:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801167:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80116a:	72 05                	jb     801171 <printnum+0x35>
  80116c:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80116f:	77 3e                	ja     8011af <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801171:	83 ec 0c             	sub    $0xc,%esp
  801174:	ff 75 18             	pushl  0x18(%ebp)
  801177:	83 eb 01             	sub    $0x1,%ebx
  80117a:	53                   	push   %ebx
  80117b:	50                   	push   %eax
  80117c:	83 ec 08             	sub    $0x8,%esp
  80117f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801182:	ff 75 e0             	pushl  -0x20(%ebp)
  801185:	ff 75 dc             	pushl  -0x24(%ebp)
  801188:	ff 75 d8             	pushl  -0x28(%ebp)
  80118b:	e8 a0 09 00 00       	call   801b30 <__udivdi3>
  801190:	83 c4 18             	add    $0x18,%esp
  801193:	52                   	push   %edx
  801194:	50                   	push   %eax
  801195:	89 f2                	mov    %esi,%edx
  801197:	89 f8                	mov    %edi,%eax
  801199:	e8 9e ff ff ff       	call   80113c <printnum>
  80119e:	83 c4 20             	add    $0x20,%esp
  8011a1:	eb 13                	jmp    8011b6 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	56                   	push   %esi
  8011a7:	ff 75 18             	pushl  0x18(%ebp)
  8011aa:	ff d7                	call   *%edi
  8011ac:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011af:	83 eb 01             	sub    $0x1,%ebx
  8011b2:	85 db                	test   %ebx,%ebx
  8011b4:	7f ed                	jg     8011a3 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	56                   	push   %esi
  8011ba:	83 ec 04             	sub    $0x4,%esp
  8011bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c9:	e8 92 0a 00 00       	call   801c60 <__umoddi3>
  8011ce:	83 c4 14             	add    $0x14,%esp
  8011d1:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011d8:	50                   	push   %eax
  8011d9:	ff d7                	call   *%edi
  8011db:	83 c4 10             	add    $0x10,%esp
}
  8011de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e1:	5b                   	pop    %ebx
  8011e2:	5e                   	pop    %esi
  8011e3:	5f                   	pop    %edi
  8011e4:	5d                   	pop    %ebp
  8011e5:	c3                   	ret    

008011e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e9:	83 fa 01             	cmp    $0x1,%edx
  8011ec:	7e 0e                	jle    8011fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011ee:	8b 10                	mov    (%eax),%edx
  8011f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f3:	89 08                	mov    %ecx,(%eax)
  8011f5:	8b 02                	mov    (%edx),%eax
  8011f7:	8b 52 04             	mov    0x4(%edx),%edx
  8011fa:	eb 22                	jmp    80121e <getuint+0x38>
	else if (lflag)
  8011fc:	85 d2                	test   %edx,%edx
  8011fe:	74 10                	je     801210 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801200:	8b 10                	mov    (%eax),%edx
  801202:	8d 4a 04             	lea    0x4(%edx),%ecx
  801205:	89 08                	mov    %ecx,(%eax)
  801207:	8b 02                	mov    (%edx),%eax
  801209:	ba 00 00 00 00       	mov    $0x0,%edx
  80120e:	eb 0e                	jmp    80121e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801210:	8b 10                	mov    (%eax),%edx
  801212:	8d 4a 04             	lea    0x4(%edx),%ecx
  801215:	89 08                	mov    %ecx,(%eax)
  801217:	8b 02                	mov    (%edx),%eax
  801219:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801226:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80122a:	8b 10                	mov    (%eax),%edx
  80122c:	3b 50 04             	cmp    0x4(%eax),%edx
  80122f:	73 0a                	jae    80123b <sprintputch+0x1b>
		*b->buf++ = ch;
  801231:	8d 4a 01             	lea    0x1(%edx),%ecx
  801234:	89 08                	mov    %ecx,(%eax)
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	88 02                	mov    %al,(%edx)
}
  80123b:	5d                   	pop    %ebp
  80123c:	c3                   	ret    

0080123d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80123d:	55                   	push   %ebp
  80123e:	89 e5                	mov    %esp,%ebp
  801240:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801243:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801246:	50                   	push   %eax
  801247:	ff 75 10             	pushl  0x10(%ebp)
  80124a:	ff 75 0c             	pushl  0xc(%ebp)
  80124d:	ff 75 08             	pushl  0x8(%ebp)
  801250:	e8 05 00 00 00       	call   80125a <vprintfmt>
	va_end(ap);
  801255:	83 c4 10             	add    $0x10,%esp
}
  801258:	c9                   	leave  
  801259:	c3                   	ret    

0080125a <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	57                   	push   %edi
  80125e:	56                   	push   %esi
  80125f:	53                   	push   %ebx
  801260:	83 ec 2c             	sub    $0x2c,%esp
  801263:	8b 75 08             	mov    0x8(%ebp),%esi
  801266:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801269:	8b 7d 10             	mov    0x10(%ebp),%edi
  80126c:	eb 12                	jmp    801280 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80126e:	85 c0                	test   %eax,%eax
  801270:	0f 84 8d 03 00 00    	je     801603 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	53                   	push   %ebx
  80127a:	50                   	push   %eax
  80127b:	ff d6                	call   *%esi
  80127d:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801280:	83 c7 01             	add    $0x1,%edi
  801283:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801287:	83 f8 25             	cmp    $0x25,%eax
  80128a:	75 e2                	jne    80126e <vprintfmt+0x14>
  80128c:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801290:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801297:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80129e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012aa:	eb 07                	jmp    8012b3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012af:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b3:	8d 47 01             	lea    0x1(%edi),%eax
  8012b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b9:	0f b6 07             	movzbl (%edi),%eax
  8012bc:	0f b6 c8             	movzbl %al,%ecx
  8012bf:	83 e8 23             	sub    $0x23,%eax
  8012c2:	3c 55                	cmp    $0x55,%al
  8012c4:	0f 87 1e 03 00 00    	ja     8015e8 <vprintfmt+0x38e>
  8012ca:	0f b6 c0             	movzbl %al,%eax
  8012cd:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012d7:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012db:	eb d6                	jmp    8012b3 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e5:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012e8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012eb:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012ef:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012f2:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012f5:	83 fa 09             	cmp    $0x9,%edx
  8012f8:	77 38                	ja     801332 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012fa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012fd:	eb e9                	jmp    8012e8 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801302:	8d 48 04             	lea    0x4(%eax),%ecx
  801305:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801308:	8b 00                	mov    (%eax),%eax
  80130a:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801310:	eb 26                	jmp    801338 <vprintfmt+0xde>
  801312:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801315:	89 c8                	mov    %ecx,%eax
  801317:	c1 f8 1f             	sar    $0x1f,%eax
  80131a:	f7 d0                	not    %eax
  80131c:	21 c1                	and    %eax,%ecx
  80131e:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801321:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801324:	eb 8d                	jmp    8012b3 <vprintfmt+0x59>
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801329:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801330:	eb 81                	jmp    8012b3 <vprintfmt+0x59>
  801332:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801335:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801338:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80133c:	0f 89 71 ff ff ff    	jns    8012b3 <vprintfmt+0x59>
				width = precision, precision = -1;
  801342:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801345:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801348:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80134f:	e9 5f ff ff ff       	jmp    8012b3 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801354:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80135a:	e9 54 ff ff ff       	jmp    8012b3 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80135f:	8b 45 14             	mov    0x14(%ebp),%eax
  801362:	8d 50 04             	lea    0x4(%eax),%edx
  801365:	89 55 14             	mov    %edx,0x14(%ebp)
  801368:	83 ec 08             	sub    $0x8,%esp
  80136b:	53                   	push   %ebx
  80136c:	ff 30                	pushl  (%eax)
  80136e:	ff d6                	call   *%esi
			break;
  801370:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801373:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801376:	e9 05 ff ff ff       	jmp    801280 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80137b:	8b 45 14             	mov    0x14(%ebp),%eax
  80137e:	8d 50 04             	lea    0x4(%eax),%edx
  801381:	89 55 14             	mov    %edx,0x14(%ebp)
  801384:	8b 00                	mov    (%eax),%eax
  801386:	99                   	cltd   
  801387:	31 d0                	xor    %edx,%eax
  801389:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80138b:	83 f8 0f             	cmp    $0xf,%eax
  80138e:	7f 0b                	jg     80139b <vprintfmt+0x141>
  801390:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  801397:	85 d2                	test   %edx,%edx
  801399:	75 18                	jne    8013b3 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80139b:	50                   	push   %eax
  80139c:	68 7f 1f 80 00       	push   $0x801f7f
  8013a1:	53                   	push   %ebx
  8013a2:	56                   	push   %esi
  8013a3:	e8 95 fe ff ff       	call   80123d <printfmt>
  8013a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ae:	e9 cd fe ff ff       	jmp    801280 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013b3:	52                   	push   %edx
  8013b4:	68 dd 1e 80 00       	push   $0x801edd
  8013b9:	53                   	push   %ebx
  8013ba:	56                   	push   %esi
  8013bb:	e8 7d fe ff ff       	call   80123d <printfmt>
  8013c0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c6:	e9 b5 fe ff ff       	jmp    801280 <vprintfmt+0x26>
  8013cb:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013ce:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d7:	8d 50 04             	lea    0x4(%eax),%edx
  8013da:	89 55 14             	mov    %edx,0x14(%ebp)
  8013dd:	8b 38                	mov    (%eax),%edi
  8013df:	85 ff                	test   %edi,%edi
  8013e1:	75 05                	jne    8013e8 <vprintfmt+0x18e>
				p = "(null)";
  8013e3:	bf 78 1f 80 00       	mov    $0x801f78,%edi
			if (width > 0 && padc != '-')
  8013e8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013ec:	0f 84 91 00 00 00    	je     801483 <vprintfmt+0x229>
  8013f2:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8013f6:	0f 8e 95 00 00 00    	jle    801491 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	51                   	push   %ecx
  801400:	57                   	push   %edi
  801401:	e8 85 02 00 00       	call   80168b <strnlen>
  801406:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801409:	29 c1                	sub    %eax,%ecx
  80140b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80140e:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801411:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801415:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801418:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80141b:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80141d:	eb 0f                	jmp    80142e <vprintfmt+0x1d4>
					putch(padc, putdat);
  80141f:	83 ec 08             	sub    $0x8,%esp
  801422:	53                   	push   %ebx
  801423:	ff 75 e0             	pushl  -0x20(%ebp)
  801426:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801428:	83 ef 01             	sub    $0x1,%edi
  80142b:	83 c4 10             	add    $0x10,%esp
  80142e:	85 ff                	test   %edi,%edi
  801430:	7f ed                	jg     80141f <vprintfmt+0x1c5>
  801432:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801435:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801438:	89 c8                	mov    %ecx,%eax
  80143a:	c1 f8 1f             	sar    $0x1f,%eax
  80143d:	f7 d0                	not    %eax
  80143f:	21 c8                	and    %ecx,%eax
  801441:	29 c1                	sub    %eax,%ecx
  801443:	89 75 08             	mov    %esi,0x8(%ebp)
  801446:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801449:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80144c:	89 cb                	mov    %ecx,%ebx
  80144e:	eb 4d                	jmp    80149d <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801450:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801454:	74 1b                	je     801471 <vprintfmt+0x217>
  801456:	0f be c0             	movsbl %al,%eax
  801459:	83 e8 20             	sub    $0x20,%eax
  80145c:	83 f8 5e             	cmp    $0x5e,%eax
  80145f:	76 10                	jbe    801471 <vprintfmt+0x217>
					putch('?', putdat);
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	ff 75 0c             	pushl  0xc(%ebp)
  801467:	6a 3f                	push   $0x3f
  801469:	ff 55 08             	call   *0x8(%ebp)
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	eb 0d                	jmp    80147e <vprintfmt+0x224>
				else
					putch(ch, putdat);
  801471:	83 ec 08             	sub    $0x8,%esp
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	52                   	push   %edx
  801478:	ff 55 08             	call   *0x8(%ebp)
  80147b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147e:	83 eb 01             	sub    $0x1,%ebx
  801481:	eb 1a                	jmp    80149d <vprintfmt+0x243>
  801483:	89 75 08             	mov    %esi,0x8(%ebp)
  801486:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801489:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80148f:	eb 0c                	jmp    80149d <vprintfmt+0x243>
  801491:	89 75 08             	mov    %esi,0x8(%ebp)
  801494:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801497:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80149a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80149d:	83 c7 01             	add    $0x1,%edi
  8014a0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014a4:	0f be d0             	movsbl %al,%edx
  8014a7:	85 d2                	test   %edx,%edx
  8014a9:	74 23                	je     8014ce <vprintfmt+0x274>
  8014ab:	85 f6                	test   %esi,%esi
  8014ad:	78 a1                	js     801450 <vprintfmt+0x1f6>
  8014af:	83 ee 01             	sub    $0x1,%esi
  8014b2:	79 9c                	jns    801450 <vprintfmt+0x1f6>
  8014b4:	89 df                	mov    %ebx,%edi
  8014b6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014bc:	eb 18                	jmp    8014d6 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014be:	83 ec 08             	sub    $0x8,%esp
  8014c1:	53                   	push   %ebx
  8014c2:	6a 20                	push   $0x20
  8014c4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014c6:	83 ef 01             	sub    $0x1,%edi
  8014c9:	83 c4 10             	add    $0x10,%esp
  8014cc:	eb 08                	jmp    8014d6 <vprintfmt+0x27c>
  8014ce:	89 df                	mov    %ebx,%edi
  8014d0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d6:	85 ff                	test   %edi,%edi
  8014d8:	7f e4                	jg     8014be <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014dd:	e9 9e fd ff ff       	jmp    801280 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014e2:	83 fa 01             	cmp    $0x1,%edx
  8014e5:	7e 16                	jle    8014fd <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ea:	8d 50 08             	lea    0x8(%eax),%edx
  8014ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f0:	8b 50 04             	mov    0x4(%eax),%edx
  8014f3:	8b 00                	mov    (%eax),%eax
  8014f5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014fb:	eb 32                	jmp    80152f <vprintfmt+0x2d5>
	else if (lflag)
  8014fd:	85 d2                	test   %edx,%edx
  8014ff:	74 18                	je     801519 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  801501:	8b 45 14             	mov    0x14(%ebp),%eax
  801504:	8d 50 04             	lea    0x4(%eax),%edx
  801507:	89 55 14             	mov    %edx,0x14(%ebp)
  80150a:	8b 00                	mov    (%eax),%eax
  80150c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150f:	89 c1                	mov    %eax,%ecx
  801511:	c1 f9 1f             	sar    $0x1f,%ecx
  801514:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801517:	eb 16                	jmp    80152f <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801519:	8b 45 14             	mov    0x14(%ebp),%eax
  80151c:	8d 50 04             	lea    0x4(%eax),%edx
  80151f:	89 55 14             	mov    %edx,0x14(%ebp)
  801522:	8b 00                	mov    (%eax),%eax
  801524:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801527:	89 c1                	mov    %eax,%ecx
  801529:	c1 f9 1f             	sar    $0x1f,%ecx
  80152c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80152f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801532:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801535:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80153a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80153e:	79 74                	jns    8015b4 <vprintfmt+0x35a>
				putch('-', putdat);
  801540:	83 ec 08             	sub    $0x8,%esp
  801543:	53                   	push   %ebx
  801544:	6a 2d                	push   $0x2d
  801546:	ff d6                	call   *%esi
				num = -(long long) num;
  801548:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80154b:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80154e:	f7 d8                	neg    %eax
  801550:	83 d2 00             	adc    $0x0,%edx
  801553:	f7 da                	neg    %edx
  801555:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801558:	b9 0a 00 00 00       	mov    $0xa,%ecx
  80155d:	eb 55                	jmp    8015b4 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80155f:	8d 45 14             	lea    0x14(%ebp),%eax
  801562:	e8 7f fc ff ff       	call   8011e6 <getuint>
			base = 10;
  801567:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  80156c:	eb 46                	jmp    8015b4 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80156e:	8d 45 14             	lea    0x14(%ebp),%eax
  801571:	e8 70 fc ff ff       	call   8011e6 <getuint>
			base = 8;
  801576:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80157b:	eb 37                	jmp    8015b4 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	53                   	push   %ebx
  801581:	6a 30                	push   $0x30
  801583:	ff d6                	call   *%esi
			putch('x', putdat);
  801585:	83 c4 08             	add    $0x8,%esp
  801588:	53                   	push   %ebx
  801589:	6a 78                	push   $0x78
  80158b:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80158d:	8b 45 14             	mov    0x14(%ebp),%eax
  801590:	8d 50 04             	lea    0x4(%eax),%edx
  801593:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801596:	8b 00                	mov    (%eax),%eax
  801598:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80159d:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015a0:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015a5:	eb 0d                	jmp    8015b4 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015aa:	e8 37 fc ff ff       	call   8011e6 <getuint>
			base = 16;
  8015af:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015b4:	83 ec 0c             	sub    $0xc,%esp
  8015b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015bb:	57                   	push   %edi
  8015bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8015bf:	51                   	push   %ecx
  8015c0:	52                   	push   %edx
  8015c1:	50                   	push   %eax
  8015c2:	89 da                	mov    %ebx,%edx
  8015c4:	89 f0                	mov    %esi,%eax
  8015c6:	e8 71 fb ff ff       	call   80113c <printnum>
			break;
  8015cb:	83 c4 20             	add    $0x20,%esp
  8015ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d1:	e9 aa fc ff ff       	jmp    801280 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	53                   	push   %ebx
  8015da:	51                   	push   %ecx
  8015db:	ff d6                	call   *%esi
			break;
  8015dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015e3:	e9 98 fc ff ff       	jmp    801280 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	53                   	push   %ebx
  8015ec:	6a 25                	push   $0x25
  8015ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	eb 03                	jmp    8015f8 <vprintfmt+0x39e>
  8015f5:	83 ef 01             	sub    $0x1,%edi
  8015f8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015fc:	75 f7                	jne    8015f5 <vprintfmt+0x39b>
  8015fe:	e9 7d fc ff ff       	jmp    801280 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5f                   	pop    %edi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 18             	sub    $0x18,%esp
  801611:	8b 45 08             	mov    0x8(%ebp),%eax
  801614:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801617:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801621:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801628:	85 c0                	test   %eax,%eax
  80162a:	74 26                	je     801652 <vsnprintf+0x47>
  80162c:	85 d2                	test   %edx,%edx
  80162e:	7e 22                	jle    801652 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801630:	ff 75 14             	pushl  0x14(%ebp)
  801633:	ff 75 10             	pushl  0x10(%ebp)
  801636:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801639:	50                   	push   %eax
  80163a:	68 20 12 80 00       	push   $0x801220
  80163f:	e8 16 fc ff ff       	call   80125a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801644:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801647:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80164a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164d:	83 c4 10             	add    $0x10,%esp
  801650:	eb 05                	jmp    801657 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801652:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801662:	50                   	push   %eax
  801663:	ff 75 10             	pushl  0x10(%ebp)
  801666:	ff 75 0c             	pushl  0xc(%ebp)
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 9a ff ff ff       	call   80160b <vsnprintf>
	va_end(ap);

	return rc;
}
  801671:	c9                   	leave  
  801672:	c3                   	ret    

00801673 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801679:	b8 00 00 00 00       	mov    $0x0,%eax
  80167e:	eb 03                	jmp    801683 <strlen+0x10>
		n++;
  801680:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801683:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801687:	75 f7                	jne    801680 <strlen+0xd>
		n++;
	return n;
}
  801689:	5d                   	pop    %ebp
  80168a:	c3                   	ret    

0080168b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801691:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801694:	ba 00 00 00 00       	mov    $0x0,%edx
  801699:	eb 03                	jmp    80169e <strnlen+0x13>
		n++;
  80169b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169e:	39 c2                	cmp    %eax,%edx
  8016a0:	74 08                	je     8016aa <strnlen+0x1f>
  8016a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016a6:	75 f3                	jne    80169b <strnlen+0x10>
  8016a8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016aa:	5d                   	pop    %ebp
  8016ab:	c3                   	ret    

008016ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ac:	55                   	push   %ebp
  8016ad:	89 e5                	mov    %esp,%ebp
  8016af:	53                   	push   %ebx
  8016b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b6:	89 c2                	mov    %eax,%edx
  8016b8:	83 c2 01             	add    $0x1,%edx
  8016bb:	83 c1 01             	add    $0x1,%ecx
  8016be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c5:	84 db                	test   %bl,%bl
  8016c7:	75 ef                	jne    8016b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016c9:	5b                   	pop    %ebx
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d3:	53                   	push   %ebx
  8016d4:	e8 9a ff ff ff       	call   801673 <strlen>
  8016d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016dc:	ff 75 0c             	pushl  0xc(%ebp)
  8016df:	01 d8                	add    %ebx,%eax
  8016e1:	50                   	push   %eax
  8016e2:	e8 c5 ff ff ff       	call   8016ac <strcpy>
	return dst;
}
  8016e7:	89 d8                	mov    %ebx,%eax
  8016e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ec:	c9                   	leave  
  8016ed:	c3                   	ret    

008016ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ee:	55                   	push   %ebp
  8016ef:	89 e5                	mov    %esp,%ebp
  8016f1:	56                   	push   %esi
  8016f2:	53                   	push   %ebx
  8016f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f9:	89 f3                	mov    %esi,%ebx
  8016fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016fe:	89 f2                	mov    %esi,%edx
  801700:	eb 0f                	jmp    801711 <strncpy+0x23>
		*dst++ = *src;
  801702:	83 c2 01             	add    $0x1,%edx
  801705:	0f b6 01             	movzbl (%ecx),%eax
  801708:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80170b:	80 39 01             	cmpb   $0x1,(%ecx)
  80170e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801711:	39 da                	cmp    %ebx,%edx
  801713:	75 ed                	jne    801702 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801715:	89 f0                	mov    %esi,%eax
  801717:	5b                   	pop    %ebx
  801718:	5e                   	pop    %esi
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	56                   	push   %esi
  80171f:	53                   	push   %ebx
  801720:	8b 75 08             	mov    0x8(%ebp),%esi
  801723:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801726:	8b 55 10             	mov    0x10(%ebp),%edx
  801729:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80172b:	85 d2                	test   %edx,%edx
  80172d:	74 21                	je     801750 <strlcpy+0x35>
  80172f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801733:	89 f2                	mov    %esi,%edx
  801735:	eb 09                	jmp    801740 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801737:	83 c2 01             	add    $0x1,%edx
  80173a:	83 c1 01             	add    $0x1,%ecx
  80173d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801740:	39 c2                	cmp    %eax,%edx
  801742:	74 09                	je     80174d <strlcpy+0x32>
  801744:	0f b6 19             	movzbl (%ecx),%ebx
  801747:	84 db                	test   %bl,%bl
  801749:	75 ec                	jne    801737 <strlcpy+0x1c>
  80174b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80174d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801750:	29 f0                	sub    %esi,%eax
}
  801752:	5b                   	pop    %ebx
  801753:	5e                   	pop    %esi
  801754:	5d                   	pop    %ebp
  801755:	c3                   	ret    

00801756 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801756:	55                   	push   %ebp
  801757:	89 e5                	mov    %esp,%ebp
  801759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175f:	eb 06                	jmp    801767 <strcmp+0x11>
		p++, q++;
  801761:	83 c1 01             	add    $0x1,%ecx
  801764:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801767:	0f b6 01             	movzbl (%ecx),%eax
  80176a:	84 c0                	test   %al,%al
  80176c:	74 04                	je     801772 <strcmp+0x1c>
  80176e:	3a 02                	cmp    (%edx),%al
  801770:	74 ef                	je     801761 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801772:	0f b6 c0             	movzbl %al,%eax
  801775:	0f b6 12             	movzbl (%edx),%edx
  801778:	29 d0                	sub    %edx,%eax
}
  80177a:	5d                   	pop    %ebp
  80177b:	c3                   	ret    

0080177c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80177c:	55                   	push   %ebp
  80177d:	89 e5                	mov    %esp,%ebp
  80177f:	53                   	push   %ebx
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	8b 55 0c             	mov    0xc(%ebp),%edx
  801786:	89 c3                	mov    %eax,%ebx
  801788:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80178b:	eb 06                	jmp    801793 <strncmp+0x17>
		n--, p++, q++;
  80178d:	83 c0 01             	add    $0x1,%eax
  801790:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801793:	39 d8                	cmp    %ebx,%eax
  801795:	74 15                	je     8017ac <strncmp+0x30>
  801797:	0f b6 08             	movzbl (%eax),%ecx
  80179a:	84 c9                	test   %cl,%cl
  80179c:	74 04                	je     8017a2 <strncmp+0x26>
  80179e:	3a 0a                	cmp    (%edx),%cl
  8017a0:	74 eb                	je     80178d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a2:	0f b6 00             	movzbl (%eax),%eax
  8017a5:	0f b6 12             	movzbl (%edx),%edx
  8017a8:	29 d0                	sub    %edx,%eax
  8017aa:	eb 05                	jmp    8017b1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017ac:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b1:	5b                   	pop    %ebx
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017be:	eb 07                	jmp    8017c7 <strchr+0x13>
		if (*s == c)
  8017c0:	38 ca                	cmp    %cl,%dl
  8017c2:	74 0f                	je     8017d3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017c4:	83 c0 01             	add    $0x1,%eax
  8017c7:	0f b6 10             	movzbl (%eax),%edx
  8017ca:	84 d2                	test   %dl,%dl
  8017cc:	75 f2                	jne    8017c0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017df:	eb 03                	jmp    8017e4 <strfind+0xf>
  8017e1:	83 c0 01             	add    $0x1,%eax
  8017e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017e7:	84 d2                	test   %dl,%dl
  8017e9:	74 04                	je     8017ef <strfind+0x1a>
  8017eb:	38 ca                	cmp    %cl,%dl
  8017ed:	75 f2                	jne    8017e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	57                   	push   %edi
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8017fd:	85 c9                	test   %ecx,%ecx
  8017ff:	74 36                	je     801837 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801801:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801807:	75 28                	jne    801831 <memset+0x40>
  801809:	f6 c1 03             	test   $0x3,%cl
  80180c:	75 23                	jne    801831 <memset+0x40>
		c &= 0xFF;
  80180e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801812:	89 d3                	mov    %edx,%ebx
  801814:	c1 e3 08             	shl    $0x8,%ebx
  801817:	89 d6                	mov    %edx,%esi
  801819:	c1 e6 18             	shl    $0x18,%esi
  80181c:	89 d0                	mov    %edx,%eax
  80181e:	c1 e0 10             	shl    $0x10,%eax
  801821:	09 f0                	or     %esi,%eax
  801823:	09 c2                	or     %eax,%edx
  801825:	89 d0                	mov    %edx,%eax
  801827:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801829:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  80182c:	fc                   	cld    
  80182d:	f3 ab                	rep stos %eax,%es:(%edi)
  80182f:	eb 06                	jmp    801837 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801831:	8b 45 0c             	mov    0xc(%ebp),%eax
  801834:	fc                   	cld    
  801835:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801837:	89 f8                	mov    %edi,%eax
  801839:	5b                   	pop    %ebx
  80183a:	5e                   	pop    %esi
  80183b:	5f                   	pop    %edi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	57                   	push   %edi
  801842:	56                   	push   %esi
  801843:	8b 45 08             	mov    0x8(%ebp),%eax
  801846:	8b 75 0c             	mov    0xc(%ebp),%esi
  801849:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80184c:	39 c6                	cmp    %eax,%esi
  80184e:	73 35                	jae    801885 <memmove+0x47>
  801850:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801853:	39 d0                	cmp    %edx,%eax
  801855:	73 2e                	jae    801885 <memmove+0x47>
		s += n;
		d += n;
  801857:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80185a:	89 d6                	mov    %edx,%esi
  80185c:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801864:	75 13                	jne    801879 <memmove+0x3b>
  801866:	f6 c1 03             	test   $0x3,%cl
  801869:	75 0e                	jne    801879 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80186b:	83 ef 04             	sub    $0x4,%edi
  80186e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801871:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801874:	fd                   	std    
  801875:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801877:	eb 09                	jmp    801882 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801879:	83 ef 01             	sub    $0x1,%edi
  80187c:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80187f:	fd                   	std    
  801880:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801882:	fc                   	cld    
  801883:	eb 1d                	jmp    8018a2 <memmove+0x64>
  801885:	89 f2                	mov    %esi,%edx
  801887:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801889:	f6 c2 03             	test   $0x3,%dl
  80188c:	75 0f                	jne    80189d <memmove+0x5f>
  80188e:	f6 c1 03             	test   $0x3,%cl
  801891:	75 0a                	jne    80189d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801893:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801896:	89 c7                	mov    %eax,%edi
  801898:	fc                   	cld    
  801899:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189b:	eb 05                	jmp    8018a2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80189d:	89 c7                	mov    %eax,%edi
  80189f:	fc                   	cld    
  8018a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a2:	5e                   	pop    %esi
  8018a3:	5f                   	pop    %edi
  8018a4:	5d                   	pop    %ebp
  8018a5:	c3                   	ret    

008018a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018a9:	ff 75 10             	pushl  0x10(%ebp)
  8018ac:	ff 75 0c             	pushl  0xc(%ebp)
  8018af:	ff 75 08             	pushl  0x8(%ebp)
  8018b2:	e8 87 ff ff ff       	call   80183e <memmove>
}
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    

008018b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018b9:	55                   	push   %ebp
  8018ba:	89 e5                	mov    %esp,%ebp
  8018bc:	56                   	push   %esi
  8018bd:	53                   	push   %ebx
  8018be:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c4:	89 c6                	mov    %eax,%esi
  8018c6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c9:	eb 1a                	jmp    8018e5 <memcmp+0x2c>
		if (*s1 != *s2)
  8018cb:	0f b6 08             	movzbl (%eax),%ecx
  8018ce:	0f b6 1a             	movzbl (%edx),%ebx
  8018d1:	38 d9                	cmp    %bl,%cl
  8018d3:	74 0a                	je     8018df <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018d5:	0f b6 c1             	movzbl %cl,%eax
  8018d8:	0f b6 db             	movzbl %bl,%ebx
  8018db:	29 d8                	sub    %ebx,%eax
  8018dd:	eb 0f                	jmp    8018ee <memcmp+0x35>
		s1++, s2++;
  8018df:	83 c0 01             	add    $0x1,%eax
  8018e2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e5:	39 f0                	cmp    %esi,%eax
  8018e7:	75 e2                	jne    8018cb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ee:	5b                   	pop    %ebx
  8018ef:	5e                   	pop    %esi
  8018f0:	5d                   	pop    %ebp
  8018f1:	c3                   	ret    

008018f2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018fb:	89 c2                	mov    %eax,%edx
  8018fd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801900:	eb 07                	jmp    801909 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801902:	38 08                	cmp    %cl,(%eax)
  801904:	74 07                	je     80190d <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801906:	83 c0 01             	add    $0x1,%eax
  801909:	39 d0                	cmp    %edx,%eax
  80190b:	72 f5                	jb     801902 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	57                   	push   %edi
  801913:	56                   	push   %esi
  801914:	53                   	push   %ebx
  801915:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801918:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191b:	eb 03                	jmp    801920 <strtol+0x11>
		s++;
  80191d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801920:	0f b6 01             	movzbl (%ecx),%eax
  801923:	3c 09                	cmp    $0x9,%al
  801925:	74 f6                	je     80191d <strtol+0xe>
  801927:	3c 20                	cmp    $0x20,%al
  801929:	74 f2                	je     80191d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80192b:	3c 2b                	cmp    $0x2b,%al
  80192d:	75 0a                	jne    801939 <strtol+0x2a>
		s++;
  80192f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801932:	bf 00 00 00 00       	mov    $0x0,%edi
  801937:	eb 10                	jmp    801949 <strtol+0x3a>
  801939:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80193e:	3c 2d                	cmp    $0x2d,%al
  801940:	75 07                	jne    801949 <strtol+0x3a>
		s++, neg = 1;
  801942:	8d 49 01             	lea    0x1(%ecx),%ecx
  801945:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801949:	85 db                	test   %ebx,%ebx
  80194b:	0f 94 c0             	sete   %al
  80194e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801954:	75 19                	jne    80196f <strtol+0x60>
  801956:	80 39 30             	cmpb   $0x30,(%ecx)
  801959:	75 14                	jne    80196f <strtol+0x60>
  80195b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80195f:	0f 85 8a 00 00 00    	jne    8019ef <strtol+0xe0>
		s += 2, base = 16;
  801965:	83 c1 02             	add    $0x2,%ecx
  801968:	bb 10 00 00 00       	mov    $0x10,%ebx
  80196d:	eb 16                	jmp    801985 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80196f:	84 c0                	test   %al,%al
  801971:	74 12                	je     801985 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801973:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801978:	80 39 30             	cmpb   $0x30,(%ecx)
  80197b:	75 08                	jne    801985 <strtol+0x76>
		s++, base = 8;
  80197d:	83 c1 01             	add    $0x1,%ecx
  801980:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801985:	b8 00 00 00 00       	mov    $0x0,%eax
  80198a:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  80198d:	0f b6 11             	movzbl (%ecx),%edx
  801990:	8d 72 d0             	lea    -0x30(%edx),%esi
  801993:	89 f3                	mov    %esi,%ebx
  801995:	80 fb 09             	cmp    $0x9,%bl
  801998:	77 08                	ja     8019a2 <strtol+0x93>
			dig = *s - '0';
  80199a:	0f be d2             	movsbl %dl,%edx
  80199d:	83 ea 30             	sub    $0x30,%edx
  8019a0:	eb 22                	jmp    8019c4 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019a2:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019a5:	89 f3                	mov    %esi,%ebx
  8019a7:	80 fb 19             	cmp    $0x19,%bl
  8019aa:	77 08                	ja     8019b4 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019ac:	0f be d2             	movsbl %dl,%edx
  8019af:	83 ea 57             	sub    $0x57,%edx
  8019b2:	eb 10                	jmp    8019c4 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019b4:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019b7:	89 f3                	mov    %esi,%ebx
  8019b9:	80 fb 19             	cmp    $0x19,%bl
  8019bc:	77 16                	ja     8019d4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019be:	0f be d2             	movsbl %dl,%edx
  8019c1:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019c4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019c7:	7d 0f                	jge    8019d8 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019c9:	83 c1 01             	add    $0x1,%ecx
  8019cc:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d0:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019d2:	eb b9                	jmp    80198d <strtol+0x7e>
  8019d4:	89 c2                	mov    %eax,%edx
  8019d6:	eb 02                	jmp    8019da <strtol+0xcb>
  8019d8:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019da:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019de:	74 05                	je     8019e5 <strtol+0xd6>
		*endptr = (char *) s;
  8019e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019e5:	85 ff                	test   %edi,%edi
  8019e7:	74 0c                	je     8019f5 <strtol+0xe6>
  8019e9:	89 d0                	mov    %edx,%eax
  8019eb:	f7 d8                	neg    %eax
  8019ed:	eb 06                	jmp    8019f5 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019ef:	84 c0                	test   %al,%al
  8019f1:	75 8a                	jne    80197d <strtol+0x6e>
  8019f3:	eb 90                	jmp    801985 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8019f5:	5b                   	pop    %ebx
  8019f6:	5e                   	pop    %esi
  8019f7:	5f                   	pop    %edi
  8019f8:	5d                   	pop    %ebp
  8019f9:	c3                   	ret    

008019fa <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	56                   	push   %esi
  8019fe:	53                   	push   %ebx
  8019ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a05:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a08:	85 f6                	test   %esi,%esi
  801a0a:	74 06                	je     801a12 <ipc_recv+0x18>
  801a0c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a12:	85 db                	test   %ebx,%ebx
  801a14:	74 06                	je     801a1c <ipc_recv+0x22>
  801a16:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a1c:	83 f8 01             	cmp    $0x1,%eax
  801a1f:	19 d2                	sbb    %edx,%edx
  801a21:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	50                   	push   %eax
  801a27:	e8 de e8 ff ff       	call   80030a <sys_ipc_recv>
  801a2c:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a2e:	83 c4 10             	add    $0x10,%esp
  801a31:	85 d2                	test   %edx,%edx
  801a33:	75 24                	jne    801a59 <ipc_recv+0x5f>
	if (from_env_store)
  801a35:	85 f6                	test   %esi,%esi
  801a37:	74 0a                	je     801a43 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a39:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3e:	8b 40 70             	mov    0x70(%eax),%eax
  801a41:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a43:	85 db                	test   %ebx,%ebx
  801a45:	74 0a                	je     801a51 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a47:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4c:	8b 40 74             	mov    0x74(%eax),%eax
  801a4f:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a51:	a1 04 40 80 00       	mov    0x804004,%eax
  801a56:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	57                   	push   %edi
  801a64:	56                   	push   %esi
  801a65:	53                   	push   %ebx
  801a66:	83 ec 0c             	sub    $0xc,%esp
  801a69:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a6c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a72:	83 fb 01             	cmp    $0x1,%ebx
  801a75:	19 c0                	sbb    %eax,%eax
  801a77:	09 c3                	or     %eax,%ebx
  801a79:	eb 1c                	jmp    801a97 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a7b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a7e:	74 12                	je     801a92 <ipc_send+0x32>
  801a80:	50                   	push   %eax
  801a81:	68 a0 22 80 00       	push   $0x8022a0
  801a86:	6a 36                	push   $0x36
  801a88:	68 b7 22 80 00       	push   $0x8022b7
  801a8d:	e8 bd f5 ff ff       	call   80104f <_panic>
		sys_yield();
  801a92:	e8 a4 e6 ff ff       	call   80013b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a97:	ff 75 14             	pushl  0x14(%ebp)
  801a9a:	53                   	push   %ebx
  801a9b:	56                   	push   %esi
  801a9c:	57                   	push   %edi
  801a9d:	e8 45 e8 ff ff       	call   8002e7 <sys_ipc_try_send>
		if (ret == 0) break;
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	75 d2                	jne    801a7b <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    

00801ab1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801abc:	6b d0 78             	imul   $0x78,%eax,%edx
  801abf:	83 c2 50             	add    $0x50,%edx
  801ac2:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ac8:	39 ca                	cmp    %ecx,%edx
  801aca:	75 0d                	jne    801ad9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801acc:	6b c0 78             	imul   $0x78,%eax,%eax
  801acf:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ad4:	8b 40 08             	mov    0x8(%eax),%eax
  801ad7:	eb 0e                	jmp    801ae7 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad9:	83 c0 01             	add    $0x1,%eax
  801adc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ae1:	75 d9                	jne    801abc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ae3:	66 b8 00 00          	mov    $0x0,%ax
}
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aef:	89 d0                	mov    %edx,%eax
  801af1:	c1 e8 16             	shr    $0x16,%eax
  801af4:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801afb:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b00:	f6 c1 01             	test   $0x1,%cl
  801b03:	74 1d                	je     801b22 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b05:	c1 ea 0c             	shr    $0xc,%edx
  801b08:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b0f:	f6 c2 01             	test   $0x1,%dl
  801b12:	74 0e                	je     801b22 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b14:	c1 ea 0c             	shr    $0xc,%edx
  801b17:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b1e:	ef 
  801b1f:	0f b7 c0             	movzwl %ax,%eax
}
  801b22:	5d                   	pop    %ebp
  801b23:	c3                   	ret    
  801b24:	66 90                	xchg   %ax,%ax
  801b26:	66 90                	xchg   %ax,%ax
  801b28:	66 90                	xchg   %ax,%ax
  801b2a:	66 90                	xchg   %ax,%ax
  801b2c:	66 90                	xchg   %ax,%ax
  801b2e:	66 90                	xchg   %ax,%ax

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
