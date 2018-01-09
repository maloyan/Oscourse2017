
obj/user/softint:     file format elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800045:	e8 ce 00 00 00       	call   800118 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 78             	imul   $0x78,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
  800076:	83 c4 10             	add    $0x10,%esp
#endif
}
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800086:	e8 a7 04 00 00       	call   800532 <close_all>
	sys_env_destroy(0);
  80008b:	83 ec 0c             	sub    $0xc,%esp
  80008e:	6a 00                	push   $0x0
  800090:	e8 42 00 00 00       	call   8000d7 <sys_env_destroy>
  800095:	83 c4 10             	add    $0x10,%esp
}
  800098:	c9                   	leave  
  800099:	c3                   	ret    

0080009a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	57                   	push   %edi
  80009e:	56                   	push   %esi
  80009f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	89 c3                	mov    %eax,%ebx
  8000ad:	89 c7                	mov    %eax,%edi
  8000af:	89 c6                	mov    %eax,%esi
  8000b1:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5f                   	pop    %edi
  8000b6:	5d                   	pop    %ebp
  8000b7:	c3                   	ret    

008000b8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	57                   	push   %edi
  8000bc:	56                   	push   %esi
  8000bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000be:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c8:	89 d1                	mov    %edx,%ecx
  8000ca:	89 d3                	mov    %edx,%ebx
  8000cc:	89 d7                	mov    %edx,%edi
  8000ce:	89 d6                	mov    %edx,%esi
  8000d0:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    

008000d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	57                   	push   %edi
  8000db:	56                   	push   %esi
  8000dc:	53                   	push   %ebx
  8000dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e5:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	89 cb                	mov    %ecx,%ebx
  8000ef:	89 cf                	mov    %ecx,%edi
  8000f1:	89 ce                	mov    %ecx,%esi
  8000f3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000f5:	85 c0                	test   %eax,%eax
  8000f7:	7e 17                	jle    800110 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 0a 1e 80 00       	push   $0x801e0a
  800104:	6a 23                	push   $0x23
  800106:	68 27 1e 80 00       	push   $0x801e27
  80010b:	e8 3b 0f 00 00       	call   80104b <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	57                   	push   %edi
  80011c:	56                   	push   %esi
  80011d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011e:	ba 00 00 00 00       	mov    $0x0,%edx
  800123:	b8 02 00 00 00       	mov    $0x2,%eax
  800128:	89 d1                	mov    %edx,%ecx
  80012a:	89 d3                	mov    %edx,%ebx
  80012c:	89 d7                	mov    %edx,%edi
  80012e:	89 d6                	mov    %edx,%esi
  800130:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800132:	5b                   	pop    %ebx
  800133:	5e                   	pop    %esi
  800134:	5f                   	pop    %edi
  800135:	5d                   	pop    %ebp
  800136:	c3                   	ret    

00800137 <sys_yield>:

void
sys_yield(void)
{
  800137:	55                   	push   %ebp
  800138:	89 e5                	mov    %esp,%ebp
  80013a:	57                   	push   %edi
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013d:	ba 00 00 00 00       	mov    $0x0,%edx
  800142:	b8 0b 00 00 00       	mov    $0xb,%eax
  800147:	89 d1                	mov    %edx,%ecx
  800149:	89 d3                	mov    %edx,%ebx
  80014b:	89 d7                	mov    %edx,%edi
  80014d:	89 d6                	mov    %edx,%esi
  80014f:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5f                   	pop    %edi
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	57                   	push   %edi
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
  80015c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80015f:	be 00 00 00 00       	mov    $0x0,%esi
  800164:	b8 04 00 00 00       	mov    $0x4,%eax
  800169:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800172:	89 f7                	mov    %esi,%edi
  800174:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800176:	85 c0                	test   %eax,%eax
  800178:	7e 17                	jle    800191 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 0a 1e 80 00       	push   $0x801e0a
  800185:	6a 23                	push   $0x23
  800187:	68 27 1e 80 00       	push   $0x801e27
  80018c:	e8 ba 0e 00 00       	call   80104b <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800194:	5b                   	pop    %ebx
  800195:	5e                   	pop    %esi
  800196:	5f                   	pop    %edi
  800197:	5d                   	pop    %ebp
  800198:	c3                   	ret    

00800199 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	57                   	push   %edi
  80019d:	56                   	push   %esi
  80019e:	53                   	push   %ebx
  80019f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001a2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001b8:	85 c0                	test   %eax,%eax
  8001ba:	7e 17                	jle    8001d3 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 0a 1e 80 00       	push   $0x801e0a
  8001c7:	6a 23                	push   $0x23
  8001c9:	68 27 1e 80 00       	push   $0x801e27
  8001ce:	e8 78 0e 00 00       	call   80104b <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d6:	5b                   	pop    %ebx
  8001d7:	5e                   	pop    %esi
  8001d8:	5f                   	pop    %edi
  8001d9:	5d                   	pop    %ebp
  8001da:	c3                   	ret    

008001db <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	57                   	push   %edi
  8001df:	56                   	push   %esi
  8001e0:	53                   	push   %ebx
  8001e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	89 df                	mov    %ebx,%edi
  8001f6:	89 de                	mov    %ebx,%esi
  8001f8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001fa:	85 c0                	test   %eax,%eax
  8001fc:	7e 17                	jle    800215 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 0a 1e 80 00       	push   $0x801e0a
  800209:	6a 23                	push   $0x23
  80020b:	68 27 1e 80 00       	push   $0x801e27
  800210:	e8 36 0e 00 00       	call   80104b <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800218:	5b                   	pop    %ebx
  800219:	5e                   	pop    %esi
  80021a:	5f                   	pop    %edi
  80021b:	5d                   	pop    %ebp
  80021c:	c3                   	ret    

0080021d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800226:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022b:	b8 08 00 00 00       	mov    $0x8,%eax
  800230:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	89 df                	mov    %ebx,%edi
  800238:	89 de                	mov    %ebx,%esi
  80023a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023c:	85 c0                	test   %eax,%eax
  80023e:	7e 17                	jle    800257 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 0a 1e 80 00       	push   $0x801e0a
  80024b:	6a 23                	push   $0x23
  80024d:	68 27 1e 80 00       	push   $0x801e27
  800252:	e8 f4 0d 00 00       	call   80104b <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	57                   	push   %edi
  800263:	56                   	push   %esi
  800264:	53                   	push   %ebx
  800265:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800268:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026d:	b8 09 00 00 00       	mov    $0x9,%eax
  800272:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	89 df                	mov    %ebx,%edi
  80027a:	89 de                	mov    %ebx,%esi
  80027c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80027e:	85 c0                	test   %eax,%eax
  800280:	7e 17                	jle    800299 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 0a 1e 80 00       	push   $0x801e0a
  80028d:	6a 23                	push   $0x23
  80028f:	68 27 1e 80 00       	push   $0x801e27
  800294:	e8 b2 0d 00 00       	call   80104b <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800299:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029c:	5b                   	pop    %ebx
  80029d:	5e                   	pop    %esi
  80029e:	5f                   	pop    %edi
  80029f:	5d                   	pop    %ebp
  8002a0:	c3                   	ret    

008002a1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a1:	55                   	push   %ebp
  8002a2:	89 e5                	mov    %esp,%ebp
  8002a4:	57                   	push   %edi
  8002a5:	56                   	push   %esi
  8002a6:	53                   	push   %ebx
  8002a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ba:	89 df                	mov    %ebx,%edi
  8002bc:	89 de                	mov    %ebx,%esi
  8002be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c0:	85 c0                	test   %eax,%eax
  8002c2:	7e 17                	jle    8002db <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c4:	83 ec 0c             	sub    $0xc,%esp
  8002c7:	50                   	push   %eax
  8002c8:	6a 0a                	push   $0xa
  8002ca:	68 0a 1e 80 00       	push   $0x801e0a
  8002cf:	6a 23                	push   $0x23
  8002d1:	68 27 1e 80 00       	push   $0x801e27
  8002d6:	e8 70 0d 00 00       	call   80104b <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002de:	5b                   	pop    %ebx
  8002df:	5e                   	pop    %esi
  8002e0:	5f                   	pop    %edi
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	57                   	push   %edi
  8002e7:	56                   	push   %esi
  8002e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e9:	be 00 00 00 00       	mov    $0x0,%esi
  8002ee:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ff:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800301:	5b                   	pop    %ebx
  800302:	5e                   	pop    %esi
  800303:	5f                   	pop    %edi
  800304:	5d                   	pop    %ebp
  800305:	c3                   	ret    

00800306 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	57                   	push   %edi
  80030a:	56                   	push   %esi
  80030b:	53                   	push   %ebx
  80030c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80030f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800314:	b8 0d 00 00 00       	mov    $0xd,%eax
  800319:	8b 55 08             	mov    0x8(%ebp),%edx
  80031c:	89 cb                	mov    %ecx,%ebx
  80031e:	89 cf                	mov    %ecx,%edi
  800320:	89 ce                	mov    %ecx,%esi
  800322:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800324:	85 c0                	test   %eax,%eax
  800326:	7e 17                	jle    80033f <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800328:	83 ec 0c             	sub    $0xc,%esp
  80032b:	50                   	push   %eax
  80032c:	6a 0d                	push   $0xd
  80032e:	68 0a 1e 80 00       	push   $0x801e0a
  800333:	6a 23                	push   $0x23
  800335:	68 27 1e 80 00       	push   $0x801e27
  80033a:	e8 0c 0d 00 00       	call   80104b <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800342:	5b                   	pop    %ebx
  800343:	5e                   	pop    %esi
  800344:	5f                   	pop    %edi
  800345:	5d                   	pop    %ebp
  800346:	c3                   	ret    

00800347 <sys_gettime>:

int sys_gettime(void)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	57                   	push   %edi
  80034b:	56                   	push   %esi
  80034c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80034d:	ba 00 00 00 00       	mov    $0x0,%edx
  800352:	b8 0e 00 00 00       	mov    $0xe,%eax
  800357:	89 d1                	mov    %edx,%ecx
  800359:	89 d3                	mov    %edx,%ebx
  80035b:	89 d7                	mov    %edx,%edi
  80035d:	89 d6                	mov    %edx,%esi
  80035f:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800361:	5b                   	pop    %ebx
  800362:	5e                   	pop    %esi
  800363:	5f                   	pop    %edi
  800364:	5d                   	pop    %ebp
  800365:	c3                   	ret    

00800366 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800366:	55                   	push   %ebp
  800367:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	05 00 00 00 30       	add    $0x30000000,%eax
  800371:	c1 e8 0c             	shr    $0xc,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800379:	8b 45 08             	mov    0x8(%ebp),%eax
  80037c:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800381:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800386:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80038b:	5d                   	pop    %ebp
  80038c:	c3                   	ret    

0080038d <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800393:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800398:	89 c2                	mov    %eax,%edx
  80039a:	c1 ea 16             	shr    $0x16,%edx
  80039d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003a4:	f6 c2 01             	test   $0x1,%dl
  8003a7:	74 11                	je     8003ba <fd_alloc+0x2d>
  8003a9:	89 c2                	mov    %eax,%edx
  8003ab:	c1 ea 0c             	shr    $0xc,%edx
  8003ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b5:	f6 c2 01             	test   $0x1,%dl
  8003b8:	75 09                	jne    8003c3 <fd_alloc+0x36>
			*fd_store = fd;
  8003ba:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c1:	eb 17                	jmp    8003da <fd_alloc+0x4d>
  8003c3:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cd:	75 c9                	jne    800398 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003cf:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003d5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003da:	5d                   	pop    %ebp
  8003db:	c3                   	ret    

008003dc <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003e2:	83 f8 1f             	cmp    $0x1f,%eax
  8003e5:	77 36                	ja     80041d <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003e7:	c1 e0 0c             	shl    $0xc,%eax
  8003ea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003ef:	89 c2                	mov    %eax,%edx
  8003f1:	c1 ea 16             	shr    $0x16,%edx
  8003f4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003fb:	f6 c2 01             	test   $0x1,%dl
  8003fe:	74 24                	je     800424 <fd_lookup+0x48>
  800400:	89 c2                	mov    %eax,%edx
  800402:	c1 ea 0c             	shr    $0xc,%edx
  800405:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80040c:	f6 c2 01             	test   $0x1,%dl
  80040f:	74 1a                	je     80042b <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800411:	8b 55 0c             	mov    0xc(%ebp),%edx
  800414:	89 02                	mov    %eax,(%edx)
	return 0;
  800416:	b8 00 00 00 00       	mov    $0x0,%eax
  80041b:	eb 13                	jmp    800430 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80041d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800422:	eb 0c                	jmp    800430 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800424:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800429:	eb 05                	jmp    800430 <fd_lookup+0x54>
  80042b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800430:	5d                   	pop    %ebp
  800431:	c3                   	ret    

00800432 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 08             	sub    $0x8,%esp
  800438:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80043b:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800440:	eb 13                	jmp    800455 <dev_lookup+0x23>
  800442:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800445:	39 08                	cmp    %ecx,(%eax)
  800447:	75 0c                	jne    800455 <dev_lookup+0x23>
			*dev = devtab[i];
  800449:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80044c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
  800453:	eb 2e                	jmp    800483 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800455:	8b 02                	mov    (%edx),%eax
  800457:	85 c0                	test   %eax,%eax
  800459:	75 e7                	jne    800442 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045b:	a1 04 40 80 00       	mov    0x804004,%eax
  800460:	8b 40 48             	mov    0x48(%eax),%eax
  800463:	83 ec 04             	sub    $0x4,%esp
  800466:	51                   	push   %ecx
  800467:	50                   	push   %eax
  800468:	68 38 1e 80 00       	push   $0x801e38
  80046d:	e8 b2 0c 00 00       	call   801124 <cprintf>
	*dev = 0;
  800472:	8b 45 0c             	mov    0xc(%ebp),%eax
  800475:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80047b:	83 c4 10             	add    $0x10,%esp
  80047e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800483:	c9                   	leave  
  800484:	c3                   	ret    

00800485 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800485:	55                   	push   %ebp
  800486:	89 e5                	mov    %esp,%ebp
  800488:	56                   	push   %esi
  800489:	53                   	push   %ebx
  80048a:	83 ec 10             	sub    $0x10,%esp
  80048d:	8b 75 08             	mov    0x8(%ebp),%esi
  800490:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800496:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800497:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80049d:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a0:	50                   	push   %eax
  8004a1:	e8 36 ff ff ff       	call   8003dc <fd_lookup>
  8004a6:	83 c4 08             	add    $0x8,%esp
  8004a9:	85 c0                	test   %eax,%eax
  8004ab:	78 05                	js     8004b2 <fd_close+0x2d>
	    || fd != fd2)
  8004ad:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b0:	74 0b                	je     8004bd <fd_close+0x38>
		return (must_exist ? r : 0);
  8004b2:	80 fb 01             	cmp    $0x1,%bl
  8004b5:	19 d2                	sbb    %edx,%edx
  8004b7:	f7 d2                	not    %edx
  8004b9:	21 d0                	and    %edx,%eax
  8004bb:	eb 41                	jmp    8004fe <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	ff 36                	pushl  (%esi)
  8004c6:	e8 67 ff ff ff       	call   800432 <dev_lookup>
  8004cb:	89 c3                	mov    %eax,%ebx
  8004cd:	83 c4 10             	add    $0x10,%esp
  8004d0:	85 c0                	test   %eax,%eax
  8004d2:	78 1a                	js     8004ee <fd_close+0x69>
		if (dev->dev_close)
  8004d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004d7:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004da:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	74 0b                	je     8004ee <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8004e3:	83 ec 0c             	sub    $0xc,%esp
  8004e6:	56                   	push   %esi
  8004e7:	ff d0                	call   *%eax
  8004e9:	89 c3                	mov    %eax,%ebx
  8004eb:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004ee:	83 ec 08             	sub    $0x8,%esp
  8004f1:	56                   	push   %esi
  8004f2:	6a 00                	push   $0x0
  8004f4:	e8 e2 fc ff ff       	call   8001db <sys_page_unmap>
	return r;
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	89 d8                	mov    %ebx,%eax
}
  8004fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800501:	5b                   	pop    %ebx
  800502:	5e                   	pop    %esi
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    

