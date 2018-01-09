
obj/user/buggyhello:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
  800042:	83 c4 10             	add    $0x10,%esp
}
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 78             	imul   $0x78,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
  800083:	83 c4 10             	add    $0x10,%esp
#endif
}
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 a7 04 00 00       	call   80053f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
  8000a2:	83 c4 10             	add    $0x10,%esp
}
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 0a 1e 80 00       	push   $0x801e0a
  800111:	6a 23                	push   $0x23
  800113:	68 27 1e 80 00       	push   $0x801e27
  800118:	e8 3b 0f 00 00       	call   801058 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 0a 1e 80 00       	push   $0x801e0a
  800192:	6a 23                	push   $0x23
  800194:	68 27 1e 80 00       	push   $0x801e27
  800199:	e8 ba 0e 00 00       	call   801058 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 0a 1e 80 00       	push   $0x801e0a
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 27 1e 80 00       	push   $0x801e27
  8001db:	e8 78 0e 00 00       	call   801058 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 0a 1e 80 00       	push   $0x801e0a
  800216:	6a 23                	push   $0x23
  800218:	68 27 1e 80 00       	push   $0x801e27
  80021d:	e8 36 0e 00 00       	call   801058 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 0a 1e 80 00       	push   $0x801e0a
  800258:	6a 23                	push   $0x23
  80025a:	68 27 1e 80 00       	push   $0x801e27
  80025f:	e8 f4 0d 00 00       	call   801058 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 0a 1e 80 00       	push   $0x801e0a
  80029a:	6a 23                	push   $0x23
  80029c:	68 27 1e 80 00       	push   $0x801e27
  8002a1:	e8 b2 0d 00 00       	call   801058 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 0a 1e 80 00       	push   $0x801e0a
  8002dc:	6a 23                	push   $0x23
  8002de:	68 27 1e 80 00       	push   $0x801e27
  8002e3:	e8 70 0d 00 00       	call   801058 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 0a 1e 80 00       	push   $0x801e0a
  800340:	6a 23                	push   $0x23
  800342:	68 27 1e 80 00       	push   $0x801e27
  800347:	e8 0c 0d 00 00       	call   801058 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_gettime>:

int sys_gettime(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800376:	8b 45 08             	mov    0x8(%ebp),%eax
  800379:	05 00 00 00 30       	add    $0x30000000,%eax
  80037e:	c1 e8 0c             	shr    $0xc,%eax
}
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800386:	8b 45 08             	mov    0x8(%ebp),%eax
  800389:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80038e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800393:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800398:	5d                   	pop    %ebp
  800399:	c3                   	ret    

0080039a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a5:	89 c2                	mov    %eax,%edx
  8003a7:	c1 ea 16             	shr    $0x16,%edx
  8003aa:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b1:	f6 c2 01             	test   $0x1,%dl
  8003b4:	74 11                	je     8003c7 <fd_alloc+0x2d>
  8003b6:	89 c2                	mov    %eax,%edx
  8003b8:	c1 ea 0c             	shr    $0xc,%edx
  8003bb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c2:	f6 c2 01             	test   $0x1,%dl
  8003c5:	75 09                	jne    8003d0 <fd_alloc+0x36>
			*fd_store = fd;
  8003c7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ce:	eb 17                	jmp    8003e7 <fd_alloc+0x4d>
  8003d0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003da:	75 c9                	jne    8003a5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003dc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e2:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ef:	83 f8 1f             	cmp    $0x1f,%eax
  8003f2:	77 36                	ja     80042a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f4:	c1 e0 0c             	shl    $0xc,%eax
  8003f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fc:	89 c2                	mov    %eax,%edx
  8003fe:	c1 ea 16             	shr    $0x16,%edx
  800401:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800408:	f6 c2 01             	test   $0x1,%dl
  80040b:	74 24                	je     800431 <fd_lookup+0x48>
  80040d:	89 c2                	mov    %eax,%edx
  80040f:	c1 ea 0c             	shr    $0xc,%edx
  800412:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800419:	f6 c2 01             	test   $0x1,%dl
  80041c:	74 1a                	je     800438 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800421:	89 02                	mov    %eax,(%edx)
	return 0;
  800423:	b8 00 00 00 00       	mov    $0x0,%eax
  800428:	eb 13                	jmp    80043d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80042a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042f:	eb 0c                	jmp    80043d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800431:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800436:	eb 05                	jmp    80043d <fd_lookup+0x54>
  800438:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043d:	5d                   	pop    %ebp
  80043e:	c3                   	ret    

0080043f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	83 ec 08             	sub    $0x8,%esp
  800445:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800448:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044d:	eb 13                	jmp    800462 <dev_lookup+0x23>
  80044f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800452:	39 08                	cmp    %ecx,(%eax)
  800454:	75 0c                	jne    800462 <dev_lookup+0x23>
			*dev = devtab[i];
  800456:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800459:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	eb 2e                	jmp    800490 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800462:	8b 02                	mov    (%edx),%eax
  800464:	85 c0                	test   %eax,%eax
  800466:	75 e7                	jne    80044f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800468:	a1 04 40 80 00       	mov    0x804004,%eax
  80046d:	8b 40 48             	mov    0x48(%eax),%eax
  800470:	83 ec 04             	sub    $0x4,%esp
  800473:	51                   	push   %ecx
  800474:	50                   	push   %eax
  800475:	68 38 1e 80 00       	push   $0x801e38
  80047a:	e8 b2 0c 00 00       	call   801131 <cprintf>
	*dev = 0;
  80047f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800482:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800490:	c9                   	leave  
  800491:	c3                   	ret    

00800492 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800492:	55                   	push   %ebp
  800493:	89 e5                	mov    %esp,%ebp
  800495:	56                   	push   %esi
  800496:	53                   	push   %ebx
  800497:	83 ec 10             	sub    $0x10,%esp
  80049a:	8b 75 08             	mov    0x8(%ebp),%esi
  80049d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a3:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004a4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004aa:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ad:	50                   	push   %eax
  8004ae:	e8 36 ff ff ff       	call   8003e9 <fd_lookup>
  8004b3:	83 c4 08             	add    $0x8,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 05                	js     8004bf <fd_close+0x2d>
	    || fd != fd2)
  8004ba:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bd:	74 0b                	je     8004ca <fd_close+0x38>
		return (must_exist ? r : 0);
  8004bf:	80 fb 01             	cmp    $0x1,%bl
  8004c2:	19 d2                	sbb    %edx,%edx
  8004c4:	f7 d2                	not    %edx
  8004c6:	21 d0                	and    %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 67 ff ff ff       	call   80043f <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x69>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 e2 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c5 fe ff ff       	call   8003e9 <fd_lookup>
  800524:	89 c2                	mov    %eax,%edx
  800526:	83 c4 08             	add    $0x8,%esp
  800529:	85 d2                	test   %edx,%edx
  80052b:	78 10                	js     80053d <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	6a 01                	push   $0x1
  800532:	ff 75 f4             	pushl  -0xc(%ebp)
  800535:	e8 58 ff ff ff       	call   800492 <fd_close>
  80053a:	83 c4 10             	add    $0x10,%esp
}
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <close_all>:

void
close_all(void)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	53                   	push   %ebx
  800543:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800546:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054b:	83 ec 0c             	sub    $0xc,%esp
  80054e:	53                   	push   %ebx
  80054f:	e8 be ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800554:	83 c3 01             	add    $0x1,%ebx
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	83 fb 20             	cmp    $0x20,%ebx
  80055d:	75 ec                	jne    80054b <close_all+0xc>
		close(i);
}
  80055f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800562:	c9                   	leave  
  800563:	c3                   	ret    

00800564 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800564:	55                   	push   %ebp
  800565:	89 e5                	mov    %esp,%ebp
  800567:	57                   	push   %edi
  800568:	56                   	push   %esi
  800569:	53                   	push   %ebx
  80056a:	83 ec 2c             	sub    $0x2c,%esp
  80056d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800570:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800573:	50                   	push   %eax
  800574:	ff 75 08             	pushl  0x8(%ebp)
  800577:	e8 6d fe ff ff       	call   8003e9 <fd_lookup>
  80057c:	89 c2                	mov    %eax,%edx
  80057e:	83 c4 08             	add    $0x8,%esp
  800581:	85 d2                	test   %edx,%edx
  800583:	0f 88 c1 00 00 00    	js     80064a <dup+0xe6>
		return r;
	close(newfdnum);
  800589:	83 ec 0c             	sub    $0xc,%esp
  80058c:	56                   	push   %esi
  80058d:	e8 80 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  800592:	89 f3                	mov    %esi,%ebx
  800594:	c1 e3 0c             	shl    $0xc,%ebx
  800597:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80059d:	83 c4 04             	add    $0x4,%esp
  8005a0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005a3:	e8 db fd ff ff       	call   800383 <fd2data>
  8005a8:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005aa:	89 1c 24             	mov    %ebx,(%esp)
  8005ad:	e8 d1 fd ff ff       	call   800383 <fd2data>
  8005b2:	83 c4 10             	add    $0x10,%esp
  8005b5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b8:	89 f8                	mov    %edi,%eax
  8005ba:	c1 e8 16             	shr    $0x16,%eax
  8005bd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c4:	a8 01                	test   $0x1,%al
  8005c6:	74 37                	je     8005ff <dup+0x9b>
  8005c8:	89 f8                	mov    %edi,%eax
  8005ca:	c1 e8 0c             	shr    $0xc,%eax
  8005cd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d4:	f6 c2 01             	test   $0x1,%dl
  8005d7:	74 26                	je     8005ff <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e8:	50                   	push   %eax
  8005e9:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ec:	6a 00                	push   $0x0
  8005ee:	57                   	push   %edi
  8005ef:	6a 00                	push   $0x0
  8005f1:	e8 b0 fb ff ff       	call   8001a6 <sys_page_map>
  8005f6:	89 c7                	mov    %eax,%edi
  8005f8:	83 c4 20             	add    $0x20,%esp
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	78 2e                	js     80062d <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800602:	89 d0                	mov    %edx,%eax
  800604:	c1 e8 0c             	shr    $0xc,%eax
  800607:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060e:	83 ec 0c             	sub    $0xc,%esp
  800611:	25 07 0e 00 00       	and    $0xe07,%eax
  800616:	50                   	push   %eax
  800617:	53                   	push   %ebx
  800618:	6a 00                	push   $0x0
  80061a:	52                   	push   %edx
  80061b:	6a 00                	push   $0x0
  80061d:	e8 84 fb ff ff       	call   8001a6 <sys_page_map>
  800622:	89 c7                	mov    %eax,%edi
  800624:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800627:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800629:	85 ff                	test   %edi,%edi
  80062b:	79 1d                	jns    80064a <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80062d:	83 ec 08             	sub    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 00                	push   $0x0
  800633:	e8 b0 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800638:	83 c4 08             	add    $0x8,%esp
  80063b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063e:	6a 00                	push   $0x0
  800640:	e8 a3 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800645:	83 c4 10             	add    $0x10,%esp
  800648:	89 f8                	mov    %edi,%eax
}
  80064a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80064d:	5b                   	pop    %ebx
  80064e:	5e                   	pop    %esi
  80064f:	5f                   	pop    %edi
  800650:	5d                   	pop    %ebp
  800651:	c3                   	ret    

