
obj/user/echo:     file format elf32-i386


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
  80002c:	e8 ad 00 00 00       	call   8000de <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80003f:	8b 75 0c             	mov    0xc(%ebp),%esi
	int i, nflag;

	nflag = 0;
  800042:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800049:	83 ff 01             	cmp    $0x1,%edi
  80004c:	7e 2b                	jle    800079 <umain+0x46>
  80004e:	83 ec 08             	sub    $0x8,%esp
  800051:	68 80 1e 80 00       	push   $0x801e80
  800056:	ff 76 04             	pushl  0x4(%esi)
  800059:	e8 c3 01 00 00       	call   800221 <strcmp>
  80005e:	83 c4 10             	add    $0x10,%esp
void
umain(int argc, char **argv)
{
	int i, nflag;

	nflag = 0;
  800061:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
  800068:	85 c0                	test   %eax,%eax
  80006a:	75 0d                	jne    800079 <umain+0x46>
		nflag = 1;
		argc--;
  80006c:	83 ef 01             	sub    $0x1,%edi
		argv++;
  80006f:	83 c6 04             	add    $0x4,%esi
{
	int i, nflag;

	nflag = 0;
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
  800072:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  800079:	bb 01 00 00 00       	mov    $0x1,%ebx
  80007e:	eb 38                	jmp    8000b8 <umain+0x85>
		if (i > 1)
  800080:	83 fb 01             	cmp    $0x1,%ebx
  800083:	7e 14                	jle    800099 <umain+0x66>
			write(1, " ", 1);
  800085:	83 ec 04             	sub    $0x4,%esp
  800088:	6a 01                	push   $0x1
  80008a:	68 83 1e 80 00       	push   $0x801e83
  80008f:	6a 01                	push   $0x1
  800091:	e8 b0 0a 00 00       	call   800b46 <write>
  800096:	83 c4 10             	add    $0x10,%esp
		write(1, argv[i], strlen(argv[i]));
  800099:	83 ec 0c             	sub    $0xc,%esp
  80009c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  80009f:	e8 9a 00 00 00       	call   80013e <strlen>
  8000a4:	83 c4 0c             	add    $0xc,%esp
  8000a7:	50                   	push   %eax
  8000a8:	ff 34 9e             	pushl  (%esi,%ebx,4)
  8000ab:	6a 01                	push   $0x1
  8000ad:	e8 94 0a 00 00       	call   800b46 <write>
	if (argc > 1 && strcmp(argv[1], "-n") == 0) {
		nflag = 1;
		argc--;
		argv++;
	}
	for (i = 1; i < argc; i++) {
  8000b2:	83 c3 01             	add    $0x1,%ebx
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	39 df                	cmp    %ebx,%edi
  8000ba:	7f c4                	jg     800080 <umain+0x4d>
		if (i > 1)
			write(1, " ", 1);
		write(1, argv[i], strlen(argv[i]));
	}
	if (!nflag)
  8000bc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c0:	75 14                	jne    8000d6 <umain+0xa3>
		write(1, "\n", 1);
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	6a 01                	push   $0x1
  8000c7:	68 17 1f 80 00       	push   $0x801f17
  8000cc:	6a 01                	push   $0x1
  8000ce:	e8 73 0a 00 00       	call   800b46 <write>
  8000d3:	83 c4 10             	add    $0x10,%esp
}
  8000d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000e6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8000e9:	e8 55 04 00 00       	call   800543 <sys_getenvid>
  8000ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f3:	6b c0 78             	imul   $0x78,%eax,%eax
  8000f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fb:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800100:	85 db                	test   %ebx,%ebx
  800102:	7e 07                	jle    80010b <libmain+0x2d>
		binaryname = argv[0];
  800104:	8b 06                	mov    (%esi),%eax
  800106:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80010b:	83 ec 08             	sub    $0x8,%esp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	e8 1e ff ff ff       	call   800033 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800115:	e8 0a 00 00 00       	call   800124 <exit>
  80011a:	83 c4 10             	add    $0x10,%esp
#endif
}
  80011d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 2e 08 00 00       	call   80095d <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 c9 03 00 00       	call   800502 <sys_env_destroy>
  800139:	83 c4 10             	add    $0x10,%esp
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800144:	b8 00 00 00 00       	mov    $0x0,%eax
  800149:	eb 03                	jmp    80014e <strlen+0x10>
		n++;
  80014b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80014e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800152:	75 f7                	jne    80014b <strlen+0xd>
		n++;
	return n;
}
  800154:	5d                   	pop    %ebp
  800155:	c3                   	ret    

00800156 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	eb 03                	jmp    800169 <strnlen+0x13>
		n++;
  800166:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800169:	39 c2                	cmp    %eax,%edx
  80016b:	74 08                	je     800175 <strnlen+0x1f>
  80016d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800171:	75 f3                	jne    800166 <strnlen+0x10>
  800173:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800175:	5d                   	pop    %ebp
  800176:	c3                   	ret    

00800177 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	8b 45 08             	mov    0x8(%ebp),%eax
  80017e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800181:	89 c2                	mov    %eax,%edx
  800183:	83 c2 01             	add    $0x1,%edx
  800186:	83 c1 01             	add    $0x1,%ecx
  800189:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80018d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800190:	84 db                	test   %bl,%bl
  800192:	75 ef                	jne    800183 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800194:	5b                   	pop    %ebx
  800195:	5d                   	pop    %ebp
  800196:	c3                   	ret    

00800197 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	53                   	push   %ebx
  80019b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80019e:	53                   	push   %ebx
  80019f:	e8 9a ff ff ff       	call   80013e <strlen>
  8001a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8001a7:	ff 75 0c             	pushl  0xc(%ebp)
  8001aa:	01 d8                	add    %ebx,%eax
  8001ac:	50                   	push   %eax
  8001ad:	e8 c5 ff ff ff       	call   800177 <strcpy>
	return dst;
}
  8001b2:	89 d8                	mov    %ebx,%eax
  8001b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	8b 75 08             	mov    0x8(%ebp),%esi
  8001c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c4:	89 f3                	mov    %esi,%ebx
  8001c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001c9:	89 f2                	mov    %esi,%edx
  8001cb:	eb 0f                	jmp    8001dc <strncpy+0x23>
		*dst++ = *src;
  8001cd:	83 c2 01             	add    $0x1,%edx
  8001d0:	0f b6 01             	movzbl (%ecx),%eax
  8001d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8001d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8001d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8001dc:	39 da                	cmp    %ebx,%edx
  8001de:	75 ed                	jne    8001cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8001e0:	89 f0                	mov    %esi,%eax
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5d                   	pop    %ebp
  8001e5:	c3                   	ret    

008001e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8001ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8001f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8001f6:	85 d2                	test   %edx,%edx
  8001f8:	74 21                	je     80021b <strlcpy+0x35>
  8001fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	eb 09                	jmp    80020b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800202:	83 c2 01             	add    $0x1,%edx
  800205:	83 c1 01             	add    $0x1,%ecx
  800208:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80020b:	39 c2                	cmp    %eax,%edx
  80020d:	74 09                	je     800218 <strlcpy+0x32>
  80020f:	0f b6 19             	movzbl (%ecx),%ebx
  800212:	84 db                	test   %bl,%bl
  800214:	75 ec                	jne    800202 <strlcpy+0x1c>
  800216:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800218:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80021b:	29 f0                	sub    %esi,%eax
}
  80021d:	5b                   	pop    %ebx
  80021e:	5e                   	pop    %esi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800227:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80022a:	eb 06                	jmp    800232 <strcmp+0x11>
		p++, q++;
  80022c:	83 c1 01             	add    $0x1,%ecx
  80022f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800232:	0f b6 01             	movzbl (%ecx),%eax
  800235:	84 c0                	test   %al,%al
  800237:	74 04                	je     80023d <strcmp+0x1c>
  800239:	3a 02                	cmp    (%edx),%al
  80023b:	74 ef                	je     80022c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80023d:	0f b6 c0             	movzbl %al,%eax
  800240:	0f b6 12             	movzbl (%edx),%edx
  800243:	29 d0                	sub    %edx,%eax
}
  800245:	5d                   	pop    %ebp
  800246:	c3                   	ret    

00800247 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800247:	55                   	push   %ebp
  800248:	89 e5                	mov    %esp,%ebp
  80024a:	53                   	push   %ebx
  80024b:	8b 45 08             	mov    0x8(%ebp),%eax
  80024e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800251:	89 c3                	mov    %eax,%ebx
  800253:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800256:	eb 06                	jmp    80025e <strncmp+0x17>
		n--, p++, q++;
  800258:	83 c0 01             	add    $0x1,%eax
  80025b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80025e:	39 d8                	cmp    %ebx,%eax
  800260:	74 15                	je     800277 <strncmp+0x30>
  800262:	0f b6 08             	movzbl (%eax),%ecx
  800265:	84 c9                	test   %cl,%cl
  800267:	74 04                	je     80026d <strncmp+0x26>
  800269:	3a 0a                	cmp    (%edx),%cl
  80026b:	74 eb                	je     800258 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80026d:	0f b6 00             	movzbl (%eax),%eax
  800270:	0f b6 12             	movzbl (%edx),%edx
  800273:	29 d0                	sub    %edx,%eax
  800275:	eb 05                	jmp    80027c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800277:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80027c:	5b                   	pop    %ebx
  80027d:	5d                   	pop    %ebp
  80027e:	c3                   	ret    

0080027f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80027f:	55                   	push   %ebp
  800280:	89 e5                	mov    %esp,%ebp
  800282:	8b 45 08             	mov    0x8(%ebp),%eax
  800285:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800289:	eb 07                	jmp    800292 <strchr+0x13>
		if (*s == c)
  80028b:	38 ca                	cmp    %cl,%dl
  80028d:	74 0f                	je     80029e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80028f:	83 c0 01             	add    $0x1,%eax
  800292:	0f b6 10             	movzbl (%eax),%edx
  800295:	84 d2                	test   %dl,%dl
  800297:	75 f2                	jne    80028b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800299:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80029e:	5d                   	pop    %ebp
  80029f:	c3                   	ret    

008002a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8002aa:	eb 03                	jmp    8002af <strfind+0xf>
  8002ac:	83 c0 01             	add    $0x1,%eax
  8002af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8002b2:	84 d2                	test   %dl,%dl
  8002b4:	74 04                	je     8002ba <strfind+0x1a>
  8002b6:	38 ca                	cmp    %cl,%dl
  8002b8:	75 f2                	jne    8002ac <strfind+0xc>
			break;
	return (char *) s;
}
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8002c8:	85 c9                	test   %ecx,%ecx
  8002ca:	74 36                	je     800302 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8002cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8002d2:	75 28                	jne    8002fc <memset+0x40>
  8002d4:	f6 c1 03             	test   $0x3,%cl
  8002d7:	75 23                	jne    8002fc <memset+0x40>
		c &= 0xFF;
  8002d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8002dd:	89 d3                	mov    %edx,%ebx
  8002df:	c1 e3 08             	shl    $0x8,%ebx
  8002e2:	89 d6                	mov    %edx,%esi
  8002e4:	c1 e6 18             	shl    $0x18,%esi
  8002e7:	89 d0                	mov    %edx,%eax
  8002e9:	c1 e0 10             	shl    $0x10,%eax
  8002ec:	09 f0                	or     %esi,%eax
  8002ee:	09 c2                	or     %eax,%edx
  8002f0:	89 d0                	mov    %edx,%eax
  8002f2:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8002f4:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8002f7:	fc                   	cld    
  8002f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8002fa:	eb 06                	jmp    800302 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8002fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8002ff:	fc                   	cld    
  800300:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800302:	89 f8                	mov    %edi,%eax
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	8b 45 08             	mov    0x8(%ebp),%eax
  800311:	8b 75 0c             	mov    0xc(%ebp),%esi
  800314:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800317:	39 c6                	cmp    %eax,%esi
  800319:	73 35                	jae    800350 <memmove+0x47>
  80031b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80031e:	39 d0                	cmp    %edx,%eax
  800320:	73 2e                	jae    800350 <memmove+0x47>
		s += n;
		d += n;
  800322:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800325:	89 d6                	mov    %edx,%esi
  800327:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800329:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80032f:	75 13                	jne    800344 <memmove+0x3b>
  800331:	f6 c1 03             	test   $0x3,%cl
  800334:	75 0e                	jne    800344 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800336:	83 ef 04             	sub    $0x4,%edi
  800339:	8d 72 fc             	lea    -0x4(%edx),%esi
  80033c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80033f:	fd                   	std    
  800340:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800342:	eb 09                	jmp    80034d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800344:	83 ef 01             	sub    $0x1,%edi
  800347:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  80034a:	fd                   	std    
  80034b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80034d:	fc                   	cld    
  80034e:	eb 1d                	jmp    80036d <memmove+0x64>
  800350:	89 f2                	mov    %esi,%edx
  800352:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800354:	f6 c2 03             	test   $0x3,%dl
  800357:	75 0f                	jne    800368 <memmove+0x5f>
  800359:	f6 c1 03             	test   $0x3,%cl
  80035c:	75 0a                	jne    800368 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80035e:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800361:	89 c7                	mov    %eax,%edi
  800363:	fc                   	cld    
  800364:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800366:	eb 05                	jmp    80036d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800368:	89 c7                	mov    %eax,%edi
  80036a:	fc                   	cld    
  80036b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80036d:	5e                   	pop    %esi
  80036e:	5f                   	pop    %edi
  80036f:	5d                   	pop    %ebp
  800370:	c3                   	ret    

00800371 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800374:	ff 75 10             	pushl  0x10(%ebp)
  800377:	ff 75 0c             	pushl  0xc(%ebp)
  80037a:	ff 75 08             	pushl  0x8(%ebp)
  80037d:	e8 87 ff ff ff       	call   800309 <memmove>
}
  800382:	c9                   	leave  
  800383:	c3                   	ret    

00800384 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	8b 45 08             	mov    0x8(%ebp),%eax
  80038c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80038f:	89 c6                	mov    %eax,%esi
  800391:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800394:	eb 1a                	jmp    8003b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800396:	0f b6 08             	movzbl (%eax),%ecx
  800399:	0f b6 1a             	movzbl (%edx),%ebx
  80039c:	38 d9                	cmp    %bl,%cl
  80039e:	74 0a                	je     8003aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8003a0:	0f b6 c1             	movzbl %cl,%eax
  8003a3:	0f b6 db             	movzbl %bl,%ebx
  8003a6:	29 d8                	sub    %ebx,%eax
  8003a8:	eb 0f                	jmp    8003b9 <memcmp+0x35>
		s1++, s2++;
  8003aa:	83 c0 01             	add    $0x1,%eax
  8003ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8003b0:	39 f0                	cmp    %esi,%eax
  8003b2:	75 e2                	jne    800396 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003b9:	5b                   	pop    %ebx
  8003ba:	5e                   	pop    %esi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    

008003bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8003bd:	55                   	push   %ebp
  8003be:	89 e5                	mov    %esp,%ebp
  8003c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8003c6:	89 c2                	mov    %eax,%edx
  8003c8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8003cb:	eb 07                	jmp    8003d4 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8003cd:	38 08                	cmp    %cl,(%eax)
  8003cf:	74 07                	je     8003d8 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8003d1:	83 c0 01             	add    $0x1,%eax
  8003d4:	39 d0                	cmp    %edx,%eax
  8003d6:	72 f5                	jb     8003cd <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8003d8:	5d                   	pop    %ebp
  8003d9:	c3                   	ret    

