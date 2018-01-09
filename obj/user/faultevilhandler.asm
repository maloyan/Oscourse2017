
obj/user/faultevilhandler:     file format elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 7f ee       	push   $0xee7ff000
  800040:	6a 00                	push   $0x0
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
  800060:	83 c4 10             	add    $0x10,%esp
}
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 78             	imul   $0x78,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
  8000a1:	83 c4 10             	add    $0x10,%esp
#endif
}
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 a7 04 00 00       	call   80055d <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
  8000c0:	83 c4 10             	add    $0x10,%esp
}
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 0a 1e 80 00       	push   $0x801e0a
  80012f:	6a 23                	push   $0x23
  800131:	68 27 1e 80 00       	push   $0x801e27
  800136:	e8 3b 0f 00 00       	call   801076 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 0a 1e 80 00       	push   $0x801e0a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 27 1e 80 00       	push   $0x801e27
  8001b7:	e8 ba 0e 00 00       	call   801076 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 0a 1e 80 00       	push   $0x801e0a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 27 1e 80 00       	push   $0x801e27
  8001f9:	e8 78 0e 00 00       	call   801076 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 0a 1e 80 00       	push   $0x801e0a
  800234:	6a 23                	push   $0x23
  800236:	68 27 1e 80 00       	push   $0x801e27
  80023b:	e8 36 0e 00 00       	call   801076 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 0a 1e 80 00       	push   $0x801e0a
  800276:	6a 23                	push   $0x23
  800278:	68 27 1e 80 00       	push   $0x801e27
  80027d:	e8 f4 0d 00 00       	call   801076 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 0a 1e 80 00       	push   $0x801e0a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 27 1e 80 00       	push   $0x801e27
  8002bf:	e8 b2 0d 00 00       	call   801076 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 0a 1e 80 00       	push   $0x801e0a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 27 1e 80 00       	push   $0x801e27
  800301:	e8 70 0d 00 00       	call   801076 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 0a 1e 80 00       	push   $0x801e0a
  80035e:	6a 23                	push   $0x23
  800360:	68 27 1e 80 00       	push   $0x801e27
  800365:	e8 0c 0d 00 00       	call   801076 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <sys_gettime>:

int sys_gettime(void)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	89 d1                	mov    %edx,%ecx
  800384:	89 d3                	mov    %edx,%ebx
  800386:	89 d7                	mov    %edx,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800394:	8b 45 08             	mov    0x8(%ebp),%eax
  800397:	05 00 00 00 30       	add    $0x30000000,%eax
  80039c:	c1 e8 0c             	shr    $0xc,%eax
}
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a7:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8003ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
  8003bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c3:	89 c2                	mov    %eax,%edx
  8003c5:	c1 ea 16             	shr    $0x16,%edx
  8003c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003cf:	f6 c2 01             	test   $0x1,%dl
  8003d2:	74 11                	je     8003e5 <fd_alloc+0x2d>
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 0c             	shr    $0xc,%edx
  8003d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	75 09                	jne    8003ee <fd_alloc+0x36>
			*fd_store = fd;
  8003e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ec:	eb 17                	jmp    800405 <fd_alloc+0x4d>
  8003ee:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003f8:	75 c9                	jne    8003c3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800400:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800405:	5d                   	pop    %ebp
  800406:	c3                   	ret    

00800407 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040d:	83 f8 1f             	cmp    $0x1f,%eax
  800410:	77 36                	ja     800448 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800412:	c1 e0 0c             	shl    $0xc,%eax
  800415:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 ea 16             	shr    $0x16,%edx
  80041f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800426:	f6 c2 01             	test   $0x1,%dl
  800429:	74 24                	je     80044f <fd_lookup+0x48>
  80042b:	89 c2                	mov    %eax,%edx
  80042d:	c1 ea 0c             	shr    $0xc,%edx
  800430:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	74 1a                	je     800456 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043f:	89 02                	mov    %eax,(%edx)
	return 0;
  800441:	b8 00 00 00 00       	mov    $0x0,%eax
  800446:	eb 13                	jmp    80045b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800448:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044d:	eb 0c                	jmp    80045b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800454:	eb 05                	jmp    80045b <fd_lookup+0x54>
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    

0080045d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045d:	55                   	push   %ebp
  80045e:	89 e5                	mov    %esp,%ebp
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800466:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046b:	eb 13                	jmp    800480 <dev_lookup+0x23>
  80046d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800470:	39 08                	cmp    %ecx,(%eax)
  800472:	75 0c                	jne    800480 <dev_lookup+0x23>
			*dev = devtab[i];
  800474:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800477:	89 01                	mov    %eax,(%ecx)
			return 0;
  800479:	b8 00 00 00 00       	mov    $0x0,%eax
  80047e:	eb 2e                	jmp    8004ae <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800480:	8b 02                	mov    (%edx),%eax
  800482:	85 c0                	test   %eax,%eax
  800484:	75 e7                	jne    80046d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800486:	a1 04 40 80 00       	mov    0x804004,%eax
  80048b:	8b 40 48             	mov    0x48(%eax),%eax
  80048e:	83 ec 04             	sub    $0x4,%esp
  800491:	51                   	push   %ecx
  800492:	50                   	push   %eax
  800493:	68 38 1e 80 00       	push   $0x801e38
  800498:	e8 b2 0c 00 00       	call   80114f <cprintf>
	*dev = 0;
  80049d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a6:	83 c4 10             	add    $0x10,%esp
  8004a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004ae:	c9                   	leave  
  8004af:	c3                   	ret    

008004b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b0:	55                   	push   %ebp
  8004b1:	89 e5                	mov    %esp,%ebp
  8004b3:	56                   	push   %esi
  8004b4:	53                   	push   %ebx
  8004b5:	83 ec 10             	sub    $0x10,%esp
  8004b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c1:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004c8:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004cb:	50                   	push   %eax
  8004cc:	e8 36 ff ff ff       	call   800407 <fd_lookup>
  8004d1:	83 c4 08             	add    $0x8,%esp
  8004d4:	85 c0                	test   %eax,%eax
  8004d6:	78 05                	js     8004dd <fd_close+0x2d>
	    || fd != fd2)
  8004d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004db:	74 0b                	je     8004e8 <fd_close+0x38>
		return (must_exist ? r : 0);
  8004dd:	80 fb 01             	cmp    $0x1,%bl
  8004e0:	19 d2                	sbb    %edx,%edx
  8004e2:	f7 d2                	not    %edx
  8004e4:	21 d0                	and    %edx,%eax
  8004e6:	eb 41                	jmp    800529 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e8:	83 ec 08             	sub    $0x8,%esp
  8004eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	ff 36                	pushl  (%esi)
  8004f1:	e8 67 ff ff ff       	call   80045d <dev_lookup>
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	85 c0                	test   %eax,%eax
  8004fd:	78 1a                	js     800519 <fd_close+0x69>
		if (dev->dev_close)
  8004ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800502:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800505:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050a:	85 c0                	test   %eax,%eax
  80050c:	74 0b                	je     800519 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80050e:	83 ec 0c             	sub    $0xc,%esp
  800511:	56                   	push   %esi
  800512:	ff d0                	call   *%eax
  800514:	89 c3                	mov    %eax,%ebx
  800516:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800519:	83 ec 08             	sub    $0x8,%esp
  80051c:	56                   	push   %esi
  80051d:	6a 00                	push   $0x0
  80051f:	e8 e2 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	89 d8                	mov    %ebx,%eax
}
  800529:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052c:	5b                   	pop    %ebx
  80052d:	5e                   	pop    %esi
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    

00800530 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800530:	55                   	push   %ebp
  800531:	89 e5                	mov    %esp,%ebp
  800533:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800536:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800539:	50                   	push   %eax
  80053a:	ff 75 08             	pushl  0x8(%ebp)
  80053d:	e8 c5 fe ff ff       	call   800407 <fd_lookup>
  800542:	89 c2                	mov    %eax,%edx
  800544:	83 c4 08             	add    $0x8,%esp
  800547:	85 d2                	test   %edx,%edx
  800549:	78 10                	js     80055b <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	6a 01                	push   $0x1
  800550:	ff 75 f4             	pushl  -0xc(%ebp)
  800553:	e8 58 ff ff ff       	call   8004b0 <fd_close>
  800558:	83 c4 10             	add    $0x10,%esp
}
  80055b:	c9                   	leave  
  80055c:	c3                   	ret    

0080055d <close_all>:

void
close_all(void)
{
  80055d:	55                   	push   %ebp
  80055e:	89 e5                	mov    %esp,%ebp
  800560:	53                   	push   %ebx
  800561:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800564:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800569:	83 ec 0c             	sub    $0xc,%esp
  80056c:	53                   	push   %ebx
  80056d:	e8 be ff ff ff       	call   800530 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800572:	83 c3 01             	add    $0x1,%ebx
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	83 fb 20             	cmp    $0x20,%ebx
  80057b:	75 ec                	jne    800569 <close_all+0xc>
		close(i);
}
  80057d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800580:	c9                   	leave  
  800581:	c3                   	ret    

00800582 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800582:	55                   	push   %ebp
  800583:	89 e5                	mov    %esp,%ebp
  800585:	57                   	push   %edi
  800586:	56                   	push   %esi
  800587:	53                   	push   %ebx
  800588:	83 ec 2c             	sub    $0x2c,%esp
  80058b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800591:	50                   	push   %eax
  800592:	ff 75 08             	pushl  0x8(%ebp)
  800595:	e8 6d fe ff ff       	call   800407 <fd_lookup>
  80059a:	89 c2                	mov    %eax,%edx
  80059c:	83 c4 08             	add    $0x8,%esp
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	0f 88 c1 00 00 00    	js     800668 <dup+0xe6>
		return r;
	close(newfdnum);
  8005a7:	83 ec 0c             	sub    $0xc,%esp
  8005aa:	56                   	push   %esi
  8005ab:	e8 80 ff ff ff       	call   800530 <close>

	newfd = INDEX2FD(newfdnum);
  8005b0:	89 f3                	mov    %esi,%ebx
  8005b2:	c1 e3 0c             	shl    $0xc,%ebx
  8005b5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005bb:	83 c4 04             	add    $0x4,%esp
  8005be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c1:	e8 db fd ff ff       	call   8003a1 <fd2data>
  8005c6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c8:	89 1c 24             	mov    %ebx,(%esp)
  8005cb:	e8 d1 fd ff ff       	call   8003a1 <fd2data>
  8005d0:	83 c4 10             	add    $0x10,%esp
  8005d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d6:	89 f8                	mov    %edi,%eax
  8005d8:	c1 e8 16             	shr    $0x16,%eax
  8005db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e2:	a8 01                	test   $0x1,%al
  8005e4:	74 37                	je     80061d <dup+0x9b>
  8005e6:	89 f8                	mov    %edi,%eax
  8005e8:	c1 e8 0c             	shr    $0xc,%eax
  8005eb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f2:	f6 c2 01             	test   $0x1,%dl
  8005f5:	74 26                	je     80061d <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fe:	83 ec 0c             	sub    $0xc,%esp
  800601:	25 07 0e 00 00       	and    $0xe07,%eax
  800606:	50                   	push   %eax
  800607:	ff 75 d4             	pushl  -0x2c(%ebp)
  80060a:	6a 00                	push   $0x0
  80060c:	57                   	push   %edi
  80060d:	6a 00                	push   $0x0
  80060f:	e8 b0 fb ff ff       	call   8001c4 <sys_page_map>
  800614:	89 c7                	mov    %eax,%edi
  800616:	83 c4 20             	add    $0x20,%esp
  800619:	85 c0                	test   %eax,%eax
  80061b:	78 2e                	js     80064b <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800620:	89 d0                	mov    %edx,%eax
  800622:	c1 e8 0c             	shr    $0xc,%eax
  800625:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062c:	83 ec 0c             	sub    $0xc,%esp
  80062f:	25 07 0e 00 00       	and    $0xe07,%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	6a 00                	push   $0x0
  800638:	52                   	push   %edx
  800639:	6a 00                	push   $0x0
  80063b:	e8 84 fb ff ff       	call   8001c4 <sys_page_map>
  800640:	89 c7                	mov    %eax,%edi
  800642:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800645:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800647:	85 ff                	test   %edi,%edi
  800649:	79 1d                	jns    800668 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064b:	83 ec 08             	sub    $0x8,%esp
  80064e:	53                   	push   %ebx
  80064f:	6a 00                	push   $0x0
  800651:	e8 b0 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800656:	83 c4 08             	add    $0x8,%esp
  800659:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065c:	6a 00                	push   $0x0
  80065e:	e8 a3 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	89 f8                	mov    %edi,%eax
}
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    