00800652 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800652:	55                   	push   %ebp
  800653:	89 e5                	mov    %esp,%ebp
  800655:	53                   	push   %ebx
  800656:	83 ec 14             	sub    $0x14,%esp
  800659:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80065c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065f:	50                   	push   %eax
  800660:	53                   	push   %ebx
  800661:	e8 83 fd ff ff       	call   8003e9 <fd_lookup>
  800666:	83 c4 08             	add    $0x8,%esp
  800669:	89 c2                	mov    %eax,%edx
  80066b:	85 c0                	test   %eax,%eax
  80066d:	78 6d                	js     8006dc <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800675:	50                   	push   %eax
  800676:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800679:	ff 30                	pushl  (%eax)
  80067b:	e8 bf fd ff ff       	call   80043f <dev_lookup>
  800680:	83 c4 10             	add    $0x10,%esp
  800683:	85 c0                	test   %eax,%eax
  800685:	78 4c                	js     8006d3 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800687:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80068a:	8b 42 08             	mov    0x8(%edx),%eax
  80068d:	83 e0 03             	and    $0x3,%eax
  800690:	83 f8 01             	cmp    $0x1,%eax
  800693:	75 21                	jne    8006b6 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 04 40 80 00       	mov    0x804004,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 79 1e 80 00       	push   $0x801e79
  8006a7:	e8 85 0a 00 00       	call   801131 <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b4:	eb 26                	jmp    8006dc <read+0x8a>
	}
	if (!dev->dev_read)
  8006b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b9:	8b 40 08             	mov    0x8(%eax),%eax
  8006bc:	85 c0                	test   %eax,%eax
  8006be:	74 17                	je     8006d7 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	ff 75 10             	pushl  0x10(%ebp)
  8006c6:	ff 75 0c             	pushl  0xc(%ebp)
  8006c9:	52                   	push   %edx
  8006ca:	ff d0                	call   *%eax
  8006cc:	89 c2                	mov    %eax,%edx
  8006ce:	83 c4 10             	add    $0x10,%esp
  8006d1:	eb 09                	jmp    8006dc <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d3:	89 c2                	mov    %eax,%edx
  8006d5:	eb 05                	jmp    8006dc <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d7:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006dc:	89 d0                	mov    %edx,%eax
  8006de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006e1:	c9                   	leave  
  8006e2:	c3                   	ret    

008006e3 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	57                   	push   %edi
  8006e7:	56                   	push   %esi
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 0c             	sub    $0xc,%esp
  8006ec:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006ef:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f7:	eb 21                	jmp    80071a <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f9:	83 ec 04             	sub    $0x4,%esp
  8006fc:	89 f0                	mov    %esi,%eax
  8006fe:	29 d8                	sub    %ebx,%eax
  800700:	50                   	push   %eax
  800701:	89 d8                	mov    %ebx,%eax
  800703:	03 45 0c             	add    0xc(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	57                   	push   %edi
  800708:	e8 45 ff ff ff       	call   800652 <read>
		if (m < 0)
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	85 c0                	test   %eax,%eax
  800712:	78 0c                	js     800720 <readn+0x3d>
			return m;
		if (m == 0)
  800714:	85 c0                	test   %eax,%eax
  800716:	74 06                	je     80071e <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800718:	01 c3                	add    %eax,%ebx
  80071a:	39 f3                	cmp    %esi,%ebx
  80071c:	72 db                	jb     8006f9 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  80071e:	89 d8                	mov    %ebx,%eax
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ad fc ff ff       	call   8003e9 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e9 fc ff ff       	call   80043f <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 95 1e 80 00       	push   $0x801e95
  800778:	e8 b4 09 00 00       	call   801131 <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 23 fc ff ff       	call   8003e9 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f8 fb ff ff       	call   8003e9 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 34 fc ff ff       	call   80043f <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 58 1e 80 00       	push   $0x801e58
  80082d:	e8 ff 08 00 00       	call   801131 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6d fb ff ff       	call   8003e9 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a9 fb ff ff       	call   80043f <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 e7 01 00 00       	call   800add <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 db                	test   %ebx,%ebx
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	53                   	push   %ebx
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 03                	push   $0x3
  800938:	e8 7d 11 00 00       	call   801aba <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 11 11 00 00       	call   801a69 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 9e 10 00 00       	call   801a03 <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	89 c2                	mov    %eax,%edx
  8009de:	85 d2                	test   %edx,%edx
  8009e0:	78 2c                	js     800a0e <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e2:	83 ec 08             	sub    $0x8,%esp
  8009e5:	68 00 50 80 00       	push   $0x805000
  8009ea:	53                   	push   %ebx
  8009eb:	e8 c5 0c 00 00       	call   8016b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009f0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009fb:	a1 84 50 80 00       	mov    0x805084,%eax
  800a00:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a06:	83 c4 10             	add    $0x10,%esp
  800a09:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	83 ec 08             	sub    $0x8,%esp
  800a19:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a22:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800a28:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800a2d:	76 05                	jbe    800a34 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800a2f:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800a34:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800a39:	83 ec 04             	sub    $0x4,%esp
  800a3c:	50                   	push   %eax
  800a3d:	ff 75 0c             	pushl  0xc(%ebp)
  800a40:	68 08 50 80 00       	push   $0x805008
  800a45:	e8 fd 0d 00 00       	call   801847 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4f:	b8 04 00 00 00       	mov    $0x4,%eax
  800a54:	e8 c8 fe ff ff       	call   800921 <fsipc>
	return write;
}
  800a59:	c9                   	leave  
  800a5a:	c3                   	ret    

00800a5b <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	56                   	push   %esi
  800a5f:	53                   	push   %ebx
  800a60:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 40 0c             	mov    0xc(%eax),%eax
  800a69:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a6e:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a74:	ba 00 00 00 00       	mov    $0x0,%edx
  800a79:	b8 03 00 00 00       	mov    $0x3,%eax
  800a7e:	e8 9e fe ff ff       	call   800921 <fsipc>
  800a83:	89 c3                	mov    %eax,%ebx
  800a85:	85 c0                	test   %eax,%eax
  800a87:	78 4b                	js     800ad4 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800a89:	39 c6                	cmp    %eax,%esi
  800a8b:	73 16                	jae    800aa3 <devfile_read+0x48>
  800a8d:	68 c4 1e 80 00       	push   $0x801ec4
  800a92:	68 cb 1e 80 00       	push   $0x801ecb
  800a97:	6a 7c                	push   $0x7c
  800a99:	68 e0 1e 80 00       	push   $0x801ee0
  800a9e:	e8 b5 05 00 00       	call   801058 <_panic>
	assert(r <= PGSIZE);
  800aa3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa8:	7e 16                	jle    800ac0 <devfile_read+0x65>
  800aaa:	68 eb 1e 80 00       	push   $0x801eeb
  800aaf:	68 cb 1e 80 00       	push   $0x801ecb
  800ab4:	6a 7d                	push   $0x7d
  800ab6:	68 e0 1e 80 00       	push   $0x801ee0
  800abb:	e8 98 05 00 00       	call   801058 <_panic>
	memmove(buf, &fsipcbuf, r);
  800ac0:	83 ec 04             	sub    $0x4,%esp
  800ac3:	50                   	push   %eax
  800ac4:	68 00 50 80 00       	push   $0x805000
  800ac9:	ff 75 0c             	pushl  0xc(%ebp)
  800acc:	e8 76 0d 00 00       	call   801847 <memmove>
	return r;
  800ad1:	83 c4 10             	add    $0x10,%esp
}
  800ad4:	89 d8                	mov    %ebx,%eax
  800ad6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800add:	55                   	push   %ebp
  800ade:	89 e5                	mov    %esp,%ebp
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 20             	sub    $0x20,%esp
  800ae4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ae7:	53                   	push   %ebx
  800ae8:	e8 8f 0b 00 00       	call   80167c <strlen>
  800aed:	83 c4 10             	add    $0x10,%esp
  800af0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800af5:	7f 67                	jg     800b5e <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800af7:	83 ec 0c             	sub    $0xc,%esp
  800afa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800afd:	50                   	push   %eax
  800afe:	e8 97 f8 ff ff       	call   80039a <fd_alloc>
  800b03:	83 c4 10             	add    $0x10,%esp
		return r;
  800b06:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	78 57                	js     800b63 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b0c:	83 ec 08             	sub    $0x8,%esp
  800b0f:	53                   	push   %ebx
  800b10:	68 00 50 80 00       	push   $0x805000
  800b15:	e8 9b 0b 00 00       	call   8016b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1d:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b22:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b25:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2a:	e8 f2 fd ff ff       	call   800921 <fsipc>
  800b2f:	89 c3                	mov    %eax,%ebx
  800b31:	83 c4 10             	add    $0x10,%esp
  800b34:	85 c0                	test   %eax,%eax
  800b36:	79 14                	jns    800b4c <open+0x6f>
		fd_close(fd, 0);
  800b38:	83 ec 08             	sub    $0x8,%esp
  800b3b:	6a 00                	push   $0x0
  800b3d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b40:	e8 4d f9 ff ff       	call   800492 <fd_close>
		return r;
  800b45:	83 c4 10             	add    $0x10,%esp
  800b48:	89 da                	mov    %ebx,%edx
  800b4a:	eb 17                	jmp    800b63 <open+0x86>
	}

	return fd2num(fd);
  800b4c:	83 ec 0c             	sub    $0xc,%esp
  800b4f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b52:	e8 1c f8 ff ff       	call   800373 <fd2num>
  800b57:	89 c2                	mov    %eax,%edx
  800b59:	83 c4 10             	add    $0x10,%esp
  800b5c:	eb 05                	jmp    800b63 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b5e:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b63:	89 d0                	mov    %edx,%eax
  800b65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b70:	ba 00 00 00 00       	mov    $0x0,%edx
  800b75:	b8 08 00 00 00       	mov    $0x8,%eax
  800b7a:	e8 a2 fd ff ff       	call   800921 <fsipc>
}
  800b7f:	c9                   	leave  
  800b80:	c3                   	ret    