008003da <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	57                   	push   %edi
  8003de:	56                   	push   %esi
  8003df:	53                   	push   %ebx
  8003e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003e6:	eb 03                	jmp    8003eb <strtol+0x11>
		s++;
  8003e8:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8003eb:	0f b6 01             	movzbl (%ecx),%eax
  8003ee:	3c 09                	cmp    $0x9,%al
  8003f0:	74 f6                	je     8003e8 <strtol+0xe>
  8003f2:	3c 20                	cmp    $0x20,%al
  8003f4:	74 f2                	je     8003e8 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8003f6:	3c 2b                	cmp    $0x2b,%al
  8003f8:	75 0a                	jne    800404 <strtol+0x2a>
		s++;
  8003fa:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8003fd:	bf 00 00 00 00       	mov    $0x0,%edi
  800402:	eb 10                	jmp    800414 <strtol+0x3a>
  800404:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800409:	3c 2d                	cmp    $0x2d,%al
  80040b:	75 07                	jne    800414 <strtol+0x3a>
		s++, neg = 1;
  80040d:	8d 49 01             	lea    0x1(%ecx),%ecx
  800410:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800414:	85 db                	test   %ebx,%ebx
  800416:	0f 94 c0             	sete   %al
  800419:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80041f:	75 19                	jne    80043a <strtol+0x60>
  800421:	80 39 30             	cmpb   $0x30,(%ecx)
  800424:	75 14                	jne    80043a <strtol+0x60>
  800426:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80042a:	0f 85 8a 00 00 00    	jne    8004ba <strtol+0xe0>
		s += 2, base = 16;
  800430:	83 c1 02             	add    $0x2,%ecx
  800433:	bb 10 00 00 00       	mov    $0x10,%ebx
  800438:	eb 16                	jmp    800450 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80043a:	84 c0                	test   %al,%al
  80043c:	74 12                	je     800450 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80043e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800443:	80 39 30             	cmpb   $0x30,(%ecx)
  800446:	75 08                	jne    800450 <strtol+0x76>
		s++, base = 8;
  800448:	83 c1 01             	add    $0x1,%ecx
  80044b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800450:	b8 00 00 00 00       	mov    $0x0,%eax
  800455:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800458:	0f b6 11             	movzbl (%ecx),%edx
  80045b:	8d 72 d0             	lea    -0x30(%edx),%esi
  80045e:	89 f3                	mov    %esi,%ebx
  800460:	80 fb 09             	cmp    $0x9,%bl
  800463:	77 08                	ja     80046d <strtol+0x93>
			dig = *s - '0';
  800465:	0f be d2             	movsbl %dl,%edx
  800468:	83 ea 30             	sub    $0x30,%edx
  80046b:	eb 22                	jmp    80048f <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  80046d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800470:	89 f3                	mov    %esi,%ebx
  800472:	80 fb 19             	cmp    $0x19,%bl
  800475:	77 08                	ja     80047f <strtol+0xa5>
			dig = *s - 'a' + 10;
  800477:	0f be d2             	movsbl %dl,%edx
  80047a:	83 ea 57             	sub    $0x57,%edx
  80047d:	eb 10                	jmp    80048f <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  80047f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800482:	89 f3                	mov    %esi,%ebx
  800484:	80 fb 19             	cmp    $0x19,%bl
  800487:	77 16                	ja     80049f <strtol+0xc5>
			dig = *s - 'A' + 10;
  800489:	0f be d2             	movsbl %dl,%edx
  80048c:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80048f:	3b 55 10             	cmp    0x10(%ebp),%edx
  800492:	7d 0f                	jge    8004a3 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800494:	83 c1 01             	add    $0x1,%ecx
  800497:	0f af 45 10          	imul   0x10(%ebp),%eax
  80049b:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80049d:	eb b9                	jmp    800458 <strtol+0x7e>
  80049f:	89 c2                	mov    %eax,%edx
  8004a1:	eb 02                	jmp    8004a5 <strtol+0xcb>
  8004a3:	89 c2                	mov    %eax,%edx

	if (endptr)
  8004a5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8004a9:	74 05                	je     8004b0 <strtol+0xd6>
		*endptr = (char *) s;
  8004ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8004ae:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8004b0:	85 ff                	test   %edi,%edi
  8004b2:	74 0c                	je     8004c0 <strtol+0xe6>
  8004b4:	89 d0                	mov    %edx,%eax
  8004b6:	f7 d8                	neg    %eax
  8004b8:	eb 06                	jmp    8004c0 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8004ba:	84 c0                	test   %al,%al
  8004bc:	75 8a                	jne    800448 <strtol+0x6e>
  8004be:	eb 90                	jmp    800450 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8004c0:	5b                   	pop    %ebx
  8004c1:	5e                   	pop    %esi
  8004c2:	5f                   	pop    %edi
  8004c3:	5d                   	pop    %ebp
  8004c4:	c3                   	ret    

008004c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	57                   	push   %edi
  8004c9:	56                   	push   %esi
  8004ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8004d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d6:	89 c3                	mov    %eax,%ebx
  8004d8:	89 c7                	mov    %eax,%edi
  8004da:	89 c6                	mov    %eax,%esi
  8004dc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8004de:	5b                   	pop    %ebx
  8004df:	5e                   	pop    %esi
  8004e0:	5f                   	pop    %edi
  8004e1:	5d                   	pop    %ebp
  8004e2:	c3                   	ret    

008004e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8004e3:	55                   	push   %ebp
  8004e4:	89 e5                	mov    %esp,%ebp
  8004e6:	57                   	push   %edi
  8004e7:	56                   	push   %esi
  8004e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8004e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8004f3:	89 d1                	mov    %edx,%ecx
  8004f5:	89 d3                	mov    %edx,%ebx
  8004f7:	89 d7                	mov    %edx,%edi
  8004f9:	89 d6                	mov    %edx,%esi
  8004fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8004fd:	5b                   	pop    %ebx
  8004fe:	5e                   	pop    %esi
  8004ff:	5f                   	pop    %edi
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800502:	55                   	push   %ebp
  800503:	89 e5                	mov    %esp,%ebp
  800505:	57                   	push   %edi
  800506:	56                   	push   %esi
  800507:	53                   	push   %ebx
  800508:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80050b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800510:	b8 03 00 00 00       	mov    $0x3,%eax
  800515:	8b 55 08             	mov    0x8(%ebp),%edx
  800518:	89 cb                	mov    %ecx,%ebx
  80051a:	89 cf                	mov    %ecx,%edi
  80051c:	89 ce                	mov    %ecx,%esi
  80051e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800520:	85 c0                	test   %eax,%eax
  800522:	7e 17                	jle    80053b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800524:	83 ec 0c             	sub    $0xc,%esp
  800527:	50                   	push   %eax
  800528:	6a 03                	push   $0x3
  80052a:	68 8f 1e 80 00       	push   $0x801e8f
  80052f:	6a 23                	push   $0x23
  800531:	68 ac 1e 80 00       	push   $0x801eac
  800536:	e8 3b 0f 00 00       	call   801476 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80053b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80053e:	5b                   	pop    %ebx
  80053f:	5e                   	pop    %esi
  800540:	5f                   	pop    %edi
  800541:	5d                   	pop    %ebp
  800542:	c3                   	ret    

00800543 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800543:	55                   	push   %ebp
  800544:	89 e5                	mov    %esp,%ebp
  800546:	57                   	push   %edi
  800547:	56                   	push   %esi
  800548:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800549:	ba 00 00 00 00       	mov    $0x0,%edx
  80054e:	b8 02 00 00 00       	mov    $0x2,%eax
  800553:	89 d1                	mov    %edx,%ecx
  800555:	89 d3                	mov    %edx,%ebx
  800557:	89 d7                	mov    %edx,%edi
  800559:	89 d6                	mov    %edx,%esi
  80055b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80055d:	5b                   	pop    %ebx
  80055e:	5e                   	pop    %esi
  80055f:	5f                   	pop    %edi
  800560:	5d                   	pop    %ebp
  800561:	c3                   	ret    

00800562 <sys_yield>:

void
sys_yield(void)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800568:	ba 00 00 00 00       	mov    $0x0,%edx
  80056d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800572:	89 d1                	mov    %edx,%ecx
  800574:	89 d3                	mov    %edx,%ebx
  800576:	89 d7                	mov    %edx,%edi
  800578:	89 d6                	mov    %edx,%esi
  80057a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80057c:	5b                   	pop    %ebx
  80057d:	5e                   	pop    %esi
  80057e:	5f                   	pop    %edi
  80057f:	5d                   	pop    %ebp
  800580:	c3                   	ret    

00800581 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800581:	55                   	push   %ebp
  800582:	89 e5                	mov    %esp,%ebp
  800584:	57                   	push   %edi
  800585:	56                   	push   %esi
  800586:	53                   	push   %ebx
  800587:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80058a:	be 00 00 00 00       	mov    $0x0,%esi
  80058f:	b8 04 00 00 00       	mov    $0x4,%eax
  800594:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800597:	8b 55 08             	mov    0x8(%ebp),%edx
  80059a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80059d:	89 f7                	mov    %esi,%edi
  80059f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	7e 17                	jle    8005bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005a5:	83 ec 0c             	sub    $0xc,%esp
  8005a8:	50                   	push   %eax
  8005a9:	6a 04                	push   $0x4
  8005ab:	68 8f 1e 80 00       	push   $0x801e8f
  8005b0:	6a 23                	push   $0x23
  8005b2:	68 ac 1e 80 00       	push   $0x801eac
  8005b7:	e8 ba 0e 00 00       	call   801476 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8005bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005bf:	5b                   	pop    %ebx
  8005c0:	5e                   	pop    %esi
  8005c1:	5f                   	pop    %edi
  8005c2:	5d                   	pop    %ebp
  8005c3:	c3                   	ret    

008005c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8005c4:	55                   	push   %ebp
  8005c5:	89 e5                	mov    %esp,%ebp
  8005c7:	57                   	push   %edi
  8005c8:	56                   	push   %esi
  8005c9:	53                   	push   %ebx
  8005ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8005cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8005d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8005d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8005d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8005db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8005de:	8b 75 18             	mov    0x18(%ebp),%esi
  8005e1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	7e 17                	jle    8005fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	50                   	push   %eax
  8005eb:	6a 05                	push   $0x5
  8005ed:	68 8f 1e 80 00       	push   $0x801e8f
  8005f2:	6a 23                	push   $0x23
  8005f4:	68 ac 1e 80 00       	push   $0x801eac
  8005f9:	e8 78 0e 00 00       	call   801476 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8005fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800601:	5b                   	pop    %ebx
  800602:	5e                   	pop    %esi
  800603:	5f                   	pop    %edi
  800604:	5d                   	pop    %ebp
  800605:	c3                   	ret    

00800606 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800606:	55                   	push   %ebp
  800607:	89 e5                	mov    %esp,%ebp
  800609:	57                   	push   %edi
  80060a:	56                   	push   %esi
  80060b:	53                   	push   %ebx
  80060c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80060f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800614:	b8 06 00 00 00       	mov    $0x6,%eax
  800619:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80061c:	8b 55 08             	mov    0x8(%ebp),%edx
  80061f:	89 df                	mov    %ebx,%edi
  800621:	89 de                	mov    %ebx,%esi
  800623:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800625:	85 c0                	test   %eax,%eax
  800627:	7e 17                	jle    800640 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800629:	83 ec 0c             	sub    $0xc,%esp
  80062c:	50                   	push   %eax
  80062d:	6a 06                	push   $0x6
  80062f:	68 8f 1e 80 00       	push   $0x801e8f
  800634:	6a 23                	push   $0x23
  800636:	68 ac 1e 80 00       	push   $0x801eac
  80063b:	e8 36 0e 00 00       	call   801476 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800643:	5b                   	pop    %ebx
  800644:	5e                   	pop    %esi
  800645:	5f                   	pop    %edi
  800646:	5d                   	pop    %ebp
  800647:	c3                   	ret    

00800648 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800648:	55                   	push   %ebp
  800649:	89 e5                	mov    %esp,%ebp
  80064b:	57                   	push   %edi
  80064c:	56                   	push   %esi
  80064d:	53                   	push   %ebx
  80064e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800651:	bb 00 00 00 00       	mov    $0x0,%ebx
  800656:	b8 08 00 00 00       	mov    $0x8,%eax
  80065b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80065e:	8b 55 08             	mov    0x8(%ebp),%edx
  800661:	89 df                	mov    %ebx,%edi
  800663:	89 de                	mov    %ebx,%esi
  800665:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800667:	85 c0                	test   %eax,%eax
  800669:	7e 17                	jle    800682 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80066b:	83 ec 0c             	sub    $0xc,%esp
  80066e:	50                   	push   %eax
  80066f:	6a 08                	push   $0x8
  800671:	68 8f 1e 80 00       	push   $0x801e8f
  800676:	6a 23                	push   $0x23
  800678:	68 ac 1e 80 00       	push   $0x801eac
  80067d:	e8 f4 0d 00 00       	call   801476 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800682:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800685:	5b                   	pop    %ebx
  800686:	5e                   	pop    %esi
  800687:	5f                   	pop    %edi
  800688:	5d                   	pop    %ebp
  800689:	c3                   	ret    

0080068a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80068a:	55                   	push   %ebp
  80068b:	89 e5                	mov    %esp,%ebp
  80068d:	57                   	push   %edi
  80068e:	56                   	push   %esi
  80068f:	53                   	push   %ebx
  800690:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800693:	bb 00 00 00 00       	mov    $0x0,%ebx
  800698:	b8 09 00 00 00       	mov    $0x9,%eax
  80069d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a3:	89 df                	mov    %ebx,%edi
  8006a5:	89 de                	mov    %ebx,%esi
  8006a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006a9:	85 c0                	test   %eax,%eax
  8006ab:	7e 17                	jle    8006c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ad:	83 ec 0c             	sub    $0xc,%esp
  8006b0:	50                   	push   %eax
  8006b1:	6a 09                	push   $0x9
  8006b3:	68 8f 1e 80 00       	push   $0x801e8f
  8006b8:	6a 23                	push   $0x23
  8006ba:	68 ac 1e 80 00       	push   $0x801eac
  8006bf:	e8 b2 0d 00 00       	call   801476 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8006c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c7:	5b                   	pop    %ebx
  8006c8:	5e                   	pop    %esi
  8006c9:	5f                   	pop    %edi
  8006ca:	5d                   	pop    %ebp
  8006cb:	c3                   	ret    

008006cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8006cc:	55                   	push   %ebp
  8006cd:	89 e5                	mov    %esp,%ebp
  8006cf:	57                   	push   %edi
  8006d0:	56                   	push   %esi
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8006d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8006e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e5:	89 df                	mov    %ebx,%edi
  8006e7:	89 de                	mov    %ebx,%esi
  8006e9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8006eb:	85 c0                	test   %eax,%eax
  8006ed:	7e 17                	jle    800706 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8006ef:	83 ec 0c             	sub    $0xc,%esp
  8006f2:	50                   	push   %eax
  8006f3:	6a 0a                	push   $0xa
  8006f5:	68 8f 1e 80 00       	push   $0x801e8f
  8006fa:	6a 23                	push   $0x23
  8006fc:	68 ac 1e 80 00       	push   $0x801eac
  800701:	e8 70 0d 00 00       	call   801476 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800706:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800709:	5b                   	pop    %ebx
  80070a:	5e                   	pop    %esi
  80070b:	5f                   	pop    %edi
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	57                   	push   %edi
  800712:	56                   	push   %esi
  800713:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800714:	be 00 00 00 00       	mov    $0x0,%esi
  800719:	b8 0c 00 00 00       	mov    $0xc,%eax
  80071e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800721:	8b 55 08             	mov    0x8(%ebp),%edx
  800724:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800727:	8b 7d 14             	mov    0x14(%ebp),%edi
  80072a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80072c:	5b                   	pop    %ebx
  80072d:	5e                   	pop    %esi
  80072e:	5f                   	pop    %edi
  80072f:	5d                   	pop    %ebp
  800730:	c3                   	ret    