00800670 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800670:	55                   	push   %ebp
  800671:	89 e5                	mov    %esp,%ebp
  800673:	53                   	push   %ebx
  800674:	83 ec 14             	sub    $0x14,%esp
  800677:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80067a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067d:	50                   	push   %eax
  80067e:	53                   	push   %ebx
  80067f:	e8 83 fd ff ff       	call   800407 <fd_lookup>
  800684:	83 c4 08             	add    $0x8,%esp
  800687:	89 c2                	mov    %eax,%edx
  800689:	85 c0                	test   %eax,%eax
  80068b:	78 6d                	js     8006fa <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068d:	83 ec 08             	sub    $0x8,%esp
  800690:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800693:	50                   	push   %eax
  800694:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800697:	ff 30                	pushl  (%eax)
  800699:	e8 bf fd ff ff       	call   80045d <dev_lookup>
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	78 4c                	js     8006f1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a8:	8b 42 08             	mov    0x8(%edx),%eax
  8006ab:	83 e0 03             	and    $0x3,%eax
  8006ae:	83 f8 01             	cmp    $0x1,%eax
  8006b1:	75 21                	jne    8006d4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b3:	a1 04 40 80 00       	mov    0x804004,%eax
  8006b8:	8b 40 48             	mov    0x48(%eax),%eax
  8006bb:	83 ec 04             	sub    $0x4,%esp
  8006be:	53                   	push   %ebx
  8006bf:	50                   	push   %eax
  8006c0:	68 79 1e 80 00       	push   $0x801e79
  8006c5:	e8 85 0a 00 00       	call   80114f <cprintf>
		return -E_INVAL;
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d2:	eb 26                	jmp    8006fa <read+0x8a>
	}
	if (!dev->dev_read)
  8006d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d7:	8b 40 08             	mov    0x8(%eax),%eax
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	74 17                	je     8006f5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	ff 75 10             	pushl  0x10(%ebp)
  8006e4:	ff 75 0c             	pushl  0xc(%ebp)
  8006e7:	52                   	push   %edx
  8006e8:	ff d0                	call   *%eax
  8006ea:	89 c2                	mov    %eax,%edx
  8006ec:	83 c4 10             	add    $0x10,%esp
  8006ef:	eb 09                	jmp    8006fa <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f1:	89 c2                	mov    %eax,%edx
  8006f3:	eb 05                	jmp    8006fa <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006fa:	89 d0                	mov    %edx,%eax
  8006fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ff:	c9                   	leave  
  800700:	c3                   	ret    

00800701 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	57                   	push   %edi
  800705:	56                   	push   %esi
  800706:	53                   	push   %ebx
  800707:	83 ec 0c             	sub    $0xc,%esp
  80070a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800710:	bb 00 00 00 00       	mov    $0x0,%ebx
  800715:	eb 21                	jmp    800738 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800717:	83 ec 04             	sub    $0x4,%esp
  80071a:	89 f0                	mov    %esi,%eax
  80071c:	29 d8                	sub    %ebx,%eax
  80071e:	50                   	push   %eax
  80071f:	89 d8                	mov    %ebx,%eax
  800721:	03 45 0c             	add    0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	57                   	push   %edi
  800726:	e8 45 ff ff ff       	call   800670 <read>
		if (m < 0)
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	85 c0                	test   %eax,%eax
  800730:	78 0c                	js     80073e <readn+0x3d>
			return m;
		if (m == 0)
  800732:	85 c0                	test   %eax,%eax
  800734:	74 06                	je     80073c <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800736:	01 c3                	add    %eax,%ebx
  800738:	39 f3                	cmp    %esi,%ebx
  80073a:	72 db                	jb     800717 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80073c:	89 d8                	mov    %ebx,%eax
}
  80073e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5f                   	pop    %edi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    

00800746 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	53                   	push   %ebx
  80074a:	83 ec 14             	sub    $0x14,%esp
  80074d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800750:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	53                   	push   %ebx
  800755:	e8 ad fc ff ff       	call   800407 <fd_lookup>
  80075a:	83 c4 08             	add    $0x8,%esp
  80075d:	89 c2                	mov    %eax,%edx
  80075f:	85 c0                	test   %eax,%eax
  800761:	78 68                	js     8007cb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800769:	50                   	push   %eax
  80076a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80076d:	ff 30                	pushl  (%eax)
  80076f:	e8 e9 fc ff ff       	call   80045d <dev_lookup>
  800774:	83 c4 10             	add    $0x10,%esp
  800777:	85 c0                	test   %eax,%eax
  800779:	78 47                	js     8007c2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80077e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800782:	75 21                	jne    8007a5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800784:	a1 04 40 80 00       	mov    0x804004,%eax
  800789:	8b 40 48             	mov    0x48(%eax),%eax
  80078c:	83 ec 04             	sub    $0x4,%esp
  80078f:	53                   	push   %ebx
  800790:	50                   	push   %eax
  800791:	68 95 1e 80 00       	push   $0x801e95
  800796:	e8 b4 09 00 00       	call   80114f <cprintf>
		return -E_INVAL;
  80079b:	83 c4 10             	add    $0x10,%esp
  80079e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a3:	eb 26                	jmp    8007cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007a8:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ab:	85 d2                	test   %edx,%edx
  8007ad:	74 17                	je     8007c6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007af:	83 ec 04             	sub    $0x4,%esp
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	ff 75 0c             	pushl  0xc(%ebp)
  8007b8:	50                   	push   %eax
  8007b9:	ff d2                	call   *%edx
  8007bb:	89 c2                	mov    %eax,%edx
  8007bd:	83 c4 10             	add    $0x10,%esp
  8007c0:	eb 09                	jmp    8007cb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	eb 05                	jmp    8007cb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007cb:	89 d0                	mov    %edx,%eax
  8007cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d0:	c9                   	leave  
  8007d1:	c3                   	ret    

008007d2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007db:	50                   	push   %eax
  8007dc:	ff 75 08             	pushl  0x8(%ebp)
  8007df:	e8 23 fc ff ff       	call   800407 <fd_lookup>
  8007e4:	83 c4 08             	add    $0x8,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 0e                	js     8007f9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	53                   	push   %ebx
  8007ff:	83 ec 14             	sub    $0x14,%esp
  800802:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800805:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800808:	50                   	push   %eax
  800809:	53                   	push   %ebx
  80080a:	e8 f8 fb ff ff       	call   800407 <fd_lookup>
  80080f:	83 c4 08             	add    $0x8,%esp
  800812:	89 c2                	mov    %eax,%edx
  800814:	85 c0                	test   %eax,%eax
  800816:	78 65                	js     80087d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80081e:	50                   	push   %eax
  80081f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800822:	ff 30                	pushl  (%eax)
  800824:	e8 34 fc ff ff       	call   80045d <dev_lookup>
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	85 c0                	test   %eax,%eax
  80082e:	78 44                	js     800874 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800830:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800833:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800837:	75 21                	jne    80085a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800839:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083e:	8b 40 48             	mov    0x48(%eax),%eax
  800841:	83 ec 04             	sub    $0x4,%esp
  800844:	53                   	push   %ebx
  800845:	50                   	push   %eax
  800846:	68 58 1e 80 00       	push   $0x801e58
  80084b:	e8 ff 08 00 00       	call   80114f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800850:	83 c4 10             	add    $0x10,%esp
  800853:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800858:	eb 23                	jmp    80087d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80085d:	8b 52 18             	mov    0x18(%edx),%edx
  800860:	85 d2                	test   %edx,%edx
  800862:	74 14                	je     800878 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800864:	83 ec 08             	sub    $0x8,%esp
  800867:	ff 75 0c             	pushl  0xc(%ebp)
  80086a:	50                   	push   %eax
  80086b:	ff d2                	call   *%edx
  80086d:	89 c2                	mov    %eax,%edx
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	eb 09                	jmp    80087d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800874:	89 c2                	mov    %eax,%edx
  800876:	eb 05                	jmp    80087d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800878:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80087d:	89 d0                	mov    %edx,%eax
  80087f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800882:	c9                   	leave  
  800883:	c3                   	ret    

00800884 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	53                   	push   %ebx
  800888:	83 ec 14             	sub    $0x14,%esp
  80088b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800891:	50                   	push   %eax
  800892:	ff 75 08             	pushl  0x8(%ebp)
  800895:	e8 6d fb ff ff       	call   800407 <fd_lookup>
  80089a:	83 c4 08             	add    $0x8,%esp
  80089d:	89 c2                	mov    %eax,%edx
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	78 58                	js     8008fb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a3:	83 ec 08             	sub    $0x8,%esp
  8008a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a9:	50                   	push   %eax
  8008aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008ad:	ff 30                	pushl  (%eax)
  8008af:	e8 a9 fb ff ff       	call   80045d <dev_lookup>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	85 c0                	test   %eax,%eax
  8008b9:	78 37                	js     8008f2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008be:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c2:	74 32                	je     8008f6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ce:	00 00 00 
	stat->st_isdir = 0;
  8008d1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d8:	00 00 00 
	stat->st_dev = dev;
  8008db:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	53                   	push   %ebx
  8008e5:	ff 75 f0             	pushl  -0x10(%ebp)
  8008e8:	ff 50 14             	call   *0x14(%eax)
  8008eb:	89 c2                	mov    %eax,%edx
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	eb 09                	jmp    8008fb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f2:	89 c2                	mov    %eax,%edx
  8008f4:	eb 05                	jmp    8008fb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800900:	c9                   	leave  
  800901:	c3                   	ret    

00800902 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	56                   	push   %esi
  800906:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	6a 00                	push   $0x0
  80090c:	ff 75 08             	pushl  0x8(%ebp)
  80090f:	e8 e7 01 00 00       	call   800afb <open>
  800914:	89 c3                	mov    %eax,%ebx
  800916:	83 c4 10             	add    $0x10,%esp
  800919:	85 db                	test   %ebx,%ebx
  80091b:	78 1b                	js     800938 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	ff 75 0c             	pushl  0xc(%ebp)
  800923:	53                   	push   %ebx
  800924:	e8 5b ff ff ff       	call   800884 <fstat>
  800929:	89 c6                	mov    %eax,%esi
	close(fd);
  80092b:	89 1c 24             	mov    %ebx,(%esp)
  80092e:	e8 fd fb ff ff       	call   800530 <close>
	return r;
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	89 f0                	mov    %esi,%eax
}
  800938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	89 c6                	mov    %eax,%esi
  800946:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800948:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80094f:	75 12                	jne    800963 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800951:	83 ec 0c             	sub    $0xc,%esp
  800954:	6a 03                	push   $0x3
  800956:	e8 7d 11 00 00       	call   801ad8 <ipc_find_env>
  80095b:	a3 00 40 80 00       	mov    %eax,0x804000
  800960:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800963:	6a 07                	push   $0x7
  800965:	68 00 50 80 00       	push   $0x805000
  80096a:	56                   	push   %esi
  80096b:	ff 35 00 40 80 00    	pushl  0x804000
  800971:	e8 11 11 00 00       	call   801a87 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800976:	83 c4 0c             	add    $0xc,%esp
  800979:	6a 00                	push   $0x0
  80097b:	53                   	push   %ebx
  80097c:	6a 00                	push   $0x0
  80097e:	e8 9e 10 00 00       	call   801a21 <ipc_recv>
}
  800983:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800986:	5b                   	pop    %ebx
  800987:	5e                   	pop    %esi
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800990:	8b 45 08             	mov    0x8(%ebp),%eax
  800993:	8b 40 0c             	mov    0xc(%eax),%eax
  800996:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80099e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a8:	b8 02 00 00 00       	mov    $0x2,%eax
  8009ad:	e8 8d ff ff ff       	call   80093f <fsipc>
}
  8009b2:	c9                   	leave  
  8009b3:	c3                   	ret    