00800505 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80050b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80050e:	50                   	push   %eax
  80050f:	ff 75 08             	pushl  0x8(%ebp)
  800512:	e8 c5 fe ff ff       	call   8003dc <fd_lookup>
  800517:	89 c2                	mov    %eax,%edx
  800519:	83 c4 08             	add    $0x8,%esp
  80051c:	85 d2                	test   %edx,%edx
  80051e:	78 10                	js     800530 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	6a 01                	push   $0x1
  800525:	ff 75 f4             	pushl  -0xc(%ebp)
  800528:	e8 58 ff ff ff       	call   800485 <fd_close>
  80052d:	83 c4 10             	add    $0x10,%esp
}
  800530:	c9                   	leave  
  800531:	c3                   	ret    

00800532 <close_all>:

void
close_all(void)
{
  800532:	55                   	push   %ebp
  800533:	89 e5                	mov    %esp,%ebp
  800535:	53                   	push   %ebx
  800536:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800539:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80053e:	83 ec 0c             	sub    $0xc,%esp
  800541:	53                   	push   %ebx
  800542:	e8 be ff ff ff       	call   800505 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800547:	83 c3 01             	add    $0x1,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	83 fb 20             	cmp    $0x20,%ebx
  800550:	75 ec                	jne    80053e <close_all+0xc>
		close(i);
}
  800552:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800555:	c9                   	leave  
  800556:	c3                   	ret    

00800557 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800557:	55                   	push   %ebp
  800558:	89 e5                	mov    %esp,%ebp
  80055a:	57                   	push   %edi
  80055b:	56                   	push   %esi
  80055c:	53                   	push   %ebx
  80055d:	83 ec 2c             	sub    $0x2c,%esp
  800560:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800563:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800566:	50                   	push   %eax
  800567:	ff 75 08             	pushl  0x8(%ebp)
  80056a:	e8 6d fe ff ff       	call   8003dc <fd_lookup>
  80056f:	89 c2                	mov    %eax,%edx
  800571:	83 c4 08             	add    $0x8,%esp
  800574:	85 d2                	test   %edx,%edx
  800576:	0f 88 c1 00 00 00    	js     80063d <dup+0xe6>
		return r;
	close(newfdnum);
  80057c:	83 ec 0c             	sub    $0xc,%esp
  80057f:	56                   	push   %esi
  800580:	e8 80 ff ff ff       	call   800505 <close>

	newfd = INDEX2FD(newfdnum);
  800585:	89 f3                	mov    %esi,%ebx
  800587:	c1 e3 0c             	shl    $0xc,%ebx
  80058a:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800590:	83 c4 04             	add    $0x4,%esp
  800593:	ff 75 e4             	pushl  -0x1c(%ebp)
  800596:	e8 db fd ff ff       	call   800376 <fd2data>
  80059b:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80059d:	89 1c 24             	mov    %ebx,(%esp)
  8005a0:	e8 d1 fd ff ff       	call   800376 <fd2data>
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ab:	89 f8                	mov    %edi,%eax
  8005ad:	c1 e8 16             	shr    $0x16,%eax
  8005b0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005b7:	a8 01                	test   $0x1,%al
  8005b9:	74 37                	je     8005f2 <dup+0x9b>
  8005bb:	89 f8                	mov    %edi,%eax
  8005bd:	c1 e8 0c             	shr    $0xc,%eax
  8005c0:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005c7:	f6 c2 01             	test   $0x1,%dl
  8005ca:	74 26                	je     8005f2 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d3:	83 ec 0c             	sub    $0xc,%esp
  8005d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005db:	50                   	push   %eax
  8005dc:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005df:	6a 00                	push   $0x0
  8005e1:	57                   	push   %edi
  8005e2:	6a 00                	push   $0x0
  8005e4:	e8 b0 fb ff ff       	call   800199 <sys_page_map>
  8005e9:	89 c7                	mov    %eax,%edi
  8005eb:	83 c4 20             	add    $0x20,%esp
  8005ee:	85 c0                	test   %eax,%eax
  8005f0:	78 2e                	js     800620 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005f2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005f5:	89 d0                	mov    %edx,%eax
  8005f7:	c1 e8 0c             	shr    $0xc,%eax
  8005fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800601:	83 ec 0c             	sub    $0xc,%esp
  800604:	25 07 0e 00 00       	and    $0xe07,%eax
  800609:	50                   	push   %eax
  80060a:	53                   	push   %ebx
  80060b:	6a 00                	push   $0x0
  80060d:	52                   	push   %edx
  80060e:	6a 00                	push   $0x0
  800610:	e8 84 fb ff ff       	call   800199 <sys_page_map>
  800615:	89 c7                	mov    %eax,%edi
  800617:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80061a:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061c:	85 ff                	test   %edi,%edi
  80061e:	79 1d                	jns    80063d <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	6a 00                	push   $0x0
  800626:	e8 b0 fb ff ff       	call   8001db <sys_page_unmap>
	sys_page_unmap(0, nva);
  80062b:	83 c4 08             	add    $0x8,%esp
  80062e:	ff 75 d4             	pushl  -0x2c(%ebp)
  800631:	6a 00                	push   $0x0
  800633:	e8 a3 fb ff ff       	call   8001db <sys_page_unmap>
	return r;
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	89 f8                	mov    %edi,%eax
}
  80063d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800640:	5b                   	pop    %ebx
  800641:	5e                   	pop    %esi
  800642:	5f                   	pop    %edi
  800643:	5d                   	pop    %ebp
  800644:	c3                   	ret    

00800645 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800645:	55                   	push   %ebp
  800646:	89 e5                	mov    %esp,%ebp
  800648:	53                   	push   %ebx
  800649:	83 ec 14             	sub    $0x14,%esp
  80064c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80064f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800652:	50                   	push   %eax
  800653:	53                   	push   %ebx
  800654:	e8 83 fd ff ff       	call   8003dc <fd_lookup>
  800659:	83 c4 08             	add    $0x8,%esp
  80065c:	89 c2                	mov    %eax,%edx
  80065e:	85 c0                	test   %eax,%eax
  800660:	78 6d                	js     8006cf <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800668:	50                   	push   %eax
  800669:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80066c:	ff 30                	pushl  (%eax)
  80066e:	e8 bf fd ff ff       	call   800432 <dev_lookup>
  800673:	83 c4 10             	add    $0x10,%esp
  800676:	85 c0                	test   %eax,%eax
  800678:	78 4c                	js     8006c6 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80067a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80067d:	8b 42 08             	mov    0x8(%edx),%eax
  800680:	83 e0 03             	and    $0x3,%eax
  800683:	83 f8 01             	cmp    $0x1,%eax
  800686:	75 21                	jne    8006a9 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800688:	a1 04 40 80 00       	mov    0x804004,%eax
  80068d:	8b 40 48             	mov    0x48(%eax),%eax
  800690:	83 ec 04             	sub    $0x4,%esp
  800693:	53                   	push   %ebx
  800694:	50                   	push   %eax
  800695:	68 79 1e 80 00       	push   $0x801e79
  80069a:	e8 85 0a 00 00       	call   801124 <cprintf>
		return -E_INVAL;
  80069f:	83 c4 10             	add    $0x10,%esp
  8006a2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006a7:	eb 26                	jmp    8006cf <read+0x8a>
	}
	if (!dev->dev_read)
  8006a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ac:	8b 40 08             	mov    0x8(%eax),%eax
  8006af:	85 c0                	test   %eax,%eax
  8006b1:	74 17                	je     8006ca <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006b3:	83 ec 04             	sub    $0x4,%esp
  8006b6:	ff 75 10             	pushl  0x10(%ebp)
  8006b9:	ff 75 0c             	pushl  0xc(%ebp)
  8006bc:	52                   	push   %edx
  8006bd:	ff d0                	call   *%eax
  8006bf:	89 c2                	mov    %eax,%edx
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	eb 09                	jmp    8006cf <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006c6:	89 c2                	mov    %eax,%edx
  8006c8:	eb 05                	jmp    8006cf <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ca:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006cf:	89 d0                	mov    %edx,%eax
  8006d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006d4:	c9                   	leave  
  8006d5:	c3                   	ret    