00800731 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800731:	55                   	push   %ebp
  800732:	89 e5                	mov    %esp,%ebp
  800734:	57                   	push   %edi
  800735:	56                   	push   %esi
  800736:	53                   	push   %ebx
  800737:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80073a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800744:	8b 55 08             	mov    0x8(%ebp),%edx
  800747:	89 cb                	mov    %ecx,%ebx
  800749:	89 cf                	mov    %ecx,%edi
  80074b:	89 ce                	mov    %ecx,%esi
  80074d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80074f:	85 c0                	test   %eax,%eax
  800751:	7e 17                	jle    80076a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800753:	83 ec 0c             	sub    $0xc,%esp
  800756:	50                   	push   %eax
  800757:	6a 0d                	push   $0xd
  800759:	68 8f 1e 80 00       	push   $0x801e8f
  80075e:	6a 23                	push   $0x23
  800760:	68 ac 1e 80 00       	push   $0x801eac
  800765:	e8 0c 0d 00 00       	call   801476 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80076a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076d:	5b                   	pop    %ebx
  80076e:	5e                   	pop    %esi
  80076f:	5f                   	pop    %edi
  800770:	5d                   	pop    %ebp
  800771:	c3                   	ret    

00800772 <sys_gettime>:

int sys_gettime(void)
{
  800772:	55                   	push   %ebp
  800773:	89 e5                	mov    %esp,%ebp
  800775:	57                   	push   %edi
  800776:	56                   	push   %esi
  800777:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800778:	ba 00 00 00 00       	mov    $0x0,%edx
  80077d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800782:	89 d1                	mov    %edx,%ecx
  800784:	89 d3                	mov    %edx,%ebx
  800786:	89 d7                	mov    %edx,%edi
  800788:	89 d6                	mov    %edx,%esi
  80078a:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  80078c:	5b                   	pop    %ebx
  80078d:	5e                   	pop    %esi
  80078e:	5f                   	pop    %edi
  80078f:	5d                   	pop    %ebp
  800790:	c3                   	ret    

00800791 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800794:	8b 45 08             	mov    0x8(%ebp),%eax
  800797:	05 00 00 00 30       	add    $0x30000000,%eax
  80079c:	c1 e8 0c             	shr    $0xc,%eax
}
  80079f:	5d                   	pop    %ebp
  8007a0:	c3                   	ret    

008007a1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8007a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a7:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8007ac:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8007b1:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007be:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8007c3:	89 c2                	mov    %eax,%edx
  8007c5:	c1 ea 16             	shr    $0x16,%edx
  8007c8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8007cf:	f6 c2 01             	test   $0x1,%dl
  8007d2:	74 11                	je     8007e5 <fd_alloc+0x2d>
  8007d4:	89 c2                	mov    %eax,%edx
  8007d6:	c1 ea 0c             	shr    $0xc,%edx
  8007d9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8007e0:	f6 c2 01             	test   $0x1,%dl
  8007e3:	75 09                	jne    8007ee <fd_alloc+0x36>
			*fd_store = fd;
  8007e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8007e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ec:	eb 17                	jmp    800805 <fd_alloc+0x4d>
  8007ee:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8007f3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8007f8:	75 c9                	jne    8007c3 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8007fa:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800800:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800805:	5d                   	pop    %ebp
  800806:	c3                   	ret    

00800807 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80080d:	83 f8 1f             	cmp    $0x1f,%eax
  800810:	77 36                	ja     800848 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800812:	c1 e0 0c             	shl    $0xc,%eax
  800815:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80081a:	89 c2                	mov    %eax,%edx
  80081c:	c1 ea 16             	shr    $0x16,%edx
  80081f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800826:	f6 c2 01             	test   $0x1,%dl
  800829:	74 24                	je     80084f <fd_lookup+0x48>
  80082b:	89 c2                	mov    %eax,%edx
  80082d:	c1 ea 0c             	shr    $0xc,%edx
  800830:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800837:	f6 c2 01             	test   $0x1,%dl
  80083a:	74 1a                	je     800856 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083f:	89 02                	mov    %eax,(%edx)
	return 0;
  800841:	b8 00 00 00 00       	mov    $0x0,%eax
  800846:	eb 13                	jmp    80085b <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800848:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80084d:	eb 0c                	jmp    80085b <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80084f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800854:	eb 05                	jmp    80085b <fd_lookup+0x54>
  800856:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800866:	ba 38 1f 80 00       	mov    $0x801f38,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80086b:	eb 13                	jmp    800880 <dev_lookup+0x23>
  80086d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800870:	39 08                	cmp    %ecx,(%eax)
  800872:	75 0c                	jne    800880 <dev_lookup+0x23>
			*dev = devtab[i];
  800874:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800877:	89 01                	mov    %eax,(%ecx)
			return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
  80087e:	eb 2e                	jmp    8008ae <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800880:	8b 02                	mov    (%edx),%eax
  800882:	85 c0                	test   %eax,%eax
  800884:	75 e7                	jne    80086d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800886:	a1 04 40 80 00       	mov    0x804004,%eax
  80088b:	8b 40 48             	mov    0x48(%eax),%eax
  80088e:	83 ec 04             	sub    $0x4,%esp
  800891:	51                   	push   %ecx
  800892:	50                   	push   %eax
  800893:	68 bc 1e 80 00       	push   $0x801ebc
  800898:	e8 b2 0c 00 00       	call   80154f <cprintf>
	*dev = 0;
  80089d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8008a6:	83 c4 10             	add    $0x10,%esp
  8008a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    

008008b0 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8008b0:	55                   	push   %ebp
  8008b1:	89 e5                	mov    %esp,%ebp
  8008b3:	56                   	push   %esi
  8008b4:	53                   	push   %ebx
  8008b5:	83 ec 10             	sub    $0x10,%esp
  8008b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8008bb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008c1:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8008c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8008c8:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8008cb:	50                   	push   %eax
  8008cc:	e8 36 ff ff ff       	call   800807 <fd_lookup>
  8008d1:	83 c4 08             	add    $0x8,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 05                	js     8008dd <fd_close+0x2d>
	    || fd != fd2)
  8008d8:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8008db:	74 0b                	je     8008e8 <fd_close+0x38>
		return (must_exist ? r : 0);
  8008dd:	80 fb 01             	cmp    $0x1,%bl
  8008e0:	19 d2                	sbb    %edx,%edx
  8008e2:	f7 d2                	not    %edx
  8008e4:	21 d0                	and    %edx,%eax
  8008e6:	eb 41                	jmp    800929 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ee:	50                   	push   %eax
  8008ef:	ff 36                	pushl  (%esi)
  8008f1:	e8 67 ff ff ff       	call   80085d <dev_lookup>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1a                	js     800919 <fd_close+0x69>
		if (dev->dev_close)
  8008ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800902:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800905:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80090a:	85 c0                	test   %eax,%eax
  80090c:	74 0b                	je     800919 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80090e:	83 ec 0c             	sub    $0xc,%esp
  800911:	56                   	push   %esi
  800912:	ff d0                	call   *%eax
  800914:	89 c3                	mov    %eax,%ebx
  800916:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	56                   	push   %esi
  80091d:	6a 00                	push   $0x0
  80091f:	e8 e2 fc ff ff       	call   800606 <sys_page_unmap>
	return r;
  800924:	83 c4 10             	add    $0x10,%esp
  800927:	89 d8                	mov    %ebx,%eax
}
  800929:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800936:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800939:	50                   	push   %eax
  80093a:	ff 75 08             	pushl  0x8(%ebp)
  80093d:	e8 c5 fe ff ff       	call   800807 <fd_lookup>
  800942:	89 c2                	mov    %eax,%edx
  800944:	83 c4 08             	add    $0x8,%esp
  800947:	85 d2                	test   %edx,%edx
  800949:	78 10                	js     80095b <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80094b:	83 ec 08             	sub    $0x8,%esp
  80094e:	6a 01                	push   $0x1
  800950:	ff 75 f4             	pushl  -0xc(%ebp)
  800953:	e8 58 ff ff ff       	call   8008b0 <fd_close>
  800958:	83 c4 10             	add    $0x10,%esp
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <close_all>:

void
close_all(void)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	53                   	push   %ebx
  800961:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800964:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800969:	83 ec 0c             	sub    $0xc,%esp
  80096c:	53                   	push   %ebx
  80096d:	e8 be ff ff ff       	call   800930 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800972:	83 c3 01             	add    $0x1,%ebx
  800975:	83 c4 10             	add    $0x10,%esp
  800978:	83 fb 20             	cmp    $0x20,%ebx
  80097b:	75 ec                	jne    800969 <close_all+0xc>
		close(i);
}
  80097d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800980:	c9                   	leave  
  800981:	c3                   	ret    

00800982 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	57                   	push   %edi
  800986:	56                   	push   %esi
  800987:	53                   	push   %ebx
  800988:	83 ec 2c             	sub    $0x2c,%esp
  80098b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80098e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800991:	50                   	push   %eax
  800992:	ff 75 08             	pushl  0x8(%ebp)
  800995:	e8 6d fe ff ff       	call   800807 <fd_lookup>
  80099a:	89 c2                	mov    %eax,%edx
  80099c:	83 c4 08             	add    $0x8,%esp
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	0f 88 c1 00 00 00    	js     800a68 <dup+0xe6>
		return r;
	close(newfdnum);
  8009a7:	83 ec 0c             	sub    $0xc,%esp
  8009aa:	56                   	push   %esi
  8009ab:	e8 80 ff ff ff       	call   800930 <close>

	newfd = INDEX2FD(newfdnum);
  8009b0:	89 f3                	mov    %esi,%ebx
  8009b2:	c1 e3 0c             	shl    $0xc,%ebx
  8009b5:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8009bb:	83 c4 04             	add    $0x4,%esp
  8009be:	ff 75 e4             	pushl  -0x1c(%ebp)
  8009c1:	e8 db fd ff ff       	call   8007a1 <fd2data>
  8009c6:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8009c8:	89 1c 24             	mov    %ebx,(%esp)
  8009cb:	e8 d1 fd ff ff       	call   8007a1 <fd2data>
  8009d0:	83 c4 10             	add    $0x10,%esp
  8009d3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8009d6:	89 f8                	mov    %edi,%eax
  8009d8:	c1 e8 16             	shr    $0x16,%eax
  8009db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8009e2:	a8 01                	test   $0x1,%al
  8009e4:	74 37                	je     800a1d <dup+0x9b>
  8009e6:	89 f8                	mov    %edi,%eax
  8009e8:	c1 e8 0c             	shr    $0xc,%eax
  8009eb:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8009f2:	f6 c2 01             	test   $0x1,%dl
  8009f5:	74 26                	je     800a1d <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8009f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8009fe:	83 ec 0c             	sub    $0xc,%esp
  800a01:	25 07 0e 00 00       	and    $0xe07,%eax
  800a06:	50                   	push   %eax
  800a07:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a0a:	6a 00                	push   $0x0
  800a0c:	57                   	push   %edi
  800a0d:	6a 00                	push   $0x0
  800a0f:	e8 b0 fb ff ff       	call   8005c4 <sys_page_map>
  800a14:	89 c7                	mov    %eax,%edi
  800a16:	83 c4 20             	add    $0x20,%esp
  800a19:	85 c0                	test   %eax,%eax
  800a1b:	78 2e                	js     800a4b <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a1d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a20:	89 d0                	mov    %edx,%eax
  800a22:	c1 e8 0c             	shr    $0xc,%eax
  800a25:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800a2c:	83 ec 0c             	sub    $0xc,%esp
  800a2f:	25 07 0e 00 00       	and    $0xe07,%eax
  800a34:	50                   	push   %eax
  800a35:	53                   	push   %ebx
  800a36:	6a 00                	push   $0x0
  800a38:	52                   	push   %edx
  800a39:	6a 00                	push   $0x0
  800a3b:	e8 84 fb ff ff       	call   8005c4 <sys_page_map>
  800a40:	89 c7                	mov    %eax,%edi
  800a42:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800a45:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800a47:	85 ff                	test   %edi,%edi
  800a49:	79 1d                	jns    800a68 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800a4b:	83 ec 08             	sub    $0x8,%esp
  800a4e:	53                   	push   %ebx
  800a4f:	6a 00                	push   $0x0
  800a51:	e8 b0 fb ff ff       	call   800606 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800a56:	83 c4 08             	add    $0x8,%esp
  800a59:	ff 75 d4             	pushl  -0x2c(%ebp)
  800a5c:	6a 00                	push   $0x0
  800a5e:	e8 a3 fb ff ff       	call   800606 <sys_page_unmap>
	return r;
  800a63:	83 c4 10             	add    $0x10,%esp
  800a66:	89 f8                	mov    %edi,%eax
}
  800a68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a6b:	5b                   	pop    %ebx
  800a6c:	5e                   	pop    %esi
  800a6d:	5f                   	pop    %edi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	53                   	push   %ebx
  800a74:	83 ec 14             	sub    $0x14,%esp
  800a77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800a7a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800a7d:	50                   	push   %eax
  800a7e:	53                   	push   %ebx
  800a7f:	e8 83 fd ff ff       	call   800807 <fd_lookup>
  800a84:	83 c4 08             	add    $0x8,%esp
  800a87:	89 c2                	mov    %eax,%edx
  800a89:	85 c0                	test   %eax,%eax
  800a8b:	78 6d                	js     800afa <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800a8d:	83 ec 08             	sub    $0x8,%esp
  800a90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800a93:	50                   	push   %eax
  800a94:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a97:	ff 30                	pushl  (%eax)
  800a99:	e8 bf fd ff ff       	call   80085d <dev_lookup>
  800a9e:	83 c4 10             	add    $0x10,%esp
  800aa1:	85 c0                	test   %eax,%eax
  800aa3:	78 4c                	js     800af1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800aa5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800aa8:	8b 42 08             	mov    0x8(%edx),%eax
  800aab:	83 e0 03             	and    $0x3,%eax
  800aae:	83 f8 01             	cmp    $0x1,%eax
  800ab1:	75 21                	jne    800ad4 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800ab3:	a1 04 40 80 00       	mov    0x804004,%eax
  800ab8:	8b 40 48             	mov    0x48(%eax),%eax
  800abb:	83 ec 04             	sub    $0x4,%esp
  800abe:	53                   	push   %ebx
  800abf:	50                   	push   %eax
  800ac0:	68 fd 1e 80 00       	push   $0x801efd
  800ac5:	e8 85 0a 00 00       	call   80154f <cprintf>
		return -E_INVAL;
  800aca:	83 c4 10             	add    $0x10,%esp
  800acd:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ad2:	eb 26                	jmp    800afa <read+0x8a>
	}
	if (!dev->dev_read)
  800ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ad7:	8b 40 08             	mov    0x8(%eax),%eax
  800ada:	85 c0                	test   %eax,%eax
  800adc:	74 17                	je     800af5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800ade:	83 ec 04             	sub    $0x4,%esp
  800ae1:	ff 75 10             	pushl  0x10(%ebp)
  800ae4:	ff 75 0c             	pushl  0xc(%ebp)
  800ae7:	52                   	push   %edx
  800ae8:	ff d0                	call   *%eax
  800aea:	89 c2                	mov    %eax,%edx
  800aec:	83 c4 10             	add    $0x10,%esp
  800aef:	eb 09                	jmp    800afa <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800af1:	89 c2                	mov    %eax,%edx
  800af3:	eb 05                	jmp    800afa <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  800af5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  800afa:	89 d0                	mov    %edx,%eax
  800afc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aff:	c9                   	leave  
  800b00:	c3                   	ret    