008009b4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8009bd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	b8 06 00 00 00       	mov    $0x6,%eax
  8009cf:	e8 6b ff ff ff       	call   80093f <fsipc>
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	53                   	push   %ebx
  8009da:	83 ec 04             	sub    $0x4,%esp
  8009dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f0:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f5:	e8 45 ff ff ff       	call   80093f <fsipc>
  8009fa:	89 c2                	mov    %eax,%edx
  8009fc:	85 d2                	test   %edx,%edx
  8009fe:	78 2c                	js     800a2c <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a00:	83 ec 08             	sub    $0x8,%esp
  800a03:	68 00 50 80 00       	push   $0x805000
  800a08:	53                   	push   %ebx
  800a09:	e8 c5 0c 00 00       	call   8016d3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0e:	a1 80 50 80 00       	mov    0x805080,%eax
  800a13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a19:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a24:	83 c4 10             	add    $0x10,%esp
  800a27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	83 ec 08             	sub    $0x8,%esp
  800a37:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3d:	8b 52 0c             	mov    0xc(%edx),%edx
  800a40:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a46:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a4b:	76 05                	jbe    800a52 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a4d:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a52:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a57:	83 ec 04             	sub    $0x4,%esp
  800a5a:	50                   	push   %eax
  800a5b:	ff 75 0c             	pushl  0xc(%ebp)
  800a5e:	68 08 50 80 00       	push   $0x805008
  800a63:	e8 fd 0d 00 00       	call   801865 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a72:	e8 c8 fe ff ff       	call   80093f <fsipc>
	return write;
}
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 40 0c             	mov    0xc(%eax),%eax
  800a87:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a92:	ba 00 00 00 00       	mov    $0x0,%edx
  800a97:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9c:	e8 9e fe ff ff       	call   80093f <fsipc>
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	78 4b                	js     800af2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa7:	39 c6                	cmp    %eax,%esi
  800aa9:	73 16                	jae    800ac1 <devfile_read+0x48>
  800aab:	68 c4 1e 80 00       	push   $0x801ec4
  800ab0:	68 cb 1e 80 00       	push   $0x801ecb
  800ab5:	6a 7c                	push   $0x7c
  800ab7:	68 e0 1e 80 00       	push   $0x801ee0
  800abc:	e8 b5 05 00 00       	call   801076 <_panic>
	assert(r <= PGSIZE);
  800ac1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac6:	7e 16                	jle    800ade <devfile_read+0x65>
  800ac8:	68 eb 1e 80 00       	push   $0x801eeb
  800acd:	68 cb 1e 80 00       	push   $0x801ecb
  800ad2:	6a 7d                	push   $0x7d
  800ad4:	68 e0 1e 80 00       	push   $0x801ee0
  800ad9:	e8 98 05 00 00       	call   801076 <_panic>
	memmove(buf, &fsipcbuf, r);
  800ade:	83 ec 04             	sub    $0x4,%esp
  800ae1:	50                   	push   %eax
  800ae2:	68 00 50 80 00       	push   $0x805000
  800ae7:	ff 75 0c             	pushl  0xc(%ebp)
  800aea:	e8 76 0d 00 00       	call   801865 <memmove>
	return r;
  800aef:	83 c4 10             	add    $0x10,%esp
}
  800af2:	89 d8                	mov    %ebx,%eax
  800af4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	53                   	push   %ebx
  800aff:	83 ec 20             	sub    $0x20,%esp
  800b02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b05:	53                   	push   %ebx
  800b06:	e8 8f 0b 00 00       	call   80169a <strlen>
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b13:	7f 67                	jg     800b7c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b15:	83 ec 0c             	sub    $0xc,%esp
  800b18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1b:	50                   	push   %eax
  800b1c:	e8 97 f8 ff ff       	call   8003b8 <fd_alloc>
  800b21:	83 c4 10             	add    $0x10,%esp
		return r;
  800b24:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b26:	85 c0                	test   %eax,%eax
  800b28:	78 57                	js     800b81 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b2a:	83 ec 08             	sub    $0x8,%esp
  800b2d:	53                   	push   %ebx
  800b2e:	68 00 50 80 00       	push   $0x805000
  800b33:	e8 9b 0b 00 00       	call   8016d3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b43:	b8 01 00 00 00       	mov    $0x1,%eax
  800b48:	e8 f2 fd ff ff       	call   80093f <fsipc>
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	83 c4 10             	add    $0x10,%esp
  800b52:	85 c0                	test   %eax,%eax
  800b54:	79 14                	jns    800b6a <open+0x6f>
		fd_close(fd, 0);
  800b56:	83 ec 08             	sub    $0x8,%esp
  800b59:	6a 00                	push   $0x0
  800b5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5e:	e8 4d f9 ff ff       	call   8004b0 <fd_close>
		return r;
  800b63:	83 c4 10             	add    $0x10,%esp
  800b66:	89 da                	mov    %ebx,%edx
  800b68:	eb 17                	jmp    800b81 <open+0x86>
	}

	return fd2num(fd);
  800b6a:	83 ec 0c             	sub    $0xc,%esp
  800b6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b70:	e8 1c f8 ff ff       	call   800391 <fd2num>
  800b75:	89 c2                	mov    %eax,%edx
  800b77:	83 c4 10             	add    $0x10,%esp
  800b7a:	eb 05                	jmp    800b81 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b81:	89 d0                	mov    %edx,%eax
  800b83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b86:	c9                   	leave  
  800b87:	c3                   	ret    

00800b88 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b93:	b8 08 00 00 00       	mov    $0x8,%eax
  800b98:	e8 a2 fd ff ff       	call   80093f <fsipc>
}
  800b9d:	c9                   	leave  
  800b9e:	c3                   	ret    

00800b9f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b9f:	55                   	push   %ebp
  800ba0:	89 e5                	mov    %esp,%ebp
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	ff 75 08             	pushl  0x8(%ebp)
  800bad:	e8 ef f7 ff ff       	call   8003a1 <fd2data>
  800bb2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800bb4:	83 c4 08             	add    $0x8,%esp
  800bb7:	68 f7 1e 80 00       	push   $0x801ef7
  800bbc:	53                   	push   %ebx
  800bbd:	e8 11 0b 00 00       	call   8016d3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800bc2:	8b 56 04             	mov    0x4(%esi),%edx
  800bc5:	89 d0                	mov    %edx,%eax
  800bc7:	2b 06                	sub    (%esi),%eax
  800bc9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bcf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bd6:	00 00 00 
	stat->st_dev = &devpipe;
  800bd9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800be0:	30 80 00 
	return 0;
}
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
  800be8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	53                   	push   %ebx
  800bf3:	83 ec 0c             	sub    $0xc,%esp
  800bf6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bf9:	53                   	push   %ebx
  800bfa:	6a 00                	push   $0x0
  800bfc:	e8 05 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800c01:	89 1c 24             	mov    %ebx,(%esp)
  800c04:	e8 98 f7 ff ff       	call   8003a1 <fd2data>
  800c09:	83 c4 08             	add    $0x8,%esp
  800c0c:	50                   	push   %eax
  800c0d:	6a 00                	push   $0x0
  800c0f:	e8 f2 f5 ff ff       	call   800206 <sys_page_unmap>
}
  800c14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c17:	c9                   	leave  
  800c18:	c3                   	ret    

00800c19 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800c19:	55                   	push   %ebp
  800c1a:	89 e5                	mov    %esp,%ebp
  800c1c:	57                   	push   %edi
  800c1d:	56                   	push   %esi
  800c1e:	53                   	push   %ebx
  800c1f:	83 ec 1c             	sub    $0x1c,%esp
  800c22:	89 c7                	mov    %eax,%edi
  800c24:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c26:	a1 04 40 80 00       	mov    0x804004,%eax
  800c2b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c2e:	83 ec 0c             	sub    $0xc,%esp
  800c31:	57                   	push   %edi
  800c32:	e8 d9 0e 00 00       	call   801b10 <pageref>
  800c37:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c3a:	89 34 24             	mov    %esi,(%esp)
  800c3d:	e8 ce 0e 00 00       	call   801b10 <pageref>
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c48:	0f 94 c0             	sete   %al
  800c4b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c4e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c54:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c57:	39 cb                	cmp    %ecx,%ebx
  800c59:	74 15                	je     800c70 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c5b:	8b 52 58             	mov    0x58(%edx),%edx
  800c5e:	50                   	push   %eax
  800c5f:	52                   	push   %edx
  800c60:	53                   	push   %ebx
  800c61:	68 04 1f 80 00       	push   $0x801f04
  800c66:	e8 e4 04 00 00       	call   80114f <cprintf>
  800c6b:	83 c4 10             	add    $0x10,%esp
  800c6e:	eb b6                	jmp    800c26 <_pipeisclosed+0xd>
	}
}
  800c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    

00800c78 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 28             	sub    $0x28,%esp
  800c81:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c84:	56                   	push   %esi
  800c85:	e8 17 f7 ff ff       	call   8003a1 <fd2data>
  800c8a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c8c:	83 c4 10             	add    $0x10,%esp
  800c8f:	bf 00 00 00 00       	mov    $0x0,%edi
  800c94:	eb 4b                	jmp    800ce1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c96:	89 da                	mov    %ebx,%edx
  800c98:	89 f0                	mov    %esi,%eax
  800c9a:	e8 7a ff ff ff       	call   800c19 <_pipeisclosed>
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	75 48                	jne    800ceb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800ca3:	e8 ba f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800ca8:	8b 43 04             	mov    0x4(%ebx),%eax
  800cab:	8b 0b                	mov    (%ebx),%ecx
  800cad:	8d 51 20             	lea    0x20(%ecx),%edx
  800cb0:	39 d0                	cmp    %edx,%eax
  800cb2:	73 e2                	jae    800c96 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800cbb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800cbe:	89 c2                	mov    %eax,%edx
  800cc0:	c1 fa 1f             	sar    $0x1f,%edx
  800cc3:	89 d1                	mov    %edx,%ecx
  800cc5:	c1 e9 1b             	shr    $0x1b,%ecx
  800cc8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ccb:	83 e2 1f             	and    $0x1f,%edx
  800cce:	29 ca                	sub    %ecx,%edx
  800cd0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cd4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cd8:	83 c0 01             	add    $0x1,%eax
  800cdb:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cde:	83 c7 01             	add    $0x1,%edi
  800ce1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ce4:	75 c2                	jne    800ca8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ce6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce9:	eb 05                	jmp    800cf0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ceb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 18             	sub    $0x18,%esp
  800d01:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800d04:	57                   	push   %edi
  800d05:	e8 97 f6 ff ff       	call   8003a1 <fd2data>
  800d0a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0c:	83 c4 10             	add    $0x10,%esp
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	eb 3d                	jmp    800d53 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800d16:	85 db                	test   %ebx,%ebx
  800d18:	74 04                	je     800d1e <devpipe_read+0x26>
				return i;
  800d1a:	89 d8                	mov    %ebx,%eax
  800d1c:	eb 44                	jmp    800d62 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d1e:	89 f2                	mov    %esi,%edx
  800d20:	89 f8                	mov    %edi,%eax
  800d22:	e8 f2 fe ff ff       	call   800c19 <_pipeisclosed>
  800d27:	85 c0                	test   %eax,%eax
  800d29:	75 32                	jne    800d5d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d2b:	e8 32 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d30:	8b 06                	mov    (%esi),%eax
  800d32:	3b 46 04             	cmp    0x4(%esi),%eax
  800d35:	74 df                	je     800d16 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d37:	99                   	cltd   
  800d38:	c1 ea 1b             	shr    $0x1b,%edx
  800d3b:	01 d0                	add    %edx,%eax
  800d3d:	83 e0 1f             	and    $0x1f,%eax
  800d40:	29 d0                	sub    %edx,%eax
  800d42:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d4d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d50:	83 c3 01             	add    $0x1,%ebx
  800d53:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d56:	75 d8                	jne    800d30 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d58:	8b 45 10             	mov    0x10(%ebp),%eax
  800d5b:	eb 05                	jmp    800d62 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d5d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
  800d6f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d75:	50                   	push   %eax
  800d76:	e8 3d f6 ff ff       	call   8003b8 <fd_alloc>
  800d7b:	83 c4 10             	add    $0x10,%esp
  800d7e:	89 c2                	mov    %eax,%edx
  800d80:	85 c0                	test   %eax,%eax
  800d82:	0f 88 2c 01 00 00    	js     800eb4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d88:	83 ec 04             	sub    $0x4,%esp
  800d8b:	68 07 04 00 00       	push   $0x407
  800d90:	ff 75 f4             	pushl  -0xc(%ebp)
  800d93:	6a 00                	push   $0x0
  800d95:	e8 e7 f3 ff ff       	call   800181 <sys_page_alloc>
  800d9a:	83 c4 10             	add    $0x10,%esp
  800d9d:	89 c2                	mov    %eax,%edx
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	0f 88 0d 01 00 00    	js     800eb4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800dad:	50                   	push   %eax
  800dae:	e8 05 f6 ff ff       	call   8003b8 <fd_alloc>
  800db3:	89 c3                	mov    %eax,%ebx
  800db5:	83 c4 10             	add    $0x10,%esp
  800db8:	85 c0                	test   %eax,%eax
  800dba:	0f 88 e2 00 00 00    	js     800ea2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc0:	83 ec 04             	sub    $0x4,%esp
  800dc3:	68 07 04 00 00       	push   $0x407
  800dc8:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcb:	6a 00                	push   $0x0
  800dcd:	e8 af f3 ff ff       	call   800181 <sys_page_alloc>
  800dd2:	89 c3                	mov    %eax,%ebx
  800dd4:	83 c4 10             	add    $0x10,%esp
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	0f 88 c3 00 00 00    	js     800ea2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800ddf:	83 ec 0c             	sub    $0xc,%esp
  800de2:	ff 75 f4             	pushl  -0xc(%ebp)
  800de5:	e8 b7 f5 ff ff       	call   8003a1 <fd2data>
  800dea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dec:	83 c4 0c             	add    $0xc,%esp
  800def:	68 07 04 00 00       	push   $0x407
  800df4:	50                   	push   %eax
  800df5:	6a 00                	push   $0x0
  800df7:	e8 85 f3 ff ff       	call   800181 <sys_page_alloc>
  800dfc:	89 c3                	mov    %eax,%ebx
  800dfe:	83 c4 10             	add    $0x10,%esp
  800e01:	85 c0                	test   %eax,%eax
  800e03:	0f 88 89 00 00 00    	js     800e92 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800e09:	83 ec 0c             	sub    $0xc,%esp
  800e0c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e0f:	e8 8d f5 ff ff       	call   8003a1 <fd2data>
  800e14:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e1b:	50                   	push   %eax
  800e1c:	6a 00                	push   $0x0
  800e1e:	56                   	push   %esi
  800e1f:	6a 00                	push   $0x0
  800e21:	e8 9e f3 ff ff       	call   8001c4 <sys_page_map>
  800e26:	89 c3                	mov    %eax,%ebx
  800e28:	83 c4 20             	add    $0x20,%esp
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	78 55                	js     800e84 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e2f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e38:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e3d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e44:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e4a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e4d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e52:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e59:	83 ec 0c             	sub    $0xc,%esp
  800e5c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e5f:	e8 2d f5 ff ff       	call   800391 <fd2num>
  800e64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e67:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e69:	83 c4 04             	add    $0x4,%esp
  800e6c:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6f:	e8 1d f5 ff ff       	call   800391 <fd2num>
  800e74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e77:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e82:	eb 30                	jmp    800eb4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e84:	83 ec 08             	sub    $0x8,%esp
  800e87:	56                   	push   %esi
  800e88:	6a 00                	push   $0x0
  800e8a:	e8 77 f3 ff ff       	call   800206 <sys_page_unmap>
  800e8f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e92:	83 ec 08             	sub    $0x8,%esp
  800e95:	ff 75 f0             	pushl  -0x10(%ebp)
  800e98:	6a 00                	push   $0x0
  800e9a:	e8 67 f3 ff ff       	call   800206 <sys_page_unmap>
  800e9f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800ea2:	83 ec 08             	sub    $0x8,%esp
  800ea5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea8:	6a 00                	push   $0x0
  800eaa:	e8 57 f3 ff ff       	call   800206 <sys_page_unmap>
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800eb4:	89 d0                	mov    %edx,%eax
  800eb6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5d                   	pop    %ebp
  800ebc:	c3                   	ret    

