
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 78             	imul   $0x78,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
  80007e:	83 c4 10             	add    $0x10,%esp
#endif
}
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 a7 04 00 00       	call   80053a <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
  80009d:	83 c4 10             	add    $0x10,%esp
}
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 0a 1e 80 00       	push   $0x801e0a
  80010c:	6a 23                	push   $0x23
  80010e:	68 27 1e 80 00       	push   $0x801e27
  800113:	e8 3b 0f 00 00       	call   801053 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 0a 1e 80 00       	push   $0x801e0a
  80018d:	6a 23                	push   $0x23
  80018f:	68 27 1e 80 00       	push   $0x801e27
  800194:	e8 ba 0e 00 00       	call   801053 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 0a 1e 80 00       	push   $0x801e0a
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 27 1e 80 00       	push   $0x801e27
  8001d6:	e8 78 0e 00 00       	call   801053 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 0a 1e 80 00       	push   $0x801e0a
  800211:	6a 23                	push   $0x23
  800213:	68 27 1e 80 00       	push   $0x801e27
  800218:	e8 36 0e 00 00       	call   801053 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 0a 1e 80 00       	push   $0x801e0a
  800253:	6a 23                	push   $0x23
  800255:	68 27 1e 80 00       	push   $0x801e27
  80025a:	e8 f4 0d 00 00       	call   801053 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 0a 1e 80 00       	push   $0x801e0a
  800295:	6a 23                	push   $0x23
  800297:	68 27 1e 80 00       	push   $0x801e27
  80029c:	e8 b2 0d 00 00       	call   801053 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 0a 1e 80 00       	push   $0x801e0a
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 27 1e 80 00       	push   $0x801e27
  8002de:	e8 70 0d 00 00       	call   801053 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 0a 1e 80 00       	push   $0x801e0a
  80033b:	6a 23                	push   $0x23
  80033d:	68 27 1e 80 00       	push   $0x801e27
  800342:	e8 0c 0d 00 00       	call   801053 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <sys_gettime>:

int sys_gettime(void)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	57                   	push   %edi
  800353:	56                   	push   %esi
  800354:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800355:	ba 00 00 00 00       	mov    $0x0,%edx
  80035a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035f:	89 d1                	mov    %edx,%ecx
  800361:	89 d3                	mov    %edx,%ebx
  800363:	89 d7                	mov    %edx,%edi
  800365:	89 d6                	mov    %edx,%esi
  800367:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800369:	5b                   	pop    %ebx
  80036a:	5e                   	pop    %esi
  80036b:	5f                   	pop    %edi
  80036c:	5d                   	pop    %ebp
  80036d:	c3                   	ret    

0080036e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800371:	8b 45 08             	mov    0x8(%ebp),%eax
  800374:	05 00 00 00 30       	add    $0x30000000,%eax
  800379:	c1 e8 0c             	shr    $0xc,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800381:	8b 45 08             	mov    0x8(%ebp),%eax
  800384:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  800389:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80038e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800393:	5d                   	pop    %ebp
  800394:	c3                   	ret    

00800395 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a0:	89 c2                	mov    %eax,%edx
  8003a2:	c1 ea 16             	shr    $0x16,%edx
  8003a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ac:	f6 c2 01             	test   $0x1,%dl
  8003af:	74 11                	je     8003c2 <fd_alloc+0x2d>
  8003b1:	89 c2                	mov    %eax,%edx
  8003b3:	c1 ea 0c             	shr    $0xc,%edx
  8003b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bd:	f6 c2 01             	test   $0x1,%dl
  8003c0:	75 09                	jne    8003cb <fd_alloc+0x36>
			*fd_store = fd;
  8003c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003c9:	eb 17                	jmp    8003e2 <fd_alloc+0x4d>
  8003cb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d5:	75 c9                	jne    8003a0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003d7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003dd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e2:	5d                   	pop    %ebp
  8003e3:	c3                   	ret    

008003e4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ea:	83 f8 1f             	cmp    $0x1f,%eax
  8003ed:	77 36                	ja     800425 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003ef:	c1 e0 0c             	shl    $0xc,%eax
  8003f2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003f7:	89 c2                	mov    %eax,%edx
  8003f9:	c1 ea 16             	shr    $0x16,%edx
  8003fc:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800403:	f6 c2 01             	test   $0x1,%dl
  800406:	74 24                	je     80042c <fd_lookup+0x48>
  800408:	89 c2                	mov    %eax,%edx
  80040a:	c1 ea 0c             	shr    $0xc,%edx
  80040d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800414:	f6 c2 01             	test   $0x1,%dl
  800417:	74 1a                	je     800433 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800419:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041c:	89 02                	mov    %eax,(%edx)
	return 0;
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	eb 13                	jmp    800438 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042a:	eb 0c                	jmp    800438 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800431:	eb 05                	jmp    800438 <fd_lookup+0x54>
  800433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800438:	5d                   	pop    %ebp
  800439:	c3                   	ret    

0080043a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800443:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800448:	eb 13                	jmp    80045d <dev_lookup+0x23>
  80044a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80044d:	39 08                	cmp    %ecx,(%eax)
  80044f:	75 0c                	jne    80045d <dev_lookup+0x23>
			*dev = devtab[i];
  800451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800454:	89 01                	mov    %eax,(%ecx)
			return 0;
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	eb 2e                	jmp    80048b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	85 c0                	test   %eax,%eax
  800461:	75 e7                	jne    80044a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800463:	a1 04 40 80 00       	mov    0x804004,%eax
  800468:	8b 40 48             	mov    0x48(%eax),%eax
  80046b:	83 ec 04             	sub    $0x4,%esp
  80046e:	51                   	push   %ecx
  80046f:	50                   	push   %eax
  800470:	68 38 1e 80 00       	push   $0x801e38
  800475:	e8 b2 0c 00 00       	call   80112c <cprintf>
	*dev = 0;
  80047a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80047d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800483:	83 c4 10             	add    $0x10,%esp
  800486:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048b:	c9                   	leave  
  80048c:	c3                   	ret    

0080048d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80048d:	55                   	push   %ebp
  80048e:	89 e5                	mov    %esp,%ebp
  800490:	56                   	push   %esi
  800491:	53                   	push   %ebx
  800492:	83 ec 10             	sub    $0x10,%esp
  800495:	8b 75 08             	mov    0x8(%ebp),%esi
  800498:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80049e:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80049f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a5:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a8:	50                   	push   %eax
  8004a9:	e8 36 ff ff ff       	call   8003e4 <fd_lookup>
  8004ae:	83 c4 08             	add    $0x8,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 05                	js     8004ba <fd_close+0x2d>
	    || fd != fd2)
  8004b5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004b8:	74 0b                	je     8004c5 <fd_close+0x38>
		return (must_exist ? r : 0);
  8004ba:	80 fb 01             	cmp    $0x1,%bl
  8004bd:	19 d2                	sbb    %edx,%edx
  8004bf:	f7 d2                	not    %edx
  8004c1:	21 d0                	and    %edx,%eax
  8004c3:	eb 41                	jmp    800506 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004cb:	50                   	push   %eax
  8004cc:	ff 36                	pushl  (%esi)
  8004ce:	e8 67 ff ff ff       	call   80043a <dev_lookup>
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	78 1a                	js     8004f6 <fd_close+0x69>
		if (dev->dev_close)
  8004dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004df:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	74 0b                	je     8004f6 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8004eb:	83 ec 0c             	sub    $0xc,%esp
  8004ee:	56                   	push   %esi
  8004ef:	ff d0                	call   *%eax
  8004f1:	89 c3                	mov    %eax,%ebx
  8004f3:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	56                   	push   %esi
  8004fa:	6a 00                	push   $0x0
  8004fc:	e8 e2 fc ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800501:	83 c4 10             	add    $0x10,%esp
  800504:	89 d8                	mov    %ebx,%eax
}
  800506:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800509:	5b                   	pop    %ebx
  80050a:	5e                   	pop    %esi
  80050b:	5d                   	pop    %ebp
  80050c:	c3                   	ret    

0080050d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80050d:	55                   	push   %ebp
  80050e:	89 e5                	mov    %esp,%ebp
  800510:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800513:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800516:	50                   	push   %eax
  800517:	ff 75 08             	pushl  0x8(%ebp)
  80051a:	e8 c5 fe ff ff       	call   8003e4 <fd_lookup>
  80051f:	89 c2                	mov    %eax,%edx
  800521:	83 c4 08             	add    $0x8,%esp
  800524:	85 d2                	test   %edx,%edx
  800526:	78 10                	js     800538 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  800528:	83 ec 08             	sub    $0x8,%esp
  80052b:	6a 01                	push   $0x1
  80052d:	ff 75 f4             	pushl  -0xc(%ebp)
  800530:	e8 58 ff ff ff       	call   80048d <fd_close>
  800535:	83 c4 10             	add    $0x10,%esp
}
  800538:	c9                   	leave  
  800539:	c3                   	ret    

0080053a <close_all>:

void
close_all(void)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	53                   	push   %ebx
  80053e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800541:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800546:	83 ec 0c             	sub    $0xc,%esp
  800549:	53                   	push   %ebx
  80054a:	e8 be ff ff ff       	call   80050d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80054f:	83 c3 01             	add    $0x1,%ebx
  800552:	83 c4 10             	add    $0x10,%esp
  800555:	83 fb 20             	cmp    $0x20,%ebx
  800558:	75 ec                	jne    800546 <close_all+0xc>
		close(i);
}
  80055a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80055d:	c9                   	leave  
  80055e:	c3                   	ret    

0080055f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80055f:	55                   	push   %ebp
  800560:	89 e5                	mov    %esp,%ebp
  800562:	57                   	push   %edi
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	83 ec 2c             	sub    $0x2c,%esp
  800568:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80056e:	50                   	push   %eax
  80056f:	ff 75 08             	pushl  0x8(%ebp)
  800572:	e8 6d fe ff ff       	call   8003e4 <fd_lookup>
  800577:	89 c2                	mov    %eax,%edx
  800579:	83 c4 08             	add    $0x8,%esp
  80057c:	85 d2                	test   %edx,%edx
  80057e:	0f 88 c1 00 00 00    	js     800645 <dup+0xe6>
		return r;
	close(newfdnum);
  800584:	83 ec 0c             	sub    $0xc,%esp
  800587:	56                   	push   %esi
  800588:	e8 80 ff ff ff       	call   80050d <close>

	newfd = INDEX2FD(newfdnum);
  80058d:	89 f3                	mov    %esi,%ebx
  80058f:	c1 e3 0c             	shl    $0xc,%ebx
  800592:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800598:	83 c4 04             	add    $0x4,%esp
  80059b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059e:	e8 db fd ff ff       	call   80037e <fd2data>
  8005a3:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a5:	89 1c 24             	mov    %ebx,(%esp)
  8005a8:	e8 d1 fd ff ff       	call   80037e <fd2data>
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b3:	89 f8                	mov    %edi,%eax
  8005b5:	c1 e8 16             	shr    $0x16,%eax
  8005b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005bf:	a8 01                	test   $0x1,%al
  8005c1:	74 37                	je     8005fa <dup+0x9b>
  8005c3:	89 f8                	mov    %edi,%eax
  8005c5:	c1 e8 0c             	shr    $0xc,%eax
  8005c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005cf:	f6 c2 01             	test   $0x1,%dl
  8005d2:	74 26                	je     8005fa <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005db:	83 ec 0c             	sub    $0xc,%esp
  8005de:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e3:	50                   	push   %eax
  8005e4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e7:	6a 00                	push   $0x0
  8005e9:	57                   	push   %edi
  8005ea:	6a 00                	push   $0x0
  8005ec:	e8 b0 fb ff ff       	call   8001a1 <sys_page_map>
  8005f1:	89 c7                	mov    %eax,%edi
  8005f3:	83 c4 20             	add    $0x20,%esp
  8005f6:	85 c0                	test   %eax,%eax
  8005f8:	78 2e                	js     800628 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fd:	89 d0                	mov    %edx,%eax
  8005ff:	c1 e8 0c             	shr    $0xc,%eax
  800602:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800609:	83 ec 0c             	sub    $0xc,%esp
  80060c:	25 07 0e 00 00       	and    $0xe07,%eax
  800611:	50                   	push   %eax
  800612:	53                   	push   %ebx
  800613:	6a 00                	push   $0x0
  800615:	52                   	push   %edx
  800616:	6a 00                	push   $0x0
  800618:	e8 84 fb ff ff       	call   8001a1 <sys_page_map>
  80061d:	89 c7                	mov    %eax,%edi
  80061f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800622:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800624:	85 ff                	test   %edi,%edi
  800626:	79 1d                	jns    800645 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800628:	83 ec 08             	sub    $0x8,%esp
  80062b:	53                   	push   %ebx
  80062c:	6a 00                	push   $0x0
  80062e:	e8 b0 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800633:	83 c4 08             	add    $0x8,%esp
  800636:	ff 75 d4             	pushl  -0x2c(%ebp)
  800639:	6a 00                	push   $0x0
  80063b:	e8 a3 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	89 f8                	mov    %edi,%eax
}
  800645:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800648:	5b                   	pop    %ebx
  800649:	5e                   	pop    %esi
  80064a:	5f                   	pop    %edi
  80064b:	5d                   	pop    %ebp
  80064c:	c3                   	ret    