00800b01 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	83 ec 0c             	sub    $0xc,%esp
  800b0a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800b15:	eb 21                	jmp    800b38 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800b17:	83 ec 04             	sub    $0x4,%esp
  800b1a:	89 f0                	mov    %esi,%eax
  800b1c:	29 d8                	sub    %ebx,%eax
  800b1e:	50                   	push   %eax
  800b1f:	89 d8                	mov    %ebx,%eax
  800b21:	03 45 0c             	add    0xc(%ebp),%eax
  800b24:	50                   	push   %eax
  800b25:	57                   	push   %edi
  800b26:	e8 45 ff ff ff       	call   800a70 <read>
		if (m < 0)
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	85 c0                	test   %eax,%eax
  800b30:	78 0c                	js     800b3e <readn+0x3d>
			return m;
		if (m == 0)
  800b32:	85 c0                	test   %eax,%eax
  800b34:	74 06                	je     800b3c <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800b36:	01 c3                	add    %eax,%ebx
  800b38:	39 f3                	cmp    %esi,%ebx
  800b3a:	72 db                	jb     800b17 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  800b3c:	89 d8                	mov    %ebx,%eax
}
  800b3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b41:	5b                   	pop    %ebx
  800b42:	5e                   	pop    %esi
  800b43:	5f                   	pop    %edi
  800b44:	5d                   	pop    %ebp
  800b45:	c3                   	ret    

00800b46 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	53                   	push   %ebx
  800b4a:	83 ec 14             	sub    $0x14,%esp
  800b4d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800b50:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800b53:	50                   	push   %eax
  800b54:	53                   	push   %ebx
  800b55:	e8 ad fc ff ff       	call   800807 <fd_lookup>
  800b5a:	83 c4 08             	add    $0x8,%esp
  800b5d:	89 c2                	mov    %eax,%edx
  800b5f:	85 c0                	test   %eax,%eax
  800b61:	78 68                	js     800bcb <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b69:	50                   	push   %eax
  800b6a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b6d:	ff 30                	pushl  (%eax)
  800b6f:	e8 e9 fc ff ff       	call   80085d <dev_lookup>
  800b74:	83 c4 10             	add    $0x10,%esp
  800b77:	85 c0                	test   %eax,%eax
  800b79:	78 47                	js     800bc2 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800b7b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800b7e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800b82:	75 21                	jne    800ba5 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800b84:	a1 04 40 80 00       	mov    0x804004,%eax
  800b89:	8b 40 48             	mov    0x48(%eax),%eax
  800b8c:	83 ec 04             	sub    $0x4,%esp
  800b8f:	53                   	push   %ebx
  800b90:	50                   	push   %eax
  800b91:	68 19 1f 80 00       	push   $0x801f19
  800b96:	e8 b4 09 00 00       	call   80154f <cprintf>
		return -E_INVAL;
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800ba3:	eb 26                	jmp    800bcb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ba8:	8b 52 0c             	mov    0xc(%edx),%edx
  800bab:	85 d2                	test   %edx,%edx
  800bad:	74 17                	je     800bc6 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800baf:	83 ec 04             	sub    $0x4,%esp
  800bb2:	ff 75 10             	pushl  0x10(%ebp)
  800bb5:	ff 75 0c             	pushl  0xc(%ebp)
  800bb8:	50                   	push   %eax
  800bb9:	ff d2                	call   *%edx
  800bbb:	89 c2                	mov    %eax,%edx
  800bbd:	83 c4 10             	add    $0x10,%esp
  800bc0:	eb 09                	jmp    800bcb <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800bc2:	89 c2                	mov    %eax,%edx
  800bc4:	eb 05                	jmp    800bcb <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800bc6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800bcb:	89 d0                	mov    %edx,%eax
  800bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <seek>:

int
seek(int fdnum, off_t offset)
{
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800bd8:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800bdb:	50                   	push   %eax
  800bdc:	ff 75 08             	pushl  0x8(%ebp)
  800bdf:	e8 23 fc ff ff       	call   800807 <fd_lookup>
  800be4:	83 c4 08             	add    $0x8,%esp
  800be7:	85 c0                	test   %eax,%eax
  800be9:	78 0e                	js     800bf9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800beb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800bee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 14             	sub    $0x14,%esp
  800c02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c05:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c08:	50                   	push   %eax
  800c09:	53                   	push   %ebx
  800c0a:	e8 f8 fb ff ff       	call   800807 <fd_lookup>
  800c0f:	83 c4 08             	add    $0x8,%esp
  800c12:	89 c2                	mov    %eax,%edx
  800c14:	85 c0                	test   %eax,%eax
  800c16:	78 65                	js     800c7d <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c18:	83 ec 08             	sub    $0x8,%esp
  800c1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c1e:	50                   	push   %eax
  800c1f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c22:	ff 30                	pushl  (%eax)
  800c24:	e8 34 fc ff ff       	call   80085d <dev_lookup>
  800c29:	83 c4 10             	add    $0x10,%esp
  800c2c:	85 c0                	test   %eax,%eax
  800c2e:	78 44                	js     800c74 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c33:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800c37:	75 21                	jne    800c5a <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800c39:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800c3e:	8b 40 48             	mov    0x48(%eax),%eax
  800c41:	83 ec 04             	sub    $0x4,%esp
  800c44:	53                   	push   %ebx
  800c45:	50                   	push   %eax
  800c46:	68 dc 1e 80 00       	push   $0x801edc
  800c4b:	e8 ff 08 00 00       	call   80154f <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800c58:	eb 23                	jmp    800c7d <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800c5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800c5d:	8b 52 18             	mov    0x18(%edx),%edx
  800c60:	85 d2                	test   %edx,%edx
  800c62:	74 14                	je     800c78 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800c64:	83 ec 08             	sub    $0x8,%esp
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	50                   	push   %eax
  800c6b:	ff d2                	call   *%edx
  800c6d:	89 c2                	mov    %eax,%edx
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	eb 09                	jmp    800c7d <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800c74:	89 c2                	mov    %eax,%edx
  800c76:	eb 05                	jmp    800c7d <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800c78:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800c7d:	89 d0                	mov    %edx,%eax
  800c7f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	53                   	push   %ebx
  800c88:	83 ec 14             	sub    $0x14,%esp
  800c8b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800c8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800c91:	50                   	push   %eax
  800c92:	ff 75 08             	pushl  0x8(%ebp)
  800c95:	e8 6d fb ff ff       	call   800807 <fd_lookup>
  800c9a:	83 c4 08             	add    $0x8,%esp
  800c9d:	89 c2                	mov    %eax,%edx
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	78 58                	js     800cfb <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800ca3:	83 ec 08             	sub    $0x8,%esp
  800ca6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ca9:	50                   	push   %eax
  800caa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800cad:	ff 30                	pushl  (%eax)
  800caf:	e8 a9 fb ff ff       	call   80085d <dev_lookup>
  800cb4:	83 c4 10             	add    $0x10,%esp
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	78 37                	js     800cf2 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbe:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800cc2:	74 32                	je     800cf6 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800cc4:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800cc7:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800cce:	00 00 00 
	stat->st_isdir = 0;
  800cd1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800cd8:	00 00 00 
	stat->st_dev = dev;
  800cdb:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800ce1:	83 ec 08             	sub    $0x8,%esp
  800ce4:	53                   	push   %ebx
  800ce5:	ff 75 f0             	pushl  -0x10(%ebp)
  800ce8:	ff 50 14             	call   *0x14(%eax)
  800ceb:	89 c2                	mov    %eax,%edx
  800ced:	83 c4 10             	add    $0x10,%esp
  800cf0:	eb 09                	jmp    800cfb <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800cf2:	89 c2                	mov    %eax,%edx
  800cf4:	eb 05                	jmp    800cfb <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  800cf6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  800cfb:	89 d0                	mov    %edx,%eax
  800cfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d00:	c9                   	leave  
  800d01:	c3                   	ret    

00800d02 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800d07:	83 ec 08             	sub    $0x8,%esp
  800d0a:	6a 00                	push   $0x0
  800d0c:	ff 75 08             	pushl  0x8(%ebp)
  800d0f:	e8 e7 01 00 00       	call   800efb <open>
  800d14:	89 c3                	mov    %eax,%ebx
  800d16:	83 c4 10             	add    $0x10,%esp
  800d19:	85 db                	test   %ebx,%ebx
  800d1b:	78 1b                	js     800d38 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800d1d:	83 ec 08             	sub    $0x8,%esp
  800d20:	ff 75 0c             	pushl  0xc(%ebp)
  800d23:	53                   	push   %ebx
  800d24:	e8 5b ff ff ff       	call   800c84 <fstat>
  800d29:	89 c6                	mov    %eax,%esi
	close(fd);
  800d2b:	89 1c 24             	mov    %ebx,(%esp)
  800d2e:	e8 fd fb ff ff       	call   800930 <close>
	return r;
  800d33:	83 c4 10             	add    $0x10,%esp
  800d36:	89 f0                	mov    %esi,%eax
}
  800d38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d3b:	5b                   	pop    %ebx
  800d3c:	5e                   	pop    %esi
  800d3d:	5d                   	pop    %ebp
  800d3e:	c3                   	ret    

00800d3f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
  800d44:	89 c6                	mov    %eax,%esi
  800d46:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800d48:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800d4f:	75 12                	jne    800d63 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	6a 03                	push   $0x3
  800d56:	e8 f6 0d 00 00       	call   801b51 <ipc_find_env>
  800d5b:	a3 00 40 80 00       	mov    %eax,0x804000
  800d60:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800d63:	6a 07                	push   $0x7
  800d65:	68 00 50 80 00       	push   $0x805000
  800d6a:	56                   	push   %esi
  800d6b:	ff 35 00 40 80 00    	pushl  0x804000
  800d71:	e8 8a 0d 00 00       	call   801b00 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800d76:	83 c4 0c             	add    $0xc,%esp
  800d79:	6a 00                	push   $0x0
  800d7b:	53                   	push   %ebx
  800d7c:	6a 00                	push   $0x0
  800d7e:	e8 17 0d 00 00       	call   801a9a <ipc_recv>
}
  800d83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800d90:	8b 45 08             	mov    0x8(%ebp),%eax
  800d93:	8b 40 0c             	mov    0xc(%eax),%eax
  800d96:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800d9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800da3:	ba 00 00 00 00       	mov    $0x0,%edx
  800da8:	b8 02 00 00 00       	mov    $0x2,%eax
  800dad:	e8 8d ff ff ff       	call   800d3f <fsipc>
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800dba:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbd:	8b 40 0c             	mov    0xc(%eax),%eax
  800dc0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800dc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dca:	b8 06 00 00 00       	mov    $0x6,%eax
  800dcf:	e8 6b ff ff ff       	call   800d3f <fsipc>
}
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    

00800dd6 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	53                   	push   %ebx
  800dda:	83 ec 04             	sub    $0x4,%esp
  800ddd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800de0:	8b 45 08             	mov    0x8(%ebp),%eax
  800de3:	8b 40 0c             	mov    0xc(%eax),%eax
  800de6:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800deb:	ba 00 00 00 00       	mov    $0x0,%edx
  800df0:	b8 05 00 00 00       	mov    $0x5,%eax
  800df5:	e8 45 ff ff ff       	call   800d3f <fsipc>
  800dfa:	89 c2                	mov    %eax,%edx
  800dfc:	85 d2                	test   %edx,%edx
  800dfe:	78 2c                	js     800e2c <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800e00:	83 ec 08             	sub    $0x8,%esp
  800e03:	68 00 50 80 00       	push   $0x805000
  800e08:	53                   	push   %ebx
  800e09:	e8 69 f3 ff ff       	call   800177 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800e0e:	a1 80 50 80 00       	mov    0x805080,%eax
  800e13:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800e19:	a1 84 50 80 00       	mov    0x805084,%eax
  800e1e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800e24:	83 c4 10             	add    $0x10,%esp
  800e27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 08             	sub    $0x8,%esp
  800e37:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  800e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3d:	8b 52 0c             	mov    0xc(%edx),%edx
  800e40:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  800e46:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  800e4b:	76 05                	jbe    800e52 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  800e4d:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  800e52:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	50                   	push   %eax
  800e5b:	ff 75 0c             	pushl  0xc(%ebp)
  800e5e:	68 08 50 80 00       	push   $0x805008
  800e63:	e8 a1 f4 ff ff       	call   800309 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  800e68:	ba 00 00 00 00       	mov    $0x0,%edx
  800e6d:	b8 04 00 00 00       	mov    $0x4,%eax
  800e72:	e8 c8 fe ff ff       	call   800d3f <fsipc>
	return write;
}
  800e77:	c9                   	leave  
  800e78:	c3                   	ret    

00800e79 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	56                   	push   %esi
  800e7d:	53                   	push   %ebx
  800e7e:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800e81:	8b 45 08             	mov    0x8(%ebp),%eax
  800e84:	8b 40 0c             	mov    0xc(%eax),%eax
  800e87:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800e8c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800e92:	ba 00 00 00 00       	mov    $0x0,%edx
  800e97:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9c:	e8 9e fe ff ff       	call   800d3f <fsipc>
  800ea1:	89 c3                	mov    %eax,%ebx
  800ea3:	85 c0                	test   %eax,%eax
  800ea5:	78 4b                	js     800ef2 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800ea7:	39 c6                	cmp    %eax,%esi
  800ea9:	73 16                	jae    800ec1 <devfile_read+0x48>
  800eab:	68 48 1f 80 00       	push   $0x801f48
  800eb0:	68 4f 1f 80 00       	push   $0x801f4f
  800eb5:	6a 7c                	push   $0x7c
  800eb7:	68 64 1f 80 00       	push   $0x801f64
  800ebc:	e8 b5 05 00 00       	call   801476 <_panic>
	assert(r <= PGSIZE);
  800ec1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ec6:	7e 16                	jle    800ede <devfile_read+0x65>
  800ec8:	68 6f 1f 80 00       	push   $0x801f6f
  800ecd:	68 4f 1f 80 00       	push   $0x801f4f
  800ed2:	6a 7d                	push   $0x7d
  800ed4:	68 64 1f 80 00       	push   $0x801f64
  800ed9:	e8 98 05 00 00       	call   801476 <_panic>
	memmove(buf, &fsipcbuf, r);
  800ede:	83 ec 04             	sub    $0x4,%esp
  800ee1:	50                   	push   %eax
  800ee2:	68 00 50 80 00       	push   $0x805000
  800ee7:	ff 75 0c             	pushl  0xc(%ebp)
  800eea:	e8 1a f4 ff ff       	call   800309 <memmove>
	return r;
  800eef:	83 c4 10             	add    $0x10,%esp
}
  800ef2:	89 d8                	mov    %ebx,%eax
  800ef4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef7:	5b                   	pop    %ebx
  800ef8:	5e                   	pop    %esi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	53                   	push   %ebx
  800eff:	83 ec 20             	sub    $0x20,%esp
  800f02:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800f05:	53                   	push   %ebx
  800f06:	e8 33 f2 ff ff       	call   80013e <strlen>
  800f0b:	83 c4 10             	add    $0x10,%esp
  800f0e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800f13:	7f 67                	jg     800f7c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1b:	50                   	push   %eax
  800f1c:	e8 97 f8 ff ff       	call   8007b8 <fd_alloc>
  800f21:	83 c4 10             	add    $0x10,%esp
		return r;
  800f24:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800f26:	85 c0                	test   %eax,%eax
  800f28:	78 57                	js     800f81 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800f2a:	83 ec 08             	sub    $0x8,%esp
  800f2d:	53                   	push   %ebx
  800f2e:	68 00 50 80 00       	push   $0x805000
  800f33:	e8 3f f2 ff ff       	call   800177 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800f38:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f3b:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800f40:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800f43:	b8 01 00 00 00       	mov    $0x1,%eax
  800f48:	e8 f2 fd ff ff       	call   800d3f <fsipc>
  800f4d:	89 c3                	mov    %eax,%ebx
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	79 14                	jns    800f6a <open+0x6f>
		fd_close(fd, 0);
  800f56:	83 ec 08             	sub    $0x8,%esp
  800f59:	6a 00                	push   $0x0
  800f5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800f5e:	e8 4d f9 ff ff       	call   8008b0 <fd_close>
		return r;
  800f63:	83 c4 10             	add    $0x10,%esp
  800f66:	89 da                	mov    %ebx,%edx
  800f68:	eb 17                	jmp    800f81 <open+0x86>
	}

	return fd2num(fd);
  800f6a:	83 ec 0c             	sub    $0xc,%esp
  800f6d:	ff 75 f4             	pushl  -0xc(%ebp)
  800f70:	e8 1c f8 ff ff       	call   800791 <fd2num>
  800f75:	89 c2                	mov    %eax,%edx
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	eb 05                	jmp    800f81 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800f7c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800f81:	89 d0                	mov    %edx,%eax
  800f83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800f8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f93:	b8 08 00 00 00       	mov    $0x8,%eax
  800f98:	e8 a2 fd ff ff       	call   800d3f <fsipc>
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	56                   	push   %esi
  800fa3:	53                   	push   %ebx
  800fa4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	ff 75 08             	pushl  0x8(%ebp)
  800fad:	e8 ef f7 ff ff       	call   8007a1 <fd2data>
  800fb2:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800fb4:	83 c4 08             	add    $0x8,%esp
  800fb7:	68 7b 1f 80 00       	push   $0x801f7b
  800fbc:	53                   	push   %ebx
  800fbd:	e8 b5 f1 ff ff       	call   800177 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800fc2:	8b 56 04             	mov    0x4(%esi),%edx
  800fc5:	89 d0                	mov    %edx,%eax
  800fc7:	2b 06                	sub    (%esi),%eax
  800fc9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800fcf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800fd6:	00 00 00 
	stat->st_dev = &devpipe;
  800fd9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800fe0:	30 80 00 
	return 0;
}
  800fe3:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5d                   	pop    %ebp
  800fee:	c3                   	ret    