00800ebd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ec3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec6:	50                   	push   %eax
  800ec7:	ff 75 08             	pushl  0x8(%ebp)
  800eca:	e8 38 f5 ff ff       	call   800407 <fd_lookup>
  800ecf:	89 c2                	mov    %eax,%edx
  800ed1:	83 c4 10             	add    $0x10,%esp
  800ed4:	85 d2                	test   %edx,%edx
  800ed6:	78 18                	js     800ef0 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ede:	e8 be f4 ff ff       	call   8003a1 <fd2data>
	return _pipeisclosed(fd, p);
  800ee3:	89 c2                	mov    %eax,%edx
  800ee5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ee8:	e8 2c fd ff ff       	call   800c19 <_pipeisclosed>
  800eed:	83 c4 10             	add    $0x10,%esp
}
  800ef0:	c9                   	leave  
  800ef1:	c3                   	ret    

00800ef2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ef5:	b8 00 00 00 00       	mov    $0x0,%eax
  800efa:	5d                   	pop    %ebp
  800efb:	c3                   	ret    

00800efc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800f02:	68 35 1f 80 00       	push   $0x801f35
  800f07:	ff 75 0c             	pushl  0xc(%ebp)
  800f0a:	e8 c4 07 00 00       	call   8016d3 <strcpy>
	return 0;
}
  800f0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	57                   	push   %edi
  800f1a:	56                   	push   %esi
  800f1b:	53                   	push   %ebx
  800f1c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f22:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f27:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2d:	eb 2e                	jmp    800f5d <devcons_write+0x47>
		m = n - tot;
  800f2f:	8b 55 10             	mov    0x10(%ebp),%edx
  800f32:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f34:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f39:	83 fa 7f             	cmp    $0x7f,%edx
  800f3c:	77 02                	ja     800f40 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f3e:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	56                   	push   %esi
  800f44:	03 45 0c             	add    0xc(%ebp),%eax
  800f47:	50                   	push   %eax
  800f48:	57                   	push   %edi
  800f49:	e8 17 09 00 00       	call   801865 <memmove>
		sys_cputs(buf, m);
  800f4e:	83 c4 08             	add    $0x8,%esp
  800f51:	56                   	push   %esi
  800f52:	57                   	push   %edi
  800f53:	e8 6d f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f58:	01 f3                	add    %esi,%ebx
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	89 d8                	mov    %ebx,%eax
  800f5f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f62:	72 cb                	jb     800f2f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f67:	5b                   	pop    %ebx
  800f68:	5e                   	pop    %esi
  800f69:	5f                   	pop    %edi
  800f6a:	5d                   	pop    %ebp
  800f6b:	c3                   	ret    

00800f6c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f72:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f77:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f7b:	75 07                	jne    800f84 <devcons_read+0x18>
  800f7d:	eb 28                	jmp    800fa7 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f7f:	e8 de f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f84:	e8 5a f1 ff ff       	call   8000e3 <sys_cgetc>
  800f89:	85 c0                	test   %eax,%eax
  800f8b:	74 f2                	je     800f7f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f8d:	85 c0                	test   %eax,%eax
  800f8f:	78 16                	js     800fa7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f91:	83 f8 04             	cmp    $0x4,%eax
  800f94:	74 0c                	je     800fa2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f99:	88 02                	mov    %al,(%edx)
	return 1;
  800f9b:	b8 01 00 00 00       	mov    $0x1,%eax
  800fa0:	eb 05                	jmp    800fa7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800fa7:	c9                   	leave  
  800fa8:	c3                   	ret    

00800fa9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800fb5:	6a 01                	push   $0x1
  800fb7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fba:	50                   	push   %eax
  800fbb:	e8 05 f1 ff ff       	call   8000c5 <sys_cputs>
  800fc0:	83 c4 10             	add    $0x10,%esp
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    

00800fc5 <getchar>:

int
getchar(void)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fcb:	6a 01                	push   $0x1
  800fcd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fd0:	50                   	push   %eax
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 98 f6 ff ff       	call   800670 <read>
	if (r < 0)
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 0f                	js     800fee <getchar+0x29>
		return r;
	if (r < 1)
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	7e 06                	jle    800fe9 <getchar+0x24>
		return -E_EOF;
	return c;
  800fe3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fe7:	eb 05                	jmp    800fee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fe9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff9:	50                   	push   %eax
  800ffa:	ff 75 08             	pushl  0x8(%ebp)
  800ffd:	e8 05 f4 ff ff       	call   800407 <fd_lookup>
  801002:	83 c4 10             	add    $0x10,%esp
  801005:	85 c0                	test   %eax,%eax
  801007:	78 11                	js     80101a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801009:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80100c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801012:	39 10                	cmp    %edx,(%eax)
  801014:	0f 94 c0             	sete   %al
  801017:	0f b6 c0             	movzbl %al,%eax
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <opencons>:

int
opencons(void)
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801025:	50                   	push   %eax
  801026:	e8 8d f3 ff ff       	call   8003b8 <fd_alloc>
  80102b:	83 c4 10             	add    $0x10,%esp
		return r;
  80102e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801030:	85 c0                	test   %eax,%eax
  801032:	78 3e                	js     801072 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801034:	83 ec 04             	sub    $0x4,%esp
  801037:	68 07 04 00 00       	push   $0x407
  80103c:	ff 75 f4             	pushl  -0xc(%ebp)
  80103f:	6a 00                	push   $0x0
  801041:	e8 3b f1 ff ff       	call   800181 <sys_page_alloc>
  801046:	83 c4 10             	add    $0x10,%esp
		return r;
  801049:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80104b:	85 c0                	test   %eax,%eax
  80104d:	78 23                	js     801072 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80104f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801055:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801058:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80105a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801064:	83 ec 0c             	sub    $0xc,%esp
  801067:	50                   	push   %eax
  801068:	e8 24 f3 ff ff       	call   800391 <fd2num>
  80106d:	89 c2                	mov    %eax,%edx
  80106f:	83 c4 10             	add    $0x10,%esp
}
  801072:	89 d0                	mov    %edx,%eax
  801074:	c9                   	leave  
  801075:	c3                   	ret    

00801076 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	56                   	push   %esi
  80107a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80107b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80107e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801084:	e8 ba f0 ff ff       	call   800143 <sys_getenvid>
  801089:	83 ec 0c             	sub    $0xc,%esp
  80108c:	ff 75 0c             	pushl  0xc(%ebp)
  80108f:	ff 75 08             	pushl  0x8(%ebp)
  801092:	56                   	push   %esi
  801093:	50                   	push   %eax
  801094:	68 44 1f 80 00       	push   $0x801f44
  801099:	e8 b1 00 00 00       	call   80114f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80109e:	83 c4 18             	add    $0x18,%esp
  8010a1:	53                   	push   %ebx
  8010a2:	ff 75 10             	pushl  0x10(%ebp)
  8010a5:	e8 54 00 00 00       	call   8010fe <vcprintf>
	cprintf("\n");
  8010aa:	c7 04 24 93 1e 80 00 	movl   $0x801e93,(%esp)
  8010b1:	e8 99 00 00 00       	call   80114f <cprintf>
  8010b6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b9:	cc                   	int3   
  8010ba:	eb fd                	jmp    8010b9 <_panic+0x43>

008010bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010bc:	55                   	push   %ebp
  8010bd:	89 e5                	mov    %esp,%ebp
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 04             	sub    $0x4,%esp
  8010c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c6:	8b 13                	mov    (%ebx),%edx
  8010c8:	8d 42 01             	lea    0x1(%edx),%eax
  8010cb:	89 03                	mov    %eax,(%ebx)
  8010cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010d9:	75 1a                	jne    8010f5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010db:	83 ec 08             	sub    $0x8,%esp
  8010de:	68 ff 00 00 00       	push   $0xff
  8010e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8010e6:	50                   	push   %eax
  8010e7:	e8 d9 ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010f2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010f5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fc:	c9                   	leave  
  8010fd:	c3                   	ret    

008010fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
  801101:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801107:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80110e:	00 00 00 
	b.cnt = 0;
  801111:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801118:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80111b:	ff 75 0c             	pushl  0xc(%ebp)
  80111e:	ff 75 08             	pushl  0x8(%ebp)
  801121:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	68 bc 10 80 00       	push   $0x8010bc
  80112d:	e8 4f 01 00 00       	call   801281 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801132:	83 c4 08             	add    $0x8,%esp
  801135:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80113b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801141:	50                   	push   %eax
  801142:	e8 7e ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801147:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80114d:	c9                   	leave  
  80114e:	c3                   	ret    

0080114f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801155:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801158:	50                   	push   %eax
  801159:	ff 75 08             	pushl  0x8(%ebp)
  80115c:	e8 9d ff ff ff       	call   8010fe <vcprintf>
	va_end(ap);

	return cnt;
}
  801161:	c9                   	leave  
  801162:	c3                   	ret    

