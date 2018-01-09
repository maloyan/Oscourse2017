
obj/user/ls:     file format elf32-i386


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
  80002c:	e8 92 02 00 00       	call   8002c3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ls1>:
		panic("error reading directory %s: %i", path, n);
}

void
ls1(const char *prefix, bool isdir, off_t size, const char *name)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003b:	8b 75 0c             	mov    0xc(%ebp),%esi
	const char *sep;

	if(flag['l'])
  80003e:	83 3d f0 41 80 00 00 	cmpl   $0x0,0x8041f0
  800045:	74 20                	je     800067 <ls1+0x34>
		printf("%11d %c ", size, isdir ? 'd' : '-');
  800047:	89 f0                	mov    %esi,%eax
  800049:	3c 01                	cmp    $0x1,%al
  80004b:	19 c0                	sbb    %eax,%eax
  80004d:	83 e0 c9             	and    $0xffffffc9,%eax
  800050:	83 c0 64             	add    $0x64,%eax
  800053:	83 ec 04             	sub    $0x4,%esp
  800056:	50                   	push   %eax
  800057:	ff 75 10             	pushl  0x10(%ebp)
  80005a:	68 02 23 80 00       	push   $0x802302
  80005f:	e8 96 19 00 00       	call   8019fa <printf>
  800064:	83 c4 10             	add    $0x10,%esp
	if(prefix) {
  800067:	85 db                	test   %ebx,%ebx
  800069:	74 39                	je     8000a4 <ls1+0x71>
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
			sep = "/";
		else
			sep = "";
  80006b:	ba 68 23 80 00       	mov    $0x802368,%edx
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800070:	80 3b 00             	cmpb   $0x0,(%ebx)
  800073:	74 1d                	je     800092 <ls1+0x5f>
  800075:	83 ec 0c             	sub    $0xc,%esp
  800078:	53                   	push   %ebx
  800079:	e8 c9 08 00 00       	call   800947 <strlen>
  80007e:	83 c4 10             	add    $0x10,%esp
			sep = "/";
  800081:	ba 00 23 80 00       	mov    $0x802300,%edx
	const char *sep;

	if(flag['l'])
		printf("%11d %c ", size, isdir ? 'd' : '-');
	if(prefix) {
		if (prefix[0] && prefix[strlen(prefix)-1] != '/')
  800086:	80 7c 03 ff 2f       	cmpb   $0x2f,-0x1(%ebx,%eax,1)
  80008b:	75 05                	jne    800092 <ls1+0x5f>
			sep = "/";
		else
			sep = "";
  80008d:	ba 68 23 80 00       	mov    $0x802368,%edx
		printf("%s%s", prefix, sep);
  800092:	83 ec 04             	sub    $0x4,%esp
  800095:	52                   	push   %edx
  800096:	53                   	push   %ebx
  800097:	68 0b 23 80 00       	push   $0x80230b
  80009c:	e8 59 19 00 00       	call   8019fa <printf>
  8000a1:	83 c4 10             	add    $0x10,%esp
	}
	printf("%s", name);
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	ff 75 14             	pushl  0x14(%ebp)
  8000aa:	68 b1 27 80 00       	push   $0x8027b1
  8000af:	e8 46 19 00 00       	call   8019fa <printf>
	if(flag['F'] && isdir)
  8000b4:	83 c4 10             	add    $0x10,%esp
  8000b7:	89 f0                	mov    %esi,%eax
  8000b9:	84 c0                	test   %al,%al
  8000bb:	74 19                	je     8000d6 <ls1+0xa3>
  8000bd:	83 3d 58 41 80 00 00 	cmpl   $0x0,0x804158
  8000c4:	74 10                	je     8000d6 <ls1+0xa3>
		printf("/");
  8000c6:	83 ec 0c             	sub    $0xc,%esp
  8000c9:	68 00 23 80 00       	push   $0x802300
  8000ce:	e8 27 19 00 00       	call   8019fa <printf>
  8000d3:	83 c4 10             	add    $0x10,%esp
	printf("\n");
  8000d6:	83 ec 0c             	sub    $0xc,%esp
  8000d9:	68 67 23 80 00       	push   $0x802367
  8000de:	e8 17 19 00 00       	call   8019fa <printf>
  8000e3:	83 c4 10             	add    $0x10,%esp
}
  8000e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e9:	5b                   	pop    %ebx
  8000ea:	5e                   	pop    %esi
  8000eb:	5d                   	pop    %ebp
  8000ec:	c3                   	ret    

008000ed <lsdir>:
		ls1(0, st.st_isdir, st.st_size, path);
}

void
lsdir(const char *path, const char *prefix)
{
  8000ed:	55                   	push   %ebp
  8000ee:	89 e5                	mov    %esp,%ebp
  8000f0:	57                   	push   %edi
  8000f1:	56                   	push   %esi
  8000f2:	53                   	push   %ebx
  8000f3:	81 ec 14 01 00 00    	sub    $0x114,%esp
  8000f9:	8b 7d 08             	mov    0x8(%ebp),%edi
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
  8000fc:	6a 00                	push   $0x0
  8000fe:	57                   	push   %edi
  8000ff:	e8 54 17 00 00       	call   801858 <open>
  800104:	89 c3                	mov    %eax,%ebx
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	85 c0                	test   %eax,%eax
  80010b:	79 41                	jns    80014e <lsdir+0x61>
		panic("open %s: %i", path, fd);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	57                   	push   %edi
  800112:	68 10 23 80 00       	push   $0x802310
  800117:	6a 1d                	push   $0x1d
  800119:	68 1c 23 80 00       	push   $0x80231c
  80011e:	e8 00 02 00 00       	call   800323 <_panic>
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
		if (f.f_name[0])
  800123:	80 bd e8 fe ff ff 00 	cmpb   $0x0,-0x118(%ebp)
  80012a:	74 28                	je     800154 <lsdir+0x67>
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
  80012c:	56                   	push   %esi
  80012d:	ff b5 68 ff ff ff    	pushl  -0x98(%ebp)
  800133:	83 bd 6c ff ff ff 01 	cmpl   $0x1,-0x94(%ebp)
  80013a:	0f 94 c0             	sete   %al
  80013d:	0f b6 c0             	movzbl %al,%eax
  800140:	50                   	push   %eax
  800141:	ff 75 0c             	pushl  0xc(%ebp)
  800144:	e8 ea fe ff ff       	call   800033 <ls1>
  800149:	83 c4 10             	add    $0x10,%esp
  80014c:	eb 06                	jmp    800154 <lsdir+0x67>
	int fd, n;
	struct File f;

	if ((fd = open(path, O_RDONLY)) < 0)
		panic("open %s: %i", path, fd);
	while ((n = readn(fd, &f, sizeof f)) == sizeof f)
  80014e:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
  800154:	83 ec 04             	sub    $0x4,%esp
  800157:	68 00 01 00 00       	push   $0x100
  80015c:	56                   	push   %esi
  80015d:	53                   	push   %ebx
  80015e:	e8 fb 12 00 00       	call   80145e <readn>
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	3d 00 01 00 00       	cmp    $0x100,%eax
  80016b:	74 b6                	je     800123 <lsdir+0x36>
		if (f.f_name[0])
			ls1(prefix, f.f_type==FTYPE_DIR, f.f_size, f.f_name);
	if (n > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7e 12                	jle    800183 <lsdir+0x96>
		panic("short read in directory %s", path);
  800171:	57                   	push   %edi
  800172:	68 26 23 80 00       	push   $0x802326
  800177:	6a 22                	push   $0x22
  800179:	68 1c 23 80 00       	push   $0x80231c
  80017e:	e8 a0 01 00 00       	call   800323 <_panic>
	if (n < 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	79 16                	jns    80019d <lsdir+0xb0>
		panic("error reading directory %s: %i", path, n);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	57                   	push   %edi
  80018c:	68 6c 23 80 00       	push   $0x80236c
  800191:	6a 24                	push   $0x24
  800193:	68 1c 23 80 00       	push   $0x80231c
  800198:	e8 86 01 00 00       	call   800323 <_panic>
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <ls>:
void lsdir(const char*, const char*);
void ls1(const char*, bool, off_t, const char*);

void
ls(const char *path, const char *prefix)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	53                   	push   %ebx
  8001a9:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  8001af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Stat st;

	if ((r = stat(path, &st)) < 0)
  8001b2:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
  8001b8:	50                   	push   %eax
  8001b9:	53                   	push   %ebx
  8001ba:	e8 a0 14 00 00       	call   80165f <stat>
  8001bf:	83 c4 10             	add    $0x10,%esp
  8001c2:	85 c0                	test   %eax,%eax
  8001c4:	79 16                	jns    8001dc <ls+0x37>
		panic("stat %s: %i", path, r);
  8001c6:	83 ec 0c             	sub    $0xc,%esp
  8001c9:	50                   	push   %eax
  8001ca:	53                   	push   %ebx
  8001cb:	68 41 23 80 00       	push   $0x802341
  8001d0:	6a 0f                	push   $0xf
  8001d2:	68 1c 23 80 00       	push   $0x80231c
  8001d7:	e8 47 01 00 00       	call   800323 <_panic>
	if (st.st_isdir && !flag['d'])
  8001dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8001df:	85 c0                	test   %eax,%eax
  8001e1:	74 1a                	je     8001fd <ls+0x58>
  8001e3:	83 3d d0 41 80 00 00 	cmpl   $0x0,0x8041d0
  8001ea:	75 11                	jne    8001fd <ls+0x58>
		lsdir(path, prefix);
  8001ec:	83 ec 08             	sub    $0x8,%esp
  8001ef:	ff 75 0c             	pushl  0xc(%ebp)
  8001f2:	53                   	push   %ebx
  8001f3:	e8 f5 fe ff ff       	call   8000ed <lsdir>
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	eb 17                	jmp    800214 <ls+0x6f>
	else
		ls1(0, st.st_isdir, st.st_size, path);
  8001fd:	53                   	push   %ebx
  8001fe:	ff 75 ec             	pushl  -0x14(%ebp)
  800201:	85 c0                	test   %eax,%eax
  800203:	0f 95 c0             	setne  %al
  800206:	0f b6 c0             	movzbl %al,%eax
  800209:	50                   	push   %eax
  80020a:	6a 00                	push   $0x0
  80020c:	e8 22 fe ff ff       	call   800033 <ls1>
  800211:	83 c4 10             	add    $0x10,%esp
}
  800214:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <usage>:
	printf("\n");
}

void
usage(void)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 14             	sub    $0x14,%esp
	printf("usage: ls [-dFl] [file...]\n");
  80021f:	68 4d 23 80 00       	push   $0x80234d
  800224:	e8 d1 17 00 00       	call   8019fa <printf>
	exit();
  800229:	e8 db 00 00 00       	call   800309 <exit>
  80022e:	83 c4 10             	add    $0x10,%esp
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <umain>:

void
umain(int argc, char **argv)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	56                   	push   %esi
  800237:	53                   	push   %ebx
  800238:	83 ec 14             	sub    $0x14,%esp
  80023b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
  80023e:	8d 45 e8             	lea    -0x18(%ebp),%eax
  800241:	50                   	push   %eax
  800242:	56                   	push   %esi
  800243:	8d 45 08             	lea    0x8(%ebp),%eax
  800246:	50                   	push   %eax
  800247:	e8 4e 0d 00 00       	call   800f9a <argstart>
	while ((i = argnext(&args)) >= 0)
  80024c:	83 c4 10             	add    $0x10,%esp
  80024f:	8d 5d e8             	lea    -0x18(%ebp),%ebx
  800252:	eb 1e                	jmp    800272 <umain+0x3f>
		switch (i) {
  800254:	83 f8 64             	cmp    $0x64,%eax
  800257:	74 0a                	je     800263 <umain+0x30>
  800259:	83 f8 6c             	cmp    $0x6c,%eax
  80025c:	74 05                	je     800263 <umain+0x30>
  80025e:	83 f8 46             	cmp    $0x46,%eax
  800261:	75 0a                	jne    80026d <umain+0x3a>
		case 'd':
		case 'F':
		case 'l':
			flag[i]++;
  800263:	83 04 85 40 40 80 00 	addl   $0x1,0x804040(,%eax,4)
  80026a:	01 
			break;
  80026b:	eb 05                	jmp    800272 <umain+0x3f>
		default:
			usage();
  80026d:	e8 a7 ff ff ff       	call   800219 <usage>
{
	int i;
	struct Argstate args;

	argstart(&argc, argv, &args);
	while ((i = argnext(&args)) >= 0)
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	53                   	push   %ebx
  800276:	e8 4f 0d 00 00       	call   800fca <argnext>
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	85 c0                	test   %eax,%eax
  800280:	79 d2                	jns    800254 <umain+0x21>
  800282:	bb 01 00 00 00       	mov    $0x1,%ebx
			break;
		default:
			usage();
		}

	if (argc == 1)
  800287:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  80028b:	75 2a                	jne    8002b7 <umain+0x84>
		ls("/", "");
  80028d:	83 ec 08             	sub    $0x8,%esp
  800290:	68 68 23 80 00       	push   $0x802368
  800295:	68 00 23 80 00       	push   $0x802300
  80029a:	e8 06 ff ff ff       	call   8001a5 <ls>
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	eb 18                	jmp    8002bc <umain+0x89>
	else {
		for (i = 1; i < argc; i++)
			ls(argv[i], argv[i]);
  8002a4:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
  8002a7:	83 ec 08             	sub    $0x8,%esp
  8002aa:	50                   	push   %eax
  8002ab:	50                   	push   %eax
  8002ac:	e8 f4 fe ff ff       	call   8001a5 <ls>
		}

	if (argc == 1)
		ls("/", "");
	else {
		for (i = 1; i < argc; i++)
  8002b1:	83 c3 01             	add    $0x1,%ebx
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	3b 5d 08             	cmp    0x8(%ebp),%ebx
  8002ba:	7c e8                	jl     8002a4 <umain+0x71>
			ls(argv[i], argv[i]);
	}
}
  8002bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002bf:	5b                   	pop    %ebx
  8002c0:	5e                   	pop    %esi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	56                   	push   %esi
  8002c7:	53                   	push   %ebx
  8002c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002cb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8002ce:	e8 79 0a 00 00       	call   800d4c <sys_getenvid>
  8002d3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002d8:	6b c0 78             	imul   $0x78,%eax,%eax
  8002db:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002e0:	a3 40 44 80 00       	mov    %eax,0x804440

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002e5:	85 db                	test   %ebx,%ebx
  8002e7:	7e 07                	jle    8002f0 <libmain+0x2d>
		binaryname = argv[0];
  8002e9:	8b 06                	mov    (%esi),%eax
  8002eb:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	e8 39 ff ff ff       	call   800233 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8002fa:	e8 0a 00 00 00       	call   800309 <exit>
  8002ff:	83 c4 10             	add    $0x10,%esp
#endif
}
  800302:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80030f:	e8 a6 0f 00 00       	call   8012ba <close_all>
	sys_env_destroy(0);
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	6a 00                	push   $0x0
  800319:	e8 ed 09 00 00       	call   800d0b <sys_env_destroy>
  80031e:	83 c4 10             	add    $0x10,%esp
}
  800321:	c9                   	leave  
  800322:	c3                   	ret    

00800323 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	56                   	push   %esi
  800327:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800328:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80032b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800331:	e8 16 0a 00 00       	call   800d4c <sys_getenvid>
  800336:	83 ec 0c             	sub    $0xc,%esp
  800339:	ff 75 0c             	pushl  0xc(%ebp)
  80033c:	ff 75 08             	pushl  0x8(%ebp)
  80033f:	56                   	push   %esi
  800340:	50                   	push   %eax
  800341:	68 98 23 80 00       	push   $0x802398
  800346:	e8 b1 00 00 00       	call   8003fc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80034b:	83 c4 18             	add    $0x18,%esp
  80034e:	53                   	push   %ebx
  80034f:	ff 75 10             	pushl  0x10(%ebp)
  800352:	e8 54 00 00 00       	call   8003ab <vcprintf>
	cprintf("\n");
  800357:	c7 04 24 67 23 80 00 	movl   $0x802367,(%esp)
  80035e:	e8 99 00 00 00       	call   8003fc <cprintf>
  800363:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800366:	cc                   	int3   
  800367:	eb fd                	jmp    800366 <_panic+0x43>