008006d6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	57                   	push   %edi
  8006da:	56                   	push   %esi
  8006db:	53                   	push   %ebx
  8006dc:	83 ec 0c             	sub    $0xc,%esp
  8006df:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ea:	eb 21                	jmp    80070d <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ec:	83 ec 04             	sub    $0x4,%esp
  8006ef:	89 f0                	mov    %esi,%eax
  8006f1:	29 d8                	sub    %ebx,%eax
  8006f3:	50                   	push   %eax
  8006f4:	89 d8                	mov    %ebx,%eax
  8006f6:	03 45 0c             	add    0xc(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	57                   	push   %edi
  8006fb:	e8 45 ff ff ff       	call   800645 <read>
		if (m < 0)
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 c0                	test   %eax,%eax
  800705:	78 0c                	js     800713 <readn+0x3d>
			return m;
		if (m == 0)
  800707:	85 c0                	test   %eax,%eax
  800709:	74 06                	je     800711 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070b:	01 c3                	add    %eax,%ebx
  80070d:	39 f3                	cmp    %esi,%ebx
  80070f:	72 db                	jb     8006ec <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800711:	89 d8                	mov    %ebx,%eax
}
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	53                   	push   %ebx
  80071f:	83 ec 14             	sub    $0x14,%esp
  800722:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800725:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	53                   	push   %ebx
  80072a:	e8 ad fc ff ff       	call   8003dc <fd_lookup>
  80072f:	83 c4 08             	add    $0x8,%esp
  800732:	89 c2                	mov    %eax,%edx
  800734:	85 c0                	test   %eax,%eax
  800736:	78 68                	js     8007a0 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	ff 30                	pushl  (%eax)
  800744:	e8 e9 fc ff ff       	call   800432 <dev_lookup>
  800749:	83 c4 10             	add    $0x10,%esp
  80074c:	85 c0                	test   %eax,%eax
  80074e:	78 47                	js     800797 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800750:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800753:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800757:	75 21                	jne    80077a <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800759:	a1 04 40 80 00       	mov    0x804004,%eax
  80075e:	8b 40 48             	mov    0x48(%eax),%eax
  800761:	83 ec 04             	sub    $0x4,%esp
  800764:	53                   	push   %ebx
  800765:	50                   	push   %eax
  800766:	68 95 1e 80 00       	push   $0x801e95
  80076b:	e8 b4 09 00 00       	call   801124 <cprintf>
		return -E_INVAL;
  800770:	83 c4 10             	add    $0x10,%esp
  800773:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800778:	eb 26                	jmp    8007a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80077a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80077d:	8b 52 0c             	mov    0xc(%edx),%edx
  800780:	85 d2                	test   %edx,%edx
  800782:	74 17                	je     80079b <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800784:	83 ec 04             	sub    $0x4,%esp
  800787:	ff 75 10             	pushl  0x10(%ebp)
  80078a:	ff 75 0c             	pushl  0xc(%ebp)
  80078d:	50                   	push   %eax
  80078e:	ff d2                	call   *%edx
  800790:	89 c2                	mov    %eax,%edx
  800792:	83 c4 10             	add    $0x10,%esp
  800795:	eb 09                	jmp    8007a0 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800797:	89 c2                	mov    %eax,%edx
  800799:	eb 05                	jmp    8007a0 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80079b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a0:	89 d0                	mov    %edx,%eax
  8007a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a5:	c9                   	leave  
  8007a6:	c3                   	ret    

008007a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007a7:	55                   	push   %ebp
  8007a8:	89 e5                	mov    %esp,%ebp
  8007aa:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ad:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b0:	50                   	push   %eax
  8007b1:	ff 75 08             	pushl  0x8(%ebp)
  8007b4:	e8 23 fc ff ff       	call   8003dc <fd_lookup>
  8007b9:	83 c4 08             	add    $0x8,%esp
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	78 0e                	js     8007ce <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007c6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ce:	c9                   	leave  
  8007cf:	c3                   	ret    

008007d0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	53                   	push   %ebx
  8007d4:	83 ec 14             	sub    $0x14,%esp
  8007d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007da:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	53                   	push   %ebx
  8007df:	e8 f8 fb ff ff       	call   8003dc <fd_lookup>
  8007e4:	83 c4 08             	add    $0x8,%esp
  8007e7:	89 c2                	mov    %eax,%edx
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 65                	js     800852 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f3:	50                   	push   %eax
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	ff 30                	pushl  (%eax)
  8007f9:	e8 34 fc ff ff       	call   800432 <dev_lookup>
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	78 44                	js     800849 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800805:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800808:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80080c:	75 21                	jne    80082f <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80080e:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800813:	8b 40 48             	mov    0x48(%eax),%eax
  800816:	83 ec 04             	sub    $0x4,%esp
  800819:	53                   	push   %ebx
  80081a:	50                   	push   %eax
  80081b:	68 58 1e 80 00       	push   $0x801e58
  800820:	e8 ff 08 00 00       	call   801124 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800825:	83 c4 10             	add    $0x10,%esp
  800828:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80082d:	eb 23                	jmp    800852 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80082f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800832:	8b 52 18             	mov    0x18(%edx),%edx
  800835:	85 d2                	test   %edx,%edx
  800837:	74 14                	je     80084d <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800839:	83 ec 08             	sub    $0x8,%esp
  80083c:	ff 75 0c             	pushl  0xc(%ebp)
  80083f:	50                   	push   %eax
  800840:	ff d2                	call   *%edx
  800842:	89 c2                	mov    %eax,%edx
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	eb 09                	jmp    800852 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800849:	89 c2                	mov    %eax,%edx
  80084b:	eb 05                	jmp    800852 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80084d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800852:	89 d0                	mov    %edx,%eax
  800854:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800857:	c9                   	leave  
  800858:	c3                   	ret    

00800859 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	83 ec 14             	sub    $0x14,%esp
  800860:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800863:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800866:	50                   	push   %eax
  800867:	ff 75 08             	pushl  0x8(%ebp)
  80086a:	e8 6d fb ff ff       	call   8003dc <fd_lookup>
  80086f:	83 c4 08             	add    $0x8,%esp
  800872:	89 c2                	mov    %eax,%edx
  800874:	85 c0                	test   %eax,%eax
  800876:	78 58                	js     8008d0 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800878:	83 ec 08             	sub    $0x8,%esp
  80087b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80087e:	50                   	push   %eax
  80087f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800882:	ff 30                	pushl  (%eax)
  800884:	e8 a9 fb ff ff       	call   800432 <dev_lookup>
  800889:	83 c4 10             	add    $0x10,%esp
  80088c:	85 c0                	test   %eax,%eax
  80088e:	78 37                	js     8008c7 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800897:	74 32                	je     8008cb <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800899:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a3:	00 00 00 
	stat->st_isdir = 0;
  8008a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ad:	00 00 00 
	stat->st_dev = dev;
  8008b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8008bd:	ff 50 14             	call   *0x14(%eax)
  8008c0:	89 c2                	mov    %eax,%edx
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	eb 09                	jmp    8008d0 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c7:	89 c2                	mov    %eax,%edx
  8008c9:	eb 05                	jmp    8008d0 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008cb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d0:	89 d0                	mov    %edx,%eax
  8008d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008d5:	c9                   	leave  
  8008d6:	c3                   	ret    

008008d7 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	56                   	push   %esi
  8008db:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	6a 00                	push   $0x0
  8008e1:	ff 75 08             	pushl  0x8(%ebp)
  8008e4:	e8 e7 01 00 00       	call   800ad0 <open>
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	85 db                	test   %ebx,%ebx
  8008f0:	78 1b                	js     80090d <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	ff 75 0c             	pushl  0xc(%ebp)
  8008f8:	53                   	push   %ebx
  8008f9:	e8 5b ff ff ff       	call   800859 <fstat>
  8008fe:	89 c6                	mov    %eax,%esi
	close(fd);
  800900:	89 1c 24             	mov    %ebx,(%esp)
  800903:	e8 fd fb ff ff       	call   800505 <close>
	return r;
  800908:	83 c4 10             	add    $0x10,%esp
  80090b:	89 f0                	mov    %esi,%eax
}
  80090d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	89 c6                	mov    %eax,%esi
  80091b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80091d:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800924:	75 12                	jne    800938 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	6a 03                	push   $0x3
  80092b:	e8 7d 11 00 00       	call   801aad <ipc_find_env>
  800930:	a3 00 40 80 00       	mov    %eax,0x804000
  800935:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800938:	6a 07                	push   $0x7
  80093a:	68 00 50 80 00       	push   $0x805000
  80093f:	56                   	push   %esi
  800940:	ff 35 00 40 80 00    	pushl  0x804000
  800946:	e8 11 11 00 00       	call   801a5c <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80094b:	83 c4 0c             	add    $0xc,%esp
  80094e:	6a 00                	push   $0x0
  800950:	53                   	push   %ebx
  800951:	6a 00                	push   $0x0
  800953:	e8 9e 10 00 00       	call   8019f6 <ipc_recv>
}
  800958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 40 0c             	mov    0xc(%eax),%eax
  80096b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800970:	8b 45 0c             	mov    0xc(%ebp),%eax
  800973:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	b8 02 00 00 00       	mov    $0x2,%eax
  800982:	e8 8d ff ff ff       	call   800914 <fsipc>
}
  800987:	c9                   	leave  
  800988:	c3                   	ret    

00800989 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
  800992:	8b 40 0c             	mov    0xc(%eax),%eax
  800995:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80099a:	ba 00 00 00 00       	mov    $0x0,%edx
  80099f:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a4:	e8 6b ff ff ff       	call   800914 <fsipc>
}
  8009a9:	c9                   	leave  
  8009aa:	c3                   	ret    

008009ab <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	53                   	push   %ebx
  8009af:	83 ec 04             	sub    $0x4,%esp
  8009b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bb:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ca:	e8 45 ff ff ff       	call   800914 <fsipc>
  8009cf:	89 c2                	mov    %eax,%edx
  8009d1:	85 d2                	test   %edx,%edx
  8009d3:	78 2c                	js     800a01 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009d5:	83 ec 08             	sub    $0x8,%esp
  8009d8:	68 00 50 80 00       	push   $0x805000
  8009dd:	53                   	push   %ebx
  8009de:	e8 c5 0c 00 00       	call   8016a8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009e3:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ee:	a1 84 50 80 00       	mov    0x805084,%eax
  8009f3:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f9:	83 c4 10             	add    $0x10,%esp
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a01:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    

00800a06 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 08             	sub    $0x8,%esp
  800a0c:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a12:	8b 52 0c             	mov    0xc(%edx),%edx
  800a15:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a1b:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a20:	76 05                	jbe    800a27 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a22:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a27:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a2c:	83 ec 04             	sub    $0x4,%esp
  800a2f:	50                   	push   %eax
  800a30:	ff 75 0c             	pushl  0xc(%ebp)
  800a33:	68 08 50 80 00       	push   $0x805008
  800a38:	e8 fd 0d 00 00       	call   80183a <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a42:	b8 04 00 00 00       	mov    $0x4,%eax
  800a47:	e8 c8 fe ff ff       	call   800914 <fsipc>
	return write;
}
  800a4c:	c9                   	leave  
  800a4d:	c3                   	ret    