0080064d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	53                   	push   %ebx
  800651:	83 ec 14             	sub    $0x14,%esp
  800654:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800657:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	53                   	push   %ebx
  80065c:	e8 83 fd ff ff       	call   8003e4 <fd_lookup>
  800661:	83 c4 08             	add    $0x8,%esp
  800664:	89 c2                	mov    %eax,%edx
  800666:	85 c0                	test   %eax,%eax
  800668:	78 6d                	js     8006d7 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066a:	83 ec 08             	sub    $0x8,%esp
  80066d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800670:	50                   	push   %eax
  800671:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800674:	ff 30                	pushl  (%eax)
  800676:	e8 bf fd ff ff       	call   80043a <dev_lookup>
  80067b:	83 c4 10             	add    $0x10,%esp
  80067e:	85 c0                	test   %eax,%eax
  800680:	78 4c                	js     8006ce <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800682:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800685:	8b 42 08             	mov    0x8(%edx),%eax
  800688:	83 e0 03             	and    $0x3,%eax
  80068b:	83 f8 01             	cmp    $0x1,%eax
  80068e:	75 21                	jne    8006b1 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800690:	a1 04 40 80 00       	mov    0x804004,%eax
  800695:	8b 40 48             	mov    0x48(%eax),%eax
  800698:	83 ec 04             	sub    $0x4,%esp
  80069b:	53                   	push   %ebx
  80069c:	50                   	push   %eax
  80069d:	68 79 1e 80 00       	push   $0x801e79
  8006a2:	e8 85 0a 00 00       	call   80112c <cprintf>
		return -E_INVAL;
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006af:	eb 26                	jmp    8006d7 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b4:	8b 40 08             	mov    0x8(%eax),%eax
  8006b7:	85 c0                	test   %eax,%eax
  8006b9:	74 17                	je     8006d2 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bb:	83 ec 04             	sub    $0x4,%esp
  8006be:	ff 75 10             	pushl  0x10(%ebp)
  8006c1:	ff 75 0c             	pushl  0xc(%ebp)
  8006c4:	52                   	push   %edx
  8006c5:	ff d0                	call   *%eax
  8006c7:	89 c2                	mov    %eax,%edx
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	eb 09                	jmp    8006d7 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ce:	89 c2                	mov    %eax,%edx
  8006d0:	eb 05                	jmp    8006d7 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d2:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d7:	89 d0                	mov    %edx,%eax
  8006d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 0c             	sub    $0xc,%esp
  8006e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ea:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f2:	eb 21                	jmp    800715 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f4:	83 ec 04             	sub    $0x4,%esp
  8006f7:	89 f0                	mov    %esi,%eax
  8006f9:	29 d8                	sub    %ebx,%eax
  8006fb:	50                   	push   %eax
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	03 45 0c             	add    0xc(%ebp),%eax
  800701:	50                   	push   %eax
  800702:	57                   	push   %edi
  800703:	e8 45 ff ff ff       	call   80064d <read>
		if (m < 0)
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	85 c0                	test   %eax,%eax
  80070d:	78 0c                	js     80071b <readn+0x3d>
			return m;
		if (m == 0)
  80070f:	85 c0                	test   %eax,%eax
  800711:	74 06                	je     800719 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800713:	01 c3                	add    %eax,%ebx
  800715:	39 f3                	cmp    %esi,%ebx
  800717:	72 db                	jb     8006f4 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800719:	89 d8                	mov    %ebx,%eax
}
  80071b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80071e:	5b                   	pop    %ebx
  80071f:	5e                   	pop    %esi
  800720:	5f                   	pop    %edi
  800721:	5d                   	pop    %ebp
  800722:	c3                   	ret    

00800723 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	53                   	push   %ebx
  800727:	83 ec 14             	sub    $0x14,%esp
  80072a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80072d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800730:	50                   	push   %eax
  800731:	53                   	push   %ebx
  800732:	e8 ad fc ff ff       	call   8003e4 <fd_lookup>
  800737:	83 c4 08             	add    $0x8,%esp
  80073a:	89 c2                	mov    %eax,%edx
  80073c:	85 c0                	test   %eax,%eax
  80073e:	78 68                	js     8007a8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800740:	83 ec 08             	sub    $0x8,%esp
  800743:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800746:	50                   	push   %eax
  800747:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074a:	ff 30                	pushl  (%eax)
  80074c:	e8 e9 fc ff ff       	call   80043a <dev_lookup>
  800751:	83 c4 10             	add    $0x10,%esp
  800754:	85 c0                	test   %eax,%eax
  800756:	78 47                	js     80079f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800758:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80075b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80075f:	75 21                	jne    800782 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800761:	a1 04 40 80 00       	mov    0x804004,%eax
  800766:	8b 40 48             	mov    0x48(%eax),%eax
  800769:	83 ec 04             	sub    $0x4,%esp
  80076c:	53                   	push   %ebx
  80076d:	50                   	push   %eax
  80076e:	68 95 1e 80 00       	push   $0x801e95
  800773:	e8 b4 09 00 00       	call   80112c <cprintf>
		return -E_INVAL;
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800780:	eb 26                	jmp    8007a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800782:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800785:	8b 52 0c             	mov    0xc(%edx),%edx
  800788:	85 d2                	test   %edx,%edx
  80078a:	74 17                	je     8007a3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80078c:	83 ec 04             	sub    $0x4,%esp
  80078f:	ff 75 10             	pushl  0x10(%ebp)
  800792:	ff 75 0c             	pushl  0xc(%ebp)
  800795:	50                   	push   %eax
  800796:	ff d2                	call   *%edx
  800798:	89 c2                	mov    %eax,%edx
  80079a:	83 c4 10             	add    $0x10,%esp
  80079d:	eb 09                	jmp    8007a8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079f:	89 c2                	mov    %eax,%edx
  8007a1:	eb 05                	jmp    8007a8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007a8:	89 d0                	mov    %edx,%eax
  8007aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <seek>:

int
seek(int fdnum, off_t offset)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007b8:	50                   	push   %eax
  8007b9:	ff 75 08             	pushl  0x8(%ebp)
  8007bc:	e8 23 fc ff ff       	call   8003e4 <fd_lookup>
  8007c1:	83 c4 08             	add    $0x8,%esp
  8007c4:	85 c0                	test   %eax,%eax
  8007c6:	78 0e                	js     8007d6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007c8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	83 ec 14             	sub    $0x14,%esp
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e5:	50                   	push   %eax
  8007e6:	53                   	push   %ebx
  8007e7:	e8 f8 fb ff ff       	call   8003e4 <fd_lookup>
  8007ec:	83 c4 08             	add    $0x8,%esp
  8007ef:	89 c2                	mov    %eax,%edx
  8007f1:	85 c0                	test   %eax,%eax
  8007f3:	78 65                	js     80085a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007fb:	50                   	push   %eax
  8007fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ff:	ff 30                	pushl  (%eax)
  800801:	e8 34 fc ff ff       	call   80043a <dev_lookup>
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	85 c0                	test   %eax,%eax
  80080b:	78 44                	js     800851 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800810:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800814:	75 21                	jne    800837 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800816:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80081b:	8b 40 48             	mov    0x48(%eax),%eax
  80081e:	83 ec 04             	sub    $0x4,%esp
  800821:	53                   	push   %ebx
  800822:	50                   	push   %eax
  800823:	68 58 1e 80 00       	push   $0x801e58
  800828:	e8 ff 08 00 00       	call   80112c <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800835:	eb 23                	jmp    80085a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800837:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083a:	8b 52 18             	mov    0x18(%edx),%edx
  80083d:	85 d2                	test   %edx,%edx
  80083f:	74 14                	je     800855 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	ff 75 0c             	pushl  0xc(%ebp)
  800847:	50                   	push   %eax
  800848:	ff d2                	call   *%edx
  80084a:	89 c2                	mov    %eax,%edx
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	eb 09                	jmp    80085a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800851:	89 c2                	mov    %eax,%edx
  800853:	eb 05                	jmp    80085a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800855:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085a:	89 d0                	mov    %edx,%eax
  80085c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80085f:	c9                   	leave  
  800860:	c3                   	ret    

00800861 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800861:	55                   	push   %ebp
  800862:	89 e5                	mov    %esp,%ebp
  800864:	53                   	push   %ebx
  800865:	83 ec 14             	sub    $0x14,%esp
  800868:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80086b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80086e:	50                   	push   %eax
  80086f:	ff 75 08             	pushl  0x8(%ebp)
  800872:	e8 6d fb ff ff       	call   8003e4 <fd_lookup>
  800877:	83 c4 08             	add    $0x8,%esp
  80087a:	89 c2                	mov    %eax,%edx
  80087c:	85 c0                	test   %eax,%eax
  80087e:	78 58                	js     8008d8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800886:	50                   	push   %eax
  800887:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088a:	ff 30                	pushl  (%eax)
  80088c:	e8 a9 fb ff ff       	call   80043a <dev_lookup>
  800891:	83 c4 10             	add    $0x10,%esp
  800894:	85 c0                	test   %eax,%eax
  800896:	78 37                	js     8008cf <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800898:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80089b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80089f:	74 32                	je     8008d3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008ab:	00 00 00 
	stat->st_isdir = 0;
  8008ae:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008b5:	00 00 00 
	stat->st_dev = dev;
  8008b8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	53                   	push   %ebx
  8008c2:	ff 75 f0             	pushl  -0x10(%ebp)
  8008c5:	ff 50 14             	call   *0x14(%eax)
  8008c8:	89 c2                	mov    %eax,%edx
  8008ca:	83 c4 10             	add    $0x10,%esp
  8008cd:	eb 09                	jmp    8008d8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cf:	89 c2                	mov    %eax,%edx
  8008d1:	eb 05                	jmp    8008d8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008d8:	89 d0                	mov    %edx,%eax
  8008da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    