00800fef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800fef:	55                   	push   %ebp
  800ff0:	89 e5                	mov    %esp,%ebp
  800ff2:	53                   	push   %ebx
  800ff3:	83 ec 0c             	sub    $0xc,%esp
  800ff6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ff9:	53                   	push   %ebx
  800ffa:	6a 00                	push   $0x0
  800ffc:	e8 05 f6 ff ff       	call   800606 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801001:	89 1c 24             	mov    %ebx,(%esp)
  801004:	e8 98 f7 ff ff       	call   8007a1 <fd2data>
  801009:	83 c4 08             	add    $0x8,%esp
  80100c:	50                   	push   %eax
  80100d:	6a 00                	push   $0x0
  80100f:	e8 f2 f5 ff ff       	call   800606 <sys_page_unmap>
}
  801014:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801017:	c9                   	leave  
  801018:	c3                   	ret    

00801019 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801019:	55                   	push   %ebp
  80101a:	89 e5                	mov    %esp,%ebp
  80101c:	57                   	push   %edi
  80101d:	56                   	push   %esi
  80101e:	53                   	push   %ebx
  80101f:	83 ec 1c             	sub    $0x1c,%esp
  801022:	89 c7                	mov    %eax,%edi
  801024:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801026:	a1 04 40 80 00       	mov    0x804004,%eax
  80102b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	57                   	push   %edi
  801032:	e8 52 0b 00 00       	call   801b89 <pageref>
  801037:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80103a:	89 34 24             	mov    %esi,(%esp)
  80103d:	e8 47 0b 00 00       	call   801b89 <pageref>
  801042:	83 c4 10             	add    $0x10,%esp
  801045:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801048:	0f 94 c0             	sete   %al
  80104b:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80104e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801054:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801057:	39 cb                	cmp    %ecx,%ebx
  801059:	74 15                	je     801070 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  80105b:	8b 52 58             	mov    0x58(%edx),%edx
  80105e:	50                   	push   %eax
  80105f:	52                   	push   %edx
  801060:	53                   	push   %ebx
  801061:	68 88 1f 80 00       	push   $0x801f88
  801066:	e8 e4 04 00 00       	call   80154f <cprintf>
  80106b:	83 c4 10             	add    $0x10,%esp
  80106e:	eb b6                	jmp    801026 <_pipeisclosed+0xd>
	}
}
  801070:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801073:	5b                   	pop    %ebx
  801074:	5e                   	pop    %esi
  801075:	5f                   	pop    %edi
  801076:	5d                   	pop    %ebp
  801077:	c3                   	ret    

00801078 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	57                   	push   %edi
  80107c:	56                   	push   %esi
  80107d:	53                   	push   %ebx
  80107e:	83 ec 28             	sub    $0x28,%esp
  801081:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801084:	56                   	push   %esi
  801085:	e8 17 f7 ff ff       	call   8007a1 <fd2data>
  80108a:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80108c:	83 c4 10             	add    $0x10,%esp
  80108f:	bf 00 00 00 00       	mov    $0x0,%edi
  801094:	eb 4b                	jmp    8010e1 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801096:	89 da                	mov    %ebx,%edx
  801098:	89 f0                	mov    %esi,%eax
  80109a:	e8 7a ff ff ff       	call   801019 <_pipeisclosed>
  80109f:	85 c0                	test   %eax,%eax
  8010a1:	75 48                	jne    8010eb <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8010a3:	e8 ba f4 ff ff       	call   800562 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010a8:	8b 43 04             	mov    0x4(%ebx),%eax
  8010ab:	8b 0b                	mov    (%ebx),%ecx
  8010ad:	8d 51 20             	lea    0x20(%ecx),%edx
  8010b0:	39 d0                	cmp    %edx,%eax
  8010b2:	73 e2                	jae    801096 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8010b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010b7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8010bb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	c1 fa 1f             	sar    $0x1f,%edx
  8010c3:	89 d1                	mov    %edx,%ecx
  8010c5:	c1 e9 1b             	shr    $0x1b,%ecx
  8010c8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8010cb:	83 e2 1f             	and    $0x1f,%edx
  8010ce:	29 ca                	sub    %ecx,%edx
  8010d0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8010d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8010d8:	83 c0 01             	add    $0x1,%eax
  8010db:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010de:	83 c7 01             	add    $0x1,%edi
  8010e1:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010e4:	75 c2                	jne    8010a8 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8010e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8010e9:	eb 05                	jmp    8010f0 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8010eb:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8010f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f3:	5b                   	pop    %ebx
  8010f4:	5e                   	pop    %esi
  8010f5:	5f                   	pop    %edi
  8010f6:	5d                   	pop    %ebp
  8010f7:	c3                   	ret    

008010f8 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	57                   	push   %edi
  8010fc:	56                   	push   %esi
  8010fd:	53                   	push   %ebx
  8010fe:	83 ec 18             	sub    $0x18,%esp
  801101:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801104:	57                   	push   %edi
  801105:	e8 97 f6 ff ff       	call   8007a1 <fd2data>
  80110a:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80110c:	83 c4 10             	add    $0x10,%esp
  80110f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801114:	eb 3d                	jmp    801153 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801116:	85 db                	test   %ebx,%ebx
  801118:	74 04                	je     80111e <devpipe_read+0x26>
				return i;
  80111a:	89 d8                	mov    %ebx,%eax
  80111c:	eb 44                	jmp    801162 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80111e:	89 f2                	mov    %esi,%edx
  801120:	89 f8                	mov    %edi,%eax
  801122:	e8 f2 fe ff ff       	call   801019 <_pipeisclosed>
  801127:	85 c0                	test   %eax,%eax
  801129:	75 32                	jne    80115d <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80112b:	e8 32 f4 ff ff       	call   800562 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801130:	8b 06                	mov    (%esi),%eax
  801132:	3b 46 04             	cmp    0x4(%esi),%eax
  801135:	74 df                	je     801116 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801137:	99                   	cltd   
  801138:	c1 ea 1b             	shr    $0x1b,%edx
  80113b:	01 d0                	add    %edx,%eax
  80113d:	83 e0 1f             	and    $0x1f,%eax
  801140:	29 d0                	sub    %edx,%eax
  801142:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801147:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80114a:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80114d:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801150:	83 c3 01             	add    $0x1,%ebx
  801153:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801156:	75 d8                	jne    801130 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801158:	8b 45 10             	mov    0x10(%ebp),%eax
  80115b:	eb 05                	jmp    801162 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80115d:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801162:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801165:	5b                   	pop    %ebx
  801166:	5e                   	pop    %esi
  801167:	5f                   	pop    %edi
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801172:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801175:	50                   	push   %eax
  801176:	e8 3d f6 ff ff       	call   8007b8 <fd_alloc>
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	89 c2                	mov    %eax,%edx
  801180:	85 c0                	test   %eax,%eax
  801182:	0f 88 2c 01 00 00    	js     8012b4 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801188:	83 ec 04             	sub    $0x4,%esp
  80118b:	68 07 04 00 00       	push   $0x407
  801190:	ff 75 f4             	pushl  -0xc(%ebp)
  801193:	6a 00                	push   $0x0
  801195:	e8 e7 f3 ff ff       	call   800581 <sys_page_alloc>
  80119a:	83 c4 10             	add    $0x10,%esp
  80119d:	89 c2                	mov    %eax,%edx
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	0f 88 0d 01 00 00    	js     8012b4 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	e8 05 f6 ff ff       	call   8007b8 <fd_alloc>
  8011b3:	89 c3                	mov    %eax,%ebx
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	85 c0                	test   %eax,%eax
  8011ba:	0f 88 e2 00 00 00    	js     8012a2 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011c0:	83 ec 04             	sub    $0x4,%esp
  8011c3:	68 07 04 00 00       	push   $0x407
  8011c8:	ff 75 f0             	pushl  -0x10(%ebp)
  8011cb:	6a 00                	push   $0x0
  8011cd:	e8 af f3 ff ff       	call   800581 <sys_page_alloc>
  8011d2:	89 c3                	mov    %eax,%ebx
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	0f 88 c3 00 00 00    	js     8012a2 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8011df:	83 ec 0c             	sub    $0xc,%esp
  8011e2:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e5:	e8 b7 f5 ff ff       	call   8007a1 <fd2data>
  8011ea:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011ec:	83 c4 0c             	add    $0xc,%esp
  8011ef:	68 07 04 00 00       	push   $0x407
  8011f4:	50                   	push   %eax
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 85 f3 ff ff       	call   800581 <sys_page_alloc>
  8011fc:	89 c3                	mov    %eax,%ebx
  8011fe:	83 c4 10             	add    $0x10,%esp
  801201:	85 c0                	test   %eax,%eax
  801203:	0f 88 89 00 00 00    	js     801292 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801209:	83 ec 0c             	sub    $0xc,%esp
  80120c:	ff 75 f0             	pushl  -0x10(%ebp)
  80120f:	e8 8d f5 ff ff       	call   8007a1 <fd2data>
  801214:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80121b:	50                   	push   %eax
  80121c:	6a 00                	push   $0x0
  80121e:	56                   	push   %esi
  80121f:	6a 00                	push   $0x0
  801221:	e8 9e f3 ff ff       	call   8005c4 <sys_page_map>
  801226:	89 c3                	mov    %eax,%ebx
  801228:	83 c4 20             	add    $0x20,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 55                	js     801284 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80122f:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801235:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801238:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  80123a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801244:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80124a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124d:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80124f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801252:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801259:	83 ec 0c             	sub    $0xc,%esp
  80125c:	ff 75 f4             	pushl  -0xc(%ebp)
  80125f:	e8 2d f5 ff ff       	call   800791 <fd2num>
  801264:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801267:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801269:	83 c4 04             	add    $0x4,%esp
  80126c:	ff 75 f0             	pushl  -0x10(%ebp)
  80126f:	e8 1d f5 ff ff       	call   800791 <fd2num>
  801274:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801277:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80127a:	83 c4 10             	add    $0x10,%esp
  80127d:	ba 00 00 00 00       	mov    $0x0,%edx
  801282:	eb 30                	jmp    8012b4 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801284:	83 ec 08             	sub    $0x8,%esp
  801287:	56                   	push   %esi
  801288:	6a 00                	push   $0x0
  80128a:	e8 77 f3 ff ff       	call   800606 <sys_page_unmap>
  80128f:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801292:	83 ec 08             	sub    $0x8,%esp
  801295:	ff 75 f0             	pushl  -0x10(%ebp)
  801298:	6a 00                	push   $0x0
  80129a:	e8 67 f3 ff ff       	call   800606 <sys_page_unmap>
  80129f:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8012a2:	83 ec 08             	sub    $0x8,%esp
  8012a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 57 f3 ff ff       	call   800606 <sys_page_unmap>
  8012af:	83 c4 10             	add    $0x10,%esp
  8012b2:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  8012b4:	89 d0                	mov    %edx,%eax
  8012b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b9:	5b                   	pop    %ebx
  8012ba:	5e                   	pop    %esi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012c6:	50                   	push   %eax
  8012c7:	ff 75 08             	pushl  0x8(%ebp)
  8012ca:	e8 38 f5 ff ff       	call   800807 <fd_lookup>
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 d2                	test   %edx,%edx
  8012d6:	78 18                	js     8012f0 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	ff 75 f4             	pushl  -0xc(%ebp)
  8012de:	e8 be f4 ff ff       	call   8007a1 <fd2data>
	return _pipeisclosed(fd, p);
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012e8:	e8 2c fd ff ff       	call   801019 <_pipeisclosed>
  8012ed:	83 c4 10             	add    $0x10,%esp
}
  8012f0:	c9                   	leave  
  8012f1:	c3                   	ret    

008012f2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8012f2:	55                   	push   %ebp
  8012f3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8012f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fa:	5d                   	pop    %ebp
  8012fb:	c3                   	ret    

008012fc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801302:	68 b9 1f 80 00       	push   $0x801fb9
  801307:	ff 75 0c             	pushl  0xc(%ebp)
  80130a:	e8 68 ee ff ff       	call   800177 <strcpy>
	return 0;
}
  80130f:	b8 00 00 00 00       	mov    $0x0,%eax
  801314:	c9                   	leave  
  801315:	c3                   	ret    

00801316 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	57                   	push   %edi
  80131a:	56                   	push   %esi
  80131b:	53                   	push   %ebx
  80131c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801322:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801327:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80132d:	eb 2e                	jmp    80135d <devcons_write+0x47>
		m = n - tot;
  80132f:	8b 55 10             	mov    0x10(%ebp),%edx
  801332:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801334:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801339:	83 fa 7f             	cmp    $0x7f,%edx
  80133c:	77 02                	ja     801340 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80133e:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801340:	83 ec 04             	sub    $0x4,%esp
  801343:	56                   	push   %esi
  801344:	03 45 0c             	add    0xc(%ebp),%eax
  801347:	50                   	push   %eax
  801348:	57                   	push   %edi
  801349:	e8 bb ef ff ff       	call   800309 <memmove>
		sys_cputs(buf, m);
  80134e:	83 c4 08             	add    $0x8,%esp
  801351:	56                   	push   %esi
  801352:	57                   	push   %edi
  801353:	e8 6d f1 ff ff       	call   8004c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801358:	01 f3                	add    %esi,%ebx
  80135a:	83 c4 10             	add    $0x10,%esp
  80135d:	89 d8                	mov    %ebx,%eax
  80135f:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801362:	72 cb                	jb     80132f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801364:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801367:	5b                   	pop    %ebx
  801368:	5e                   	pop    %esi
  801369:	5f                   	pop    %edi
  80136a:	5d                   	pop    %ebp
  80136b:	c3                   	ret    