00800a4e <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a4e:	55                   	push   %ebp
  800a4f:	89 e5                	mov    %esp,%ebp
  800a51:	56                   	push   %esi
  800a52:	53                   	push   %ebx
  800a53:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a56:	8b 45 08             	mov    0x8(%ebp),%eax
  800a59:	8b 40 0c             	mov    0xc(%eax),%eax
  800a5c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a61:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a71:	e8 9e fe ff ff       	call   800914 <fsipc>
  800a76:	89 c3                	mov    %eax,%ebx
  800a78:	85 c0                	test   %eax,%eax
  800a7a:	78 4b                	js     800ac7 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a7c:	39 c6                	cmp    %eax,%esi
  800a7e:	73 16                	jae    800a96 <devfile_read+0x48>
  800a80:	68 c4 1e 80 00       	push   $0x801ec4
  800a85:	68 cb 1e 80 00       	push   $0x801ecb
  800a8a:	6a 7c                	push   $0x7c
  800a8c:	68 e0 1e 80 00       	push   $0x801ee0
  800a91:	e8 b5 05 00 00       	call   80104b <_panic>
	assert(r <= PGSIZE);
  800a96:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9b:	7e 16                	jle    800ab3 <devfile_read+0x65>
  800a9d:	68 eb 1e 80 00       	push   $0x801eeb
  800aa2:	68 cb 1e 80 00       	push   $0x801ecb
  800aa7:	6a 7d                	push   $0x7d
  800aa9:	68 e0 1e 80 00       	push   $0x801ee0
  800aae:	e8 98 05 00 00       	call   80104b <_panic>
	memmove(buf, &fsipcbuf, r);
  800ab3:	83 ec 04             	sub    $0x4,%esp
  800ab6:	50                   	push   %eax
  800ab7:	68 00 50 80 00       	push   $0x805000
  800abc:	ff 75 0c             	pushl  0xc(%ebp)
  800abf:	e8 76 0d 00 00       	call   80183a <memmove>
	return r;
  800ac4:	83 c4 10             	add    $0x10,%esp
}
  800ac7:	89 d8                	mov    %ebx,%eax
  800ac9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800acc:	5b                   	pop    %ebx
  800acd:	5e                   	pop    %esi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	53                   	push   %ebx
  800ad4:	83 ec 20             	sub    $0x20,%esp
  800ad7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ada:	53                   	push   %ebx
  800adb:	e8 8f 0b 00 00       	call   80166f <strlen>
  800ae0:	83 c4 10             	add    $0x10,%esp
  800ae3:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae8:	7f 67                	jg     800b51 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aea:	83 ec 0c             	sub    $0xc,%esp
  800aed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af0:	50                   	push   %eax
  800af1:	e8 97 f8 ff ff       	call   80038d <fd_alloc>
  800af6:	83 c4 10             	add    $0x10,%esp
		return r;
  800af9:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afb:	85 c0                	test   %eax,%eax
  800afd:	78 57                	js     800b56 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aff:	83 ec 08             	sub    $0x8,%esp
  800b02:	53                   	push   %ebx
  800b03:	68 00 50 80 00       	push   $0x805000
  800b08:	e8 9b 0b 00 00       	call   8016a8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b10:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b18:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1d:	e8 f2 fd ff ff       	call   800914 <fsipc>
  800b22:	89 c3                	mov    %eax,%ebx
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	85 c0                	test   %eax,%eax
  800b29:	79 14                	jns    800b3f <open+0x6f>
		fd_close(fd, 0);
  800b2b:	83 ec 08             	sub    $0x8,%esp
  800b2e:	6a 00                	push   $0x0
  800b30:	ff 75 f4             	pushl  -0xc(%ebp)
  800b33:	e8 4d f9 ff ff       	call   800485 <fd_close>
		return r;
  800b38:	83 c4 10             	add    $0x10,%esp
  800b3b:	89 da                	mov    %ebx,%edx
  800b3d:	eb 17                	jmp    800b56 <open+0x86>
	}

	return fd2num(fd);
  800b3f:	83 ec 0c             	sub    $0xc,%esp
  800b42:	ff 75 f4             	pushl  -0xc(%ebp)
  800b45:	e8 1c f8 ff ff       	call   800366 <fd2num>
  800b4a:	89 c2                	mov    %eax,%edx
  800b4c:	83 c4 10             	add    $0x10,%esp
  800b4f:	eb 05                	jmp    800b56 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b51:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b56:	89 d0                	mov    %edx,%eax
  800b58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6d:	e8 a2 fd ff ff       	call   800914 <fsipc>
}
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
  800b79:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	ff 75 08             	pushl  0x8(%ebp)
  800b82:	e8 ef f7 ff ff       	call   800376 <fd2data>
  800b87:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b89:	83 c4 08             	add    $0x8,%esp
  800b8c:	68 f7 1e 80 00       	push   $0x801ef7
  800b91:	53                   	push   %ebx
  800b92:	e8 11 0b 00 00       	call   8016a8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b97:	8b 56 04             	mov    0x4(%esi),%edx
  800b9a:	89 d0                	mov    %edx,%eax
  800b9c:	2b 06                	sub    (%esi),%eax
  800b9e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bab:	00 00 00 
	stat->st_dev = &devpipe;
  800bae:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb5:	30 80 00 
	return 0;
}
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bce:	53                   	push   %ebx
  800bcf:	6a 00                	push   $0x0
  800bd1:	e8 05 f6 ff ff       	call   8001db <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd6:	89 1c 24             	mov    %ebx,(%esp)
  800bd9:	e8 98 f7 ff ff       	call   800376 <fd2data>
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 00                	push   $0x0
  800be4:	e8 f2 f5 ff ff       	call   8001db <sys_page_unmap>
}
  800be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 1c             	sub    $0x1c,%esp
  800bf7:	89 c7                	mov    %eax,%edi
  800bf9:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bfb:	a1 04 40 80 00       	mov    0x804004,%eax
  800c00:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c03:	83 ec 0c             	sub    $0xc,%esp
  800c06:	57                   	push   %edi
  800c07:	e8 d9 0e 00 00       	call   801ae5 <pageref>
  800c0c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c0f:	89 34 24             	mov    %esi,(%esp)
  800c12:	e8 ce 0e 00 00       	call   801ae5 <pageref>
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1d:	0f 94 c0             	sete   %al
  800c20:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c23:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c29:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c2c:	39 cb                	cmp    %ecx,%ebx
  800c2e:	74 15                	je     800c45 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c30:	8b 52 58             	mov    0x58(%edx),%edx
  800c33:	50                   	push   %eax
  800c34:	52                   	push   %edx
  800c35:	53                   	push   %ebx
  800c36:	68 04 1f 80 00       	push   $0x801f04
  800c3b:	e8 e4 04 00 00       	call   801124 <cprintf>
  800c40:	83 c4 10             	add    $0x10,%esp
  800c43:	eb b6                	jmp    800bfb <_pipeisclosed+0xd>
	}
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c4d:	55                   	push   %ebp
  800c4e:	89 e5                	mov    %esp,%ebp
  800c50:	57                   	push   %edi
  800c51:	56                   	push   %esi
  800c52:	53                   	push   %ebx
  800c53:	83 ec 28             	sub    $0x28,%esp
  800c56:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c59:	56                   	push   %esi
  800c5a:	e8 17 f7 ff ff       	call   800376 <fd2data>
  800c5f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c61:	83 c4 10             	add    $0x10,%esp
  800c64:	bf 00 00 00 00       	mov    $0x0,%edi
  800c69:	eb 4b                	jmp    800cb6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c6b:	89 da                	mov    %ebx,%edx
  800c6d:	89 f0                	mov    %esi,%eax
  800c6f:	e8 7a ff ff ff       	call   800bee <_pipeisclosed>
  800c74:	85 c0                	test   %eax,%eax
  800c76:	75 48                	jne    800cc0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c78:	e8 ba f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c80:	8b 0b                	mov    (%ebx),%ecx
  800c82:	8d 51 20             	lea    0x20(%ecx),%edx
  800c85:	39 d0                	cmp    %edx,%eax
  800c87:	73 e2                	jae    800c6b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c90:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c93:	89 c2                	mov    %eax,%edx
  800c95:	c1 fa 1f             	sar    $0x1f,%edx
  800c98:	89 d1                	mov    %edx,%ecx
  800c9a:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca0:	83 e2 1f             	and    $0x1f,%edx
  800ca3:	29 ca                	sub    %ecx,%edx
  800ca5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cad:	83 c0 01             	add    $0x1,%eax
  800cb0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cb3:	83 c7 01             	add    $0x1,%edi
  800cb6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cb9:	75 c2                	jne    800c7d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cbb:	8b 45 10             	mov    0x10(%ebp),%eax
  800cbe:	eb 05                	jmp    800cc5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5f                   	pop    %edi
  800ccb:	5d                   	pop    %ebp
  800ccc:	c3                   	ret    

00800ccd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	57                   	push   %edi
  800cd1:	56                   	push   %esi
  800cd2:	53                   	push   %ebx
  800cd3:	83 ec 18             	sub    $0x18,%esp
  800cd6:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cd9:	57                   	push   %edi
  800cda:	e8 97 f6 ff ff       	call   800376 <fd2data>
  800cdf:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce1:	83 c4 10             	add    $0x10,%esp
  800ce4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce9:	eb 3d                	jmp    800d28 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ceb:	85 db                	test   %ebx,%ebx
  800ced:	74 04                	je     800cf3 <devpipe_read+0x26>
				return i;
  800cef:	89 d8                	mov    %ebx,%eax
  800cf1:	eb 44                	jmp    800d37 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cf3:	89 f2                	mov    %esi,%edx
  800cf5:	89 f8                	mov    %edi,%eax
  800cf7:	e8 f2 fe ff ff       	call   800bee <_pipeisclosed>
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	75 32                	jne    800d32 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d00:	e8 32 f4 ff ff       	call   800137 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d05:	8b 06                	mov    (%esi),%eax
  800d07:	3b 46 04             	cmp    0x4(%esi),%eax
  800d0a:	74 df                	je     800ceb <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d0c:	99                   	cltd   
  800d0d:	c1 ea 1b             	shr    $0x1b,%edx
  800d10:	01 d0                	add    %edx,%eax
  800d12:	83 e0 1f             	and    $0x1f,%eax
  800d15:	29 d0                	sub    %edx,%eax
  800d17:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d22:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d25:	83 c3 01             	add    $0x1,%ebx
  800d28:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d2b:	75 d8                	jne    800d05 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d2d:	8b 45 10             	mov    0x10(%ebp),%eax
  800d30:	eb 05                	jmp    800d37 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3a:	5b                   	pop    %ebx
  800d3b:	5e                   	pop    %esi
  800d3c:	5f                   	pop    %edi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d4a:	50                   	push   %eax
  800d4b:	e8 3d f6 ff ff       	call   80038d <fd_alloc>
  800d50:	83 c4 10             	add    $0x10,%esp
  800d53:	89 c2                	mov    %eax,%edx
  800d55:	85 c0                	test   %eax,%eax
  800d57:	0f 88 2c 01 00 00    	js     800e89 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5d:	83 ec 04             	sub    $0x4,%esp
  800d60:	68 07 04 00 00       	push   $0x407
  800d65:	ff 75 f4             	pushl  -0xc(%ebp)
  800d68:	6a 00                	push   $0x0
  800d6a:	e8 e7 f3 ff ff       	call   800156 <sys_page_alloc>
  800d6f:	83 c4 10             	add    $0x10,%esp
  800d72:	89 c2                	mov    %eax,%edx
  800d74:	85 c0                	test   %eax,%eax
  800d76:	0f 88 0d 01 00 00    	js     800e89 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d82:	50                   	push   %eax
  800d83:	e8 05 f6 ff ff       	call   80038d <fd_alloc>
  800d88:	89 c3                	mov    %eax,%ebx
  800d8a:	83 c4 10             	add    $0x10,%esp
  800d8d:	85 c0                	test   %eax,%eax
  800d8f:	0f 88 e2 00 00 00    	js     800e77 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d95:	83 ec 04             	sub    $0x4,%esp
  800d98:	68 07 04 00 00       	push   $0x407
  800d9d:	ff 75 f0             	pushl  -0x10(%ebp)
  800da0:	6a 00                	push   $0x0
  800da2:	e8 af f3 ff ff       	call   800156 <sys_page_alloc>
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	83 c4 10             	add    $0x10,%esp
  800dac:	85 c0                	test   %eax,%eax
  800dae:	0f 88 c3 00 00 00    	js     800e77 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800db4:	83 ec 0c             	sub    $0xc,%esp
  800db7:	ff 75 f4             	pushl  -0xc(%ebp)
  800dba:	e8 b7 f5 ff ff       	call   800376 <fd2data>
  800dbf:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc1:	83 c4 0c             	add    $0xc,%esp
  800dc4:	68 07 04 00 00       	push   $0x407
  800dc9:	50                   	push   %eax
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 85 f3 ff ff       	call   800156 <sys_page_alloc>
  800dd1:	89 c3                	mov    %eax,%ebx
  800dd3:	83 c4 10             	add    $0x10,%esp
  800dd6:	85 c0                	test   %eax,%eax
  800dd8:	0f 88 89 00 00 00    	js     800e67 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dde:	83 ec 0c             	sub    $0xc,%esp
  800de1:	ff 75 f0             	pushl  -0x10(%ebp)
  800de4:	e8 8d f5 ff ff       	call   800376 <fd2data>
  800de9:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df0:	50                   	push   %eax
  800df1:	6a 00                	push   $0x0
  800df3:	56                   	push   %esi
  800df4:	6a 00                	push   $0x0
  800df6:	e8 9e f3 ff ff       	call   800199 <sys_page_map>
  800dfb:	89 c3                	mov    %eax,%ebx
  800dfd:	83 c4 20             	add    $0x20,%esp
  800e00:	85 c0                	test   %eax,%eax
  800e02:	78 55                	js     800e59 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e04:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e0d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e12:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e19:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e22:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e27:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e2e:	83 ec 0c             	sub    $0xc,%esp
  800e31:	ff 75 f4             	pushl  -0xc(%ebp)
  800e34:	e8 2d f5 ff ff       	call   800366 <fd2num>
  800e39:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3e:	83 c4 04             	add    $0x4,%esp
  800e41:	ff 75 f0             	pushl  -0x10(%ebp)
  800e44:	e8 1d f5 ff ff       	call   800366 <fd2num>
  800e49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	ba 00 00 00 00       	mov    $0x0,%edx
  800e57:	eb 30                	jmp    800e89 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e59:	83 ec 08             	sub    $0x8,%esp
  800e5c:	56                   	push   %esi
  800e5d:	6a 00                	push   $0x0
  800e5f:	e8 77 f3 ff ff       	call   8001db <sys_page_unmap>
  800e64:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e67:	83 ec 08             	sub    $0x8,%esp
  800e6a:	ff 75 f0             	pushl  -0x10(%ebp)
  800e6d:	6a 00                	push   $0x0
  800e6f:	e8 67 f3 ff ff       	call   8001db <sys_page_unmap>
  800e74:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e77:	83 ec 08             	sub    $0x8,%esp
  800e7a:	ff 75 f4             	pushl  -0xc(%ebp)
  800e7d:	6a 00                	push   $0x0
  800e7f:	e8 57 f3 ff ff       	call   8001db <sys_page_unmap>
  800e84:	83 c4 10             	add    $0x10,%esp
  800e87:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e89:	89 d0                	mov    %edx,%eax
  800e8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e9b:	50                   	push   %eax
  800e9c:	ff 75 08             	pushl  0x8(%ebp)
  800e9f:	e8 38 f5 ff ff       	call   8003dc <fd_lookup>
  800ea4:	89 c2                	mov    %eax,%edx
  800ea6:	83 c4 10             	add    $0x10,%esp
  800ea9:	85 d2                	test   %edx,%edx
  800eab:	78 18                	js     800ec5 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ead:	83 ec 0c             	sub    $0xc,%esp
  800eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800eb3:	e8 be f4 ff ff       	call   800376 <fd2data>
	return _pipeisclosed(fd, p);
  800eb8:	89 c2                	mov    %eax,%edx
  800eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ebd:	e8 2c fd ff ff       	call   800bee <_pipeisclosed>
  800ec2:	83 c4 10             	add    $0x10,%esp
}
  800ec5:	c9                   	leave  
  800ec6:	c3                   	ret    