00800369 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	53                   	push   %ebx
  80036d:	83 ec 04             	sub    $0x4,%esp
  800370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800373:	8b 13                	mov    (%ebx),%edx
  800375:	8d 42 01             	lea    0x1(%edx),%eax
  800378:	89 03                	mov    %eax,(%ebx)
  80037a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800381:	3d ff 00 00 00       	cmp    $0xff,%eax
  800386:	75 1a                	jne    8003a2 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800388:	83 ec 08             	sub    $0x8,%esp
  80038b:	68 ff 00 00 00       	push   $0xff
  800390:	8d 43 08             	lea    0x8(%ebx),%eax
  800393:	50                   	push   %eax
  800394:	e8 35 09 00 00       	call   800cce <sys_cputs>
		b->idx = 0;
  800399:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80039f:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8003a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003b4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003bb:	00 00 00 
	b.cnt = 0;
  8003be:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003c5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003c8:	ff 75 0c             	pushl  0xc(%ebp)
  8003cb:	ff 75 08             	pushl  0x8(%ebp)
  8003ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003d4:	50                   	push   %eax
  8003d5:	68 69 03 80 00       	push   $0x800369
  8003da:	e8 4f 01 00 00       	call   80052e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003df:	83 c4 08             	add    $0x8,%esp
  8003e2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003e8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ee:	50                   	push   %eax
  8003ef:	e8 da 08 00 00       	call   800cce <sys_cputs>

	return b.cnt;
}
  8003f4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800402:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800405:	50                   	push   %eax
  800406:	ff 75 08             	pushl  0x8(%ebp)
  800409:	e8 9d ff ff ff       	call   8003ab <vcprintf>
	va_end(ap);

	return cnt;
}
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	57                   	push   %edi
  800414:	56                   	push   %esi
  800415:	53                   	push   %ebx
  800416:	83 ec 1c             	sub    $0x1c,%esp
  800419:	89 c7                	mov    %eax,%edi
  80041b:	89 d6                	mov    %edx,%esi
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
  800420:	8b 55 0c             	mov    0xc(%ebp),%edx
  800423:	89 d1                	mov    %edx,%ecx
  800425:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800428:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80042b:	8b 45 10             	mov    0x10(%ebp),%eax
  80042e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800434:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80043b:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80043e:	72 05                	jb     800445 <printnum+0x35>
  800440:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800443:	77 3e                	ja     800483 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800445:	83 ec 0c             	sub    $0xc,%esp
  800448:	ff 75 18             	pushl  0x18(%ebp)
  80044b:	83 eb 01             	sub    $0x1,%ebx
  80044e:	53                   	push   %ebx
  80044f:	50                   	push   %eax
  800450:	83 ec 08             	sub    $0x8,%esp
  800453:	ff 75 e4             	pushl  -0x1c(%ebp)
  800456:	ff 75 e0             	pushl  -0x20(%ebp)
  800459:	ff 75 dc             	pushl  -0x24(%ebp)
  80045c:	ff 75 d8             	pushl  -0x28(%ebp)
  80045f:	e8 bc 1b 00 00       	call   802020 <__udivdi3>
  800464:	83 c4 18             	add    $0x18,%esp
  800467:	52                   	push   %edx
  800468:	50                   	push   %eax
  800469:	89 f2                	mov    %esi,%edx
  80046b:	89 f8                	mov    %edi,%eax
  80046d:	e8 9e ff ff ff       	call   800410 <printnum>
  800472:	83 c4 20             	add    $0x20,%esp
  800475:	eb 13                	jmp    80048a <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	56                   	push   %esi
  80047b:	ff 75 18             	pushl  0x18(%ebp)
  80047e:	ff d7                	call   *%edi
  800480:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800483:	83 eb 01             	sub    $0x1,%ebx
  800486:	85 db                	test   %ebx,%ebx
  800488:	7f ed                	jg     800477 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	56                   	push   %esi
  80048e:	83 ec 04             	sub    $0x4,%esp
  800491:	ff 75 e4             	pushl  -0x1c(%ebp)
  800494:	ff 75 e0             	pushl  -0x20(%ebp)
  800497:	ff 75 dc             	pushl  -0x24(%ebp)
  80049a:	ff 75 d8             	pushl  -0x28(%ebp)
  80049d:	e8 ae 1c 00 00       	call   802150 <__umoddi3>
  8004a2:	83 c4 14             	add    $0x14,%esp
  8004a5:	0f be 80 bb 23 80 00 	movsbl 0x8023bb(%eax),%eax
  8004ac:	50                   	push   %eax
  8004ad:	ff d7                	call   *%edi
  8004af:	83 c4 10             	add    $0x10,%esp
}
  8004b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b5:	5b                   	pop    %ebx
  8004b6:	5e                   	pop    %esi
  8004b7:	5f                   	pop    %edi
  8004b8:	5d                   	pop    %ebp
  8004b9:	c3                   	ret    

008004ba <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ba:	55                   	push   %ebp
  8004bb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004bd:	83 fa 01             	cmp    $0x1,%edx
  8004c0:	7e 0e                	jle    8004d0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004c2:	8b 10                	mov    (%eax),%edx
  8004c4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004c7:	89 08                	mov    %ecx,(%eax)
  8004c9:	8b 02                	mov    (%edx),%eax
  8004cb:	8b 52 04             	mov    0x4(%edx),%edx
  8004ce:	eb 22                	jmp    8004f2 <getuint+0x38>
	else if (lflag)
  8004d0:	85 d2                	test   %edx,%edx
  8004d2:	74 10                	je     8004e4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004d4:	8b 10                	mov    (%eax),%edx
  8004d6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d9:	89 08                	mov    %ecx,(%eax)
  8004db:	8b 02                	mov    (%edx),%eax
  8004dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e2:	eb 0e                	jmp    8004f2 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004e4:	8b 10                	mov    (%eax),%edx
  8004e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e9:	89 08                	mov    %ecx,(%eax)
  8004eb:	8b 02                	mov    (%edx),%eax
  8004ed:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004fa:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004fe:	8b 10                	mov    (%eax),%edx
  800500:	3b 50 04             	cmp    0x4(%eax),%edx
  800503:	73 0a                	jae    80050f <sprintputch+0x1b>
		*b->buf++ = ch;
  800505:	8d 4a 01             	lea    0x1(%edx),%ecx
  800508:	89 08                	mov    %ecx,(%eax)
  80050a:	8b 45 08             	mov    0x8(%ebp),%eax
  80050d:	88 02                	mov    %al,(%edx)
}
  80050f:	5d                   	pop    %ebp
  800510:	c3                   	ret    

00800511 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800517:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80051a:	50                   	push   %eax
  80051b:	ff 75 10             	pushl  0x10(%ebp)
  80051e:	ff 75 0c             	pushl  0xc(%ebp)
  800521:	ff 75 08             	pushl  0x8(%ebp)
  800524:	e8 05 00 00 00       	call   80052e <vprintfmt>
	va_end(ap);
  800529:	83 c4 10             	add    $0x10,%esp
}
  80052c:	c9                   	leave  
  80052d:	c3                   	ret    

0080052e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80052e:	55                   	push   %ebp
  80052f:	89 e5                	mov    %esp,%ebp
  800531:	57                   	push   %edi
  800532:	56                   	push   %esi
  800533:	53                   	push   %ebx
  800534:	83 ec 2c             	sub    $0x2c,%esp
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80053d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800540:	eb 12                	jmp    800554 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800542:	85 c0                	test   %eax,%eax
  800544:	0f 84 8d 03 00 00    	je     8008d7 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80054a:	83 ec 08             	sub    $0x8,%esp
  80054d:	53                   	push   %ebx
  80054e:	50                   	push   %eax
  80054f:	ff d6                	call   *%esi
  800551:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800554:	83 c7 01             	add    $0x1,%edi
  800557:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80055b:	83 f8 25             	cmp    $0x25,%eax
  80055e:	75 e2                	jne    800542 <vprintfmt+0x14>
  800560:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800564:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80056b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800572:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800579:	ba 00 00 00 00       	mov    $0x0,%edx
  80057e:	eb 07                	jmp    800587 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800580:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800583:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800587:	8d 47 01             	lea    0x1(%edi),%eax
  80058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058d:	0f b6 07             	movzbl (%edi),%eax
  800590:	0f b6 c8             	movzbl %al,%ecx
  800593:	83 e8 23             	sub    $0x23,%eax
  800596:	3c 55                	cmp    $0x55,%al
  800598:	0f 87 1e 03 00 00    	ja     8008bc <vprintfmt+0x38e>
  80059e:	0f b6 c0             	movzbl %al,%eax
  8005a1:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  8005a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8005ab:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005af:	eb d6                	jmp    800587 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005bc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005bf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005c3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005c6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005c9:	83 fa 09             	cmp    $0x9,%edx
  8005cc:	77 38                	ja     800606 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005ce:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005d1:	eb e9                	jmp    8005bc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 48 04             	lea    0x4(%eax),%ecx
  8005d9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005e4:	eb 26                	jmp    80060c <vprintfmt+0xde>
  8005e6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e9:	89 c8                	mov    %ecx,%eax
  8005eb:	c1 f8 1f             	sar    $0x1f,%eax
  8005ee:	f7 d0                	not    %eax
  8005f0:	21 c1                	and    %eax,%ecx
  8005f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f8:	eb 8d                	jmp    800587 <vprintfmt+0x59>
  8005fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005fd:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800604:	eb 81                	jmp    800587 <vprintfmt+0x59>
  800606:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800609:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80060c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800610:	0f 89 71 ff ff ff    	jns    800587 <vprintfmt+0x59>
				width = precision, precision = -1;
  800616:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800619:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80061c:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800623:	e9 5f ff ff ff       	jmp    800587 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800628:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80062e:	e9 54 ff ff ff       	jmp    800587 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 04             	lea    0x4(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	53                   	push   %ebx
  800640:	ff 30                	pushl  (%eax)
  800642:	ff d6                	call   *%esi
			break;
  800644:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80064a:	e9 05 ff ff ff       	jmp    800554 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	99                   	cltd   
  80065b:	31 d0                	xor    %edx,%eax
  80065d:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80065f:	83 f8 0f             	cmp    $0xf,%eax
  800662:	7f 0b                	jg     80066f <vprintfmt+0x141>
  800664:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  80066b:	85 d2                	test   %edx,%edx
  80066d:	75 18                	jne    800687 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80066f:	50                   	push   %eax
  800670:	68 d3 23 80 00       	push   $0x8023d3
  800675:	53                   	push   %ebx
  800676:	56                   	push   %esi
  800677:	e8 95 fe ff ff       	call   800511 <printfmt>
  80067c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800682:	e9 cd fe ff ff       	jmp    800554 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800687:	52                   	push   %edx
  800688:	68 b1 27 80 00       	push   $0x8027b1
  80068d:	53                   	push   %ebx
  80068e:	56                   	push   %esi
  80068f:	e8 7d fe ff ff       	call   800511 <printfmt>
  800694:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800697:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069a:	e9 b5 fe ff ff       	jmp    800554 <vprintfmt+0x26>
  80069f:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8006a5:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8d 50 04             	lea    0x4(%eax),%edx
  8006ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b1:	8b 38                	mov    (%eax),%edi
  8006b3:	85 ff                	test   %edi,%edi
  8006b5:	75 05                	jne    8006bc <vprintfmt+0x18e>
				p = "(null)";
  8006b7:	bf cc 23 80 00       	mov    $0x8023cc,%edi
			if (width > 0 && padc != '-')
  8006bc:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006c0:	0f 84 91 00 00 00    	je     800757 <vprintfmt+0x229>
  8006c6:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8006ca:	0f 8e 95 00 00 00    	jle    800765 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	51                   	push   %ecx
  8006d4:	57                   	push   %edi
  8006d5:	e8 85 02 00 00       	call   80095f <strnlen>
  8006da:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006dd:	29 c1                	sub    %eax,%ecx
  8006df:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8006e2:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006e5:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ec:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006ef:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006f1:	eb 0f                	jmp    800702 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8006f3:	83 ec 08             	sub    $0x8,%esp
  8006f6:	53                   	push   %ebx
  8006f7:	ff 75 e0             	pushl  -0x20(%ebp)
  8006fa:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	83 ef 01             	sub    $0x1,%edi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	85 ff                	test   %edi,%edi
  800704:	7f ed                	jg     8006f3 <vprintfmt+0x1c5>
  800706:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800709:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80070c:	89 c8                	mov    %ecx,%eax
  80070e:	c1 f8 1f             	sar    $0x1f,%eax
  800711:	f7 d0                	not    %eax
  800713:	21 c8                	and    %ecx,%eax
  800715:	29 c1                	sub    %eax,%ecx
  800717:	89 75 08             	mov    %esi,0x8(%ebp)
  80071a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800720:	89 cb                	mov    %ecx,%ebx
  800722:	eb 4d                	jmp    800771 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800724:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800728:	74 1b                	je     800745 <vprintfmt+0x217>
  80072a:	0f be c0             	movsbl %al,%eax
  80072d:	83 e8 20             	sub    $0x20,%eax
  800730:	83 f8 5e             	cmp    $0x5e,%eax
  800733:	76 10                	jbe    800745 <vprintfmt+0x217>
					putch('?', putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	ff 75 0c             	pushl  0xc(%ebp)
  80073b:	6a 3f                	push   $0x3f
  80073d:	ff 55 08             	call   *0x8(%ebp)
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb 0d                	jmp    800752 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	ff 75 0c             	pushl  0xc(%ebp)
  80074b:	52                   	push   %edx
  80074c:	ff 55 08             	call   *0x8(%ebp)
  80074f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800752:	83 eb 01             	sub    $0x1,%ebx
  800755:	eb 1a                	jmp    800771 <vprintfmt+0x243>
  800757:	89 75 08             	mov    %esi,0x8(%ebp)
  80075a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80075d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800760:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800763:	eb 0c                	jmp    800771 <vprintfmt+0x243>
  800765:	89 75 08             	mov    %esi,0x8(%ebp)
  800768:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80076b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80076e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800771:	83 c7 01             	add    $0x1,%edi
  800774:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800778:	0f be d0             	movsbl %al,%edx
  80077b:	85 d2                	test   %edx,%edx
  80077d:	74 23                	je     8007a2 <vprintfmt+0x274>
  80077f:	85 f6                	test   %esi,%esi
  800781:	78 a1                	js     800724 <vprintfmt+0x1f6>
  800783:	83 ee 01             	sub    $0x1,%esi
  800786:	79 9c                	jns    800724 <vprintfmt+0x1f6>
  800788:	89 df                	mov    %ebx,%edi
  80078a:	8b 75 08             	mov    0x8(%ebp),%esi
  80078d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800790:	eb 18                	jmp    8007aa <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800792:	83 ec 08             	sub    $0x8,%esp
  800795:	53                   	push   %ebx
  800796:	6a 20                	push   $0x20
  800798:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80079a:	83 ef 01             	sub    $0x1,%edi
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	eb 08                	jmp    8007aa <vprintfmt+0x27c>
  8007a2:	89 df                	mov    %ebx,%edi
  8007a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007aa:	85 ff                	test   %edi,%edi
  8007ac:	7f e4                	jg     800792 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8007ae:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007b1:	e9 9e fd ff ff       	jmp    800554 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007b6:	83 fa 01             	cmp    $0x1,%edx
  8007b9:	7e 16                	jle    8007d1 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8d 50 08             	lea    0x8(%eax),%edx
  8007c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c4:	8b 50 04             	mov    0x4(%eax),%edx
  8007c7:	8b 00                	mov    (%eax),%eax
  8007c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007cf:	eb 32                	jmp    800803 <vprintfmt+0x2d5>
	else if (lflag)
  8007d1:	85 d2                	test   %edx,%edx
  8007d3:	74 18                	je     8007ed <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  8007d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d8:	8d 50 04             	lea    0x4(%eax),%edx
  8007db:	89 55 14             	mov    %edx,0x14(%ebp)
  8007de:	8b 00                	mov    (%eax),%eax
  8007e0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e3:	89 c1                	mov    %eax,%ecx
  8007e5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007e8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007eb:	eb 16                	jmp    800803 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8d 50 04             	lea    0x4(%eax),%edx
  8007f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f6:	8b 00                	mov    (%eax),%eax
  8007f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fb:	89 c1                	mov    %eax,%ecx
  8007fd:	c1 f9 1f             	sar    $0x1f,%ecx
  800800:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800803:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800806:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800809:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80080e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800812:	79 74                	jns    800888 <vprintfmt+0x35a>
				putch('-', putdat);
  800814:	83 ec 08             	sub    $0x8,%esp
  800817:	53                   	push   %ebx
  800818:	6a 2d                	push   $0x2d
  80081a:	ff d6                	call   *%esi
				num = -(long long) num;
  80081c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80081f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800822:	f7 d8                	neg    %eax
  800824:	83 d2 00             	adc    $0x0,%edx
  800827:	f7 da                	neg    %edx
  800829:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082c:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800831:	eb 55                	jmp    800888 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800833:	8d 45 14             	lea    0x14(%ebp),%eax
  800836:	e8 7f fc ff ff       	call   8004ba <getuint>
			base = 10;
  80083b:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800840:	eb 46                	jmp    800888 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800842:	8d 45 14             	lea    0x14(%ebp),%eax
  800845:	e8 70 fc ff ff       	call   8004ba <getuint>
			base = 8;
  80084a:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  80084f:	eb 37                	jmp    800888 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800851:	83 ec 08             	sub    $0x8,%esp
  800854:	53                   	push   %ebx
  800855:	6a 30                	push   $0x30
  800857:	ff d6                	call   *%esi
			putch('x', putdat);
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	53                   	push   %ebx
  80085d:	6a 78                	push   $0x78
  80085f:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8d 50 04             	lea    0x4(%eax),%edx
  800867:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  80086a:	8b 00                	mov    (%eax),%eax
  80086c:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800871:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800874:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800879:	eb 0d                	jmp    800888 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
  80087e:	e8 37 fc ff ff       	call   8004ba <getuint>
			base = 16;
  800883:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800888:	83 ec 0c             	sub    $0xc,%esp
  80088b:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  80088f:	57                   	push   %edi
  800890:	ff 75 e0             	pushl  -0x20(%ebp)
  800893:	51                   	push   %ecx
  800894:	52                   	push   %edx
  800895:	50                   	push   %eax
  800896:	89 da                	mov    %ebx,%edx
  800898:	89 f0                	mov    %esi,%eax
  80089a:	e8 71 fb ff ff       	call   800410 <printnum>
			break;
  80089f:	83 c4 20             	add    $0x20,%esp
  8008a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008a5:	e9 aa fc ff ff       	jmp    800554 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008aa:	83 ec 08             	sub    $0x8,%esp
  8008ad:	53                   	push   %ebx
  8008ae:	51                   	push   %ecx
  8008af:	ff d6                	call   *%esi
			break;
  8008b1:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008b7:	e9 98 fc ff ff       	jmp    800554 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008bc:	83 ec 08             	sub    $0x8,%esp
  8008bf:	53                   	push   %ebx
  8008c0:	6a 25                	push   $0x25
  8008c2:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	eb 03                	jmp    8008cc <vprintfmt+0x39e>
  8008c9:	83 ef 01             	sub    $0x1,%edi
  8008cc:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008d0:	75 f7                	jne    8008c9 <vprintfmt+0x39b>
  8008d2:	e9 7d fc ff ff       	jmp    800554 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8008d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5f                   	pop    %edi
  8008dd:	5d                   	pop    %ebp
  8008de:	c3                   	ret    

008008df <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	83 ec 18             	sub    $0x18,%esp
  8008e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e8:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008ee:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f2:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008fc:	85 c0                	test   %eax,%eax
  8008fe:	74 26                	je     800926 <vsnprintf+0x47>
  800900:	85 d2                	test   %edx,%edx
  800902:	7e 22                	jle    800926 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800904:	ff 75 14             	pushl  0x14(%ebp)
  800907:	ff 75 10             	pushl  0x10(%ebp)
  80090a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80090d:	50                   	push   %eax
  80090e:	68 f4 04 80 00       	push   $0x8004f4
  800913:	e8 16 fc ff ff       	call   80052e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800918:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80091b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80091e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	eb 05                	jmp    80092b <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800926:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80092b:	c9                   	leave  
  80092c:	c3                   	ret    

0080092d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80092d:	55                   	push   %ebp
  80092e:	89 e5                	mov    %esp,%ebp
  800930:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800933:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800936:	50                   	push   %eax
  800937:	ff 75 10             	pushl  0x10(%ebp)
  80093a:	ff 75 0c             	pushl  0xc(%ebp)
  80093d:	ff 75 08             	pushl  0x8(%ebp)
  800940:	e8 9a ff ff ff       	call   8008df <vsnprintf>
	va_end(ap);

	return rc;
}
  800945:	c9                   	leave  
  800946:	c3                   	ret    

00800947 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80094d:	b8 00 00 00 00       	mov    $0x0,%eax
  800952:	eb 03                	jmp    800957 <strlen+0x10>
		n++;
  800954:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800957:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80095b:	75 f7                	jne    800954 <strlen+0xd>
		n++;
	return n;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800965:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800968:	ba 00 00 00 00       	mov    $0x0,%edx
  80096d:	eb 03                	jmp    800972 <strnlen+0x13>
		n++;
  80096f:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800972:	39 c2                	cmp    %eax,%edx
  800974:	74 08                	je     80097e <strnlen+0x1f>
  800976:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80097a:	75 f3                	jne    80096f <strnlen+0x10>
  80097c:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  80097e:	5d                   	pop    %ebp
  80097f:	c3                   	ret    

00800980 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	8b 45 08             	mov    0x8(%ebp),%eax
  800987:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80098a:	89 c2                	mov    %eax,%edx
  80098c:	83 c2 01             	add    $0x1,%edx
  80098f:	83 c1 01             	add    $0x1,%ecx
  800992:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800996:	88 5a ff             	mov    %bl,-0x1(%edx)
  800999:	84 db                	test   %bl,%bl
  80099b:	75 ef                	jne    80098c <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	53                   	push   %ebx
  8009a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009a7:	53                   	push   %ebx
  8009a8:	e8 9a ff ff ff       	call   800947 <strlen>
  8009ad:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009b0:	ff 75 0c             	pushl  0xc(%ebp)
  8009b3:	01 d8                	add    %ebx,%eax
  8009b5:	50                   	push   %eax
  8009b6:	e8 c5 ff ff ff       	call   800980 <strcpy>
	return dst;
}
  8009bb:	89 d8                	mov    %ebx,%eax
  8009bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cd:	89 f3                	mov    %esi,%ebx
  8009cf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009d2:	89 f2                	mov    %esi,%edx
  8009d4:	eb 0f                	jmp    8009e5 <strncpy+0x23>
		*dst++ = *src;
  8009d6:	83 c2 01             	add    $0x1,%edx
  8009d9:	0f b6 01             	movzbl (%ecx),%eax
  8009dc:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009df:	80 39 01             	cmpb   $0x1,(%ecx)
  8009e2:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009e5:	39 da                	cmp    %ebx,%edx
  8009e7:	75 ed                	jne    8009d6 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009e9:	89 f0                	mov    %esi,%eax
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	56                   	push   %esi
  8009f3:	53                   	push   %ebx
  8009f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fa:	8b 55 10             	mov    0x10(%ebp),%edx
  8009fd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009ff:	85 d2                	test   %edx,%edx
  800a01:	74 21                	je     800a24 <strlcpy+0x35>
  800a03:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a07:	89 f2                	mov    %esi,%edx
  800a09:	eb 09                	jmp    800a14 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a0b:	83 c2 01             	add    $0x1,%edx
  800a0e:	83 c1 01             	add    $0x1,%ecx
  800a11:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a14:	39 c2                	cmp    %eax,%edx
  800a16:	74 09                	je     800a21 <strlcpy+0x32>
  800a18:	0f b6 19             	movzbl (%ecx),%ebx
  800a1b:	84 db                	test   %bl,%bl
  800a1d:	75 ec                	jne    800a0b <strlcpy+0x1c>
  800a1f:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a21:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a24:	29 f0                	sub    %esi,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a30:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a33:	eb 06                	jmp    800a3b <strcmp+0x11>
		p++, q++;
  800a35:	83 c1 01             	add    $0x1,%ecx
  800a38:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a3b:	0f b6 01             	movzbl (%ecx),%eax
  800a3e:	84 c0                	test   %al,%al
  800a40:	74 04                	je     800a46 <strcmp+0x1c>
  800a42:	3a 02                	cmp    (%edx),%al
  800a44:	74 ef                	je     800a35 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a46:	0f b6 c0             	movzbl %al,%eax
  800a49:	0f b6 12             	movzbl (%edx),%edx
  800a4c:	29 d0                	sub    %edx,%eax
}
  800a4e:	5d                   	pop    %ebp
  800a4f:	c3                   	ret    