0080136c <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80136c:	55                   	push   %ebp
  80136d:	89 e5                	mov    %esp,%ebp
  80136f:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801372:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801377:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80137b:	75 07                	jne    801384 <devcons_read+0x18>
  80137d:	eb 28                	jmp    8013a7 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80137f:	e8 de f1 ff ff       	call   800562 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801384:	e8 5a f1 ff ff       	call   8004e3 <sys_cgetc>
  801389:	85 c0                	test   %eax,%eax
  80138b:	74 f2                	je     80137f <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80138d:	85 c0                	test   %eax,%eax
  80138f:	78 16                	js     8013a7 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801391:	83 f8 04             	cmp    $0x4,%eax
  801394:	74 0c                	je     8013a2 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801396:	8b 55 0c             	mov    0xc(%ebp),%edx
  801399:	88 02                	mov    %al,(%edx)
	return 1;
  80139b:	b8 01 00 00 00       	mov    $0x1,%eax
  8013a0:	eb 05                	jmp    8013a7 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8013a7:	c9                   	leave  
  8013a8:	c3                   	ret    

008013a9 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8013a9:	55                   	push   %ebp
  8013aa:	89 e5                	mov    %esp,%ebp
  8013ac:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013af:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b2:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8013b5:	6a 01                	push   $0x1
  8013b7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013ba:	50                   	push   %eax
  8013bb:	e8 05 f1 ff ff       	call   8004c5 <sys_cputs>
  8013c0:	83 c4 10             	add    $0x10,%esp
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <getchar>:

int
getchar(void)
{
  8013c5:	55                   	push   %ebp
  8013c6:	89 e5                	mov    %esp,%ebp
  8013c8:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  8013cb:	6a 01                	push   $0x1
  8013cd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013d0:	50                   	push   %eax
  8013d1:	6a 00                	push   $0x0
  8013d3:	e8 98 f6 ff ff       	call   800a70 <read>
	if (r < 0)
  8013d8:	83 c4 10             	add    $0x10,%esp
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 0f                	js     8013ee <getchar+0x29>
		return r;
	if (r < 1)
  8013df:	85 c0                	test   %eax,%eax
  8013e1:	7e 06                	jle    8013e9 <getchar+0x24>
		return -E_EOF;
	return c;
  8013e3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8013e7:	eb 05                	jmp    8013ee <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8013e9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8013ee:	c9                   	leave  
  8013ef:	c3                   	ret    

008013f0 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8013f0:	55                   	push   %ebp
  8013f1:	89 e5                	mov    %esp,%ebp
  8013f3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f9:	50                   	push   %eax
  8013fa:	ff 75 08             	pushl  0x8(%ebp)
  8013fd:	e8 05 f4 ff ff       	call   800807 <fd_lookup>
  801402:	83 c4 10             	add    $0x10,%esp
  801405:	85 c0                	test   %eax,%eax
  801407:	78 11                	js     80141a <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801409:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801412:	39 10                	cmp    %edx,(%eax)
  801414:	0f 94 c0             	sete   %al
  801417:	0f b6 c0             	movzbl %al,%eax
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    

0080141c <opencons>:

int
opencons(void)
{
  80141c:	55                   	push   %ebp
  80141d:	89 e5                	mov    %esp,%ebp
  80141f:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801422:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801425:	50                   	push   %eax
  801426:	e8 8d f3 ff ff       	call   8007b8 <fd_alloc>
  80142b:	83 c4 10             	add    $0x10,%esp
		return r;
  80142e:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801430:	85 c0                	test   %eax,%eax
  801432:	78 3e                	js     801472 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801434:	83 ec 04             	sub    $0x4,%esp
  801437:	68 07 04 00 00       	push   $0x407
  80143c:	ff 75 f4             	pushl  -0xc(%ebp)
  80143f:	6a 00                	push   $0x0
  801441:	e8 3b f1 ff ff       	call   800581 <sys_page_alloc>
  801446:	83 c4 10             	add    $0x10,%esp
		return r;
  801449:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 23                	js     801472 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80144f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801455:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801458:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80145a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80145d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801464:	83 ec 0c             	sub    $0xc,%esp
  801467:	50                   	push   %eax
  801468:	e8 24 f3 ff ff       	call   800791 <fd2num>
  80146d:	89 c2                	mov    %eax,%edx
  80146f:	83 c4 10             	add    $0x10,%esp
}
  801472:	89 d0                	mov    %edx,%eax
  801474:	c9                   	leave  
  801475:	c3                   	ret    

00801476 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	56                   	push   %esi
  80147a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80147b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80147e:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801484:	e8 ba f0 ff ff       	call   800543 <sys_getenvid>
  801489:	83 ec 0c             	sub    $0xc,%esp
  80148c:	ff 75 0c             	pushl  0xc(%ebp)
  80148f:	ff 75 08             	pushl  0x8(%ebp)
  801492:	56                   	push   %esi
  801493:	50                   	push   %eax
  801494:	68 c8 1f 80 00       	push   $0x801fc8
  801499:	e8 b1 00 00 00       	call   80154f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80149e:	83 c4 18             	add    $0x18,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	ff 75 10             	pushl  0x10(%ebp)
  8014a5:	e8 54 00 00 00       	call   8014fe <vcprintf>
	cprintf("\n");
  8014aa:	c7 04 24 17 1f 80 00 	movl   $0x801f17,(%esp)
  8014b1:	e8 99 00 00 00       	call   80154f <cprintf>
  8014b6:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014b9:	cc                   	int3   
  8014ba:	eb fd                	jmp    8014b9 <_panic+0x43>

008014bc <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	53                   	push   %ebx
  8014c0:	83 ec 04             	sub    $0x4,%esp
  8014c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8014c6:	8b 13                	mov    (%ebx),%edx
  8014c8:	8d 42 01             	lea    0x1(%edx),%eax
  8014cb:	89 03                	mov    %eax,(%ebx)
  8014cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014d0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8014d4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8014d9:	75 1a                	jne    8014f5 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8014db:	83 ec 08             	sub    $0x8,%esp
  8014de:	68 ff 00 00 00       	push   $0xff
  8014e3:	8d 43 08             	lea    0x8(%ebx),%eax
  8014e6:	50                   	push   %eax
  8014e7:	e8 d9 ef ff ff       	call   8004c5 <sys_cputs>
		b->idx = 0;
  8014ec:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8014f2:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8014f5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8014f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014fc:	c9                   	leave  
  8014fd:	c3                   	ret    

008014fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801507:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80150e:	00 00 00 
	b.cnt = 0;
  801511:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801518:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80151b:	ff 75 0c             	pushl  0xc(%ebp)
  80151e:	ff 75 08             	pushl  0x8(%ebp)
  801521:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801527:	50                   	push   %eax
  801528:	68 bc 14 80 00       	push   $0x8014bc
  80152d:	e8 4f 01 00 00       	call   801681 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801532:	83 c4 08             	add    $0x8,%esp
  801535:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80153b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801541:	50                   	push   %eax
  801542:	e8 7e ef ff ff       	call   8004c5 <sys_cputs>

	return b.cnt;
}
  801547:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    

0080154f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801555:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801558:	50                   	push   %eax
  801559:	ff 75 08             	pushl  0x8(%ebp)
  80155c:	e8 9d ff ff ff       	call   8014fe <vcprintf>
	va_end(ap);

	return cnt;
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	57                   	push   %edi
  801567:	56                   	push   %esi
  801568:	53                   	push   %ebx
  801569:	83 ec 1c             	sub    $0x1c,%esp
  80156c:	89 c7                	mov    %eax,%edi
  80156e:	89 d6                	mov    %edx,%esi
  801570:	8b 45 08             	mov    0x8(%ebp),%eax
  801573:	8b 55 0c             	mov    0xc(%ebp),%edx
  801576:	89 d1                	mov    %edx,%ecx
  801578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80157e:	8b 45 10             	mov    0x10(%ebp),%eax
  801581:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801584:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801587:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80158e:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801591:	72 05                	jb     801598 <printnum+0x35>
  801593:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801596:	77 3e                	ja     8015d6 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801598:	83 ec 0c             	sub    $0xc,%esp
  80159b:	ff 75 18             	pushl  0x18(%ebp)
  80159e:	83 eb 01             	sub    $0x1,%ebx
  8015a1:	53                   	push   %ebx
  8015a2:	50                   	push   %eax
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015a9:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ac:	ff 75 dc             	pushl  -0x24(%ebp)
  8015af:	ff 75 d8             	pushl  -0x28(%ebp)
  8015b2:	e8 19 06 00 00       	call   801bd0 <__udivdi3>
  8015b7:	83 c4 18             	add    $0x18,%esp
  8015ba:	52                   	push   %edx
  8015bb:	50                   	push   %eax
  8015bc:	89 f2                	mov    %esi,%edx
  8015be:	89 f8                	mov    %edi,%eax
  8015c0:	e8 9e ff ff ff       	call   801563 <printnum>
  8015c5:	83 c4 20             	add    $0x20,%esp
  8015c8:	eb 13                	jmp    8015dd <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	56                   	push   %esi
  8015ce:	ff 75 18             	pushl  0x18(%ebp)
  8015d1:	ff d7                	call   *%edi
  8015d3:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8015d6:	83 eb 01             	sub    $0x1,%ebx
  8015d9:	85 db                	test   %ebx,%ebx
  8015db:	7f ed                	jg     8015ca <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	56                   	push   %esi
  8015e1:	83 ec 04             	sub    $0x4,%esp
  8015e4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8015ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8015f0:	e8 0b 07 00 00       	call   801d00 <__umoddi3>
  8015f5:	83 c4 14             	add    $0x14,%esp
  8015f8:	0f be 80 eb 1f 80 00 	movsbl 0x801feb(%eax),%eax
  8015ff:	50                   	push   %eax
  801600:	ff d7                	call   *%edi
  801602:	83 c4 10             	add    $0x10,%esp
}
  801605:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    

0080160d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80160d:	55                   	push   %ebp
  80160e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801610:	83 fa 01             	cmp    $0x1,%edx
  801613:	7e 0e                	jle    801623 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801615:	8b 10                	mov    (%eax),%edx
  801617:	8d 4a 08             	lea    0x8(%edx),%ecx
  80161a:	89 08                	mov    %ecx,(%eax)
  80161c:	8b 02                	mov    (%edx),%eax
  80161e:	8b 52 04             	mov    0x4(%edx),%edx
  801621:	eb 22                	jmp    801645 <getuint+0x38>
	else if (lflag)
  801623:	85 d2                	test   %edx,%edx
  801625:	74 10                	je     801637 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801627:	8b 10                	mov    (%eax),%edx
  801629:	8d 4a 04             	lea    0x4(%edx),%ecx
  80162c:	89 08                	mov    %ecx,(%eax)
  80162e:	8b 02                	mov    (%edx),%eax
  801630:	ba 00 00 00 00       	mov    $0x0,%edx
  801635:	eb 0e                	jmp    801645 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801637:	8b 10                	mov    (%eax),%edx
  801639:	8d 4a 04             	lea    0x4(%edx),%ecx
  80163c:	89 08                	mov    %ecx,(%eax)
  80163e:	8b 02                	mov    (%edx),%eax
  801640:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80164d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801651:	8b 10                	mov    (%eax),%edx
  801653:	3b 50 04             	cmp    0x4(%eax),%edx
  801656:	73 0a                	jae    801662 <sprintputch+0x1b>
		*b->buf++ = ch;
  801658:	8d 4a 01             	lea    0x1(%edx),%ecx
  80165b:	89 08                	mov    %ecx,(%eax)
  80165d:	8b 45 08             	mov    0x8(%ebp),%eax
  801660:	88 02                	mov    %al,(%edx)
}
  801662:	5d                   	pop    %ebp
  801663:	c3                   	ret    