00801163 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801163:	55                   	push   %ebp
  801164:	89 e5                	mov    %esp,%ebp
  801166:	57                   	push   %edi
  801167:	56                   	push   %esi
  801168:	53                   	push   %ebx
  801169:	83 ec 1c             	sub    $0x1c,%esp
  80116c:	89 c7                	mov    %eax,%edi
  80116e:	89 d6                	mov    %edx,%esi
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	8b 55 0c             	mov    0xc(%ebp),%edx
  801176:	89 d1                	mov    %edx,%ecx
  801178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80117b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80117e:	8b 45 10             	mov    0x10(%ebp),%eax
  801181:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801184:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801187:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80118e:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801191:	72 05                	jb     801198 <printnum+0x35>
  801193:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801196:	77 3e                	ja     8011d6 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801198:	83 ec 0c             	sub    $0xc,%esp
  80119b:	ff 75 18             	pushl  0x18(%ebp)
  80119e:	83 eb 01             	sub    $0x1,%ebx
  8011a1:	53                   	push   %ebx
  8011a2:	50                   	push   %eax
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8011af:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b2:	e8 99 09 00 00       	call   801b50 <__udivdi3>
  8011b7:	83 c4 18             	add    $0x18,%esp
  8011ba:	52                   	push   %edx
  8011bb:	50                   	push   %eax
  8011bc:	89 f2                	mov    %esi,%edx
  8011be:	89 f8                	mov    %edi,%eax
  8011c0:	e8 9e ff ff ff       	call   801163 <printnum>
  8011c5:	83 c4 20             	add    $0x20,%esp
  8011c8:	eb 13                	jmp    8011dd <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	56                   	push   %esi
  8011ce:	ff 75 18             	pushl  0x18(%ebp)
  8011d1:	ff d7                	call   *%edi
  8011d3:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011d6:	83 eb 01             	sub    $0x1,%ebx
  8011d9:	85 db                	test   %ebx,%ebx
  8011db:	7f ed                	jg     8011ca <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011dd:	83 ec 08             	sub    $0x8,%esp
  8011e0:	56                   	push   %esi
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8011f0:	e8 8b 0a 00 00       	call   801c80 <__umoddi3>
  8011f5:	83 c4 14             	add    $0x14,%esp
  8011f8:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011ff:	50                   	push   %eax
  801200:	ff d7                	call   *%edi
  801202:	83 c4 10             	add    $0x10,%esp
}
  801205:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801208:	5b                   	pop    %ebx
  801209:	5e                   	pop    %esi
  80120a:	5f                   	pop    %edi
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801210:	83 fa 01             	cmp    $0x1,%edx
  801213:	7e 0e                	jle    801223 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801215:	8b 10                	mov    (%eax),%edx
  801217:	8d 4a 08             	lea    0x8(%edx),%ecx
  80121a:	89 08                	mov    %ecx,(%eax)
  80121c:	8b 02                	mov    (%edx),%eax
  80121e:	8b 52 04             	mov    0x4(%edx),%edx
  801221:	eb 22                	jmp    801245 <getuint+0x38>
	else if (lflag)
  801223:	85 d2                	test   %edx,%edx
  801225:	74 10                	je     801237 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801227:	8b 10                	mov    (%eax),%edx
  801229:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122c:	89 08                	mov    %ecx,(%eax)
  80122e:	8b 02                	mov    (%edx),%eax
  801230:	ba 00 00 00 00       	mov    $0x0,%edx
  801235:	eb 0e                	jmp    801245 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801237:	8b 10                	mov    (%eax),%edx
  801239:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123c:	89 08                	mov    %ecx,(%eax)
  80123e:	8b 02                	mov    (%edx),%eax
  801240:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    

00801247 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80124d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801251:	8b 10                	mov    (%eax),%edx
  801253:	3b 50 04             	cmp    0x4(%eax),%edx
  801256:	73 0a                	jae    801262 <sprintputch+0x1b>
		*b->buf++ = ch;
  801258:	8d 4a 01             	lea    0x1(%edx),%ecx
  80125b:	89 08                	mov    %ecx,(%eax)
  80125d:	8b 45 08             	mov    0x8(%ebp),%eax
  801260:	88 02                	mov    %al,(%edx)
}
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80126a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80126d:	50                   	push   %eax
  80126e:	ff 75 10             	pushl  0x10(%ebp)
  801271:	ff 75 0c             	pushl  0xc(%ebp)
  801274:	ff 75 08             	pushl  0x8(%ebp)
  801277:	e8 05 00 00 00       	call   801281 <vprintfmt>
	va_end(ap);
  80127c:	83 c4 10             	add    $0x10,%esp
}
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	57                   	push   %edi
  801285:	56                   	push   %esi
  801286:	53                   	push   %ebx
  801287:	83 ec 2c             	sub    $0x2c,%esp
  80128a:	8b 75 08             	mov    0x8(%ebp),%esi
  80128d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801290:	8b 7d 10             	mov    0x10(%ebp),%edi
  801293:	eb 12                	jmp    8012a7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801295:	85 c0                	test   %eax,%eax
  801297:	0f 84 8d 03 00 00    	je     80162a <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	53                   	push   %ebx
  8012a1:	50                   	push   %eax
  8012a2:	ff d6                	call   *%esi
  8012a4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8012a7:	83 c7 01             	add    $0x1,%edi
  8012aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8012ae:	83 f8 25             	cmp    $0x25,%eax
  8012b1:	75 e2                	jne    801295 <vprintfmt+0x14>
  8012b3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8012b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d1:	eb 07                	jmp    8012da <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012d6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012da:	8d 47 01             	lea    0x1(%edi),%eax
  8012dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e0:	0f b6 07             	movzbl (%edi),%eax
  8012e3:	0f b6 c8             	movzbl %al,%ecx
  8012e6:	83 e8 23             	sub    $0x23,%eax
  8012e9:	3c 55                	cmp    $0x55,%al
  8012eb:	0f 87 1e 03 00 00    	ja     80160f <vprintfmt+0x38e>
  8012f1:	0f b6 c0             	movzbl %al,%eax
  8012f4:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012fe:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801302:	eb d6                	jmp    8012da <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801307:	b8 00 00 00 00       	mov    $0x0,%eax
  80130c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80130f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801312:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801316:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801319:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80131c:	83 fa 09             	cmp    $0x9,%edx
  80131f:	77 38                	ja     801359 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801321:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801324:	eb e9                	jmp    80130f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801326:	8b 45 14             	mov    0x14(%ebp),%eax
  801329:	8d 48 04             	lea    0x4(%eax),%ecx
  80132c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80132f:	8b 00                	mov    (%eax),%eax
  801331:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801337:	eb 26                	jmp    80135f <vprintfmt+0xde>
  801339:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80133c:	89 c8                	mov    %ecx,%eax
  80133e:	c1 f8 1f             	sar    $0x1f,%eax
  801341:	f7 d0                	not    %eax
  801343:	21 c1                	and    %eax,%ecx
  801345:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80134b:	eb 8d                	jmp    8012da <vprintfmt+0x59>
  80134d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801350:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801357:	eb 81                	jmp    8012da <vprintfmt+0x59>
  801359:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80135c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80135f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801363:	0f 89 71 ff ff ff    	jns    8012da <vprintfmt+0x59>
				width = precision, precision = -1;
  801369:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80136c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80136f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801376:	e9 5f ff ff ff       	jmp    8012da <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80137b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801381:	e9 54 ff ff ff       	jmp    8012da <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801386:	8b 45 14             	mov    0x14(%ebp),%eax
  801389:	8d 50 04             	lea    0x4(%eax),%edx
  80138c:	89 55 14             	mov    %edx,0x14(%ebp)
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	53                   	push   %ebx
  801393:	ff 30                	pushl  (%eax)
  801395:	ff d6                	call   *%esi
			break;
  801397:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80139a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80139d:	e9 05 ff ff ff       	jmp    8012a7 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8013a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a5:	8d 50 04             	lea    0x4(%eax),%edx
  8013a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ab:	8b 00                	mov    (%eax),%eax
  8013ad:	99                   	cltd   
  8013ae:	31 d0                	xor    %edx,%eax
  8013b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013b2:	83 f8 0f             	cmp    $0xf,%eax
  8013b5:	7f 0b                	jg     8013c2 <vprintfmt+0x141>
  8013b7:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013be:	85 d2                	test   %edx,%edx
  8013c0:	75 18                	jne    8013da <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8013c2:	50                   	push   %eax
  8013c3:	68 7f 1f 80 00       	push   $0x801f7f
  8013c8:	53                   	push   %ebx
  8013c9:	56                   	push   %esi
  8013ca:	e8 95 fe ff ff       	call   801264 <printfmt>
  8013cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013d5:	e9 cd fe ff ff       	jmp    8012a7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013da:	52                   	push   %edx
  8013db:	68 dd 1e 80 00       	push   $0x801edd
  8013e0:	53                   	push   %ebx
  8013e1:	56                   	push   %esi
  8013e2:	e8 7d fe ff ff       	call   801264 <printfmt>
  8013e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ed:	e9 b5 fe ff ff       	jmp    8012a7 <vprintfmt+0x26>
  8013f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8013fe:	8d 50 04             	lea    0x4(%eax),%edx
  801401:	89 55 14             	mov    %edx,0x14(%ebp)
  801404:	8b 38                	mov    (%eax),%edi
  801406:	85 ff                	test   %edi,%edi
  801408:	75 05                	jne    80140f <vprintfmt+0x18e>
				p = "(null)";
  80140a:	bf 78 1f 80 00       	mov    $0x801f78,%edi
			if (width > 0 && padc != '-')
  80140f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801413:	0f 84 91 00 00 00    	je     8014aa <vprintfmt+0x229>
  801419:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80141d:	0f 8e 95 00 00 00    	jle    8014b8 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	51                   	push   %ecx
  801427:	57                   	push   %edi
  801428:	e8 85 02 00 00       	call   8016b2 <strnlen>
  80142d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801430:	29 c1                	sub    %eax,%ecx
  801432:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801435:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801438:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80143c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80143f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801442:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801444:	eb 0f                	jmp    801455 <vprintfmt+0x1d4>
					putch(padc, putdat);
  801446:	83 ec 08             	sub    $0x8,%esp
  801449:	53                   	push   %ebx
  80144a:	ff 75 e0             	pushl  -0x20(%ebp)
  80144d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80144f:	83 ef 01             	sub    $0x1,%edi
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	85 ff                	test   %edi,%edi
  801457:	7f ed                	jg     801446 <vprintfmt+0x1c5>
  801459:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80145c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80145f:	89 c8                	mov    %ecx,%eax
  801461:	c1 f8 1f             	sar    $0x1f,%eax
  801464:	f7 d0                	not    %eax
  801466:	21 c8                	and    %ecx,%eax
  801468:	29 c1                	sub    %eax,%ecx
  80146a:	89 75 08             	mov    %esi,0x8(%ebp)
  80146d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801470:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801473:	89 cb                	mov    %ecx,%ebx
  801475:	eb 4d                	jmp    8014c4 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801477:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80147b:	74 1b                	je     801498 <vprintfmt+0x217>
  80147d:	0f be c0             	movsbl %al,%eax
  801480:	83 e8 20             	sub    $0x20,%eax
  801483:	83 f8 5e             	cmp    $0x5e,%eax
  801486:	76 10                	jbe    801498 <vprintfmt+0x217>
					putch('?', putdat);
  801488:	83 ec 08             	sub    $0x8,%esp
  80148b:	ff 75 0c             	pushl  0xc(%ebp)
  80148e:	6a 3f                	push   $0x3f
  801490:	ff 55 08             	call   *0x8(%ebp)
  801493:	83 c4 10             	add    $0x10,%esp
  801496:	eb 0d                	jmp    8014a5 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  801498:	83 ec 08             	sub    $0x8,%esp
  80149b:	ff 75 0c             	pushl  0xc(%ebp)
  80149e:	52                   	push   %edx
  80149f:	ff 55 08             	call   *0x8(%ebp)
  8014a2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8014a5:	83 eb 01             	sub    $0x1,%ebx
  8014a8:	eb 1a                	jmp    8014c4 <vprintfmt+0x243>
  8014aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8014ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014b6:	eb 0c                	jmp    8014c4 <vprintfmt+0x243>
  8014b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8014bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014c4:	83 c7 01             	add    $0x1,%edi
  8014c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014cb:	0f be d0             	movsbl %al,%edx
  8014ce:	85 d2                	test   %edx,%edx
  8014d0:	74 23                	je     8014f5 <vprintfmt+0x274>
  8014d2:	85 f6                	test   %esi,%esi
  8014d4:	78 a1                	js     801477 <vprintfmt+0x1f6>
  8014d6:	83 ee 01             	sub    $0x1,%esi
  8014d9:	79 9c                	jns    801477 <vprintfmt+0x1f6>
  8014db:	89 df                	mov    %ebx,%edi
  8014dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8014e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014e3:	eb 18                	jmp    8014fd <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	53                   	push   %ebx
  8014e9:	6a 20                	push   $0x20
  8014eb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ed:	83 ef 01             	sub    $0x1,%edi
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb 08                	jmp    8014fd <vprintfmt+0x27c>
  8014f5:	89 df                	mov    %ebx,%edi
  8014f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8014fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014fd:	85 ff                	test   %edi,%edi
  8014ff:	7f e4                	jg     8014e5 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801504:	e9 9e fd ff ff       	jmp    8012a7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801509:	83 fa 01             	cmp    $0x1,%edx
  80150c:	7e 16                	jle    801524 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80150e:	8b 45 14             	mov    0x14(%ebp),%eax
  801511:	8d 50 08             	lea    0x8(%eax),%edx
  801514:	89 55 14             	mov    %edx,0x14(%ebp)
  801517:	8b 50 04             	mov    0x4(%eax),%edx
  80151a:	8b 00                	mov    (%eax),%eax
  80151c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801522:	eb 32                	jmp    801556 <vprintfmt+0x2d5>
	else if (lflag)
  801524:	85 d2                	test   %edx,%edx
  801526:	74 18                	je     801540 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  801528:	8b 45 14             	mov    0x14(%ebp),%eax
  80152b:	8d 50 04             	lea    0x4(%eax),%edx
  80152e:	89 55 14             	mov    %edx,0x14(%ebp)
  801531:	8b 00                	mov    (%eax),%eax
  801533:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801536:	89 c1                	mov    %eax,%ecx
  801538:	c1 f9 1f             	sar    $0x1f,%ecx
  80153b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80153e:	eb 16                	jmp    801556 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801540:	8b 45 14             	mov    0x14(%ebp),%eax
  801543:	8d 50 04             	lea    0x4(%eax),%edx
  801546:	89 55 14             	mov    %edx,0x14(%ebp)
  801549:	8b 00                	mov    (%eax),%eax
  80154b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154e:	89 c1                	mov    %eax,%ecx
  801550:	c1 f9 1f             	sar    $0x1f,%ecx
  801553:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801556:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801559:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80155c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801561:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801565:	79 74                	jns    8015db <vprintfmt+0x35a>
				putch('-', putdat);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	53                   	push   %ebx
  80156b:	6a 2d                	push   $0x2d
  80156d:	ff d6                	call   *%esi
				num = -(long long) num;
  80156f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801572:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801575:	f7 d8                	neg    %eax
  801577:	83 d2 00             	adc    $0x0,%edx
  80157a:	f7 da                	neg    %edx
  80157c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80157f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801584:	eb 55                	jmp    8015db <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801586:	8d 45 14             	lea    0x14(%ebp),%eax
  801589:	e8 7f fc ff ff       	call   80120d <getuint>
			base = 10;
  80158e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801593:	eb 46                	jmp    8015db <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801595:	8d 45 14             	lea    0x14(%ebp),%eax
  801598:	e8 70 fc ff ff       	call   80120d <getuint>
			base = 8;
  80159d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8015a2:	eb 37                	jmp    8015db <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	53                   	push   %ebx
  8015a8:	6a 30                	push   $0x30
  8015aa:	ff d6                	call   *%esi
			putch('x', putdat);
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	6a 78                	push   $0x78
  8015b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b7:	8d 50 04             	lea    0x4(%eax),%edx
  8015ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015bd:	8b 00                	mov    (%eax),%eax
  8015bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015c7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015cc:	eb 0d                	jmp    8015db <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d1:	e8 37 fc ff ff       	call   80120d <getuint>
			base = 16;
  8015d6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015db:	83 ec 0c             	sub    $0xc,%esp
  8015de:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015e2:	57                   	push   %edi
  8015e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e6:	51                   	push   %ecx
  8015e7:	52                   	push   %edx
  8015e8:	50                   	push   %eax
  8015e9:	89 da                	mov    %ebx,%edx
  8015eb:	89 f0                	mov    %esi,%eax
  8015ed:	e8 71 fb ff ff       	call   801163 <printnum>
			break;
  8015f2:	83 c4 20             	add    $0x20,%esp
  8015f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015f8:	e9 aa fc ff ff       	jmp    8012a7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015fd:	83 ec 08             	sub    $0x8,%esp
  801600:	53                   	push   %ebx
  801601:	51                   	push   %ecx
  801602:	ff d6                	call   *%esi
			break;
  801604:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801607:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80160a:	e9 98 fc ff ff       	jmp    8012a7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	53                   	push   %ebx
  801613:	6a 25                	push   $0x25
  801615:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	eb 03                	jmp    80161f <vprintfmt+0x39e>
  80161c:	83 ef 01             	sub    $0x1,%edi
  80161f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801623:	75 f7                	jne    80161c <vprintfmt+0x39b>
  801625:	e9 7d fc ff ff       	jmp    8012a7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80162a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80162d:	5b                   	pop    %ebx
  80162e:	5e                   	pop    %esi
  80162f:	5f                   	pop    %edi
  801630:	5d                   	pop    %ebp
  801631:	c3                   	ret    