00800a50 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a50:	55                   	push   %ebp
  800a51:	89 e5                	mov    %esp,%ebp
  800a53:	53                   	push   %ebx
  800a54:	8b 45 08             	mov    0x8(%ebp),%eax
  800a57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a5a:	89 c3                	mov    %eax,%ebx
  800a5c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a5f:	eb 06                	jmp    800a67 <strncmp+0x17>
		n--, p++, q++;
  800a61:	83 c0 01             	add    $0x1,%eax
  800a64:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a67:	39 d8                	cmp    %ebx,%eax
  800a69:	74 15                	je     800a80 <strncmp+0x30>
  800a6b:	0f b6 08             	movzbl (%eax),%ecx
  800a6e:	84 c9                	test   %cl,%cl
  800a70:	74 04                	je     800a76 <strncmp+0x26>
  800a72:	3a 0a                	cmp    (%edx),%cl
  800a74:	74 eb                	je     800a61 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a76:	0f b6 00             	movzbl (%eax),%eax
  800a79:	0f b6 12             	movzbl (%edx),%edx
  800a7c:	29 d0                	sub    %edx,%eax
  800a7e:	eb 05                	jmp    800a85 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a85:	5b                   	pop    %ebx
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a88:	55                   	push   %ebp
  800a89:	89 e5                	mov    %esp,%ebp
  800a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a92:	eb 07                	jmp    800a9b <strchr+0x13>
		if (*s == c)
  800a94:	38 ca                	cmp    %cl,%dl
  800a96:	74 0f                	je     800aa7 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a98:	83 c0 01             	add    $0x1,%eax
  800a9b:	0f b6 10             	movzbl (%eax),%edx
  800a9e:	84 d2                	test   %dl,%dl
  800aa0:	75 f2                	jne    800a94 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800aa7:	5d                   	pop    %ebp
  800aa8:	c3                   	ret    

00800aa9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ab3:	eb 03                	jmp    800ab8 <strfind+0xf>
  800ab5:	83 c0 01             	add    $0x1,%eax
  800ab8:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800abb:	84 d2                	test   %dl,%dl
  800abd:	74 04                	je     800ac3 <strfind+0x1a>
  800abf:	38 ca                	cmp    %cl,%dl
  800ac1:	75 f2                	jne    800ab5 <strfind+0xc>
			break;
	return (char *) s;
}
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	57                   	push   %edi
  800ac9:	56                   	push   %esi
  800aca:	53                   	push   %ebx
  800acb:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ace:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800ad1:	85 c9                	test   %ecx,%ecx
  800ad3:	74 36                	je     800b0b <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad5:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800adb:	75 28                	jne    800b05 <memset+0x40>
  800add:	f6 c1 03             	test   $0x3,%cl
  800ae0:	75 23                	jne    800b05 <memset+0x40>
		c &= 0xFF;
  800ae2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae6:	89 d3                	mov    %edx,%ebx
  800ae8:	c1 e3 08             	shl    $0x8,%ebx
  800aeb:	89 d6                	mov    %edx,%esi
  800aed:	c1 e6 18             	shl    $0x18,%esi
  800af0:	89 d0                	mov    %edx,%eax
  800af2:	c1 e0 10             	shl    $0x10,%eax
  800af5:	09 f0                	or     %esi,%eax
  800af7:	09 c2                	or     %eax,%edx
  800af9:	89 d0                	mov    %edx,%eax
  800afb:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800afd:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b00:	fc                   	cld    
  800b01:	f3 ab                	rep stos %eax,%es:(%edi)
  800b03:	eb 06                	jmp    800b0b <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b08:	fc                   	cld    
  800b09:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b0b:	89 f8                	mov    %edi,%eax
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b20:	39 c6                	cmp    %eax,%esi
  800b22:	73 35                	jae    800b59 <memmove+0x47>
  800b24:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b27:	39 d0                	cmp    %edx,%eax
  800b29:	73 2e                	jae    800b59 <memmove+0x47>
		s += n;
		d += n;
  800b2b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800b2e:	89 d6                	mov    %edx,%esi
  800b30:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b32:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b38:	75 13                	jne    800b4d <memmove+0x3b>
  800b3a:	f6 c1 03             	test   $0x3,%cl
  800b3d:	75 0e                	jne    800b4d <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b3f:	83 ef 04             	sub    $0x4,%edi
  800b42:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b45:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800b48:	fd                   	std    
  800b49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b4b:	eb 09                	jmp    800b56 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b4d:	83 ef 01             	sub    $0x1,%edi
  800b50:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b53:	fd                   	std    
  800b54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b56:	fc                   	cld    
  800b57:	eb 1d                	jmp    800b76 <memmove+0x64>
  800b59:	89 f2                	mov    %esi,%edx
  800b5b:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5d:	f6 c2 03             	test   $0x3,%dl
  800b60:	75 0f                	jne    800b71 <memmove+0x5f>
  800b62:	f6 c1 03             	test   $0x3,%cl
  800b65:	75 0a                	jne    800b71 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b67:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800b6a:	89 c7                	mov    %eax,%edi
  800b6c:	fc                   	cld    
  800b6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b6f:	eb 05                	jmp    800b76 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b71:	89 c7                	mov    %eax,%edi
  800b73:	fc                   	cld    
  800b74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800b7d:	ff 75 10             	pushl  0x10(%ebp)
  800b80:	ff 75 0c             	pushl  0xc(%ebp)
  800b83:	ff 75 08             	pushl  0x8(%ebp)
  800b86:	e8 87 ff ff ff       	call   800b12 <memmove>
}
  800b8b:	c9                   	leave  
  800b8c:	c3                   	ret    

00800b8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	56                   	push   %esi
  800b91:	53                   	push   %ebx
  800b92:	8b 45 08             	mov    0x8(%ebp),%eax
  800b95:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b98:	89 c6                	mov    %eax,%esi
  800b9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9d:	eb 1a                	jmp    800bb9 <memcmp+0x2c>
		if (*s1 != *s2)
  800b9f:	0f b6 08             	movzbl (%eax),%ecx
  800ba2:	0f b6 1a             	movzbl (%edx),%ebx
  800ba5:	38 d9                	cmp    %bl,%cl
  800ba7:	74 0a                	je     800bb3 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800ba9:	0f b6 c1             	movzbl %cl,%eax
  800bac:	0f b6 db             	movzbl %bl,%ebx
  800baf:	29 d8                	sub    %ebx,%eax
  800bb1:	eb 0f                	jmp    800bc2 <memcmp+0x35>
		s1++, s2++;
  800bb3:	83 c0 01             	add    $0x1,%eax
  800bb6:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bb9:	39 f0                	cmp    %esi,%eax
  800bbb:	75 e2                	jne    800b9f <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bcf:	89 c2                	mov    %eax,%edx
  800bd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd4:	eb 07                	jmp    800bdd <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd6:	38 08                	cmp    %cl,(%eax)
  800bd8:	74 07                	je     800be1 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	39 d0                	cmp    %edx,%eax
  800bdf:	72 f5                	jb     800bd6 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be1:	5d                   	pop    %ebp
  800be2:	c3                   	ret    

00800be3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800be3:	55                   	push   %ebp
  800be4:	89 e5                	mov    %esp,%ebp
  800be6:	57                   	push   %edi
  800be7:	56                   	push   %esi
  800be8:	53                   	push   %ebx
  800be9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bef:	eb 03                	jmp    800bf4 <strtol+0x11>
		s++;
  800bf1:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf4:	0f b6 01             	movzbl (%ecx),%eax
  800bf7:	3c 09                	cmp    $0x9,%al
  800bf9:	74 f6                	je     800bf1 <strtol+0xe>
  800bfb:	3c 20                	cmp    $0x20,%al
  800bfd:	74 f2                	je     800bf1 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bff:	3c 2b                	cmp    $0x2b,%al
  800c01:	75 0a                	jne    800c0d <strtol+0x2a>
		s++;
  800c03:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c06:	bf 00 00 00 00       	mov    $0x0,%edi
  800c0b:	eb 10                	jmp    800c1d <strtol+0x3a>
  800c0d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c12:	3c 2d                	cmp    $0x2d,%al
  800c14:	75 07                	jne    800c1d <strtol+0x3a>
		s++, neg = 1;
  800c16:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c19:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1d:	85 db                	test   %ebx,%ebx
  800c1f:	0f 94 c0             	sete   %al
  800c22:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c28:	75 19                	jne    800c43 <strtol+0x60>
  800c2a:	80 39 30             	cmpb   $0x30,(%ecx)
  800c2d:	75 14                	jne    800c43 <strtol+0x60>
  800c2f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c33:	0f 85 8a 00 00 00    	jne    800cc3 <strtol+0xe0>
		s += 2, base = 16;
  800c39:	83 c1 02             	add    $0x2,%ecx
  800c3c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c41:	eb 16                	jmp    800c59 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c43:	84 c0                	test   %al,%al
  800c45:	74 12                	je     800c59 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c47:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	80 39 30             	cmpb   $0x30,(%ecx)
  800c4f:	75 08                	jne    800c59 <strtol+0x76>
		s++, base = 8;
  800c51:	83 c1 01             	add    $0x1,%ecx
  800c54:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c59:	b8 00 00 00 00       	mov    $0x0,%eax
  800c5e:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c61:	0f b6 11             	movzbl (%ecx),%edx
  800c64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c67:	89 f3                	mov    %esi,%ebx
  800c69:	80 fb 09             	cmp    $0x9,%bl
  800c6c:	77 08                	ja     800c76 <strtol+0x93>
			dig = *s - '0';
  800c6e:	0f be d2             	movsbl %dl,%edx
  800c71:	83 ea 30             	sub    $0x30,%edx
  800c74:	eb 22                	jmp    800c98 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800c76:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c79:	89 f3                	mov    %esi,%ebx
  800c7b:	80 fb 19             	cmp    $0x19,%bl
  800c7e:	77 08                	ja     800c88 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800c80:	0f be d2             	movsbl %dl,%edx
  800c83:	83 ea 57             	sub    $0x57,%edx
  800c86:	eb 10                	jmp    800c98 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800c88:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c8b:	89 f3                	mov    %esi,%ebx
  800c8d:	80 fb 19             	cmp    $0x19,%bl
  800c90:	77 16                	ja     800ca8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c92:	0f be d2             	movsbl %dl,%edx
  800c95:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800c98:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c9b:	7d 0f                	jge    800cac <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800c9d:	83 c1 01             	add    $0x1,%ecx
  800ca0:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ca4:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ca6:	eb b9                	jmp    800c61 <strtol+0x7e>
  800ca8:	89 c2                	mov    %eax,%edx
  800caa:	eb 02                	jmp    800cae <strtol+0xcb>
  800cac:	89 c2                	mov    %eax,%edx

	if (endptr)
  800cae:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb2:	74 05                	je     800cb9 <strtol+0xd6>
		*endptr = (char *) s;
  800cb4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cb7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cb9:	85 ff                	test   %edi,%edi
  800cbb:	74 0c                	je     800cc9 <strtol+0xe6>
  800cbd:	89 d0                	mov    %edx,%eax
  800cbf:	f7 d8                	neg    %eax
  800cc1:	eb 06                	jmp    800cc9 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc3:	84 c0                	test   %al,%al
  800cc5:	75 8a                	jne    800c51 <strtol+0x6e>
  800cc7:	eb 90                	jmp    800c59 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	57                   	push   %edi
  800cd2:	56                   	push   %esi
  800cd3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cd4:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdf:	89 c3                	mov    %eax,%ebx
  800ce1:	89 c7                	mov    %eax,%edi
  800ce3:	89 c6                	mov    %eax,%esi
  800ce5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    