00800b81 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	56                   	push   %esi
  800b85:	53                   	push   %ebx
  800b86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b89:	83 ec 0c             	sub    $0xc,%esp
  800b8c:	ff 75 08             	pushl  0x8(%ebp)
  800b8f:	e8 ef f7 ff ff       	call   800383 <fd2data>
  800b94:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b96:	83 c4 08             	add    $0x8,%esp
  800b99:	68 f7 1e 80 00       	push   $0x801ef7
  800b9e:	53                   	push   %ebx
  800b9f:	e8 11 0b 00 00       	call   8016b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800ba4:	8b 56 04             	mov    0x4(%esi),%edx
  800ba7:	89 d0                	mov    %edx,%eax
  800ba9:	2b 06                	sub    (%esi),%eax
  800bab:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800bb1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bb8:	00 00 00 
	stat->st_dev = &devpipe;
  800bbb:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bc2:	30 80 00 
	return 0;
}
  800bc5:	b8 00 00 00 00       	mov    $0x0,%eax
  800bca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bcd:	5b                   	pop    %ebx
  800bce:	5e                   	pop    %esi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	53                   	push   %ebx
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bdb:	53                   	push   %ebx
  800bdc:	6a 00                	push   $0x0
  800bde:	e8 05 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800be3:	89 1c 24             	mov    %ebx,(%esp)
  800be6:	e8 98 f7 ff ff       	call   800383 <fd2data>
  800beb:	83 c4 08             	add    $0x8,%esp
  800bee:	50                   	push   %eax
  800bef:	6a 00                	push   $0x0
  800bf1:	e8 f2 f5 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bf6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 1c             	sub    $0x1c,%esp
  800c04:	89 c7                	mov    %eax,%edi
  800c06:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800c08:	a1 04 40 80 00       	mov    0x804004,%eax
  800c0d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c10:	83 ec 0c             	sub    $0xc,%esp
  800c13:	57                   	push   %edi
  800c14:	e8 d9 0e 00 00       	call   801af2 <pageref>
  800c19:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c1c:	89 34 24             	mov    %esi,(%esp)
  800c1f:	e8 ce 0e 00 00       	call   801af2 <pageref>
  800c24:	83 c4 10             	add    $0x10,%esp
  800c27:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c2a:	0f 94 c0             	sete   %al
  800c2d:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  800c30:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c36:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c39:	39 cb                	cmp    %ecx,%ebx
  800c3b:	74 15                	je     800c52 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  800c3d:	8b 52 58             	mov    0x58(%edx),%edx
  800c40:	50                   	push   %eax
  800c41:	52                   	push   %edx
  800c42:	53                   	push   %ebx
  800c43:	68 04 1f 80 00       	push   $0x801f04
  800c48:	e8 e4 04 00 00       	call   801131 <cprintf>
  800c4d:	83 c4 10             	add    $0x10,%esp
  800c50:	eb b6                	jmp    800c08 <_pipeisclosed+0xd>
	}
}
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 28             	sub    $0x28,%esp
  800c63:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c66:	56                   	push   %esi
  800c67:	e8 17 f7 ff ff       	call   800383 <fd2data>
  800c6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	bf 00 00 00 00       	mov    $0x0,%edi
  800c76:	eb 4b                	jmp    800cc3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c78:	89 da                	mov    %ebx,%edx
  800c7a:	89 f0                	mov    %esi,%eax
  800c7c:	e8 7a ff ff ff       	call   800bfb <_pipeisclosed>
  800c81:	85 c0                	test   %eax,%eax
  800c83:	75 48                	jne    800ccd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c85:	e8 ba f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c8d:	8b 0b                	mov    (%ebx),%ecx
  800c8f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c92:	39 d0                	cmp    %edx,%eax
  800c94:	73 e2                	jae    800c78 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca0:	89 c2                	mov    %eax,%edx
  800ca2:	c1 fa 1f             	sar    $0x1f,%edx
  800ca5:	89 d1                	mov    %edx,%ecx
  800ca7:	c1 e9 1b             	shr    $0x1b,%ecx
  800caa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cad:	83 e2 1f             	and    $0x1f,%edx
  800cb0:	29 ca                	sub    %ecx,%edx
  800cb2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc0:	83 c7 01             	add    $0x1,%edi
  800cc3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc6:	75 c2                	jne    800c8a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccb:	eb 05                	jmp    800cd2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 18             	sub    $0x18,%esp
  800ce3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce6:	57                   	push   %edi
  800ce7:	e8 97 f6 ff ff       	call   800383 <fd2data>
  800cec:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cee:	83 c4 10             	add    $0x10,%esp
  800cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf6:	eb 3d                	jmp    800d35 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf8:	85 db                	test   %ebx,%ebx
  800cfa:	74 04                	je     800d00 <devpipe_read+0x26>
				return i;
  800cfc:	89 d8                	mov    %ebx,%eax
  800cfe:	eb 44                	jmp    800d44 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d00:	89 f2                	mov    %esi,%edx
  800d02:	89 f8                	mov    %edi,%eax
  800d04:	e8 f2 fe ff ff       	call   800bfb <_pipeisclosed>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	75 32                	jne    800d3f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d0d:	e8 32 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d12:	8b 06                	mov    (%esi),%eax
  800d14:	3b 46 04             	cmp    0x4(%esi),%eax
  800d17:	74 df                	je     800cf8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d19:	99                   	cltd   
  800d1a:	c1 ea 1b             	shr    $0x1b,%edx
  800d1d:	01 d0                	add    %edx,%eax
  800d1f:	83 e0 1f             	and    $0x1f,%eax
  800d22:	29 d0                	sub    %edx,%eax
  800d24:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d2f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d32:	83 c3 01             	add    $0x1,%ebx
  800d35:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d38:	75 d8                	jne    800d12 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3d:	eb 05                	jmp    800d44 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d57:	50                   	push   %eax
  800d58:	e8 3d f6 ff ff       	call   80039a <fd_alloc>
  800d5d:	83 c4 10             	add    $0x10,%esp
  800d60:	89 c2                	mov    %eax,%edx
  800d62:	85 c0                	test   %eax,%eax
  800d64:	0f 88 2c 01 00 00    	js     800e96 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6a:	83 ec 04             	sub    $0x4,%esp
  800d6d:	68 07 04 00 00       	push   $0x407
  800d72:	ff 75 f4             	pushl  -0xc(%ebp)
  800d75:	6a 00                	push   $0x0
  800d77:	e8 e7 f3 ff ff       	call   800163 <sys_page_alloc>
  800d7c:	83 c4 10             	add    $0x10,%esp
  800d7f:	89 c2                	mov    %eax,%edx
  800d81:	85 c0                	test   %eax,%eax
  800d83:	0f 88 0d 01 00 00    	js     800e96 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8f:	50                   	push   %eax
  800d90:	e8 05 f6 ff ff       	call   80039a <fd_alloc>
  800d95:	89 c3                	mov    %eax,%ebx
  800d97:	83 c4 10             	add    $0x10,%esp
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	0f 88 e2 00 00 00    	js     800e84 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da2:	83 ec 04             	sub    $0x4,%esp
  800da5:	68 07 04 00 00       	push   $0x407
  800daa:	ff 75 f0             	pushl  -0x10(%ebp)
  800dad:	6a 00                	push   $0x0
  800daf:	e8 af f3 ff ff       	call   800163 <sys_page_alloc>
  800db4:	89 c3                	mov    %eax,%ebx
  800db6:	83 c4 10             	add    $0x10,%esp
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	0f 88 c3 00 00 00    	js     800e84 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc7:	e8 b7 f5 ff ff       	call   800383 <fd2data>
  800dcc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dce:	83 c4 0c             	add    $0xc,%esp
  800dd1:	68 07 04 00 00       	push   $0x407
  800dd6:	50                   	push   %eax
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 85 f3 ff ff       	call   800163 <sys_page_alloc>
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	0f 88 89 00 00 00    	js     800e74 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	ff 75 f0             	pushl  -0x10(%ebp)
  800df1:	e8 8d f5 ff ff       	call   800383 <fd2data>
  800df6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dfd:	50                   	push   %eax
  800dfe:	6a 00                	push   $0x0
  800e00:	56                   	push   %esi
  800e01:	6a 00                	push   $0x0
  800e03:	e8 9e f3 ff ff       	call   8001a6 <sys_page_map>
  800e08:	89 c3                	mov    %eax,%ebx
  800e0a:	83 c4 20             	add    $0x20,%esp
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	78 55                	js     800e66 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e41:	e8 2d f5 ff ff       	call   800373 <fd2num>
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4b:	83 c4 04             	add    $0x4,%esp
  800e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e51:	e8 1d f5 ff ff       	call   800373 <fd2num>
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e59:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e64:	eb 30                	jmp    800e96 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	56                   	push   %esi
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 77 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 67 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e84:	83 ec 08             	sub    $0x8,%esp
  800e87:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8a:	6a 00                	push   $0x0
  800e8c:	e8 57 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e96:	89 d0                	mov    %edx,%eax
  800e98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea8:	50                   	push   %eax
  800ea9:	ff 75 08             	pushl  0x8(%ebp)
  800eac:	e8 38 f5 ff ff       	call   8003e9 <fd_lookup>
  800eb1:	89 c2                	mov    %eax,%edx
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 d2                	test   %edx,%edx
  800eb8:	78 18                	js     800ed2 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eba:	83 ec 0c             	sub    $0xc,%esp
  800ebd:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec0:	e8 be f4 ff ff       	call   800383 <fd2data>
	return _pipeisclosed(fd, p);
  800ec5:	89 c2                	mov    %eax,%edx
  800ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eca:	e8 2c fd ff ff       	call   800bfb <_pipeisclosed>
  800ecf:	83 c4 10             	add    $0x10,%esp
}
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ed7:	b8 00 00 00 00       	mov    $0x0,%eax
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee4:	68 35 1f 80 00       	push   $0x801f35
  800ee9:	ff 75 0c             	pushl  0xc(%ebp)
  800eec:	e8 c4 07 00 00       	call   8016b5 <strcpy>
	return 0;
}
  800ef1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef6:	c9                   	leave  
  800ef7:	c3                   	ret    