00801664 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801664:	55                   	push   %ebp
  801665:	89 e5                	mov    %esp,%ebp
  801667:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80166a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80166d:	50                   	push   %eax
  80166e:	ff 75 10             	pushl  0x10(%ebp)
  801671:	ff 75 0c             	pushl  0xc(%ebp)
  801674:	ff 75 08             	pushl  0x8(%ebp)
  801677:	e8 05 00 00 00       	call   801681 <vprintfmt>
	va_end(ap);
  80167c:	83 c4 10             	add    $0x10,%esp
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	57                   	push   %edi
  801685:	56                   	push   %esi
  801686:	53                   	push   %ebx
  801687:	83 ec 2c             	sub    $0x2c,%esp
  80168a:	8b 75 08             	mov    0x8(%ebp),%esi
  80168d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801690:	8b 7d 10             	mov    0x10(%ebp),%edi
  801693:	eb 12                	jmp    8016a7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801695:	85 c0                	test   %eax,%eax
  801697:	0f 84 8d 03 00 00    	je     801a2a <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  80169d:	83 ec 08             	sub    $0x8,%esp
  8016a0:	53                   	push   %ebx
  8016a1:	50                   	push   %eax
  8016a2:	ff d6                	call   *%esi
  8016a4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016a7:	83 c7 01             	add    $0x1,%edi
  8016aa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ae:	83 f8 25             	cmp    $0x25,%eax
  8016b1:	75 e2                	jne    801695 <vprintfmt+0x14>
  8016b3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016b7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016be:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016c5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8016cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d1:	eb 07                	jmp    8016da <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8016d6:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8016da:	8d 47 01             	lea    0x1(%edi),%eax
  8016dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e0:	0f b6 07             	movzbl (%edi),%eax
  8016e3:	0f b6 c8             	movzbl %al,%ecx
  8016e6:	83 e8 23             	sub    $0x23,%eax
  8016e9:	3c 55                	cmp    $0x55,%al
  8016eb:	0f 87 1e 03 00 00    	ja     801a0f <vprintfmt+0x38e>
  8016f1:	0f b6 c0             	movzbl %al,%eax
  8016f4:	ff 24 85 40 21 80 00 	jmp    *0x802140(,%eax,4)
  8016fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8016fe:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801702:	eb d6                	jmp    8016da <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801704:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801707:	b8 00 00 00 00       	mov    $0x0,%eax
  80170c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80170f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801712:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801716:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801719:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80171c:	83 fa 09             	cmp    $0x9,%edx
  80171f:	77 38                	ja     801759 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801721:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801724:	eb e9                	jmp    80170f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801726:	8b 45 14             	mov    0x14(%ebp),%eax
  801729:	8d 48 04             	lea    0x4(%eax),%ecx
  80172c:	89 4d 14             	mov    %ecx,0x14(%ebp)
  80172f:	8b 00                	mov    (%eax),%eax
  801731:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801737:	eb 26                	jmp    80175f <vprintfmt+0xde>
  801739:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80173c:	89 c8                	mov    %ecx,%eax
  80173e:	c1 f8 1f             	sar    $0x1f,%eax
  801741:	f7 d0                	not    %eax
  801743:	21 c1                	and    %eax,%ecx
  801745:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801748:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80174b:	eb 8d                	jmp    8016da <vprintfmt+0x59>
  80174d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801750:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801757:	eb 81                	jmp    8016da <vprintfmt+0x59>
  801759:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80175c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80175f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801763:	0f 89 71 ff ff ff    	jns    8016da <vprintfmt+0x59>
				width = precision, precision = -1;
  801769:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80176c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80176f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801776:	e9 5f ff ff ff       	jmp    8016da <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80177b:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80177e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801781:	e9 54 ff ff ff       	jmp    8016da <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801786:	8b 45 14             	mov    0x14(%ebp),%eax
  801789:	8d 50 04             	lea    0x4(%eax),%edx
  80178c:	89 55 14             	mov    %edx,0x14(%ebp)
  80178f:	83 ec 08             	sub    $0x8,%esp
  801792:	53                   	push   %ebx
  801793:	ff 30                	pushl  (%eax)
  801795:	ff d6                	call   *%esi
			break;
  801797:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80179a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80179d:	e9 05 ff ff ff       	jmp    8016a7 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8017a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a5:	8d 50 04             	lea    0x4(%eax),%edx
  8017a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8017ab:	8b 00                	mov    (%eax),%eax
  8017ad:	99                   	cltd   
  8017ae:	31 d0                	xor    %edx,%eax
  8017b0:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017b2:	83 f8 0f             	cmp    $0xf,%eax
  8017b5:	7f 0b                	jg     8017c2 <vprintfmt+0x141>
  8017b7:	8b 14 85 c0 22 80 00 	mov    0x8022c0(,%eax,4),%edx
  8017be:	85 d2                	test   %edx,%edx
  8017c0:	75 18                	jne    8017da <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8017c2:	50                   	push   %eax
  8017c3:	68 03 20 80 00       	push   $0x802003
  8017c8:	53                   	push   %ebx
  8017c9:	56                   	push   %esi
  8017ca:	e8 95 fe ff ff       	call   801664 <printfmt>
  8017cf:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8017d5:	e9 cd fe ff ff       	jmp    8016a7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8017da:	52                   	push   %edx
  8017db:	68 61 1f 80 00       	push   $0x801f61
  8017e0:	53                   	push   %ebx
  8017e1:	56                   	push   %esi
  8017e2:	e8 7d fe ff ff       	call   801664 <printfmt>
  8017e7:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8017ed:	e9 b5 fe ff ff       	jmp    8016a7 <vprintfmt+0x26>
  8017f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8017f5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8017f8:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8017fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fe:	8d 50 04             	lea    0x4(%eax),%edx
  801801:	89 55 14             	mov    %edx,0x14(%ebp)
  801804:	8b 38                	mov    (%eax),%edi
  801806:	85 ff                	test   %edi,%edi
  801808:	75 05                	jne    80180f <vprintfmt+0x18e>
				p = "(null)";
  80180a:	bf fc 1f 80 00       	mov    $0x801ffc,%edi
			if (width > 0 && padc != '-')
  80180f:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801813:	0f 84 91 00 00 00    	je     8018aa <vprintfmt+0x229>
  801819:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80181d:	0f 8e 95 00 00 00    	jle    8018b8 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	51                   	push   %ecx
  801827:	57                   	push   %edi
  801828:	e8 29 e9 ff ff       	call   800156 <strnlen>
  80182d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801830:	29 c1                	sub    %eax,%ecx
  801832:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801835:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801838:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80183c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80183f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801842:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801844:	eb 0f                	jmp    801855 <vprintfmt+0x1d4>
					putch(padc, putdat);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	53                   	push   %ebx
  80184a:	ff 75 e0             	pushl  -0x20(%ebp)
  80184d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80184f:	83 ef 01             	sub    $0x1,%edi
  801852:	83 c4 10             	add    $0x10,%esp
  801855:	85 ff                	test   %edi,%edi
  801857:	7f ed                	jg     801846 <vprintfmt+0x1c5>
  801859:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80185c:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80185f:	89 c8                	mov    %ecx,%eax
  801861:	c1 f8 1f             	sar    $0x1f,%eax
  801864:	f7 d0                	not    %eax
  801866:	21 c8                	and    %ecx,%eax
  801868:	29 c1                	sub    %eax,%ecx
  80186a:	89 75 08             	mov    %esi,0x8(%ebp)
  80186d:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801870:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801873:	89 cb                	mov    %ecx,%ebx
  801875:	eb 4d                	jmp    8018c4 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801877:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80187b:	74 1b                	je     801898 <vprintfmt+0x217>
  80187d:	0f be c0             	movsbl %al,%eax
  801880:	83 e8 20             	sub    $0x20,%eax
  801883:	83 f8 5e             	cmp    $0x5e,%eax
  801886:	76 10                	jbe    801898 <vprintfmt+0x217>
					putch('?', putdat);
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	ff 75 0c             	pushl  0xc(%ebp)
  80188e:	6a 3f                	push   $0x3f
  801890:	ff 55 08             	call   *0x8(%ebp)
  801893:	83 c4 10             	add    $0x10,%esp
  801896:	eb 0d                	jmp    8018a5 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  801898:	83 ec 08             	sub    $0x8,%esp
  80189b:	ff 75 0c             	pushl  0xc(%ebp)
  80189e:	52                   	push   %edx
  80189f:	ff 55 08             	call   *0x8(%ebp)
  8018a2:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018a5:	83 eb 01             	sub    $0x1,%ebx
  8018a8:	eb 1a                	jmp    8018c4 <vprintfmt+0x243>
  8018aa:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ad:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018b0:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018b3:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018b6:	eb 0c                	jmp    8018c4 <vprintfmt+0x243>
  8018b8:	89 75 08             	mov    %esi,0x8(%ebp)
  8018bb:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018be:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018c4:	83 c7 01             	add    $0x1,%edi
  8018c7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018cb:	0f be d0             	movsbl %al,%edx
  8018ce:	85 d2                	test   %edx,%edx
  8018d0:	74 23                	je     8018f5 <vprintfmt+0x274>
  8018d2:	85 f6                	test   %esi,%esi
  8018d4:	78 a1                	js     801877 <vprintfmt+0x1f6>
  8018d6:	83 ee 01             	sub    $0x1,%esi
  8018d9:	79 9c                	jns    801877 <vprintfmt+0x1f6>
  8018db:	89 df                	mov    %ebx,%edi
  8018dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8018e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018e3:	eb 18                	jmp    8018fd <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8018e5:	83 ec 08             	sub    $0x8,%esp
  8018e8:	53                   	push   %ebx
  8018e9:	6a 20                	push   $0x20
  8018eb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8018ed:	83 ef 01             	sub    $0x1,%edi
  8018f0:	83 c4 10             	add    $0x10,%esp
  8018f3:	eb 08                	jmp    8018fd <vprintfmt+0x27c>
  8018f5:	89 df                	mov    %ebx,%edi
  8018f7:	8b 75 08             	mov    0x8(%ebp),%esi
  8018fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8018fd:	85 ff                	test   %edi,%edi
  8018ff:	7f e4                	jg     8018e5 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801901:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801904:	e9 9e fd ff ff       	jmp    8016a7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801909:	83 fa 01             	cmp    $0x1,%edx
  80190c:	7e 16                	jle    801924 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  80190e:	8b 45 14             	mov    0x14(%ebp),%eax
  801911:	8d 50 08             	lea    0x8(%eax),%edx
  801914:	89 55 14             	mov    %edx,0x14(%ebp)
  801917:	8b 50 04             	mov    0x4(%eax),%edx
  80191a:	8b 00                	mov    (%eax),%eax
  80191c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80191f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801922:	eb 32                	jmp    801956 <vprintfmt+0x2d5>
	else if (lflag)
  801924:	85 d2                	test   %edx,%edx
  801926:	74 18                	je     801940 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  801928:	8b 45 14             	mov    0x14(%ebp),%eax
  80192b:	8d 50 04             	lea    0x4(%eax),%edx
  80192e:	89 55 14             	mov    %edx,0x14(%ebp)
  801931:	8b 00                	mov    (%eax),%eax
  801933:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801936:	89 c1                	mov    %eax,%ecx
  801938:	c1 f9 1f             	sar    $0x1f,%ecx
  80193b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80193e:	eb 16                	jmp    801956 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801940:	8b 45 14             	mov    0x14(%ebp),%eax
  801943:	8d 50 04             	lea    0x4(%eax),%edx
  801946:	89 55 14             	mov    %edx,0x14(%ebp)
  801949:	8b 00                	mov    (%eax),%eax
  80194b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80194e:	89 c1                	mov    %eax,%ecx
  801950:	c1 f9 1f             	sar    $0x1f,%ecx
  801953:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801956:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801959:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80195c:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801961:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801965:	79 74                	jns    8019db <vprintfmt+0x35a>
				putch('-', putdat);
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	53                   	push   %ebx
  80196b:	6a 2d                	push   $0x2d
  80196d:	ff d6                	call   *%esi
				num = -(long long) num;
  80196f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801972:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801975:	f7 d8                	neg    %eax
  801977:	83 d2 00             	adc    $0x0,%edx
  80197a:	f7 da                	neg    %edx
  80197c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80197f:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801984:	eb 55                	jmp    8019db <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801986:	8d 45 14             	lea    0x14(%ebp),%eax
  801989:	e8 7f fc ff ff       	call   80160d <getuint>
			base = 10;
  80198e:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801993:	eb 46                	jmp    8019db <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801995:	8d 45 14             	lea    0x14(%ebp),%eax
  801998:	e8 70 fc ff ff       	call   80160d <getuint>
			base = 8;
  80199d:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8019a2:	eb 37                	jmp    8019db <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	53                   	push   %ebx
  8019a8:	6a 30                	push   $0x30
  8019aa:	ff d6                	call   *%esi
			putch('x', putdat);
  8019ac:	83 c4 08             	add    $0x8,%esp
  8019af:	53                   	push   %ebx
  8019b0:	6a 78                	push   $0x78
  8019b2:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8019b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b7:	8d 50 04             	lea    0x4(%eax),%edx
  8019ba:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8019bd:	8b 00                	mov    (%eax),%eax
  8019bf:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8019c4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8019c7:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8019cc:	eb 0d                	jmp    8019db <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8019ce:	8d 45 14             	lea    0x14(%ebp),%eax
  8019d1:	e8 37 fc ff ff       	call   80160d <getuint>
			base = 16;
  8019d6:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  8019db:	83 ec 0c             	sub    $0xc,%esp
  8019de:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8019e2:	57                   	push   %edi
  8019e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8019e6:	51                   	push   %ecx
  8019e7:	52                   	push   %edx
  8019e8:	50                   	push   %eax
  8019e9:	89 da                	mov    %ebx,%edx
  8019eb:	89 f0                	mov    %esi,%eax
  8019ed:	e8 71 fb ff ff       	call   801563 <printnum>
			break;
  8019f2:	83 c4 20             	add    $0x20,%esp
  8019f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8019f8:	e9 aa fc ff ff       	jmp    8016a7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8019fd:	83 ec 08             	sub    $0x8,%esp
  801a00:	53                   	push   %ebx
  801a01:	51                   	push   %ecx
  801a02:	ff d6                	call   *%esi
			break;
  801a04:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801a0a:	e9 98 fc ff ff       	jmp    8016a7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801a0f:	83 ec 08             	sub    $0x8,%esp
  801a12:	53                   	push   %ebx
  801a13:	6a 25                	push   $0x25
  801a15:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	eb 03                	jmp    801a1f <vprintfmt+0x39e>
  801a1c:	83 ef 01             	sub    $0x1,%edi
  801a1f:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801a23:	75 f7                	jne    801a1c <vprintfmt+0x39b>
  801a25:	e9 7d fc ff ff       	jmp    8016a7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801a2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a2d:	5b                   	pop    %ebx
  801a2e:	5e                   	pop    %esi
  801a2f:	5f                   	pop    %edi
  801a30:	5d                   	pop    %ebp
  801a31:	c3                   	ret    

00801a32 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 18             	sub    $0x18,%esp
  801a38:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801a3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801a41:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801a45:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801a48:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	74 26                	je     801a79 <vsnprintf+0x47>
  801a53:	85 d2                	test   %edx,%edx
  801a55:	7e 22                	jle    801a79 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801a57:	ff 75 14             	pushl  0x14(%ebp)
  801a5a:	ff 75 10             	pushl  0x10(%ebp)
  801a5d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801a60:	50                   	push   %eax
  801a61:	68 47 16 80 00       	push   $0x801647
  801a66:	e8 16 fc ff ff       	call   801681 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801a6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801a6e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801a71:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a74:	83 c4 10             	add    $0x10,%esp
  801a77:	eb 05                	jmp    801a7e <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801a79:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801a86:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801a89:	50                   	push   %eax
  801a8a:	ff 75 10             	pushl  0x10(%ebp)
  801a8d:	ff 75 0c             	pushl  0xc(%ebp)
  801a90:	ff 75 08             	pushl  0x8(%ebp)
  801a93:	e8 9a ff ff ff       	call   801a32 <vsnprintf>
	va_end(ap);

	return rc;
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	56                   	push   %esi
  801a9e:	53                   	push   %ebx
  801a9f:	8b 75 08             	mov    0x8(%ebp),%esi
  801aa2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801aa8:	85 f6                	test   %esi,%esi
  801aaa:	74 06                	je     801ab2 <ipc_recv+0x18>
  801aac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801ab2:	85 db                	test   %ebx,%ebx
  801ab4:	74 06                	je     801abc <ipc_recv+0x22>
  801ab6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801abc:	83 f8 01             	cmp    $0x1,%eax
  801abf:	19 d2                	sbb    %edx,%edx
  801ac1:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801ac3:	83 ec 0c             	sub    $0xc,%esp
  801ac6:	50                   	push   %eax
  801ac7:	e8 65 ec ff ff       	call   800731 <sys_ipc_recv>
  801acc:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	85 d2                	test   %edx,%edx
  801ad3:	75 24                	jne    801af9 <ipc_recv+0x5f>
	if (from_env_store)
  801ad5:	85 f6                	test   %esi,%esi
  801ad7:	74 0a                	je     801ae3 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801ad9:	a1 04 40 80 00       	mov    0x804004,%eax
  801ade:	8b 40 70             	mov    0x70(%eax),%eax
  801ae1:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801ae3:	85 db                	test   %ebx,%ebx
  801ae5:	74 0a                	je     801af1 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801ae7:	a1 04 40 80 00       	mov    0x804004,%eax
  801aec:	8b 40 74             	mov    0x74(%eax),%eax
  801aef:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801af1:	a1 04 40 80 00       	mov    0x804004,%eax
  801af6:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801af9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afc:	5b                   	pop    %ebx
  801afd:	5e                   	pop    %esi
  801afe:	5d                   	pop    %ebp
  801aff:	c3                   	ret    

00801b00 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	57                   	push   %edi
  801b04:	56                   	push   %esi
  801b05:	53                   	push   %ebx
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801b12:	83 fb 01             	cmp    $0x1,%ebx
  801b15:	19 c0                	sbb    %eax,%eax
  801b17:	09 c3                	or     %eax,%ebx
  801b19:	eb 1c                	jmp    801b37 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801b1b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b1e:	74 12                	je     801b32 <ipc_send+0x32>
  801b20:	50                   	push   %eax
  801b21:	68 20 23 80 00       	push   $0x802320
  801b26:	6a 36                	push   $0x36
  801b28:	68 37 23 80 00       	push   $0x802337
  801b2d:	e8 44 f9 ff ff       	call   801476 <_panic>
		sys_yield();
  801b32:	e8 2b ea ff ff       	call   800562 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801b37:	ff 75 14             	pushl  0x14(%ebp)
  801b3a:	53                   	push   %ebx
  801b3b:	56                   	push   %esi
  801b3c:	57                   	push   %edi
  801b3d:	e8 cc eb ff ff       	call   80070e <sys_ipc_try_send>
		if (ret == 0) break;
  801b42:	83 c4 10             	add    $0x10,%esp
  801b45:	85 c0                	test   %eax,%eax
  801b47:	75 d2                	jne    801b1b <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5e                   	pop    %esi
  801b4e:	5f                   	pop    %edi
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    