008008df <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	56                   	push   %esi
  8008e3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	6a 00                	push   $0x0
  8008e9:	ff 75 08             	pushl  0x8(%ebp)
  8008ec:	e8 e7 01 00 00       	call   800ad8 <open>
  8008f1:	89 c3                	mov    %eax,%ebx
  8008f3:	83 c4 10             	add    $0x10,%esp
  8008f6:	85 db                	test   %ebx,%ebx
  8008f8:	78 1b                	js     800915 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008fa:	83 ec 08             	sub    $0x8,%esp
  8008fd:	ff 75 0c             	pushl  0xc(%ebp)
  800900:	53                   	push   %ebx
  800901:	e8 5b ff ff ff       	call   800861 <fstat>
  800906:	89 c6                	mov    %eax,%esi
	close(fd);
  800908:	89 1c 24             	mov    %ebx,(%esp)
  80090b:	e8 fd fb ff ff       	call   80050d <close>
	return r;
  800910:	83 c4 10             	add    $0x10,%esp
  800913:	89 f0                	mov    %esi,%eax
}
  800915:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	56                   	push   %esi
  800920:	53                   	push   %ebx
  800921:	89 c6                	mov    %eax,%esi
  800923:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800925:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80092c:	75 12                	jne    800940 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80092e:	83 ec 0c             	sub    $0xc,%esp
  800931:	6a 03                	push   $0x3
  800933:	e8 7d 11 00 00       	call   801ab5 <ipc_find_env>
  800938:	a3 00 40 80 00       	mov    %eax,0x804000
  80093d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800940:	6a 07                	push   $0x7
  800942:	68 00 50 80 00       	push   $0x805000
  800947:	56                   	push   %esi
  800948:	ff 35 00 40 80 00    	pushl  0x804000
  80094e:	e8 11 11 00 00       	call   801a64 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800953:	83 c4 0c             	add    $0xc,%esp
  800956:	6a 00                	push   $0x0
  800958:	53                   	push   %ebx
  800959:	6a 00                	push   $0x0
  80095b:	e8 9e 10 00 00       	call   8019fe <ipc_recv>
}
  800960:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5d                   	pop    %ebp
  800966:	c3                   	ret    

00800967 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 40 0c             	mov    0xc(%eax),%eax
  800973:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800978:	8b 45 0c             	mov    0xc(%ebp),%eax
  80097b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 02 00 00 00       	mov    $0x2,%eax
  80098a:	e8 8d ff ff ff       	call   80091c <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a7:	b8 06 00 00 00       	mov    $0x6,%eax
  8009ac:	e8 6b ff ff ff       	call   80091c <fsipc>
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	53                   	push   %ebx
  8009b7:	83 ec 04             	sub    $0x4,%esp
  8009ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d2:	e8 45 ff ff ff       	call   80091c <fsipc>
  8009d7:	89 c2                	mov    %eax,%edx
  8009d9:	85 d2                	test   %edx,%edx
  8009db:	78 2c                	js     800a09 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009dd:	83 ec 08             	sub    $0x8,%esp
  8009e0:	68 00 50 80 00       	push   $0x805000
  8009e5:	53                   	push   %ebx
  8009e6:	e8 c5 0c 00 00       	call   8016b0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009eb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a01:	83 c4 10             	add    $0x10,%esp
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	83 ec 08             	sub    $0x8,%esp
  800a14:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a17:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a1d:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a23:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a28:	76 05                	jbe    800a2f <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a2a:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a2f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a34:	83 ec 04             	sub    $0x4,%esp
  800a37:	50                   	push   %eax
  800a38:	ff 75 0c             	pushl  0xc(%ebp)
  800a3b:	68 08 50 80 00       	push   $0x805008
  800a40:	e8 fd 0d 00 00       	call   801842 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	b8 04 00 00 00       	mov    $0x4,%eax
  800a4f:	e8 c8 fe ff ff       	call   80091c <fsipc>
	return write;
}
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    

00800a56 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	56                   	push   %esi
  800a5a:	53                   	push   %ebx
  800a5b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 40 0c             	mov    0xc(%eax),%eax
  800a64:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a69:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a74:	b8 03 00 00 00       	mov    $0x3,%eax
  800a79:	e8 9e fe ff ff       	call   80091c <fsipc>
  800a7e:	89 c3                	mov    %eax,%ebx
  800a80:	85 c0                	test   %eax,%eax
  800a82:	78 4b                	js     800acf <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a84:	39 c6                	cmp    %eax,%esi
  800a86:	73 16                	jae    800a9e <devfile_read+0x48>
  800a88:	68 c4 1e 80 00       	push   $0x801ec4
  800a8d:	68 cb 1e 80 00       	push   $0x801ecb
  800a92:	6a 7c                	push   $0x7c
  800a94:	68 e0 1e 80 00       	push   $0x801ee0
  800a99:	e8 b5 05 00 00       	call   801053 <_panic>
	assert(r <= PGSIZE);
  800a9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa3:	7e 16                	jle    800abb <devfile_read+0x65>
  800aa5:	68 eb 1e 80 00       	push   $0x801eeb
  800aaa:	68 cb 1e 80 00       	push   $0x801ecb
  800aaf:	6a 7d                	push   $0x7d
  800ab1:	68 e0 1e 80 00       	push   $0x801ee0
  800ab6:	e8 98 05 00 00       	call   801053 <_panic>
	memmove(buf, &fsipcbuf, r);
  800abb:	83 ec 04             	sub    $0x4,%esp
  800abe:	50                   	push   %eax
  800abf:	68 00 50 80 00       	push   $0x805000
  800ac4:	ff 75 0c             	pushl  0xc(%ebp)
  800ac7:	e8 76 0d 00 00       	call   801842 <memmove>
	return r;
  800acc:	83 c4 10             	add    $0x10,%esp
}
  800acf:	89 d8                	mov    %ebx,%eax
  800ad1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	53                   	push   %ebx
  800adc:	83 ec 20             	sub    $0x20,%esp
  800adf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae2:	53                   	push   %ebx
  800ae3:	e8 8f 0b 00 00       	call   801677 <strlen>
  800ae8:	83 c4 10             	add    $0x10,%esp
  800aeb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af0:	7f 67                	jg     800b59 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af2:	83 ec 0c             	sub    $0xc,%esp
  800af5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af8:	50                   	push   %eax
  800af9:	e8 97 f8 ff ff       	call   800395 <fd_alloc>
  800afe:	83 c4 10             	add    $0x10,%esp
		return r;
  800b01:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b03:	85 c0                	test   %eax,%eax
  800b05:	78 57                	js     800b5e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b07:	83 ec 08             	sub    $0x8,%esp
  800b0a:	53                   	push   %ebx
  800b0b:	68 00 50 80 00       	push   $0x805000
  800b10:	e8 9b 0b 00 00       	call   8016b0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b20:	b8 01 00 00 00       	mov    $0x1,%eax
  800b25:	e8 f2 fd ff ff       	call   80091c <fsipc>
  800b2a:	89 c3                	mov    %eax,%ebx
  800b2c:	83 c4 10             	add    $0x10,%esp
  800b2f:	85 c0                	test   %eax,%eax
  800b31:	79 14                	jns    800b47 <open+0x6f>
		fd_close(fd, 0);
  800b33:	83 ec 08             	sub    $0x8,%esp
  800b36:	6a 00                	push   $0x0
  800b38:	ff 75 f4             	pushl  -0xc(%ebp)
  800b3b:	e8 4d f9 ff ff       	call   80048d <fd_close>
		return r;
  800b40:	83 c4 10             	add    $0x10,%esp
  800b43:	89 da                	mov    %ebx,%edx
  800b45:	eb 17                	jmp    800b5e <open+0x86>
	}

	return fd2num(fd);
  800b47:	83 ec 0c             	sub    $0xc,%esp
  800b4a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b4d:	e8 1c f8 ff ff       	call   80036e <fd2num>
  800b52:	89 c2                	mov    %eax,%edx
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	eb 05                	jmp    800b5e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b59:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b5e:	89 d0                	mov    %edx,%eax
  800b60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b6b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b70:	b8 08 00 00 00       	mov    $0x8,%eax
  800b75:	e8 a2 fd ff ff       	call   80091c <fsipc>
}
  800b7a:	c9                   	leave  
  800b7b:	c3                   	ret    

00800b7c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b84:	83 ec 0c             	sub    $0xc,%esp
  800b87:	ff 75 08             	pushl  0x8(%ebp)
  800b8a:	e8 ef f7 ff ff       	call   80037e <fd2data>
  800b8f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b91:	83 c4 08             	add    $0x8,%esp
  800b94:	68 f7 1e 80 00       	push   $0x801ef7
  800b99:	53                   	push   %ebx
  800b9a:	e8 11 0b 00 00       	call   8016b0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9f:	8b 56 04             	mov    0x4(%esi),%edx
  800ba2:	89 d0                	mov    %edx,%eax
  800ba4:	2b 06                	sub    (%esi),%eax
  800ba6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb3:	00 00 00 
	stat->st_dev = &devpipe;
  800bb6:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bbd:	30 80 00 
	return 0;
}
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    

00800bcc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bcc:	55                   	push   %ebp
  800bcd:	89 e5                	mov    %esp,%ebp
  800bcf:	53                   	push   %ebx
  800bd0:	83 ec 0c             	sub    $0xc,%esp
  800bd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd6:	53                   	push   %ebx
  800bd7:	6a 00                	push   $0x0
  800bd9:	e8 05 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bde:	89 1c 24             	mov    %ebx,(%esp)
  800be1:	e8 98 f7 ff ff       	call   80037e <fd2data>
  800be6:	83 c4 08             	add    $0x8,%esp
  800be9:	50                   	push   %eax
  800bea:	6a 00                	push   $0x0
  800bec:	e8 f2 f5 ff ff       	call   8001e3 <sys_page_unmap>
}
  800bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf4:	c9                   	leave  
  800bf5:	c3                   	ret    