00800ef8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
  800efe:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f04:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f09:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0f:	eb 2e                	jmp    800f3f <devcons_write+0x47>
		m = n - tot;
  800f11:	8b 55 10             	mov    0x10(%ebp),%edx
  800f14:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800f16:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  800f1b:	83 fa 7f             	cmp    $0x7f,%edx
  800f1e:	77 02                	ja     800f22 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f20:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f22:	83 ec 04             	sub    $0x4,%esp
  800f25:	56                   	push   %esi
  800f26:	03 45 0c             	add    0xc(%ebp),%eax
  800f29:	50                   	push   %eax
  800f2a:	57                   	push   %edi
  800f2b:	e8 17 09 00 00       	call   801847 <memmove>
		sys_cputs(buf, m);
  800f30:	83 c4 08             	add    $0x8,%esp
  800f33:	56                   	push   %esi
  800f34:	57                   	push   %edi
  800f35:	e8 6d f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f3a:	01 f3                	add    %esi,%ebx
  800f3c:	83 c4 10             	add    $0x10,%esp
  800f3f:	89 d8                	mov    %ebx,%eax
  800f41:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800f44:	72 cb                	jb     800f11 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f49:	5b                   	pop    %ebx
  800f4a:	5e                   	pop    %esi
  800f4b:	5f                   	pop    %edi
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  800f54:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  800f59:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f5d:	75 07                	jne    800f66 <devcons_read+0x18>
  800f5f:	eb 28                	jmp    800f89 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f61:	e8 de f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f66:	e8 5a f1 ff ff       	call   8000c5 <sys_cgetc>
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	74 f2                	je     800f61 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 16                	js     800f89 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f73:	83 f8 04             	cmp    $0x4,%eax
  800f76:	74 0c                	je     800f84 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f78:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7b:	88 02                	mov    %al,(%edx)
	return 1;
  800f7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800f82:	eb 05                	jmp    800f89 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f84:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f89:	c9                   	leave  
  800f8a:	c3                   	ret    

00800f8b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f91:	8b 45 08             	mov    0x8(%ebp),%eax
  800f94:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f97:	6a 01                	push   $0x1
  800f99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9c:	50                   	push   %eax
  800f9d:	e8 05 f1 ff ff       	call   8000a7 <sys_cputs>
  800fa2:	83 c4 10             	add    $0x10,%esp
}
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <getchar>:

int
getchar(void)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800fad:	6a 01                	push   $0x1
  800faf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb2:	50                   	push   %eax
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 98 f6 ff ff       	call   800652 <read>
	if (r < 0)
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 0f                	js     800fd0 <getchar+0x29>
		return r;
	if (r < 1)
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	7e 06                	jle    800fcb <getchar+0x24>
		return -E_EOF;
	return c;
  800fc5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc9:	eb 05                	jmp    800fd0 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fcb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fd0:	c9                   	leave  
  800fd1:	c3                   	ret    

00800fd2 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdb:	50                   	push   %eax
  800fdc:	ff 75 08             	pushl  0x8(%ebp)
  800fdf:	e8 05 f4 ff ff       	call   8003e9 <fd_lookup>
  800fe4:	83 c4 10             	add    $0x10,%esp
  800fe7:	85 c0                	test   %eax,%eax
  800fe9:	78 11                	js     800ffc <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800feb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fee:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff4:	39 10                	cmp    %edx,(%eax)
  800ff6:	0f 94 c0             	sete   %al
  800ff9:	0f b6 c0             	movzbl %al,%eax
}
  800ffc:	c9                   	leave  
  800ffd:	c3                   	ret    

00800ffe <opencons>:

int
opencons(void)
{
  800ffe:	55                   	push   %ebp
  800fff:	89 e5                	mov    %esp,%ebp
  801001:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801004:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801007:	50                   	push   %eax
  801008:	e8 8d f3 ff ff       	call   80039a <fd_alloc>
  80100d:	83 c4 10             	add    $0x10,%esp
		return r;
  801010:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801012:	85 c0                	test   %eax,%eax
  801014:	78 3e                	js     801054 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801016:	83 ec 04             	sub    $0x4,%esp
  801019:	68 07 04 00 00       	push   $0x407
  80101e:	ff 75 f4             	pushl  -0xc(%ebp)
  801021:	6a 00                	push   $0x0
  801023:	e8 3b f1 ff ff       	call   800163 <sys_page_alloc>
  801028:	83 c4 10             	add    $0x10,%esp
		return r;
  80102b:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102d:	85 c0                	test   %eax,%eax
  80102f:	78 23                	js     801054 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801031:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801037:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80103c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	50                   	push   %eax
  80104a:	e8 24 f3 ff ff       	call   800373 <fd2num>
  80104f:	89 c2                	mov    %eax,%edx
  801051:	83 c4 10             	add    $0x10,%esp
}
  801054:	89 d0                	mov    %edx,%eax
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	56                   	push   %esi
  80105c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80105d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801060:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801066:	e8 ba f0 ff ff       	call   800125 <sys_getenvid>
  80106b:	83 ec 0c             	sub    $0xc,%esp
  80106e:	ff 75 0c             	pushl  0xc(%ebp)
  801071:	ff 75 08             	pushl  0x8(%ebp)
  801074:	56                   	push   %esi
  801075:	50                   	push   %eax
  801076:	68 44 1f 80 00       	push   $0x801f44
  80107b:	e8 b1 00 00 00       	call   801131 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801080:	83 c4 18             	add    $0x18,%esp
  801083:	53                   	push   %ebx
  801084:	ff 75 10             	pushl  0x10(%ebp)
  801087:	e8 54 00 00 00       	call   8010e0 <vcprintf>
	cprintf("\n");
  80108c:	c7 04 24 93 1e 80 00 	movl   $0x801e93,(%esp)
  801093:	e8 99 00 00 00       	call   801131 <cprintf>
  801098:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109b:	cc                   	int3   
  80109c:	eb fd                	jmp    80109b <_panic+0x43>

0080109e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	53                   	push   %ebx
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a8:	8b 13                	mov    (%ebx),%edx
  8010aa:	8d 42 01             	lea    0x1(%edx),%eax
  8010ad:	89 03                	mov    %eax,(%ebx)
  8010af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bb:	75 1a                	jne    8010d7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010bd:	83 ec 08             	sub    $0x8,%esp
  8010c0:	68 ff 00 00 00       	push   $0xff
  8010c5:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c8:	50                   	push   %eax
  8010c9:	e8 d9 ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010d7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010de:	c9                   	leave  
  8010df:	c3                   	ret    

008010e0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e0:	55                   	push   %ebp
  8010e1:	89 e5                	mov    %esp,%ebp
  8010e3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f0:	00 00 00 
	b.cnt = 0;
  8010f3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010fa:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010fd:	ff 75 0c             	pushl  0xc(%ebp)
  801100:	ff 75 08             	pushl  0x8(%ebp)
  801103:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	68 9e 10 80 00       	push   $0x80109e
  80110f:	e8 4f 01 00 00       	call   801263 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801114:	83 c4 08             	add    $0x8,%esp
  801117:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80111d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801123:	50                   	push   %eax
  801124:	e8 7e ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801129:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80112f:	c9                   	leave  
  801130:	c3                   	ret    

00801131 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801137:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113a:	50                   	push   %eax
  80113b:	ff 75 08             	pushl  0x8(%ebp)
  80113e:	e8 9d ff ff ff       	call   8010e0 <vcprintf>
	va_end(ap);

	return cnt;
}
  801143:	c9                   	leave  
  801144:	c3                   	ret    