00800cec <sys_cgetc>:

int
sys_cgetc(void)
{
  800cec:	55                   	push   %ebp
  800ced:	89 e5                	mov    %esp,%ebp
  800cef:	57                   	push   %edi
  800cf0:	56                   	push   %esi
  800cf1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf7:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfc:	89 d1                	mov    %edx,%ecx
  800cfe:	89 d3                	mov    %edx,%ebx
  800d00:	89 d7                	mov    %edx,%edi
  800d02:	89 d6                	mov    %edx,%esi
  800d04:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d06:	5b                   	pop    %ebx
  800d07:	5e                   	pop    %esi
  800d08:	5f                   	pop    %edi
  800d09:	5d                   	pop    %ebp
  800d0a:	c3                   	ret    

00800d0b <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	57                   	push   %edi
  800d0f:	56                   	push   %esi
  800d10:	53                   	push   %ebx
  800d11:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d14:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d19:	b8 03 00 00 00       	mov    $0x3,%eax
  800d1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d21:	89 cb                	mov    %ecx,%ebx
  800d23:	89 cf                	mov    %ecx,%edi
  800d25:	89 ce                	mov    %ecx,%esi
  800d27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d29:	85 c0                	test   %eax,%eax
  800d2b:	7e 17                	jle    800d44 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	50                   	push   %eax
  800d31:	6a 03                	push   $0x3
  800d33:	68 df 26 80 00       	push   $0x8026df
  800d38:	6a 23                	push   $0x23
  800d3a:	68 fc 26 80 00       	push   $0x8026fc
  800d3f:	e8 df f5 ff ff       	call   800323 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	57                   	push   %edi
  800d50:	56                   	push   %esi
  800d51:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d52:	ba 00 00 00 00       	mov    $0x0,%edx
  800d57:	b8 02 00 00 00       	mov    $0x2,%eax
  800d5c:	89 d1                	mov    %edx,%ecx
  800d5e:	89 d3                	mov    %edx,%ebx
  800d60:	89 d7                	mov    %edx,%edi
  800d62:	89 d6                	mov    %edx,%esi
  800d64:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_yield>:

void
sys_yield(void)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	ba 00 00 00 00       	mov    $0x0,%edx
  800d76:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d7b:	89 d1                	mov    %edx,%ecx
  800d7d:	89 d3                	mov    %edx,%ebx
  800d7f:	89 d7                	mov    %edx,%edi
  800d81:	89 d6                	mov    %edx,%esi
  800d83:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
  800d90:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d93:	be 00 00 00 00       	mov    $0x0,%esi
  800d98:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da0:	8b 55 08             	mov    0x8(%ebp),%edx
  800da3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da6:	89 f7                	mov    %esi,%edi
  800da8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7e 17                	jle    800dc5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dae:	83 ec 0c             	sub    $0xc,%esp
  800db1:	50                   	push   %eax
  800db2:	6a 04                	push   $0x4
  800db4:	68 df 26 80 00       	push   $0x8026df
  800db9:	6a 23                	push   $0x23
  800dbb:	68 fc 26 80 00       	push   $0x8026fc
  800dc0:	e8 5e f5 ff ff       	call   800323 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800dc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc8:	5b                   	pop    %ebx
  800dc9:	5e                   	pop    %esi
  800dca:	5f                   	pop    %edi
  800dcb:	5d                   	pop    %ebp
  800dcc:	c3                   	ret    

00800dcd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd6:	b8 05 00 00 00       	mov    $0x5,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800de4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800de7:	8b 75 18             	mov    0x18(%ebp),%esi
  800dea:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7e 17                	jle    800e07 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	50                   	push   %eax
  800df4:	6a 05                	push   $0x5
  800df6:	68 df 26 80 00       	push   $0x8026df
  800dfb:	6a 23                	push   $0x23
  800dfd:	68 fc 26 80 00       	push   $0x8026fc
  800e02:	e8 1c f5 ff ff       	call   800323 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0a:	5b                   	pop    %ebx
  800e0b:	5e                   	pop    %esi
  800e0c:	5f                   	pop    %edi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1d:	b8 06 00 00 00       	mov    $0x6,%eax
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	89 df                	mov    %ebx,%edi
  800e2a:	89 de                	mov    %ebx,%esi
  800e2c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7e 17                	jle    800e49 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e32:	83 ec 0c             	sub    $0xc,%esp
  800e35:	50                   	push   %eax
  800e36:	6a 06                	push   $0x6
  800e38:	68 df 26 80 00       	push   $0x8026df
  800e3d:	6a 23                	push   $0x23
  800e3f:	68 fc 26 80 00       	push   $0x8026fc
  800e44:	e8 da f4 ff ff       	call   800323 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	b8 08 00 00 00       	mov    $0x8,%eax
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7e 17                	jle    800e8b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e74:	83 ec 0c             	sub    $0xc,%esp
  800e77:	50                   	push   %eax
  800e78:	6a 08                	push   $0x8
  800e7a:	68 df 26 80 00       	push   $0x8026df
  800e7f:	6a 23                	push   $0x23
  800e81:	68 fc 26 80 00       	push   $0x8026fc
  800e86:	e8 98 f4 ff ff       	call   800323 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    

00800e93 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	b8 09 00 00 00       	mov    $0x9,%eax
  800ea6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea9:	8b 55 08             	mov    0x8(%ebp),%edx
  800eac:	89 df                	mov    %ebx,%edi
  800eae:	89 de                	mov    %ebx,%esi
  800eb0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	7e 17                	jle    800ecd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	50                   	push   %eax
  800eba:	6a 09                	push   $0x9
  800ebc:	68 df 26 80 00       	push   $0x8026df
  800ec1:	6a 23                	push   $0x23
  800ec3:	68 fc 26 80 00       	push   $0x8026fc
  800ec8:	e8 56 f4 ff ff       	call   800323 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
  800edb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eeb:	8b 55 08             	mov    0x8(%ebp),%edx
  800eee:	89 df                	mov    %ebx,%edi
  800ef0:	89 de                	mov    %ebx,%esi
  800ef2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	7e 17                	jle    800f0f <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	50                   	push   %eax
  800efc:	6a 0a                	push   $0xa
  800efe:	68 df 26 80 00       	push   $0x8026df
  800f03:	6a 23                	push   $0x23
  800f05:	68 fc 26 80 00       	push   $0x8026fc
  800f0a:	e8 14 f4 ff ff       	call   800323 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    

00800f17 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f17:	55                   	push   %ebp
  800f18:	89 e5                	mov    %esp,%ebp
  800f1a:	57                   	push   %edi
  800f1b:	56                   	push   %esi
  800f1c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1d:	be 00 00 00 00       	mov    $0x0,%esi
  800f22:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f27:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f30:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f33:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f35:	5b                   	pop    %ebx
  800f36:	5e                   	pop    %esi
  800f37:	5f                   	pop    %edi
  800f38:	5d                   	pop    %ebp
  800f39:	c3                   	ret    

00800f3a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	57                   	push   %edi
  800f3e:	56                   	push   %esi
  800f3f:	53                   	push   %ebx
  800f40:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f43:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f48:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f50:	89 cb                	mov    %ecx,%ebx
  800f52:	89 cf                	mov    %ecx,%edi
  800f54:	89 ce                	mov    %ecx,%esi
  800f56:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f58:	85 c0                	test   %eax,%eax
  800f5a:	7e 17                	jle    800f73 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	50                   	push   %eax
  800f60:	6a 0d                	push   $0xd
  800f62:	68 df 26 80 00       	push   $0x8026df
  800f67:	6a 23                	push   $0x23
  800f69:	68 fc 26 80 00       	push   $0x8026fc
  800f6e:	e8 b0 f3 ff ff       	call   800323 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f76:	5b                   	pop    %ebx
  800f77:	5e                   	pop    %esi
  800f78:	5f                   	pop    %edi
  800f79:	5d                   	pop    %ebp
  800f7a:	c3                   	ret    

00800f7b <sys_gettime>:

int sys_gettime(void)
{
  800f7b:	55                   	push   %ebp
  800f7c:	89 e5                	mov    %esp,%ebp
  800f7e:	57                   	push   %edi
  800f7f:	56                   	push   %esi
  800f80:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f81:	ba 00 00 00 00       	mov    $0x0,%edx
  800f86:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f8b:	89 d1                	mov    %edx,%ecx
  800f8d:	89 d3                	mov    %edx,%ebx
  800f8f:	89 d7                	mov    %edx,%edi
  800f91:	89 d6                	mov    %edx,%esi
  800f93:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fa3:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800fa6:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800fa8:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800fab:	83 3a 01             	cmpl   $0x1,(%edx)
  800fae:	7e 09                	jle    800fb9 <argstart+0x1f>
  800fb0:	ba 68 23 80 00       	mov    $0x802368,%edx
  800fb5:	85 c9                	test   %ecx,%ecx
  800fb7:	75 05                	jne    800fbe <argstart+0x24>
  800fb9:	ba 00 00 00 00       	mov    $0x0,%edx
  800fbe:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800fc1:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800fc8:	5d                   	pop    %ebp
  800fc9:	c3                   	ret    

00800fca <argnext>:

int
argnext(struct Argstate *args)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	53                   	push   %ebx
  800fce:	83 ec 04             	sub    $0x4,%esp
  800fd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800fd4:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800fdb:	8b 43 08             	mov    0x8(%ebx),%eax
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	74 6f                	je     801051 <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  800fe2:	80 38 00             	cmpb   $0x0,(%eax)
  800fe5:	75 4e                	jne    801035 <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800fe7:	8b 0b                	mov    (%ebx),%ecx
  800fe9:	83 39 01             	cmpl   $0x1,(%ecx)
  800fec:	74 55                	je     801043 <argnext+0x79>
		    || args->argv[1][0] != '-'
  800fee:	8b 53 04             	mov    0x4(%ebx),%edx
  800ff1:	8b 42 04             	mov    0x4(%edx),%eax
  800ff4:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ff7:	75 4a                	jne    801043 <argnext+0x79>
		    || args->argv[1][1] == '\0')
  800ff9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800ffd:	74 44                	je     801043 <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800fff:	83 c0 01             	add    $0x1,%eax
  801002:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801005:	83 ec 04             	sub    $0x4,%esp
  801008:	8b 01                	mov    (%ecx),%eax
  80100a:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801011:	50                   	push   %eax
  801012:	8d 42 08             	lea    0x8(%edx),%eax
  801015:	50                   	push   %eax
  801016:	83 c2 04             	add    $0x4,%edx
  801019:	52                   	push   %edx
  80101a:	e8 f3 fa ff ff       	call   800b12 <memmove>
		(*args->argc)--;
  80101f:	8b 03                	mov    (%ebx),%eax
  801021:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801024:	8b 43 08             	mov    0x8(%ebx),%eax
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	80 38 2d             	cmpb   $0x2d,(%eax)
  80102d:	75 06                	jne    801035 <argnext+0x6b>
  80102f:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801033:	74 0e                	je     801043 <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801035:	8b 53 08             	mov    0x8(%ebx),%edx
  801038:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  80103b:	83 c2 01             	add    $0x1,%edx
  80103e:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801041:	eb 13                	jmp    801056 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801043:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  80104a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  80104f:	eb 05                	jmp    801056 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801051:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801056:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	53                   	push   %ebx
  80105f:	83 ec 04             	sub    $0x4,%esp
  801062:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801065:	8b 43 08             	mov    0x8(%ebx),%eax
  801068:	85 c0                	test   %eax,%eax
  80106a:	74 58                	je     8010c4 <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  80106c:	80 38 00             	cmpb   $0x0,(%eax)
  80106f:	74 0c                	je     80107d <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801071:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801074:	c7 43 08 68 23 80 00 	movl   $0x802368,0x8(%ebx)
  80107b:	eb 42                	jmp    8010bf <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  80107d:	8b 13                	mov    (%ebx),%edx
  80107f:	83 3a 01             	cmpl   $0x1,(%edx)
  801082:	7e 2d                	jle    8010b1 <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801084:	8b 43 04             	mov    0x4(%ebx),%eax
  801087:	8b 48 04             	mov    0x4(%eax),%ecx
  80108a:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  80108d:	83 ec 04             	sub    $0x4,%esp
  801090:	8b 12                	mov    (%edx),%edx
  801092:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801099:	52                   	push   %edx
  80109a:	8d 50 08             	lea    0x8(%eax),%edx
  80109d:	52                   	push   %edx
  80109e:	83 c0 04             	add    $0x4,%eax
  8010a1:	50                   	push   %eax
  8010a2:	e8 6b fa ff ff       	call   800b12 <memmove>
		(*args->argc)--;
  8010a7:	8b 03                	mov    (%ebx),%eax
  8010a9:	83 28 01             	subl   $0x1,(%eax)
  8010ac:	83 c4 10             	add    $0x10,%esp
  8010af:	eb 0e                	jmp    8010bf <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  8010b1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  8010b8:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  8010bf:	8b 43 0c             	mov    0xc(%ebx),%eax
  8010c2:	eb 05                	jmp    8010c9 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  8010c4:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  8010c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    

008010ce <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	83 ec 08             	sub    $0x8,%esp
  8010d4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  8010d7:	8b 51 0c             	mov    0xc(%ecx),%edx
  8010da:	89 d0                	mov    %edx,%eax
  8010dc:	85 d2                	test   %edx,%edx
  8010de:	75 0c                	jne    8010ec <argvalue+0x1e>
  8010e0:	83 ec 0c             	sub    $0xc,%esp
  8010e3:	51                   	push   %ecx
  8010e4:	e8 72 ff ff ff       	call   80105b <argnextvalue>
  8010e9:	83 c4 10             	add    $0x10,%esp
}
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    

008010ee <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f4:	05 00 00 00 30       	add    $0x30000000,%eax
  8010f9:	c1 e8 0c             	shr    $0xc,%eax
}
  8010fc:	5d                   	pop    %ebp
  8010fd:	c3                   	ret    

008010fe <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010fe:	55                   	push   %ebp
  8010ff:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801109:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80110e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801120:	89 c2                	mov    %eax,%edx
  801122:	c1 ea 16             	shr    $0x16,%edx
  801125:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112c:	f6 c2 01             	test   $0x1,%dl
  80112f:	74 11                	je     801142 <fd_alloc+0x2d>
  801131:	89 c2                	mov    %eax,%edx
  801133:	c1 ea 0c             	shr    $0xc,%edx
  801136:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113d:	f6 c2 01             	test   $0x1,%dl
  801140:	75 09                	jne    80114b <fd_alloc+0x36>
			*fd_store = fd;
  801142:	89 01                	mov    %eax,(%ecx)
			return 0;
  801144:	b8 00 00 00 00       	mov    $0x0,%eax
  801149:	eb 17                	jmp    801162 <fd_alloc+0x4d>
  80114b:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801150:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801155:	75 c9                	jne    801120 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801157:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80115d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801162:	5d                   	pop    %ebp
  801163:	c3                   	ret    

00801164 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80116a:	83 f8 1f             	cmp    $0x1f,%eax
  80116d:	77 36                	ja     8011a5 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80116f:	c1 e0 0c             	shl    $0xc,%eax
  801172:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801177:	89 c2                	mov    %eax,%edx
  801179:	c1 ea 16             	shr    $0x16,%edx
  80117c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801183:	f6 c2 01             	test   $0x1,%dl
  801186:	74 24                	je     8011ac <fd_lookup+0x48>
  801188:	89 c2                	mov    %eax,%edx
  80118a:	c1 ea 0c             	shr    $0xc,%edx
  80118d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801194:	f6 c2 01             	test   $0x1,%dl
  801197:	74 1a                	je     8011b3 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801199:	8b 55 0c             	mov    0xc(%ebp),%edx
  80119c:	89 02                	mov    %eax,(%edx)
	return 0;
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	eb 13                	jmp    8011b8 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011aa:	eb 0c                	jmp    8011b8 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8011ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011b1:	eb 05                	jmp    8011b8 <fd_lookup+0x54>
  8011b3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    