00800ec7 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec7:	55                   	push   %ebp
  800ec8:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eca:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecf:	5d                   	pop    %ebp
  800ed0:	c3                   	ret    

00800ed1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed7:	68 35 1f 80 00       	push   $0x801f35
  800edc:	ff 75 0c             	pushl  0xc(%ebp)
  800edf:	e8 c4 07 00 00       	call   8016a8 <strcpy>
	return 0;
}
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef7:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f02:	eb 2e                	jmp    800f32 <devcons_write+0x47>
		m = n - tot;
  800f04:	8b 55 10             	mov    0x10(%ebp),%edx
  800f07:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f09:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f0e:	83 fa 7f             	cmp    $0x7f,%edx
  800f11:	77 02                	ja     800f15 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f13:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	56                   	push   %esi
  800f19:	03 45 0c             	add    0xc(%ebp),%eax
  800f1c:	50                   	push   %eax
  800f1d:	57                   	push   %edi
  800f1e:	e8 17 09 00 00       	call   80183a <memmove>
		sys_cputs(buf, m);
  800f23:	83 c4 08             	add    $0x8,%esp
  800f26:	56                   	push   %esi
  800f27:	57                   	push   %edi
  800f28:	e8 6d f1 ff ff       	call   80009a <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f2d:	01 f3                	add    %esi,%ebx
  800f2f:	83 c4 10             	add    $0x10,%esp
  800f32:	89 d8                	mov    %ebx,%eax
  800f34:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f37:	72 cb                	jb     800f04 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f47:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f50:	75 07                	jne    800f59 <devcons_read+0x18>
  800f52:	eb 28                	jmp    800f7c <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f54:	e8 de f1 ff ff       	call   800137 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f59:	e8 5a f1 ff ff       	call   8000b8 <sys_cgetc>
  800f5e:	85 c0                	test   %eax,%eax
  800f60:	74 f2                	je     800f54 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f62:	85 c0                	test   %eax,%eax
  800f64:	78 16                	js     800f7c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f66:	83 f8 04             	cmp    $0x4,%eax
  800f69:	74 0c                	je     800f77 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6e:	88 02                	mov    %al,(%edx)
	return 1;
  800f70:	b8 01 00 00 00       	mov    $0x1,%eax
  800f75:	eb 05                	jmp    800f7c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f77:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f84:	8b 45 08             	mov    0x8(%ebp),%eax
  800f87:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f8a:	6a 01                	push   $0x1
  800f8c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	e8 05 f1 ff ff       	call   80009a <sys_cputs>
  800f95:	83 c4 10             	add    $0x10,%esp
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <getchar>:

int
getchar(void)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fa0:	6a 01                	push   $0x1
  800fa2:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa5:	50                   	push   %eax
  800fa6:	6a 00                	push   $0x0
  800fa8:	e8 98 f6 ff ff       	call   800645 <read>
	if (r < 0)
  800fad:	83 c4 10             	add    $0x10,%esp
  800fb0:	85 c0                	test   %eax,%eax
  800fb2:	78 0f                	js     800fc3 <getchar+0x29>
		return r;
	if (r < 1)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	7e 06                	jle    800fbe <getchar+0x24>
		return -E_EOF;
	return c;
  800fb8:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fbc:	eb 05                	jmp    800fc3 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fbe:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fc3:	c9                   	leave  
  800fc4:	c3                   	ret    

00800fc5 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fc5:	55                   	push   %ebp
  800fc6:	89 e5                	mov    %esp,%ebp
  800fc8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fce:	50                   	push   %eax
  800fcf:	ff 75 08             	pushl  0x8(%ebp)
  800fd2:	e8 05 f4 ff ff       	call   8003dc <fd_lookup>
  800fd7:	83 c4 10             	add    $0x10,%esp
  800fda:	85 c0                	test   %eax,%eax
  800fdc:	78 11                	js     800fef <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fde:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe7:	39 10                	cmp    %edx,(%eax)
  800fe9:	0f 94 c0             	sete   %al
  800fec:	0f b6 c0             	movzbl %al,%eax
}
  800fef:	c9                   	leave  
  800ff0:	c3                   	ret    

00800ff1 <opencons>:

int
opencons(void)
{
  800ff1:	55                   	push   %ebp
  800ff2:	89 e5                	mov    %esp,%ebp
  800ff4:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ffa:	50                   	push   %eax
  800ffb:	e8 8d f3 ff ff       	call   80038d <fd_alloc>
  801000:	83 c4 10             	add    $0x10,%esp
		return r;
  801003:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801005:	85 c0                	test   %eax,%eax
  801007:	78 3e                	js     801047 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801009:	83 ec 04             	sub    $0x4,%esp
  80100c:	68 07 04 00 00       	push   $0x407
  801011:	ff 75 f4             	pushl  -0xc(%ebp)
  801014:	6a 00                	push   $0x0
  801016:	e8 3b f1 ff ff       	call   800156 <sys_page_alloc>
  80101b:	83 c4 10             	add    $0x10,%esp
		return r;
  80101e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801020:	85 c0                	test   %eax,%eax
  801022:	78 23                	js     801047 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801024:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80102a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80102f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801032:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801039:	83 ec 0c             	sub    $0xc,%esp
  80103c:	50                   	push   %eax
  80103d:	e8 24 f3 ff ff       	call   800366 <fd2num>
  801042:	89 c2                	mov    %eax,%edx
  801044:	83 c4 10             	add    $0x10,%esp
}
  801047:	89 d0                	mov    %edx,%eax
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	56                   	push   %esi
  80104f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801050:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801053:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801059:	e8 ba f0 ff ff       	call   800118 <sys_getenvid>
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	ff 75 0c             	pushl  0xc(%ebp)
  801064:	ff 75 08             	pushl  0x8(%ebp)
  801067:	56                   	push   %esi
  801068:	50                   	push   %eax
  801069:	68 44 1f 80 00       	push   $0x801f44
  80106e:	e8 b1 00 00 00       	call   801124 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801073:	83 c4 18             	add    $0x18,%esp
  801076:	53                   	push   %ebx
  801077:	ff 75 10             	pushl  0x10(%ebp)
  80107a:	e8 54 00 00 00       	call   8010d3 <vcprintf>
	cprintf("\n");
  80107f:	c7 04 24 93 1e 80 00 	movl   $0x801e93,(%esp)
  801086:	e8 99 00 00 00       	call   801124 <cprintf>
  80108b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108e:	cc                   	int3   
  80108f:	eb fd                	jmp    80108e <_panic+0x43>

00801091 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	53                   	push   %ebx
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80109b:	8b 13                	mov    (%ebx),%edx
  80109d:	8d 42 01             	lea    0x1(%edx),%eax
  8010a0:	89 03                	mov    %eax,(%ebx)
  8010a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ae:	75 1a                	jne    8010ca <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010b0:	83 ec 08             	sub    $0x8,%esp
  8010b3:	68 ff 00 00 00       	push   $0xff
  8010b8:	8d 43 08             	lea    0x8(%ebx),%eax
  8010bb:	50                   	push   %eax
  8010bc:	e8 d9 ef ff ff       	call   80009a <sys_cputs>
		b->idx = 0;
  8010c1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c7:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ca:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010e3:	00 00 00 
	b.cnt = 0;
  8010e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f0:	ff 75 0c             	pushl  0xc(%ebp)
  8010f3:	ff 75 08             	pushl  0x8(%ebp)
  8010f6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010fc:	50                   	push   %eax
  8010fd:	68 91 10 80 00       	push   $0x801091
  801102:	e8 4f 01 00 00       	call   801256 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801107:	83 c4 08             	add    $0x8,%esp
  80110a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801110:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801116:	50                   	push   %eax
  801117:	e8 7e ef ff ff       	call   80009a <sys_cputs>

	return b.cnt;
}
  80111c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80112a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80112d:	50                   	push   %eax
  80112e:	ff 75 08             	pushl  0x8(%ebp)
  801131:	e8 9d ff ff ff       	call   8010d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801138:	55                   	push   %ebp
  801139:	89 e5                	mov    %esp,%ebp
  80113b:	57                   	push   %edi
  80113c:	56                   	push   %esi
  80113d:	53                   	push   %ebx
  80113e:	83 ec 1c             	sub    $0x1c,%esp
  801141:	89 c7                	mov    %eax,%edi
  801143:	89 d6                	mov    %edx,%esi
  801145:	8b 45 08             	mov    0x8(%ebp),%eax
  801148:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114b:	89 d1                	mov    %edx,%ecx
  80114d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801150:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801153:	8b 45 10             	mov    0x10(%ebp),%eax
  801156:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801159:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80115c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801163:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801166:	72 05                	jb     80116d <printnum+0x35>
  801168:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  80116b:	77 3e                	ja     8011ab <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80116d:	83 ec 0c             	sub    $0xc,%esp
  801170:	ff 75 18             	pushl  0x18(%ebp)
  801173:	83 eb 01             	sub    $0x1,%ebx
  801176:	53                   	push   %ebx
  801177:	50                   	push   %eax
  801178:	83 ec 08             	sub    $0x8,%esp
  80117b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80117e:	ff 75 e0             	pushl  -0x20(%ebp)
  801181:	ff 75 dc             	pushl  -0x24(%ebp)
  801184:	ff 75 d8             	pushl  -0x28(%ebp)
  801187:	e8 94 09 00 00       	call   801b20 <__udivdi3>
  80118c:	83 c4 18             	add    $0x18,%esp
  80118f:	52                   	push   %edx
  801190:	50                   	push   %eax
  801191:	89 f2                	mov    %esi,%edx
  801193:	89 f8                	mov    %edi,%eax
  801195:	e8 9e ff ff ff       	call   801138 <printnum>
  80119a:	83 c4 20             	add    $0x20,%esp
  80119d:	eb 13                	jmp    8011b2 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80119f:	83 ec 08             	sub    $0x8,%esp
  8011a2:	56                   	push   %esi
  8011a3:	ff 75 18             	pushl  0x18(%ebp)
  8011a6:	ff d7                	call   *%edi
  8011a8:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ab:	83 eb 01             	sub    $0x1,%ebx
  8011ae:	85 db                	test   %ebx,%ebx
  8011b0:	7f ed                	jg     80119f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b2:	83 ec 08             	sub    $0x8,%esp
  8011b5:	56                   	push   %esi
  8011b6:	83 ec 04             	sub    $0x4,%esp
  8011b9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011bf:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011c5:	e8 86 0a 00 00       	call   801c50 <__umoddi3>
  8011ca:	83 c4 14             	add    $0x14,%esp
  8011cd:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011d4:	50                   	push   %eax
  8011d5:	ff d7                	call   *%edi
  8011d7:	83 c4 10             	add    $0x10,%esp
}
  8011da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dd:	5b                   	pop    %ebx
  8011de:	5e                   	pop    %esi
  8011df:	5f                   	pop    %edi
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    