00800bf6 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bf6:	55                   	push   %ebp
  800bf7:	89 e5                	mov    %esp,%ebp
  800bf9:	57                   	push   %edi
  800bfa:	56                   	push   %esi
  800bfb:	53                   	push   %ebx
  800bfc:	83 ec 1c             	sub    $0x1c,%esp
  800bff:	89 c7                	mov    %eax,%edi
  800c01:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c03:	a1 04 40 80 00       	mov    0x804004,%eax
  800c08:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	57                   	push   %edi
  800c0f:	e8 d9 0e 00 00       	call   801aed <pageref>
  800c14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c17:	89 34 24             	mov    %esi,(%esp)
  800c1a:	e8 ce 0e 00 00       	call   801aed <pageref>
  800c1f:	83 c4 10             	add    $0x10,%esp
  800c22:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c25:	0f 94 c0             	sete   %al
  800c28:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c2b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c31:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c34:	39 cb                	cmp    %ecx,%ebx
  800c36:	74 15                	je     800c4d <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c38:	8b 52 58             	mov    0x58(%edx),%edx
  800c3b:	50                   	push   %eax
  800c3c:	52                   	push   %edx
  800c3d:	53                   	push   %ebx
  800c3e:	68 04 1f 80 00       	push   $0x801f04
  800c43:	e8 e4 04 00 00       	call   80112c <cprintf>
  800c48:	83 c4 10             	add    $0x10,%esp
  800c4b:	eb b6                	jmp    800c03 <_pipeisclosed+0xd>
	}
}
  800c4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 28             	sub    $0x28,%esp
  800c5e:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c61:	56                   	push   %esi
  800c62:	e8 17 f7 ff ff       	call   80037e <fd2data>
  800c67:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c71:	eb 4b                	jmp    800cbe <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c73:	89 da                	mov    %ebx,%edx
  800c75:	89 f0                	mov    %esi,%eax
  800c77:	e8 7a ff ff ff       	call   800bf6 <_pipeisclosed>
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	75 48                	jne    800cc8 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c80:	e8 ba f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c85:	8b 43 04             	mov    0x4(%ebx),%eax
  800c88:	8b 0b                	mov    (%ebx),%ecx
  800c8a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c8d:	39 d0                	cmp    %edx,%eax
  800c8f:	73 e2                	jae    800c73 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c91:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c94:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c98:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c9b:	89 c2                	mov    %eax,%edx
  800c9d:	c1 fa 1f             	sar    $0x1f,%edx
  800ca0:	89 d1                	mov    %edx,%ecx
  800ca2:	c1 e9 1b             	shr    $0x1b,%ecx
  800ca5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800ca8:	83 e2 1f             	and    $0x1f,%edx
  800cab:	29 ca                	sub    %ecx,%edx
  800cad:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cb5:	83 c0 01             	add    $0x1,%eax
  800cb8:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cbb:	83 c7 01             	add    $0x1,%edi
  800cbe:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc1:	75 c2                	jne    800c85 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800cc6:	eb 05                	jmp    800ccd <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cc8:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
  800cdb:	83 ec 18             	sub    $0x18,%esp
  800cde:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce1:	57                   	push   %edi
  800ce2:	e8 97 f6 ff ff       	call   80037e <fd2data>
  800ce7:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf1:	eb 3d                	jmp    800d30 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf3:	85 db                	test   %ebx,%ebx
  800cf5:	74 04                	je     800cfb <devpipe_read+0x26>
				return i;
  800cf7:	89 d8                	mov    %ebx,%eax
  800cf9:	eb 44                	jmp    800d3f <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	89 f8                	mov    %edi,%eax
  800cff:	e8 f2 fe ff ff       	call   800bf6 <_pipeisclosed>
  800d04:	85 c0                	test   %eax,%eax
  800d06:	75 32                	jne    800d3a <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d08:	e8 32 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d0d:	8b 06                	mov    (%esi),%eax
  800d0f:	3b 46 04             	cmp    0x4(%esi),%eax
  800d12:	74 df                	je     800cf3 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d14:	99                   	cltd   
  800d15:	c1 ea 1b             	shr    $0x1b,%edx
  800d18:	01 d0                	add    %edx,%eax
  800d1a:	83 e0 1f             	and    $0x1f,%eax
  800d1d:	29 d0                	sub    %edx,%eax
  800d1f:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d2a:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d2d:	83 c3 01             	add    $0x1,%ebx
  800d30:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d33:	75 d8                	jne    800d0d <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d35:	8b 45 10             	mov    0x10(%ebp),%eax
  800d38:	eb 05                	jmp    800d3f <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d3a:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    

00800d47 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	56                   	push   %esi
  800d4b:	53                   	push   %ebx
  800d4c:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d52:	50                   	push   %eax
  800d53:	e8 3d f6 ff ff       	call   800395 <fd_alloc>
  800d58:	83 c4 10             	add    $0x10,%esp
  800d5b:	89 c2                	mov    %eax,%edx
  800d5d:	85 c0                	test   %eax,%eax
  800d5f:	0f 88 2c 01 00 00    	js     800e91 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d65:	83 ec 04             	sub    $0x4,%esp
  800d68:	68 07 04 00 00       	push   $0x407
  800d6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800d70:	6a 00                	push   $0x0
  800d72:	e8 e7 f3 ff ff       	call   80015e <sys_page_alloc>
  800d77:	83 c4 10             	add    $0x10,%esp
  800d7a:	89 c2                	mov    %eax,%edx
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	0f 88 0d 01 00 00    	js     800e91 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8a:	50                   	push   %eax
  800d8b:	e8 05 f6 ff ff       	call   800395 <fd_alloc>
  800d90:	89 c3                	mov    %eax,%ebx
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	0f 88 e2 00 00 00    	js     800e7f <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	68 07 04 00 00       	push   $0x407
  800da5:	ff 75 f0             	pushl  -0x10(%ebp)
  800da8:	6a 00                	push   $0x0
  800daa:	e8 af f3 ff ff       	call   80015e <sys_page_alloc>
  800daf:	89 c3                	mov    %eax,%ebx
  800db1:	83 c4 10             	add    $0x10,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	0f 88 c3 00 00 00    	js     800e7f <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dbc:	83 ec 0c             	sub    $0xc,%esp
  800dbf:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc2:	e8 b7 f5 ff ff       	call   80037e <fd2data>
  800dc7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc9:	83 c4 0c             	add    $0xc,%esp
  800dcc:	68 07 04 00 00       	push   $0x407
  800dd1:	50                   	push   %eax
  800dd2:	6a 00                	push   $0x0
  800dd4:	e8 85 f3 ff ff       	call   80015e <sys_page_alloc>
  800dd9:	89 c3                	mov    %eax,%ebx
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	0f 88 89 00 00 00    	js     800e6f <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de6:	83 ec 0c             	sub    $0xc,%esp
  800de9:	ff 75 f0             	pushl  -0x10(%ebp)
  800dec:	e8 8d f5 ff ff       	call   80037e <fd2data>
  800df1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df8:	50                   	push   %eax
  800df9:	6a 00                	push   $0x0
  800dfb:	56                   	push   %esi
  800dfc:	6a 00                	push   $0x0
  800dfe:	e8 9e f3 ff ff       	call   8001a1 <sys_page_map>
  800e03:	89 c3                	mov    %eax,%ebx
  800e05:	83 c4 20             	add    $0x20,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	78 55                	js     800e61 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e0c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e15:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1a:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e21:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2a:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e36:	83 ec 0c             	sub    $0xc,%esp
  800e39:	ff 75 f4             	pushl  -0xc(%ebp)
  800e3c:	e8 2d f5 ff ff       	call   80036e <fd2num>
  800e41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e44:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e46:	83 c4 04             	add    $0x4,%esp
  800e49:	ff 75 f0             	pushl  -0x10(%ebp)
  800e4c:	e8 1d f5 ff ff       	call   80036e <fd2num>
  800e51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e54:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800e5f:	eb 30                	jmp    800e91 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	56                   	push   %esi
  800e65:	6a 00                	push   $0x0
  800e67:	e8 77 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e6c:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	ff 75 f0             	pushl  -0x10(%ebp)
  800e75:	6a 00                	push   $0x0
  800e77:	e8 67 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e7c:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e7f:	83 ec 08             	sub    $0x8,%esp
  800e82:	ff 75 f4             	pushl  -0xc(%ebp)
  800e85:	6a 00                	push   $0x0
  800e87:	e8 57 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e8c:	83 c4 10             	add    $0x10,%esp
  800e8f:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e91:	89 d0                	mov    %edx,%eax
  800e93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e96:	5b                   	pop    %ebx
  800e97:	5e                   	pop    %esi
  800e98:	5d                   	pop    %ebp
  800e99:	c3                   	ret    

00800e9a <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea3:	50                   	push   %eax
  800ea4:	ff 75 08             	pushl  0x8(%ebp)
  800ea7:	e8 38 f5 ff ff       	call   8003e4 <fd_lookup>
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	83 c4 10             	add    $0x10,%esp
  800eb1:	85 d2                	test   %edx,%edx
  800eb3:	78 18                	js     800ecd <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eb5:	83 ec 0c             	sub    $0xc,%esp
  800eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebb:	e8 be f4 ff ff       	call   80037e <fd2data>
	return _pipeisclosed(fd, p);
  800ec0:	89 c2                	mov    %eax,%edx
  800ec2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec5:	e8 2c fd ff ff       	call   800bf6 <_pipeisclosed>
  800eca:	83 c4 10             	add    $0x10,%esp
}
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ed2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed7:	5d                   	pop    %ebp
  800ed8:	c3                   	ret    

00800ed9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ed9:	55                   	push   %ebp
  800eda:	89 e5                	mov    %esp,%ebp
  800edc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800edf:	68 35 1f 80 00       	push   $0x801f35
  800ee4:	ff 75 0c             	pushl  0xc(%ebp)
  800ee7:	e8 c4 07 00 00       	call   8016b0 <strcpy>
	return 0;
}
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	57                   	push   %edi
  800ef7:	56                   	push   %esi
  800ef8:	53                   	push   %ebx
  800ef9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eff:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f04:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0a:	eb 2e                	jmp    800f3a <devcons_write+0x47>
		m = n - tot;
  800f0c:	8b 55 10             	mov    0x10(%ebp),%edx
  800f0f:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f11:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f16:	83 fa 7f             	cmp    $0x7f,%edx
  800f19:	77 02                	ja     800f1d <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f1b:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f1d:	83 ec 04             	sub    $0x4,%esp
  800f20:	56                   	push   %esi
  800f21:	03 45 0c             	add    0xc(%ebp),%eax
  800f24:	50                   	push   %eax
  800f25:	57                   	push   %edi
  800f26:	e8 17 09 00 00       	call   801842 <memmove>
		sys_cputs(buf, m);
  800f2b:	83 c4 08             	add    $0x8,%esp
  800f2e:	56                   	push   %esi
  800f2f:	57                   	push   %edi
  800f30:	e8 6d f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f35:	01 f3                	add    %esi,%ebx
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	89 d8                	mov    %ebx,%eax
  800f3c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f3f:	72 cb                	jb     800f0c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f44:	5b                   	pop    %ebx
  800f45:	5e                   	pop    %esi
  800f46:	5f                   	pop    %edi
  800f47:	5d                   	pop    %ebp
  800f48:	c3                   	ret    

00800f49 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f49:	55                   	push   %ebp
  800f4a:	89 e5                	mov    %esp,%ebp
  800f4c:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f4f:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f54:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f58:	75 07                	jne    800f61 <devcons_read+0x18>
  800f5a:	eb 28                	jmp    800f84 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f5c:	e8 de f1 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f61:	e8 5a f1 ff ff       	call   8000c0 <sys_cgetc>
  800f66:	85 c0                	test   %eax,%eax
  800f68:	74 f2                	je     800f5c <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f6a:	85 c0                	test   %eax,%eax
  800f6c:	78 16                	js     800f84 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f6e:	83 f8 04             	cmp    $0x4,%eax
  800f71:	74 0c                	je     800f7f <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f76:	88 02                	mov    %al,(%edx)
	return 1;
  800f78:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7d:	eb 05                	jmp    800f84 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f7f:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f8c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8f:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f92:	6a 01                	push   $0x1
  800f94:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f97:	50                   	push   %eax
  800f98:	e8 05 f1 ff ff       	call   8000a2 <sys_cputs>
  800f9d:	83 c4 10             	add    $0x10,%esp
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <getchar>:

int
getchar(void)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fa8:	6a 01                	push   $0x1
  800faa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fad:	50                   	push   %eax
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 98 f6 ff ff       	call   80064d <read>
	if (r < 0)
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 0f                	js     800fcb <getchar+0x29>
		return r;
	if (r < 1)
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	7e 06                	jle    800fc6 <getchar+0x24>
		return -E_EOF;
	return c;
  800fc0:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc4:	eb 05                	jmp    800fcb <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fc6:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fcb:	c9                   	leave  
  800fcc:	c3                   	ret    

00800fcd <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd6:	50                   	push   %eax
  800fd7:	ff 75 08             	pushl  0x8(%ebp)
  800fda:	e8 05 f4 ff ff       	call   8003e4 <fd_lookup>
  800fdf:	83 c4 10             	add    $0x10,%esp
  800fe2:	85 c0                	test   %eax,%eax
  800fe4:	78 11                	js     800ff7 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fef:	39 10                	cmp    %edx,(%eax)
  800ff1:	0f 94 c0             	sete   %al
  800ff4:	0f b6 c0             	movzbl %al,%eax
}
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <opencons>:

int
opencons(void)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801002:	50                   	push   %eax
  801003:	e8 8d f3 ff ff       	call   800395 <fd_alloc>
  801008:	83 c4 10             	add    $0x10,%esp
		return r;
  80100b:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 3e                	js     80104f <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801011:	83 ec 04             	sub    $0x4,%esp
  801014:	68 07 04 00 00       	push   $0x407
  801019:	ff 75 f4             	pushl  -0xc(%ebp)
  80101c:	6a 00                	push   $0x0
  80101e:	e8 3b f1 ff ff       	call   80015e <sys_page_alloc>
  801023:	83 c4 10             	add    $0x10,%esp
		return r;
  801026:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801028:	85 c0                	test   %eax,%eax
  80102a:	78 23                	js     80104f <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80102c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801032:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801035:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	50                   	push   %eax
  801045:	e8 24 f3 ff ff       	call   80036e <fd2num>
  80104a:	89 c2                	mov    %eax,%edx
  80104c:	83 c4 10             	add    $0x10,%esp
}
  80104f:	89 d0                	mov    %edx,%eax
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	56                   	push   %esi
  801057:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801058:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80105b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801061:	e8 ba f0 ff ff       	call   800120 <sys_getenvid>
  801066:	83 ec 0c             	sub    $0xc,%esp
  801069:	ff 75 0c             	pushl  0xc(%ebp)
  80106c:	ff 75 08             	pushl  0x8(%ebp)
  80106f:	56                   	push   %esi
  801070:	50                   	push   %eax
  801071:	68 44 1f 80 00       	push   $0x801f44
  801076:	e8 b1 00 00 00       	call   80112c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80107b:	83 c4 18             	add    $0x18,%esp
  80107e:	53                   	push   %ebx
  80107f:	ff 75 10             	pushl  0x10(%ebp)
  801082:	e8 54 00 00 00       	call   8010db <vcprintf>
	cprintf("\n");
  801087:	c7 04 24 93 1e 80 00 	movl   $0x801e93,(%esp)
  80108e:	e8 99 00 00 00       	call   80112c <cprintf>
  801093:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801096:	cc                   	int3   
  801097:	eb fd                	jmp    801096 <_panic+0x43>

00801099 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	53                   	push   %ebx
  80109d:	83 ec 04             	sub    $0x4,%esp
  8010a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a3:	8b 13                	mov    (%ebx),%edx
  8010a5:	8d 42 01             	lea    0x1(%edx),%eax
  8010a8:	89 03                	mov    %eax,(%ebx)
  8010aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ad:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010b6:	75 1a                	jne    8010d2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010b8:	83 ec 08             	sub    $0x8,%esp
  8010bb:	68 ff 00 00 00       	push   $0xff
  8010c0:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c3:	50                   	push   %eax
  8010c4:	e8 d9 ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010cf:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010d2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010eb:	00 00 00 
	b.cnt = 0;
  8010ee:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f8:	ff 75 0c             	pushl  0xc(%ebp)
  8010fb:	ff 75 08             	pushl  0x8(%ebp)
  8010fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801104:	50                   	push   %eax
  801105:	68 99 10 80 00       	push   $0x801099
  80110a:	e8 4f 01 00 00       	call   80125e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80110f:	83 c4 08             	add    $0x8,%esp
  801112:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801118:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80111e:	50                   	push   %eax
  80111f:	e8 7e ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  801124:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80112a:	c9                   	leave  
  80112b:	c3                   	ret    

0080112c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80112c:	55                   	push   %ebp
  80112d:	89 e5                	mov    %esp,%ebp
  80112f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801132:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801135:	50                   	push   %eax
  801136:	ff 75 08             	pushl  0x8(%ebp)
  801139:	e8 9d ff ff ff       	call   8010db <vcprintf>
	va_end(ap);

	return cnt;
}
  80113e:	c9                   	leave  
  80113f:	c3                   	ret    

00801140 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 1c             	sub    $0x1c,%esp
  801149:	89 c7                	mov    %eax,%edi
  80114b:	89 d6                	mov    %edx,%esi
  80114d:	8b 45 08             	mov    0x8(%ebp),%eax
  801150:	8b 55 0c             	mov    0xc(%ebp),%edx
  801153:	89 d1                	mov    %edx,%ecx
  801155:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801158:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80115b:	8b 45 10             	mov    0x10(%ebp),%eax
  80115e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801161:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801164:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80116b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80116e:	72 05                	jb     801175 <printnum+0x35>
  801170:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801173:	77 3e                	ja     8011b3 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801175:	83 ec 0c             	sub    $0xc,%esp
  801178:	ff 75 18             	pushl  0x18(%ebp)
  80117b:	83 eb 01             	sub    $0x1,%ebx
  80117e:	53                   	push   %ebx
  80117f:	50                   	push   %eax
  801180:	83 ec 08             	sub    $0x8,%esp
  801183:	ff 75 e4             	pushl  -0x1c(%ebp)
  801186:	ff 75 e0             	pushl  -0x20(%ebp)
  801189:	ff 75 dc             	pushl  -0x24(%ebp)
  80118c:	ff 75 d8             	pushl  -0x28(%ebp)
  80118f:	e8 9c 09 00 00       	call   801b30 <__udivdi3>
  801194:	83 c4 18             	add    $0x18,%esp
  801197:	52                   	push   %edx
  801198:	50                   	push   %eax
  801199:	89 f2                	mov    %esi,%edx
  80119b:	89 f8                	mov    %edi,%eax
  80119d:	e8 9e ff ff ff       	call   801140 <printnum>
  8011a2:	83 c4 20             	add    $0x20,%esp
  8011a5:	eb 13                	jmp    8011ba <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	56                   	push   %esi
  8011ab:	ff 75 18             	pushl  0x18(%ebp)
  8011ae:	ff d7                	call   *%edi
  8011b0:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011b3:	83 eb 01             	sub    $0x1,%ebx
  8011b6:	85 db                	test   %ebx,%ebx
  8011b8:	7f ed                	jg     8011a7 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011ba:	83 ec 08             	sub    $0x8,%esp
  8011bd:	56                   	push   %esi
  8011be:	83 ec 04             	sub    $0x4,%esp
  8011c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8011cd:	e8 8e 0a 00 00       	call   801c60 <__umoddi3>
  8011d2:	83 c4 14             	add    $0x14,%esp
  8011d5:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011dc:	50                   	push   %eax
  8011dd:	ff d7                	call   *%edi
  8011df:	83 c4 10             	add    $0x10,%esp
}
  8011e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5e                   	pop    %esi
  8011e7:	5f                   	pop    %edi
  8011e8:	5d                   	pop    %ebp
  8011e9:	c3                   	ret    

008011ea <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ea:	55                   	push   %ebp
  8011eb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011ed:	83 fa 01             	cmp    $0x1,%edx
  8011f0:	7e 0e                	jle    801200 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011f2:	8b 10                	mov    (%eax),%edx
  8011f4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011f7:	89 08                	mov    %ecx,(%eax)
  8011f9:	8b 02                	mov    (%edx),%eax
  8011fb:	8b 52 04             	mov    0x4(%edx),%edx
  8011fe:	eb 22                	jmp    801222 <getuint+0x38>
	else if (lflag)
  801200:	85 d2                	test   %edx,%edx
  801202:	74 10                	je     801214 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801204:	8b 10                	mov    (%eax),%edx
  801206:	8d 4a 04             	lea    0x4(%edx),%ecx
  801209:	89 08                	mov    %ecx,(%eax)
  80120b:	8b 02                	mov    (%edx),%eax
  80120d:	ba 00 00 00 00       	mov    $0x0,%edx
  801212:	eb 0e                	jmp    801222 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801214:	8b 10                	mov    (%eax),%edx
  801216:	8d 4a 04             	lea    0x4(%edx),%ecx
  801219:	89 08                	mov    %ecx,(%eax)
  80121b:	8b 02                	mov    (%edx),%eax
  80121d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80122a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80122e:	8b 10                	mov    (%eax),%edx
  801230:	3b 50 04             	cmp    0x4(%eax),%edx
  801233:	73 0a                	jae    80123f <sprintputch+0x1b>
		*b->buf++ = ch;
  801235:	8d 4a 01             	lea    0x1(%edx),%ecx
  801238:	89 08                	mov    %ecx,(%eax)
  80123a:	8b 45 08             	mov    0x8(%ebp),%eax
  80123d:	88 02                	mov    %al,(%edx)
}
  80123f:	5d                   	pop    %ebp
  801240:	c3                   	ret    

00801241 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801247:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80124a:	50                   	push   %eax
  80124b:	ff 75 10             	pushl  0x10(%ebp)
  80124e:	ff 75 0c             	pushl  0xc(%ebp)
  801251:	ff 75 08             	pushl  0x8(%ebp)
  801254:	e8 05 00 00 00       	call   80125e <vprintfmt>
	va_end(ap);
  801259:	83 c4 10             	add    $0x10,%esp
}
  80125c:	c9                   	leave  
  80125d:	c3                   	ret    