008011ba <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011c3:	ba 88 27 80 00       	mov    $0x802788,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011c8:	eb 13                	jmp    8011dd <dev_lookup+0x23>
  8011ca:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8011cd:	39 08                	cmp    %ecx,(%eax)
  8011cf:	75 0c                	jne    8011dd <dev_lookup+0x23>
			*dev = devtab[i];
  8011d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011d4:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011db:	eb 2e                	jmp    80120b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011dd:	8b 02                	mov    (%edx),%eax
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	75 e7                	jne    8011ca <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011e3:	a1 40 44 80 00       	mov    0x804440,%eax
  8011e8:	8b 40 48             	mov    0x48(%eax),%eax
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	51                   	push   %ecx
  8011ef:	50                   	push   %eax
  8011f0:	68 0c 27 80 00       	push   $0x80270c
  8011f5:	e8 02 f2 ff ff       	call   8003fc <cprintf>
	*dev = 0;
  8011fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80120b:	c9                   	leave  
  80120c:	c3                   	ret    

0080120d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	56                   	push   %esi
  801211:	53                   	push   %ebx
  801212:	83 ec 10             	sub    $0x10,%esp
  801215:	8b 75 08             	mov    0x8(%ebp),%esi
  801218:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80121b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121e:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801225:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801228:	50                   	push   %eax
  801229:	e8 36 ff ff ff       	call   801164 <fd_lookup>
  80122e:	83 c4 08             	add    $0x8,%esp
  801231:	85 c0                	test   %eax,%eax
  801233:	78 05                	js     80123a <fd_close+0x2d>
	    || fd != fd2)
  801235:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801238:	74 0b                	je     801245 <fd_close+0x38>
		return (must_exist ? r : 0);
  80123a:	80 fb 01             	cmp    $0x1,%bl
  80123d:	19 d2                	sbb    %edx,%edx
  80123f:	f7 d2                	not    %edx
  801241:	21 d0                	and    %edx,%eax
  801243:	eb 41                	jmp    801286 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801245:	83 ec 08             	sub    $0x8,%esp
  801248:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	ff 36                	pushl  (%esi)
  80124e:	e8 67 ff ff ff       	call   8011ba <dev_lookup>
  801253:	89 c3                	mov    %eax,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 1a                	js     801276 <fd_close+0x69>
		if (dev->dev_close)
  80125c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80125f:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801262:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801267:	85 c0                	test   %eax,%eax
  801269:	74 0b                	je     801276 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80126b:	83 ec 0c             	sub    $0xc,%esp
  80126e:	56                   	push   %esi
  80126f:	ff d0                	call   *%eax
  801271:	89 c3                	mov    %eax,%ebx
  801273:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	56                   	push   %esi
  80127a:	6a 00                	push   $0x0
  80127c:	e8 8e fb ff ff       	call   800e0f <sys_page_unmap>
	return r;
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	89 d8                	mov    %ebx,%eax
}
  801286:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801289:	5b                   	pop    %ebx
  80128a:	5e                   	pop    %esi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    

0080128d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80128d:	55                   	push   %ebp
  80128e:	89 e5                	mov    %esp,%ebp
  801290:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801293:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801296:	50                   	push   %eax
  801297:	ff 75 08             	pushl  0x8(%ebp)
  80129a:	e8 c5 fe ff ff       	call   801164 <fd_lookup>
  80129f:	89 c2                	mov    %eax,%edx
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	85 d2                	test   %edx,%edx
  8012a6:	78 10                	js     8012b8 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8012a8:	83 ec 08             	sub    $0x8,%esp
  8012ab:	6a 01                	push   $0x1
  8012ad:	ff 75 f4             	pushl  -0xc(%ebp)
  8012b0:	e8 58 ff ff ff       	call   80120d <fd_close>
  8012b5:	83 c4 10             	add    $0x10,%esp
}
  8012b8:	c9                   	leave  
  8012b9:	c3                   	ret    

008012ba <close_all>:

void
close_all(void)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	53                   	push   %ebx
  8012be:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012c1:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012c6:	83 ec 0c             	sub    $0xc,%esp
  8012c9:	53                   	push   %ebx
  8012ca:	e8 be ff ff ff       	call   80128d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8012cf:	83 c3 01             	add    $0x1,%ebx
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	83 fb 20             	cmp    $0x20,%ebx
  8012d8:	75 ec                	jne    8012c6 <close_all+0xc>
		close(i);
}
  8012da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	57                   	push   %edi
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
  8012e5:	83 ec 2c             	sub    $0x2c,%esp
  8012e8:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8012eb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012ee:	50                   	push   %eax
  8012ef:	ff 75 08             	pushl  0x8(%ebp)
  8012f2:	e8 6d fe ff ff       	call   801164 <fd_lookup>
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	83 c4 08             	add    $0x8,%esp
  8012fc:	85 d2                	test   %edx,%edx
  8012fe:	0f 88 c1 00 00 00    	js     8013c5 <dup+0xe6>
		return r;
	close(newfdnum);
  801304:	83 ec 0c             	sub    $0xc,%esp
  801307:	56                   	push   %esi
  801308:	e8 80 ff ff ff       	call   80128d <close>

	newfd = INDEX2FD(newfdnum);
  80130d:	89 f3                	mov    %esi,%ebx
  80130f:	c1 e3 0c             	shl    $0xc,%ebx
  801312:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801318:	83 c4 04             	add    $0x4,%esp
  80131b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80131e:	e8 db fd ff ff       	call   8010fe <fd2data>
  801323:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801325:	89 1c 24             	mov    %ebx,(%esp)
  801328:	e8 d1 fd ff ff       	call   8010fe <fd2data>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801333:	89 f8                	mov    %edi,%eax
  801335:	c1 e8 16             	shr    $0x16,%eax
  801338:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80133f:	a8 01                	test   $0x1,%al
  801341:	74 37                	je     80137a <dup+0x9b>
  801343:	89 f8                	mov    %edi,%eax
  801345:	c1 e8 0c             	shr    $0xc,%eax
  801348:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80134f:	f6 c2 01             	test   $0x1,%dl
  801352:	74 26                	je     80137a <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801354:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80135b:	83 ec 0c             	sub    $0xc,%esp
  80135e:	25 07 0e 00 00       	and    $0xe07,%eax
  801363:	50                   	push   %eax
  801364:	ff 75 d4             	pushl  -0x2c(%ebp)
  801367:	6a 00                	push   $0x0
  801369:	57                   	push   %edi
  80136a:	6a 00                	push   $0x0
  80136c:	e8 5c fa ff ff       	call   800dcd <sys_page_map>
  801371:	89 c7                	mov    %eax,%edi
  801373:	83 c4 20             	add    $0x20,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 2e                	js     8013a8 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80137a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80137d:	89 d0                	mov    %edx,%eax
  80137f:	c1 e8 0c             	shr    $0xc,%eax
  801382:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801389:	83 ec 0c             	sub    $0xc,%esp
  80138c:	25 07 0e 00 00       	and    $0xe07,%eax
  801391:	50                   	push   %eax
  801392:	53                   	push   %ebx
  801393:	6a 00                	push   $0x0
  801395:	52                   	push   %edx
  801396:	6a 00                	push   $0x0
  801398:	e8 30 fa ff ff       	call   800dcd <sys_page_map>
  80139d:	89 c7                	mov    %eax,%edi
  80139f:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8013a2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013a4:	85 ff                	test   %edi,%edi
  8013a6:	79 1d                	jns    8013c5 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	53                   	push   %ebx
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 5c fa ff ff       	call   800e0f <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013b3:	83 c4 08             	add    $0x8,%esp
  8013b6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013b9:	6a 00                	push   $0x0
  8013bb:	e8 4f fa ff ff       	call   800e0f <sys_page_unmap>
	return r;
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	89 f8                	mov    %edi,%eax
}
  8013c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c8:	5b                   	pop    %ebx
  8013c9:	5e                   	pop    %esi
  8013ca:	5f                   	pop    %edi
  8013cb:	5d                   	pop    %ebp
  8013cc:	c3                   	ret    

008013cd <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013cd:	55                   	push   %ebp
  8013ce:	89 e5                	mov    %esp,%ebp
  8013d0:	53                   	push   %ebx
  8013d1:	83 ec 14             	sub    $0x14,%esp
  8013d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013da:	50                   	push   %eax
  8013db:	53                   	push   %ebx
  8013dc:	e8 83 fd ff ff       	call   801164 <fd_lookup>
  8013e1:	83 c4 08             	add    $0x8,%esp
  8013e4:	89 c2                	mov    %eax,%edx
  8013e6:	85 c0                	test   %eax,%eax
  8013e8:	78 6d                	js     801457 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013ea:	83 ec 08             	sub    $0x8,%esp
  8013ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f0:	50                   	push   %eax
  8013f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f4:	ff 30                	pushl  (%eax)
  8013f6:	e8 bf fd ff ff       	call   8011ba <dev_lookup>
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	85 c0                	test   %eax,%eax
  801400:	78 4c                	js     80144e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801402:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801405:	8b 42 08             	mov    0x8(%edx),%eax
  801408:	83 e0 03             	and    $0x3,%eax
  80140b:	83 f8 01             	cmp    $0x1,%eax
  80140e:	75 21                	jne    801431 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801410:	a1 40 44 80 00       	mov    0x804440,%eax
  801415:	8b 40 48             	mov    0x48(%eax),%eax
  801418:	83 ec 04             	sub    $0x4,%esp
  80141b:	53                   	push   %ebx
  80141c:	50                   	push   %eax
  80141d:	68 4d 27 80 00       	push   $0x80274d
  801422:	e8 d5 ef ff ff       	call   8003fc <cprintf>
		return -E_INVAL;
  801427:	83 c4 10             	add    $0x10,%esp
  80142a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80142f:	eb 26                	jmp    801457 <read+0x8a>
	}
	if (!dev->dev_read)
  801431:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801434:	8b 40 08             	mov    0x8(%eax),%eax
  801437:	85 c0                	test   %eax,%eax
  801439:	74 17                	je     801452 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	ff 75 10             	pushl  0x10(%ebp)
  801441:	ff 75 0c             	pushl  0xc(%ebp)
  801444:	52                   	push   %edx
  801445:	ff d0                	call   *%eax
  801447:	89 c2                	mov    %eax,%edx
  801449:	83 c4 10             	add    $0x10,%esp
  80144c:	eb 09                	jmp    801457 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144e:	89 c2                	mov    %eax,%edx
  801450:	eb 05                	jmp    801457 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801452:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801457:	89 d0                	mov    %edx,%eax
  801459:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	57                   	push   %edi
  801462:	56                   	push   %esi
  801463:	53                   	push   %ebx
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	8b 7d 08             	mov    0x8(%ebp),%edi
  80146a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80146d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801472:	eb 21                	jmp    801495 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801474:	83 ec 04             	sub    $0x4,%esp
  801477:	89 f0                	mov    %esi,%eax
  801479:	29 d8                	sub    %ebx,%eax
  80147b:	50                   	push   %eax
  80147c:	89 d8                	mov    %ebx,%eax
  80147e:	03 45 0c             	add    0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	57                   	push   %edi
  801483:	e8 45 ff ff ff       	call   8013cd <read>
		if (m < 0)
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 0c                	js     80149b <readn+0x3d>
			return m;
		if (m == 0)
  80148f:	85 c0                	test   %eax,%eax
  801491:	74 06                	je     801499 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801493:	01 c3                	add    %eax,%ebx
  801495:	39 f3                	cmp    %esi,%ebx
  801497:	72 db                	jb     801474 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801499:	89 d8                	mov    %ebx,%eax
}
  80149b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80149e:	5b                   	pop    %ebx
  80149f:	5e                   	pop    %esi
  8014a0:	5f                   	pop    %edi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 14             	sub    $0x14,%esp
  8014aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b0:	50                   	push   %eax
  8014b1:	53                   	push   %ebx
  8014b2:	e8 ad fc ff ff       	call   801164 <fd_lookup>
  8014b7:	83 c4 08             	add    $0x8,%esp
  8014ba:	89 c2                	mov    %eax,%edx
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 68                	js     801528 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c0:	83 ec 08             	sub    $0x8,%esp
  8014c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c6:	50                   	push   %eax
  8014c7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ca:	ff 30                	pushl  (%eax)
  8014cc:	e8 e9 fc ff ff       	call   8011ba <dev_lookup>
  8014d1:	83 c4 10             	add    $0x10,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 47                	js     80151f <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014db:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014df:	75 21                	jne    801502 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e1:	a1 40 44 80 00       	mov    0x804440,%eax
  8014e6:	8b 40 48             	mov    0x48(%eax),%eax
  8014e9:	83 ec 04             	sub    $0x4,%esp
  8014ec:	53                   	push   %ebx
  8014ed:	50                   	push   %eax
  8014ee:	68 69 27 80 00       	push   $0x802769
  8014f3:	e8 04 ef ff ff       	call   8003fc <cprintf>
		return -E_INVAL;
  8014f8:	83 c4 10             	add    $0x10,%esp
  8014fb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801500:	eb 26                	jmp    801528 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801502:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801505:	8b 52 0c             	mov    0xc(%edx),%edx
  801508:	85 d2                	test   %edx,%edx
  80150a:	74 17                	je     801523 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80150c:	83 ec 04             	sub    $0x4,%esp
  80150f:	ff 75 10             	pushl  0x10(%ebp)
  801512:	ff 75 0c             	pushl  0xc(%ebp)
  801515:	50                   	push   %eax
  801516:	ff d2                	call   *%edx
  801518:	89 c2                	mov    %eax,%edx
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	eb 09                	jmp    801528 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80151f:	89 c2                	mov    %eax,%edx
  801521:	eb 05                	jmp    801528 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801523:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801528:	89 d0                	mov    %edx,%eax
  80152a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80152d:	c9                   	leave  
  80152e:	c3                   	ret    

0080152f <seek>:

int
seek(int fdnum, off_t offset)
{
  80152f:	55                   	push   %ebp
  801530:	89 e5                	mov    %esp,%ebp
  801532:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801535:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	ff 75 08             	pushl  0x8(%ebp)
  80153c:	e8 23 fc ff ff       	call   801164 <fd_lookup>
  801541:	83 c4 08             	add    $0x8,%esp
  801544:	85 c0                	test   %eax,%eax
  801546:	78 0e                	js     801556 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801548:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80154b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80154e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801556:	c9                   	leave  
  801557:	c3                   	ret    

00801558 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	53                   	push   %ebx
  80155c:	83 ec 14             	sub    $0x14,%esp
  80155f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801562:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	53                   	push   %ebx
  801567:	e8 f8 fb ff ff       	call   801164 <fd_lookup>
  80156c:	83 c4 08             	add    $0x8,%esp
  80156f:	89 c2                	mov    %eax,%edx
  801571:	85 c0                	test   %eax,%eax
  801573:	78 65                	js     8015da <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157b:	50                   	push   %eax
  80157c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80157f:	ff 30                	pushl  (%eax)
  801581:	e8 34 fc ff ff       	call   8011ba <dev_lookup>
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	78 44                	js     8015d1 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80158d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801590:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801594:	75 21                	jne    8015b7 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801596:	a1 40 44 80 00       	mov    0x804440,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80159b:	8b 40 48             	mov    0x48(%eax),%eax
  80159e:	83 ec 04             	sub    $0x4,%esp
  8015a1:	53                   	push   %ebx
  8015a2:	50                   	push   %eax
  8015a3:	68 2c 27 80 00       	push   $0x80272c
  8015a8:	e8 4f ee ff ff       	call   8003fc <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015b5:	eb 23                	jmp    8015da <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8015b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015ba:	8b 52 18             	mov    0x18(%edx),%edx
  8015bd:	85 d2                	test   %edx,%edx
  8015bf:	74 14                	je     8015d5 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c1:	83 ec 08             	sub    $0x8,%esp
  8015c4:	ff 75 0c             	pushl  0xc(%ebp)
  8015c7:	50                   	push   %eax
  8015c8:	ff d2                	call   *%edx
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	83 c4 10             	add    $0x10,%esp
  8015cf:	eb 09                	jmp    8015da <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	eb 05                	jmp    8015da <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8015d5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8015da:	89 d0                	mov    %edx,%eax
  8015dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	53                   	push   %ebx
  8015e5:	83 ec 14             	sub    $0x14,%esp
  8015e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	ff 75 08             	pushl  0x8(%ebp)
  8015f2:	e8 6d fb ff ff       	call   801164 <fd_lookup>
  8015f7:	83 c4 08             	add    $0x8,%esp
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	85 c0                	test   %eax,%eax
  8015fe:	78 58                	js     801658 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801606:	50                   	push   %eax
  801607:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160a:	ff 30                	pushl  (%eax)
  80160c:	e8 a9 fb ff ff       	call   8011ba <dev_lookup>
  801611:	83 c4 10             	add    $0x10,%esp
  801614:	85 c0                	test   %eax,%eax
  801616:	78 37                	js     80164f <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801618:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80161b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80161f:	74 32                	je     801653 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801621:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801624:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80162b:	00 00 00 
	stat->st_isdir = 0;
  80162e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801635:	00 00 00 
	stat->st_dev = dev;
  801638:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80163e:	83 ec 08             	sub    $0x8,%esp
  801641:	53                   	push   %ebx
  801642:	ff 75 f0             	pushl  -0x10(%ebp)
  801645:	ff 50 14             	call   *0x14(%eax)
  801648:	89 c2                	mov    %eax,%edx
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	eb 09                	jmp    801658 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80164f:	89 c2                	mov    %eax,%edx
  801651:	eb 05                	jmp    801658 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801653:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801658:	89 d0                	mov    %edx,%eax
  80165a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	56                   	push   %esi
  801663:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801664:	83 ec 08             	sub    $0x8,%esp
  801667:	6a 00                	push   $0x0
  801669:	ff 75 08             	pushl  0x8(%ebp)
  80166c:	e8 e7 01 00 00       	call   801858 <open>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 db                	test   %ebx,%ebx
  801678:	78 1b                	js     801695 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	ff 75 0c             	pushl  0xc(%ebp)
  801680:	53                   	push   %ebx
  801681:	e8 5b ff ff ff       	call   8015e1 <fstat>
  801686:	89 c6                	mov    %eax,%esi
	close(fd);
  801688:	89 1c 24             	mov    %ebx,(%esp)
  80168b:	e8 fd fb ff ff       	call   80128d <close>
	return r;
  801690:	83 c4 10             	add    $0x10,%esp
  801693:	89 f0                	mov    %esi,%eax
}
  801695:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801698:	5b                   	pop    %ebx
  801699:	5e                   	pop    %esi
  80169a:	5d                   	pop    %ebp
  80169b:	c3                   	ret    