00801632 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801632:	55                   	push   %ebp
  801633:	89 e5                	mov    %esp,%ebp
  801635:	83 ec 18             	sub    $0x18,%esp
  801638:	8b 45 08             	mov    0x8(%ebp),%eax
  80163b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80163e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801641:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801645:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801648:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80164f:	85 c0                	test   %eax,%eax
  801651:	74 26                	je     801679 <vsnprintf+0x47>
  801653:	85 d2                	test   %edx,%edx
  801655:	7e 22                	jle    801679 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801657:	ff 75 14             	pushl  0x14(%ebp)
  80165a:	ff 75 10             	pushl  0x10(%ebp)
  80165d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801660:	50                   	push   %eax
  801661:	68 47 12 80 00       	push   $0x801247
  801666:	e8 16 fc ff ff       	call   801281 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80166b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80166e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801674:	83 c4 10             	add    $0x10,%esp
  801677:	eb 05                	jmp    80167e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801679:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80167e:	c9                   	leave  
  80167f:	c3                   	ret    

00801680 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801686:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801689:	50                   	push   %eax
  80168a:	ff 75 10             	pushl  0x10(%ebp)
  80168d:	ff 75 0c             	pushl  0xc(%ebp)
  801690:	ff 75 08             	pushl  0x8(%ebp)
  801693:	e8 9a ff ff ff       	call   801632 <vsnprintf>
	va_end(ap);

	return rc;
}
  801698:	c9                   	leave  
  801699:	c3                   	ret    

0080169a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80169a:	55                   	push   %ebp
  80169b:	89 e5                	mov    %esp,%ebp
  80169d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a5:	eb 03                	jmp    8016aa <strlen+0x10>
		n++;
  8016a7:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ae:	75 f7                	jne    8016a7 <strlen+0xd>
		n++;
	return n;
}
  8016b0:	5d                   	pop    %ebp
  8016b1:	c3                   	ret    

008016b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b2:	55                   	push   %ebp
  8016b3:	89 e5                	mov    %esp,%ebp
  8016b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c0:	eb 03                	jmp    8016c5 <strnlen+0x13>
		n++;
  8016c2:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c5:	39 c2                	cmp    %eax,%edx
  8016c7:	74 08                	je     8016d1 <strnlen+0x1f>
  8016c9:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016cd:	75 f3                	jne    8016c2 <strnlen+0x10>
  8016cf:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d1:	5d                   	pop    %ebp
  8016d2:	c3                   	ret    

008016d3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	53                   	push   %ebx
  8016d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016dd:	89 c2                	mov    %eax,%edx
  8016df:	83 c2 01             	add    $0x1,%edx
  8016e2:	83 c1 01             	add    $0x1,%ecx
  8016e5:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016e9:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ec:	84 db                	test   %bl,%bl
  8016ee:	75 ef                	jne    8016df <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f0:	5b                   	pop    %ebx
  8016f1:	5d                   	pop    %ebp
  8016f2:	c3                   	ret    

008016f3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	53                   	push   %ebx
  8016f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016fa:	53                   	push   %ebx
  8016fb:	e8 9a ff ff ff       	call   80169a <strlen>
  801700:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801703:	ff 75 0c             	pushl  0xc(%ebp)
  801706:	01 d8                	add    %ebx,%eax
  801708:	50                   	push   %eax
  801709:	e8 c5 ff ff ff       	call   8016d3 <strcpy>
	return dst;
}
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801713:	c9                   	leave  
  801714:	c3                   	ret    

00801715 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	8b 75 08             	mov    0x8(%ebp),%esi
  80171d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801720:	89 f3                	mov    %esi,%ebx
  801722:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801725:	89 f2                	mov    %esi,%edx
  801727:	eb 0f                	jmp    801738 <strncpy+0x23>
		*dst++ = *src;
  801729:	83 c2 01             	add    $0x1,%edx
  80172c:	0f b6 01             	movzbl (%ecx),%eax
  80172f:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801732:	80 39 01             	cmpb   $0x1,(%ecx)
  801735:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801738:	39 da                	cmp    %ebx,%edx
  80173a:	75 ed                	jne    801729 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80173c:	89 f0                	mov    %esi,%eax
  80173e:	5b                   	pop    %ebx
  80173f:	5e                   	pop    %esi
  801740:	5d                   	pop    %ebp
  801741:	c3                   	ret    

00801742 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	56                   	push   %esi
  801746:	53                   	push   %ebx
  801747:	8b 75 08             	mov    0x8(%ebp),%esi
  80174a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174d:	8b 55 10             	mov    0x10(%ebp),%edx
  801750:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801752:	85 d2                	test   %edx,%edx
  801754:	74 21                	je     801777 <strlcpy+0x35>
  801756:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175a:	89 f2                	mov    %esi,%edx
  80175c:	eb 09                	jmp    801767 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80175e:	83 c2 01             	add    $0x1,%edx
  801761:	83 c1 01             	add    $0x1,%ecx
  801764:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801767:	39 c2                	cmp    %eax,%edx
  801769:	74 09                	je     801774 <strlcpy+0x32>
  80176b:	0f b6 19             	movzbl (%ecx),%ebx
  80176e:	84 db                	test   %bl,%bl
  801770:	75 ec                	jne    80175e <strlcpy+0x1c>
  801772:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801774:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801777:	29 f0                	sub    %esi,%eax
}
  801779:	5b                   	pop    %ebx
  80177a:	5e                   	pop    %esi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
  801780:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801783:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801786:	eb 06                	jmp    80178e <strcmp+0x11>
		p++, q++;
  801788:	83 c1 01             	add    $0x1,%ecx
  80178b:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80178e:	0f b6 01             	movzbl (%ecx),%eax
  801791:	84 c0                	test   %al,%al
  801793:	74 04                	je     801799 <strcmp+0x1c>
  801795:	3a 02                	cmp    (%edx),%al
  801797:	74 ef                	je     801788 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801799:	0f b6 c0             	movzbl %al,%eax
  80179c:	0f b6 12             	movzbl (%edx),%edx
  80179f:	29 d0                	sub    %edx,%eax
}
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    

008017a3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a3:	55                   	push   %ebp
  8017a4:	89 e5                	mov    %esp,%ebp
  8017a6:	53                   	push   %ebx
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ad:	89 c3                	mov    %eax,%ebx
  8017af:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b2:	eb 06                	jmp    8017ba <strncmp+0x17>
		n--, p++, q++;
  8017b4:	83 c0 01             	add    $0x1,%eax
  8017b7:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017ba:	39 d8                	cmp    %ebx,%eax
  8017bc:	74 15                	je     8017d3 <strncmp+0x30>
  8017be:	0f b6 08             	movzbl (%eax),%ecx
  8017c1:	84 c9                	test   %cl,%cl
  8017c3:	74 04                	je     8017c9 <strncmp+0x26>
  8017c5:	3a 0a                	cmp    (%edx),%cl
  8017c7:	74 eb                	je     8017b4 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c9:	0f b6 00             	movzbl (%eax),%eax
  8017cc:	0f b6 12             	movzbl (%edx),%edx
  8017cf:	29 d0                	sub    %edx,%eax
  8017d1:	eb 05                	jmp    8017d8 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017d3:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017d8:	5b                   	pop    %ebx
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017db:	55                   	push   %ebp
  8017dc:	89 e5                	mov    %esp,%ebp
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e5:	eb 07                	jmp    8017ee <strchr+0x13>
		if (*s == c)
  8017e7:	38 ca                	cmp    %cl,%dl
  8017e9:	74 0f                	je     8017fa <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017eb:	83 c0 01             	add    $0x1,%eax
  8017ee:	0f b6 10             	movzbl (%eax),%edx
  8017f1:	84 d2                	test   %dl,%dl
  8017f3:	75 f2                	jne    8017e7 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fa:	5d                   	pop    %ebp
  8017fb:	c3                   	ret    