0080125e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80125e:	55                   	push   %ebp
  80125f:	89 e5                	mov    %esp,%ebp
  801261:	57                   	push   %edi
  801262:	56                   	push   %esi
  801263:	53                   	push   %ebx
  801264:	83 ec 2c             	sub    $0x2c,%esp
  801267:	8b 75 08             	mov    0x8(%ebp),%esi
  80126a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80126d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801270:	eb 12                	jmp    801284 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801272:	85 c0                	test   %eax,%eax
  801274:	0f 84 8d 03 00 00    	je     801607 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	53                   	push   %ebx
  80127e:	50                   	push   %eax
  80127f:	ff d6                	call   *%esi
  801281:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801284:	83 c7 01             	add    $0x1,%edi
  801287:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80128b:	83 f8 25             	cmp    $0x25,%eax
  80128e:	75 e2                	jne    801272 <vprintfmt+0x14>
  801290:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801294:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80129b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ae:	eb 07                	jmp    8012b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012b3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b7:	8d 47 01             	lea    0x1(%edi),%eax
  8012ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012bd:	0f b6 07             	movzbl (%edi),%eax
  8012c0:	0f b6 c8             	movzbl %al,%ecx
  8012c3:	83 e8 23             	sub    $0x23,%eax
  8012c6:	3c 55                	cmp    $0x55,%al
  8012c8:	0f 87 1e 03 00 00    	ja     8015ec <vprintfmt+0x38e>
  8012ce:	0f b6 c0             	movzbl %al,%eax
  8012d1:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012db:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012df:	eb d6                	jmp    8012b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012ef:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012f3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012f6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012f9:	83 fa 09             	cmp    $0x9,%edx
  8012fc:	77 38                	ja     801336 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801301:	eb e9                	jmp    8012ec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801303:	8b 45 14             	mov    0x14(%ebp),%eax
  801306:	8d 48 04             	lea    0x4(%eax),%ecx
  801309:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80130c:	8b 00                	mov    (%eax),%eax
  80130e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801314:	eb 26                	jmp    80133c <vprintfmt+0xde>
  801316:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801319:	89 c8                	mov    %ecx,%eax
  80131b:	c1 f8 1f             	sar    $0x1f,%eax
  80131e:	f7 d0                	not    %eax
  801320:	21 c1                	and    %eax,%ecx
  801322:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801328:	eb 8d                	jmp    8012b7 <vprintfmt+0x59>
  80132a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80132d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801334:	eb 81                	jmp    8012b7 <vprintfmt+0x59>
  801336:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801339:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80133c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801340:	0f 89 71 ff ff ff    	jns    8012b7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801346:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801349:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80134c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801353:	e9 5f ff ff ff       	jmp    8012b7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801358:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80135e:	e9 54 ff ff ff       	jmp    8012b7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801363:	8b 45 14             	mov    0x14(%ebp),%eax
  801366:	8d 50 04             	lea    0x4(%eax),%edx
  801369:	89 55 14             	mov    %edx,0x14(%ebp)
  80136c:	83 ec 08             	sub    $0x8,%esp
  80136f:	53                   	push   %ebx
  801370:	ff 30                	pushl  (%eax)
  801372:	ff d6                	call   *%esi
			break;
  801374:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801377:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80137a:	e9 05 ff ff ff       	jmp    801284 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80137f:	8b 45 14             	mov    0x14(%ebp),%eax
  801382:	8d 50 04             	lea    0x4(%eax),%edx
  801385:	89 55 14             	mov    %edx,0x14(%ebp)
  801388:	8b 00                	mov    (%eax),%eax
  80138a:	99                   	cltd   
  80138b:	31 d0                	xor    %edx,%eax
  80138d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80138f:	83 f8 0f             	cmp    $0xf,%eax
  801392:	7f 0b                	jg     80139f <vprintfmt+0x141>
  801394:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80139b:	85 d2                	test   %edx,%edx
  80139d:	75 18                	jne    8013b7 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80139f:	50                   	push   %eax
  8013a0:	68 7f 1f 80 00       	push   $0x801f7f
  8013a5:	53                   	push   %ebx
  8013a6:	56                   	push   %esi
  8013a7:	e8 95 fe ff ff       	call   801241 <printfmt>
  8013ac:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013b2:	e9 cd fe ff ff       	jmp    801284 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013b7:	52                   	push   %edx
  8013b8:	68 dd 1e 80 00       	push   $0x801edd
  8013bd:	53                   	push   %ebx
  8013be:	56                   	push   %esi
  8013bf:	e8 7d fe ff ff       	call   801241 <printfmt>
  8013c4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ca:	e9 b5 fe ff ff       	jmp    801284 <vprintfmt+0x26>
  8013cf:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013db:	8d 50 04             	lea    0x4(%eax),%edx
  8013de:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e1:	8b 38                	mov    (%eax),%edi
  8013e3:	85 ff                	test   %edi,%edi
  8013e5:	75 05                	jne    8013ec <vprintfmt+0x18e>
				p = "(null)";
  8013e7:	bf 78 1f 80 00       	mov    $0x801f78,%edi
			if (width > 0 && padc != '-')
  8013ec:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013f0:	0f 84 91 00 00 00    	je     801487 <vprintfmt+0x229>
  8013f6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8013fa:	0f 8e 95 00 00 00    	jle    801495 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	51                   	push   %ecx
  801404:	57                   	push   %edi
  801405:	e8 85 02 00 00       	call   80168f <strnlen>
  80140a:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80140d:	29 c1                	sub    %eax,%ecx
  80140f:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801412:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801415:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801419:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80141c:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80141f:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801421:	eb 0f                	jmp    801432 <vprintfmt+0x1d4>
					putch(padc, putdat);
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	53                   	push   %ebx
  801427:	ff 75 e0             	pushl  -0x20(%ebp)
  80142a:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80142c:	83 ef 01             	sub    $0x1,%edi
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	85 ff                	test   %edi,%edi
  801434:	7f ed                	jg     801423 <vprintfmt+0x1c5>
  801436:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801439:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80143c:	89 c8                	mov    %ecx,%eax
  80143e:	c1 f8 1f             	sar    $0x1f,%eax
  801441:	f7 d0                	not    %eax
  801443:	21 c8                	and    %ecx,%eax
  801445:	29 c1                	sub    %eax,%ecx
  801447:	89 75 08             	mov    %esi,0x8(%ebp)
  80144a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80144d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801450:	89 cb                	mov    %ecx,%ebx
  801452:	eb 4d                	jmp    8014a1 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801454:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801458:	74 1b                	je     801475 <vprintfmt+0x217>
  80145a:	0f be c0             	movsbl %al,%eax
  80145d:	83 e8 20             	sub    $0x20,%eax
  801460:	83 f8 5e             	cmp    $0x5e,%eax
  801463:	76 10                	jbe    801475 <vprintfmt+0x217>
					putch('?', putdat);
  801465:	83 ec 08             	sub    $0x8,%esp
  801468:	ff 75 0c             	pushl  0xc(%ebp)
  80146b:	6a 3f                	push   $0x3f
  80146d:	ff 55 08             	call   *0x8(%ebp)
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	eb 0d                	jmp    801482 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  801475:	83 ec 08             	sub    $0x8,%esp
  801478:	ff 75 0c             	pushl  0xc(%ebp)
  80147b:	52                   	push   %edx
  80147c:	ff 55 08             	call   *0x8(%ebp)
  80147f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801482:	83 eb 01             	sub    $0x1,%ebx
  801485:	eb 1a                	jmp    8014a1 <vprintfmt+0x243>
  801487:	89 75 08             	mov    %esi,0x8(%ebp)
  80148a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80148d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801490:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801493:	eb 0c                	jmp    8014a1 <vprintfmt+0x243>
  801495:	89 75 08             	mov    %esi,0x8(%ebp)
  801498:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80149b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80149e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a1:	83 c7 01             	add    $0x1,%edi
  8014a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014a8:	0f be d0             	movsbl %al,%edx
  8014ab:	85 d2                	test   %edx,%edx
  8014ad:	74 23                	je     8014d2 <vprintfmt+0x274>
  8014af:	85 f6                	test   %esi,%esi
  8014b1:	78 a1                	js     801454 <vprintfmt+0x1f6>
  8014b3:	83 ee 01             	sub    $0x1,%esi
  8014b6:	79 9c                	jns    801454 <vprintfmt+0x1f6>
  8014b8:	89 df                	mov    %ebx,%edi
  8014ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8014bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c0:	eb 18                	jmp    8014da <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014c2:	83 ec 08             	sub    $0x8,%esp
  8014c5:	53                   	push   %ebx
  8014c6:	6a 20                	push   $0x20
  8014c8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014ca:	83 ef 01             	sub    $0x1,%edi
  8014cd:	83 c4 10             	add    $0x10,%esp
  8014d0:	eb 08                	jmp    8014da <vprintfmt+0x27c>
  8014d2:	89 df                	mov    %ebx,%edi
  8014d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014da:	85 ff                	test   %edi,%edi
  8014dc:	7f e4                	jg     8014c2 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e1:	e9 9e fd ff ff       	jmp    801284 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014e6:	83 fa 01             	cmp    $0x1,%edx
  8014e9:	7e 16                	jle    801501 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ee:	8d 50 08             	lea    0x8(%eax),%edx
  8014f1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f4:	8b 50 04             	mov    0x4(%eax),%edx
  8014f7:	8b 00                	mov    (%eax),%eax
  8014f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014ff:	eb 32                	jmp    801533 <vprintfmt+0x2d5>
	else if (lflag)
  801501:	85 d2                	test   %edx,%edx
  801503:	74 18                	je     80151d <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  801505:	8b 45 14             	mov    0x14(%ebp),%eax
  801508:	8d 50 04             	lea    0x4(%eax),%edx
  80150b:	89 55 14             	mov    %edx,0x14(%ebp)
  80150e:	8b 00                	mov    (%eax),%eax
  801510:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801513:	89 c1                	mov    %eax,%ecx
  801515:	c1 f9 1f             	sar    $0x1f,%ecx
  801518:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80151b:	eb 16                	jmp    801533 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  80151d:	8b 45 14             	mov    0x14(%ebp),%eax
  801520:	8d 50 04             	lea    0x4(%eax),%edx
  801523:	89 55 14             	mov    %edx,0x14(%ebp)
  801526:	8b 00                	mov    (%eax),%eax
  801528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80152b:	89 c1                	mov    %eax,%ecx
  80152d:	c1 f9 1f             	sar    $0x1f,%ecx
  801530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801533:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801536:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801539:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80153e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801542:	79 74                	jns    8015b8 <vprintfmt+0x35a>
				putch('-', putdat);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	53                   	push   %ebx
  801548:	6a 2d                	push   $0x2d
  80154a:	ff d6                	call   *%esi
				num = -(long long) num;
  80154c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80154f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801552:	f7 d8                	neg    %eax
  801554:	83 d2 00             	adc    $0x0,%edx
  801557:	f7 da                	neg    %edx
  801559:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80155c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801561:	eb 55                	jmp    8015b8 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801563:	8d 45 14             	lea    0x14(%ebp),%eax
  801566:	e8 7f fc ff ff       	call   8011ea <getuint>
			base = 10;
  80156b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801570:	eb 46                	jmp    8015b8 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801572:	8d 45 14             	lea    0x14(%ebp),%eax
  801575:	e8 70 fc ff ff       	call   8011ea <getuint>
			base = 8;
  80157a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80157f:	eb 37                	jmp    8015b8 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	6a 30                	push   $0x30
  801587:	ff d6                	call   *%esi
			putch('x', putdat);
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 78                	push   $0x78
  80158f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801591:	8b 45 14             	mov    0x14(%ebp),%eax
  801594:	8d 50 04             	lea    0x4(%eax),%edx
  801597:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80159a:	8b 00                	mov    (%eax),%eax
  80159c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015a4:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015a9:	eb 0d                	jmp    8015b8 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ae:	e8 37 fc ff ff       	call   8011ea <getuint>
			base = 16;
  8015b3:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015b8:	83 ec 0c             	sub    $0xc,%esp
  8015bb:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015bf:	57                   	push   %edi
  8015c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c3:	51                   	push   %ecx
  8015c4:	52                   	push   %edx
  8015c5:	50                   	push   %eax
  8015c6:	89 da                	mov    %ebx,%edx
  8015c8:	89 f0                	mov    %esi,%eax
  8015ca:	e8 71 fb ff ff       	call   801140 <printnum>
			break;
  8015cf:	83 c4 20             	add    $0x20,%esp
  8015d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015d5:	e9 aa fc ff ff       	jmp    801284 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015da:	83 ec 08             	sub    $0x8,%esp
  8015dd:	53                   	push   %ebx
  8015de:	51                   	push   %ecx
  8015df:	ff d6                	call   *%esi
			break;
  8015e1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015e7:	e9 98 fc ff ff       	jmp    801284 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	53                   	push   %ebx
  8015f0:	6a 25                	push   $0x25
  8015f2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	eb 03                	jmp    8015fc <vprintfmt+0x39e>
  8015f9:	83 ef 01             	sub    $0x1,%edi
  8015fc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801600:	75 f7                	jne    8015f9 <vprintfmt+0x39b>
  801602:	e9 7d fc ff ff       	jmp    801284 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801607:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160a:	5b                   	pop    %ebx
  80160b:	5e                   	pop    %esi
  80160c:	5f                   	pop    %edi
  80160d:	5d                   	pop    %ebp
  80160e:	c3                   	ret    