008011e2 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011e2:	55                   	push   %ebp
  8011e3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011e5:	83 fa 01             	cmp    $0x1,%edx
  8011e8:	7e 0e                	jle    8011f8 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011ea:	8b 10                	mov    (%eax),%edx
  8011ec:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011ef:	89 08                	mov    %ecx,(%eax)
  8011f1:	8b 02                	mov    (%edx),%eax
  8011f3:	8b 52 04             	mov    0x4(%edx),%edx
  8011f6:	eb 22                	jmp    80121a <getuint+0x38>
	else if (lflag)
  8011f8:	85 d2                	test   %edx,%edx
  8011fa:	74 10                	je     80120c <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011fc:	8b 10                	mov    (%eax),%edx
  8011fe:	8d 4a 04             	lea    0x4(%edx),%ecx
  801201:	89 08                	mov    %ecx,(%eax)
  801203:	8b 02                	mov    (%edx),%eax
  801205:	ba 00 00 00 00       	mov    $0x0,%edx
  80120a:	eb 0e                	jmp    80121a <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80120c:	8b 10                	mov    (%eax),%edx
  80120e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801211:	89 08                	mov    %ecx,(%eax)
  801213:	8b 02                	mov    (%edx),%eax
  801215:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80121a:	5d                   	pop    %ebp
  80121b:	c3                   	ret    

0080121c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801222:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801226:	8b 10                	mov    (%eax),%edx
  801228:	3b 50 04             	cmp    0x4(%eax),%edx
  80122b:	73 0a                	jae    801237 <sprintputch+0x1b>
		*b->buf++ = ch;
  80122d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801230:	89 08                	mov    %ecx,(%eax)
  801232:	8b 45 08             	mov    0x8(%ebp),%eax
  801235:	88 02                	mov    %al,(%edx)
}
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80123f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801242:	50                   	push   %eax
  801243:	ff 75 10             	pushl  0x10(%ebp)
  801246:	ff 75 0c             	pushl  0xc(%ebp)
  801249:	ff 75 08             	pushl  0x8(%ebp)
  80124c:	e8 05 00 00 00       	call   801256 <vprintfmt>
	va_end(ap);
  801251:	83 c4 10             	add    $0x10,%esp
}
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	57                   	push   %edi
  80125a:	56                   	push   %esi
  80125b:	53                   	push   %ebx
  80125c:	83 ec 2c             	sub    $0x2c,%esp
  80125f:	8b 75 08             	mov    0x8(%ebp),%esi
  801262:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801265:	8b 7d 10             	mov    0x10(%ebp),%edi
  801268:	eb 12                	jmp    80127c <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80126a:	85 c0                	test   %eax,%eax
  80126c:	0f 84 8d 03 00 00    	je     8015ff <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  801272:	83 ec 08             	sub    $0x8,%esp
  801275:	53                   	push   %ebx
  801276:	50                   	push   %eax
  801277:	ff d6                	call   *%esi
  801279:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80127c:	83 c7 01             	add    $0x1,%edi
  80127f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801283:	83 f8 25             	cmp    $0x25,%eax
  801286:	75 e2                	jne    80126a <vprintfmt+0x14>
  801288:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80128c:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801293:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80129a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8012a6:	eb 07                	jmp    8012af <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ab:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012af:	8d 47 01             	lea    0x1(%edi),%eax
  8012b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012b5:	0f b6 07             	movzbl (%edi),%eax
  8012b8:	0f b6 c8             	movzbl %al,%ecx
  8012bb:	83 e8 23             	sub    $0x23,%eax
  8012be:	3c 55                	cmp    $0x55,%al
  8012c0:	0f 87 1e 03 00 00    	ja     8015e4 <vprintfmt+0x38e>
  8012c6:	0f b6 c0             	movzbl %al,%eax
  8012c9:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012d3:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012d7:	eb d6                	jmp    8012af <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012e7:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012eb:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012ee:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012f1:	83 fa 09             	cmp    $0x9,%edx
  8012f4:	77 38                	ja     80132e <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012f6:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012f9:	eb e9                	jmp    8012e4 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8012fe:	8d 48 04             	lea    0x4(%eax),%ecx
  801301:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801304:	8b 00                	mov    (%eax),%eax
  801306:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80130c:	eb 26                	jmp    801334 <vprintfmt+0xde>
  80130e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801311:	89 c8                	mov    %ecx,%eax
  801313:	c1 f8 1f             	sar    $0x1f,%eax
  801316:	f7 d0                	not    %eax
  801318:	21 c1                	and    %eax,%ecx
  80131a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80131d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801320:	eb 8d                	jmp    8012af <vprintfmt+0x59>
  801322:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801325:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80132c:	eb 81                	jmp    8012af <vprintfmt+0x59>
  80132e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801331:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801334:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801338:	0f 89 71 ff ff ff    	jns    8012af <vprintfmt+0x59>
				width = precision, precision = -1;
  80133e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801341:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801344:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80134b:	e9 5f ff ff ff       	jmp    8012af <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801350:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801353:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801356:	e9 54 ff ff ff       	jmp    8012af <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80135b:	8b 45 14             	mov    0x14(%ebp),%eax
  80135e:	8d 50 04             	lea    0x4(%eax),%edx
  801361:	89 55 14             	mov    %edx,0x14(%ebp)
  801364:	83 ec 08             	sub    $0x8,%esp
  801367:	53                   	push   %ebx
  801368:	ff 30                	pushl  (%eax)
  80136a:	ff d6                	call   *%esi
			break;
  80136c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80136f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801372:	e9 05 ff ff ff       	jmp    80127c <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  801377:	8b 45 14             	mov    0x14(%ebp),%eax
  80137a:	8d 50 04             	lea    0x4(%eax),%edx
  80137d:	89 55 14             	mov    %edx,0x14(%ebp)
  801380:	8b 00                	mov    (%eax),%eax
  801382:	99                   	cltd   
  801383:	31 d0                	xor    %edx,%eax
  801385:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801387:	83 f8 0f             	cmp    $0xf,%eax
  80138a:	7f 0b                	jg     801397 <vprintfmt+0x141>
  80138c:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  801393:	85 d2                	test   %edx,%edx
  801395:	75 18                	jne    8013af <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  801397:	50                   	push   %eax
  801398:	68 7f 1f 80 00       	push   $0x801f7f
  80139d:	53                   	push   %ebx
  80139e:	56                   	push   %esi
  80139f:	e8 95 fe ff ff       	call   801239 <printfmt>
  8013a4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013aa:	e9 cd fe ff ff       	jmp    80127c <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013af:	52                   	push   %edx
  8013b0:	68 dd 1e 80 00       	push   $0x801edd
  8013b5:	53                   	push   %ebx
  8013b6:	56                   	push   %esi
  8013b7:	e8 7d fe ff ff       	call   801239 <printfmt>
  8013bc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c2:	e9 b5 fe ff ff       	jmp    80127c <vprintfmt+0x26>
  8013c7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013cd:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013d3:	8d 50 04             	lea    0x4(%eax),%edx
  8013d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013d9:	8b 38                	mov    (%eax),%edi
  8013db:	85 ff                	test   %edi,%edi
  8013dd:	75 05                	jne    8013e4 <vprintfmt+0x18e>
				p = "(null)";
  8013df:	bf 78 1f 80 00       	mov    $0x801f78,%edi
			if (width > 0 && padc != '-')
  8013e4:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e8:	0f 84 91 00 00 00    	je     80147f <vprintfmt+0x229>
  8013ee:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8013f2:	0f 8e 95 00 00 00    	jle    80148d <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	51                   	push   %ecx
  8013fc:	57                   	push   %edi
  8013fd:	e8 85 02 00 00       	call   801687 <strnlen>
  801402:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801405:	29 c1                	sub    %eax,%ecx
  801407:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80140a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80140d:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801411:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801414:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801417:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801419:	eb 0f                	jmp    80142a <vprintfmt+0x1d4>
					putch(padc, putdat);
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	53                   	push   %ebx
  80141f:	ff 75 e0             	pushl  -0x20(%ebp)
  801422:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801424:	83 ef 01             	sub    $0x1,%edi
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	85 ff                	test   %edi,%edi
  80142c:	7f ed                	jg     80141b <vprintfmt+0x1c5>
  80142e:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801431:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801434:	89 c8                	mov    %ecx,%eax
  801436:	c1 f8 1f             	sar    $0x1f,%eax
  801439:	f7 d0                	not    %eax
  80143b:	21 c8                	and    %ecx,%eax
  80143d:	29 c1                	sub    %eax,%ecx
  80143f:	89 75 08             	mov    %esi,0x8(%ebp)
  801442:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801445:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801448:	89 cb                	mov    %ecx,%ebx
  80144a:	eb 4d                	jmp    801499 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80144c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801450:	74 1b                	je     80146d <vprintfmt+0x217>
  801452:	0f be c0             	movsbl %al,%eax
  801455:	83 e8 20             	sub    $0x20,%eax
  801458:	83 f8 5e             	cmp    $0x5e,%eax
  80145b:	76 10                	jbe    80146d <vprintfmt+0x217>
					putch('?', putdat);
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	ff 75 0c             	pushl  0xc(%ebp)
  801463:	6a 3f                	push   $0x3f
  801465:	ff 55 08             	call   *0x8(%ebp)
  801468:	83 c4 10             	add    $0x10,%esp
  80146b:	eb 0d                	jmp    80147a <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80146d:	83 ec 08             	sub    $0x8,%esp
  801470:	ff 75 0c             	pushl  0xc(%ebp)
  801473:	52                   	push   %edx
  801474:	ff 55 08             	call   *0x8(%ebp)
  801477:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147a:	83 eb 01             	sub    $0x1,%ebx
  80147d:	eb 1a                	jmp    801499 <vprintfmt+0x243>
  80147f:	89 75 08             	mov    %esi,0x8(%ebp)
  801482:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801488:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80148b:	eb 0c                	jmp    801499 <vprintfmt+0x243>
  80148d:	89 75 08             	mov    %esi,0x8(%ebp)
  801490:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801493:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801496:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801499:	83 c7 01             	add    $0x1,%edi
  80149c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014a0:	0f be d0             	movsbl %al,%edx
  8014a3:	85 d2                	test   %edx,%edx
  8014a5:	74 23                	je     8014ca <vprintfmt+0x274>
  8014a7:	85 f6                	test   %esi,%esi
  8014a9:	78 a1                	js     80144c <vprintfmt+0x1f6>
  8014ab:	83 ee 01             	sub    $0x1,%esi
  8014ae:	79 9c                	jns    80144c <vprintfmt+0x1f6>
  8014b0:	89 df                	mov    %ebx,%edi
  8014b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b8:	eb 18                	jmp    8014d2 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ba:	83 ec 08             	sub    $0x8,%esp
  8014bd:	53                   	push   %ebx
  8014be:	6a 20                	push   $0x20
  8014c0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014c2:	83 ef 01             	sub    $0x1,%edi
  8014c5:	83 c4 10             	add    $0x10,%esp
  8014c8:	eb 08                	jmp    8014d2 <vprintfmt+0x27c>
  8014ca:	89 df                	mov    %ebx,%edi
  8014cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8014cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014d2:	85 ff                	test   %edi,%edi
  8014d4:	7f e4                	jg     8014ba <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014d9:	e9 9e fd ff ff       	jmp    80127c <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014de:	83 fa 01             	cmp    $0x1,%edx
  8014e1:	7e 16                	jle    8014f9 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e6:	8d 50 08             	lea    0x8(%eax),%edx
  8014e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ec:	8b 50 04             	mov    0x4(%eax),%edx
  8014ef:	8b 00                	mov    (%eax),%eax
  8014f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014f7:	eb 32                	jmp    80152b <vprintfmt+0x2d5>
	else if (lflag)
  8014f9:	85 d2                	test   %edx,%edx
  8014fb:	74 18                	je     801515 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8014fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801500:	8d 50 04             	lea    0x4(%eax),%edx
  801503:	89 55 14             	mov    %edx,0x14(%ebp)
  801506:	8b 00                	mov    (%eax),%eax
  801508:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80150b:	89 c1                	mov    %eax,%ecx
  80150d:	c1 f9 1f             	sar    $0x1f,%ecx
  801510:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801513:	eb 16                	jmp    80152b <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801515:	8b 45 14             	mov    0x14(%ebp),%eax
  801518:	8d 50 04             	lea    0x4(%eax),%edx
  80151b:	89 55 14             	mov    %edx,0x14(%ebp)
  80151e:	8b 00                	mov    (%eax),%eax
  801520:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801523:	89 c1                	mov    %eax,%ecx
  801525:	c1 f9 1f             	sar    $0x1f,%ecx
  801528:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80152b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80152e:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801531:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801536:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80153a:	79 74                	jns    8015b0 <vprintfmt+0x35a>
				putch('-', putdat);
  80153c:	83 ec 08             	sub    $0x8,%esp
  80153f:	53                   	push   %ebx
  801540:	6a 2d                	push   $0x2d
  801542:	ff d6                	call   *%esi
				num = -(long long) num;
  801544:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801547:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80154a:	f7 d8                	neg    %eax
  80154c:	83 d2 00             	adc    $0x0,%edx
  80154f:	f7 da                	neg    %edx
  801551:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801554:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801559:	eb 55                	jmp    8015b0 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80155b:	8d 45 14             	lea    0x14(%ebp),%eax
  80155e:	e8 7f fc ff ff       	call   8011e2 <getuint>
			base = 10;
  801563:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801568:	eb 46                	jmp    8015b0 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  80156a:	8d 45 14             	lea    0x14(%ebp),%eax
  80156d:	e8 70 fc ff ff       	call   8011e2 <getuint>
			base = 8;
  801572:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801577:	eb 37                	jmp    8015b0 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	53                   	push   %ebx
  80157d:	6a 30                	push   $0x30
  80157f:	ff d6                	call   *%esi
			putch('x', putdat);
  801581:	83 c4 08             	add    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	6a 78                	push   $0x78
  801587:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801589:	8b 45 14             	mov    0x14(%ebp),%eax
  80158c:	8d 50 04             	lea    0x4(%eax),%edx
  80158f:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801592:	8b 00                	mov    (%eax),%eax
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801599:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  80159c:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015a1:	eb 0d                	jmp    8015b0 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a6:	e8 37 fc ff ff       	call   8011e2 <getuint>
			base = 16;
  8015ab:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015b0:	83 ec 0c             	sub    $0xc,%esp
  8015b3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015b7:	57                   	push   %edi
  8015b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8015bb:	51                   	push   %ecx
  8015bc:	52                   	push   %edx
  8015bd:	50                   	push   %eax
  8015be:	89 da                	mov    %ebx,%edx
  8015c0:	89 f0                	mov    %esi,%eax
  8015c2:	e8 71 fb ff ff       	call   801138 <printnum>
			break;
  8015c7:	83 c4 20             	add    $0x20,%esp
  8015ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015cd:	e9 aa fc ff ff       	jmp    80127c <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015d2:	83 ec 08             	sub    $0x8,%esp
  8015d5:	53                   	push   %ebx
  8015d6:	51                   	push   %ecx
  8015d7:	ff d6                	call   *%esi
			break;
  8015d9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015df:	e9 98 fc ff ff       	jmp    80127c <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	6a 25                	push   $0x25
  8015ea:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	eb 03                	jmp    8015f4 <vprintfmt+0x39e>
  8015f1:	83 ef 01             	sub    $0x1,%edi
  8015f4:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8015f8:	75 f7                	jne    8015f1 <vprintfmt+0x39b>
  8015fa:	e9 7d fc ff ff       	jmp    80127c <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8015ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801602:	5b                   	pop    %ebx
  801603:	5e                   	pop    %esi
  801604:	5f                   	pop    %edi
  801605:	5d                   	pop    %ebp
  801606:	c3                   	ret    