008017fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801806:	eb 03                	jmp    80180b <strfind+0xf>
  801808:	83 c0 01             	add    $0x1,%eax
  80180b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80180e:	84 d2                	test   %dl,%dl
  801810:	74 04                	je     801816 <strfind+0x1a>
  801812:	38 ca                	cmp    %cl,%dl
  801814:	75 f2                	jne    801808 <strfind+0xc>
			break;
	return (char *) s;
}
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	57                   	push   %edi
  80181c:	56                   	push   %esi
  80181d:	53                   	push   %ebx
  80181e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801821:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  801824:	85 c9                	test   %ecx,%ecx
  801826:	74 36                	je     80185e <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801828:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80182e:	75 28                	jne    801858 <memset+0x40>
  801830:	f6 c1 03             	test   $0x3,%cl
  801833:	75 23                	jne    801858 <memset+0x40>
		c &= 0xFF;
  801835:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801839:	89 d3                	mov    %edx,%ebx
  80183b:	c1 e3 08             	shl    $0x8,%ebx
  80183e:	89 d6                	mov    %edx,%esi
  801840:	c1 e6 18             	shl    $0x18,%esi
  801843:	89 d0                	mov    %edx,%eax
  801845:	c1 e0 10             	shl    $0x10,%eax
  801848:	09 f0                	or     %esi,%eax
  80184a:	09 c2                	or     %eax,%edx
  80184c:	89 d0                	mov    %edx,%eax
  80184e:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801850:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801853:	fc                   	cld    
  801854:	f3 ab                	rep stos %eax,%es:(%edi)
  801856:	eb 06                	jmp    80185e <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801858:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185b:	fc                   	cld    
  80185c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80185e:	89 f8                	mov    %edi,%eax
  801860:	5b                   	pop    %ebx
  801861:	5e                   	pop    %esi
  801862:	5f                   	pop    %edi
  801863:	5d                   	pop    %ebp
  801864:	c3                   	ret    

00801865 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	57                   	push   %edi
  801869:	56                   	push   %esi
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801870:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801873:	39 c6                	cmp    %eax,%esi
  801875:	73 35                	jae    8018ac <memmove+0x47>
  801877:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187a:	39 d0                	cmp    %edx,%eax
  80187c:	73 2e                	jae    8018ac <memmove+0x47>
		s += n;
		d += n;
  80187e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801881:	89 d6                	mov    %edx,%esi
  801883:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801885:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80188b:	75 13                	jne    8018a0 <memmove+0x3b>
  80188d:	f6 c1 03             	test   $0x3,%cl
  801890:	75 0e                	jne    8018a0 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801892:	83 ef 04             	sub    $0x4,%edi
  801895:	8d 72 fc             	lea    -0x4(%edx),%esi
  801898:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80189b:	fd                   	std    
  80189c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189e:	eb 09                	jmp    8018a9 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018a0:	83 ef 01             	sub    $0x1,%edi
  8018a3:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a6:	fd                   	std    
  8018a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018a9:	fc                   	cld    
  8018aa:	eb 1d                	jmp    8018c9 <memmove+0x64>
  8018ac:	89 f2                	mov    %esi,%edx
  8018ae:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b0:	f6 c2 03             	test   $0x3,%dl
  8018b3:	75 0f                	jne    8018c4 <memmove+0x5f>
  8018b5:	f6 c1 03             	test   $0x3,%cl
  8018b8:	75 0a                	jne    8018c4 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018ba:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8018bd:	89 c7                	mov    %eax,%edi
  8018bf:	fc                   	cld    
  8018c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c2:	eb 05                	jmp    8018c9 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c4:	89 c7                	mov    %eax,%edi
  8018c6:	fc                   	cld    
  8018c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018c9:	5e                   	pop    %esi
  8018ca:	5f                   	pop    %edi
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    

008018cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d0:	ff 75 10             	pushl  0x10(%ebp)
  8018d3:	ff 75 0c             	pushl  0xc(%ebp)
  8018d6:	ff 75 08             	pushl  0x8(%ebp)
  8018d9:	e8 87 ff ff ff       	call   801865 <memmove>
}
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018eb:	89 c6                	mov    %eax,%esi
  8018ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f0:	eb 1a                	jmp    80190c <memcmp+0x2c>
		if (*s1 != *s2)
  8018f2:	0f b6 08             	movzbl (%eax),%ecx
  8018f5:	0f b6 1a             	movzbl (%edx),%ebx
  8018f8:	38 d9                	cmp    %bl,%cl
  8018fa:	74 0a                	je     801906 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018fc:	0f b6 c1             	movzbl %cl,%eax
  8018ff:	0f b6 db             	movzbl %bl,%ebx
  801902:	29 d8                	sub    %ebx,%eax
  801904:	eb 0f                	jmp    801915 <memcmp+0x35>
		s1++, s2++;
  801906:	83 c0 01             	add    $0x1,%eax
  801909:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190c:	39 f0                	cmp    %esi,%eax
  80190e:	75 e2                	jne    8018f2 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801915:	5b                   	pop    %ebx
  801916:	5e                   	pop    %esi
  801917:	5d                   	pop    %ebp
  801918:	c3                   	ret    

00801919 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801919:	55                   	push   %ebp
  80191a:	89 e5                	mov    %esp,%ebp
  80191c:	8b 45 08             	mov    0x8(%ebp),%eax
  80191f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801922:	89 c2                	mov    %eax,%edx
  801924:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801927:	eb 07                	jmp    801930 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801929:	38 08                	cmp    %cl,(%eax)
  80192b:	74 07                	je     801934 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192d:	83 c0 01             	add    $0x1,%eax
  801930:	39 d0                	cmp    %edx,%eax
  801932:	72 f5                	jb     801929 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801934:	5d                   	pop    %ebp
  801935:	c3                   	ret    

00801936 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801936:	55                   	push   %ebp
  801937:	89 e5                	mov    %esp,%ebp
  801939:	57                   	push   %edi
  80193a:	56                   	push   %esi
  80193b:	53                   	push   %ebx
  80193c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801942:	eb 03                	jmp    801947 <strtol+0x11>
		s++;
  801944:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801947:	0f b6 01             	movzbl (%ecx),%eax
  80194a:	3c 09                	cmp    $0x9,%al
  80194c:	74 f6                	je     801944 <strtol+0xe>
  80194e:	3c 20                	cmp    $0x20,%al
  801950:	74 f2                	je     801944 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801952:	3c 2b                	cmp    $0x2b,%al
  801954:	75 0a                	jne    801960 <strtol+0x2a>
		s++;
  801956:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801959:	bf 00 00 00 00       	mov    $0x0,%edi
  80195e:	eb 10                	jmp    801970 <strtol+0x3a>
  801960:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801965:	3c 2d                	cmp    $0x2d,%al
  801967:	75 07                	jne    801970 <strtol+0x3a>
		s++, neg = 1;
  801969:	8d 49 01             	lea    0x1(%ecx),%ecx
  80196c:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801970:	85 db                	test   %ebx,%ebx
  801972:	0f 94 c0             	sete   %al
  801975:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80197b:	75 19                	jne    801996 <strtol+0x60>
  80197d:	80 39 30             	cmpb   $0x30,(%ecx)
  801980:	75 14                	jne    801996 <strtol+0x60>
  801982:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801986:	0f 85 8a 00 00 00    	jne    801a16 <strtol+0xe0>
		s += 2, base = 16;
  80198c:	83 c1 02             	add    $0x2,%ecx
  80198f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801994:	eb 16                	jmp    8019ac <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801996:	84 c0                	test   %al,%al
  801998:	74 12                	je     8019ac <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80199f:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a2:	75 08                	jne    8019ac <strtol+0x76>
		s++, base = 8;
  8019a4:	83 c1 01             	add    $0x1,%ecx
  8019a7:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b4:	0f b6 11             	movzbl (%ecx),%edx
  8019b7:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019ba:	89 f3                	mov    %esi,%ebx
  8019bc:	80 fb 09             	cmp    $0x9,%bl
  8019bf:	77 08                	ja     8019c9 <strtol+0x93>
			dig = *s - '0';
  8019c1:	0f be d2             	movsbl %dl,%edx
  8019c4:	83 ea 30             	sub    $0x30,%edx
  8019c7:	eb 22                	jmp    8019eb <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019c9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019cc:	89 f3                	mov    %esi,%ebx
  8019ce:	80 fb 19             	cmp    $0x19,%bl
  8019d1:	77 08                	ja     8019db <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019d3:	0f be d2             	movsbl %dl,%edx
  8019d6:	83 ea 57             	sub    $0x57,%edx
  8019d9:	eb 10                	jmp    8019eb <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019db:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019de:	89 f3                	mov    %esi,%ebx
  8019e0:	80 fb 19             	cmp    $0x19,%bl
  8019e3:	77 16                	ja     8019fb <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019e5:	0f be d2             	movsbl %dl,%edx
  8019e8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019eb:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ee:	7d 0f                	jge    8019ff <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019f0:	83 c1 01             	add    $0x1,%ecx
  8019f3:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019f9:	eb b9                	jmp    8019b4 <strtol+0x7e>
  8019fb:	89 c2                	mov    %eax,%edx
  8019fd:	eb 02                	jmp    801a01 <strtol+0xcb>
  8019ff:	89 c2                	mov    %eax,%edx

	if (endptr)
  801a01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a05:	74 05                	je     801a0c <strtol+0xd6>
		*endptr = (char *) s;
  801a07:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a0c:	85 ff                	test   %edi,%edi
  801a0e:	74 0c                	je     801a1c <strtol+0xe6>
  801a10:	89 d0                	mov    %edx,%eax
  801a12:	f7 d8                	neg    %eax
  801a14:	eb 06                	jmp    801a1c <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a16:	84 c0                	test   %al,%al
  801a18:	75 8a                	jne    8019a4 <strtol+0x6e>
  801a1a:	eb 90                	jmp    8019ac <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5f                   	pop    %edi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	8b 75 08             	mov    0x8(%ebp),%esi
  801a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a2f:	85 f6                	test   %esi,%esi
  801a31:	74 06                	je     801a39 <ipc_recv+0x18>
  801a33:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a39:	85 db                	test   %ebx,%ebx
  801a3b:	74 06                	je     801a43 <ipc_recv+0x22>
  801a3d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a43:	83 f8 01             	cmp    $0x1,%eax
  801a46:	19 d2                	sbb    %edx,%edx
  801a48:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	50                   	push   %eax
  801a4e:	e8 de e8 ff ff       	call   800331 <sys_ipc_recv>
  801a53:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a55:	83 c4 10             	add    $0x10,%esp
  801a58:	85 d2                	test   %edx,%edx
  801a5a:	75 24                	jne    801a80 <ipc_recv+0x5f>
	if (from_env_store)
  801a5c:	85 f6                	test   %esi,%esi
  801a5e:	74 0a                	je     801a6a <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a60:	a1 04 40 80 00       	mov    0x804004,%eax
  801a65:	8b 40 70             	mov    0x70(%eax),%eax
  801a68:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	74 0a                	je     801a78 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a6e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a73:	8b 40 74             	mov    0x74(%eax),%eax
  801a76:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a78:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7d:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a80:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a83:	5b                   	pop    %ebx
  801a84:	5e                   	pop    %esi
  801a85:	5d                   	pop    %ebp
  801a86:	c3                   	ret    

00801a87 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	57                   	push   %edi
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a93:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a96:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a99:	83 fb 01             	cmp    $0x1,%ebx
  801a9c:	19 c0                	sbb    %eax,%eax
  801a9e:	09 c3                	or     %eax,%ebx
  801aa0:	eb 1c                	jmp    801abe <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801aa2:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa5:	74 12                	je     801ab9 <ipc_send+0x32>
  801aa7:	50                   	push   %eax
  801aa8:	68 a0 22 80 00       	push   $0x8022a0
  801aad:	6a 36                	push   $0x36
  801aaf:	68 b7 22 80 00       	push   $0x8022b7
  801ab4:	e8 bd f5 ff ff       	call   801076 <_panic>
		sys_yield();
  801ab9:	e8 a4 e6 ff ff       	call   800162 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801abe:	ff 75 14             	pushl  0x14(%ebp)
  801ac1:	53                   	push   %ebx
  801ac2:	56                   	push   %esi
  801ac3:	57                   	push   %edi
  801ac4:	e8 45 e8 ff ff       	call   80030e <sys_ipc_try_send>
		if (ret == 0) break;
  801ac9:	83 c4 10             	add    $0x10,%esp
  801acc:	85 c0                	test   %eax,%eax
  801ace:	75 d2                	jne    801aa2 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801ad0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad3:	5b                   	pop    %ebx
  801ad4:	5e                   	pop    %esi
  801ad5:	5f                   	pop    %edi
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ade:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ae3:	6b d0 78             	imul   $0x78,%eax,%edx
  801ae6:	83 c2 50             	add    $0x50,%edx
  801ae9:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801aef:	39 ca                	cmp    %ecx,%edx
  801af1:	75 0d                	jne    801b00 <ipc_find_env+0x28>
			return envs[i].env_id;
  801af3:	6b c0 78             	imul   $0x78,%eax,%eax
  801af6:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801afb:	8b 40 08             	mov    0x8(%eax),%eax
  801afe:	eb 0e                	jmp    801b0e <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b00:	83 c0 01             	add    $0x1,%eax
  801b03:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b08:	75 d9                	jne    801ae3 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b0a:	66 b8 00 00          	mov    $0x0,%ax
}
  801b0e:	5d                   	pop    %ebp
  801b0f:	c3                   	ret    