0080160f <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160f:	55                   	push   %ebp
  801610:	89 e5                	mov    %esp,%ebp
  801612:	83 ec 18             	sub    $0x18,%esp
  801615:	8b 45 08             	mov    0x8(%ebp),%eax
  801618:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80161b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801622:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801625:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80162c:	85 c0                	test   %eax,%eax
  80162e:	74 26                	je     801656 <vsnprintf+0x47>
  801630:	85 d2                	test   %edx,%edx
  801632:	7e 22                	jle    801656 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801634:	ff 75 14             	pushl  0x14(%ebp)
  801637:	ff 75 10             	pushl  0x10(%ebp)
  80163a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80163d:	50                   	push   %eax
  80163e:	68 24 12 80 00       	push   $0x801224
  801643:	e8 16 fc ff ff       	call   80125e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801648:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80164b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80164e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801651:	83 c4 10             	add    $0x10,%esp
  801654:	eb 05                	jmp    80165b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801656:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801663:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801666:	50                   	push   %eax
  801667:	ff 75 10             	pushl  0x10(%ebp)
  80166a:	ff 75 0c             	pushl  0xc(%ebp)
  80166d:	ff 75 08             	pushl  0x8(%ebp)
  801670:	e8 9a ff ff ff       	call   80160f <vsnprintf>
	va_end(ap);

	return rc;
}
  801675:	c9                   	leave  
  801676:	c3                   	ret    

00801677 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80167d:	b8 00 00 00 00       	mov    $0x0,%eax
  801682:	eb 03                	jmp    801687 <strlen+0x10>
		n++;
  801684:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801687:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80168b:	75 f7                	jne    801684 <strlen+0xd>
		n++;
	return n;
}
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801695:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801698:	ba 00 00 00 00       	mov    $0x0,%edx
  80169d:	eb 03                	jmp    8016a2 <strnlen+0x13>
		n++;
  80169f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a2:	39 c2                	cmp    %eax,%edx
  8016a4:	74 08                	je     8016ae <strnlen+0x1f>
  8016a6:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016aa:	75 f3                	jne    80169f <strnlen+0x10>
  8016ac:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016ae:	5d                   	pop    %ebp
  8016af:	c3                   	ret    

008016b0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	53                   	push   %ebx
  8016b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ba:	89 c2                	mov    %eax,%edx
  8016bc:	83 c2 01             	add    $0x1,%edx
  8016bf:	83 c1 01             	add    $0x1,%ecx
  8016c2:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016c6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016c9:	84 db                	test   %bl,%bl
  8016cb:	75 ef                	jne    8016bc <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016cd:	5b                   	pop    %ebx
  8016ce:	5d                   	pop    %ebp
  8016cf:	c3                   	ret    

008016d0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d0:	55                   	push   %ebp
  8016d1:	89 e5                	mov    %esp,%ebp
  8016d3:	53                   	push   %ebx
  8016d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d7:	53                   	push   %ebx
  8016d8:	e8 9a ff ff ff       	call   801677 <strlen>
  8016dd:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	01 d8                	add    %ebx,%eax
  8016e5:	50                   	push   %eax
  8016e6:	e8 c5 ff ff ff       	call   8016b0 <strcpy>
	return dst;
}
  8016eb:	89 d8                	mov    %ebx,%eax
  8016ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	56                   	push   %esi
  8016f6:	53                   	push   %ebx
  8016f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016fd:	89 f3                	mov    %esi,%ebx
  8016ff:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801702:	89 f2                	mov    %esi,%edx
  801704:	eb 0f                	jmp    801715 <strncpy+0x23>
		*dst++ = *src;
  801706:	83 c2 01             	add    $0x1,%edx
  801709:	0f b6 01             	movzbl (%ecx),%eax
  80170c:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80170f:	80 39 01             	cmpb   $0x1,(%ecx)
  801712:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801715:	39 da                	cmp    %ebx,%edx
  801717:	75 ed                	jne    801706 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801719:	89 f0                	mov    %esi,%eax
  80171b:	5b                   	pop    %ebx
  80171c:	5e                   	pop    %esi
  80171d:	5d                   	pop    %ebp
  80171e:	c3                   	ret    

0080171f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	56                   	push   %esi
  801723:	53                   	push   %ebx
  801724:	8b 75 08             	mov    0x8(%ebp),%esi
  801727:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172a:	8b 55 10             	mov    0x10(%ebp),%edx
  80172d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80172f:	85 d2                	test   %edx,%edx
  801731:	74 21                	je     801754 <strlcpy+0x35>
  801733:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801737:	89 f2                	mov    %esi,%edx
  801739:	eb 09                	jmp    801744 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80173b:	83 c2 01             	add    $0x1,%edx
  80173e:	83 c1 01             	add    $0x1,%ecx
  801741:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801744:	39 c2                	cmp    %eax,%edx
  801746:	74 09                	je     801751 <strlcpy+0x32>
  801748:	0f b6 19             	movzbl (%ecx),%ebx
  80174b:	84 db                	test   %bl,%bl
  80174d:	75 ec                	jne    80173b <strlcpy+0x1c>
  80174f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801751:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801754:	29 f0                	sub    %esi,%eax
}
  801756:	5b                   	pop    %ebx
  801757:	5e                   	pop    %esi
  801758:	5d                   	pop    %ebp
  801759:	c3                   	ret    

0080175a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801760:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801763:	eb 06                	jmp    80176b <strcmp+0x11>
		p++, q++;
  801765:	83 c1 01             	add    $0x1,%ecx
  801768:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80176b:	0f b6 01             	movzbl (%ecx),%eax
  80176e:	84 c0                	test   %al,%al
  801770:	74 04                	je     801776 <strcmp+0x1c>
  801772:	3a 02                	cmp    (%edx),%al
  801774:	74 ef                	je     801765 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801776:	0f b6 c0             	movzbl %al,%eax
  801779:	0f b6 12             	movzbl (%edx),%edx
  80177c:	29 d0                	sub    %edx,%eax
}
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	8b 45 08             	mov    0x8(%ebp),%eax
  801787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178a:	89 c3                	mov    %eax,%ebx
  80178c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80178f:	eb 06                	jmp    801797 <strncmp+0x17>
		n--, p++, q++;
  801791:	83 c0 01             	add    $0x1,%eax
  801794:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801797:	39 d8                	cmp    %ebx,%eax
  801799:	74 15                	je     8017b0 <strncmp+0x30>
  80179b:	0f b6 08             	movzbl (%eax),%ecx
  80179e:	84 c9                	test   %cl,%cl
  8017a0:	74 04                	je     8017a6 <strncmp+0x26>
  8017a2:	3a 0a                	cmp    (%edx),%cl
  8017a4:	74 eb                	je     801791 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a6:	0f b6 00             	movzbl (%eax),%eax
  8017a9:	0f b6 12             	movzbl (%edx),%edx
  8017ac:	29 d0                	sub    %edx,%eax
  8017ae:	eb 05                	jmp    8017b5 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b0:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017b5:	5b                   	pop    %ebx
  8017b6:	5d                   	pop    %ebp
  8017b7:	c3                   	ret    

008017b8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c2:	eb 07                	jmp    8017cb <strchr+0x13>
		if (*s == c)
  8017c4:	38 ca                	cmp    %cl,%dl
  8017c6:	74 0f                	je     8017d7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017c8:	83 c0 01             	add    $0x1,%eax
  8017cb:	0f b6 10             	movzbl (%eax),%edx
  8017ce:	84 d2                	test   %dl,%dl
  8017d0:	75 f2                	jne    8017c4 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e3:	eb 03                	jmp    8017e8 <strfind+0xf>
  8017e5:	83 c0 01             	add    $0x1,%eax
  8017e8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017eb:	84 d2                	test   %dl,%dl
  8017ed:	74 04                	je     8017f3 <strfind+0x1a>
  8017ef:	38 ca                	cmp    %cl,%dl
  8017f1:	75 f2                	jne    8017e5 <strfind+0xc>
			break;
	return (char *) s;
}
  8017f3:	5d                   	pop    %ebp
  8017f4:	c3                   	ret    

008017f5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	57                   	push   %edi
  8017f9:	56                   	push   %esi
  8017fa:	53                   	push   %ebx
  8017fb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  801801:	85 c9                	test   %ecx,%ecx
  801803:	74 36                	je     80183b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801805:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80180b:	75 28                	jne    801835 <memset+0x40>
  80180d:	f6 c1 03             	test   $0x3,%cl
  801810:	75 23                	jne    801835 <memset+0x40>
		c &= 0xFF;
  801812:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801816:	89 d3                	mov    %edx,%ebx
  801818:	c1 e3 08             	shl    $0x8,%ebx
  80181b:	89 d6                	mov    %edx,%esi
  80181d:	c1 e6 18             	shl    $0x18,%esi
  801820:	89 d0                	mov    %edx,%eax
  801822:	c1 e0 10             	shl    $0x10,%eax
  801825:	09 f0                	or     %esi,%eax
  801827:	09 c2                	or     %eax,%edx
  801829:	89 d0                	mov    %edx,%eax
  80182b:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80182d:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801830:	fc                   	cld    
  801831:	f3 ab                	rep stos %eax,%es:(%edi)
  801833:	eb 06                	jmp    80183b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801835:	8b 45 0c             	mov    0xc(%ebp),%eax
  801838:	fc                   	cld    
  801839:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80183b:	89 f8                	mov    %edi,%eax
  80183d:	5b                   	pop    %ebx
  80183e:	5e                   	pop    %esi
  80183f:	5f                   	pop    %edi
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	57                   	push   %edi
  801846:	56                   	push   %esi
  801847:	8b 45 08             	mov    0x8(%ebp),%eax
  80184a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80184d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801850:	39 c6                	cmp    %eax,%esi
  801852:	73 35                	jae    801889 <memmove+0x47>
  801854:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801857:	39 d0                	cmp    %edx,%eax
  801859:	73 2e                	jae    801889 <memmove+0x47>
		s += n;
		d += n;
  80185b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  80185e:	89 d6                	mov    %edx,%esi
  801860:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801862:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801868:	75 13                	jne    80187d <memmove+0x3b>
  80186a:	f6 c1 03             	test   $0x3,%cl
  80186d:	75 0e                	jne    80187d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80186f:	83 ef 04             	sub    $0x4,%edi
  801872:	8d 72 fc             	lea    -0x4(%edx),%esi
  801875:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  801878:	fd                   	std    
  801879:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187b:	eb 09                	jmp    801886 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80187d:	83 ef 01             	sub    $0x1,%edi
  801880:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801883:	fd                   	std    
  801884:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801886:	fc                   	cld    
  801887:	eb 1d                	jmp    8018a6 <memmove+0x64>
  801889:	89 f2                	mov    %esi,%edx
  80188b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188d:	f6 c2 03             	test   $0x3,%dl
  801890:	75 0f                	jne    8018a1 <memmove+0x5f>
  801892:	f6 c1 03             	test   $0x3,%cl
  801895:	75 0a                	jne    8018a1 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801897:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80189a:	89 c7                	mov    %eax,%edi
  80189c:	fc                   	cld    
  80189d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189f:	eb 05                	jmp    8018a6 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a1:	89 c7                	mov    %eax,%edi
  8018a3:	fc                   	cld    
  8018a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a6:	5e                   	pop    %esi
  8018a7:	5f                   	pop    %edi
  8018a8:	5d                   	pop    %ebp
  8018a9:	c3                   	ret    