00801607 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	83 ec 18             	sub    $0x18,%esp
  80160d:	8b 45 08             	mov    0x8(%ebp),%eax
  801610:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801613:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801616:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80161d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801624:	85 c0                	test   %eax,%eax
  801626:	74 26                	je     80164e <vsnprintf+0x47>
  801628:	85 d2                	test   %edx,%edx
  80162a:	7e 22                	jle    80164e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80162c:	ff 75 14             	pushl  0x14(%ebp)
  80162f:	ff 75 10             	pushl  0x10(%ebp)
  801632:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801635:	50                   	push   %eax
  801636:	68 1c 12 80 00       	push   $0x80121c
  80163b:	e8 16 fc ff ff       	call   801256 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801640:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801643:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801649:	83 c4 10             	add    $0x10,%esp
  80164c:	eb 05                	jmp    801653 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80164e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801653:	c9                   	leave  
  801654:	c3                   	ret    

00801655 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801655:	55                   	push   %ebp
  801656:	89 e5                	mov    %esp,%ebp
  801658:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80165e:	50                   	push   %eax
  80165f:	ff 75 10             	pushl  0x10(%ebp)
  801662:	ff 75 0c             	pushl  0xc(%ebp)
  801665:	ff 75 08             	pushl  0x8(%ebp)
  801668:	e8 9a ff ff ff       	call   801607 <vsnprintf>
	va_end(ap);

	return rc;
}
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801675:	b8 00 00 00 00       	mov    $0x0,%eax
  80167a:	eb 03                	jmp    80167f <strlen+0x10>
		n++;
  80167c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80167f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801683:	75 f7                	jne    80167c <strlen+0xd>
		n++;
	return n;
}
  801685:	5d                   	pop    %ebp
  801686:	c3                   	ret    

00801687 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801690:	ba 00 00 00 00       	mov    $0x0,%edx
  801695:	eb 03                	jmp    80169a <strnlen+0x13>
		n++;
  801697:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169a:	39 c2                	cmp    %eax,%edx
  80169c:	74 08                	je     8016a6 <strnlen+0x1f>
  80169e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016a2:	75 f3                	jne    801697 <strnlen+0x10>
  8016a4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016a6:	5d                   	pop    %ebp
  8016a7:	c3                   	ret    

008016a8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a8:	55                   	push   %ebp
  8016a9:	89 e5                	mov    %esp,%ebp
  8016ab:	53                   	push   %ebx
  8016ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8016af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b2:	89 c2                	mov    %eax,%edx
  8016b4:	83 c2 01             	add    $0x1,%edx
  8016b7:	83 c1 01             	add    $0x1,%ecx
  8016ba:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016be:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c1:	84 db                	test   %bl,%bl
  8016c3:	75 ef                	jne    8016b4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016c5:	5b                   	pop    %ebx
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016cf:	53                   	push   %ebx
  8016d0:	e8 9a ff ff ff       	call   80166f <strlen>
  8016d5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016d8:	ff 75 0c             	pushl  0xc(%ebp)
  8016db:	01 d8                	add    %ebx,%eax
  8016dd:	50                   	push   %eax
  8016de:	e8 c5 ff ff ff       	call   8016a8 <strcpy>
	return dst;
}
  8016e3:	89 d8                	mov    %ebx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
  8016ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016f5:	89 f3                	mov    %esi,%ebx
  8016f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016fa:	89 f2                	mov    %esi,%edx
  8016fc:	eb 0f                	jmp    80170d <strncpy+0x23>
		*dst++ = *src;
  8016fe:	83 c2 01             	add    $0x1,%edx
  801701:	0f b6 01             	movzbl (%ecx),%eax
  801704:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801707:	80 39 01             	cmpb   $0x1,(%ecx)
  80170a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170d:	39 da                	cmp    %ebx,%edx
  80170f:	75 ed                	jne    8016fe <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801711:	89 f0                	mov    %esi,%eax
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
  80171c:	8b 75 08             	mov    0x8(%ebp),%esi
  80171f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801722:	8b 55 10             	mov    0x10(%ebp),%edx
  801725:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801727:	85 d2                	test   %edx,%edx
  801729:	74 21                	je     80174c <strlcpy+0x35>
  80172b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80172f:	89 f2                	mov    %esi,%edx
  801731:	eb 09                	jmp    80173c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801733:	83 c2 01             	add    $0x1,%edx
  801736:	83 c1 01             	add    $0x1,%ecx
  801739:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80173c:	39 c2                	cmp    %eax,%edx
  80173e:	74 09                	je     801749 <strlcpy+0x32>
  801740:	0f b6 19             	movzbl (%ecx),%ebx
  801743:	84 db                	test   %bl,%bl
  801745:	75 ec                	jne    801733 <strlcpy+0x1c>
  801747:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801749:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80174c:	29 f0                	sub    %esi,%eax
}
  80174e:	5b                   	pop    %ebx
  80174f:	5e                   	pop    %esi
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801758:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175b:	eb 06                	jmp    801763 <strcmp+0x11>
		p++, q++;
  80175d:	83 c1 01             	add    $0x1,%ecx
  801760:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801763:	0f b6 01             	movzbl (%ecx),%eax
  801766:	84 c0                	test   %al,%al
  801768:	74 04                	je     80176e <strcmp+0x1c>
  80176a:	3a 02                	cmp    (%edx),%al
  80176c:	74 ef                	je     80175d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80176e:	0f b6 c0             	movzbl %al,%eax
  801771:	0f b6 12             	movzbl (%edx),%edx
  801774:	29 d0                	sub    %edx,%eax
}
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	8b 45 08             	mov    0x8(%ebp),%eax
  80177f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801782:	89 c3                	mov    %eax,%ebx
  801784:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801787:	eb 06                	jmp    80178f <strncmp+0x17>
		n--, p++, q++;
  801789:	83 c0 01             	add    $0x1,%eax
  80178c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80178f:	39 d8                	cmp    %ebx,%eax
  801791:	74 15                	je     8017a8 <strncmp+0x30>
  801793:	0f b6 08             	movzbl (%eax),%ecx
  801796:	84 c9                	test   %cl,%cl
  801798:	74 04                	je     80179e <strncmp+0x26>
  80179a:	3a 0a                	cmp    (%edx),%cl
  80179c:	74 eb                	je     801789 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80179e:	0f b6 00             	movzbl (%eax),%eax
  8017a1:	0f b6 12             	movzbl (%edx),%edx
  8017a4:	29 d0                	sub    %edx,%eax
  8017a6:	eb 05                	jmp    8017ad <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017a8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ad:	5b                   	pop    %ebx
  8017ae:	5d                   	pop    %ebp
  8017af:	c3                   	ret    

008017b0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b0:	55                   	push   %ebp
  8017b1:	89 e5                	mov    %esp,%ebp
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ba:	eb 07                	jmp    8017c3 <strchr+0x13>
		if (*s == c)
  8017bc:	38 ca                	cmp    %cl,%dl
  8017be:	74 0f                	je     8017cf <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017c0:	83 c0 01             	add    $0x1,%eax
  8017c3:	0f b6 10             	movzbl (%eax),%edx
  8017c6:	84 d2                	test   %dl,%dl
  8017c8:	75 f2                	jne    8017bc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cf:	5d                   	pop    %ebp
  8017d0:	c3                   	ret    

008017d1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d1:	55                   	push   %ebp
  8017d2:	89 e5                	mov    %esp,%ebp
  8017d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017db:	eb 03                	jmp    8017e0 <strfind+0xf>
  8017dd:	83 c0 01             	add    $0x1,%eax
  8017e0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017e3:	84 d2                	test   %dl,%dl
  8017e5:	74 04                	je     8017eb <strfind+0x1a>
  8017e7:	38 ca                	cmp    %cl,%dl
  8017e9:	75 f2                	jne    8017dd <strfind+0xc>
			break;
	return (char *) s;
}
  8017eb:	5d                   	pop    %ebp
  8017ec:	c3                   	ret    