00801145 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	57                   	push   %edi
  801149:	56                   	push   %esi
  80114a:	53                   	push   %ebx
  80114b:	83 ec 1c             	sub    $0x1c,%esp
  80114e:	89 c7                	mov    %eax,%edi
  801150:	89 d6                	mov    %edx,%esi
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	8b 55 0c             	mov    0xc(%ebp),%edx
  801158:	89 d1                	mov    %edx,%ecx
  80115a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80115d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801160:	8b 45 10             	mov    0x10(%ebp),%eax
  801163:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801166:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801169:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801170:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801173:	72 05                	jb     80117a <printnum+0x35>
  801175:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801178:	77 3e                	ja     8011b8 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117a:	83 ec 0c             	sub    $0xc,%esp
  80117d:	ff 75 18             	pushl  0x18(%ebp)
  801180:	83 eb 01             	sub    $0x1,%ebx
  801183:	53                   	push   %ebx
  801184:	50                   	push   %eax
  801185:	83 ec 08             	sub    $0x8,%esp
  801188:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118b:	ff 75 e0             	pushl  -0x20(%ebp)
  80118e:	ff 75 dc             	pushl  -0x24(%ebp)
  801191:	ff 75 d8             	pushl  -0x28(%ebp)
  801194:	e8 97 09 00 00       	call   801b30 <__udivdi3>
  801199:	83 c4 18             	add    $0x18,%esp
  80119c:	52                   	push   %edx
  80119d:	50                   	push   %eax
  80119e:	89 f2                	mov    %esi,%edx
  8011a0:	89 f8                	mov    %edi,%eax
  8011a2:	e8 9e ff ff ff       	call   801145 <printnum>
  8011a7:	83 c4 20             	add    $0x20,%esp
  8011aa:	eb 13                	jmp    8011bf <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	56                   	push   %esi
  8011b0:	ff 75 18             	pushl  0x18(%ebp)
  8011b3:	ff d7                	call   *%edi
  8011b5:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011b8:	83 eb 01             	sub    $0x1,%ebx
  8011bb:	85 db                	test   %ebx,%ebx
  8011bd:	7f ed                	jg     8011ac <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011bf:	83 ec 08             	sub    $0x8,%esp
  8011c2:	56                   	push   %esi
  8011c3:	83 ec 04             	sub    $0x4,%esp
  8011c6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8011cc:	ff 75 dc             	pushl  -0x24(%ebp)
  8011cf:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d2:	e8 89 0a 00 00       	call   801c60 <__umoddi3>
  8011d7:	83 c4 14             	add    $0x14,%esp
  8011da:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011e1:	50                   	push   %eax
  8011e2:	ff d7                	call   *%edi
  8011e4:	83 c4 10             	add    $0x10,%esp
}
  8011e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ea:	5b                   	pop    %ebx
  8011eb:	5e                   	pop    %esi
  8011ec:	5f                   	pop    %edi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f2:	83 fa 01             	cmp    $0x1,%edx
  8011f5:	7e 0e                	jle    801205 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011f7:	8b 10                	mov    (%eax),%edx
  8011f9:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011fc:	89 08                	mov    %ecx,(%eax)
  8011fe:	8b 02                	mov    (%edx),%eax
  801200:	8b 52 04             	mov    0x4(%edx),%edx
  801203:	eb 22                	jmp    801227 <getuint+0x38>
	else if (lflag)
  801205:	85 d2                	test   %edx,%edx
  801207:	74 10                	je     801219 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801209:	8b 10                	mov    (%eax),%edx
  80120b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120e:	89 08                	mov    %ecx,(%eax)
  801210:	8b 02                	mov    (%edx),%eax
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
  801217:	eb 0e                	jmp    801227 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801219:	8b 10                	mov    (%eax),%edx
  80121b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121e:	89 08                	mov    %ecx,(%eax)
  801220:	8b 02                	mov    (%edx),%eax
  801222:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801227:	5d                   	pop    %ebp
  801228:	c3                   	ret    

00801229 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80122f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801233:	8b 10                	mov    (%eax),%edx
  801235:	3b 50 04             	cmp    0x4(%eax),%edx
  801238:	73 0a                	jae    801244 <sprintputch+0x1b>
		*b->buf++ = ch;
  80123a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80123d:	89 08                	mov    %ecx,(%eax)
  80123f:	8b 45 08             	mov    0x8(%ebp),%eax
  801242:	88 02                	mov    %al,(%edx)
}
  801244:	5d                   	pop    %ebp
  801245:	c3                   	ret    

00801246 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801246:	55                   	push   %ebp
  801247:	89 e5                	mov    %esp,%ebp
  801249:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80124c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80124f:	50                   	push   %eax
  801250:	ff 75 10             	pushl  0x10(%ebp)
  801253:	ff 75 0c             	pushl  0xc(%ebp)
  801256:	ff 75 08             	pushl  0x8(%ebp)
  801259:	e8 05 00 00 00       	call   801263 <vprintfmt>
	va_end(ap);
  80125e:	83 c4 10             	add    $0x10,%esp
}
  801261:	c9                   	leave  
  801262:	c3                   	ret    