008018aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018aa:	55                   	push   %ebp
  8018ab:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018ad:	ff 75 10             	pushl  0x10(%ebp)
  8018b0:	ff 75 0c             	pushl  0xc(%ebp)
  8018b3:	ff 75 08             	pushl  0x8(%ebp)
  8018b6:	e8 87 ff ff ff       	call   801842 <memmove>
}
  8018bb:	c9                   	leave  
  8018bc:	c3                   	ret    

008018bd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018bd:	55                   	push   %ebp
  8018be:	89 e5                	mov    %esp,%ebp
  8018c0:	56                   	push   %esi
  8018c1:	53                   	push   %ebx
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c8:	89 c6                	mov    %eax,%esi
  8018ca:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018cd:	eb 1a                	jmp    8018e9 <memcmp+0x2c>
		if (*s1 != *s2)
  8018cf:	0f b6 08             	movzbl (%eax),%ecx
  8018d2:	0f b6 1a             	movzbl (%edx),%ebx
  8018d5:	38 d9                	cmp    %bl,%cl
  8018d7:	74 0a                	je     8018e3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018d9:	0f b6 c1             	movzbl %cl,%eax
  8018dc:	0f b6 db             	movzbl %bl,%ebx
  8018df:	29 d8                	sub    %ebx,%eax
  8018e1:	eb 0f                	jmp    8018f2 <memcmp+0x35>
		s1++, s2++;
  8018e3:	83 c0 01             	add    $0x1,%eax
  8018e6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e9:	39 f0                	cmp    %esi,%eax
  8018eb:	75 e2                	jne    8018cf <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f2:	5b                   	pop    %ebx
  8018f3:	5e                   	pop    %esi
  8018f4:	5d                   	pop    %ebp
  8018f5:	c3                   	ret    

008018f6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018ff:	89 c2                	mov    %eax,%edx
  801901:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801904:	eb 07                	jmp    80190d <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  801906:	38 08                	cmp    %cl,(%eax)
  801908:	74 07                	je     801911 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190a:	83 c0 01             	add    $0x1,%eax
  80190d:	39 d0                	cmp    %edx,%eax
  80190f:	72 f5                	jb     801906 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801911:	5d                   	pop    %ebp
  801912:	c3                   	ret    

00801913 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801913:	55                   	push   %ebp
  801914:	89 e5                	mov    %esp,%ebp
  801916:	57                   	push   %edi
  801917:	56                   	push   %esi
  801918:	53                   	push   %ebx
  801919:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80191c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191f:	eb 03                	jmp    801924 <strtol+0x11>
		s++;
  801921:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801924:	0f b6 01             	movzbl (%ecx),%eax
  801927:	3c 09                	cmp    $0x9,%al
  801929:	74 f6                	je     801921 <strtol+0xe>
  80192b:	3c 20                	cmp    $0x20,%al
  80192d:	74 f2                	je     801921 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80192f:	3c 2b                	cmp    $0x2b,%al
  801931:	75 0a                	jne    80193d <strtol+0x2a>
		s++;
  801933:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801936:	bf 00 00 00 00       	mov    $0x0,%edi
  80193b:	eb 10                	jmp    80194d <strtol+0x3a>
  80193d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801942:	3c 2d                	cmp    $0x2d,%al
  801944:	75 07                	jne    80194d <strtol+0x3a>
		s++, neg = 1;
  801946:	8d 49 01             	lea    0x1(%ecx),%ecx
  801949:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80194d:	85 db                	test   %ebx,%ebx
  80194f:	0f 94 c0             	sete   %al
  801952:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801958:	75 19                	jne    801973 <strtol+0x60>
  80195a:	80 39 30             	cmpb   $0x30,(%ecx)
  80195d:	75 14                	jne    801973 <strtol+0x60>
  80195f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801963:	0f 85 8a 00 00 00    	jne    8019f3 <strtol+0xe0>
		s += 2, base = 16;
  801969:	83 c1 02             	add    $0x2,%ecx
  80196c:	bb 10 00 00 00       	mov    $0x10,%ebx
  801971:	eb 16                	jmp    801989 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801973:	84 c0                	test   %al,%al
  801975:	74 12                	je     801989 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801977:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80197c:	80 39 30             	cmpb   $0x30,(%ecx)
  80197f:	75 08                	jne    801989 <strtol+0x76>
		s++, base = 8;
  801981:	83 c1 01             	add    $0x1,%ecx
  801984:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801989:	b8 00 00 00 00       	mov    $0x0,%eax
  80198e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801991:	0f b6 11             	movzbl (%ecx),%edx
  801994:	8d 72 d0             	lea    -0x30(%edx),%esi
  801997:	89 f3                	mov    %esi,%ebx
  801999:	80 fb 09             	cmp    $0x9,%bl
  80199c:	77 08                	ja     8019a6 <strtol+0x93>
			dig = *s - '0';
  80199e:	0f be d2             	movsbl %dl,%edx
  8019a1:	83 ea 30             	sub    $0x30,%edx
  8019a4:	eb 22                	jmp    8019c8 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019a6:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019a9:	89 f3                	mov    %esi,%ebx
  8019ab:	80 fb 19             	cmp    $0x19,%bl
  8019ae:	77 08                	ja     8019b8 <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019b0:	0f be d2             	movsbl %dl,%edx
  8019b3:	83 ea 57             	sub    $0x57,%edx
  8019b6:	eb 10                	jmp    8019c8 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019b8:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019bb:	89 f3                	mov    %esi,%ebx
  8019bd:	80 fb 19             	cmp    $0x19,%bl
  8019c0:	77 16                	ja     8019d8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019c2:	0f be d2             	movsbl %dl,%edx
  8019c5:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019c8:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019cb:	7d 0f                	jge    8019dc <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019cd:	83 c1 01             	add    $0x1,%ecx
  8019d0:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019d6:	eb b9                	jmp    801991 <strtol+0x7e>
  8019d8:	89 c2                	mov    %eax,%edx
  8019da:	eb 02                	jmp    8019de <strtol+0xcb>
  8019dc:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019de:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e2:	74 05                	je     8019e9 <strtol+0xd6>
		*endptr = (char *) s;
  8019e4:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019e7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019e9:	85 ff                	test   %edi,%edi
  8019eb:	74 0c                	je     8019f9 <strtol+0xe6>
  8019ed:	89 d0                	mov    %edx,%eax
  8019ef:	f7 d8                	neg    %eax
  8019f1:	eb 06                	jmp    8019f9 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f3:	84 c0                	test   %al,%al
  8019f5:	75 8a                	jne    801981 <strtol+0x6e>
  8019f7:	eb 90                	jmp    801989 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8019f9:	5b                   	pop    %ebx
  8019fa:	5e                   	pop    %esi
  8019fb:	5f                   	pop    %edi
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	56                   	push   %esi
  801a02:	53                   	push   %ebx
  801a03:	8b 75 08             	mov    0x8(%ebp),%esi
  801a06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a0c:	85 f6                	test   %esi,%esi
  801a0e:	74 06                	je     801a16 <ipc_recv+0x18>
  801a10:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a16:	85 db                	test   %ebx,%ebx
  801a18:	74 06                	je     801a20 <ipc_recv+0x22>
  801a1a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a20:	83 f8 01             	cmp    $0x1,%eax
  801a23:	19 d2                	sbb    %edx,%edx
  801a25:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	50                   	push   %eax
  801a2b:	e8 de e8 ff ff       	call   80030e <sys_ipc_recv>
  801a30:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	85 d2                	test   %edx,%edx
  801a37:	75 24                	jne    801a5d <ipc_recv+0x5f>
	if (from_env_store)
  801a39:	85 f6                	test   %esi,%esi
  801a3b:	74 0a                	je     801a47 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a3d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a42:	8b 40 70             	mov    0x70(%eax),%eax
  801a45:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a47:	85 db                	test   %ebx,%ebx
  801a49:	74 0a                	je     801a55 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a4b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a50:	8b 40 74             	mov    0x74(%eax),%eax
  801a53:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a55:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5a:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a5d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a60:	5b                   	pop    %ebx
  801a61:	5e                   	pop    %esi
  801a62:	5d                   	pop    %ebp
  801a63:	c3                   	ret    

00801a64 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	57                   	push   %edi
  801a68:	56                   	push   %esi
  801a69:	53                   	push   %ebx
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a70:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a76:	83 fb 01             	cmp    $0x1,%ebx
  801a79:	19 c0                	sbb    %eax,%eax
  801a7b:	09 c3                	or     %eax,%ebx
  801a7d:	eb 1c                	jmp    801a9b <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a7f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a82:	74 12                	je     801a96 <ipc_send+0x32>
  801a84:	50                   	push   %eax
  801a85:	68 a0 22 80 00       	push   $0x8022a0
  801a8a:	6a 36                	push   $0x36
  801a8c:	68 b7 22 80 00       	push   $0x8022b7
  801a91:	e8 bd f5 ff ff       	call   801053 <_panic>
		sys_yield();
  801a96:	e8 a4 e6 ff ff       	call   80013f <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801a9b:	ff 75 14             	pushl  0x14(%ebp)
  801a9e:	53                   	push   %ebx
  801a9f:	56                   	push   %esi
  801aa0:	57                   	push   %edi
  801aa1:	e8 45 e8 ff ff       	call   8002eb <sys_ipc_try_send>
		if (ret == 0) break;
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	75 d2                	jne    801a7f <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801aad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab0:	5b                   	pop    %ebx
  801ab1:	5e                   	pop    %esi
  801ab2:	5f                   	pop    %edi
  801ab3:	5d                   	pop    %ebp
  801ab4:	c3                   	ret    

00801ab5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801abb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac0:	6b d0 78             	imul   $0x78,%eax,%edx
  801ac3:	83 c2 50             	add    $0x50,%edx
  801ac6:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801acc:	39 ca                	cmp    %ecx,%edx
  801ace:	75 0d                	jne    801add <ipc_find_env+0x28>
			return envs[i].env_id;
  801ad0:	6b c0 78             	imul   $0x78,%eax,%eax
  801ad3:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ad8:	8b 40 08             	mov    0x8(%eax),%eax
  801adb:	eb 0e                	jmp    801aeb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801add:	83 c0 01             	add    $0x1,%eax
  801ae0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ae5:	75 d9                	jne    801ac0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ae7:	66 b8 00 00          	mov    $0x0,%ax
}
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801af3:	89 d0                	mov    %edx,%eax
  801af5:	c1 e8 16             	shr    $0x16,%eax
  801af8:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b04:	f6 c1 01             	test   $0x1,%cl
  801b07:	74 1d                	je     801b26 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b09:	c1 ea 0c             	shr    $0xc,%edx
  801b0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b13:	f6 c2 01             	test   $0x1,%dl
  801b16:	74 0e                	je     801b26 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b18:	c1 ea 0c             	shr    $0xc,%edx
  801b1b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b22:	ef 
  801b23:	0f b7 c0             	movzwl %ax,%eax
}
  801b26:	5d                   	pop    %ebp
  801b27:	c3                   	ret    
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