0080169c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	56                   	push   %esi
  8016a0:	53                   	push   %ebx
  8016a1:	89 c6                	mov    %eax,%esi
  8016a3:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016a5:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ac:	75 12                	jne    8016c0 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016ae:	83 ec 0c             	sub    $0xc,%esp
  8016b1:	6a 03                	push   $0x3
  8016b3:	e8 e6 08 00 00       	call   801f9e <ipc_find_env>
  8016b8:	a3 00 40 80 00       	mov    %eax,0x804000
  8016bd:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c0:	6a 07                	push   $0x7
  8016c2:	68 00 50 80 00       	push   $0x805000
  8016c7:	56                   	push   %esi
  8016c8:	ff 35 00 40 80 00    	pushl  0x804000
  8016ce:	e8 7a 08 00 00       	call   801f4d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d3:	83 c4 0c             	add    $0xc,%esp
  8016d6:	6a 00                	push   $0x0
  8016d8:	53                   	push   %ebx
  8016d9:	6a 00                	push   $0x0
  8016db:	e8 07 08 00 00       	call   801ee7 <ipc_recv>
}
  8016e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e3:	5b                   	pop    %ebx
  8016e4:	5e                   	pop    %esi
  8016e5:	5d                   	pop    %ebp
  8016e6:	c3                   	ret    

008016e7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e7:	55                   	push   %ebp
  8016e8:	89 e5                	mov    %esp,%ebp
  8016ea:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016fb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801700:	ba 00 00 00 00       	mov    $0x0,%edx
  801705:	b8 02 00 00 00       	mov    $0x2,%eax
  80170a:	e8 8d ff ff ff       	call   80169c <fsipc>
}
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801717:	8b 45 08             	mov    0x8(%ebp),%eax
  80171a:	8b 40 0c             	mov    0xc(%eax),%eax
  80171d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801722:	ba 00 00 00 00       	mov    $0x0,%edx
  801727:	b8 06 00 00 00       	mov    $0x6,%eax
  80172c:	e8 6b ff ff ff       	call   80169c <fsipc>
}
  801731:	c9                   	leave  
  801732:	c3                   	ret    

00801733 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	53                   	push   %ebx
  801737:	83 ec 04             	sub    $0x4,%esp
  80173a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80173d:	8b 45 08             	mov    0x8(%ebp),%eax
  801740:	8b 40 0c             	mov    0xc(%eax),%eax
  801743:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801748:	ba 00 00 00 00       	mov    $0x0,%edx
  80174d:	b8 05 00 00 00       	mov    $0x5,%eax
  801752:	e8 45 ff ff ff       	call   80169c <fsipc>
  801757:	89 c2                	mov    %eax,%edx
  801759:	85 d2                	test   %edx,%edx
  80175b:	78 2c                	js     801789 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	68 00 50 80 00       	push   $0x805000
  801765:	53                   	push   %ebx
  801766:	e8 15 f2 ff ff       	call   800980 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80176b:	a1 80 50 80 00       	mov    0x805080,%eax
  801770:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801776:	a1 84 50 80 00       	mov    0x805084,%eax
  80177b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801781:	83 c4 10             	add    $0x10,%esp
  801784:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801789:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178c:	c9                   	leave  
  80178d:	c3                   	ret    

0080178e <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801797:	8b 55 08             	mov    0x8(%ebp),%edx
  80179a:	8b 52 0c             	mov    0xc(%edx),%edx
  80179d:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8017a3:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8017a8:	76 05                	jbe    8017af <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8017aa:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8017af:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8017b4:	83 ec 04             	sub    $0x4,%esp
  8017b7:	50                   	push   %eax
  8017b8:	ff 75 0c             	pushl  0xc(%ebp)
  8017bb:	68 08 50 80 00       	push   $0x805008
  8017c0:	e8 4d f3 ff ff       	call   800b12 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8017c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8017cf:	e8 c8 fe ff ff       	call   80169c <fsipc>
	return write;
}
  8017d4:	c9                   	leave  
  8017d5:	c3                   	ret    

008017d6 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017d6:	55                   	push   %ebp
  8017d7:	89 e5                	mov    %esp,%ebp
  8017d9:	56                   	push   %esi
  8017da:	53                   	push   %ebx
  8017db:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017e9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f9:	e8 9e fe ff ff       	call   80169c <fsipc>
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	85 c0                	test   %eax,%eax
  801802:	78 4b                	js     80184f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801804:	39 c6                	cmp    %eax,%esi
  801806:	73 16                	jae    80181e <devfile_read+0x48>
  801808:	68 98 27 80 00       	push   $0x802798
  80180d:	68 9f 27 80 00       	push   $0x80279f
  801812:	6a 7c                	push   $0x7c
  801814:	68 b4 27 80 00       	push   $0x8027b4
  801819:	e8 05 eb ff ff       	call   800323 <_panic>
	assert(r <= PGSIZE);
  80181e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801823:	7e 16                	jle    80183b <devfile_read+0x65>
  801825:	68 bf 27 80 00       	push   $0x8027bf
  80182a:	68 9f 27 80 00       	push   $0x80279f
  80182f:	6a 7d                	push   $0x7d
  801831:	68 b4 27 80 00       	push   $0x8027b4
  801836:	e8 e8 ea ff ff       	call   800323 <_panic>
	memmove(buf, &fsipcbuf, r);
  80183b:	83 ec 04             	sub    $0x4,%esp
  80183e:	50                   	push   %eax
  80183f:	68 00 50 80 00       	push   $0x805000
  801844:	ff 75 0c             	pushl  0xc(%ebp)
  801847:	e8 c6 f2 ff ff       	call   800b12 <memmove>
	return r;
  80184c:	83 c4 10             	add    $0x10,%esp
}
  80184f:	89 d8                	mov    %ebx,%eax
  801851:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801854:	5b                   	pop    %ebx
  801855:	5e                   	pop    %esi
  801856:	5d                   	pop    %ebp
  801857:	c3                   	ret    

00801858 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801858:	55                   	push   %ebp
  801859:	89 e5                	mov    %esp,%ebp
  80185b:	53                   	push   %ebx
  80185c:	83 ec 20             	sub    $0x20,%esp
  80185f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801862:	53                   	push   %ebx
  801863:	e8 df f0 ff ff       	call   800947 <strlen>
  801868:	83 c4 10             	add    $0x10,%esp
  80186b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801870:	7f 67                	jg     8018d9 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801878:	50                   	push   %eax
  801879:	e8 97 f8 ff ff       	call   801115 <fd_alloc>
  80187e:	83 c4 10             	add    $0x10,%esp
		return r;
  801881:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801883:	85 c0                	test   %eax,%eax
  801885:	78 57                	js     8018de <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801887:	83 ec 08             	sub    $0x8,%esp
  80188a:	53                   	push   %ebx
  80188b:	68 00 50 80 00       	push   $0x805000
  801890:	e8 eb f0 ff ff       	call   800980 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801895:	8b 45 0c             	mov    0xc(%ebp),%eax
  801898:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80189d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a0:	b8 01 00 00 00       	mov    $0x1,%eax
  8018a5:	e8 f2 fd ff ff       	call   80169c <fsipc>
  8018aa:	89 c3                	mov    %eax,%ebx
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	85 c0                	test   %eax,%eax
  8018b1:	79 14                	jns    8018c7 <open+0x6f>
		fd_close(fd, 0);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	6a 00                	push   $0x0
  8018b8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018bb:	e8 4d f9 ff ff       	call   80120d <fd_close>
		return r;
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	89 da                	mov    %ebx,%edx
  8018c5:	eb 17                	jmp    8018de <open+0x86>
	}

	return fd2num(fd);
  8018c7:	83 ec 0c             	sub    $0xc,%esp
  8018ca:	ff 75 f4             	pushl  -0xc(%ebp)
  8018cd:	e8 1c f8 ff ff       	call   8010ee <fd2num>
  8018d2:	89 c2                	mov    %eax,%edx
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	eb 05                	jmp    8018de <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8018d9:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8018de:	89 d0                	mov    %edx,%eax
  8018e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e3:	c9                   	leave  
  8018e4:	c3                   	ret    

008018e5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018eb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f0:	b8 08 00 00 00       	mov    $0x8,%eax
  8018f5:	e8 a2 fd ff ff       	call   80169c <fsipc>
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8018fc:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801900:	7e 3a                	jle    80193c <writebuf+0x40>
};


static void
writebuf(struct printbuf *b)
{
  801902:	55                   	push   %ebp
  801903:	89 e5                	mov    %esp,%ebp
  801905:	53                   	push   %ebx
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  80190b:	ff 70 04             	pushl  0x4(%eax)
  80190e:	8d 40 10             	lea    0x10(%eax),%eax
  801911:	50                   	push   %eax
  801912:	ff 33                	pushl  (%ebx)
  801914:	e8 8a fb ff ff       	call   8014a3 <write>
		if (result > 0)
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	85 c0                	test   %eax,%eax
  80191e:	7e 03                	jle    801923 <writebuf+0x27>
			b->result += result;
  801920:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801923:	39 43 04             	cmp    %eax,0x4(%ebx)
  801926:	74 10                	je     801938 <writebuf+0x3c>
			b->error = (result < 0 ? result : 0);
  801928:	85 c0                	test   %eax,%eax
  80192a:	0f 9f c2             	setg   %dl
  80192d:	0f b6 d2             	movzbl %dl,%edx
  801930:	83 ea 01             	sub    $0x1,%edx
  801933:	21 d0                	and    %edx,%eax
  801935:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801938:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80193b:	c9                   	leave  
  80193c:	f3 c3                	repz ret 

0080193e <putch>:

static void
putch(int ch, void *thunk)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	53                   	push   %ebx
  801942:	83 ec 04             	sub    $0x4,%esp
  801945:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801948:	8b 53 04             	mov    0x4(%ebx),%edx
  80194b:	8d 42 01             	lea    0x1(%edx),%eax
  80194e:	89 43 04             	mov    %eax,0x4(%ebx)
  801951:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801954:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801958:	3d 00 01 00 00       	cmp    $0x100,%eax
  80195d:	75 0e                	jne    80196d <putch+0x2f>
		writebuf(b);
  80195f:	89 d8                	mov    %ebx,%eax
  801961:	e8 96 ff ff ff       	call   8018fc <writebuf>
		b->idx = 0;
  801966:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  80196d:	83 c4 04             	add    $0x4,%esp
  801970:	5b                   	pop    %ebx
  801971:	5d                   	pop    %ebp
  801972:	c3                   	ret    

00801973 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801985:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80198c:	00 00 00 
	b.result = 0;
  80198f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801996:	00 00 00 
	b.error = 1;
  801999:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8019a0:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8019a3:	ff 75 10             	pushl  0x10(%ebp)
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019af:	50                   	push   %eax
  8019b0:	68 3e 19 80 00       	push   $0x80193e
  8019b5:	e8 74 eb ff ff       	call   80052e <vprintfmt>
	if (b.idx > 0)
  8019ba:	83 c4 10             	add    $0x10,%esp
  8019bd:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8019c4:	7e 0b                	jle    8019d1 <vfprintf+0x5e>
		writebuf(&b);
  8019c6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8019cc:	e8 2b ff ff ff       	call   8018fc <writebuf>

	return (b.result ? b.result : b.error);
  8019d1:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	75 06                	jne    8019e1 <vfprintf+0x6e>
  8019db:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8019e9:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8019ec:	50                   	push   %eax
  8019ed:	ff 75 0c             	pushl  0xc(%ebp)
  8019f0:	ff 75 08             	pushl  0x8(%ebp)
  8019f3:	e8 7b ff ff ff       	call   801973 <vfprintf>
	va_end(ap);

	return cnt;
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <printf>:

int
printf(const char *fmt, ...)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a00:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801a03:	50                   	push   %eax
  801a04:	ff 75 08             	pushl  0x8(%ebp)
  801a07:	6a 01                	push   $0x1
  801a09:	e8 65 ff ff ff       	call   801973 <vfprintf>
	va_end(ap);

	return cnt;
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a18:	83 ec 0c             	sub    $0xc,%esp
  801a1b:	ff 75 08             	pushl  0x8(%ebp)
  801a1e:	e8 db f6 ff ff       	call   8010fe <fd2data>
  801a23:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a25:	83 c4 08             	add    $0x8,%esp
  801a28:	68 cb 27 80 00       	push   $0x8027cb
  801a2d:	53                   	push   %ebx
  801a2e:	e8 4d ef ff ff       	call   800980 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a33:	8b 56 04             	mov    0x4(%esi),%edx
  801a36:	89 d0                	mov    %edx,%eax
  801a38:	2b 06                	sub    (%esi),%eax
  801a3a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a40:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a47:	00 00 00 
	stat->st_dev = &devpipe;
  801a4a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801a51:	30 80 00 
	return 0;
}
  801a54:	b8 00 00 00 00       	mov    $0x0,%eax
  801a59:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a5c:	5b                   	pop    %ebx
  801a5d:	5e                   	pop    %esi
  801a5e:	5d                   	pop    %ebp
  801a5f:	c3                   	ret    

00801a60 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a60:	55                   	push   %ebp
  801a61:	89 e5                	mov    %esp,%ebp
  801a63:	53                   	push   %ebx
  801a64:	83 ec 0c             	sub    $0xc,%esp
  801a67:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a6a:	53                   	push   %ebx
  801a6b:	6a 00                	push   $0x0
  801a6d:	e8 9d f3 ff ff       	call   800e0f <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a72:	89 1c 24             	mov    %ebx,(%esp)
  801a75:	e8 84 f6 ff ff       	call   8010fe <fd2data>
  801a7a:	83 c4 08             	add    $0x8,%esp
  801a7d:	50                   	push   %eax
  801a7e:	6a 00                	push   $0x0
  801a80:	e8 8a f3 ff ff       	call   800e0f <sys_page_unmap>
}
  801a85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a88:	c9                   	leave  
  801a89:	c3                   	ret    