00801263 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801263:	55                   	push   %ebp
  801264:	89 e5                	mov    %esp,%ebp
  801266:	57                   	push   %edi
  801267:	56                   	push   %esi
  801268:	53                   	push   %ebx
  801269:	83 ec 2c             	sub    $0x2c,%esp
  80126c:	8b 75 08             	mov    0x8(%ebp),%esi
  80126f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801272:	8b 7d 10             	mov    0x10(%ebp),%edi
  801275:	eb 12                	jmp    801289 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801277:	85 c0                	test   %eax,%eax
  801279:	0f 84 8d 03 00 00    	je     80160c <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	53                   	push   %ebx
  801283:	50                   	push   %eax
  801284:	ff d6                	call   *%esi
  801286:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801289:	83 c7 01             	add    $0x1,%edi
  80128c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801290:	83 f8 25             	cmp    $0x25,%eax
  801293:	75 e2                	jne    801277 <vprintfmt+0x14>
  801295:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801299:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8012a7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b3:	eb 07                	jmp    8012bc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012b8:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012bc:	8d 47 01             	lea    0x1(%edi),%eax
  8012bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c2:	0f b6 07             	movzbl (%edi),%eax
  8012c5:	0f b6 c8             	movzbl %al,%ecx
  8012c8:	83 e8 23             	sub    $0x23,%eax
  8012cb:	3c 55                	cmp    $0x55,%al
  8012cd:	0f 87 1e 03 00 00    	ja     8015f1 <vprintfmt+0x38e>
  8012d3:	0f b6 c0             	movzbl %al,%eax
  8012d6:	ff 24 85 c0 20 80 00 	jmp    *0x8020c0(,%eax,4)
  8012dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e0:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012e4:	eb d6                	jmp    8012bc <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ee:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012f1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012f4:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012f8:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012fb:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012fe:	83 fa 09             	cmp    $0x9,%edx
  801301:	77 38                	ja     80133b <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801303:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801306:	eb e9                	jmp    8012f1 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801308:	8b 45 14             	mov    0x14(%ebp),%eax
  80130b:	8d 48 04             	lea    0x4(%eax),%ecx
  80130e:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801311:	8b 00                	mov    (%eax),%eax
  801313:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801319:	eb 26                	jmp    801341 <vprintfmt+0xde>
  80131b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80131e:	89 c8                	mov    %ecx,%eax
  801320:	c1 f8 1f             	sar    $0x1f,%eax
  801323:	f7 d0                	not    %eax
  801325:	21 c1                	and    %eax,%ecx
  801327:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80132d:	eb 8d                	jmp    8012bc <vprintfmt+0x59>
  80132f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801332:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801339:	eb 81                	jmp    8012bc <vprintfmt+0x59>
  80133b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80133e:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801341:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801345:	0f 89 71 ff ff ff    	jns    8012bc <vprintfmt+0x59>
				width = precision, precision = -1;
  80134b:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80134e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801351:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801358:	e9 5f ff ff ff       	jmp    8012bc <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80135d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801363:	e9 54 ff ff ff       	jmp    8012bc <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801368:	8b 45 14             	mov    0x14(%ebp),%eax
  80136b:	8d 50 04             	lea    0x4(%eax),%edx
  80136e:	89 55 14             	mov    %edx,0x14(%ebp)
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	53                   	push   %ebx
  801375:	ff 30                	pushl  (%eax)
  801377:	ff d6                	call   *%esi
			break;
  801379:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80137f:	e9 05 ff ff ff       	jmp    801289 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  801384:	8b 45 14             	mov    0x14(%ebp),%eax
  801387:	8d 50 04             	lea    0x4(%eax),%edx
  80138a:	89 55 14             	mov    %edx,0x14(%ebp)
  80138d:	8b 00                	mov    (%eax),%eax
  80138f:	99                   	cltd   
  801390:	31 d0                	xor    %edx,%eax
  801392:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801394:	83 f8 0f             	cmp    $0xf,%eax
  801397:	7f 0b                	jg     8013a4 <vprintfmt+0x141>
  801399:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  8013a0:	85 d2                	test   %edx,%edx
  8013a2:	75 18                	jne    8013bc <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8013a4:	50                   	push   %eax
  8013a5:	68 7f 1f 80 00       	push   $0x801f7f
  8013aa:	53                   	push   %ebx
  8013ab:	56                   	push   %esi
  8013ac:	e8 95 fe ff ff       	call   801246 <printfmt>
  8013b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013b7:	e9 cd fe ff ff       	jmp    801289 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013bc:	52                   	push   %edx
  8013bd:	68 dd 1e 80 00       	push   $0x801edd
  8013c2:	53                   	push   %ebx
  8013c3:	56                   	push   %esi
  8013c4:	e8 7d fe ff ff       	call   801246 <printfmt>
  8013c9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013cf:	e9 b5 fe ff ff       	jmp    801289 <vprintfmt+0x26>
  8013d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8013d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013da:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e0:	8d 50 04             	lea    0x4(%eax),%edx
  8013e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e6:	8b 38                	mov    (%eax),%edi
  8013e8:	85 ff                	test   %edi,%edi
  8013ea:	75 05                	jne    8013f1 <vprintfmt+0x18e>
				p = "(null)";
  8013ec:	bf 78 1f 80 00       	mov    $0x801f78,%edi
			if (width > 0 && padc != '-')
  8013f1:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013f5:	0f 84 91 00 00 00    	je     80148c <vprintfmt+0x229>
  8013fb:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8013ff:	0f 8e 95 00 00 00    	jle    80149a <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	51                   	push   %ecx
  801409:	57                   	push   %edi
  80140a:	e8 85 02 00 00       	call   801694 <strnlen>
  80140f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801412:	29 c1                	sub    %eax,%ecx
  801414:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801417:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80141a:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80141e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801421:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801424:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801426:	eb 0f                	jmp    801437 <vprintfmt+0x1d4>
					putch(padc, putdat);
  801428:	83 ec 08             	sub    $0x8,%esp
  80142b:	53                   	push   %ebx
  80142c:	ff 75 e0             	pushl  -0x20(%ebp)
  80142f:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801431:	83 ef 01             	sub    $0x1,%edi
  801434:	83 c4 10             	add    $0x10,%esp
  801437:	85 ff                	test   %edi,%edi
  801439:	7f ed                	jg     801428 <vprintfmt+0x1c5>
  80143b:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80143e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801441:	89 c8                	mov    %ecx,%eax
  801443:	c1 f8 1f             	sar    $0x1f,%eax
  801446:	f7 d0                	not    %eax
  801448:	21 c8                	and    %ecx,%eax
  80144a:	29 c1                	sub    %eax,%ecx
  80144c:	89 75 08             	mov    %esi,0x8(%ebp)
  80144f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801452:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801455:	89 cb                	mov    %ecx,%ebx
  801457:	eb 4d                	jmp    8014a6 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801459:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80145d:	74 1b                	je     80147a <vprintfmt+0x217>
  80145f:	0f be c0             	movsbl %al,%eax
  801462:	83 e8 20             	sub    $0x20,%eax
  801465:	83 f8 5e             	cmp    $0x5e,%eax
  801468:	76 10                	jbe    80147a <vprintfmt+0x217>
					putch('?', putdat);
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	ff 75 0c             	pushl  0xc(%ebp)
  801470:	6a 3f                	push   $0x3f
  801472:	ff 55 08             	call   *0x8(%ebp)
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	eb 0d                	jmp    801487 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  80147a:	83 ec 08             	sub    $0x8,%esp
  80147d:	ff 75 0c             	pushl  0xc(%ebp)
  801480:	52                   	push   %edx
  801481:	ff 55 08             	call   *0x8(%ebp)
  801484:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801487:	83 eb 01             	sub    $0x1,%ebx
  80148a:	eb 1a                	jmp    8014a6 <vprintfmt+0x243>
  80148c:	89 75 08             	mov    %esi,0x8(%ebp)
  80148f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801492:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801495:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801498:	eb 0c                	jmp    8014a6 <vprintfmt+0x243>
  80149a:	89 75 08             	mov    %esi,0x8(%ebp)
  80149d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8014a0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a6:	83 c7 01             	add    $0x1,%edi
  8014a9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ad:	0f be d0             	movsbl %al,%edx
  8014b0:	85 d2                	test   %edx,%edx
  8014b2:	74 23                	je     8014d7 <vprintfmt+0x274>
  8014b4:	85 f6                	test   %esi,%esi
  8014b6:	78 a1                	js     801459 <vprintfmt+0x1f6>
  8014b8:	83 ee 01             	sub    $0x1,%esi
  8014bb:	79 9c                	jns    801459 <vprintfmt+0x1f6>
  8014bd:	89 df                	mov    %ebx,%edi
  8014bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c5:	eb 18                	jmp    8014df <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	53                   	push   %ebx
  8014cb:	6a 20                	push   $0x20
  8014cd:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014cf:	83 ef 01             	sub    $0x1,%edi
  8014d2:	83 c4 10             	add    $0x10,%esp
  8014d5:	eb 08                	jmp    8014df <vprintfmt+0x27c>
  8014d7:	89 df                	mov    %ebx,%edi
  8014d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014df:	85 ff                	test   %edi,%edi
  8014e1:	7f e4                	jg     8014c7 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e6:	e9 9e fd ff ff       	jmp    801289 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014eb:	83 fa 01             	cmp    $0x1,%edx
  8014ee:	7e 16                	jle    801506 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8014f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f3:	8d 50 08             	lea    0x8(%eax),%edx
  8014f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f9:	8b 50 04             	mov    0x4(%eax),%edx
  8014fc:	8b 00                	mov    (%eax),%eax
  8014fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801501:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801504:	eb 32                	jmp    801538 <vprintfmt+0x2d5>
	else if (lflag)
  801506:	85 d2                	test   %edx,%edx
  801508:	74 18                	je     801522 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80150a:	8b 45 14             	mov    0x14(%ebp),%eax
  80150d:	8d 50 04             	lea    0x4(%eax),%edx
  801510:	89 55 14             	mov    %edx,0x14(%ebp)
  801513:	8b 00                	mov    (%eax),%eax
  801515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801518:	89 c1                	mov    %eax,%ecx
  80151a:	c1 f9 1f             	sar    $0x1f,%ecx
  80151d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801520:	eb 16                	jmp    801538 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801522:	8b 45 14             	mov    0x14(%ebp),%eax
  801525:	8d 50 04             	lea    0x4(%eax),%edx
  801528:	89 55 14             	mov    %edx,0x14(%ebp)
  80152b:	8b 00                	mov    (%eax),%eax
  80152d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801530:	89 c1                	mov    %eax,%ecx
  801532:	c1 f9 1f             	sar    $0x1f,%ecx
  801535:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801538:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80153b:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80153e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801543:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801547:	79 74                	jns    8015bd <vprintfmt+0x35a>
				putch('-', putdat);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	53                   	push   %ebx
  80154d:	6a 2d                	push   $0x2d
  80154f:	ff d6                	call   *%esi
				num = -(long long) num;
  801551:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801554:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801557:	f7 d8                	neg    %eax
  801559:	83 d2 00             	adc    $0x0,%edx
  80155c:	f7 da                	neg    %edx
  80155e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801561:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801566:	eb 55                	jmp    8015bd <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801568:	8d 45 14             	lea    0x14(%ebp),%eax
  80156b:	e8 7f fc ff ff       	call   8011ef <getuint>
			base = 10;
  801570:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801575:	eb 46                	jmp    8015bd <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801577:	8d 45 14             	lea    0x14(%ebp),%eax
  80157a:	e8 70 fc ff ff       	call   8011ef <getuint>
			base = 8;
  80157f:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801584:	eb 37                	jmp    8015bd <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  801586:	83 ec 08             	sub    $0x8,%esp
  801589:	53                   	push   %ebx
  80158a:	6a 30                	push   $0x30
  80158c:	ff d6                	call   *%esi
			putch('x', putdat);
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	53                   	push   %ebx
  801592:	6a 78                	push   $0x78
  801594:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801596:	8b 45 14             	mov    0x14(%ebp),%eax
  801599:	8d 50 04             	lea    0x4(%eax),%edx
  80159c:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80159f:	8b 00                	mov    (%eax),%eax
  8015a1:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015a6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015a9:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8015ae:	eb 0d                	jmp    8015bd <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015b0:	8d 45 14             	lea    0x14(%ebp),%eax
  8015b3:	e8 37 fc ff ff       	call   8011ef <getuint>
			base = 16;
  8015b8:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015bd:	83 ec 0c             	sub    $0xc,%esp
  8015c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8015c4:	57                   	push   %edi
  8015c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8015c8:	51                   	push   %ecx
  8015c9:	52                   	push   %edx
  8015ca:	50                   	push   %eax
  8015cb:	89 da                	mov    %ebx,%edx
  8015cd:	89 f0                	mov    %esi,%eax
  8015cf:	e8 71 fb ff ff       	call   801145 <printnum>
			break;
  8015d4:	83 c4 20             	add    $0x20,%esp
  8015d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015da:	e9 aa fc ff ff       	jmp    801289 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	53                   	push   %ebx
  8015e3:	51                   	push   %ecx
  8015e4:	ff d6                	call   *%esi
			break;
  8015e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8015e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8015ec:	e9 98 fc ff ff       	jmp    801289 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	53                   	push   %ebx
  8015f5:	6a 25                	push   $0x25
  8015f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	eb 03                	jmp    801601 <vprintfmt+0x39e>
  8015fe:	83 ef 01             	sub    $0x1,%edi
  801601:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801605:	75 f7                	jne    8015fe <vprintfmt+0x39b>
  801607:	e9 7d fc ff ff       	jmp    801289 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80160c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80160f:	5b                   	pop    %ebx
  801610:	5e                   	pop    %esi
  801611:	5f                   	pop    %edi
  801612:	5d                   	pop    %ebp
  801613:	c3                   	ret    

00801614 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	83 ec 18             	sub    $0x18,%esp
  80161a:	8b 45 08             	mov    0x8(%ebp),%eax
  80161d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801620:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801623:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801627:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80162a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801631:	85 c0                	test   %eax,%eax
  801633:	74 26                	je     80165b <vsnprintf+0x47>
  801635:	85 d2                	test   %edx,%edx
  801637:	7e 22                	jle    80165b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801639:	ff 75 14             	pushl  0x14(%ebp)
  80163c:	ff 75 10             	pushl  0x10(%ebp)
  80163f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801642:	50                   	push   %eax
  801643:	68 29 12 80 00       	push   $0x801229
  801648:	e8 16 fc ff ff       	call   801263 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80164d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801650:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801653:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb 05                	jmp    801660 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80165b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801660:	c9                   	leave  
  801661:	c3                   	ret    

00801662 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801668:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166b:	50                   	push   %eax
  80166c:	ff 75 10             	pushl  0x10(%ebp)
  80166f:	ff 75 0c             	pushl  0xc(%ebp)
  801672:	ff 75 08             	pushl  0x8(%ebp)
  801675:	e8 9a ff ff ff       	call   801614 <vsnprintf>
	va_end(ap);

	return rc;
}
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    

0080167c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801682:	b8 00 00 00 00       	mov    $0x0,%eax
  801687:	eb 03                	jmp    80168c <strlen+0x10>
		n++;
  801689:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80168c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801690:	75 f7                	jne    801689 <strlen+0xd>
		n++;
	return n;
}
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    

00801694 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169d:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a2:	eb 03                	jmp    8016a7 <strnlen+0x13>
		n++;
  8016a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a7:	39 c2                	cmp    %eax,%edx
  8016a9:	74 08                	je     8016b3 <strnlen+0x1f>
  8016ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016af:	75 f3                	jne    8016a4 <strnlen+0x10>
  8016b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	53                   	push   %ebx
  8016b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8016bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016bf:	89 c2                	mov    %eax,%edx
  8016c1:	83 c2 01             	add    $0x1,%edx
  8016c4:	83 c1 01             	add    $0x1,%ecx
  8016c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ce:	84 db                	test   %bl,%bl
  8016d0:	75 ef                	jne    8016c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016d2:	5b                   	pop    %ebx
  8016d3:	5d                   	pop    %ebp
  8016d4:	c3                   	ret    