00801b10 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b16:	89 d0                	mov    %edx,%eax
  801b18:	c1 e8 16             	shr    $0x16,%eax
  801b1b:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b27:	f6 c1 01             	test   $0x1,%cl
  801b2a:	74 1d                	je     801b49 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b2c:	c1 ea 0c             	shr    $0xc,%edx
  801b2f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b36:	f6 c2 01             	test   $0x1,%dl
  801b39:	74 0e                	je     801b49 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b3b:	c1 ea 0c             	shr    $0xc,%edx
  801b3e:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b45:	ef 
  801b46:	0f b7 c0             	movzwl %ax,%eax
}
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    
  801b4b:	66 90                	xchg   %ax,%ax
  801b4d:	66 90                	xchg   %ax,%ax
  801b4f:	90                   	nop

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	83 ec 10             	sub    $0x10,%esp
  801b56:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801b5a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801b5e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801b62:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801b66:	85 d2                	test   %edx,%edx
  801b68:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801b6c:	89 34 24             	mov    %esi,(%esp)
  801b6f:	89 c8                	mov    %ecx,%eax
  801b71:	75 35                	jne    801ba8 <__udivdi3+0x58>
  801b73:	39 f1                	cmp    %esi,%ecx
  801b75:	0f 87 bd 00 00 00    	ja     801c38 <__udivdi3+0xe8>
  801b7b:	85 c9                	test   %ecx,%ecx
  801b7d:	89 cd                	mov    %ecx,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f1                	div    %ecx
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 f0                	mov    %esi,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c6                	mov    %eax,%esi
  801b94:	89 f8                	mov    %edi,%eax
  801b96:	f7 f5                	div    %ebp
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	83 c4 10             	add    $0x10,%esp
  801b9d:	5e                   	pop    %esi
  801b9e:	5f                   	pop    %edi
  801b9f:	5d                   	pop    %ebp
  801ba0:	c3                   	ret    
  801ba1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba8:	3b 14 24             	cmp    (%esp),%edx
  801bab:	77 7b                	ja     801c28 <__udivdi3+0xd8>
  801bad:	0f bd f2             	bsr    %edx,%esi
  801bb0:	83 f6 1f             	xor    $0x1f,%esi
  801bb3:	0f 84 97 00 00 00    	je     801c50 <__udivdi3+0x100>
  801bb9:	bd 20 00 00 00       	mov    $0x20,%ebp
  801bbe:	89 d7                	mov    %edx,%edi
  801bc0:	89 f1                	mov    %esi,%ecx
  801bc2:	29 f5                	sub    %esi,%ebp
  801bc4:	d3 e7                	shl    %cl,%edi
  801bc6:	89 c2                	mov    %eax,%edx
  801bc8:	89 e9                	mov    %ebp,%ecx
  801bca:	d3 ea                	shr    %cl,%edx
  801bcc:	89 f1                	mov    %esi,%ecx
  801bce:	09 fa                	or     %edi,%edx
  801bd0:	8b 3c 24             	mov    (%esp),%edi
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bd9:	89 e9                	mov    %ebp,%ecx
  801bdb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801be3:	89 fa                	mov    %edi,%edx
  801be5:	d3 ea                	shr    %cl,%edx
  801be7:	89 f1                	mov    %esi,%ecx
  801be9:	d3 e7                	shl    %cl,%edi
  801beb:	89 e9                	mov    %ebp,%ecx
  801bed:	d3 e8                	shr    %cl,%eax
  801bef:	09 c7                	or     %eax,%edi
  801bf1:	89 f8                	mov    %edi,%eax
  801bf3:	f7 74 24 08          	divl   0x8(%esp)
  801bf7:	89 d5                	mov    %edx,%ebp
  801bf9:	89 c7                	mov    %eax,%edi
  801bfb:	f7 64 24 0c          	mull   0xc(%esp)
  801bff:	39 d5                	cmp    %edx,%ebp
  801c01:	89 14 24             	mov    %edx,(%esp)
  801c04:	72 11                	jb     801c17 <__udivdi3+0xc7>
  801c06:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c0a:	89 f1                	mov    %esi,%ecx
  801c0c:	d3 e2                	shl    %cl,%edx
  801c0e:	39 c2                	cmp    %eax,%edx
  801c10:	73 5e                	jae    801c70 <__udivdi3+0x120>
  801c12:	3b 2c 24             	cmp    (%esp),%ebp
  801c15:	75 59                	jne    801c70 <__udivdi3+0x120>
  801c17:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c1a:	31 f6                	xor    %esi,%esi
  801c1c:	89 f2                	mov    %esi,%edx
  801c1e:	83 c4 10             	add    $0x10,%esp
  801c21:	5e                   	pop    %esi
  801c22:	5f                   	pop    %edi
  801c23:	5d                   	pop    %ebp
  801c24:	c3                   	ret    
  801c25:	8d 76 00             	lea    0x0(%esi),%esi
  801c28:	31 f6                	xor    %esi,%esi
  801c2a:	31 c0                	xor    %eax,%eax
  801c2c:	89 f2                	mov    %esi,%edx
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	5e                   	pop    %esi
  801c32:	5f                   	pop    %edi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
  801c35:	8d 76 00             	lea    0x0(%esi),%esi
  801c38:	89 f2                	mov    %esi,%edx
  801c3a:	31 f6                	xor    %esi,%esi
  801c3c:	89 f8                	mov    %edi,%eax
  801c3e:	f7 f1                	div    %ecx
  801c40:	89 f2                	mov    %esi,%edx
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	5e                   	pop    %esi
  801c46:	5f                   	pop    %edi
  801c47:	5d                   	pop    %ebp
  801c48:	c3                   	ret    
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801c54:	76 0b                	jbe    801c61 <__udivdi3+0x111>
  801c56:	31 c0                	xor    %eax,%eax
  801c58:	3b 14 24             	cmp    (%esp),%edx
  801c5b:	0f 83 37 ff ff ff    	jae    801b98 <__udivdi3+0x48>
  801c61:	b8 01 00 00 00       	mov    $0x1,%eax
  801c66:	e9 2d ff ff ff       	jmp    801b98 <__udivdi3+0x48>
  801c6b:	90                   	nop
  801c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 f8                	mov    %edi,%eax
  801c72:	31 f6                	xor    %esi,%esi
  801c74:	e9 1f ff ff ff       	jmp    801b98 <__udivdi3+0x48>
  801c79:	66 90                	xchg   %ax,%ax
  801c7b:	66 90                	xchg   %ax,%ax
  801c7d:	66 90                	xchg   %ax,%ax
  801c7f:	90                   	nop

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	83 ec 20             	sub    $0x20,%esp
  801c86:	8b 44 24 34          	mov    0x34(%esp),%eax
  801c8a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c92:	89 c6                	mov    %eax,%esi
  801c94:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c98:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c9c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801ca0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801ca4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801ca8:	89 74 24 18          	mov    %esi,0x18(%esp)
  801cac:	85 c0                	test   %eax,%eax
  801cae:	89 c2                	mov    %eax,%edx
  801cb0:	75 1e                	jne    801cd0 <__umoddi3+0x50>
  801cb2:	39 f7                	cmp    %esi,%edi
  801cb4:	76 52                	jbe    801d08 <__umoddi3+0x88>
  801cb6:	89 c8                	mov    %ecx,%eax
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	f7 f7                	div    %edi
  801cbc:	89 d0                	mov    %edx,%eax
  801cbe:	31 d2                	xor    %edx,%edx
  801cc0:	83 c4 20             	add    $0x20,%esp
  801cc3:	5e                   	pop    %esi
  801cc4:	5f                   	pop    %edi
  801cc5:	5d                   	pop    %ebp
  801cc6:	c3                   	ret    
  801cc7:	89 f6                	mov    %esi,%esi
  801cc9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801cd0:	39 f0                	cmp    %esi,%eax
  801cd2:	77 5c                	ja     801d30 <__umoddi3+0xb0>
  801cd4:	0f bd e8             	bsr    %eax,%ebp
  801cd7:	83 f5 1f             	xor    $0x1f,%ebp
  801cda:	75 64                	jne    801d40 <__umoddi3+0xc0>
  801cdc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801ce0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801ce4:	0f 86 f6 00 00 00    	jbe    801de0 <__umoddi3+0x160>
  801cea:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801cee:	0f 82 ec 00 00 00    	jb     801de0 <__umoddi3+0x160>
  801cf4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801cf8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801cfc:	83 c4 20             	add    $0x20,%esp
  801cff:	5e                   	pop    %esi
  801d00:	5f                   	pop    %edi
  801d01:	5d                   	pop    %ebp
  801d02:	c3                   	ret    
  801d03:	90                   	nop
  801d04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d08:	85 ff                	test   %edi,%edi
  801d0a:	89 fd                	mov    %edi,%ebp
  801d0c:	75 0b                	jne    801d19 <__umoddi3+0x99>
  801d0e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f7                	div    %edi
  801d17:	89 c5                	mov    %eax,%ebp
  801d19:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	f7 f5                	div    %ebp
  801d21:	89 c8                	mov    %ecx,%eax
  801d23:	f7 f5                	div    %ebp
  801d25:	eb 95                	jmp    801cbc <__umoddi3+0x3c>
  801d27:	89 f6                	mov    %esi,%esi
  801d29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 20             	add    $0x20,%esp
  801d37:	5e                   	pop    %esi
  801d38:	5f                   	pop    %edi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    
  801d3b:	90                   	nop
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	b8 20 00 00 00       	mov    $0x20,%eax
  801d45:	89 e9                	mov    %ebp,%ecx
  801d47:	29 e8                	sub    %ebp,%eax
  801d49:	d3 e2                	shl    %cl,%edx
  801d4b:	89 c7                	mov    %eax,%edi
  801d4d:	89 44 24 18          	mov    %eax,0x18(%esp)
  801d51:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d55:	89 f9                	mov    %edi,%ecx
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 c1                	mov    %eax,%ecx
  801d5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801d5f:	09 d1                	or     %edx,%ecx
  801d61:	89 fa                	mov    %edi,%edx
  801d63:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801d67:	89 e9                	mov    %ebp,%ecx
  801d69:	d3 e0                	shl    %cl,%eax
  801d6b:	89 f9                	mov    %edi,%ecx
  801d6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	d3 e8                	shr    %cl,%eax
  801d75:	89 e9                	mov    %ebp,%ecx
  801d77:	89 c7                	mov    %eax,%edi
  801d79:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801d7d:	d3 e6                	shl    %cl,%esi
  801d7f:	89 d1                	mov    %edx,%ecx
  801d81:	89 fa                	mov    %edi,%edx
  801d83:	d3 e8                	shr    %cl,%eax
  801d85:	89 e9                	mov    %ebp,%ecx
  801d87:	09 f0                	or     %esi,%eax
  801d89:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801d8d:	f7 74 24 10          	divl   0x10(%esp)
  801d91:	d3 e6                	shl    %cl,%esi
  801d93:	89 d1                	mov    %edx,%ecx
  801d95:	f7 64 24 0c          	mull   0xc(%esp)
  801d99:	39 d1                	cmp    %edx,%ecx
  801d9b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	89 c6                	mov    %eax,%esi
  801da3:	72 0a                	jb     801daf <__umoddi3+0x12f>
  801da5:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801da9:	73 10                	jae    801dbb <__umoddi3+0x13b>
  801dab:	39 d1                	cmp    %edx,%ecx
  801dad:	75 0c                	jne    801dbb <__umoddi3+0x13b>
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	89 c6                	mov    %eax,%esi
  801db3:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801db7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801dbb:	89 ca                	mov    %ecx,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	8b 44 24 14          	mov    0x14(%esp),%eax
  801dc3:	29 f0                	sub    %esi,%eax
  801dc5:	19 fa                	sbb    %edi,%edx
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801dce:	89 d7                	mov    %edx,%edi
  801dd0:	d3 e7                	shl    %cl,%edi
  801dd2:	89 e9                	mov    %ebp,%ecx
  801dd4:	09 f8                	or     %edi,%eax
  801dd6:	d3 ea                	shr    %cl,%edx
  801dd8:	83 c4 20             	add    $0x20,%esp
  801ddb:	5e                   	pop    %esi
  801ddc:	5f                   	pop    %edi
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    
  801ddf:	90                   	nop
  801de0:	8b 74 24 10          	mov    0x10(%esp),%esi
  801de4:	29 f9                	sub    %edi,%ecx
  801de6:	19 c6                	sbb    %eax,%esi
  801de8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801dec:	89 74 24 18          	mov    %esi,0x18(%esp)
  801df0:	e9 ff fe ff ff       	jmp    801cf4 <__umoddi3+0x74>