00801a8a <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	57                   	push   %edi
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 1c             	sub    $0x1c,%esp
  801a93:	89 c7                	mov    %eax,%edi
  801a95:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a97:	a1 40 44 80 00       	mov    0x804440,%eax
  801a9c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a9f:	83 ec 0c             	sub    $0xc,%esp
  801aa2:	57                   	push   %edi
  801aa3:	e8 2e 05 00 00       	call   801fd6 <pageref>
  801aa8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801aab:	89 34 24             	mov    %esi,(%esp)
  801aae:	e8 23 05 00 00       	call   801fd6 <pageref>
  801ab3:	83 c4 10             	add    $0x10,%esp
  801ab6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ab9:	0f 94 c0             	sete   %al
  801abc:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801abf:	8b 15 40 44 80 00    	mov    0x804440,%edx
  801ac5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ac8:	39 cb                	cmp    %ecx,%ebx
  801aca:	74 15                	je     801ae1 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801acc:	8b 52 58             	mov    0x58(%edx),%edx
  801acf:	50                   	push   %eax
  801ad0:	52                   	push   %edx
  801ad1:	53                   	push   %ebx
  801ad2:	68 d8 27 80 00       	push   $0x8027d8
  801ad7:	e8 20 e9 ff ff       	call   8003fc <cprintf>
  801adc:	83 c4 10             	add    $0x10,%esp
  801adf:	eb b6                	jmp    801a97 <_pipeisclosed+0xd>
	}
}
  801ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	57                   	push   %edi
  801aed:	56                   	push   %esi
  801aee:	53                   	push   %ebx
  801aef:	83 ec 28             	sub    $0x28,%esp
  801af2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801af5:	56                   	push   %esi
  801af6:	e8 03 f6 ff ff       	call   8010fe <fd2data>
  801afb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801afd:	83 c4 10             	add    $0x10,%esp
  801b00:	bf 00 00 00 00       	mov    $0x0,%edi
  801b05:	eb 4b                	jmp    801b52 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b07:	89 da                	mov    %ebx,%edx
  801b09:	89 f0                	mov    %esi,%eax
  801b0b:	e8 7a ff ff ff       	call   801a8a <_pipeisclosed>
  801b10:	85 c0                	test   %eax,%eax
  801b12:	75 48                	jne    801b5c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b14:	e8 52 f2 ff ff       	call   800d6b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b19:	8b 43 04             	mov    0x4(%ebx),%eax
  801b1c:	8b 0b                	mov    (%ebx),%ecx
  801b1e:	8d 51 20             	lea    0x20(%ecx),%edx
  801b21:	39 d0                	cmp    %edx,%eax
  801b23:	73 e2                	jae    801b07 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b28:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b2c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b2f:	89 c2                	mov    %eax,%edx
  801b31:	c1 fa 1f             	sar    $0x1f,%edx
  801b34:	89 d1                	mov    %edx,%ecx
  801b36:	c1 e9 1b             	shr    $0x1b,%ecx
  801b39:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b3c:	83 e2 1f             	and    $0x1f,%edx
  801b3f:	29 ca                	sub    %ecx,%edx
  801b41:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b45:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b49:	83 c0 01             	add    $0x1,%eax
  801b4c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b4f:	83 c7 01             	add    $0x1,%edi
  801b52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b55:	75 c2                	jne    801b19 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b57:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5a:	eb 05                	jmp    801b61 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b61:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b64:	5b                   	pop    %ebx
  801b65:	5e                   	pop    %esi
  801b66:	5f                   	pop    %edi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	57                   	push   %edi
  801b6d:	56                   	push   %esi
  801b6e:	53                   	push   %ebx
  801b6f:	83 ec 18             	sub    $0x18,%esp
  801b72:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b75:	57                   	push   %edi
  801b76:	e8 83 f5 ff ff       	call   8010fe <fd2data>
  801b7b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b85:	eb 3d                	jmp    801bc4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b87:	85 db                	test   %ebx,%ebx
  801b89:	74 04                	je     801b8f <devpipe_read+0x26>
				return i;
  801b8b:	89 d8                	mov    %ebx,%eax
  801b8d:	eb 44                	jmp    801bd3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b8f:	89 f2                	mov    %esi,%edx
  801b91:	89 f8                	mov    %edi,%eax
  801b93:	e8 f2 fe ff ff       	call   801a8a <_pipeisclosed>
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	75 32                	jne    801bce <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b9c:	e8 ca f1 ff ff       	call   800d6b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ba1:	8b 06                	mov    (%esi),%eax
  801ba3:	3b 46 04             	cmp    0x4(%esi),%eax
  801ba6:	74 df                	je     801b87 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ba8:	99                   	cltd   
  801ba9:	c1 ea 1b             	shr    $0x1b,%edx
  801bac:	01 d0                	add    %edx,%eax
  801bae:	83 e0 1f             	and    $0x1f,%eax
  801bb1:	29 d0                	sub    %edx,%eax
  801bb3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bbe:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc1:	83 c3 01             	add    $0x1,%ebx
  801bc4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bc7:	75 d8                	jne    801ba1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bc9:	8b 45 10             	mov    0x10(%ebp),%eax
  801bcc:	eb 05                	jmp    801bd3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bce:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bd3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd6:	5b                   	pop    %ebx
  801bd7:	5e                   	pop    %esi
  801bd8:	5f                   	pop    %edi
  801bd9:	5d                   	pop    %ebp
  801bda:	c3                   	ret    

00801bdb <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bdb:	55                   	push   %ebp
  801bdc:	89 e5                	mov    %esp,%ebp
  801bde:	56                   	push   %esi
  801bdf:	53                   	push   %ebx
  801be0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801be3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be6:	50                   	push   %eax
  801be7:	e8 29 f5 ff ff       	call   801115 <fd_alloc>
  801bec:	83 c4 10             	add    $0x10,%esp
  801bef:	89 c2                	mov    %eax,%edx
  801bf1:	85 c0                	test   %eax,%eax
  801bf3:	0f 88 2c 01 00 00    	js     801d25 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf9:	83 ec 04             	sub    $0x4,%esp
  801bfc:	68 07 04 00 00       	push   $0x407
  801c01:	ff 75 f4             	pushl  -0xc(%ebp)
  801c04:	6a 00                	push   $0x0
  801c06:	e8 7f f1 ff ff       	call   800d8a <sys_page_alloc>
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	89 c2                	mov    %eax,%edx
  801c10:	85 c0                	test   %eax,%eax
  801c12:	0f 88 0d 01 00 00    	js     801d25 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c18:	83 ec 0c             	sub    $0xc,%esp
  801c1b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c1e:	50                   	push   %eax
  801c1f:	e8 f1 f4 ff ff       	call   801115 <fd_alloc>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	83 c4 10             	add    $0x10,%esp
  801c29:	85 c0                	test   %eax,%eax
  801c2b:	0f 88 e2 00 00 00    	js     801d13 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c31:	83 ec 04             	sub    $0x4,%esp
  801c34:	68 07 04 00 00       	push   $0x407
  801c39:	ff 75 f0             	pushl  -0x10(%ebp)
  801c3c:	6a 00                	push   $0x0
  801c3e:	e8 47 f1 ff ff       	call   800d8a <sys_page_alloc>
  801c43:	89 c3                	mov    %eax,%ebx
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	85 c0                	test   %eax,%eax
  801c4a:	0f 88 c3 00 00 00    	js     801d13 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c50:	83 ec 0c             	sub    $0xc,%esp
  801c53:	ff 75 f4             	pushl  -0xc(%ebp)
  801c56:	e8 a3 f4 ff ff       	call   8010fe <fd2data>
  801c5b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5d:	83 c4 0c             	add    $0xc,%esp
  801c60:	68 07 04 00 00       	push   $0x407
  801c65:	50                   	push   %eax
  801c66:	6a 00                	push   $0x0
  801c68:	e8 1d f1 ff ff       	call   800d8a <sys_page_alloc>
  801c6d:	89 c3                	mov    %eax,%ebx
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	85 c0                	test   %eax,%eax
  801c74:	0f 88 89 00 00 00    	js     801d03 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7a:	83 ec 0c             	sub    $0xc,%esp
  801c7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c80:	e8 79 f4 ff ff       	call   8010fe <fd2data>
  801c85:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c8c:	50                   	push   %eax
  801c8d:	6a 00                	push   $0x0
  801c8f:	56                   	push   %esi
  801c90:	6a 00                	push   $0x0
  801c92:	e8 36 f1 ff ff       	call   800dcd <sys_page_map>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	83 c4 20             	add    $0x20,%esp
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	78 55                	js     801cf5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ca0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801cab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cb5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cbb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cbe:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cca:	83 ec 0c             	sub    $0xc,%esp
  801ccd:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd0:	e8 19 f4 ff ff       	call   8010ee <fd2num>
  801cd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cd8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cda:	83 c4 04             	add    $0x4,%esp
  801cdd:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce0:	e8 09 f4 ff ff       	call   8010ee <fd2num>
  801ce5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ce8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ceb:	83 c4 10             	add    $0x10,%esp
  801cee:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf3:	eb 30                	jmp    801d25 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cf5:	83 ec 08             	sub    $0x8,%esp
  801cf8:	56                   	push   %esi
  801cf9:	6a 00                	push   $0x0
  801cfb:	e8 0f f1 ff ff       	call   800e0f <sys_page_unmap>
  801d00:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d03:	83 ec 08             	sub    $0x8,%esp
  801d06:	ff 75 f0             	pushl  -0x10(%ebp)
  801d09:	6a 00                	push   $0x0
  801d0b:	e8 ff f0 ff ff       	call   800e0f <sys_page_unmap>
  801d10:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d13:	83 ec 08             	sub    $0x8,%esp
  801d16:	ff 75 f4             	pushl  -0xc(%ebp)
  801d19:	6a 00                	push   $0x0
  801d1b:	e8 ef f0 ff ff       	call   800e0f <sys_page_unmap>
  801d20:	83 c4 10             	add    $0x10,%esp
  801d23:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d25:	89 d0                	mov    %edx,%eax
  801d27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2a:	5b                   	pop    %ebx
  801d2b:	5e                   	pop    %esi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d37:	50                   	push   %eax
  801d38:	ff 75 08             	pushl  0x8(%ebp)
  801d3b:	e8 24 f4 ff ff       	call   801164 <fd_lookup>
  801d40:	89 c2                	mov    %eax,%edx
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	85 d2                	test   %edx,%edx
  801d47:	78 18                	js     801d61 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d49:	83 ec 0c             	sub    $0xc,%esp
  801d4c:	ff 75 f4             	pushl  -0xc(%ebp)
  801d4f:	e8 aa f3 ff ff       	call   8010fe <fd2data>
	return _pipeisclosed(fd, p);
  801d54:	89 c2                	mov    %eax,%edx
  801d56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d59:	e8 2c fd ff ff       	call   801a8a <_pipeisclosed>
  801d5e:	83 c4 10             	add    $0x10,%esp
}
  801d61:	c9                   	leave  
  801d62:	c3                   	ret    

00801d63 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d63:	55                   	push   %ebp
  801d64:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d66:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6b:	5d                   	pop    %ebp
  801d6c:	c3                   	ret    

00801d6d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d6d:	55                   	push   %ebp
  801d6e:	89 e5                	mov    %esp,%ebp
  801d70:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d73:	68 0c 28 80 00       	push   $0x80280c
  801d78:	ff 75 0c             	pushl  0xc(%ebp)
  801d7b:	e8 00 ec ff ff       	call   800980 <strcpy>
	return 0;
}
  801d80:	b8 00 00 00 00       	mov    $0x0,%eax
  801d85:	c9                   	leave  
  801d86:	c3                   	ret    

00801d87 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d87:	55                   	push   %ebp
  801d88:	89 e5                	mov    %esp,%ebp
  801d8a:	57                   	push   %edi
  801d8b:	56                   	push   %esi
  801d8c:	53                   	push   %ebx
  801d8d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d93:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d98:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d9e:	eb 2e                	jmp    801dce <devcons_write+0x47>
		m = n - tot;
  801da0:	8b 55 10             	mov    0x10(%ebp),%edx
  801da3:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801da5:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801daa:	83 fa 7f             	cmp    $0x7f,%edx
  801dad:	77 02                	ja     801db1 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801daf:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db1:	83 ec 04             	sub    $0x4,%esp
  801db4:	56                   	push   %esi
  801db5:	03 45 0c             	add    0xc(%ebp),%eax
  801db8:	50                   	push   %eax
  801db9:	57                   	push   %edi
  801dba:	e8 53 ed ff ff       	call   800b12 <memmove>
		sys_cputs(buf, m);
  801dbf:	83 c4 08             	add    $0x8,%esp
  801dc2:	56                   	push   %esi
  801dc3:	57                   	push   %edi
  801dc4:	e8 05 ef ff ff       	call   800cce <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dc9:	01 f3                	add    %esi,%ebx
  801dcb:	83 c4 10             	add    $0x10,%esp
  801dce:	89 d8                	mov    %ebx,%eax
  801dd0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801dd3:	72 cb                	jb     801da0 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd8:	5b                   	pop    %ebx
  801dd9:	5e                   	pop    %esi
  801dda:	5f                   	pop    %edi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801de3:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801de8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dec:	75 07                	jne    801df5 <devcons_read+0x18>
  801dee:	eb 28                	jmp    801e18 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801df0:	e8 76 ef ff ff       	call   800d6b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801df5:	e8 f2 ee ff ff       	call   800cec <sys_cgetc>
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	74 f2                	je     801df0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 16                	js     801e18 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e02:	83 f8 04             	cmp    $0x4,%eax
  801e05:	74 0c                	je     801e13 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e07:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0a:	88 02                	mov    %al,(%edx)
	return 1;
  801e0c:	b8 01 00 00 00       	mov    $0x1,%eax
  801e11:	eb 05                	jmp    801e18 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e13:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e18:	c9                   	leave  
  801e19:	c3                   	ret    

00801e1a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801e1a:	55                   	push   %ebp
  801e1b:	89 e5                	mov    %esp,%ebp
  801e1d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e20:	8b 45 08             	mov    0x8(%ebp),%eax
  801e23:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e26:	6a 01                	push   $0x1
  801e28:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2b:	50                   	push   %eax
  801e2c:	e8 9d ee ff ff       	call   800cce <sys_cputs>
  801e31:	83 c4 10             	add    $0x10,%esp
}
  801e34:	c9                   	leave  
  801e35:	c3                   	ret    

00801e36 <getchar>:

int
getchar(void)
{
  801e36:	55                   	push   %ebp
  801e37:	89 e5                	mov    %esp,%ebp
  801e39:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e3c:	6a 01                	push   $0x1
  801e3e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e41:	50                   	push   %eax
  801e42:	6a 00                	push   $0x0
  801e44:	e8 84 f5 ff ff       	call   8013cd <read>
	if (r < 0)
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 0f                	js     801e5f <getchar+0x29>
		return r;
	if (r < 1)
  801e50:	85 c0                	test   %eax,%eax
  801e52:	7e 06                	jle    801e5a <getchar+0x24>
		return -E_EOF;
	return c;
  801e54:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e58:	eb 05                	jmp    801e5f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e5a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e5f:	c9                   	leave  
  801e60:	c3                   	ret    

00801e61 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e61:	55                   	push   %ebp
  801e62:	89 e5                	mov    %esp,%ebp
  801e64:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6a:	50                   	push   %eax
  801e6b:	ff 75 08             	pushl  0x8(%ebp)
  801e6e:	e8 f1 f2 ff ff       	call   801164 <fd_lookup>
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 11                	js     801e8b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7d:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e83:	39 10                	cmp    %edx,(%eax)
  801e85:	0f 94 c0             	sete   %al
  801e88:	0f b6 c0             	movzbl %al,%eax
}
  801e8b:	c9                   	leave  
  801e8c:	c3                   	ret    

00801e8d <opencons>:

int
opencons(void)
{
  801e8d:	55                   	push   %ebp
  801e8e:	89 e5                	mov    %esp,%ebp
  801e90:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e93:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e96:	50                   	push   %eax
  801e97:	e8 79 f2 ff ff       	call   801115 <fd_alloc>
  801e9c:	83 c4 10             	add    $0x10,%esp
		return r;
  801e9f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	78 3e                	js     801ee3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea5:	83 ec 04             	sub    $0x4,%esp
  801ea8:	68 07 04 00 00       	push   $0x407
  801ead:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb0:	6a 00                	push   $0x0
  801eb2:	e8 d3 ee ff ff       	call   800d8a <sys_page_alloc>
  801eb7:	83 c4 10             	add    $0x10,%esp
		return r;
  801eba:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	78 23                	js     801ee3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ec0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ec6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ecb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ece:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ed5:	83 ec 0c             	sub    $0xc,%esp
  801ed8:	50                   	push   %eax
  801ed9:	e8 10 f2 ff ff       	call   8010ee <fd2num>
  801ede:	89 c2                	mov    %eax,%edx
  801ee0:	83 c4 10             	add    $0x10,%esp
}
  801ee3:	89 d0                	mov    %edx,%eax
  801ee5:	c9                   	leave  
  801ee6:	c3                   	ret    

00801ee7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	56                   	push   %esi
  801eeb:	53                   	push   %ebx
  801eec:	8b 75 08             	mov    0x8(%ebp),%esi
  801eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801ef5:	85 f6                	test   %esi,%esi
  801ef7:	74 06                	je     801eff <ipc_recv+0x18>
  801ef9:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801eff:	85 db                	test   %ebx,%ebx
  801f01:	74 06                	je     801f09 <ipc_recv+0x22>
  801f03:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801f09:	83 f8 01             	cmp    $0x1,%eax
  801f0c:	19 d2                	sbb    %edx,%edx
  801f0e:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801f10:	83 ec 0c             	sub    $0xc,%esp
  801f13:	50                   	push   %eax
  801f14:	e8 21 f0 ff ff       	call   800f3a <sys_ipc_recv>
  801f19:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801f1b:	83 c4 10             	add    $0x10,%esp
  801f1e:	85 d2                	test   %edx,%edx
  801f20:	75 24                	jne    801f46 <ipc_recv+0x5f>
	if (from_env_store)
  801f22:	85 f6                	test   %esi,%esi
  801f24:	74 0a                	je     801f30 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801f26:	a1 40 44 80 00       	mov    0x804440,%eax
  801f2b:	8b 40 70             	mov    0x70(%eax),%eax
  801f2e:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801f30:	85 db                	test   %ebx,%ebx
  801f32:	74 0a                	je     801f3e <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801f34:	a1 40 44 80 00       	mov    0x804440,%eax
  801f39:	8b 40 74             	mov    0x74(%eax),%eax
  801f3c:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801f3e:	a1 40 44 80 00       	mov    0x804440,%eax
  801f43:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801f46:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f49:	5b                   	pop    %ebx
  801f4a:	5e                   	pop    %esi
  801f4b:	5d                   	pop    %ebp
  801f4c:	c3                   	ret    