008016d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016dc:	53                   	push   %ebx
  8016dd:	e8 9a ff ff ff       	call   80167c <strlen>
  8016e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8016e5:	ff 75 0c             	pushl  0xc(%ebp)
  8016e8:	01 d8                	add    %ebx,%eax
  8016ea:	50                   	push   %eax
  8016eb:	e8 c5 ff ff ff       	call   8016b5 <strcpy>
	return dst;
}
  8016f0:	89 d8                	mov    %ebx,%eax
  8016f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f5:	c9                   	leave  
  8016f6:	c3                   	ret    

008016f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f7:	55                   	push   %ebp
  8016f8:	89 e5                	mov    %esp,%ebp
  8016fa:	56                   	push   %esi
  8016fb:	53                   	push   %ebx
  8016fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801702:	89 f3                	mov    %esi,%ebx
  801704:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801707:	89 f2                	mov    %esi,%edx
  801709:	eb 0f                	jmp    80171a <strncpy+0x23>
		*dst++ = *src;
  80170b:	83 c2 01             	add    $0x1,%edx
  80170e:	0f b6 01             	movzbl (%ecx),%eax
  801711:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801714:	80 39 01             	cmpb   $0x1,(%ecx)
  801717:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80171a:	39 da                	cmp    %ebx,%edx
  80171c:	75 ed                	jne    80170b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80171e:	89 f0                	mov    %esi,%eax
  801720:	5b                   	pop    %ebx
  801721:	5e                   	pop    %esi
  801722:	5d                   	pop    %ebp
  801723:	c3                   	ret    

00801724 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	8b 75 08             	mov    0x8(%ebp),%esi
  80172c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172f:	8b 55 10             	mov    0x10(%ebp),%edx
  801732:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801734:	85 d2                	test   %edx,%edx
  801736:	74 21                	je     801759 <strlcpy+0x35>
  801738:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173c:	89 f2                	mov    %esi,%edx
  80173e:	eb 09                	jmp    801749 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801740:	83 c2 01             	add    $0x1,%edx
  801743:	83 c1 01             	add    $0x1,%ecx
  801746:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801749:	39 c2                	cmp    %eax,%edx
  80174b:	74 09                	je     801756 <strlcpy+0x32>
  80174d:	0f b6 19             	movzbl (%ecx),%ebx
  801750:	84 db                	test   %bl,%bl
  801752:	75 ec                	jne    801740 <strlcpy+0x1c>
  801754:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801756:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801759:	29 f0                	sub    %esi,%eax
}
  80175b:	5b                   	pop    %ebx
  80175c:	5e                   	pop    %esi
  80175d:	5d                   	pop    %ebp
  80175e:	c3                   	ret    

0080175f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801765:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801768:	eb 06                	jmp    801770 <strcmp+0x11>
		p++, q++;
  80176a:	83 c1 01             	add    $0x1,%ecx
  80176d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801770:	0f b6 01             	movzbl (%ecx),%eax
  801773:	84 c0                	test   %al,%al
  801775:	74 04                	je     80177b <strcmp+0x1c>
  801777:	3a 02                	cmp    (%edx),%al
  801779:	74 ef                	je     80176a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177b:	0f b6 c0             	movzbl %al,%eax
  80177e:	0f b6 12             	movzbl (%edx),%edx
  801781:	29 d0                	sub    %edx,%eax
}
  801783:	5d                   	pop    %ebp
  801784:	c3                   	ret    

00801785 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	53                   	push   %ebx
  801789:	8b 45 08             	mov    0x8(%ebp),%eax
  80178c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178f:	89 c3                	mov    %eax,%ebx
  801791:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801794:	eb 06                	jmp    80179c <strncmp+0x17>
		n--, p++, q++;
  801796:	83 c0 01             	add    $0x1,%eax
  801799:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80179c:	39 d8                	cmp    %ebx,%eax
  80179e:	74 15                	je     8017b5 <strncmp+0x30>
  8017a0:	0f b6 08             	movzbl (%eax),%ecx
  8017a3:	84 c9                	test   %cl,%cl
  8017a5:	74 04                	je     8017ab <strncmp+0x26>
  8017a7:	3a 0a                	cmp    (%edx),%cl
  8017a9:	74 eb                	je     801796 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ab:	0f b6 00             	movzbl (%eax),%eax
  8017ae:	0f b6 12             	movzbl (%edx),%edx
  8017b1:	29 d0                	sub    %edx,%eax
  8017b3:	eb 05                	jmp    8017ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017ba:	5b                   	pop    %ebx
  8017bb:	5d                   	pop    %ebp
  8017bc:	c3                   	ret    

008017bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017bd:	55                   	push   %ebp
  8017be:	89 e5                	mov    %esp,%ebp
  8017c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c7:	eb 07                	jmp    8017d0 <strchr+0x13>
		if (*s == c)
  8017c9:	38 ca                	cmp    %cl,%dl
  8017cb:	74 0f                	je     8017dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017cd:	83 c0 01             	add    $0x1,%eax
  8017d0:	0f b6 10             	movzbl (%eax),%edx
  8017d3:	84 d2                	test   %dl,%dl
  8017d5:	75 f2                	jne    8017c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e8:	eb 03                	jmp    8017ed <strfind+0xf>
  8017ea:	83 c0 01             	add    $0x1,%eax
  8017ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f0:	84 d2                	test   %dl,%dl
  8017f2:	74 04                	je     8017f8 <strfind+0x1a>
  8017f4:	38 ca                	cmp    %cl,%dl
  8017f6:	75 f2                	jne    8017ea <strfind+0xc>
			break;
	return (char *) s;
}
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    

008017fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fa:	55                   	push   %ebp
  8017fb:	89 e5                	mov    %esp,%ebp
  8017fd:	57                   	push   %edi
  8017fe:	56                   	push   %esi
  8017ff:	53                   	push   %ebx
  801800:	8b 7d 08             	mov    0x8(%ebp),%edi
  801803:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  801806:	85 c9                	test   %ecx,%ecx
  801808:	74 36                	je     801840 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801810:	75 28                	jne    80183a <memset+0x40>
  801812:	f6 c1 03             	test   $0x3,%cl
  801815:	75 23                	jne    80183a <memset+0x40>
		c &= 0xFF;
  801817:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181b:	89 d3                	mov    %edx,%ebx
  80181d:	c1 e3 08             	shl    $0x8,%ebx
  801820:	89 d6                	mov    %edx,%esi
  801822:	c1 e6 18             	shl    $0x18,%esi
  801825:	89 d0                	mov    %edx,%eax
  801827:	c1 e0 10             	shl    $0x10,%eax
  80182a:	09 f0                	or     %esi,%eax
  80182c:	09 c2                	or     %eax,%edx
  80182e:	89 d0                	mov    %edx,%eax
  801830:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801832:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  801835:	fc                   	cld    
  801836:	f3 ab                	rep stos %eax,%es:(%edi)
  801838:	eb 06                	jmp    801840 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183d:	fc                   	cld    
  80183e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801840:	89 f8                	mov    %edi,%eax
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	57                   	push   %edi
  80184b:	56                   	push   %esi
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801852:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801855:	39 c6                	cmp    %eax,%esi
  801857:	73 35                	jae    80188e <memmove+0x47>
  801859:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185c:	39 d0                	cmp    %edx,%eax
  80185e:	73 2e                	jae    80188e <memmove+0x47>
		s += n;
		d += n;
  801860:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801863:	89 d6                	mov    %edx,%esi
  801865:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801867:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186d:	75 13                	jne    801882 <memmove+0x3b>
  80186f:	f6 c1 03             	test   $0x3,%cl
  801872:	75 0e                	jne    801882 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801874:	83 ef 04             	sub    $0x4,%edi
  801877:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187a:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80187d:	fd                   	std    
  80187e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801880:	eb 09                	jmp    80188b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801882:	83 ef 01             	sub    $0x1,%edi
  801885:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801888:	fd                   	std    
  801889:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188b:	fc                   	cld    
  80188c:	eb 1d                	jmp    8018ab <memmove+0x64>
  80188e:	89 f2                	mov    %esi,%edx
  801890:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801892:	f6 c2 03             	test   $0x3,%dl
  801895:	75 0f                	jne    8018a6 <memmove+0x5f>
  801897:	f6 c1 03             	test   $0x3,%cl
  80189a:	75 0a                	jne    8018a6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80189c:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80189f:	89 c7                	mov    %eax,%edi
  8018a1:	fc                   	cld    
  8018a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a4:	eb 05                	jmp    8018ab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018a6:	89 c7                	mov    %eax,%edi
  8018a8:	fc                   	cld    
  8018a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ab:	5e                   	pop    %esi
  8018ac:	5f                   	pop    %edi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018b2:	ff 75 10             	pushl  0x10(%ebp)
  8018b5:	ff 75 0c             	pushl  0xc(%ebp)
  8018b8:	ff 75 08             	pushl  0x8(%ebp)
  8018bb:	e8 87 ff ff ff       	call   801847 <memmove>
}
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	56                   	push   %esi
  8018c6:	53                   	push   %ebx
  8018c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018cd:	89 c6                	mov    %eax,%esi
  8018cf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018d2:	eb 1a                	jmp    8018ee <memcmp+0x2c>
		if (*s1 != *s2)
  8018d4:	0f b6 08             	movzbl (%eax),%ecx
  8018d7:	0f b6 1a             	movzbl (%edx),%ebx
  8018da:	38 d9                	cmp    %bl,%cl
  8018dc:	74 0a                	je     8018e8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018de:	0f b6 c1             	movzbl %cl,%eax
  8018e1:	0f b6 db             	movzbl %bl,%ebx
  8018e4:	29 d8                	sub    %ebx,%eax
  8018e6:	eb 0f                	jmp    8018f7 <memcmp+0x35>
		s1++, s2++;
  8018e8:	83 c0 01             	add    $0x1,%eax
  8018eb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ee:	39 f0                	cmp    %esi,%eax
  8018f0:	75 e2                	jne    8018d4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f7:	5b                   	pop    %ebx
  8018f8:	5e                   	pop    %esi
  8018f9:	5d                   	pop    %ebp
  8018fa:	c3                   	ret    