00801b51 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b51:	55                   	push   %ebp
  801b52:	89 e5                	mov    %esp,%ebp
  801b54:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b57:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b5c:	6b d0 78             	imul   $0x78,%eax,%edx
  801b5f:	83 c2 50             	add    $0x50,%edx
  801b62:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801b68:	39 ca                	cmp    %ecx,%edx
  801b6a:	75 0d                	jne    801b79 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b6c:	6b c0 78             	imul   $0x78,%eax,%eax
  801b6f:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801b74:	8b 40 08             	mov    0x8(%eax),%eax
  801b77:	eb 0e                	jmp    801b87 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b79:	83 c0 01             	add    $0x1,%eax
  801b7c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b81:	75 d9                	jne    801b5c <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b83:	66 b8 00 00          	mov    $0x0,%ax
}
  801b87:	5d                   	pop    %ebp
  801b88:	c3                   	ret    

00801b89 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b89:	55                   	push   %ebp
  801b8a:	89 e5                	mov    %esp,%ebp
  801b8c:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8f:	89 d0                	mov    %edx,%eax
  801b91:	c1 e8 16             	shr    $0x16,%eax
  801b94:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b9b:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ba0:	f6 c1 01             	test   $0x1,%cl
  801ba3:	74 1d                	je     801bc2 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801ba5:	c1 ea 0c             	shr    $0xc,%edx
  801ba8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801baf:	f6 c2 01             	test   $0x1,%dl
  801bb2:	74 0e                	je     801bc2 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb4:	c1 ea 0c             	shr    $0xc,%edx
  801bb7:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bbe:	ef 
  801bbf:	0f b7 c0             	movzwl %ax,%eax
}
  801bc2:	5d                   	pop    %ebp
  801bc3:	c3                   	ret    
  801bc4:	66 90                	xchg   %ax,%ax
  801bc6:	66 90                	xchg   %ax,%ax
  801bc8:	66 90                	xchg   %ax,%ax
  801bca:	66 90                	xchg   %ax,%ax
  801bcc:	66 90                	xchg   %ax,%ax
  801bce:	66 90                	xchg   %ax,%ax

00801bd0 <__udivdi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	57                   	push   %edi
  801bd2:	56                   	push   %esi
  801bd3:	83 ec 10             	sub    $0x10,%esp
  801bd6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801bda:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801bde:	8b 74 24 24          	mov    0x24(%esp),%esi
  801be2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801be6:	85 d2                	test   %edx,%edx
  801be8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801bec:	89 34 24             	mov    %esi,(%esp)
  801bef:	89 c8                	mov    %ecx,%eax
  801bf1:	75 35                	jne    801c28 <__udivdi3+0x58>
  801bf3:	39 f1                	cmp    %esi,%ecx
  801bf5:	0f 87 bd 00 00 00    	ja     801cb8 <__udivdi3+0xe8>
  801bfb:	85 c9                	test   %ecx,%ecx
  801bfd:	89 cd                	mov    %ecx,%ebp
  801bff:	75 0b                	jne    801c0c <__udivdi3+0x3c>
  801c01:	b8 01 00 00 00       	mov    $0x1,%eax
  801c06:	31 d2                	xor    %edx,%edx
  801c08:	f7 f1                	div    %ecx
  801c0a:	89 c5                	mov    %eax,%ebp
  801c0c:	89 f0                	mov    %esi,%eax
  801c0e:	31 d2                	xor    %edx,%edx
  801c10:	f7 f5                	div    %ebp
  801c12:	89 c6                	mov    %eax,%esi
  801c14:	89 f8                	mov    %edi,%eax
  801c16:	f7 f5                	div    %ebp
  801c18:	89 f2                	mov    %esi,%edx
  801c1a:	83 c4 10             	add    $0x10,%esp
  801c1d:	5e                   	pop    %esi
  801c1e:	5f                   	pop    %edi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    
  801c21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c28:	3b 14 24             	cmp    (%esp),%edx
  801c2b:	77 7b                	ja     801ca8 <__udivdi3+0xd8>
  801c2d:	0f bd f2             	bsr    %edx,%esi
  801c30:	83 f6 1f             	xor    $0x1f,%esi
  801c33:	0f 84 97 00 00 00    	je     801cd0 <__udivdi3+0x100>
  801c39:	bd 20 00 00 00       	mov    $0x20,%ebp
  801c3e:	89 d7                	mov    %edx,%edi
  801c40:	89 f1                	mov    %esi,%ecx
  801c42:	29 f5                	sub    %esi,%ebp
  801c44:	d3 e7                	shl    %cl,%edi
  801c46:	89 c2                	mov    %eax,%edx
  801c48:	89 e9                	mov    %ebp,%ecx
  801c4a:	d3 ea                	shr    %cl,%edx
  801c4c:	89 f1                	mov    %esi,%ecx
  801c4e:	09 fa                	or     %edi,%edx
  801c50:	8b 3c 24             	mov    (%esp),%edi
  801c53:	d3 e0                	shl    %cl,%eax
  801c55:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c59:	89 e9                	mov    %ebp,%ecx
  801c5b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c5f:	8b 44 24 04          	mov    0x4(%esp),%eax
  801c63:	89 fa                	mov    %edi,%edx
  801c65:	d3 ea                	shr    %cl,%edx
  801c67:	89 f1                	mov    %esi,%ecx
  801c69:	d3 e7                	shl    %cl,%edi
  801c6b:	89 e9                	mov    %ebp,%ecx
  801c6d:	d3 e8                	shr    %cl,%eax
  801c6f:	09 c7                	or     %eax,%edi
  801c71:	89 f8                	mov    %edi,%eax
  801c73:	f7 74 24 08          	divl   0x8(%esp)
  801c77:	89 d5                	mov    %edx,%ebp
  801c79:	89 c7                	mov    %eax,%edi
  801c7b:	f7 64 24 0c          	mull   0xc(%esp)
  801c7f:	39 d5                	cmp    %edx,%ebp
  801c81:	89 14 24             	mov    %edx,(%esp)
  801c84:	72 11                	jb     801c97 <__udivdi3+0xc7>
  801c86:	8b 54 24 04          	mov    0x4(%esp),%edx
  801c8a:	89 f1                	mov    %esi,%ecx
  801c8c:	d3 e2                	shl    %cl,%edx
  801c8e:	39 c2                	cmp    %eax,%edx
  801c90:	73 5e                	jae    801cf0 <__udivdi3+0x120>
  801c92:	3b 2c 24             	cmp    (%esp),%ebp
  801c95:	75 59                	jne    801cf0 <__udivdi3+0x120>
  801c97:	8d 47 ff             	lea    -0x1(%edi),%eax
  801c9a:	31 f6                	xor    %esi,%esi
  801c9c:	89 f2                	mov    %esi,%edx
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	31 f6                	xor    %esi,%esi
  801caa:	31 c0                	xor    %eax,%eax
  801cac:	89 f2                	mov    %esi,%edx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	31 f6                	xor    %esi,%esi
  801cbc:	89 f8                	mov    %edi,%eax
  801cbe:	f7 f1                	div    %ecx
  801cc0:	89 f2                	mov    %esi,%edx
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	5e                   	pop    %esi
  801cc6:	5f                   	pop    %edi
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801cd4:	76 0b                	jbe    801ce1 <__udivdi3+0x111>
  801cd6:	31 c0                	xor    %eax,%eax
  801cd8:	3b 14 24             	cmp    (%esp),%edx
  801cdb:	0f 83 37 ff ff ff    	jae    801c18 <__udivdi3+0x48>
  801ce1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ce6:	e9 2d ff ff ff       	jmp    801c18 <__udivdi3+0x48>
  801ceb:	90                   	nop
  801cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf0:	89 f8                	mov    %edi,%eax
  801cf2:	31 f6                	xor    %esi,%esi
  801cf4:	e9 1f ff ff ff       	jmp    801c18 <__udivdi3+0x48>
  801cf9:	66 90                	xchg   %ax,%ax
  801cfb:	66 90                	xchg   %ax,%ax
  801cfd:	66 90                	xchg   %ax,%ax
  801cff:	90                   	nop

00801d00 <__umoddi3>:
  801d00:	55                   	push   %ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	83 ec 20             	sub    $0x20,%esp
  801d06:	8b 44 24 34          	mov    0x34(%esp),%eax
  801d0a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d0e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d12:	89 c6                	mov    %eax,%esi
  801d14:	89 44 24 10          	mov    %eax,0x10(%esp)
  801d18:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d1c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801d20:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d24:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801d28:	89 74 24 18          	mov    %esi,0x18(%esp)
  801d2c:	85 c0                	test   %eax,%eax
  801d2e:	89 c2                	mov    %eax,%edx
  801d30:	75 1e                	jne    801d50 <__umoddi3+0x50>
  801d32:	39 f7                	cmp    %esi,%edi
  801d34:	76 52                	jbe    801d88 <__umoddi3+0x88>
  801d36:	89 c8                	mov    %ecx,%eax
  801d38:	89 f2                	mov    %esi,%edx
  801d3a:	f7 f7                	div    %edi
  801d3c:	89 d0                	mov    %edx,%eax
  801d3e:	31 d2                	xor    %edx,%edx
  801d40:	83 c4 20             	add    $0x20,%esp
  801d43:	5e                   	pop    %esi
  801d44:	5f                   	pop    %edi
  801d45:	5d                   	pop    %ebp
  801d46:	c3                   	ret    
  801d47:	89 f6                	mov    %esi,%esi
  801d49:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801d50:	39 f0                	cmp    %esi,%eax
  801d52:	77 5c                	ja     801db0 <__umoddi3+0xb0>
  801d54:	0f bd e8             	bsr    %eax,%ebp
  801d57:	83 f5 1f             	xor    $0x1f,%ebp
  801d5a:	75 64                	jne    801dc0 <__umoddi3+0xc0>
  801d5c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801d60:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801d64:	0f 86 f6 00 00 00    	jbe    801e60 <__umoddi3+0x160>
  801d6a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801d6e:	0f 82 ec 00 00 00    	jb     801e60 <__umoddi3+0x160>
  801d74:	8b 44 24 14          	mov    0x14(%esp),%eax
  801d78:	8b 54 24 18          	mov    0x18(%esp),%edx
  801d7c:	83 c4 20             	add    $0x20,%esp
  801d7f:	5e                   	pop    %esi
  801d80:	5f                   	pop    %edi
  801d81:	5d                   	pop    %ebp
  801d82:	c3                   	ret    
  801d83:	90                   	nop
  801d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d88:	85 ff                	test   %edi,%edi
  801d8a:	89 fd                	mov    %edi,%ebp
  801d8c:	75 0b                	jne    801d99 <__umoddi3+0x99>
  801d8e:	b8 01 00 00 00       	mov    $0x1,%eax
  801d93:	31 d2                	xor    %edx,%edx
  801d95:	f7 f7                	div    %edi
  801d97:	89 c5                	mov    %eax,%ebp
  801d99:	8b 44 24 10          	mov    0x10(%esp),%eax
  801d9d:	31 d2                	xor    %edx,%edx
  801d9f:	f7 f5                	div    %ebp
  801da1:	89 c8                	mov    %ecx,%eax
  801da3:	f7 f5                	div    %ebp
  801da5:	eb 95                	jmp    801d3c <__umoddi3+0x3c>
  801da7:	89 f6                	mov    %esi,%esi
  801da9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801db0:	89 c8                	mov    %ecx,%eax
  801db2:	89 f2                	mov    %esi,%edx
  801db4:	83 c4 20             	add    $0x20,%esp
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    
  801dbb:	90                   	nop
  801dbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801dc0:	b8 20 00 00 00       	mov    $0x20,%eax
  801dc5:	89 e9                	mov    %ebp,%ecx
  801dc7:	29 e8                	sub    %ebp,%eax
  801dc9:	d3 e2                	shl    %cl,%edx
  801dcb:	89 c7                	mov    %eax,%edi
  801dcd:	89 44 24 18          	mov    %eax,0x18(%esp)
  801dd1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801dd5:	89 f9                	mov    %edi,%ecx
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 c1                	mov    %eax,%ecx
  801ddb:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801ddf:	09 d1                	or     %edx,%ecx
  801de1:	89 fa                	mov    %edi,%edx
  801de3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801de7:	89 e9                	mov    %ebp,%ecx
  801de9:	d3 e0                	shl    %cl,%eax
  801deb:	89 f9                	mov    %edi,%ecx
  801ded:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801df1:	89 f0                	mov    %esi,%eax
  801df3:	d3 e8                	shr    %cl,%eax
  801df5:	89 e9                	mov    %ebp,%ecx
  801df7:	89 c7                	mov    %eax,%edi
  801df9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  801dfd:	d3 e6                	shl    %cl,%esi
  801dff:	89 d1                	mov    %edx,%ecx
  801e01:	89 fa                	mov    %edi,%edx
  801e03:	d3 e8                	shr    %cl,%eax
  801e05:	89 e9                	mov    %ebp,%ecx
  801e07:	09 f0                	or     %esi,%eax
  801e09:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  801e0d:	f7 74 24 10          	divl   0x10(%esp)
  801e11:	d3 e6                	shl    %cl,%esi
  801e13:	89 d1                	mov    %edx,%ecx
  801e15:	f7 64 24 0c          	mull   0xc(%esp)
  801e19:	39 d1                	cmp    %edx,%ecx
  801e1b:	89 74 24 14          	mov    %esi,0x14(%esp)
  801e1f:	89 d7                	mov    %edx,%edi
  801e21:	89 c6                	mov    %eax,%esi
  801e23:	72 0a                	jb     801e2f <__umoddi3+0x12f>
  801e25:	39 44 24 14          	cmp    %eax,0x14(%esp)
  801e29:	73 10                	jae    801e3b <__umoddi3+0x13b>
  801e2b:	39 d1                	cmp    %edx,%ecx
  801e2d:	75 0c                	jne    801e3b <__umoddi3+0x13b>
  801e2f:	89 d7                	mov    %edx,%edi
  801e31:	89 c6                	mov    %eax,%esi
  801e33:	2b 74 24 0c          	sub    0xc(%esp),%esi
  801e37:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  801e3b:	89 ca                	mov    %ecx,%edx
  801e3d:	89 e9                	mov    %ebp,%ecx
  801e3f:	8b 44 24 14          	mov    0x14(%esp),%eax
  801e43:	29 f0                	sub    %esi,%eax
  801e45:	19 fa                	sbb    %edi,%edx
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  801e4e:	89 d7                	mov    %edx,%edi
  801e50:	d3 e7                	shl    %cl,%edi
  801e52:	89 e9                	mov    %ebp,%ecx
  801e54:	09 f8                	or     %edi,%eax
  801e56:	d3 ea                	shr    %cl,%edx
  801e58:	83 c4 20             	add    $0x20,%esp
  801e5b:	5e                   	pop    %esi
  801e5c:	5f                   	pop    %edi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    
  801e5f:	90                   	nop
  801e60:	8b 74 24 10          	mov    0x10(%esp),%esi
  801e64:	29 f9                	sub    %edi,%ecx
  801e66:	19 c6                	sbb    %eax,%esi
  801e68:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801e6c:	89 74 24 18          	mov    %esi,0x18(%esp)
  801e70:	e9 ff fe ff ff       	jmp    801d74 <__umoddi3+0x74>