00801f4d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f4d:	55                   	push   %ebp
  801f4e:	89 e5                	mov    %esp,%ebp
  801f50:	57                   	push   %edi
  801f51:	56                   	push   %esi
  801f52:	53                   	push   %ebx
  801f53:	83 ec 0c             	sub    $0xc,%esp
  801f56:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f59:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f5c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801f5f:	83 fb 01             	cmp    $0x1,%ebx
  801f62:	19 c0                	sbb    %eax,%eax
  801f64:	09 c3                	or     %eax,%ebx
  801f66:	eb 1c                	jmp    801f84 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801f68:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f6b:	74 12                	je     801f7f <ipc_send+0x32>
  801f6d:	50                   	push   %eax
  801f6e:	68 18 28 80 00       	push   $0x802818
  801f73:	6a 36                	push   $0x36
  801f75:	68 2f 28 80 00       	push   $0x80282f
  801f7a:	e8 a4 e3 ff ff       	call   800323 <_panic>
		sys_yield();
  801f7f:	e8 e7 ed ff ff       	call   800d6b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801f84:	ff 75 14             	pushl  0x14(%ebp)
  801f87:	53                   	push   %ebx
  801f88:	56                   	push   %esi
  801f89:	57                   	push   %edi
  801f8a:	e8 88 ef ff ff       	call   800f17 <sys_ipc_try_send>
		if (ret == 0) break;
  801f8f:	83 c4 10             	add    $0x10,%esp
  801f92:	85 c0                	test   %eax,%eax
  801f94:	75 d2                	jne    801f68 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f99:	5b                   	pop    %ebx
  801f9a:	5e                   	pop    %esi
  801f9b:	5f                   	pop    %edi
  801f9c:	5d                   	pop    %ebp
  801f9d:	c3                   	ret    

00801f9e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f9e:	55                   	push   %ebp
  801f9f:	89 e5                	mov    %esp,%ebp
  801fa1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa9:	6b d0 78             	imul   $0x78,%eax,%edx
  801fac:	83 c2 50             	add    $0x50,%edx
  801faf:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801fb5:	39 ca                	cmp    %ecx,%edx
  801fb7:	75 0d                	jne    801fc6 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fb9:	6b c0 78             	imul   $0x78,%eax,%eax
  801fbc:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801fc1:	8b 40 08             	mov    0x8(%eax),%eax
  801fc4:	eb 0e                	jmp    801fd4 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fc6:	83 c0 01             	add    $0x1,%eax
  801fc9:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fce:	75 d9                	jne    801fa9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801fd0:	66 b8 00 00          	mov    $0x0,%ax
}
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    

00801fd6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fdc:	89 d0                	mov    %edx,%eax
  801fde:	c1 e8 16             	shr    $0x16,%eax
  801fe1:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801fe8:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fed:	f6 c1 01             	test   $0x1,%cl
  801ff0:	74 1d                	je     80200f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ff2:	c1 ea 0c             	shr    $0xc,%edx
  801ff5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ffc:	f6 c2 01             	test   $0x1,%dl
  801fff:	74 0e                	je     80200f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802001:	c1 ea 0c             	shr    $0xc,%edx
  802004:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80200b:	ef 
  80200c:	0f b7 c0             	movzwl %ax,%eax
}
  80200f:	5d                   	pop    %ebp
  802010:	c3                   	ret    
  802011:	66 90                	xchg   %ax,%ax
  802013:	66 90                	xchg   %ax,%ax
  802015:	66 90                	xchg   %ax,%ax
  802017:	66 90                	xchg   %ax,%ax
  802019:	66 90                	xchg   %ax,%ax
  80201b:	66 90                	xchg   %ax,%ax
  80201d:	66 90                	xchg   %ax,%ax
  80201f:	90                   	nop

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	57                   	push   %edi
  802022:	56                   	push   %esi
  802023:	83 ec 10             	sub    $0x10,%esp
  802026:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80202a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80202e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802032:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802036:	85 d2                	test   %edx,%edx
  802038:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80203c:	89 34 24             	mov    %esi,(%esp)
  80203f:	89 c8                	mov    %ecx,%eax
  802041:	75 35                	jne    802078 <__udivdi3+0x58>
  802043:	39 f1                	cmp    %esi,%ecx
  802045:	0f 87 bd 00 00 00    	ja     802108 <__udivdi3+0xe8>
  80204b:	85 c9                	test   %ecx,%ecx
  80204d:	89 cd                	mov    %ecx,%ebp
  80204f:	75 0b                	jne    80205c <__udivdi3+0x3c>
  802051:	b8 01 00 00 00       	mov    $0x1,%eax
  802056:	31 d2                	xor    %edx,%edx
  802058:	f7 f1                	div    %ecx
  80205a:	89 c5                	mov    %eax,%ebp
  80205c:	89 f0                	mov    %esi,%eax
  80205e:	31 d2                	xor    %edx,%edx
  802060:	f7 f5                	div    %ebp
  802062:	89 c6                	mov    %eax,%esi
  802064:	89 f8                	mov    %edi,%eax
  802066:	f7 f5                	div    %ebp
  802068:	89 f2                	mov    %esi,%edx
  80206a:	83 c4 10             	add    $0x10,%esp
  80206d:	5e                   	pop    %esi
  80206e:	5f                   	pop    %edi
  80206f:	5d                   	pop    %ebp
  802070:	c3                   	ret    
  802071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802078:	3b 14 24             	cmp    (%esp),%edx
  80207b:	77 7b                	ja     8020f8 <__udivdi3+0xd8>
  80207d:	0f bd f2             	bsr    %edx,%esi
  802080:	83 f6 1f             	xor    $0x1f,%esi
  802083:	0f 84 97 00 00 00    	je     802120 <__udivdi3+0x100>
  802089:	bd 20 00 00 00       	mov    $0x20,%ebp
  80208e:	89 d7                	mov    %edx,%edi
  802090:	89 f1                	mov    %esi,%ecx
  802092:	29 f5                	sub    %esi,%ebp
  802094:	d3 e7                	shl    %cl,%edi
  802096:	89 c2                	mov    %eax,%edx
  802098:	89 e9                	mov    %ebp,%ecx
  80209a:	d3 ea                	shr    %cl,%edx
  80209c:	89 f1                	mov    %esi,%ecx
  80209e:	09 fa                	or     %edi,%edx
  8020a0:	8b 3c 24             	mov    (%esp),%edi
  8020a3:	d3 e0                	shl    %cl,%eax
  8020a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8020a9:	89 e9                	mov    %ebp,%ecx
  8020ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020af:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020b3:	89 fa                	mov    %edi,%edx
  8020b5:	d3 ea                	shr    %cl,%edx
  8020b7:	89 f1                	mov    %esi,%ecx
  8020b9:	d3 e7                	shl    %cl,%edi
  8020bb:	89 e9                	mov    %ebp,%ecx
  8020bd:	d3 e8                	shr    %cl,%eax
  8020bf:	09 c7                	or     %eax,%edi
  8020c1:	89 f8                	mov    %edi,%eax
  8020c3:	f7 74 24 08          	divl   0x8(%esp)
  8020c7:	89 d5                	mov    %edx,%ebp
  8020c9:	89 c7                	mov    %eax,%edi
  8020cb:	f7 64 24 0c          	mull   0xc(%esp)
  8020cf:	39 d5                	cmp    %edx,%ebp
  8020d1:	89 14 24             	mov    %edx,(%esp)
  8020d4:	72 11                	jb     8020e7 <__udivdi3+0xc7>
  8020d6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020da:	89 f1                	mov    %esi,%ecx
  8020dc:	d3 e2                	shl    %cl,%edx
  8020de:	39 c2                	cmp    %eax,%edx
  8020e0:	73 5e                	jae    802140 <__udivdi3+0x120>
  8020e2:	3b 2c 24             	cmp    (%esp),%ebp
  8020e5:	75 59                	jne    802140 <__udivdi3+0x120>
  8020e7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8020ea:	31 f6                	xor    %esi,%esi
  8020ec:	89 f2                	mov    %esi,%edx
  8020ee:	83 c4 10             	add    $0x10,%esp
  8020f1:	5e                   	pop    %esi
  8020f2:	5f                   	pop    %edi
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
  8020f5:	8d 76 00             	lea    0x0(%esi),%esi
  8020f8:	31 f6                	xor    %esi,%esi
  8020fa:	31 c0                	xor    %eax,%eax
  8020fc:	89 f2                	mov    %esi,%edx
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	5e                   	pop    %esi
  802102:	5f                   	pop    %edi
  802103:	5d                   	pop    %ebp
  802104:	c3                   	ret    
  802105:	8d 76 00             	lea    0x0(%esi),%esi
  802108:	89 f2                	mov    %esi,%edx
  80210a:	31 f6                	xor    %esi,%esi
  80210c:	89 f8                	mov    %edi,%eax
  80210e:	f7 f1                	div    %ecx
  802110:	89 f2                	mov    %esi,%edx
  802112:	83 c4 10             	add    $0x10,%esp
  802115:	5e                   	pop    %esi
  802116:	5f                   	pop    %edi
  802117:	5d                   	pop    %ebp
  802118:	c3                   	ret    
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802124:	76 0b                	jbe    802131 <__udivdi3+0x111>
  802126:	31 c0                	xor    %eax,%eax
  802128:	3b 14 24             	cmp    (%esp),%edx
  80212b:	0f 83 37 ff ff ff    	jae    802068 <__udivdi3+0x48>
  802131:	b8 01 00 00 00       	mov    $0x1,%eax
  802136:	e9 2d ff ff ff       	jmp    802068 <__udivdi3+0x48>
  80213b:	90                   	nop
  80213c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 f8                	mov    %edi,%eax
  802142:	31 f6                	xor    %esi,%esi
  802144:	e9 1f ff ff ff       	jmp    802068 <__udivdi3+0x48>
  802149:	66 90                	xchg   %ax,%ax
  80214b:	66 90                	xchg   %ax,%ax
  80214d:	66 90                	xchg   %ax,%ax
  80214f:	90                   	nop

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	57                   	push   %edi
  802152:	56                   	push   %esi
  802153:	83 ec 20             	sub    $0x20,%esp
  802156:	8b 44 24 34          	mov    0x34(%esp),%eax
  80215a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80215e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802162:	89 c6                	mov    %eax,%esi
  802164:	89 44 24 10          	mov    %eax,0x10(%esp)
  802168:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80216c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802170:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802174:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802178:	89 74 24 18          	mov    %esi,0x18(%esp)
  80217c:	85 c0                	test   %eax,%eax
  80217e:	89 c2                	mov    %eax,%edx
  802180:	75 1e                	jne    8021a0 <__umoddi3+0x50>
  802182:	39 f7                	cmp    %esi,%edi
  802184:	76 52                	jbe    8021d8 <__umoddi3+0x88>
  802186:	89 c8                	mov    %ecx,%eax
  802188:	89 f2                	mov    %esi,%edx
  80218a:	f7 f7                	div    %edi
  80218c:	89 d0                	mov    %edx,%eax
  80218e:	31 d2                	xor    %edx,%edx
  802190:	83 c4 20             	add    $0x20,%esp
  802193:	5e                   	pop    %esi
  802194:	5f                   	pop    %edi
  802195:	5d                   	pop    %ebp
  802196:	c3                   	ret    
  802197:	89 f6                	mov    %esi,%esi
  802199:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8021a0:	39 f0                	cmp    %esi,%eax
  8021a2:	77 5c                	ja     802200 <__umoddi3+0xb0>
  8021a4:	0f bd e8             	bsr    %eax,%ebp
  8021a7:	83 f5 1f             	xor    $0x1f,%ebp
  8021aa:	75 64                	jne    802210 <__umoddi3+0xc0>
  8021ac:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8021b0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8021b4:	0f 86 f6 00 00 00    	jbe    8022b0 <__umoddi3+0x160>
  8021ba:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8021be:	0f 82 ec 00 00 00    	jb     8022b0 <__umoddi3+0x160>
  8021c4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8021c8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8021cc:	83 c4 20             	add    $0x20,%esp
  8021cf:	5e                   	pop    %esi
  8021d0:	5f                   	pop    %edi
  8021d1:	5d                   	pop    %ebp
  8021d2:	c3                   	ret    
  8021d3:	90                   	nop
  8021d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	85 ff                	test   %edi,%edi
  8021da:	89 fd                	mov    %edi,%ebp
  8021dc:	75 0b                	jne    8021e9 <__umoddi3+0x99>
  8021de:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e3:	31 d2                	xor    %edx,%edx
  8021e5:	f7 f7                	div    %edi
  8021e7:	89 c5                	mov    %eax,%ebp
  8021e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8021ed:	31 d2                	xor    %edx,%edx
  8021ef:	f7 f5                	div    %ebp
  8021f1:	89 c8                	mov    %ecx,%eax
  8021f3:	f7 f5                	div    %ebp
  8021f5:	eb 95                	jmp    80218c <__umoddi3+0x3c>
  8021f7:	89 f6                	mov    %esi,%esi
  8021f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 20             	add    $0x20,%esp
  802207:	5e                   	pop    %esi
  802208:	5f                   	pop    %edi
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    
  80220b:	90                   	nop
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	b8 20 00 00 00       	mov    $0x20,%eax
  802215:	89 e9                	mov    %ebp,%ecx
  802217:	29 e8                	sub    %ebp,%eax
  802219:	d3 e2                	shl    %cl,%edx
  80221b:	89 c7                	mov    %eax,%edi
  80221d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802221:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802225:	89 f9                	mov    %edi,%ecx
  802227:	d3 e8                	shr    %cl,%eax
  802229:	89 c1                	mov    %eax,%ecx
  80222b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80222f:	09 d1                	or     %edx,%ecx
  802231:	89 fa                	mov    %edi,%edx
  802233:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802237:	89 e9                	mov    %ebp,%ecx
  802239:	d3 e0                	shl    %cl,%eax
  80223b:	89 f9                	mov    %edi,%ecx
  80223d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802241:	89 f0                	mov    %esi,%eax
  802243:	d3 e8                	shr    %cl,%eax
  802245:	89 e9                	mov    %ebp,%ecx
  802247:	89 c7                	mov    %eax,%edi
  802249:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80224d:	d3 e6                	shl    %cl,%esi
  80224f:	89 d1                	mov    %edx,%ecx
  802251:	89 fa                	mov    %edi,%edx
  802253:	d3 e8                	shr    %cl,%eax
  802255:	89 e9                	mov    %ebp,%ecx
  802257:	09 f0                	or     %esi,%eax
  802259:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80225d:	f7 74 24 10          	divl   0x10(%esp)
  802261:	d3 e6                	shl    %cl,%esi
  802263:	89 d1                	mov    %edx,%ecx
  802265:	f7 64 24 0c          	mull   0xc(%esp)
  802269:	39 d1                	cmp    %edx,%ecx
  80226b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80226f:	89 d7                	mov    %edx,%edi
  802271:	89 c6                	mov    %eax,%esi
  802273:	72 0a                	jb     80227f <__umoddi3+0x12f>
  802275:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802279:	73 10                	jae    80228b <__umoddi3+0x13b>
  80227b:	39 d1                	cmp    %edx,%ecx
  80227d:	75 0c                	jne    80228b <__umoddi3+0x13b>
  80227f:	89 d7                	mov    %edx,%edi
  802281:	89 c6                	mov    %eax,%esi
  802283:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802287:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80228b:	89 ca                	mov    %ecx,%edx
  80228d:	89 e9                	mov    %ebp,%ecx
  80228f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802293:	29 f0                	sub    %esi,%eax
  802295:	19 fa                	sbb    %edi,%edx
  802297:	d3 e8                	shr    %cl,%eax
  802299:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80229e:	89 d7                	mov    %edx,%edi
  8022a0:	d3 e7                	shl    %cl,%edi
  8022a2:	89 e9                	mov    %ebp,%ecx
  8022a4:	09 f8                	or     %edi,%eax
  8022a6:	d3 ea                	shr    %cl,%edx
  8022a8:	83 c4 20             	add    $0x20,%esp
  8022ab:	5e                   	pop    %esi
  8022ac:	5f                   	pop    %edi
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    
  8022af:	90                   	nop
  8022b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8022b4:	29 f9                	sub    %edi,%ecx
  8022b6:	19 c6                	sbb    %eax,%esi
  8022b8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8022bc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8022c0:	e9 ff fe ff ff       	jmp    8021c4 <__umoddi3+0x74>