008018fb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018fb:	55                   	push   %ebp
  8018fc:	89 e5                	mov    %esp,%ebp
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801904:	89 c2                	mov    %eax,%edx
  801906:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801909:	eb 07                	jmp    801912 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190b:	38 08                	cmp    %cl,(%eax)
  80190d:	74 07                	je     801916 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80190f:	83 c0 01             	add    $0x1,%eax
  801912:	39 d0                	cmp    %edx,%eax
  801914:	72 f5                	jb     80190b <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801916:	5d                   	pop    %ebp
  801917:	c3                   	ret    

00801918 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	57                   	push   %edi
  80191c:	56                   	push   %esi
  80191d:	53                   	push   %ebx
  80191e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801921:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801924:	eb 03                	jmp    801929 <strtol+0x11>
		s++;
  801926:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801929:	0f b6 01             	movzbl (%ecx),%eax
  80192c:	3c 09                	cmp    $0x9,%al
  80192e:	74 f6                	je     801926 <strtol+0xe>
  801930:	3c 20                	cmp    $0x20,%al
  801932:	74 f2                	je     801926 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801934:	3c 2b                	cmp    $0x2b,%al
  801936:	75 0a                	jne    801942 <strtol+0x2a>
		s++;
  801938:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80193b:	bf 00 00 00 00       	mov    $0x0,%edi
  801940:	eb 10                	jmp    801952 <strtol+0x3a>
  801942:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801947:	3c 2d                	cmp    $0x2d,%al
  801949:	75 07                	jne    801952 <strtol+0x3a>
		s++, neg = 1;
  80194b:	8d 49 01             	lea    0x1(%ecx),%ecx
  80194e:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801952:	85 db                	test   %ebx,%ebx
  801954:	0f 94 c0             	sete   %al
  801957:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80195d:	75 19                	jne    801978 <strtol+0x60>
  80195f:	80 39 30             	cmpb   $0x30,(%ecx)
  801962:	75 14                	jne    801978 <strtol+0x60>
  801964:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801968:	0f 85 8a 00 00 00    	jne    8019f8 <strtol+0xe0>
		s += 2, base = 16;
  80196e:	83 c1 02             	add    $0x2,%ecx
  801971:	bb 10 00 00 00       	mov    $0x10,%ebx
  801976:	eb 16                	jmp    80198e <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801978:	84 c0                	test   %al,%al
  80197a:	74 12                	je     80198e <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80197c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801981:	80 39 30             	cmpb   $0x30,(%ecx)
  801984:	75 08                	jne    80198e <strtol+0x76>
		s++, base = 8;
  801986:	83 c1 01             	add    $0x1,%ecx
  801989:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80198e:	b8 00 00 00 00       	mov    $0x0,%eax
  801993:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801996:	0f b6 11             	movzbl (%ecx),%edx
  801999:	8d 72 d0             	lea    -0x30(%edx),%esi
  80199c:	89 f3                	mov    %esi,%ebx
  80199e:	80 fb 09             	cmp    $0x9,%bl
  8019a1:	77 08                	ja     8019ab <strtol+0x93>
			dig = *s - '0';
  8019a3:	0f be d2             	movsbl %dl,%edx
  8019a6:	83 ea 30             	sub    $0x30,%edx
  8019a9:	eb 22                	jmp    8019cd <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8019ab:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019ae:	89 f3                	mov    %esi,%ebx
  8019b0:	80 fb 19             	cmp    $0x19,%bl
  8019b3:	77 08                	ja     8019bd <strtol+0xa5>
			dig = *s - 'a' + 10;
  8019b5:	0f be d2             	movsbl %dl,%edx
  8019b8:	83 ea 57             	sub    $0x57,%edx
  8019bb:	eb 10                	jmp    8019cd <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  8019bd:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019c0:	89 f3                	mov    %esi,%ebx
  8019c2:	80 fb 19             	cmp    $0x19,%bl
  8019c5:	77 16                	ja     8019dd <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019c7:	0f be d2             	movsbl %dl,%edx
  8019ca:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019cd:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019d0:	7d 0f                	jge    8019e1 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  8019d2:	83 c1 01             	add    $0x1,%ecx
  8019d5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d9:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019db:	eb b9                	jmp    801996 <strtol+0x7e>
  8019dd:	89 c2                	mov    %eax,%edx
  8019df:	eb 02                	jmp    8019e3 <strtol+0xcb>
  8019e1:	89 c2                	mov    %eax,%edx

	if (endptr)
  8019e3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019e7:	74 05                	je     8019ee <strtol+0xd6>
		*endptr = (char *) s;
  8019e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019ec:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019ee:	85 ff                	test   %edi,%edi
  8019f0:	74 0c                	je     8019fe <strtol+0xe6>
  8019f2:	89 d0                	mov    %edx,%eax
  8019f4:	f7 d8                	neg    %eax
  8019f6:	eb 06                	jmp    8019fe <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019f8:	84 c0                	test   %al,%al
  8019fa:	75 8a                	jne    801986 <strtol+0x6e>
  8019fc:	eb 90                	jmp    80198e <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	56                   	push   %esi
  801a07:	53                   	push   %ebx
  801a08:	8b 75 08             	mov    0x8(%ebp),%esi
  801a0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801a11:	85 f6                	test   %esi,%esi
  801a13:	74 06                	je     801a1b <ipc_recv+0x18>
  801a15:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801a1b:	85 db                	test   %ebx,%ebx
  801a1d:	74 06                	je     801a25 <ipc_recv+0x22>
  801a1f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801a25:	83 f8 01             	cmp    $0x1,%eax
  801a28:	19 d2                	sbb    %edx,%edx
  801a2a:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	50                   	push   %eax
  801a30:	e8 de e8 ff ff       	call   800313 <sys_ipc_recv>
  801a35:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	85 d2                	test   %edx,%edx
  801a3c:	75 24                	jne    801a62 <ipc_recv+0x5f>
	if (from_env_store)
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	74 0a                	je     801a4c <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801a42:	a1 04 40 80 00       	mov    0x804004,%eax
  801a47:	8b 40 70             	mov    0x70(%eax),%eax
  801a4a:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801a4c:	85 db                	test   %ebx,%ebx
  801a4e:	74 0a                	je     801a5a <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801a50:	a1 04 40 80 00       	mov    0x804004,%eax
  801a55:	8b 40 74             	mov    0x74(%eax),%eax
  801a58:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801a5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5f:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801a62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	57                   	push   %edi
  801a6d:	56                   	push   %esi
  801a6e:	53                   	push   %ebx
  801a6f:	83 ec 0c             	sub    $0xc,%esp
  801a72:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a75:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801a7b:	83 fb 01             	cmp    $0x1,%ebx
  801a7e:	19 c0                	sbb    %eax,%eax
  801a80:	09 c3                	or     %eax,%ebx
  801a82:	eb 1c                	jmp    801aa0 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801a84:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a87:	74 12                	je     801a9b <ipc_send+0x32>
  801a89:	50                   	push   %eax
  801a8a:	68 a0 22 80 00       	push   $0x8022a0
  801a8f:	6a 36                	push   $0x36
  801a91:	68 b7 22 80 00       	push   $0x8022b7
  801a96:	e8 bd f5 ff ff       	call   801058 <_panic>
		sys_yield();
  801a9b:	e8 a4 e6 ff ff       	call   800144 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801aa0:	ff 75 14             	pushl  0x14(%ebp)
  801aa3:	53                   	push   %ebx
  801aa4:	56                   	push   %esi
  801aa5:	57                   	push   %edi
  801aa6:	e8 45 e8 ff ff       	call   8002f0 <sys_ipc_try_send>
		if (ret == 0) break;
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	75 d2                	jne    801a84 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801ab2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab5:	5b                   	pop    %ebx
  801ab6:	5e                   	pop    %esi
  801ab7:	5f                   	pop    %edi
  801ab8:	5d                   	pop    %ebp
  801ab9:	c3                   	ret    

00801aba <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aba:	55                   	push   %ebp
  801abb:	89 e5                	mov    %esp,%ebp
  801abd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac0:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac5:	6b d0 78             	imul   $0x78,%eax,%edx
  801ac8:	83 c2 50             	add    $0x50,%edx
  801acb:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801ad1:	39 ca                	cmp    %ecx,%edx
  801ad3:	75 0d                	jne    801ae2 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ad5:	6b c0 78             	imul   $0x78,%eax,%eax
  801ad8:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801add:	8b 40 08             	mov    0x8(%eax),%eax
  801ae0:	eb 0e                	jmp    801af0 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae2:	83 c0 01             	add    $0x1,%eax
  801ae5:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aea:	75 d9                	jne    801ac5 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aec:	66 b8 00 00          	mov    $0x0,%ax
}
  801af0:	5d                   	pop    %ebp
  801af1:	c3                   	ret    

00801af2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af2:	55                   	push   %ebp
  801af3:	89 e5                	mov    %esp,%ebp
  801af5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801af8:	89 d0                	mov    %edx,%eax
  801afa:	c1 e8 16             	shr    $0x16,%eax
  801afd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b04:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b09:	f6 c1 01             	test   $0x1,%cl
  801b0c:	74 1d                	je     801b2b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b0e:	c1 ea 0c             	shr    $0xc,%edx
  801b11:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b18:	f6 c2 01             	test   $0x1,%dl
  801b1b:	74 0e                	je     801b2b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b1d:	c1 ea 0c             	shr    $0xc,%edx
  801b20:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b27:	ef 
  801b28:	0f b7 c0             	movzwl %ax,%eax
}
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    
  801b2d:	66 90                	xchg   %ax,%ax
  801b2f:	90                   	nop

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