008017ed <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	57                   	push   %edi
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8017f9:	85 c9                	test   %ecx,%ecx
  8017fb:	74 36                	je     801833 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017fd:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801803:	75 28                	jne    80182d <memset+0x40>
  801805:	f6 c1 03             	test   $0x3,%cl
  801808:	75 23                	jne    80182d <memset+0x40>
		c &= 0xFF;
  80180a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80180e:	89 d3                	mov    %edx,%ebx
  801810:	c1 e3 08             	shl    $0x8,%ebx
  801813:	89 d6                	mov    %edx,%esi
  801815:	c1 e6 18             	shl    $0x18,%esi
  801818:	89 d0                	mov    %edx,%eax
  80181a:	c1 e0 10             	shl    $0x10,%eax
  80181d:	09 f0                	or     %esi,%eax
  80181f:	09 c2                	or     %eax,%edx
  801821:	89 d0                	mov    %edx,%eax
  801823:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801825:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801828:	fc                   	cld    
  801829:	f3 ab                	rep stos %eax,%es:(%edi)
  80182b:	eb 06                	jmp    801833 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80182d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801830:	fc                   	cld    
  801831:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801833:	89 f8                	mov    %edi,%eax
  801835:	5b                   	pop    %ebx
  801836:	5e                   	pop    %esi
  801837:	5f                   	pop    %edi
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	57                   	push   %edi
  80183e:	56                   	push   %esi
  80183f:	8b 45 08             	mov    0x8(%ebp),%eax
  801842:	8b 75 0c             	mov    0xc(%ebp),%esi
  801845:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801848:	39 c6                	cmp    %eax,%esi
  80184a:	73 35                	jae    801881 <memmove+0x47>
  80184c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80184f:	39 d0                	cmp    %edx,%eax
  801851:	73 2e                	jae    801881 <memmove+0x47>
		s += n;
		d += n;
  801853:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801856:	89 d6                	mov    %edx,%esi
  801858:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801860:	75 13                	jne    801875 <memmove+0x3b>
  801862:	f6 c1 03             	test   $0x3,%cl
  801865:	75 0e                	jne    801875 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801867:	83 ef 04             	sub    $0x4,%edi
  80186a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80186d:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801870:	fd                   	std    
  801871:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801873:	eb 09                	jmp    80187e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801875:	83 ef 01             	sub    $0x1,%edi
  801878:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80187b:	fd                   	std    
  80187c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80187e:	fc                   	cld    
  80187f:	eb 1d                	jmp    80189e <memmove+0x64>
  801881:	89 f2                	mov    %esi,%edx
  801883:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801885:	f6 c2 03             	test   $0x3,%dl
  801888:	75 0f                	jne    801899 <memmove+0x5f>
  80188a:	f6 c1 03             	test   $0x3,%cl
  80188d:	75 0a                	jne    801899 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80188f:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  801892:	89 c7                	mov    %eax,%edi
  801894:	fc                   	cld    
  801895:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801897:	eb 05                	jmp    80189e <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801899:	89 c7                	mov    %eax,%edi
  80189b:	fc                   	cld    
  80189c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80189e:	5e                   	pop    %esi
  80189f:	5f                   	pop    %edi
  8018a0:	5d                   	pop    %ebp
  8018a1:	c3                   	ret    

008018a2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a2:	55                   	push   %ebp
  8018a3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018a5:	ff 75 10             	pushl  0x10(%ebp)
  8018a8:	ff 75 0c             	pushl  0xc(%ebp)
  8018ab:	ff 75 08             	pushl  0x8(%ebp)
  8018ae:	e8 87 ff ff ff       	call   80183a <memmove>
}
  8018b3:	c9                   	leave  
  8018b4:	c3                   	ret    

008018b5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	56                   	push   %esi
  8018b9:	53                   	push   %ebx
  8018ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c0:	89 c6                	mov    %eax,%esi
  8018c2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018c5:	eb 1a                	jmp    8018e1 <memcmp+0x2c>
		if (*s1 != *s2)
  8018c7:	0f b6 08             	movzbl (%eax),%ecx
  8018ca:	0f b6 1a             	movzbl (%edx),%ebx
  8018cd:	38 d9                	cmp    %bl,%cl
  8018cf:	74 0a                	je     8018db <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018d1:	0f b6 c1             	movzbl %cl,%eax
  8018d4:	0f b6 db             	movzbl %bl,%ebx
  8018d7:	29 d8                	sub    %ebx,%eax
  8018d9:	eb 0f                	jmp    8018ea <memcmp+0x35>
		s1++, s2++;
  8018db:	83 c0 01             	add    $0x1,%eax
  8018de:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e1:	39 f0                	cmp    %esi,%eax
  8018e3:	75 e2                	jne    8018c7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5d                   	pop    %ebp
  8018ed:	c3                   	ret    

008018ee <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018ee:	55                   	push   %ebp
  8018ef:	89 e5                	mov    %esp,%ebp
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018f7:	89 c2                	mov    %eax,%edx
  8018f9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018fc:	eb 07                	jmp    801905 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018fe:	38 08                	cmp    %cl,(%eax)
  801900:	74 07                	je     801909 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801902:	83 c0 01             	add    $0x1,%eax
  801905:	39 d0                	cmp    %edx,%eax
  801907:	72 f5                	jb     8018fe <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801909:	5d                   	pop    %ebp
  80190a:	c3                   	ret    

0080190b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80190b:	55                   	push   %ebp
  80190c:	89 e5                	mov    %esp,%ebp
  80190e:	57                   	push   %edi
  80190f:	56                   	push   %esi
  801910:	53                   	push   %ebx
  801911:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801914:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801917:	eb 03                	jmp    80191c <strtol+0x11>
		s++;
  801919:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191c:	0f b6 01             	movzbl (%ecx),%eax
  80191f:	3c 09                	cmp    $0x9,%al
  801921:	74 f6                	je     801919 <strtol+0xe>
  801923:	3c 20                	cmp    $0x20,%al
  801925:	74 f2                	je     801919 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801927:	3c 2b                	cmp    $0x2b,%al
  801929:	75 0a                	jne    801935 <strtol+0x2a>
		s++;
  80192b:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80192e:	bf 00 00 00 00       	mov    $0x0,%edi
  801933:	eb 10                	jmp    801945 <strtol+0x3a>
  801935:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80193a:	3c 2d                	cmp    $0x2d,%al
  80193c:	75 07                	jne    801945 <strtol+0x3a>
		s++, neg = 1;
  80193e:	8d 49 01             	lea    0x1(%ecx),%ecx
  801941:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801945:	85 db                	test   %ebx,%ebx
  801947:	0f 94 c0             	sete   %al
  80194a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801950:	75 19                	jne    80196b <strtol+0x60>
  801952:	80 39 30             	cmpb   $0x30,(%ecx)
  801955:	75 14                	jne    80196b <strtol+0x60>
  801957:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80195b:	0f 85 8a 00 00 00    	jne    8019eb <strtol+0xe0>
		s += 2, base = 16;
  801961:	83 c1 02             	add    $0x2,%ecx
  801964:	bb 10 00 00 00       	mov    $0x10,%ebx
  801969:	eb 16                	jmp    801981 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80196b:	84 c0                	test   %al,%al
  80196d:	74 12                	je     801981 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80196f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801974:	80 39 30             	cmpb   $0x30,(%ecx)
  801977:	75 08                	jne    801981 <strtol+0x76>
		s++, base = 8;
  801979:	83 c1 01             	add    $0x1,%ecx
  80197c:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801981:	b8 00 00 00 00       	mov    $0x0,%eax
  801986:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801989:	0f b6 11             	movzbl (%ecx),%edx
  80198c:	8d 72 d0             	lea    -0x30(%edx),%esi
  80198f:	89 f3                	mov    %esi,%ebx
  801991:	80 fb 09             	cmp    $0x9,%bl
  801994:	77 08                	ja     80199e <strtol+0x93>
			dig = *s - '0';
  801996:	0f be d2             	movsbl %dl,%edx
  801999:	83 ea 30             	sub    $0x30,%edx
  80199c:	eb 22                	jmp    8019c0 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  80199e:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019a1:	89 f3                	mov    %esi,%ebx
  8019a3:	80 fb 19             	cmp    $0x19,%bl
  8019a6:	77 08                	ja     8019b0 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019a8:	0f be d2             	movsbl %dl,%edx
  8019ab:	83 ea 57             	sub    $0x57,%edx
  8019ae:	eb 10                	jmp    8019c0 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019b0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019b3:	89 f3                	mov    %esi,%ebx
  8019b5:	80 fb 19             	cmp    $0x19,%bl
  8019b8:	77 16                	ja     8019d0 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019ba:	0f be d2             	movsbl %dl,%edx
  8019bd:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019c0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019c3:	7d 0f                	jge    8019d4 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019c5:	83 c1 01             	add    $0x1,%ecx
  8019c8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019cc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019ce:	eb b9                	jmp    801989 <strtol+0x7e>
  8019d0:	89 c2                	mov    %eax,%edx
  8019d2:	eb 02                	jmp    8019d6 <strtol+0xcb>
  8019d4:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019da:	74 05                	je     8019e1 <strtol+0xd6>
		*endptr = (char *) s;
  8019dc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019df:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019e1:	85 ff                	test   %edi,%edi
  8019e3:	74 0c                	je     8019f1 <strtol+0xe6>
  8019e5:	89 d0                	mov    %edx,%eax
  8019e7:	f7 d8                	neg    %eax
  8019e9:	eb 06                	jmp    8019f1 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019eb:	84 c0                	test   %al,%al
  8019ed:	75 8a                	jne    801979 <strtol+0x6e>
  8019ef:	eb 90                	jmp    801981 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5f                   	pop    %edi
  8019f4:	5d                   	pop    %ebp
  8019f5:	c3                   	ret    

008019f6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	56                   	push   %esi
  8019fa:	53                   	push   %ebx
  8019fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8019fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a04:	85 f6                	test   %esi,%esi
  801a06:	74 06                	je     801a0e <ipc_recv+0x18>
  801a08:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a0e:	85 db                	test   %ebx,%ebx
  801a10:	74 06                	je     801a18 <ipc_recv+0x22>
  801a12:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a18:	83 f8 01             	cmp    $0x1,%eax
  801a1b:	19 d2                	sbb    %edx,%edx
  801a1d:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a1f:	83 ec 0c             	sub    $0xc,%esp
  801a22:	50                   	push   %eax
  801a23:	e8 de e8 ff ff       	call   800306 <sys_ipc_recv>
  801a28:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 d2                	test   %edx,%edx
  801a2f:	75 24                	jne    801a55 <ipc_recv+0x5f>
	if (from_env_store)
  801a31:	85 f6                	test   %esi,%esi
  801a33:	74 0a                	je     801a3f <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a35:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3a:	8b 40 70             	mov    0x70(%eax),%eax
  801a3d:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a3f:	85 db                	test   %ebx,%ebx
  801a41:	74 0a                	je     801a4d <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a43:	a1 04 40 80 00       	mov    0x804004,%eax
  801a48:	8b 40 74             	mov    0x74(%eax),%eax
  801a4b:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a4d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a52:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a58:	5b                   	pop    %ebx
  801a59:	5e                   	pop    %esi
  801a5a:	5d                   	pop    %ebp
  801a5b:	c3                   	ret    

00801a5c <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	57                   	push   %edi
  801a60:	56                   	push   %esi
  801a61:	53                   	push   %ebx
  801a62:	83 ec 0c             	sub    $0xc,%esp
  801a65:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a68:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a6e:	83 fb 01             	cmp    $0x1,%ebx
  801a71:	19 c0                	sbb    %eax,%eax
  801a73:	09 c3                	or     %eax,%ebx
  801a75:	eb 1c                	jmp    801a93 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a77:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a7a:	74 12                	je     801a8e <ipc_send+0x32>
  801a7c:	50                   	push   %eax
  801a7d:	68 a0 22 80 00       	push   $0x8022a0
  801a82:	6a 36                	push   $0x36
  801a84:	68 b7 22 80 00       	push   $0x8022b7
  801a89:	e8 bd f5 ff ff       	call   80104b <_panic>
		sys_yield();
  801a8e:	e8 a4 e6 ff ff       	call   800137 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a93:	ff 75 14             	pushl  0x14(%ebp)
  801a96:	53                   	push   %ebx
  801a97:	56                   	push   %esi
  801a98:	57                   	push   %edi
  801a99:	e8 45 e8 ff ff       	call   8002e3 <sys_ipc_try_send>
		if (ret == 0) break;
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	75 d2                	jne    801a77 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801aa5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aa8:	5b                   	pop    %ebx
  801aa9:	5e                   	pop    %esi
  801aaa:	5f                   	pop    %edi
  801aab:	5d                   	pop    %ebp
  801aac:	c3                   	ret    

00801aad <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab8:	6b d0 78             	imul   $0x78,%eax,%edx
  801abb:	83 c2 50             	add    $0x50,%edx
  801abe:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ac4:	39 ca                	cmp    %ecx,%edx
  801ac6:	75 0d                	jne    801ad5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ac8:	6b c0 78             	imul   $0x78,%eax,%eax
  801acb:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ad0:	8b 40 08             	mov    0x8(%eax),%eax
  801ad3:	eb 0e                	jmp    801ae3 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ad5:	83 c0 01             	add    $0x1,%eax
  801ad8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801add:	75 d9                	jne    801ab8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801adf:	66 b8 00 00          	mov    $0x0,%ax
}
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aeb:	89 d0                	mov    %edx,%eax
  801aed:	c1 e8 16             	shr    $0x16,%eax
  801af0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801af7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afc:	f6 c1 01             	test   $0x1,%cl
  801aff:	74 1d                	je     801b1e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b01:	c1 ea 0c             	shr    $0xc,%edx
  801b04:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b0b:	f6 c2 01             	test   $0x1,%dl
  801b0e:	74 0e                	je     801b1e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b10:	c1 ea 0c             	shr    $0xc,%edx
  801b13:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b1a:	ef 
  801b1b:	0f b7 c0             	movzwl %ax,%eax
}
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

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
