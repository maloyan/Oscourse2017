
obj/user/sh:     file format elf32-i386


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
  80002c:	e8 86 09 00 00       	call   8009b7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800042:	85 db                	test   %ebx,%ebx
  800044:	75 2c                	jne    800072 <_gettoken+0x3f>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
  800046:	b8 00 00 00 00       	mov    $0x0,%eax
_gettoken(char *s, char **p1, char **p2)
{
	int t;

	if (s == 0) {
		if (debug > 1)
  80004b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800052:	0f 8e 40 01 00 00    	jle    800198 <_gettoken+0x165>
			cprintf("GETTOKEN NULL\n");
  800058:	83 ec 0c             	sub    $0xc,%esp
  80005b:	68 00 33 80 00       	push   $0x803300
  800060:	e8 8b 0a 00 00       	call   800af0 <cprintf>
  800065:	83 c4 10             	add    $0x10,%esp
		return 0;
  800068:	b8 00 00 00 00       	mov    $0x0,%eax
  80006d:	e9 26 01 00 00       	jmp    800198 <_gettoken+0x165>
	}

	if (debug > 1)
  800072:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800079:	7e 11                	jle    80008c <_gettoken+0x59>
		cprintf("GETTOKEN: %s\n", s);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	53                   	push   %ebx
  80007f:	68 0f 33 80 00       	push   $0x80330f
  800084:	e8 67 0a 00 00       	call   800af0 <cprintf>
  800089:	83 c4 10             	add    $0x10,%esp

	*p1 = 0;
  80008c:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800092:	8b 45 10             	mov    0x10(%ebp),%eax
  800095:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  80009b:	eb 07                	jmp    8000a4 <_gettoken+0x71>
		*s++ = 0;
  80009d:	83 c3 01             	add    $0x1,%ebx
  8000a0:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	0f be 03             	movsbl (%ebx),%eax
  8000aa:	50                   	push   %eax
  8000ab:	68 1d 33 80 00       	push   $0x80331d
  8000b0:	e8 c7 10 00 00       	call   80117c <strchr>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	85 c0                	test   %eax,%eax
  8000ba:	75 e1                	jne    80009d <_gettoken+0x6a>
  8000bc:	89 de                	mov    %ebx,%esi
		*s++ = 0;
	if (*s == 0) {
  8000be:	0f b6 03             	movzbl (%ebx),%eax
  8000c1:	84 c0                	test   %al,%al
  8000c3:	75 2c                	jne    8000f1 <_gettoken+0xbe>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000c5:	b8 00 00 00 00       	mov    $0x0,%eax
	*p2 = 0;

	while (strchr(WHITESPACE, *s))
		*s++ = 0;
	if (*s == 0) {
		if (debug > 1)
  8000ca:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000d1:	0f 8e c1 00 00 00    	jle    800198 <_gettoken+0x165>
			cprintf("EOL\n");
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	68 22 33 80 00       	push   $0x803322
  8000df:	e8 0c 0a 00 00       	call   800af0 <cprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
		return 0;
  8000e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ec:	e9 a7 00 00 00       	jmp    800198 <_gettoken+0x165>
	}
	if (strchr(SYMBOLS, *s)) {
  8000f1:	83 ec 08             	sub    $0x8,%esp
  8000f4:	0f be c0             	movsbl %al,%eax
  8000f7:	50                   	push   %eax
  8000f8:	68 33 33 80 00       	push   $0x803333
  8000fd:	e8 7a 10 00 00       	call   80117c <strchr>
  800102:	83 c4 10             	add    $0x10,%esp
  800105:	85 c0                	test   %eax,%eax
  800107:	74 30                	je     800139 <_gettoken+0x106>
		t = *s;
  800109:	0f be 1b             	movsbl (%ebx),%ebx
		*p1 = s;
  80010c:	89 37                	mov    %esi,(%edi)
		*s++ = 0;
  80010e:	c6 06 00             	movb   $0x0,(%esi)
  800111:	83 c6 01             	add    $0x1,%esi
  800114:	8b 45 10             	mov    0x10(%ebp),%eax
  800117:	89 30                	mov    %esi,(%eax)
		*p2 = s;
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
  800119:	89 d8                	mov    %ebx,%eax
	if (strchr(SYMBOLS, *s)) {
		t = *s;
		*p1 = s;
		*s++ = 0;
		*p2 = s;
		if (debug > 1)
  80011b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800122:	7e 74                	jle    800198 <_gettoken+0x165>
			cprintf("TOK %c\n", t);
  800124:	83 ec 08             	sub    $0x8,%esp
  800127:	53                   	push   %ebx
  800128:	68 27 33 80 00       	push   $0x803327
  80012d:	e8 be 09 00 00       	call   800af0 <cprintf>
  800132:	83 c4 10             	add    $0x10,%esp
		return t;
  800135:	89 d8                	mov    %ebx,%eax
  800137:	eb 5f                	jmp    800198 <_gettoken+0x165>
	}
	*p1 = s;
  800139:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80013b:	eb 03                	jmp    800140 <_gettoken+0x10d>
		s++;
  80013d:	83 c3 01             	add    $0x1,%ebx
		if (debug > 1)
			cprintf("TOK %c\n", t);
		return t;
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800140:	0f b6 03             	movzbl (%ebx),%eax
  800143:	84 c0                	test   %al,%al
  800145:	74 18                	je     80015f <_gettoken+0x12c>
  800147:	83 ec 08             	sub    $0x8,%esp
  80014a:	0f be c0             	movsbl %al,%eax
  80014d:	50                   	push   %eax
  80014e:	68 2f 33 80 00       	push   $0x80332f
  800153:	e8 24 10 00 00       	call   80117c <strchr>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	74 de                	je     80013d <_gettoken+0x10a>
		s++;
	*p2 = s;
  80015f:	8b 45 10             	mov    0x10(%ebp),%eax
  800162:	89 18                	mov    %ebx,(%eax)
		t = **p2;
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
  800164:	b8 77 00 00 00       	mov    $0x77,%eax
	}
	*p1 = s;
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
		s++;
	*p2 = s;
	if (debug > 1) {
  800169:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800170:	7e 26                	jle    800198 <_gettoken+0x165>
		t = **p2;
  800172:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  800175:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  800178:	83 ec 08             	sub    $0x8,%esp
  80017b:	ff 37                	pushl  (%edi)
  80017d:	68 3b 33 80 00       	push   $0x80333b
  800182:	e8 69 09 00 00       	call   800af0 <cprintf>
		**p2 = t;
  800187:	8b 45 10             	mov    0x10(%ebp),%eax
  80018a:	8b 00                	mov    (%eax),%eax
  80018c:	89 f2                	mov    %esi,%edx
  80018e:	88 10                	mov    %dl,(%eax)
  800190:	83 c4 10             	add    $0x10,%esp
	}
	return 'w';
  800193:	b8 77 00 00 00       	mov    $0x77,%eax
}
  800198:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019b:	5b                   	pop    %ebx
  80019c:	5e                   	pop    %esi
  80019d:	5f                   	pop    %edi
  80019e:	5d                   	pop    %ebp
  80019f:	c3                   	ret    

008001a0 <gettoken>:

int
gettoken(char *s, char **p1)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	83 ec 08             	sub    $0x8,%esp
  8001a6:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char* np1, *np2;

	if (s) {
  8001a9:	85 c0                	test   %eax,%eax
  8001ab:	74 22                	je     8001cf <gettoken+0x2f>
		nc = _gettoken(s, &np1, &np2);
  8001ad:	83 ec 04             	sub    $0x4,%esp
  8001b0:	68 0c 50 80 00       	push   $0x80500c
  8001b5:	68 10 50 80 00       	push   $0x805010
  8001ba:	50                   	push   %eax
  8001bb:	e8 73 fe ff ff       	call   800033 <_gettoken>
  8001c0:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8001cd:	eb 3a                	jmp    800209 <gettoken+0x69>
	}
	c = nc;
  8001cf:	a1 08 50 80 00       	mov    0x805008,%eax
  8001d4:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001dc:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001e2:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001e4:	83 ec 04             	sub    $0x4,%esp
  8001e7:	68 0c 50 80 00       	push   $0x80500c
  8001ec:	68 10 50 80 00       	push   $0x805010
  8001f1:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001f7:	e8 37 fe ff ff       	call   800033 <_gettoken>
  8001fc:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  800201:	a1 04 50 80 00       	mov    0x805004,%eax
  800206:	83 c4 10             	add    $0x10,%esp
}
  800209:	c9                   	leave  
  80020a:	c3                   	ret    

0080020b <runcmd>:
// runcmd() is called in a forked child,
// so it's OK to manipulate file descriptor state.
#define MAXARGS 16
void
runcmd(char* s)
{
  80020b:	55                   	push   %ebp
  80020c:	89 e5                	mov    %esp,%ebp
  80020e:	57                   	push   %edi
  80020f:	56                   	push   %esi
  800210:	53                   	push   %ebx
  800211:	81 ec 64 04 00 00    	sub    $0x464,%esp
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
	gettoken(s, 0);
  800217:	6a 00                	push   $0x0
  800219:	ff 75 08             	pushl  0x8(%ebp)
  80021c:	e8 7f ff ff ff       	call   8001a0 <gettoken>
  800221:	83 c4 10             	add    $0x10,%esp

again:
	argc = 0;
	while (1) {
		switch ((c = gettoken(0, &t))) {
  800224:	8d 5d a4             	lea    -0x5c(%ebp),%ebx

	pipe_child = 0;
	gettoken(s, 0);

again:
	argc = 0;
  800227:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		switch ((c = gettoken(0, &t))) {
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	53                   	push   %ebx
  800230:	6a 00                	push   $0x0
  800232:	e8 69 ff ff ff       	call   8001a0 <gettoken>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	83 f8 3e             	cmp    $0x3e,%eax
  80023d:	0f 84 cc 00 00 00    	je     80030f <runcmd+0x104>
  800243:	83 f8 3e             	cmp    $0x3e,%eax
  800246:	7f 12                	jg     80025a <runcmd+0x4f>
  800248:	85 c0                	test   %eax,%eax
  80024a:	0f 84 3b 02 00 00    	je     80048b <runcmd+0x280>
  800250:	83 f8 3c             	cmp    $0x3c,%eax
  800253:	74 3e                	je     800293 <runcmd+0x88>
  800255:	e9 1f 02 00 00       	jmp    800479 <runcmd+0x26e>
  80025a:	83 f8 77             	cmp    $0x77,%eax
  80025d:	74 0e                	je     80026d <runcmd+0x62>
  80025f:	83 f8 7c             	cmp    $0x7c,%eax
  800262:	0f 84 25 01 00 00    	je     80038d <runcmd+0x182>
  800268:	e9 0c 02 00 00       	jmp    800479 <runcmd+0x26e>

		case 'w':	// Add an argument
			if (argc == MAXARGS) {
  80026d:	83 fe 10             	cmp    $0x10,%esi
  800270:	75 15                	jne    800287 <runcmd+0x7c>
				cprintf("too many arguments\n");
  800272:	83 ec 0c             	sub    $0xc,%esp
  800275:	68 45 33 80 00       	push   $0x803345
  80027a:	e8 71 08 00 00       	call   800af0 <cprintf>
				exit();
  80027f:	e8 79 07 00 00       	call   8009fd <exit>
  800284:	83 c4 10             	add    $0x10,%esp
			}
			argv[argc++] = t;
  800287:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80028a:	89 44 b5 a8          	mov    %eax,-0x58(%ebp,%esi,4)
  80028e:	8d 76 01             	lea    0x1(%esi),%esi
			break;
  800291:	eb 99                	jmp    80022c <runcmd+0x21>

		case '<':	// Input redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	53                   	push   %ebx
  800297:	6a 00                	push   $0x0
  800299:	e8 02 ff ff ff       	call   8001a0 <gettoken>
  80029e:	83 c4 10             	add    $0x10,%esp
  8002a1:	83 f8 77             	cmp    $0x77,%eax
  8002a4:	74 15                	je     8002bb <runcmd+0xb0>
				cprintf("syntax error: < not followed by word\n");
  8002a6:	83 ec 0c             	sub    $0xc,%esp
  8002a9:	68 90 34 80 00       	push   $0x803490
  8002ae:	e8 3d 08 00 00       	call   800af0 <cprintf>
				exit();
  8002b3:	e8 45 07 00 00       	call   8009fd <exit>
  8002b8:	83 c4 10             	add    $0x10,%esp
			// then check whether 'fd' is 0.
			// If not, dup 'fd' onto file descriptor 0,
			// then close the original 'fd'.

			// LAB 11: Your code here.
			if ((fd = open(t, O_RDONLY)) < 0) {
  8002bb:	83 ec 08             	sub    $0x8,%esp
  8002be:	6a 00                	push   $0x0
  8002c0:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002c3:	e8 5a 20 00 00       	call   802322 <open>
  8002c8:	89 c7                	mov    %eax,%edi
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	79 1b                	jns    8002ec <runcmd+0xe1>
                cprintf("open %s for read: %i", t, fd);
  8002d1:	83 ec 04             	sub    $0x4,%esp
  8002d4:	50                   	push   %eax
  8002d5:	ff 75 a4             	pushl  -0x5c(%ebp)
  8002d8:	68 59 33 80 00       	push   $0x803359
  8002dd:	e8 0e 08 00 00       	call   800af0 <cprintf>
				exit();
  8002e2:	e8 16 07 00 00       	call   8009fd <exit>
  8002e7:	83 c4 10             	add    $0x10,%esp
  8002ea:	eb 08                	jmp    8002f4 <runcmd+0xe9>
            }
            if (fd) {
  8002ec:	85 c0                	test   %eax,%eax
  8002ee:	0f 84 38 ff ff ff    	je     80022c <runcmd+0x21>
                dup(fd, 0);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	6a 00                	push   $0x0
  8002f9:	57                   	push   %edi
  8002fa:	e8 aa 1a 00 00       	call   801da9 <dup>
                close(fd);
  8002ff:	89 3c 24             	mov    %edi,(%esp)
  800302:	e8 50 1a 00 00       	call   801d57 <close>
  800307:	83 c4 10             	add    $0x10,%esp
  80030a:	e9 1d ff ff ff       	jmp    80022c <runcmd+0x21>
			//panic("< redirection not implemented");
			break;

		case '>':	// Output redirection
			// Grab the filename from the argument list
			if (gettoken(0, &t) != 'w') {
  80030f:	83 ec 08             	sub    $0x8,%esp
  800312:	53                   	push   %ebx
  800313:	6a 00                	push   $0x0
  800315:	e8 86 fe ff ff       	call   8001a0 <gettoken>
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	83 f8 77             	cmp    $0x77,%eax
  800320:	74 15                	je     800337 <runcmd+0x12c>
				cprintf("syntax error: > not followed by word\n");
  800322:	83 ec 0c             	sub    $0xc,%esp
  800325:	68 b8 34 80 00       	push   $0x8034b8
  80032a:	e8 c1 07 00 00       	call   800af0 <cprintf>
				exit();
  80032f:	e8 c9 06 00 00       	call   8009fd <exit>
  800334:	83 c4 10             	add    $0x10,%esp
			}
			if ((fd = open(t, O_WRONLY|O_CREAT|O_TRUNC)) < 0) {
  800337:	83 ec 08             	sub    $0x8,%esp
  80033a:	68 01 03 00 00       	push   $0x301
  80033f:	ff 75 a4             	pushl  -0x5c(%ebp)
  800342:	e8 db 1f 00 00       	call   802322 <open>
  800347:	89 c7                	mov    %eax,%edi
  800349:	83 c4 10             	add    $0x10,%esp
  80034c:	85 c0                	test   %eax,%eax
  80034e:	79 19                	jns    800369 <runcmd+0x15e>
				cprintf("open %s for write: %i", t, fd);
  800350:	83 ec 04             	sub    $0x4,%esp
  800353:	50                   	push   %eax
  800354:	ff 75 a4             	pushl  -0x5c(%ebp)
  800357:	68 6e 33 80 00       	push   $0x80336e
  80035c:	e8 8f 07 00 00       	call   800af0 <cprintf>
				exit();
  800361:	e8 97 06 00 00       	call   8009fd <exit>
  800366:	83 c4 10             	add    $0x10,%esp
			}
			if (fd != 1) {
  800369:	83 ff 01             	cmp    $0x1,%edi
  80036c:	0f 84 ba fe ff ff    	je     80022c <runcmd+0x21>
				dup(fd, 1);
  800372:	83 ec 08             	sub    $0x8,%esp
  800375:	6a 01                	push   $0x1
  800377:	57                   	push   %edi
  800378:	e8 2c 1a 00 00       	call   801da9 <dup>
				close(fd);
  80037d:	89 3c 24             	mov    %edi,(%esp)
  800380:	e8 d2 19 00 00       	call   801d57 <close>
  800385:	83 c4 10             	add    $0x10,%esp
  800388:	e9 9f fe ff ff       	jmp    80022c <runcmd+0x21>
			}
			break;

		case '|':	// Pipe
			if ((r = pipe(p)) < 0) {
  80038d:	83 ec 0c             	sub    $0xc,%esp
  800390:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  800396:	50                   	push   %eax
  800397:	e8 d3 28 00 00       	call   802c6f <pipe>
  80039c:	83 c4 10             	add    $0x10,%esp
  80039f:	85 c0                	test   %eax,%eax
  8003a1:	79 16                	jns    8003b9 <runcmd+0x1ae>
				cprintf("pipe: %i", r);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	50                   	push   %eax
  8003a7:	68 84 33 80 00       	push   $0x803384
  8003ac:	e8 3f 07 00 00       	call   800af0 <cprintf>
				exit();
  8003b1:	e8 47 06 00 00       	call   8009fd <exit>
  8003b6:	83 c4 10             	add    $0x10,%esp
			}
			if (debug)
  8003b9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8003c0:	74 1c                	je     8003de <runcmd+0x1d3>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003c2:	83 ec 04             	sub    $0x4,%esp
  8003c5:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003cb:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003d1:	68 8d 33 80 00       	push   $0x80338d
  8003d6:	e8 15 07 00 00       	call   800af0 <cprintf>
  8003db:	83 c4 10             	add    $0x10,%esp
			if ((r = fork()) < 0) {
  8003de:	e8 98 14 00 00       	call   80187b <fork>
  8003e3:	89 c7                	mov    %eax,%edi
  8003e5:	85 c0                	test   %eax,%eax
  8003e7:	79 16                	jns    8003ff <runcmd+0x1f4>
				cprintf("fork: %i", r);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	50                   	push   %eax
  8003ed:	68 e9 38 80 00       	push   $0x8038e9
  8003f2:	e8 f9 06 00 00       	call   800af0 <cprintf>
				exit();
  8003f7:	e8 01 06 00 00       	call   8009fd <exit>
  8003fc:	83 c4 10             	add    $0x10,%esp
			}
			if (r == 0) {
  8003ff:	85 ff                	test   %edi,%edi
  800401:	75 3c                	jne    80043f <runcmd+0x234>
				if (p[0] != 0) {
  800403:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  800409:	85 c0                	test   %eax,%eax
  80040b:	74 1c                	je     800429 <runcmd+0x21e>
					dup(p[0], 0);
  80040d:	83 ec 08             	sub    $0x8,%esp
  800410:	6a 00                	push   $0x0
  800412:	50                   	push   %eax
  800413:	e8 91 19 00 00       	call   801da9 <dup>
					close(p[0]);
  800418:	83 c4 04             	add    $0x4,%esp
  80041b:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800421:	e8 31 19 00 00       	call   801d57 <close>
  800426:	83 c4 10             	add    $0x10,%esp
				}
				close(p[1]);
  800429:	83 ec 0c             	sub    $0xc,%esp
  80042c:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  800432:	e8 20 19 00 00       	call   801d57 <close>
				goto again;
  800437:	83 c4 10             	add    $0x10,%esp
  80043a:	e9 e8 fd ff ff       	jmp    800227 <runcmd+0x1c>
			} else {
				pipe_child = r;
				if (p[1] != 1) {
  80043f:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800445:	83 f8 01             	cmp    $0x1,%eax
  800448:	74 1c                	je     800466 <runcmd+0x25b>
					dup(p[1], 1);
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 01                	push   $0x1
  80044f:	50                   	push   %eax
  800450:	e8 54 19 00 00       	call   801da9 <dup>
					close(p[1]);
  800455:	83 c4 04             	add    $0x4,%esp
  800458:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80045e:	e8 f4 18 00 00       	call   801d57 <close>
  800463:	83 c4 10             	add    $0x10,%esp
				}
				close(p[0]);
  800466:	83 ec 0c             	sub    $0xc,%esp
  800469:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  80046f:	e8 e3 18 00 00       	call   801d57 <close>
				goto runit;
  800474:	83 c4 10             	add    $0x10,%esp
  800477:	eb 17                	jmp    800490 <runcmd+0x285>
		case 0:		// String is complete
			// Run the current command!
			goto runit;

		default:
			panic("bad return %d from gettoken", c);
  800479:	50                   	push   %eax
  80047a:	68 9a 33 80 00       	push   $0x80339a
  80047f:	6a 78                	push   $0x78
  800481:	68 b6 33 80 00       	push   $0x8033b6
  800486:	e8 8c 05 00 00       	call   800a17 <_panic>
runcmd(char* s)
{
	char *argv[MAXARGS], *t, argv0buf[BUFSIZ];
	int argc, c, i, r, p[2], fd, pipe_child;

	pipe_child = 0;
  80048b:	bf 00 00 00 00       	mov    $0x0,%edi
		}
	}

runit:
	// Return immediately if command line was empty.
	if(argc == 0) {
  800490:	85 f6                	test   %esi,%esi
  800492:	75 22                	jne    8004b6 <runcmd+0x2ab>
		if (debug)
  800494:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80049b:	0f 84 96 01 00 00    	je     800637 <runcmd+0x42c>
			cprintf("EMPTY COMMAND\n");
  8004a1:	83 ec 0c             	sub    $0xc,%esp
  8004a4:	68 c0 33 80 00       	push   $0x8033c0
  8004a9:	e8 42 06 00 00       	call   800af0 <cprintf>
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	e9 81 01 00 00       	jmp    800637 <runcmd+0x42c>

	// Clean up command line.
	// Read all commands from the filesystem: add an initial '/' to
	// the command name.
	// This essentially acts like 'PATH=/'.
	if (argv[0][0] != '/') {
  8004b6:	8b 45 a8             	mov    -0x58(%ebp),%eax
  8004b9:	80 38 2f             	cmpb   $0x2f,(%eax)
  8004bc:	74 23                	je     8004e1 <runcmd+0x2d6>
		argv0buf[0] = '/';
  8004be:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	50                   	push   %eax
  8004c9:	8d 9d a4 fb ff ff    	lea    -0x45c(%ebp),%ebx
  8004cf:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  8004d5:	50                   	push   %eax
  8004d6:	e8 99 0b 00 00       	call   801074 <strcpy>
		argv[0] = argv0buf;
  8004db:	89 5d a8             	mov    %ebx,-0x58(%ebp)
  8004de:	83 c4 10             	add    $0x10,%esp
	}
	argv[argc] = 0;
  8004e1:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
  8004e8:	00 

	// Print the command.
	if (debug) {
  8004e9:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004f0:	74 49                	je     80053b <runcmd+0x330>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  8004f2:	a1 44 54 80 00       	mov    0x805444,%eax
  8004f7:	8b 40 48             	mov    0x48(%eax),%eax
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	50                   	push   %eax
  8004fe:	68 cf 33 80 00       	push   $0x8033cf
  800503:	e8 e8 05 00 00       	call   800af0 <cprintf>
  800508:	8d 5d a8             	lea    -0x58(%ebp),%ebx
		for (i = 0; argv[i]; i++)
  80050b:	83 c4 10             	add    $0x10,%esp
  80050e:	eb 11                	jmp    800521 <runcmd+0x316>
			cprintf(" %s", argv[i]);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	50                   	push   %eax
  800514:	68 5a 34 80 00       	push   $0x80345a
  800519:	e8 d2 05 00 00       	call   800af0 <cprintf>
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	83 c3 04             	add    $0x4,%ebx
	argv[argc] = 0;

	// Print the command.
	if (debug) {
		cprintf("[%08x] SPAWN:", thisenv->env_id);
		for (i = 0; argv[i]; i++)
  800524:	8b 43 fc             	mov    -0x4(%ebx),%eax
  800527:	85 c0                	test   %eax,%eax
  800529:	75 e5                	jne    800510 <runcmd+0x305>
			cprintf(" %s", argv[i]);
		cprintf("\n");
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	68 20 33 80 00       	push   $0x803320
  800533:	e8 b8 05 00 00       	call   800af0 <cprintf>
  800538:	83 c4 10             	add    $0x10,%esp
	}

	// Spawn the command!
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	8d 45 a8             	lea    -0x58(%ebp),%eax
  800541:	50                   	push   %eax
  800542:	ff 75 a8             	pushl  -0x58(%ebp)
  800545:	e8 90 1f 00 00       	call   8024da <spawn>
  80054a:	89 c3                	mov    %eax,%ebx
  80054c:	83 c4 10             	add    $0x10,%esp
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 89 c3 00 00 00    	jns    80061a <runcmd+0x40f>
		cprintf("spawn %s: %i\n", argv[0], r);
  800557:	83 ec 04             	sub    $0x4,%esp
  80055a:	50                   	push   %eax
  80055b:	ff 75 a8             	pushl  -0x58(%ebp)
  80055e:	68 dd 33 80 00       	push   $0x8033dd
  800563:	e8 88 05 00 00       	call   800af0 <cprintf>

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  800568:	e8 17 18 00 00       	call   801d84 <close_all>
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	eb 4c                	jmp    8005be <runcmd+0x3b3>
	if (r >= 0) {
		if (debug)
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  800572:	a1 44 54 80 00       	mov    0x805444,%eax
  800577:	8b 40 48             	mov    0x48(%eax),%eax
  80057a:	53                   	push   %ebx
  80057b:	ff 75 a8             	pushl  -0x58(%ebp)
  80057e:	50                   	push   %eax
  80057f:	68 eb 33 80 00       	push   $0x8033eb
  800584:	e8 67 05 00 00       	call   800af0 <cprintf>
  800589:	83 c4 10             	add    $0x10,%esp
		wait(r);
  80058c:	83 ec 0c             	sub    $0xc,%esp
  80058f:	53                   	push   %ebx
  800590:	e8 62 28 00 00       	call   802df7 <wait>
		if (debug)
  800595:	83 c4 10             	add    $0x10,%esp
  800598:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80059f:	0f 84 8c 00 00 00    	je     800631 <runcmd+0x426>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005a5:	a1 44 54 80 00       	mov    0x805444,%eax
  8005aa:	8b 40 48             	mov    0x48(%eax),%eax
  8005ad:	83 ec 08             	sub    $0x8,%esp
  8005b0:	50                   	push   %eax
  8005b1:	68 00 34 80 00       	push   $0x803400
  8005b6:	e8 35 05 00 00       	call   800af0 <cprintf>
  8005bb:	83 c4 10             	add    $0x10,%esp
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  8005be:	85 ff                	test   %edi,%edi
  8005c0:	74 51                	je     800613 <runcmd+0x408>
		if (debug)
  8005c2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005c9:	74 1a                	je     8005e5 <runcmd+0x3da>
			cprintf("[%08x] WAIT pipe_child %08x\n", thisenv->env_id, pipe_child);
  8005cb:	a1 44 54 80 00       	mov    0x805444,%eax
  8005d0:	8b 40 48             	mov    0x48(%eax),%eax
  8005d3:	83 ec 04             	sub    $0x4,%esp
  8005d6:	57                   	push   %edi
  8005d7:	50                   	push   %eax
  8005d8:	68 16 34 80 00       	push   $0x803416
  8005dd:	e8 0e 05 00 00       	call   800af0 <cprintf>
  8005e2:	83 c4 10             	add    $0x10,%esp
		wait(pipe_child);
  8005e5:	83 ec 0c             	sub    $0xc,%esp
  8005e8:	57                   	push   %edi
  8005e9:	e8 09 28 00 00       	call   802df7 <wait>
		if (debug)
  8005ee:	83 c4 10             	add    $0x10,%esp
  8005f1:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005f8:	74 19                	je     800613 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  8005fa:	a1 44 54 80 00       	mov    0x805444,%eax
  8005ff:	8b 40 48             	mov    0x48(%eax),%eax
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	50                   	push   %eax
  800606:	68 00 34 80 00       	push   $0x803400
  80060b:	e8 e0 04 00 00       	call   800af0 <cprintf>
  800610:	83 c4 10             	add    $0x10,%esp
	}

	// Done!
	exit();
  800613:	e8 e5 03 00 00       	call   8009fd <exit>
  800618:	eb 1d                	jmp    800637 <runcmd+0x42c>
	if ((r = spawn(argv[0], (const char**) argv)) < 0)
		cprintf("spawn %s: %i\n", argv[0], r);

	// In the parent, close all file descriptors and wait for the
	// spawned command to exit.
	close_all();
  80061a:	e8 65 17 00 00       	call   801d84 <close_all>
	if (r >= 0) {
		if (debug)
  80061f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800626:	0f 84 60 ff ff ff    	je     80058c <runcmd+0x381>
  80062c:	e9 41 ff ff ff       	jmp    800572 <runcmd+0x367>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// If we were the left-hand part of a pipe,
	// wait for the right-hand part to finish.
	if (pipe_child) {
  800631:	85 ff                	test   %edi,%edi
  800633:	75 b0                	jne    8005e5 <runcmd+0x3da>
  800635:	eb dc                	jmp    800613 <runcmd+0x408>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
	}

	// Done!
	exit();
}
  800637:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063a:	5b                   	pop    %ebx
  80063b:	5e                   	pop    %esi
  80063c:	5f                   	pop    %edi
  80063d:	5d                   	pop    %ebp
  80063e:	c3                   	ret    

0080063f <usage>:
}


void
usage(void)
{
  80063f:	55                   	push   %ebp
  800640:	89 e5                	mov    %esp,%ebp
  800642:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  800645:	68 e0 34 80 00       	push   $0x8034e0
  80064a:	e8 a1 04 00 00       	call   800af0 <cprintf>
	exit();
  80064f:	e8 a9 03 00 00       	call   8009fd <exit>
  800654:	83 c4 10             	add    $0x10,%esp
}
  800657:	c9                   	leave  
  800658:	c3                   	ret    

00800659 <umain>:

void
umain(int argc, char **argv)
{
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	57                   	push   %edi
  80065d:	56                   	push   %esi
  80065e:	53                   	push   %ebx
  80065f:	83 ec 30             	sub    $0x30,%esp
  800662:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  800665:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800668:	50                   	push   %eax
  800669:	56                   	push   %esi
  80066a:	8d 45 08             	lea    0x8(%ebp),%eax
  80066d:	50                   	push   %eax
  80066e:	e8 f1 13 00 00       	call   801a64 <argstart>
	while ((r = argnext(&args)) >= 0)
  800673:	83 c4 10             	add    $0x10,%esp
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
  800676:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
umain(int argc, char **argv)
{
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
  80067d:	bf 3f 00 00 00       	mov    $0x3f,%edi
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  800682:	8d 5d d8             	lea    -0x28(%ebp),%ebx
  800685:	eb 2f                	jmp    8006b6 <umain+0x5d>
		switch (r) {
  800687:	83 f8 69             	cmp    $0x69,%eax
  80068a:	74 25                	je     8006b1 <umain+0x58>
  80068c:	83 f8 78             	cmp    $0x78,%eax
  80068f:	74 07                	je     800698 <umain+0x3f>
  800691:	83 f8 64             	cmp    $0x64,%eax
  800694:	75 14                	jne    8006aa <umain+0x51>
  800696:	eb 09                	jmp    8006a1 <umain+0x48>
			break;
		case 'i':
			interactive = 1;
			break;
		case 'x':
			echocmds = 1;
  800698:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  80069f:	eb 15                	jmp    8006b6 <umain+0x5d>
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
		switch (r) {
		case 'd':
			debug++;
  8006a1:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006a8:	eb 0c                	jmp    8006b6 <umain+0x5d>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006aa:	e8 90 ff ff ff       	call   80063f <usage>
  8006af:	eb 05                	jmp    8006b6 <umain+0x5d>
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006b1:	bf 01 00 00 00       	mov    $0x1,%edi
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
	while ((r = argnext(&args)) >= 0)
  8006b6:	83 ec 0c             	sub    $0xc,%esp
  8006b9:	53                   	push   %ebx
  8006ba:	e8 d5 13 00 00       	call   801a94 <argnext>
  8006bf:	83 c4 10             	add    $0x10,%esp
  8006c2:	85 c0                	test   %eax,%eax
  8006c4:	79 c1                	jns    800687 <umain+0x2e>
  8006c6:	89 fb                	mov    %edi,%ebx
			break;
		default:
			usage();
		}

	if (argc > 2)
  8006c8:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006cc:	7e 05                	jle    8006d3 <umain+0x7a>
		usage();
  8006ce:	e8 6c ff ff ff       	call   80063f <usage>
	if (argc == 2) {
  8006d3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006d7:	75 56                	jne    80072f <umain+0xd6>
		close(0);
  8006d9:	83 ec 0c             	sub    $0xc,%esp
  8006dc:	6a 00                	push   $0x0
  8006de:	e8 74 16 00 00       	call   801d57 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  8006e3:	83 c4 08             	add    $0x8,%esp
  8006e6:	6a 00                	push   $0x0
  8006e8:	ff 76 04             	pushl  0x4(%esi)
  8006eb:	e8 32 1c 00 00       	call   802322 <open>
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	79 1b                	jns    800712 <umain+0xb9>
			panic("open %s: %i", argv[1], r);
  8006f7:	83 ec 0c             	sub    $0xc,%esp
  8006fa:	50                   	push   %eax
  8006fb:	ff 76 04             	pushl  0x4(%esi)
  8006fe:	68 36 34 80 00       	push   $0x803436
  800703:	68 28 01 00 00       	push   $0x128
  800708:	68 b6 33 80 00       	push   $0x8033b6
  80070d:	e8 05 03 00 00       	call   800a17 <_panic>
		assert(r == 0);
  800712:	85 c0                	test   %eax,%eax
  800714:	74 19                	je     80072f <umain+0xd6>
  800716:	68 42 34 80 00       	push   $0x803442
  80071b:	68 49 34 80 00       	push   $0x803449
  800720:	68 29 01 00 00       	push   $0x129
  800725:	68 b6 33 80 00       	push   $0x8033b6
  80072a:	e8 e8 02 00 00       	call   800a17 <_panic>
	}
	if (interactive == '?')
  80072f:	83 fb 3f             	cmp    $0x3f,%ebx
  800732:	75 0f                	jne    800743 <umain+0xea>
		interactive = iscons(0);
  800734:	83 ec 0c             	sub    $0xc,%esp
  800737:	6a 00                	push   $0x0
  800739:	e8 f3 01 00 00       	call   800931 <iscons>
  80073e:	89 c7                	mov    %eax,%edi
  800740:	83 c4 10             	add    $0x10,%esp

	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
  800743:	83 ff 01             	cmp    $0x1,%edi
  800746:	19 c0                	sbb    %eax,%eax
  800748:	f7 d0                	not    %eax
  80074a:	25 33 34 80 00       	and    $0x803433,%eax
  80074f:	83 ec 0c             	sub    $0xc,%esp
  800752:	50                   	push   %eax
  800753:	e8 6a 0c 00 00       	call   8013c2 <readline>
  800758:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	85 c0                	test   %eax,%eax
  80075f:	75 1e                	jne    80077f <umain+0x126>
			if (debug)
  800761:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800768:	74 10                	je     80077a <umain+0x121>
				cprintf("EXITING\n");
  80076a:	83 ec 0c             	sub    $0xc,%esp
  80076d:	68 5e 34 80 00       	push   $0x80345e
  800772:	e8 79 03 00 00       	call   800af0 <cprintf>
  800777:	83 c4 10             	add    $0x10,%esp
			exit();	// end of file
  80077a:	e8 7e 02 00 00       	call   8009fd <exit>
		}
		if (debug)
  80077f:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800786:	74 11                	je     800799 <umain+0x140>
			cprintf("LINE: %s\n", buf);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	68 67 34 80 00       	push   $0x803467
  800791:	e8 5a 03 00 00       	call   800af0 <cprintf>
  800796:	83 c4 10             	add    $0x10,%esp
		if (buf[0] == '#')
  800799:	80 3b 23             	cmpb   $0x23,(%ebx)
  80079c:	74 a5                	je     800743 <umain+0xea>
			continue;
		if (echocmds)
  80079e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8007a2:	74 11                	je     8007b5 <umain+0x15c>
			printf("# %s\n", buf);
  8007a4:	83 ec 08             	sub    $0x8,%esp
  8007a7:	53                   	push   %ebx
  8007a8:	68 71 34 80 00       	push   $0x803471
  8007ad:	e8 12 1d 00 00       	call   8024c4 <printf>
  8007b2:	83 c4 10             	add    $0x10,%esp
		if (debug)
  8007b5:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007bc:	74 10                	je     8007ce <umain+0x175>
			cprintf("BEFORE FORK\n");
  8007be:	83 ec 0c             	sub    $0xc,%esp
  8007c1:	68 77 34 80 00       	push   $0x803477
  8007c6:	e8 25 03 00 00       	call   800af0 <cprintf>
  8007cb:	83 c4 10             	add    $0x10,%esp
		if ((r = fork()) < 0)
  8007ce:	e8 a8 10 00 00       	call   80187b <fork>
  8007d3:	89 c6                	mov    %eax,%esi
  8007d5:	85 c0                	test   %eax,%eax
  8007d7:	79 15                	jns    8007ee <umain+0x195>
			panic("fork: %i", r);
  8007d9:	50                   	push   %eax
  8007da:	68 e9 38 80 00       	push   $0x8038e9
  8007df:	68 40 01 00 00       	push   $0x140
  8007e4:	68 b6 33 80 00       	push   $0x8033b6
  8007e9:	e8 29 02 00 00       	call   800a17 <_panic>
		if (debug)
  8007ee:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8007f5:	74 11                	je     800808 <umain+0x1af>
			cprintf("FORK: %d\n", r);
  8007f7:	83 ec 08             	sub    $0x8,%esp
  8007fa:	50                   	push   %eax
  8007fb:	68 84 34 80 00       	push   $0x803484
  800800:	e8 eb 02 00 00       	call   800af0 <cprintf>
  800805:	83 c4 10             	add    $0x10,%esp
		if (r == 0) {
  800808:	85 f6                	test   %esi,%esi
  80080a:	75 16                	jne    800822 <umain+0x1c9>
			runcmd(buf);
  80080c:	83 ec 0c             	sub    $0xc,%esp
  80080f:	53                   	push   %ebx
  800810:	e8 f6 f9 ff ff       	call   80020b <runcmd>
			exit();
  800815:	e8 e3 01 00 00       	call   8009fd <exit>
  80081a:	83 c4 10             	add    $0x10,%esp
  80081d:	e9 21 ff ff ff       	jmp    800743 <umain+0xea>
		} else
			wait(r);
  800822:	83 ec 0c             	sub    $0xc,%esp
  800825:	56                   	push   %esi
  800826:	e8 cc 25 00 00       	call   802df7 <wait>
  80082b:	83 c4 10             	add    $0x10,%esp
  80082e:	e9 10 ff ff ff       	jmp    800743 <umain+0xea>

00800833 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	5d                   	pop    %ebp
  80083c:	c3                   	ret    

0080083d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800843:	68 01 35 80 00       	push   $0x803501
  800848:	ff 75 0c             	pushl  0xc(%ebp)
  80084b:	e8 24 08 00 00       	call   801074 <strcpy>
	return 0;
}
  800850:	b8 00 00 00 00       	mov    $0x0,%eax
  800855:	c9                   	leave  
  800856:	c3                   	ret    

00800857 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800857:	55                   	push   %ebp
  800858:	89 e5                	mov    %esp,%ebp
  80085a:	57                   	push   %edi
  80085b:	56                   	push   %esi
  80085c:	53                   	push   %ebx
  80085d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800863:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800868:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80086e:	eb 2e                	jmp    80089e <devcons_write+0x47>
		m = n - tot;
  800870:	8b 55 10             	mov    0x10(%ebp),%edx
  800873:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  800875:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  80087a:	83 fa 7f             	cmp    $0x7f,%edx
  80087d:	77 02                	ja     800881 <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80087f:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800881:	83 ec 04             	sub    $0x4,%esp
  800884:	56                   	push   %esi
  800885:	03 45 0c             	add    0xc(%ebp),%eax
  800888:	50                   	push   %eax
  800889:	57                   	push   %edi
  80088a:	e8 77 09 00 00       	call   801206 <memmove>
		sys_cputs(buf, m);
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	56                   	push   %esi
  800893:	57                   	push   %edi
  800894:	e8 1c 0c 00 00       	call   8014b5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800899:	01 f3                	add    %esi,%ebx
  80089b:	83 c4 10             	add    $0x10,%esp
  80089e:	89 d8                	mov    %ebx,%eax
  8008a0:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8008a3:	72 cb                	jb     800870 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8008a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008a8:	5b                   	pop    %ebx
  8008a9:	5e                   	pop    %esi
  8008aa:	5f                   	pop    %edi
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    

008008ad <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8008ad:	55                   	push   %ebp
  8008ae:	89 e5                	mov    %esp,%ebp
  8008b0:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8008b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8008bc:	75 07                	jne    8008c5 <devcons_read+0x18>
  8008be:	eb 28                	jmp    8008e8 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8008c0:	e8 8d 0c 00 00       	call   801552 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8008c5:	e8 09 0c 00 00       	call   8014d3 <sys_cgetc>
  8008ca:	85 c0                	test   %eax,%eax
  8008cc:	74 f2                	je     8008c0 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8008ce:	85 c0                	test   %eax,%eax
  8008d0:	78 16                	js     8008e8 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8008d2:	83 f8 04             	cmp    $0x4,%eax
  8008d5:	74 0c                	je     8008e3 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8008d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008da:	88 02                	mov    %al,(%edx)
	return 1;
  8008dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8008e1:	eb 05                	jmp    8008e8 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8008e3:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    

008008ea <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8008f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f3:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  8008f6:	6a 01                	push   $0x1
  8008f8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8008fb:	50                   	push   %eax
  8008fc:	e8 b4 0b 00 00       	call   8014b5 <sys_cputs>
  800901:	83 c4 10             	add    $0x10,%esp
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    

00800906 <getchar>:

int
getchar(void)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80090c:	6a 01                	push   $0x1
  80090e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800911:	50                   	push   %eax
  800912:	6a 00                	push   $0x0
  800914:	e8 7e 15 00 00       	call   801e97 <read>
	if (r < 0)
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	85 c0                	test   %eax,%eax
  80091e:	78 0f                	js     80092f <getchar+0x29>
		return r;
	if (r < 1)
  800920:	85 c0                	test   %eax,%eax
  800922:	7e 06                	jle    80092a <getchar+0x24>
		return -E_EOF;
	return c;
  800924:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800928:	eb 05                	jmp    80092f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80092a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80092f:	c9                   	leave  
  800930:	c3                   	ret    

00800931 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800931:	55                   	push   %ebp
  800932:	89 e5                	mov    %esp,%ebp
  800934:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800937:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80093a:	50                   	push   %eax
  80093b:	ff 75 08             	pushl  0x8(%ebp)
  80093e:	e8 eb 12 00 00       	call   801c2e <fd_lookup>
  800943:	83 c4 10             	add    $0x10,%esp
  800946:	85 c0                	test   %eax,%eax
  800948:	78 11                	js     80095b <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  80094a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800953:	39 10                	cmp    %edx,(%eax)
  800955:	0f 94 c0             	sete   %al
  800958:	0f b6 c0             	movzbl %al,%eax
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <opencons>:

int
opencons(void)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800963:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800966:	50                   	push   %eax
  800967:	e8 73 12 00 00       	call   801bdf <fd_alloc>
  80096c:	83 c4 10             	add    $0x10,%esp
		return r;
  80096f:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800971:	85 c0                	test   %eax,%eax
  800973:	78 3e                	js     8009b3 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800975:	83 ec 04             	sub    $0x4,%esp
  800978:	68 07 04 00 00       	push   $0x407
  80097d:	ff 75 f4             	pushl  -0xc(%ebp)
  800980:	6a 00                	push   $0x0
  800982:	e8 ea 0b 00 00       	call   801571 <sys_page_alloc>
  800987:	83 c4 10             	add    $0x10,%esp
		return r;
  80098a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80098c:	85 c0                	test   %eax,%eax
  80098e:	78 23                	js     8009b3 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  800990:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800996:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800999:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80099b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8009a5:	83 ec 0c             	sub    $0xc,%esp
  8009a8:	50                   	push   %eax
  8009a9:	e8 0a 12 00 00       	call   801bb8 <fd2num>
  8009ae:	89 c2                	mov    %eax,%edx
  8009b0:	83 c4 10             	add    $0x10,%esp
}
  8009b3:	89 d0                	mov    %edx,%eax
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	56                   	push   %esi
  8009bb:	53                   	push   %ebx
  8009bc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8009bf:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  8009c2:	e8 6c 0b 00 00       	call   801533 <sys_getenvid>
  8009c7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8009cc:	6b c0 78             	imul   $0x78,%eax,%eax
  8009cf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8009d4:	a3 44 54 80 00       	mov    %eax,0x805444

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8009d9:	85 db                	test   %ebx,%ebx
  8009db:	7e 07                	jle    8009e4 <libmain+0x2d>
		binaryname = argv[0];
  8009dd:	8b 06                	mov    (%esi),%eax
  8009df:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8009e4:	83 ec 08             	sub    $0x8,%esp
  8009e7:	56                   	push   %esi
  8009e8:	53                   	push   %ebx
  8009e9:	e8 6b fc ff ff       	call   800659 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8009ee:	e8 0a 00 00 00       	call   8009fd <exit>
  8009f3:	83 c4 10             	add    $0x10,%esp
#endif
}
  8009f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a03:	e8 7c 13 00 00       	call   801d84 <close_all>
	sys_env_destroy(0);
  800a08:	83 ec 0c             	sub    $0xc,%esp
  800a0b:	6a 00                	push   $0x0
  800a0d:	e8 e0 0a 00 00       	call   8014f2 <sys_env_destroy>
  800a12:	83 c4 10             	add    $0x10,%esp
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a1c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a1f:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a25:	e8 09 0b 00 00       	call   801533 <sys_getenvid>
  800a2a:	83 ec 0c             	sub    $0xc,%esp
  800a2d:	ff 75 0c             	pushl  0xc(%ebp)
  800a30:	ff 75 08             	pushl  0x8(%ebp)
  800a33:	56                   	push   %esi
  800a34:	50                   	push   %eax
  800a35:	68 18 35 80 00       	push   $0x803518
  800a3a:	e8 b1 00 00 00       	call   800af0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800a3f:	83 c4 18             	add    $0x18,%esp
  800a42:	53                   	push   %ebx
  800a43:	ff 75 10             	pushl  0x10(%ebp)
  800a46:	e8 54 00 00 00       	call   800a9f <vcprintf>
	cprintf("\n");
  800a4b:	c7 04 24 20 33 80 00 	movl   $0x803320,(%esp)
  800a52:	e8 99 00 00 00       	call   800af0 <cprintf>
  800a57:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800a5a:	cc                   	int3   
  800a5b:	eb fd                	jmp    800a5a <_panic+0x43>

00800a5d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	53                   	push   %ebx
  800a61:	83 ec 04             	sub    $0x4,%esp
  800a64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800a67:	8b 13                	mov    (%ebx),%edx
  800a69:	8d 42 01             	lea    0x1(%edx),%eax
  800a6c:	89 03                	mov    %eax,(%ebx)
  800a6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a71:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800a75:	3d ff 00 00 00       	cmp    $0xff,%eax
  800a7a:	75 1a                	jne    800a96 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800a7c:	83 ec 08             	sub    $0x8,%esp
  800a7f:	68 ff 00 00 00       	push   $0xff
  800a84:	8d 43 08             	lea    0x8(%ebx),%eax
  800a87:	50                   	push   %eax
  800a88:	e8 28 0a 00 00       	call   8014b5 <sys_cputs>
		b->idx = 0;
  800a8d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800a93:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800a96:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800a9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a9d:	c9                   	leave  
  800a9e:	c3                   	ret    

00800a9f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800a9f:	55                   	push   %ebp
  800aa0:	89 e5                	mov    %esp,%ebp
  800aa2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800aa8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800aaf:	00 00 00 
	b.cnt = 0;
  800ab2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800ab9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800abc:	ff 75 0c             	pushl  0xc(%ebp)
  800abf:	ff 75 08             	pushl  0x8(%ebp)
  800ac2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800ac8:	50                   	push   %eax
  800ac9:	68 5d 0a 80 00       	push   $0x800a5d
  800ace:	e8 4f 01 00 00       	call   800c22 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800ad3:	83 c4 08             	add    $0x8,%esp
  800ad6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800adc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800ae2:	50                   	push   %eax
  800ae3:	e8 cd 09 00 00       	call   8014b5 <sys_cputs>

	return b.cnt;
}
  800ae8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800aee:	c9                   	leave  
  800aef:	c3                   	ret    

00800af0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800af0:	55                   	push   %ebp
  800af1:	89 e5                	mov    %esp,%ebp
  800af3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800af6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800af9:	50                   	push   %eax
  800afa:	ff 75 08             	pushl  0x8(%ebp)
  800afd:	e8 9d ff ff ff       	call   800a9f <vcprintf>
	va_end(ap);

	return cnt;
}
  800b02:	c9                   	leave  
  800b03:	c3                   	ret    

00800b04 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
  800b0a:	83 ec 1c             	sub    $0x1c,%esp
  800b0d:	89 c7                	mov    %eax,%edi
  800b0f:	89 d6                	mov    %edx,%esi
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b17:	89 d1                	mov    %edx,%ecx
  800b19:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b1f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b22:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800b25:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b28:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800b2f:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  800b32:	72 05                	jb     800b39 <printnum+0x35>
  800b34:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800b37:	77 3e                	ja     800b77 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800b39:	83 ec 0c             	sub    $0xc,%esp
  800b3c:	ff 75 18             	pushl  0x18(%ebp)
  800b3f:	83 eb 01             	sub    $0x1,%ebx
  800b42:	53                   	push   %ebx
  800b43:	50                   	push   %eax
  800b44:	83 ec 08             	sub    $0x8,%esp
  800b47:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b4a:	ff 75 e0             	pushl  -0x20(%ebp)
  800b4d:	ff 75 dc             	pushl  -0x24(%ebp)
  800b50:	ff 75 d8             	pushl  -0x28(%ebp)
  800b53:	e8 c8 24 00 00       	call   803020 <__udivdi3>
  800b58:	83 c4 18             	add    $0x18,%esp
  800b5b:	52                   	push   %edx
  800b5c:	50                   	push   %eax
  800b5d:	89 f2                	mov    %esi,%edx
  800b5f:	89 f8                	mov    %edi,%eax
  800b61:	e8 9e ff ff ff       	call   800b04 <printnum>
  800b66:	83 c4 20             	add    $0x20,%esp
  800b69:	eb 13                	jmp    800b7e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800b6b:	83 ec 08             	sub    $0x8,%esp
  800b6e:	56                   	push   %esi
  800b6f:	ff 75 18             	pushl  0x18(%ebp)
  800b72:	ff d7                	call   *%edi
  800b74:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800b77:	83 eb 01             	sub    $0x1,%ebx
  800b7a:	85 db                	test   %ebx,%ebx
  800b7c:	7f ed                	jg     800b6b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800b7e:	83 ec 08             	sub    $0x8,%esp
  800b81:	56                   	push   %esi
  800b82:	83 ec 04             	sub    $0x4,%esp
  800b85:	ff 75 e4             	pushl  -0x1c(%ebp)
  800b88:	ff 75 e0             	pushl  -0x20(%ebp)
  800b8b:	ff 75 dc             	pushl  -0x24(%ebp)
  800b8e:	ff 75 d8             	pushl  -0x28(%ebp)
  800b91:	e8 ba 25 00 00       	call   803150 <__umoddi3>
  800b96:	83 c4 14             	add    $0x14,%esp
  800b99:	0f be 80 3b 35 80 00 	movsbl 0x80353b(%eax),%eax
  800ba0:	50                   	push   %eax
  800ba1:	ff d7                	call   *%edi
  800ba3:	83 c4 10             	add    $0x10,%esp
}
  800ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800bb1:	83 fa 01             	cmp    $0x1,%edx
  800bb4:	7e 0e                	jle    800bc4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800bb6:	8b 10                	mov    (%eax),%edx
  800bb8:	8d 4a 08             	lea    0x8(%edx),%ecx
  800bbb:	89 08                	mov    %ecx,(%eax)
  800bbd:	8b 02                	mov    (%edx),%eax
  800bbf:	8b 52 04             	mov    0x4(%edx),%edx
  800bc2:	eb 22                	jmp    800be6 <getuint+0x38>
	else if (lflag)
  800bc4:	85 d2                	test   %edx,%edx
  800bc6:	74 10                	je     800bd8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800bc8:	8b 10                	mov    (%eax),%edx
  800bca:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bcd:	89 08                	mov    %ecx,(%eax)
  800bcf:	8b 02                	mov    (%edx),%eax
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	eb 0e                	jmp    800be6 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800bd8:	8b 10                	mov    (%eax),%edx
  800bda:	8d 4a 04             	lea    0x4(%edx),%ecx
  800bdd:	89 08                	mov    %ecx,(%eax)
  800bdf:	8b 02                	mov    (%edx),%eax
  800be1:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800be6:	5d                   	pop    %ebp
  800be7:	c3                   	ret    

00800be8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800bee:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800bf2:	8b 10                	mov    (%eax),%edx
  800bf4:	3b 50 04             	cmp    0x4(%eax),%edx
  800bf7:	73 0a                	jae    800c03 <sprintputch+0x1b>
		*b->buf++ = ch;
  800bf9:	8d 4a 01             	lea    0x1(%edx),%ecx
  800bfc:	89 08                	mov    %ecx,(%eax)
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	88 02                	mov    %al,(%edx)
}
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800c0b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800c0e:	50                   	push   %eax
  800c0f:	ff 75 10             	pushl  0x10(%ebp)
  800c12:	ff 75 0c             	pushl  0xc(%ebp)
  800c15:	ff 75 08             	pushl  0x8(%ebp)
  800c18:	e8 05 00 00 00       	call   800c22 <vprintfmt>
	va_end(ap);
  800c1d:	83 c4 10             	add    $0x10,%esp
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 2c             	sub    $0x2c,%esp
  800c2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800c2e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c31:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c34:	eb 12                	jmp    800c48 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800c36:	85 c0                	test   %eax,%eax
  800c38:	0f 84 8d 03 00 00    	je     800fcb <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800c3e:	83 ec 08             	sub    $0x8,%esp
  800c41:	53                   	push   %ebx
  800c42:	50                   	push   %eax
  800c43:	ff d6                	call   *%esi
  800c45:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800c48:	83 c7 01             	add    $0x1,%edi
  800c4b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800c4f:	83 f8 25             	cmp    $0x25,%eax
  800c52:	75 e2                	jne    800c36 <vprintfmt+0x14>
  800c54:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800c58:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800c5f:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800c66:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800c6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c72:	eb 07                	jmp    800c7b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c74:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800c77:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c7b:	8d 47 01             	lea    0x1(%edi),%eax
  800c7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c81:	0f b6 07             	movzbl (%edi),%eax
  800c84:	0f b6 c8             	movzbl %al,%ecx
  800c87:	83 e8 23             	sub    $0x23,%eax
  800c8a:	3c 55                	cmp    $0x55,%al
  800c8c:	0f 87 1e 03 00 00    	ja     800fb0 <vprintfmt+0x38e>
  800c92:	0f b6 c0             	movzbl %al,%eax
  800c95:	ff 24 85 80 36 80 00 	jmp    *0x803680(,%eax,4)
  800c9c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800c9f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800ca3:	eb d6                	jmp    800c7b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ca5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ca8:	b8 00 00 00 00       	mov    $0x0,%eax
  800cad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800cb0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800cb3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800cb7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800cba:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800cbd:	83 fa 09             	cmp    $0x9,%edx
  800cc0:	77 38                	ja     800cfa <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800cc2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800cc5:	eb e9                	jmp    800cb0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800cc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800cca:	8d 48 04             	lea    0x4(%eax),%ecx
  800ccd:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800cd0:	8b 00                	mov    (%eax),%eax
  800cd2:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800cd5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800cd8:	eb 26                	jmp    800d00 <vprintfmt+0xde>
  800cda:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800cdd:	89 c8                	mov    %ecx,%eax
  800cdf:	c1 f8 1f             	sar    $0x1f,%eax
  800ce2:	f7 d0                	not    %eax
  800ce4:	21 c1                	and    %eax,%ecx
  800ce6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ce9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800cec:	eb 8d                	jmp    800c7b <vprintfmt+0x59>
  800cee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800cf1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800cf8:	eb 81                	jmp    800c7b <vprintfmt+0x59>
  800cfa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800cfd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800d00:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d04:	0f 89 71 ff ff ff    	jns    800c7b <vprintfmt+0x59>
				width = precision, precision = -1;
  800d0a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800d0d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d10:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800d17:	e9 5f ff ff ff       	jmp    800c7b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800d1c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d1f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800d22:	e9 54 ff ff ff       	jmp    800c7b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800d27:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2a:	8d 50 04             	lea    0x4(%eax),%edx
  800d2d:	89 55 14             	mov    %edx,0x14(%ebp)
  800d30:	83 ec 08             	sub    $0x8,%esp
  800d33:	53                   	push   %ebx
  800d34:	ff 30                	pushl  (%eax)
  800d36:	ff d6                	call   *%esi
			break;
  800d38:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d3b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800d3e:	e9 05 ff ff ff       	jmp    800c48 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  800d43:	8b 45 14             	mov    0x14(%ebp),%eax
  800d46:	8d 50 04             	lea    0x4(%eax),%edx
  800d49:	89 55 14             	mov    %edx,0x14(%ebp)
  800d4c:	8b 00                	mov    (%eax),%eax
  800d4e:	99                   	cltd   
  800d4f:	31 d0                	xor    %edx,%eax
  800d51:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800d53:	83 f8 0f             	cmp    $0xf,%eax
  800d56:	7f 0b                	jg     800d63 <vprintfmt+0x141>
  800d58:	8b 14 85 00 38 80 00 	mov    0x803800(,%eax,4),%edx
  800d5f:	85 d2                	test   %edx,%edx
  800d61:	75 18                	jne    800d7b <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  800d63:	50                   	push   %eax
  800d64:	68 53 35 80 00       	push   $0x803553
  800d69:	53                   	push   %ebx
  800d6a:	56                   	push   %esi
  800d6b:	e8 95 fe ff ff       	call   800c05 <printfmt>
  800d70:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d73:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800d76:	e9 cd fe ff ff       	jmp    800c48 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800d7b:	52                   	push   %edx
  800d7c:	68 5b 34 80 00       	push   $0x80345b
  800d81:	53                   	push   %ebx
  800d82:	56                   	push   %esi
  800d83:	e8 7d fe ff ff       	call   800c05 <printfmt>
  800d88:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800d8b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d8e:	e9 b5 fe ff ff       	jmp    800c48 <vprintfmt+0x26>
  800d93:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800d96:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d99:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800d9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9f:	8d 50 04             	lea    0x4(%eax),%edx
  800da2:	89 55 14             	mov    %edx,0x14(%ebp)
  800da5:	8b 38                	mov    (%eax),%edi
  800da7:	85 ff                	test   %edi,%edi
  800da9:	75 05                	jne    800db0 <vprintfmt+0x18e>
				p = "(null)";
  800dab:	bf 4c 35 80 00       	mov    $0x80354c,%edi
			if (width > 0 && padc != '-')
  800db0:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800db4:	0f 84 91 00 00 00    	je     800e4b <vprintfmt+0x229>
  800dba:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800dbe:	0f 8e 95 00 00 00    	jle    800e59 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800dc4:	83 ec 08             	sub    $0x8,%esp
  800dc7:	51                   	push   %ecx
  800dc8:	57                   	push   %edi
  800dc9:	e8 85 02 00 00       	call   801053 <strnlen>
  800dce:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800dd1:	29 c1                	sub    %eax,%ecx
  800dd3:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800dd6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800dd9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800ddd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800de0:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800de3:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800de5:	eb 0f                	jmp    800df6 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800de7:	83 ec 08             	sub    $0x8,%esp
  800dea:	53                   	push   %ebx
  800deb:	ff 75 e0             	pushl  -0x20(%ebp)
  800dee:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800df0:	83 ef 01             	sub    $0x1,%edi
  800df3:	83 c4 10             	add    $0x10,%esp
  800df6:	85 ff                	test   %edi,%edi
  800df8:	7f ed                	jg     800de7 <vprintfmt+0x1c5>
  800dfa:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800dfd:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800e00:	89 c8                	mov    %ecx,%eax
  800e02:	c1 f8 1f             	sar    $0x1f,%eax
  800e05:	f7 d0                	not    %eax
  800e07:	21 c8                	and    %ecx,%eax
  800e09:	29 c1                	sub    %eax,%ecx
  800e0b:	89 75 08             	mov    %esi,0x8(%ebp)
  800e0e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e11:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e14:	89 cb                	mov    %ecx,%ebx
  800e16:	eb 4d                	jmp    800e65 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800e18:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800e1c:	74 1b                	je     800e39 <vprintfmt+0x217>
  800e1e:	0f be c0             	movsbl %al,%eax
  800e21:	83 e8 20             	sub    $0x20,%eax
  800e24:	83 f8 5e             	cmp    $0x5e,%eax
  800e27:	76 10                	jbe    800e39 <vprintfmt+0x217>
					putch('?', putdat);
  800e29:	83 ec 08             	sub    $0x8,%esp
  800e2c:	ff 75 0c             	pushl  0xc(%ebp)
  800e2f:	6a 3f                	push   $0x3f
  800e31:	ff 55 08             	call   *0x8(%ebp)
  800e34:	83 c4 10             	add    $0x10,%esp
  800e37:	eb 0d                	jmp    800e46 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	ff 75 0c             	pushl  0xc(%ebp)
  800e3f:	52                   	push   %edx
  800e40:	ff 55 08             	call   *0x8(%ebp)
  800e43:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800e46:	83 eb 01             	sub    $0x1,%ebx
  800e49:	eb 1a                	jmp    800e65 <vprintfmt+0x243>
  800e4b:	89 75 08             	mov    %esi,0x8(%ebp)
  800e4e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e51:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e54:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e57:	eb 0c                	jmp    800e65 <vprintfmt+0x243>
  800e59:	89 75 08             	mov    %esi,0x8(%ebp)
  800e5c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800e5f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800e62:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800e65:	83 c7 01             	add    $0x1,%edi
  800e68:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800e6c:	0f be d0             	movsbl %al,%edx
  800e6f:	85 d2                	test   %edx,%edx
  800e71:	74 23                	je     800e96 <vprintfmt+0x274>
  800e73:	85 f6                	test   %esi,%esi
  800e75:	78 a1                	js     800e18 <vprintfmt+0x1f6>
  800e77:	83 ee 01             	sub    $0x1,%esi
  800e7a:	79 9c                	jns    800e18 <vprintfmt+0x1f6>
  800e7c:	89 df                	mov    %ebx,%edi
  800e7e:	8b 75 08             	mov    0x8(%ebp),%esi
  800e81:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e84:	eb 18                	jmp    800e9e <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800e86:	83 ec 08             	sub    $0x8,%esp
  800e89:	53                   	push   %ebx
  800e8a:	6a 20                	push   $0x20
  800e8c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800e8e:	83 ef 01             	sub    $0x1,%edi
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	eb 08                	jmp    800e9e <vprintfmt+0x27c>
  800e96:	89 df                	mov    %ebx,%edi
  800e98:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e9e:	85 ff                	test   %edi,%edi
  800ea0:	7f e4                	jg     800e86 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800ea2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800ea5:	e9 9e fd ff ff       	jmp    800c48 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800eaa:	83 fa 01             	cmp    $0x1,%edx
  800ead:	7e 16                	jle    800ec5 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800eaf:	8b 45 14             	mov    0x14(%ebp),%eax
  800eb2:	8d 50 08             	lea    0x8(%eax),%edx
  800eb5:	89 55 14             	mov    %edx,0x14(%ebp)
  800eb8:	8b 50 04             	mov    0x4(%eax),%edx
  800ebb:	8b 00                	mov    (%eax),%eax
  800ebd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ec0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800ec3:	eb 32                	jmp    800ef7 <vprintfmt+0x2d5>
	else if (lflag)
  800ec5:	85 d2                	test   %edx,%edx
  800ec7:	74 18                	je     800ee1 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800ec9:	8b 45 14             	mov    0x14(%ebp),%eax
  800ecc:	8d 50 04             	lea    0x4(%eax),%edx
  800ecf:	89 55 14             	mov    %edx,0x14(%ebp)
  800ed2:	8b 00                	mov    (%eax),%eax
  800ed4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ed7:	89 c1                	mov    %eax,%ecx
  800ed9:	c1 f9 1f             	sar    $0x1f,%ecx
  800edc:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800edf:	eb 16                	jmp    800ef7 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800ee1:	8b 45 14             	mov    0x14(%ebp),%eax
  800ee4:	8d 50 04             	lea    0x4(%eax),%edx
  800ee7:	89 55 14             	mov    %edx,0x14(%ebp)
  800eea:	8b 00                	mov    (%eax),%eax
  800eec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	c1 f9 1f             	sar    $0x1f,%ecx
  800ef4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ef7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800efa:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800efd:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800f02:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f06:	79 74                	jns    800f7c <vprintfmt+0x35a>
				putch('-', putdat);
  800f08:	83 ec 08             	sub    $0x8,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	6a 2d                	push   $0x2d
  800f0e:	ff d6                	call   *%esi
				num = -(long long) num;
  800f10:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800f13:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800f16:	f7 d8                	neg    %eax
  800f18:	83 d2 00             	adc    $0x0,%edx
  800f1b:	f7 da                	neg    %edx
  800f1d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800f20:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800f25:	eb 55                	jmp    800f7c <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800f27:	8d 45 14             	lea    0x14(%ebp),%eax
  800f2a:	e8 7f fc ff ff       	call   800bae <getuint>
			base = 10;
  800f2f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800f34:	eb 46                	jmp    800f7c <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800f36:	8d 45 14             	lea    0x14(%ebp),%eax
  800f39:	e8 70 fc ff ff       	call   800bae <getuint>
			base = 8;
  800f3e:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800f43:	eb 37                	jmp    800f7c <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800f45:	83 ec 08             	sub    $0x8,%esp
  800f48:	53                   	push   %ebx
  800f49:	6a 30                	push   $0x30
  800f4b:	ff d6                	call   *%esi
			putch('x', putdat);
  800f4d:	83 c4 08             	add    $0x8,%esp
  800f50:	53                   	push   %ebx
  800f51:	6a 78                	push   $0x78
  800f53:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800f55:	8b 45 14             	mov    0x14(%ebp),%eax
  800f58:	8d 50 04             	lea    0x4(%eax),%edx
  800f5b:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800f5e:	8b 00                	mov    (%eax),%eax
  800f60:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800f65:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800f68:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800f6d:	eb 0d                	jmp    800f7c <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800f6f:	8d 45 14             	lea    0x14(%ebp),%eax
  800f72:	e8 37 fc ff ff       	call   800bae <getuint>
			base = 16;
  800f77:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800f83:	57                   	push   %edi
  800f84:	ff 75 e0             	pushl  -0x20(%ebp)
  800f87:	51                   	push   %ecx
  800f88:	52                   	push   %edx
  800f89:	50                   	push   %eax
  800f8a:	89 da                	mov    %ebx,%edx
  800f8c:	89 f0                	mov    %esi,%eax
  800f8e:	e8 71 fb ff ff       	call   800b04 <printnum>
			break;
  800f93:	83 c4 20             	add    $0x20,%esp
  800f96:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800f99:	e9 aa fc ff ff       	jmp    800c48 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800f9e:	83 ec 08             	sub    $0x8,%esp
  800fa1:	53                   	push   %ebx
  800fa2:	51                   	push   %ecx
  800fa3:	ff d6                	call   *%esi
			break;
  800fa5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800fa8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800fab:	e9 98 fc ff ff       	jmp    800c48 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800fb0:	83 ec 08             	sub    $0x8,%esp
  800fb3:	53                   	push   %ebx
  800fb4:	6a 25                	push   $0x25
  800fb6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800fb8:	83 c4 10             	add    $0x10,%esp
  800fbb:	eb 03                	jmp    800fc0 <vprintfmt+0x39e>
  800fbd:	83 ef 01             	sub    $0x1,%edi
  800fc0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800fc4:	75 f7                	jne    800fbd <vprintfmt+0x39b>
  800fc6:	e9 7d fc ff ff       	jmp    800c48 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800fcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fce:	5b                   	pop    %ebx
  800fcf:	5e                   	pop    %esi
  800fd0:	5f                   	pop    %edi
  800fd1:	5d                   	pop    %ebp
  800fd2:	c3                   	ret    

00800fd3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800fd3:	55                   	push   %ebp
  800fd4:	89 e5                	mov    %esp,%ebp
  800fd6:	83 ec 18             	sub    $0x18,%esp
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
  800fdc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800fdf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800fe2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800fe6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800fe9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ff0:	85 c0                	test   %eax,%eax
  800ff2:	74 26                	je     80101a <vsnprintf+0x47>
  800ff4:	85 d2                	test   %edx,%edx
  800ff6:	7e 22                	jle    80101a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ff8:	ff 75 14             	pushl  0x14(%ebp)
  800ffb:	ff 75 10             	pushl  0x10(%ebp)
  800ffe:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801001:	50                   	push   %eax
  801002:	68 e8 0b 80 00       	push   $0x800be8
  801007:	e8 16 fc ff ff       	call   800c22 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80100c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80100f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	eb 05                	jmp    80101f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80101a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801027:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80102a:	50                   	push   %eax
  80102b:	ff 75 10             	pushl  0x10(%ebp)
  80102e:	ff 75 0c             	pushl  0xc(%ebp)
  801031:	ff 75 08             	pushl  0x8(%ebp)
  801034:	e8 9a ff ff ff       	call   800fd3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801041:	b8 00 00 00 00       	mov    $0x0,%eax
  801046:	eb 03                	jmp    80104b <strlen+0x10>
		n++;
  801048:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80104b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80104f:	75 f7                	jne    801048 <strlen+0xd>
		n++;
	return n;
}
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801059:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80105c:	ba 00 00 00 00       	mov    $0x0,%edx
  801061:	eb 03                	jmp    801066 <strnlen+0x13>
		n++;
  801063:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801066:	39 c2                	cmp    %eax,%edx
  801068:	74 08                	je     801072 <strnlen+0x1f>
  80106a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80106e:	75 f3                	jne    801063 <strnlen+0x10>
  801070:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	53                   	push   %ebx
  801078:	8b 45 08             	mov    0x8(%ebp),%eax
  80107b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80107e:	89 c2                	mov    %eax,%edx
  801080:	83 c2 01             	add    $0x1,%edx
  801083:	83 c1 01             	add    $0x1,%ecx
  801086:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80108a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80108d:	84 db                	test   %bl,%bl
  80108f:	75 ef                	jne    801080 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801091:	5b                   	pop    %ebx
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	53                   	push   %ebx
  801098:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80109b:	53                   	push   %ebx
  80109c:	e8 9a ff ff ff       	call   80103b <strlen>
  8010a1:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8010a4:	ff 75 0c             	pushl  0xc(%ebp)
  8010a7:	01 d8                	add    %ebx,%eax
  8010a9:	50                   	push   %eax
  8010aa:	e8 c5 ff ff ff       	call   801074 <strcpy>
	return dst;
}
  8010af:	89 d8                	mov    %ebx,%eax
  8010b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    

008010b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	56                   	push   %esi
  8010ba:	53                   	push   %ebx
  8010bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8010be:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010c1:	89 f3                	mov    %esi,%ebx
  8010c3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010c6:	89 f2                	mov    %esi,%edx
  8010c8:	eb 0f                	jmp    8010d9 <strncpy+0x23>
		*dst++ = *src;
  8010ca:	83 c2 01             	add    $0x1,%edx
  8010cd:	0f b6 01             	movzbl (%ecx),%eax
  8010d0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8010d3:	80 39 01             	cmpb   $0x1,(%ecx)
  8010d6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8010d9:	39 da                	cmp    %ebx,%edx
  8010db:	75 ed                	jne    8010ca <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8010dd:	89 f0                	mov    %esi,%eax
  8010df:	5b                   	pop    %ebx
  8010e0:	5e                   	pop    %esi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    

008010e3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8010e3:	55                   	push   %ebp
  8010e4:	89 e5                	mov    %esp,%ebp
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8010eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ee:	8b 55 10             	mov    0x10(%ebp),%edx
  8010f1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8010f3:	85 d2                	test   %edx,%edx
  8010f5:	74 21                	je     801118 <strlcpy+0x35>
  8010f7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8010fb:	89 f2                	mov    %esi,%edx
  8010fd:	eb 09                	jmp    801108 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8010ff:	83 c2 01             	add    $0x1,%edx
  801102:	83 c1 01             	add    $0x1,%ecx
  801105:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801108:	39 c2                	cmp    %eax,%edx
  80110a:	74 09                	je     801115 <strlcpy+0x32>
  80110c:	0f b6 19             	movzbl (%ecx),%ebx
  80110f:	84 db                	test   %bl,%bl
  801111:	75 ec                	jne    8010ff <strlcpy+0x1c>
  801113:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801115:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801118:	29 f0                	sub    %esi,%eax
}
  80111a:	5b                   	pop    %ebx
  80111b:	5e                   	pop    %esi
  80111c:	5d                   	pop    %ebp
  80111d:	c3                   	ret    

0080111e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80111e:	55                   	push   %ebp
  80111f:	89 e5                	mov    %esp,%ebp
  801121:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801124:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801127:	eb 06                	jmp    80112f <strcmp+0x11>
		p++, q++;
  801129:	83 c1 01             	add    $0x1,%ecx
  80112c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80112f:	0f b6 01             	movzbl (%ecx),%eax
  801132:	84 c0                	test   %al,%al
  801134:	74 04                	je     80113a <strcmp+0x1c>
  801136:	3a 02                	cmp    (%edx),%al
  801138:	74 ef                	je     801129 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80113a:	0f b6 c0             	movzbl %al,%eax
  80113d:	0f b6 12             	movzbl (%edx),%edx
  801140:	29 d0                	sub    %edx,%eax
}
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	53                   	push   %ebx
  801148:	8b 45 08             	mov    0x8(%ebp),%eax
  80114b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80114e:	89 c3                	mov    %eax,%ebx
  801150:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801153:	eb 06                	jmp    80115b <strncmp+0x17>
		n--, p++, q++;
  801155:	83 c0 01             	add    $0x1,%eax
  801158:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80115b:	39 d8                	cmp    %ebx,%eax
  80115d:	74 15                	je     801174 <strncmp+0x30>
  80115f:	0f b6 08             	movzbl (%eax),%ecx
  801162:	84 c9                	test   %cl,%cl
  801164:	74 04                	je     80116a <strncmp+0x26>
  801166:	3a 0a                	cmp    (%edx),%cl
  801168:	74 eb                	je     801155 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80116a:	0f b6 00             	movzbl (%eax),%eax
  80116d:	0f b6 12             	movzbl (%edx),%edx
  801170:	29 d0                	sub    %edx,%eax
  801172:	eb 05                	jmp    801179 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801174:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801179:	5b                   	pop    %ebx
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	8b 45 08             	mov    0x8(%ebp),%eax
  801182:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801186:	eb 07                	jmp    80118f <strchr+0x13>
		if (*s == c)
  801188:	38 ca                	cmp    %cl,%dl
  80118a:	74 0f                	je     80119b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80118c:	83 c0 01             	add    $0x1,%eax
  80118f:	0f b6 10             	movzbl (%eax),%edx
  801192:	84 d2                	test   %dl,%dl
  801194:	75 f2                	jne    801188 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801196:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80119b:	5d                   	pop    %ebp
  80119c:	c3                   	ret    

0080119d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8011a7:	eb 03                	jmp    8011ac <strfind+0xf>
  8011a9:	83 c0 01             	add    $0x1,%eax
  8011ac:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8011af:	84 d2                	test   %dl,%dl
  8011b1:	74 04                	je     8011b7 <strfind+0x1a>
  8011b3:	38 ca                	cmp    %cl,%dl
  8011b5:	75 f2                	jne    8011a9 <strfind+0xc>
			break;
	return (char *) s;
}
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	57                   	push   %edi
  8011bd:	56                   	push   %esi
  8011be:	53                   	push   %ebx
  8011bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011c2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  8011c5:	85 c9                	test   %ecx,%ecx
  8011c7:	74 36                	je     8011ff <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8011c9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8011cf:	75 28                	jne    8011f9 <memset+0x40>
  8011d1:	f6 c1 03             	test   $0x3,%cl
  8011d4:	75 23                	jne    8011f9 <memset+0x40>
		c &= 0xFF;
  8011d6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8011da:	89 d3                	mov    %edx,%ebx
  8011dc:	c1 e3 08             	shl    $0x8,%ebx
  8011df:	89 d6                	mov    %edx,%esi
  8011e1:	c1 e6 18             	shl    $0x18,%esi
  8011e4:	89 d0                	mov    %edx,%eax
  8011e6:	c1 e0 10             	shl    $0x10,%eax
  8011e9:	09 f0                	or     %esi,%eax
  8011eb:	09 c2                	or     %eax,%edx
  8011ed:	89 d0                	mov    %edx,%eax
  8011ef:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8011f1:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  8011f4:	fc                   	cld    
  8011f5:	f3 ab                	rep stos %eax,%es:(%edi)
  8011f7:	eb 06                	jmp    8011ff <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8011f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011fc:	fc                   	cld    
  8011fd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8011ff:	89 f8                	mov    %edi,%eax
  801201:	5b                   	pop    %ebx
  801202:	5e                   	pop    %esi
  801203:	5f                   	pop    %edi
  801204:	5d                   	pop    %ebp
  801205:	c3                   	ret    

00801206 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801206:	55                   	push   %ebp
  801207:	89 e5                	mov    %esp,%ebp
  801209:	57                   	push   %edi
  80120a:	56                   	push   %esi
  80120b:	8b 45 08             	mov    0x8(%ebp),%eax
  80120e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801211:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801214:	39 c6                	cmp    %eax,%esi
  801216:	73 35                	jae    80124d <memmove+0x47>
  801218:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80121b:	39 d0                	cmp    %edx,%eax
  80121d:	73 2e                	jae    80124d <memmove+0x47>
		s += n;
		d += n;
  80121f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  801222:	89 d6                	mov    %edx,%esi
  801224:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801226:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80122c:	75 13                	jne    801241 <memmove+0x3b>
  80122e:	f6 c1 03             	test   $0x3,%cl
  801231:	75 0e                	jne    801241 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801233:	83 ef 04             	sub    $0x4,%edi
  801236:	8d 72 fc             	lea    -0x4(%edx),%esi
  801239:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  80123c:	fd                   	std    
  80123d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80123f:	eb 09                	jmp    80124a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801241:	83 ef 01             	sub    $0x1,%edi
  801244:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801247:	fd                   	std    
  801248:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80124a:	fc                   	cld    
  80124b:	eb 1d                	jmp    80126a <memmove+0x64>
  80124d:	89 f2                	mov    %esi,%edx
  80124f:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801251:	f6 c2 03             	test   $0x3,%dl
  801254:	75 0f                	jne    801265 <memmove+0x5f>
  801256:	f6 c1 03             	test   $0x3,%cl
  801259:	75 0a                	jne    801265 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80125b:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  80125e:	89 c7                	mov    %eax,%edi
  801260:	fc                   	cld    
  801261:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801263:	eb 05                	jmp    80126a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801265:	89 c7                	mov    %eax,%edi
  801267:	fc                   	cld    
  801268:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80126a:	5e                   	pop    %esi
  80126b:	5f                   	pop    %edi
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801271:	ff 75 10             	pushl  0x10(%ebp)
  801274:	ff 75 0c             	pushl  0xc(%ebp)
  801277:	ff 75 08             	pushl  0x8(%ebp)
  80127a:	e8 87 ff ff ff       	call   801206 <memmove>
}
  80127f:	c9                   	leave  
  801280:	c3                   	ret    

00801281 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801281:	55                   	push   %ebp
  801282:	89 e5                	mov    %esp,%ebp
  801284:	56                   	push   %esi
  801285:	53                   	push   %ebx
  801286:	8b 45 08             	mov    0x8(%ebp),%eax
  801289:	8b 55 0c             	mov    0xc(%ebp),%edx
  80128c:	89 c6                	mov    %eax,%esi
  80128e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801291:	eb 1a                	jmp    8012ad <memcmp+0x2c>
		if (*s1 != *s2)
  801293:	0f b6 08             	movzbl (%eax),%ecx
  801296:	0f b6 1a             	movzbl (%edx),%ebx
  801299:	38 d9                	cmp    %bl,%cl
  80129b:	74 0a                	je     8012a7 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80129d:	0f b6 c1             	movzbl %cl,%eax
  8012a0:	0f b6 db             	movzbl %bl,%ebx
  8012a3:	29 d8                	sub    %ebx,%eax
  8012a5:	eb 0f                	jmp    8012b6 <memcmp+0x35>
		s1++, s2++;
  8012a7:	83 c0 01             	add    $0x1,%eax
  8012aa:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8012ad:	39 f0                	cmp    %esi,%eax
  8012af:	75 e2                	jne    801293 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8012b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012b6:	5b                   	pop    %ebx
  8012b7:	5e                   	pop    %esi
  8012b8:	5d                   	pop    %ebp
  8012b9:	c3                   	ret    

008012ba <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8012ba:	55                   	push   %ebp
  8012bb:	89 e5                	mov    %esp,%ebp
  8012bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8012c3:	89 c2                	mov    %eax,%edx
  8012c5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8012c8:	eb 07                	jmp    8012d1 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  8012ca:	38 08                	cmp    %cl,(%eax)
  8012cc:	74 07                	je     8012d5 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8012ce:	83 c0 01             	add    $0x1,%eax
  8012d1:	39 d0                	cmp    %edx,%eax
  8012d3:	72 f5                	jb     8012ca <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8012d5:	5d                   	pop    %ebp
  8012d6:	c3                   	ret    

008012d7 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8012d7:	55                   	push   %ebp
  8012d8:	89 e5                	mov    %esp,%ebp
  8012da:	57                   	push   %edi
  8012db:	56                   	push   %esi
  8012dc:	53                   	push   %ebx
  8012dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012e3:	eb 03                	jmp    8012e8 <strtol+0x11>
		s++;
  8012e5:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8012e8:	0f b6 01             	movzbl (%ecx),%eax
  8012eb:	3c 09                	cmp    $0x9,%al
  8012ed:	74 f6                	je     8012e5 <strtol+0xe>
  8012ef:	3c 20                	cmp    $0x20,%al
  8012f1:	74 f2                	je     8012e5 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8012f3:	3c 2b                	cmp    $0x2b,%al
  8012f5:	75 0a                	jne    801301 <strtol+0x2a>
		s++;
  8012f7:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8012fa:	bf 00 00 00 00       	mov    $0x0,%edi
  8012ff:	eb 10                	jmp    801311 <strtol+0x3a>
  801301:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801306:	3c 2d                	cmp    $0x2d,%al
  801308:	75 07                	jne    801311 <strtol+0x3a>
		s++, neg = 1;
  80130a:	8d 49 01             	lea    0x1(%ecx),%ecx
  80130d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801311:	85 db                	test   %ebx,%ebx
  801313:	0f 94 c0             	sete   %al
  801316:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80131c:	75 19                	jne    801337 <strtol+0x60>
  80131e:	80 39 30             	cmpb   $0x30,(%ecx)
  801321:	75 14                	jne    801337 <strtol+0x60>
  801323:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801327:	0f 85 8a 00 00 00    	jne    8013b7 <strtol+0xe0>
		s += 2, base = 16;
  80132d:	83 c1 02             	add    $0x2,%ecx
  801330:	bb 10 00 00 00       	mov    $0x10,%ebx
  801335:	eb 16                	jmp    80134d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801337:	84 c0                	test   %al,%al
  801339:	74 12                	je     80134d <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80133b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801340:	80 39 30             	cmpb   $0x30,(%ecx)
  801343:	75 08                	jne    80134d <strtol+0x76>
		s++, base = 8;
  801345:	83 c1 01             	add    $0x1,%ecx
  801348:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80134d:	b8 00 00 00 00       	mov    $0x0,%eax
  801352:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801355:	0f b6 11             	movzbl (%ecx),%edx
  801358:	8d 72 d0             	lea    -0x30(%edx),%esi
  80135b:	89 f3                	mov    %esi,%ebx
  80135d:	80 fb 09             	cmp    $0x9,%bl
  801360:	77 08                	ja     80136a <strtol+0x93>
			dig = *s - '0';
  801362:	0f be d2             	movsbl %dl,%edx
  801365:	83 ea 30             	sub    $0x30,%edx
  801368:	eb 22                	jmp    80138c <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  80136a:	8d 72 9f             	lea    -0x61(%edx),%esi
  80136d:	89 f3                	mov    %esi,%ebx
  80136f:	80 fb 19             	cmp    $0x19,%bl
  801372:	77 08                	ja     80137c <strtol+0xa5>
			dig = *s - 'a' + 10;
  801374:	0f be d2             	movsbl %dl,%edx
  801377:	83 ea 57             	sub    $0x57,%edx
  80137a:	eb 10                	jmp    80138c <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  80137c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80137f:	89 f3                	mov    %esi,%ebx
  801381:	80 fb 19             	cmp    $0x19,%bl
  801384:	77 16                	ja     80139c <strtol+0xc5>
			dig = *s - 'A' + 10;
  801386:	0f be d2             	movsbl %dl,%edx
  801389:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80138c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80138f:	7d 0f                	jge    8013a0 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801391:	83 c1 01             	add    $0x1,%ecx
  801394:	0f af 45 10          	imul   0x10(%ebp),%eax
  801398:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80139a:	eb b9                	jmp    801355 <strtol+0x7e>
  80139c:	89 c2                	mov    %eax,%edx
  80139e:	eb 02                	jmp    8013a2 <strtol+0xcb>
  8013a0:	89 c2                	mov    %eax,%edx

	if (endptr)
  8013a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013a6:	74 05                	je     8013ad <strtol+0xd6>
		*endptr = (char *) s;
  8013a8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013ab:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8013ad:	85 ff                	test   %edi,%edi
  8013af:	74 0c                	je     8013bd <strtol+0xe6>
  8013b1:	89 d0                	mov    %edx,%eax
  8013b3:	f7 d8                	neg    %eax
  8013b5:	eb 06                	jmp    8013bd <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8013b7:	84 c0                	test   %al,%al
  8013b9:	75 8a                	jne    801345 <strtol+0x6e>
  8013bb:	eb 90                	jmp    80134d <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  8013bd:	5b                   	pop    %ebx
  8013be:	5e                   	pop    %esi
  8013bf:	5f                   	pop    %edi
  8013c0:	5d                   	pop    %ebp
  8013c1:	c3                   	ret    

008013c2 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8013c2:	55                   	push   %ebp
  8013c3:	89 e5                	mov    %esp,%ebp
  8013c5:	57                   	push   %edi
  8013c6:	56                   	push   %esi
  8013c7:	53                   	push   %ebx
  8013c8:	83 ec 0c             	sub    $0xc,%esp
  8013cb:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL) {
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	74 13                	je     8013e5 <readline+0x23>
#if JOS_KERNEL
		cprintf("%s", prompt);
#else
		fprintf(1, "%s", prompt);
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	50                   	push   %eax
  8013d6:	68 5b 34 80 00       	push   $0x80345b
  8013db:	6a 01                	push   $0x1
  8013dd:	e8 cb 10 00 00       	call   8024ad <fprintf>
  8013e2:	83 c4 10             	add    $0x10,%esp
#endif
	}

	i = 0;
	echoing = iscons(0);
  8013e5:	83 ec 0c             	sub    $0xc,%esp
  8013e8:	6a 00                	push   $0x0
  8013ea:	e8 42 f5 ff ff       	call   800931 <iscons>
  8013ef:	89 c7                	mov    %eax,%edi
  8013f1:	83 c4 10             	add    $0x10,%esp
#else
		fprintf(1, "%s", prompt);
#endif
	}

	i = 0;
  8013f4:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
  8013f9:	e8 08 f5 ff ff       	call   800906 <getchar>
  8013fe:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  801400:	85 c0                	test   %eax,%eax
  801402:	79 29                	jns    80142d <readline+0x6b>
			if (c != -E_EOF)
				cprintf("read error: %i\n", c);
			return NULL;
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
  801409:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80140c:	0f 84 9b 00 00 00    	je     8014ad <readline+0xeb>
				cprintf("read error: %i\n", c);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	53                   	push   %ebx
  801416:	68 5f 38 80 00       	push   $0x80385f
  80141b:	e8 d0 f6 ff ff       	call   800af0 <cprintf>
  801420:	83 c4 10             	add    $0x10,%esp
			return NULL;
  801423:	b8 00 00 00 00       	mov    $0x0,%eax
  801428:	e9 80 00 00 00       	jmp    8014ad <readline+0xeb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  80142d:	83 f8 7f             	cmp    $0x7f,%eax
  801430:	0f 94 c2             	sete   %dl
  801433:	83 f8 08             	cmp    $0x8,%eax
  801436:	0f 94 c0             	sete   %al
  801439:	08 c2                	or     %al,%dl
  80143b:	74 1a                	je     801457 <readline+0x95>
  80143d:	85 f6                	test   %esi,%esi
  80143f:	7e 16                	jle    801457 <readline+0x95>
			if (echoing)
  801441:	85 ff                	test   %edi,%edi
  801443:	74 0d                	je     801452 <readline+0x90>
				cputchar('\b');
  801445:	83 ec 0c             	sub    $0xc,%esp
  801448:	6a 08                	push   $0x8
  80144a:	e8 9b f4 ff ff       	call   8008ea <cputchar>
  80144f:	83 c4 10             	add    $0x10,%esp
			i--;
  801452:	83 ee 01             	sub    $0x1,%esi
  801455:	eb a2                	jmp    8013f9 <readline+0x37>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801457:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80145d:	7f 23                	jg     801482 <readline+0xc0>
  80145f:	83 fb 1f             	cmp    $0x1f,%ebx
  801462:	7e 1e                	jle    801482 <readline+0xc0>
			if (echoing)
  801464:	85 ff                	test   %edi,%edi
  801466:	74 0c                	je     801474 <readline+0xb2>
				cputchar(c);
  801468:	83 ec 0c             	sub    $0xc,%esp
  80146b:	53                   	push   %ebx
  80146c:	e8 79 f4 ff ff       	call   8008ea <cputchar>
  801471:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  801474:	88 9e 40 50 80 00    	mov    %bl,0x805040(%esi)
  80147a:	8d 76 01             	lea    0x1(%esi),%esi
  80147d:	e9 77 ff ff ff       	jmp    8013f9 <readline+0x37>
		} else if (c == '\n' || c == '\r') {
  801482:	83 fb 0d             	cmp    $0xd,%ebx
  801485:	74 09                	je     801490 <readline+0xce>
  801487:	83 fb 0a             	cmp    $0xa,%ebx
  80148a:	0f 85 69 ff ff ff    	jne    8013f9 <readline+0x37>
			if (echoing)
  801490:	85 ff                	test   %edi,%edi
  801492:	74 0d                	je     8014a1 <readline+0xdf>
				cputchar('\n');
  801494:	83 ec 0c             	sub    $0xc,%esp
  801497:	6a 0a                	push   $0xa
  801499:	e8 4c f4 ff ff       	call   8008ea <cputchar>
  80149e:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
  8014a1:	c6 86 40 50 80 00 00 	movb   $0x0,0x805040(%esi)
			return buf;
  8014a8:	b8 40 50 80 00       	mov    $0x805040,%eax
		}
	}
}
  8014ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b0:	5b                   	pop    %ebx
  8014b1:	5e                   	pop    %esi
  8014b2:	5f                   	pop    %edi
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	57                   	push   %edi
  8014b9:	56                   	push   %esi
  8014ba:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8014c6:	89 c3                	mov    %eax,%ebx
  8014c8:	89 c7                	mov    %eax,%edi
  8014ca:	89 c6                	mov    %eax,%esi
  8014cc:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8014ce:	5b                   	pop    %ebx
  8014cf:	5e                   	pop    %esi
  8014d0:	5f                   	pop    %edi
  8014d1:	5d                   	pop    %ebp
  8014d2:	c3                   	ret    

008014d3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8014d3:	55                   	push   %ebp
  8014d4:	89 e5                	mov    %esp,%ebp
  8014d6:	57                   	push   %edi
  8014d7:	56                   	push   %esi
  8014d8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014de:	b8 01 00 00 00       	mov    $0x1,%eax
  8014e3:	89 d1                	mov    %edx,%ecx
  8014e5:	89 d3                	mov    %edx,%ebx
  8014e7:	89 d7                	mov    %edx,%edi
  8014e9:	89 d6                	mov    %edx,%esi
  8014eb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8014ed:	5b                   	pop    %ebx
  8014ee:	5e                   	pop    %esi
  8014ef:	5f                   	pop    %edi
  8014f0:	5d                   	pop    %ebp
  8014f1:	c3                   	ret    

008014f2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8014f2:	55                   	push   %ebp
  8014f3:	89 e5                	mov    %esp,%ebp
  8014f5:	57                   	push   %edi
  8014f6:	56                   	push   %esi
  8014f7:	53                   	push   %ebx
  8014f8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801500:	b8 03 00 00 00       	mov    $0x3,%eax
  801505:	8b 55 08             	mov    0x8(%ebp),%edx
  801508:	89 cb                	mov    %ecx,%ebx
  80150a:	89 cf                	mov    %ecx,%edi
  80150c:	89 ce                	mov    %ecx,%esi
  80150e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801510:	85 c0                	test   %eax,%eax
  801512:	7e 17                	jle    80152b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801514:	83 ec 0c             	sub    $0xc,%esp
  801517:	50                   	push   %eax
  801518:	6a 03                	push   $0x3
  80151a:	68 6f 38 80 00       	push   $0x80386f
  80151f:	6a 23                	push   $0x23
  801521:	68 8c 38 80 00       	push   $0x80388c
  801526:	e8 ec f4 ff ff       	call   800a17 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80152b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5f                   	pop    %edi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	57                   	push   %edi
  801537:	56                   	push   %esi
  801538:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801539:	ba 00 00 00 00       	mov    $0x0,%edx
  80153e:	b8 02 00 00 00       	mov    $0x2,%eax
  801543:	89 d1                	mov    %edx,%ecx
  801545:	89 d3                	mov    %edx,%ebx
  801547:	89 d7                	mov    %edx,%edi
  801549:	89 d6                	mov    %edx,%esi
  80154b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80154d:	5b                   	pop    %ebx
  80154e:	5e                   	pop    %esi
  80154f:	5f                   	pop    %edi
  801550:	5d                   	pop    %ebp
  801551:	c3                   	ret    

00801552 <sys_yield>:

void
sys_yield(void)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	57                   	push   %edi
  801556:	56                   	push   %esi
  801557:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801558:	ba 00 00 00 00       	mov    $0x0,%edx
  80155d:	b8 0b 00 00 00       	mov    $0xb,%eax
  801562:	89 d1                	mov    %edx,%ecx
  801564:	89 d3                	mov    %edx,%ebx
  801566:	89 d7                	mov    %edx,%edi
  801568:	89 d6                	mov    %edx,%esi
  80156a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80156c:	5b                   	pop    %ebx
  80156d:	5e                   	pop    %esi
  80156e:	5f                   	pop    %edi
  80156f:	5d                   	pop    %ebp
  801570:	c3                   	ret    

00801571 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801571:	55                   	push   %ebp
  801572:	89 e5                	mov    %esp,%ebp
  801574:	57                   	push   %edi
  801575:	56                   	push   %esi
  801576:	53                   	push   %ebx
  801577:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80157a:	be 00 00 00 00       	mov    $0x0,%esi
  80157f:	b8 04 00 00 00       	mov    $0x4,%eax
  801584:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801587:	8b 55 08             	mov    0x8(%ebp),%edx
  80158a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80158d:	89 f7                	mov    %esi,%edi
  80158f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801591:	85 c0                	test   %eax,%eax
  801593:	7e 17                	jle    8015ac <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	50                   	push   %eax
  801599:	6a 04                	push   $0x4
  80159b:	68 6f 38 80 00       	push   $0x80386f
  8015a0:	6a 23                	push   $0x23
  8015a2:	68 8c 38 80 00       	push   $0x80388c
  8015a7:	e8 6b f4 ff ff       	call   800a17 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8015ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015af:	5b                   	pop    %ebx
  8015b0:	5e                   	pop    %esi
  8015b1:	5f                   	pop    %edi
  8015b2:	5d                   	pop    %ebp
  8015b3:	c3                   	ret    

008015b4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	57                   	push   %edi
  8015b8:	56                   	push   %esi
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8015cb:	8b 7d 14             	mov    0x14(%ebp),%edi
  8015ce:	8b 75 18             	mov    0x18(%ebp),%esi
  8015d1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	7e 17                	jle    8015ee <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	50                   	push   %eax
  8015db:	6a 05                	push   $0x5
  8015dd:	68 6f 38 80 00       	push   $0x80386f
  8015e2:	6a 23                	push   $0x23
  8015e4:	68 8c 38 80 00       	push   $0x80388c
  8015e9:	e8 29 f4 ff ff       	call   800a17 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8015ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5f                   	pop    %edi
  8015f4:	5d                   	pop    %ebp
  8015f5:	c3                   	ret    

008015f6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	57                   	push   %edi
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8015ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801604:	b8 06 00 00 00       	mov    $0x6,%eax
  801609:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80160c:	8b 55 08             	mov    0x8(%ebp),%edx
  80160f:	89 df                	mov    %ebx,%edi
  801611:	89 de                	mov    %ebx,%esi
  801613:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801615:	85 c0                	test   %eax,%eax
  801617:	7e 17                	jle    801630 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	50                   	push   %eax
  80161d:	6a 06                	push   $0x6
  80161f:	68 6f 38 80 00       	push   $0x80386f
  801624:	6a 23                	push   $0x23
  801626:	68 8c 38 80 00       	push   $0x80388c
  80162b:	e8 e7 f3 ff ff       	call   800a17 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801630:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801633:	5b                   	pop    %ebx
  801634:	5e                   	pop    %esi
  801635:	5f                   	pop    %edi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    

00801638 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	57                   	push   %edi
  80163c:	56                   	push   %esi
  80163d:	53                   	push   %ebx
  80163e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801641:	bb 00 00 00 00       	mov    $0x0,%ebx
  801646:	b8 08 00 00 00       	mov    $0x8,%eax
  80164b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80164e:	8b 55 08             	mov    0x8(%ebp),%edx
  801651:	89 df                	mov    %ebx,%edi
  801653:	89 de                	mov    %ebx,%esi
  801655:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801657:	85 c0                	test   %eax,%eax
  801659:	7e 17                	jle    801672 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80165b:	83 ec 0c             	sub    $0xc,%esp
  80165e:	50                   	push   %eax
  80165f:	6a 08                	push   $0x8
  801661:	68 6f 38 80 00       	push   $0x80386f
  801666:	6a 23                	push   $0x23
  801668:	68 8c 38 80 00       	push   $0x80388c
  80166d:	e8 a5 f3 ff ff       	call   800a17 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801672:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801675:	5b                   	pop    %ebx
  801676:	5e                   	pop    %esi
  801677:	5f                   	pop    %edi
  801678:	5d                   	pop    %ebp
  801679:	c3                   	ret    

0080167a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	57                   	push   %edi
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
  801680:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801683:	bb 00 00 00 00       	mov    $0x0,%ebx
  801688:	b8 09 00 00 00       	mov    $0x9,%eax
  80168d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801690:	8b 55 08             	mov    0x8(%ebp),%edx
  801693:	89 df                	mov    %ebx,%edi
  801695:	89 de                	mov    %ebx,%esi
  801697:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801699:	85 c0                	test   %eax,%eax
  80169b:	7e 17                	jle    8016b4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80169d:	83 ec 0c             	sub    $0xc,%esp
  8016a0:	50                   	push   %eax
  8016a1:	6a 09                	push   $0x9
  8016a3:	68 6f 38 80 00       	push   $0x80386f
  8016a8:	6a 23                	push   $0x23
  8016aa:	68 8c 38 80 00       	push   $0x80388c
  8016af:	e8 63 f3 ff ff       	call   800a17 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8016b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5f                   	pop    %edi
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    

008016bc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	57                   	push   %edi
  8016c0:	56                   	push   %esi
  8016c1:	53                   	push   %ebx
  8016c2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8016c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8016cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d5:	89 df                	mov    %ebx,%edi
  8016d7:	89 de                	mov    %ebx,%esi
  8016d9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8016db:	85 c0                	test   %eax,%eax
  8016dd:	7e 17                	jle    8016f6 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8016df:	83 ec 0c             	sub    $0xc,%esp
  8016e2:	50                   	push   %eax
  8016e3:	6a 0a                	push   $0xa
  8016e5:	68 6f 38 80 00       	push   $0x80386f
  8016ea:	6a 23                	push   $0x23
  8016ec:	68 8c 38 80 00       	push   $0x80388c
  8016f1:	e8 21 f3 ff ff       	call   800a17 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8016f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f9:	5b                   	pop    %ebx
  8016fa:	5e                   	pop    %esi
  8016fb:	5f                   	pop    %edi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	57                   	push   %edi
  801702:	56                   	push   %esi
  801703:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801704:	be 00 00 00 00       	mov    $0x0,%esi
  801709:	b8 0c 00 00 00       	mov    $0xc,%eax
  80170e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801711:	8b 55 08             	mov    0x8(%ebp),%edx
  801714:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801717:	8b 7d 14             	mov    0x14(%ebp),%edi
  80171a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80171c:	5b                   	pop    %ebx
  80171d:	5e                   	pop    %esi
  80171e:	5f                   	pop    %edi
  80171f:	5d                   	pop    %ebp
  801720:	c3                   	ret    

00801721 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	57                   	push   %edi
  801725:	56                   	push   %esi
  801726:	53                   	push   %ebx
  801727:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80172a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80172f:	b8 0d 00 00 00       	mov    $0xd,%eax
  801734:	8b 55 08             	mov    0x8(%ebp),%edx
  801737:	89 cb                	mov    %ecx,%ebx
  801739:	89 cf                	mov    %ecx,%edi
  80173b:	89 ce                	mov    %ecx,%esi
  80173d:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80173f:	85 c0                	test   %eax,%eax
  801741:	7e 17                	jle    80175a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801743:	83 ec 0c             	sub    $0xc,%esp
  801746:	50                   	push   %eax
  801747:	6a 0d                	push   $0xd
  801749:	68 6f 38 80 00       	push   $0x80386f
  80174e:	6a 23                	push   $0x23
  801750:	68 8c 38 80 00       	push   $0x80388c
  801755:	e8 bd f2 ff ff       	call   800a17 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80175a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5f                   	pop    %edi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <sys_gettime>:

int sys_gettime(void)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	57                   	push   %edi
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801768:	ba 00 00 00 00       	mov    $0x0,%edx
  80176d:	b8 0e 00 00 00       	mov    $0xe,%eax
  801772:	89 d1                	mov    %edx,%ecx
  801774:	89 d3                	mov    %edx,%ebx
  801776:	89 d7                	mov    %edx,%edi
  801778:	89 d6                	mov    %edx,%esi
  80177a:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5f                   	pop    %edi
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	53                   	push   %ebx
  801785:	83 ec 04             	sub    $0x4,%esp
  801788:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;addr=addr;
  80178b:	8b 02                	mov    (%edx),%eax
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  80178d:	f6 42 04 02          	testb  $0x2,0x4(%edx)
  801791:	74 2e                	je     8017c1 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
  801793:	89 c2                	mov    %eax,%edx
  801795:	c1 ea 16             	shr    $0x16,%edx
  801798:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  80179f:	f6 c2 01             	test   $0x1,%dl
  8017a2:	74 1d                	je     8017c1 <pgfault+0x40>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
  8017a4:	89 c2                	mov    %eax,%edx
  8017a6:	c1 ea 0c             	shr    $0xc,%edx
  8017a9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
		(uvpd[PDX(addr)] & PTE_P)   &&
  8017b0:	f6 c1 01             	test   $0x1,%cl
  8017b3:	74 0c                	je     8017c1 <pgfault+0x40>
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
  8017b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 9: Your code here.
	if (!((err & FEC_WR)            && 
  8017bc:	f6 c6 08             	test   $0x8,%dh
  8017bf:	75 14                	jne    8017d5 <pgfault+0x54>
		(uvpd[PDX(addr)] & PTE_P)   &&
		(uvpt[PGNUM(addr)] & PTE_P) && 
		(uvpt[PGNUM(addr)] & PTE_COW)))
		panic("not copy-on-write");
  8017c1:	83 ec 04             	sub    $0x4,%esp
  8017c4:	68 9a 38 80 00       	push   $0x80389a
  8017c9:	6a 28                	push   $0x28
  8017cb:	68 ac 38 80 00       	push   $0x8038ac
  8017d0:	e8 42 f2 ff ff       	call   800a17 <_panic>

	addr = ROUNDDOWN(addr, PGSIZE);
  8017d5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8017da:	89 c3                	mov    %eax,%ebx
	if (sys_page_alloc(0, PFTEMP, PTE_W|PTE_U|PTE_P) < 0)
  8017dc:	83 ec 04             	sub    $0x4,%esp
  8017df:	6a 07                	push   $0x7
  8017e1:	68 00 f0 7f 00       	push   $0x7ff000
  8017e6:	6a 00                	push   $0x0
  8017e8:	e8 84 fd ff ff       	call   801571 <sys_page_alloc>
  8017ed:	83 c4 10             	add    $0x10,%esp
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	79 14                	jns    801808 <pgfault+0x87>
		panic("sys_page_alloc");
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	68 b7 38 80 00       	push   $0x8038b7
  8017fc:	6a 2c                	push   $0x2c
  8017fe:	68 ac 38 80 00       	push   $0x8038ac
  801803:	e8 0f f2 ff ff       	call   800a17 <_panic>
	memcpy(PFTEMP, addr, PGSIZE);
  801808:	83 ec 04             	sub    $0x4,%esp
  80180b:	68 00 10 00 00       	push   $0x1000
  801810:	53                   	push   %ebx
  801811:	68 00 f0 7f 00       	push   $0x7ff000
  801816:	e8 53 fa ff ff       	call   80126e <memcpy>
	if (sys_page_map(0, PFTEMP, 0, addr, PTE_W|PTE_U|PTE_P) < 0)
  80181b:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801822:	53                   	push   %ebx
  801823:	6a 00                	push   $0x0
  801825:	68 00 f0 7f 00       	push   $0x7ff000
  80182a:	6a 00                	push   $0x0
  80182c:	e8 83 fd ff ff       	call   8015b4 <sys_page_map>
  801831:	83 c4 20             	add    $0x20,%esp
  801834:	85 c0                	test   %eax,%eax
  801836:	79 14                	jns    80184c <pgfault+0xcb>
		panic("sys_page_map");
  801838:	83 ec 04             	sub    $0x4,%esp
  80183b:	68 c6 38 80 00       	push   $0x8038c6
  801840:	6a 2f                	push   $0x2f
  801842:	68 ac 38 80 00       	push   $0x8038ac
  801847:	e8 cb f1 ff ff       	call   800a17 <_panic>
	if (sys_page_unmap(0, PFTEMP) < 0)
  80184c:	83 ec 08             	sub    $0x8,%esp
  80184f:	68 00 f0 7f 00       	push   $0x7ff000
  801854:	6a 00                	push   $0x0
  801856:	e8 9b fd ff ff       	call   8015f6 <sys_page_unmap>
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 c0                	test   %eax,%eax
  801860:	79 14                	jns    801876 <pgfault+0xf5>
		panic("sys_page_unmap");
  801862:	83 ec 04             	sub    $0x4,%esp
  801865:	68 d3 38 80 00       	push   $0x8038d3
  80186a:	6a 31                	push   $0x31
  80186c:	68 ac 38 80 00       	push   $0x8038ac
  801871:	e8 a1 f1 ff ff       	call   800a17 <_panic>
	return;
}
  801876:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	57                   	push   %edi
  80187f:	56                   	push   %esi
  801880:	53                   	push   %ebx
  801881:	83 ec 28             	sub    $0x28,%esp
	// LAB 9: Your code here.
	set_pgfault_handler(pgfault);
  801884:	68 81 17 80 00       	push   $0x801781
  801889:	e8 c3 15 00 00       	call   802e51 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80188e:	b8 07 00 00 00       	mov    $0x7,%eax
  801893:	cd 30                	int    $0x30
  801895:	89 c7                	mov    %eax,%edi
  801897:	89 45 e4             	mov    %eax,-0x1c(%ebp)

	envid_t envid;
	uint32_t addr;
	envid = sys_exofork();
	if (envid == 0) {
  80189a:	83 c4 10             	add    $0x10,%esp
  80189d:	85 c0                	test   %eax,%eax
  80189f:	75 21                	jne    8018c2 <fork+0x47>
		thisenv = &envs[ENVX(sys_getenvid())];
  8018a1:	e8 8d fc ff ff       	call   801533 <sys_getenvid>
  8018a6:	25 ff 03 00 00       	and    $0x3ff,%eax
  8018ab:	6b c0 78             	imul   $0x78,%eax,%eax
  8018ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8018b3:	a3 44 54 80 00       	mov    %eax,0x805444
		return 0;
  8018b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bd:	e9 80 01 00 00       	jmp    801a42 <fork+0x1c7>
	}
	if (envid < 0)
  8018c2:	85 c0                	test   %eax,%eax
  8018c4:	79 12                	jns    8018d8 <fork+0x5d>
		panic("sys_exofork: %i", envid);
  8018c6:	50                   	push   %eax
  8018c7:	68 e2 38 80 00       	push   $0x8038e2
  8018cc:	6a 70                	push   $0x70
  8018ce:	68 ac 38 80 00       	push   $0x8038ac
  8018d3:	e8 3f f1 ff ff       	call   800a17 <_panic>
  8018d8:	bb 00 00 00 00       	mov    $0x0,%ebx

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
  8018dd:	89 d8                	mov    %ebx,%eax
  8018df:	c1 e8 16             	shr    $0x16,%eax
  8018e2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018e9:	a8 01                	test   $0x1,%al
  8018eb:	0f 84 de 00 00 00    	je     8019cf <fork+0x154>
  8018f1:	89 de                	mov    %ebx,%esi
  8018f3:	c1 ee 0c             	shr    $0xc,%esi
  8018f6:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8018fd:	a8 01                	test   $0x1,%al
  8018ff:	0f 84 ca 00 00 00    	je     8019cf <fork+0x154>
  801905:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80190c:	a8 04                	test   $0x4,%al
  80190e:	0f 84 bb 00 00 00    	je     8019cf <fork+0x154>
//
static int
duppage(envid_t envid, unsigned pn)
{
	// LAB 9: Your code here.
	pte_t pte = uvpt[pn];
  801914:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
	void *addr = (void*) (pn*PGSIZE);
  80191b:	c1 e6 0c             	shl    $0xc,%esi
	if (pte & PTE_SHARE) {
  80191e:	f6 c4 04             	test   $0x4,%ah
  801921:	74 34                	je     801957 <fork+0xdc>
        if (sys_page_map(0, addr, envid, addr, pte & PTE_SYSCALL))
  801923:	83 ec 0c             	sub    $0xc,%esp
  801926:	25 07 0e 00 00       	and    $0xe07,%eax
  80192b:	50                   	push   %eax
  80192c:	56                   	push   %esi
  80192d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801930:	56                   	push   %esi
  801931:	6a 00                	push   $0x0
  801933:	e8 7c fc ff ff       	call   8015b4 <sys_page_map>
  801938:	83 c4 20             	add    $0x20,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	0f 84 8c 00 00 00    	je     8019cf <fork+0x154>
        	panic("duppage share");
  801943:	83 ec 04             	sub    $0x4,%esp
  801946:	68 f2 38 80 00       	push   $0x8038f2
  80194b:	6a 48                	push   $0x48
  80194d:	68 ac 38 80 00       	push   $0x8038ac
  801952:	e8 c0 f0 ff ff       	call   800a17 <_panic>
    } else if ((pte & PTE_W) || (pte & PTE_COW)) {
  801957:	a9 02 08 00 00       	test   $0x802,%eax
  80195c:	74 5d                	je     8019bb <fork+0x140>
       	if (sys_page_map(0, addr, envid, addr, PTE_COW|PTE_U|PTE_P) < 0)
  80195e:	83 ec 0c             	sub    $0xc,%esp
  801961:	68 05 08 00 00       	push   $0x805
  801966:	56                   	push   %esi
  801967:	ff 75 e4             	pushl  -0x1c(%ebp)
  80196a:	56                   	push   %esi
  80196b:	6a 00                	push   $0x0
  80196d:	e8 42 fc ff ff       	call   8015b4 <sys_page_map>
  801972:	83 c4 20             	add    $0x20,%esp
  801975:	85 c0                	test   %eax,%eax
  801977:	79 14                	jns    80198d <fork+0x112>
			panic("error");
  801979:	83 ec 04             	sub    $0x4,%esp
  80197c:	68 68 35 80 00       	push   $0x803568
  801981:	6a 4b                	push   $0x4b
  801983:	68 ac 38 80 00       	push   $0x8038ac
  801988:	e8 8a f0 ff ff       	call   800a17 <_panic>
		if (sys_page_map(0, addr, 0, addr, PTE_COW|PTE_U|PTE_P) < 0)
  80198d:	83 ec 0c             	sub    $0xc,%esp
  801990:	68 05 08 00 00       	push   $0x805
  801995:	56                   	push   %esi
  801996:	6a 00                	push   $0x0
  801998:	56                   	push   %esi
  801999:	6a 00                	push   $0x0
  80199b:	e8 14 fc ff ff       	call   8015b4 <sys_page_map>
  8019a0:	83 c4 20             	add    $0x20,%esp
  8019a3:	85 c0                	test   %eax,%eax
  8019a5:	79 28                	jns    8019cf <fork+0x154>
			panic("error");
  8019a7:	83 ec 04             	sub    $0x4,%esp
  8019aa:	68 68 35 80 00       	push   $0x803568
  8019af:	6a 4d                	push   $0x4d
  8019b1:	68 ac 38 80 00       	push   $0x8038ac
  8019b6:	e8 5c f0 ff ff       	call   800a17 <_panic>
 	} else sys_page_map(0, addr, envid, addr, PTE_U|PTE_P);
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	6a 05                	push   $0x5
  8019c0:	56                   	push   %esi
  8019c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8019c4:	56                   	push   %esi
  8019c5:	6a 00                	push   $0x0
  8019c7:	e8 e8 fb ff ff       	call   8015b4 <sys_page_map>
  8019cc:	83 c4 20             	add    $0x20,%esp
		return 0;
	}
	if (envid < 0)
		panic("sys_exofork: %i", envid);

	for (addr = 0; addr < USTACKTOP; addr += PGSIZE)
  8019cf:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019d5:	81 fb 00 e0 7f ee    	cmp    $0xee7fe000,%ebx
  8019db:	0f 85 fc fe ff ff    	jne    8018dd <fork+0x62>
		if ((uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_U)) {
			duppage(envid, PGNUM(addr));
		}

	if (sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U|PTE_W|PTE_P) < 0)
  8019e1:	83 ec 04             	sub    $0x4,%esp
  8019e4:	6a 07                	push   $0x7
  8019e6:	68 00 f0 7f ee       	push   $0xee7ff000
  8019eb:	57                   	push   %edi
  8019ec:	e8 80 fb ff ff       	call   801571 <sys_page_alloc>
  8019f1:	83 c4 10             	add    $0x10,%esp
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	79 14                	jns    801a0c <fork+0x191>
		panic("1");
  8019f8:	83 ec 04             	sub    $0x4,%esp
  8019fb:	68 00 39 80 00       	push   $0x803900
  801a00:	6a 78                	push   $0x78
  801a02:	68 ac 38 80 00       	push   $0x8038ac
  801a07:	e8 0b f0 ff ff       	call   800a17 <_panic>
	extern void _pgfault_upcall();
	sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	68 c0 2e 80 00       	push   $0x802ec0
  801a14:	57                   	push   %edi
  801a15:	e8 a2 fc ff ff       	call   8016bc <sys_env_set_pgfault_upcall>

	if (sys_env_set_status(envid, ENV_RUNNABLE) < 0)
  801a1a:	83 c4 08             	add    $0x8,%esp
  801a1d:	6a 02                	push   $0x2
  801a1f:	57                   	push   %edi
  801a20:	e8 13 fc ff ff       	call   801638 <sys_env_set_status>
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	79 14                	jns    801a40 <fork+0x1c5>
		panic("sys_env_set_status");
  801a2c:	83 ec 04             	sub    $0x4,%esp
  801a2f:	68 02 39 80 00       	push   $0x803902
  801a34:	6a 7d                	push   $0x7d
  801a36:	68 ac 38 80 00       	push   $0x8038ac
  801a3b:	e8 d7 ef ff ff       	call   800a17 <_panic>

	return envid;
  801a40:	89 f8                	mov    %edi,%eax
}
  801a42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a45:	5b                   	pop    %ebx
  801a46:	5e                   	pop    %esi
  801a47:	5f                   	pop    %edi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <sfork>:

// Challenge!
int
sfork(void)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801a50:	68 15 39 80 00       	push   $0x803915
  801a55:	68 86 00 00 00       	push   $0x86
  801a5a:	68 ac 38 80 00       	push   $0x8038ac
  801a5f:	e8 b3 ef ff ff       	call   800a17 <_panic>

00801a64 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	8b 55 08             	mov    0x8(%ebp),%edx
  801a6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a6d:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801a70:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801a72:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801a75:	83 3a 01             	cmpl   $0x1,(%edx)
  801a78:	7e 09                	jle    801a83 <argstart+0x1f>
  801a7a:	ba 21 33 80 00       	mov    $0x803321,%edx
  801a7f:	85 c9                	test   %ecx,%ecx
  801a81:	75 05                	jne    801a88 <argstart+0x24>
  801a83:	ba 00 00 00 00       	mov    $0x0,%edx
  801a88:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801a8b:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801a92:	5d                   	pop    %ebp
  801a93:	c3                   	ret    

00801a94 <argnext>:

int
argnext(struct Argstate *args)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	53                   	push   %ebx
  801a98:	83 ec 04             	sub    $0x4,%esp
  801a9b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801a9e:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801aa5:	8b 43 08             	mov    0x8(%ebx),%eax
  801aa8:	85 c0                	test   %eax,%eax
  801aaa:	74 6f                	je     801b1b <argnext+0x87>
		return -1;

	if (!*args->curarg) {
  801aac:	80 38 00             	cmpb   $0x0,(%eax)
  801aaf:	75 4e                	jne    801aff <argnext+0x6b>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801ab1:	8b 0b                	mov    (%ebx),%ecx
  801ab3:	83 39 01             	cmpl   $0x1,(%ecx)
  801ab6:	74 55                	je     801b0d <argnext+0x79>
		    || args->argv[1][0] != '-'
  801ab8:	8b 53 04             	mov    0x4(%ebx),%edx
  801abb:	8b 42 04             	mov    0x4(%edx),%eax
  801abe:	80 38 2d             	cmpb   $0x2d,(%eax)
  801ac1:	75 4a                	jne    801b0d <argnext+0x79>
		    || args->argv[1][1] == '\0')
  801ac3:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801ac7:	74 44                	je     801b0d <argnext+0x79>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801ac9:	83 c0 01             	add    $0x1,%eax
  801acc:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801acf:	83 ec 04             	sub    $0x4,%esp
  801ad2:	8b 01                	mov    (%ecx),%eax
  801ad4:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801adb:	50                   	push   %eax
  801adc:	8d 42 08             	lea    0x8(%edx),%eax
  801adf:	50                   	push   %eax
  801ae0:	83 c2 04             	add    $0x4,%edx
  801ae3:	52                   	push   %edx
  801ae4:	e8 1d f7 ff ff       	call   801206 <memmove>
		(*args->argc)--;
  801ae9:	8b 03                	mov    (%ebx),%eax
  801aeb:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801aee:	8b 43 08             	mov    0x8(%ebx),%eax
  801af1:	83 c4 10             	add    $0x10,%esp
  801af4:	80 38 2d             	cmpb   $0x2d,(%eax)
  801af7:	75 06                	jne    801aff <argnext+0x6b>
  801af9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801afd:	74 0e                	je     801b0d <argnext+0x79>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801aff:	8b 53 08             	mov    0x8(%ebx),%edx
  801b02:	0f b6 02             	movzbl (%edx),%eax
	args->curarg++;
  801b05:	83 c2 01             	add    $0x1,%edx
  801b08:	89 53 08             	mov    %edx,0x8(%ebx)
	return arg;
  801b0b:	eb 13                	jmp    801b20 <argnext+0x8c>

    endofargs:
	args->curarg = 0;
  801b0d:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801b14:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  801b19:	eb 05                	jmp    801b20 <argnext+0x8c>

	args->argvalue = 0;

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
		return -1;
  801b1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801b20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	53                   	push   %ebx
  801b29:	83 ec 04             	sub    $0x4,%esp
  801b2c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801b2f:	8b 43 08             	mov    0x8(%ebx),%eax
  801b32:	85 c0                	test   %eax,%eax
  801b34:	74 58                	je     801b8e <argnextvalue+0x69>
		return 0;
	if (*args->curarg) {
  801b36:	80 38 00             	cmpb   $0x0,(%eax)
  801b39:	74 0c                	je     801b47 <argnextvalue+0x22>
		args->argvalue = args->curarg;
  801b3b:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801b3e:	c7 43 08 21 33 80 00 	movl   $0x803321,0x8(%ebx)
  801b45:	eb 42                	jmp    801b89 <argnextvalue+0x64>
	} else if (*args->argc > 1) {
  801b47:	8b 13                	mov    (%ebx),%edx
  801b49:	83 3a 01             	cmpl   $0x1,(%edx)
  801b4c:	7e 2d                	jle    801b7b <argnextvalue+0x56>
		args->argvalue = args->argv[1];
  801b4e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b51:	8b 48 04             	mov    0x4(%eax),%ecx
  801b54:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801b57:	83 ec 04             	sub    $0x4,%esp
  801b5a:	8b 12                	mov    (%edx),%edx
  801b5c:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801b63:	52                   	push   %edx
  801b64:	8d 50 08             	lea    0x8(%eax),%edx
  801b67:	52                   	push   %edx
  801b68:	83 c0 04             	add    $0x4,%eax
  801b6b:	50                   	push   %eax
  801b6c:	e8 95 f6 ff ff       	call   801206 <memmove>
		(*args->argc)--;
  801b71:	8b 03                	mov    (%ebx),%eax
  801b73:	83 28 01             	subl   $0x1,(%eax)
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	eb 0e                	jmp    801b89 <argnextvalue+0x64>
	} else {
		args->argvalue = 0;
  801b7b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801b82:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	}
	return (char*) args->argvalue;
  801b89:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b8c:	eb 05                	jmp    801b93 <argnextvalue+0x6e>

char *
argnextvalue(struct Argstate *args)
{
	if (!args->curarg)
		return 0;
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
}
  801b93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <argvalue>:
	return -1;
}

char *
argvalue(struct Argstate *args)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 08             	sub    $0x8,%esp
  801b9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801ba1:	8b 51 0c             	mov    0xc(%ecx),%edx
  801ba4:	89 d0                	mov    %edx,%eax
  801ba6:	85 d2                	test   %edx,%edx
  801ba8:	75 0c                	jne    801bb6 <argvalue+0x1e>
  801baa:	83 ec 0c             	sub    $0xc,%esp
  801bad:	51                   	push   %ecx
  801bae:	e8 72 ff ff ff       	call   801b25 <argnextvalue>
  801bb3:	83 c4 10             	add    $0x10,%esp
}
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	05 00 00 00 30       	add    $0x30000000,%eax
  801bc3:	c1 e8 0c             	shr    $0xc,%eax
}
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    

00801bc8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bce:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801bd3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801bd8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801bea:	89 c2                	mov    %eax,%edx
  801bec:	c1 ea 16             	shr    $0x16,%edx
  801bef:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801bf6:	f6 c2 01             	test   $0x1,%dl
  801bf9:	74 11                	je     801c0c <fd_alloc+0x2d>
  801bfb:	89 c2                	mov    %eax,%edx
  801bfd:	c1 ea 0c             	shr    $0xc,%edx
  801c00:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c07:	f6 c2 01             	test   $0x1,%dl
  801c0a:	75 09                	jne    801c15 <fd_alloc+0x36>
			*fd_store = fd;
  801c0c:	89 01                	mov    %eax,(%ecx)
			return 0;
  801c0e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c13:	eb 17                	jmp    801c2c <fd_alloc+0x4d>
  801c15:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801c1a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801c1f:	75 c9                	jne    801bea <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801c21:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  801c27:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801c34:	83 f8 1f             	cmp    $0x1f,%eax
  801c37:	77 36                	ja     801c6f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801c39:	c1 e0 0c             	shl    $0xc,%eax
  801c3c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801c41:	89 c2                	mov    %eax,%edx
  801c43:	c1 ea 16             	shr    $0x16,%edx
  801c46:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801c4d:	f6 c2 01             	test   $0x1,%dl
  801c50:	74 24                	je     801c76 <fd_lookup+0x48>
  801c52:	89 c2                	mov    %eax,%edx
  801c54:	c1 ea 0c             	shr    $0xc,%edx
  801c57:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801c5e:	f6 c2 01             	test   $0x1,%dl
  801c61:	74 1a                	je     801c7d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801c63:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c66:	89 02                	mov    %eax,(%edx)
	return 0;
  801c68:	b8 00 00 00 00       	mov    $0x0,%eax
  801c6d:	eb 13                	jmp    801c82 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c6f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c74:	eb 0c                	jmp    801c82 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801c76:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801c7b:	eb 05                	jmp    801c82 <fd_lookup+0x54>
  801c7d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    

00801c84 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 08             	sub    $0x8,%esp
  801c8a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c8d:	ba a8 39 80 00       	mov    $0x8039a8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801c92:	eb 13                	jmp    801ca7 <dev_lookup+0x23>
  801c94:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801c97:	39 08                	cmp    %ecx,(%eax)
  801c99:	75 0c                	jne    801ca7 <dev_lookup+0x23>
			*dev = devtab[i];
  801c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c9e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca5:	eb 2e                	jmp    801cd5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801ca7:	8b 02                	mov    (%edx),%eax
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	75 e7                	jne    801c94 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801cad:	a1 44 54 80 00       	mov    0x805444,%eax
  801cb2:	8b 40 48             	mov    0x48(%eax),%eax
  801cb5:	83 ec 04             	sub    $0x4,%esp
  801cb8:	51                   	push   %ecx
  801cb9:	50                   	push   %eax
  801cba:	68 2c 39 80 00       	push   $0x80392c
  801cbf:	e8 2c ee ff ff       	call   800af0 <cprintf>
	*dev = 0;
  801cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801cd5:	c9                   	leave  
  801cd6:	c3                   	ret    

00801cd7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801cd7:	55                   	push   %ebp
  801cd8:	89 e5                	mov    %esp,%ebp
  801cda:	56                   	push   %esi
  801cdb:	53                   	push   %ebx
  801cdc:	83 ec 10             	sub    $0x10,%esp
  801cdf:	8b 75 08             	mov    0x8(%ebp),%esi
  801ce2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ce5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce8:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801ce9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801cef:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801cf2:	50                   	push   %eax
  801cf3:	e8 36 ff ff ff       	call   801c2e <fd_lookup>
  801cf8:	83 c4 08             	add    $0x8,%esp
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	78 05                	js     801d04 <fd_close+0x2d>
	    || fd != fd2)
  801cff:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801d02:	74 0b                	je     801d0f <fd_close+0x38>
		return (must_exist ? r : 0);
  801d04:	80 fb 01             	cmp    $0x1,%bl
  801d07:	19 d2                	sbb    %edx,%edx
  801d09:	f7 d2                	not    %edx
  801d0b:	21 d0                	and    %edx,%eax
  801d0d:	eb 41                	jmp    801d50 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801d0f:	83 ec 08             	sub    $0x8,%esp
  801d12:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d15:	50                   	push   %eax
  801d16:	ff 36                	pushl  (%esi)
  801d18:	e8 67 ff ff ff       	call   801c84 <dev_lookup>
  801d1d:	89 c3                	mov    %eax,%ebx
  801d1f:	83 c4 10             	add    $0x10,%esp
  801d22:	85 c0                	test   %eax,%eax
  801d24:	78 1a                	js     801d40 <fd_close+0x69>
		if (dev->dev_close)
  801d26:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d29:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801d2c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801d31:	85 c0                	test   %eax,%eax
  801d33:	74 0b                	je     801d40 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  801d35:	83 ec 0c             	sub    $0xc,%esp
  801d38:	56                   	push   %esi
  801d39:	ff d0                	call   *%eax
  801d3b:	89 c3                	mov    %eax,%ebx
  801d3d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801d40:	83 ec 08             	sub    $0x8,%esp
  801d43:	56                   	push   %esi
  801d44:	6a 00                	push   $0x0
  801d46:	e8 ab f8 ff ff       	call   8015f6 <sys_page_unmap>
	return r;
  801d4b:	83 c4 10             	add    $0x10,%esp
  801d4e:	89 d8                	mov    %ebx,%eax
}
  801d50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d53:	5b                   	pop    %ebx
  801d54:	5e                   	pop    %esi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d60:	50                   	push   %eax
  801d61:	ff 75 08             	pushl  0x8(%ebp)
  801d64:	e8 c5 fe ff ff       	call   801c2e <fd_lookup>
  801d69:	89 c2                	mov    %eax,%edx
  801d6b:	83 c4 08             	add    $0x8,%esp
  801d6e:	85 d2                	test   %edx,%edx
  801d70:	78 10                	js     801d82 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  801d72:	83 ec 08             	sub    $0x8,%esp
  801d75:	6a 01                	push   $0x1
  801d77:	ff 75 f4             	pushl  -0xc(%ebp)
  801d7a:	e8 58 ff ff ff       	call   801cd7 <fd_close>
  801d7f:	83 c4 10             	add    $0x10,%esp
}
  801d82:	c9                   	leave  
  801d83:	c3                   	ret    

00801d84 <close_all>:

void
close_all(void)
{
  801d84:	55                   	push   %ebp
  801d85:	89 e5                	mov    %esp,%ebp
  801d87:	53                   	push   %ebx
  801d88:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801d8b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801d90:	83 ec 0c             	sub    $0xc,%esp
  801d93:	53                   	push   %ebx
  801d94:	e8 be ff ff ff       	call   801d57 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801d99:	83 c3 01             	add    $0x1,%ebx
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	83 fb 20             	cmp    $0x20,%ebx
  801da2:	75 ec                	jne    801d90 <close_all+0xc>
		close(i);
}
  801da4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da7:	c9                   	leave  
  801da8:	c3                   	ret    

00801da9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801da9:	55                   	push   %ebp
  801daa:	89 e5                	mov    %esp,%ebp
  801dac:	57                   	push   %edi
  801dad:	56                   	push   %esi
  801dae:	53                   	push   %ebx
  801daf:	83 ec 2c             	sub    $0x2c,%esp
  801db2:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801db5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801db8:	50                   	push   %eax
  801db9:	ff 75 08             	pushl  0x8(%ebp)
  801dbc:	e8 6d fe ff ff       	call   801c2e <fd_lookup>
  801dc1:	89 c2                	mov    %eax,%edx
  801dc3:	83 c4 08             	add    $0x8,%esp
  801dc6:	85 d2                	test   %edx,%edx
  801dc8:	0f 88 c1 00 00 00    	js     801e8f <dup+0xe6>
		return r;
	close(newfdnum);
  801dce:	83 ec 0c             	sub    $0xc,%esp
  801dd1:	56                   	push   %esi
  801dd2:	e8 80 ff ff ff       	call   801d57 <close>

	newfd = INDEX2FD(newfdnum);
  801dd7:	89 f3                	mov    %esi,%ebx
  801dd9:	c1 e3 0c             	shl    $0xc,%ebx
  801ddc:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801de2:	83 c4 04             	add    $0x4,%esp
  801de5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801de8:	e8 db fd ff ff       	call   801bc8 <fd2data>
  801ded:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801def:	89 1c 24             	mov    %ebx,(%esp)
  801df2:	e8 d1 fd ff ff       	call   801bc8 <fd2data>
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801dfd:	89 f8                	mov    %edi,%eax
  801dff:	c1 e8 16             	shr    $0x16,%eax
  801e02:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801e09:	a8 01                	test   $0x1,%al
  801e0b:	74 37                	je     801e44 <dup+0x9b>
  801e0d:	89 f8                	mov    %edi,%eax
  801e0f:	c1 e8 0c             	shr    $0xc,%eax
  801e12:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801e19:	f6 c2 01             	test   $0x1,%dl
  801e1c:	74 26                	je     801e44 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801e1e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e25:	83 ec 0c             	sub    $0xc,%esp
  801e28:	25 07 0e 00 00       	and    $0xe07,%eax
  801e2d:	50                   	push   %eax
  801e2e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e31:	6a 00                	push   $0x0
  801e33:	57                   	push   %edi
  801e34:	6a 00                	push   $0x0
  801e36:	e8 79 f7 ff ff       	call   8015b4 <sys_page_map>
  801e3b:	89 c7                	mov    %eax,%edi
  801e3d:	83 c4 20             	add    $0x20,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 2e                	js     801e72 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e44:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801e47:	89 d0                	mov    %edx,%eax
  801e49:	c1 e8 0c             	shr    $0xc,%eax
  801e4c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801e53:	83 ec 0c             	sub    $0xc,%esp
  801e56:	25 07 0e 00 00       	and    $0xe07,%eax
  801e5b:	50                   	push   %eax
  801e5c:	53                   	push   %ebx
  801e5d:	6a 00                	push   $0x0
  801e5f:	52                   	push   %edx
  801e60:	6a 00                	push   $0x0
  801e62:	e8 4d f7 ff ff       	call   8015b4 <sys_page_map>
  801e67:	89 c7                	mov    %eax,%edi
  801e69:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801e6c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801e6e:	85 ff                	test   %edi,%edi
  801e70:	79 1d                	jns    801e8f <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801e72:	83 ec 08             	sub    $0x8,%esp
  801e75:	53                   	push   %ebx
  801e76:	6a 00                	push   $0x0
  801e78:	e8 79 f7 ff ff       	call   8015f6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801e7d:	83 c4 08             	add    $0x8,%esp
  801e80:	ff 75 d4             	pushl  -0x2c(%ebp)
  801e83:	6a 00                	push   $0x0
  801e85:	e8 6c f7 ff ff       	call   8015f6 <sys_page_unmap>
	return r;
  801e8a:	83 c4 10             	add    $0x10,%esp
  801e8d:	89 f8                	mov    %edi,%eax
}
  801e8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e92:	5b                   	pop    %ebx
  801e93:	5e                   	pop    %esi
  801e94:	5f                   	pop    %edi
  801e95:	5d                   	pop    %ebp
  801e96:	c3                   	ret    

00801e97 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801e97:	55                   	push   %ebp
  801e98:	89 e5                	mov    %esp,%ebp
  801e9a:	53                   	push   %ebx
  801e9b:	83 ec 14             	sub    $0x14,%esp
  801e9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801ea1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ea4:	50                   	push   %eax
  801ea5:	53                   	push   %ebx
  801ea6:	e8 83 fd ff ff       	call   801c2e <fd_lookup>
  801eab:	83 c4 08             	add    $0x8,%esp
  801eae:	89 c2                	mov    %eax,%edx
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 6d                	js     801f21 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801eb4:	83 ec 08             	sub    $0x8,%esp
  801eb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eba:	50                   	push   %eax
  801ebb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ebe:	ff 30                	pushl  (%eax)
  801ec0:	e8 bf fd ff ff       	call   801c84 <dev_lookup>
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	78 4c                	js     801f18 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801ecc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ecf:	8b 42 08             	mov    0x8(%edx),%eax
  801ed2:	83 e0 03             	and    $0x3,%eax
  801ed5:	83 f8 01             	cmp    $0x1,%eax
  801ed8:	75 21                	jne    801efb <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801eda:	a1 44 54 80 00       	mov    0x805444,%eax
  801edf:	8b 40 48             	mov    0x48(%eax),%eax
  801ee2:	83 ec 04             	sub    $0x4,%esp
  801ee5:	53                   	push   %ebx
  801ee6:	50                   	push   %eax
  801ee7:	68 6d 39 80 00       	push   $0x80396d
  801eec:	e8 ff eb ff ff       	call   800af0 <cprintf>
		return -E_INVAL;
  801ef1:	83 c4 10             	add    $0x10,%esp
  801ef4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801ef9:	eb 26                	jmp    801f21 <read+0x8a>
	}
	if (!dev->dev_read)
  801efb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efe:	8b 40 08             	mov    0x8(%eax),%eax
  801f01:	85 c0                	test   %eax,%eax
  801f03:	74 17                	je     801f1c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801f05:	83 ec 04             	sub    $0x4,%esp
  801f08:	ff 75 10             	pushl  0x10(%ebp)
  801f0b:	ff 75 0c             	pushl  0xc(%ebp)
  801f0e:	52                   	push   %edx
  801f0f:	ff d0                	call   *%eax
  801f11:	89 c2                	mov    %eax,%edx
  801f13:	83 c4 10             	add    $0x10,%esp
  801f16:	eb 09                	jmp    801f21 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f18:	89 c2                	mov    %eax,%edx
  801f1a:	eb 05                	jmp    801f21 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801f1c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801f21:	89 d0                	mov    %edx,%eax
  801f23:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	57                   	push   %edi
  801f2c:	56                   	push   %esi
  801f2d:	53                   	push   %ebx
  801f2e:	83 ec 0c             	sub    $0xc,%esp
  801f31:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f34:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f37:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f3c:	eb 21                	jmp    801f5f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801f3e:	83 ec 04             	sub    $0x4,%esp
  801f41:	89 f0                	mov    %esi,%eax
  801f43:	29 d8                	sub    %ebx,%eax
  801f45:	50                   	push   %eax
  801f46:	89 d8                	mov    %ebx,%eax
  801f48:	03 45 0c             	add    0xc(%ebp),%eax
  801f4b:	50                   	push   %eax
  801f4c:	57                   	push   %edi
  801f4d:	e8 45 ff ff ff       	call   801e97 <read>
		if (m < 0)
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	85 c0                	test   %eax,%eax
  801f57:	78 0c                	js     801f65 <readn+0x3d>
			return m;
		if (m == 0)
  801f59:	85 c0                	test   %eax,%eax
  801f5b:	74 06                	je     801f63 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801f5d:	01 c3                	add    %eax,%ebx
  801f5f:	39 f3                	cmp    %esi,%ebx
  801f61:	72 db                	jb     801f3e <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801f63:	89 d8                	mov    %ebx,%eax
}
  801f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    

00801f6d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	53                   	push   %ebx
  801f71:	83 ec 14             	sub    $0x14,%esp
  801f74:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801f77:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f7a:	50                   	push   %eax
  801f7b:	53                   	push   %ebx
  801f7c:	e8 ad fc ff ff       	call   801c2e <fd_lookup>
  801f81:	83 c4 08             	add    $0x8,%esp
  801f84:	89 c2                	mov    %eax,%edx
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 68                	js     801ff2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801f8a:	83 ec 08             	sub    $0x8,%esp
  801f8d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f90:	50                   	push   %eax
  801f91:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f94:	ff 30                	pushl  (%eax)
  801f96:	e8 e9 fc ff ff       	call   801c84 <dev_lookup>
  801f9b:	83 c4 10             	add    $0x10,%esp
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 47                	js     801fe9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801fa2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801fa9:	75 21                	jne    801fcc <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801fab:	a1 44 54 80 00       	mov    0x805444,%eax
  801fb0:	8b 40 48             	mov    0x48(%eax),%eax
  801fb3:	83 ec 04             	sub    $0x4,%esp
  801fb6:	53                   	push   %ebx
  801fb7:	50                   	push   %eax
  801fb8:	68 89 39 80 00       	push   $0x803989
  801fbd:	e8 2e eb ff ff       	call   800af0 <cprintf>
		return -E_INVAL;
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801fca:	eb 26                	jmp    801ff2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801fcc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fcf:	8b 52 0c             	mov    0xc(%edx),%edx
  801fd2:	85 d2                	test   %edx,%edx
  801fd4:	74 17                	je     801fed <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801fd6:	83 ec 04             	sub    $0x4,%esp
  801fd9:	ff 75 10             	pushl  0x10(%ebp)
  801fdc:	ff 75 0c             	pushl  0xc(%ebp)
  801fdf:	50                   	push   %eax
  801fe0:	ff d2                	call   *%edx
  801fe2:	89 c2                	mov    %eax,%edx
  801fe4:	83 c4 10             	add    $0x10,%esp
  801fe7:	eb 09                	jmp    801ff2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801fe9:	89 c2                	mov    %eax,%edx
  801feb:	eb 05                	jmp    801ff2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801fed:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801ff2:	89 d0                	mov    %edx,%eax
  801ff4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ff7:	c9                   	leave  
  801ff8:	c3                   	ret    

00801ff9 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fff:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802002:	50                   	push   %eax
  802003:	ff 75 08             	pushl  0x8(%ebp)
  802006:	e8 23 fc ff ff       	call   801c2e <fd_lookup>
  80200b:	83 c4 08             	add    $0x8,%esp
  80200e:	85 c0                	test   %eax,%eax
  802010:	78 0e                	js     802020 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802012:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802015:	8b 55 0c             	mov    0xc(%ebp),%edx
  802018:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80201b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802020:	c9                   	leave  
  802021:	c3                   	ret    

00802022 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802022:	55                   	push   %ebp
  802023:	89 e5                	mov    %esp,%ebp
  802025:	53                   	push   %ebx
  802026:	83 ec 14             	sub    $0x14,%esp
  802029:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80202c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80202f:	50                   	push   %eax
  802030:	53                   	push   %ebx
  802031:	e8 f8 fb ff ff       	call   801c2e <fd_lookup>
  802036:	83 c4 08             	add    $0x8,%esp
  802039:	89 c2                	mov    %eax,%edx
  80203b:	85 c0                	test   %eax,%eax
  80203d:	78 65                	js     8020a4 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80203f:	83 ec 08             	sub    $0x8,%esp
  802042:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802045:	50                   	push   %eax
  802046:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802049:	ff 30                	pushl  (%eax)
  80204b:	e8 34 fc ff ff       	call   801c84 <dev_lookup>
  802050:	83 c4 10             	add    $0x10,%esp
  802053:	85 c0                	test   %eax,%eax
  802055:	78 44                	js     80209b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802057:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80205a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80205e:	75 21                	jne    802081 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802060:	a1 44 54 80 00       	mov    0x805444,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802065:	8b 40 48             	mov    0x48(%eax),%eax
  802068:	83 ec 04             	sub    $0x4,%esp
  80206b:	53                   	push   %ebx
  80206c:	50                   	push   %eax
  80206d:	68 4c 39 80 00       	push   $0x80394c
  802072:	e8 79 ea ff ff       	call   800af0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802077:	83 c4 10             	add    $0x10,%esp
  80207a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80207f:	eb 23                	jmp    8020a4 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802081:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802084:	8b 52 18             	mov    0x18(%edx),%edx
  802087:	85 d2                	test   %edx,%edx
  802089:	74 14                	je     80209f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80208b:	83 ec 08             	sub    $0x8,%esp
  80208e:	ff 75 0c             	pushl  0xc(%ebp)
  802091:	50                   	push   %eax
  802092:	ff d2                	call   *%edx
  802094:	89 c2                	mov    %eax,%edx
  802096:	83 c4 10             	add    $0x10,%esp
  802099:	eb 09                	jmp    8020a4 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80209b:	89 c2                	mov    %eax,%edx
  80209d:	eb 05                	jmp    8020a4 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80209f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8020a4:	89 d0                	mov    %edx,%eax
  8020a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020a9:	c9                   	leave  
  8020aa:	c3                   	ret    

008020ab <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	53                   	push   %ebx
  8020af:	83 ec 14             	sub    $0x14,%esp
  8020b2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8020b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020b8:	50                   	push   %eax
  8020b9:	ff 75 08             	pushl  0x8(%ebp)
  8020bc:	e8 6d fb ff ff       	call   801c2e <fd_lookup>
  8020c1:	83 c4 08             	add    $0x8,%esp
  8020c4:	89 c2                	mov    %eax,%edx
  8020c6:	85 c0                	test   %eax,%eax
  8020c8:	78 58                	js     802122 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8020ca:	83 ec 08             	sub    $0x8,%esp
  8020cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020d0:	50                   	push   %eax
  8020d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020d4:	ff 30                	pushl  (%eax)
  8020d6:	e8 a9 fb ff ff       	call   801c84 <dev_lookup>
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	85 c0                	test   %eax,%eax
  8020e0:	78 37                	js     802119 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8020e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8020e9:	74 32                	je     80211d <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8020eb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8020ee:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8020f5:	00 00 00 
	stat->st_isdir = 0;
  8020f8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8020ff:	00 00 00 
	stat->st_dev = dev;
  802102:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802108:	83 ec 08             	sub    $0x8,%esp
  80210b:	53                   	push   %ebx
  80210c:	ff 75 f0             	pushl  -0x10(%ebp)
  80210f:	ff 50 14             	call   *0x14(%eax)
  802112:	89 c2                	mov    %eax,%edx
  802114:	83 c4 10             	add    $0x10,%esp
  802117:	eb 09                	jmp    802122 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802119:	89 c2                	mov    %eax,%edx
  80211b:	eb 05                	jmp    802122 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  80211d:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802122:	89 d0                	mov    %edx,%eax
  802124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802127:	c9                   	leave  
  802128:	c3                   	ret    

00802129 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	56                   	push   %esi
  80212d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80212e:	83 ec 08             	sub    $0x8,%esp
  802131:	6a 00                	push   $0x0
  802133:	ff 75 08             	pushl  0x8(%ebp)
  802136:	e8 e7 01 00 00       	call   802322 <open>
  80213b:	89 c3                	mov    %eax,%ebx
  80213d:	83 c4 10             	add    $0x10,%esp
  802140:	85 db                	test   %ebx,%ebx
  802142:	78 1b                	js     80215f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802144:	83 ec 08             	sub    $0x8,%esp
  802147:	ff 75 0c             	pushl  0xc(%ebp)
  80214a:	53                   	push   %ebx
  80214b:	e8 5b ff ff ff       	call   8020ab <fstat>
  802150:	89 c6                	mov    %eax,%esi
	close(fd);
  802152:	89 1c 24             	mov    %ebx,(%esp)
  802155:	e8 fd fb ff ff       	call   801d57 <close>
	return r;
  80215a:	83 c4 10             	add    $0x10,%esp
  80215d:	89 f0                	mov    %esi,%eax
}
  80215f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802162:	5b                   	pop    %ebx
  802163:	5e                   	pop    %esi
  802164:	5d                   	pop    %ebp
  802165:	c3                   	ret    

00802166 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802166:	55                   	push   %ebp
  802167:	89 e5                	mov    %esp,%ebp
  802169:	56                   	push   %esi
  80216a:	53                   	push   %ebx
  80216b:	89 c6                	mov    %eax,%esi
  80216d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80216f:	83 3d 40 54 80 00 00 	cmpl   $0x0,0x805440
  802176:	75 12                	jne    80218a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802178:	83 ec 0c             	sub    $0xc,%esp
  80217b:	6a 03                	push   $0x3
  80217d:	e8 1d 0e 00 00       	call   802f9f <ipc_find_env>
  802182:	a3 40 54 80 00       	mov    %eax,0x805440
  802187:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80218a:	6a 07                	push   $0x7
  80218c:	68 00 60 80 00       	push   $0x806000
  802191:	56                   	push   %esi
  802192:	ff 35 40 54 80 00    	pushl  0x805440
  802198:	e8 b1 0d 00 00       	call   802f4e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80219d:	83 c4 0c             	add    $0xc,%esp
  8021a0:	6a 00                	push   $0x0
  8021a2:	53                   	push   %ebx
  8021a3:	6a 00                	push   $0x0
  8021a5:	e8 3e 0d 00 00       	call   802ee8 <ipc_recv>
}
  8021aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8021b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8021bd:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  8021c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021c5:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8021ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8021cf:	b8 02 00 00 00       	mov    $0x2,%eax
  8021d4:	e8 8d ff ff ff       	call   802166 <fsipc>
}
  8021d9:	c9                   	leave  
  8021da:	c3                   	ret    

008021db <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8021e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8021e7:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  8021ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8021f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8021f6:	e8 6b ff ff ff       	call   802166 <fsipc>
}
  8021fb:	c9                   	leave  
  8021fc:	c3                   	ret    

008021fd <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8021fd:	55                   	push   %ebp
  8021fe:	89 e5                	mov    %esp,%ebp
  802200:	53                   	push   %ebx
  802201:	83 ec 04             	sub    $0x4,%esp
  802204:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802207:	8b 45 08             	mov    0x8(%ebp),%eax
  80220a:	8b 40 0c             	mov    0xc(%eax),%eax
  80220d:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802212:	ba 00 00 00 00       	mov    $0x0,%edx
  802217:	b8 05 00 00 00       	mov    $0x5,%eax
  80221c:	e8 45 ff ff ff       	call   802166 <fsipc>
  802221:	89 c2                	mov    %eax,%edx
  802223:	85 d2                	test   %edx,%edx
  802225:	78 2c                	js     802253 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802227:	83 ec 08             	sub    $0x8,%esp
  80222a:	68 00 60 80 00       	push   $0x806000
  80222f:	53                   	push   %ebx
  802230:	e8 3f ee ff ff       	call   801074 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802235:	a1 80 60 80 00       	mov    0x806080,%eax
  80223a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802240:	a1 84 60 80 00       	mov    0x806084,%eax
  802245:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80224b:	83 c4 10             	add    $0x10,%esp
  80224e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802253:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802256:	c9                   	leave  
  802257:	c3                   	ret    

00802258 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802258:	55                   	push   %ebp
  802259:	89 e5                	mov    %esp,%ebp
  80225b:	83 ec 08             	sub    $0x8,%esp
  80225e:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  802261:	8b 55 08             	mov    0x8(%ebp),%edx
  802264:	8b 52 0c             	mov    0xc(%edx),%edx
  802267:	89 15 00 60 80 00    	mov    %edx,0x806000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  80226d:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  802272:	76 05                	jbe    802279 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  802274:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  802279:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(req->req_buf, buf, movesize);
  80227e:	83 ec 04             	sub    $0x4,%esp
  802281:	50                   	push   %eax
  802282:	ff 75 0c             	pushl  0xc(%ebp)
  802285:	68 08 60 80 00       	push   $0x806008
  80228a:	e8 77 ef ff ff       	call   801206 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  80228f:	ba 00 00 00 00       	mov    $0x0,%edx
  802294:	b8 04 00 00 00       	mov    $0x4,%eax
  802299:	e8 c8 fe ff ff       	call   802166 <fsipc>
	return write;
}
  80229e:	c9                   	leave  
  80229f:	c3                   	ret    

008022a0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	56                   	push   %esi
  8022a4:	53                   	push   %ebx
  8022a5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8022a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8022ae:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  8022b3:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8022b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022be:	b8 03 00 00 00       	mov    $0x3,%eax
  8022c3:	e8 9e fe ff ff       	call   802166 <fsipc>
  8022c8:	89 c3                	mov    %eax,%ebx
  8022ca:	85 c0                	test   %eax,%eax
  8022cc:	78 4b                	js     802319 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8022ce:	39 c6                	cmp    %eax,%esi
  8022d0:	73 16                	jae    8022e8 <devfile_read+0x48>
  8022d2:	68 b8 39 80 00       	push   $0x8039b8
  8022d7:	68 49 34 80 00       	push   $0x803449
  8022dc:	6a 7c                	push   $0x7c
  8022de:	68 bf 39 80 00       	push   $0x8039bf
  8022e3:	e8 2f e7 ff ff       	call   800a17 <_panic>
	assert(r <= PGSIZE);
  8022e8:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8022ed:	7e 16                	jle    802305 <devfile_read+0x65>
  8022ef:	68 ca 39 80 00       	push   $0x8039ca
  8022f4:	68 49 34 80 00       	push   $0x803449
  8022f9:	6a 7d                	push   $0x7d
  8022fb:	68 bf 39 80 00       	push   $0x8039bf
  802300:	e8 12 e7 ff ff       	call   800a17 <_panic>
	memmove(buf, &fsipcbuf, r);
  802305:	83 ec 04             	sub    $0x4,%esp
  802308:	50                   	push   %eax
  802309:	68 00 60 80 00       	push   $0x806000
  80230e:	ff 75 0c             	pushl  0xc(%ebp)
  802311:	e8 f0 ee ff ff       	call   801206 <memmove>
	return r;
  802316:	83 c4 10             	add    $0x10,%esp
}
  802319:	89 d8                	mov    %ebx,%eax
  80231b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80231e:	5b                   	pop    %ebx
  80231f:	5e                   	pop    %esi
  802320:	5d                   	pop    %ebp
  802321:	c3                   	ret    

00802322 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802322:	55                   	push   %ebp
  802323:	89 e5                	mov    %esp,%ebp
  802325:	53                   	push   %ebx
  802326:	83 ec 20             	sub    $0x20,%esp
  802329:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80232c:	53                   	push   %ebx
  80232d:	e8 09 ed ff ff       	call   80103b <strlen>
  802332:	83 c4 10             	add    $0x10,%esp
  802335:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80233a:	7f 67                	jg     8023a3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80233c:	83 ec 0c             	sub    $0xc,%esp
  80233f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802342:	50                   	push   %eax
  802343:	e8 97 f8 ff ff       	call   801bdf <fd_alloc>
  802348:	83 c4 10             	add    $0x10,%esp
		return r;
  80234b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80234d:	85 c0                	test   %eax,%eax
  80234f:	78 57                	js     8023a8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802351:	83 ec 08             	sub    $0x8,%esp
  802354:	53                   	push   %ebx
  802355:	68 00 60 80 00       	push   $0x806000
  80235a:	e8 15 ed ff ff       	call   801074 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80235f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802362:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802367:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80236a:	b8 01 00 00 00       	mov    $0x1,%eax
  80236f:	e8 f2 fd ff ff       	call   802166 <fsipc>
  802374:	89 c3                	mov    %eax,%ebx
  802376:	83 c4 10             	add    $0x10,%esp
  802379:	85 c0                	test   %eax,%eax
  80237b:	79 14                	jns    802391 <open+0x6f>
		fd_close(fd, 0);
  80237d:	83 ec 08             	sub    $0x8,%esp
  802380:	6a 00                	push   $0x0
  802382:	ff 75 f4             	pushl  -0xc(%ebp)
  802385:	e8 4d f9 ff ff       	call   801cd7 <fd_close>
		return r;
  80238a:	83 c4 10             	add    $0x10,%esp
  80238d:	89 da                	mov    %ebx,%edx
  80238f:	eb 17                	jmp    8023a8 <open+0x86>
	}

	return fd2num(fd);
  802391:	83 ec 0c             	sub    $0xc,%esp
  802394:	ff 75 f4             	pushl  -0xc(%ebp)
  802397:	e8 1c f8 ff ff       	call   801bb8 <fd2num>
  80239c:	89 c2                	mov    %eax,%edx
  80239e:	83 c4 10             	add    $0x10,%esp
  8023a1:	eb 05                	jmp    8023a8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8023a3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8023a8:	89 d0                	mov    %edx,%eax
  8023aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023ad:	c9                   	leave  
  8023ae:	c3                   	ret    

008023af <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8023af:	55                   	push   %ebp
  8023b0:	89 e5                	mov    %esp,%ebp
  8023b2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8023b5:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ba:	b8 08 00 00 00       	mov    $0x8,%eax
  8023bf:	e8 a2 fd ff ff       	call   802166 <fsipc>
}
  8023c4:	c9                   	leave  
  8023c5:	c3                   	ret    

008023c6 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8023c6:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  8023ca:	7e 3a                	jle    802406 <writebuf+0x40>
};


static void
writebuf(struct printbuf *b)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	53                   	push   %ebx
  8023d0:	83 ec 08             	sub    $0x8,%esp
  8023d3:	89 c3                	mov    %eax,%ebx
	if (b->error > 0) {
		ssize_t result = write(b->fd, b->buf, b->idx);
  8023d5:	ff 70 04             	pushl  0x4(%eax)
  8023d8:	8d 40 10             	lea    0x10(%eax),%eax
  8023db:	50                   	push   %eax
  8023dc:	ff 33                	pushl  (%ebx)
  8023de:	e8 8a fb ff ff       	call   801f6d <write>
		if (result > 0)
  8023e3:	83 c4 10             	add    $0x10,%esp
  8023e6:	85 c0                	test   %eax,%eax
  8023e8:	7e 03                	jle    8023ed <writebuf+0x27>
			b->result += result;
  8023ea:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8023ed:	39 43 04             	cmp    %eax,0x4(%ebx)
  8023f0:	74 10                	je     802402 <writebuf+0x3c>
			b->error = (result < 0 ? result : 0);
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	0f 9f c2             	setg   %dl
  8023f7:	0f b6 d2             	movzbl %dl,%edx
  8023fa:	83 ea 01             	sub    $0x1,%edx
  8023fd:	21 d0                	and    %edx,%eax
  8023ff:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  802402:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802405:	c9                   	leave  
  802406:	f3 c3                	repz ret 

00802408 <putch>:

static void
putch(int ch, void *thunk)
{
  802408:	55                   	push   %ebp
  802409:	89 e5                	mov    %esp,%ebp
  80240b:	53                   	push   %ebx
  80240c:	83 ec 04             	sub    $0x4,%esp
  80240f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  802412:	8b 53 04             	mov    0x4(%ebx),%edx
  802415:	8d 42 01             	lea    0x1(%edx),%eax
  802418:	89 43 04             	mov    %eax,0x4(%ebx)
  80241b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80241e:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  802422:	3d 00 01 00 00       	cmp    $0x100,%eax
  802427:	75 0e                	jne    802437 <putch+0x2f>
		writebuf(b);
  802429:	89 d8                	mov    %ebx,%eax
  80242b:	e8 96 ff ff ff       	call   8023c6 <writebuf>
		b->idx = 0;
  802430:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	}
}
  802437:	83 c4 04             	add    $0x4,%esp
  80243a:	5b                   	pop    %ebx
  80243b:	5d                   	pop    %ebp
  80243c:	c3                   	ret    

0080243d <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80243d:	55                   	push   %ebp
  80243e:	89 e5                	mov    %esp,%ebp
  802440:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802446:	8b 45 08             	mov    0x8(%ebp),%eax
  802449:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80244f:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802456:	00 00 00 
	b.result = 0;
  802459:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  802460:	00 00 00 
	b.error = 1;
  802463:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80246a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80246d:	ff 75 10             	pushl  0x10(%ebp)
  802470:	ff 75 0c             	pushl  0xc(%ebp)
  802473:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802479:	50                   	push   %eax
  80247a:	68 08 24 80 00       	push   $0x802408
  80247f:	e8 9e e7 ff ff       	call   800c22 <vprintfmt>
	if (b.idx > 0)
  802484:	83 c4 10             	add    $0x10,%esp
  802487:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80248e:	7e 0b                	jle    80249b <vfprintf+0x5e>
		writebuf(&b);
  802490:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802496:	e8 2b ff ff ff       	call   8023c6 <writebuf>

	return (b.result ? b.result : b.error);
  80249b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8024a1:	85 c0                	test   %eax,%eax
  8024a3:	75 06                	jne    8024ab <vfprintf+0x6e>
  8024a5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  8024ab:	c9                   	leave  
  8024ac:	c3                   	ret    

008024ad <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8024ad:	55                   	push   %ebp
  8024ae:	89 e5                	mov    %esp,%ebp
  8024b0:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024b3:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8024b6:	50                   	push   %eax
  8024b7:	ff 75 0c             	pushl  0xc(%ebp)
  8024ba:	ff 75 08             	pushl  0x8(%ebp)
  8024bd:	e8 7b ff ff ff       	call   80243d <vfprintf>
	va_end(ap);

	return cnt;
}
  8024c2:	c9                   	leave  
  8024c3:	c3                   	ret    

008024c4 <printf>:

int
printf(const char *fmt, ...)
{
  8024c4:	55                   	push   %ebp
  8024c5:	89 e5                	mov    %esp,%ebp
  8024c7:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8024ca:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  8024cd:	50                   	push   %eax
  8024ce:	ff 75 08             	pushl  0x8(%ebp)
  8024d1:	6a 01                	push   $0x1
  8024d3:	e8 65 ff ff ff       	call   80243d <vfprintf>
	va_end(ap);

	return cnt;
}
  8024d8:	c9                   	leave  
  8024d9:	c3                   	ret    

008024da <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8024da:	55                   	push   %ebp
  8024db:	89 e5                	mov    %esp,%ebp
  8024dd:	57                   	push   %edi
  8024de:	56                   	push   %esi
  8024df:	53                   	push   %ebx
  8024e0:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  8024e6:	6a 00                	push   $0x0
  8024e8:	ff 75 08             	pushl  0x8(%ebp)
  8024eb:	e8 32 fe ff ff       	call   802322 <open>
  8024f0:	89 c1                	mov    %eax,%ecx
  8024f2:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  8024f8:	83 c4 10             	add    $0x10,%esp
  8024fb:	85 c0                	test   %eax,%eax
  8024fd:	0f 88 c6 04 00 00    	js     8029c9 <spawn+0x4ef>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  802503:	83 ec 04             	sub    $0x4,%esp
  802506:	68 00 02 00 00       	push   $0x200
  80250b:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802511:	50                   	push   %eax
  802512:	51                   	push   %ecx
  802513:	e8 10 fa ff ff       	call   801f28 <readn>
  802518:	83 c4 10             	add    $0x10,%esp
  80251b:	3d 00 02 00 00       	cmp    $0x200,%eax
  802520:	75 0c                	jne    80252e <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  802522:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802529:	45 4c 46 
  80252c:	74 33                	je     802561 <spawn+0x87>
		close(fd);
  80252e:	83 ec 0c             	sub    $0xc,%esp
  802531:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802537:	e8 1b f8 ff ff       	call   801d57 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  80253c:	83 c4 0c             	add    $0xc,%esp
  80253f:	68 7f 45 4c 46       	push   $0x464c457f
  802544:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  80254a:	68 d6 39 80 00       	push   $0x8039d6
  80254f:	e8 9c e5 ff ff       	call   800af0 <cprintf>
		return -E_NOT_EXEC;
  802554:	83 c4 10             	add    $0x10,%esp
  802557:	b8 f2 ff ff ff       	mov    $0xfffffff2,%eax
  80255c:	e9 c8 04 00 00       	jmp    802a29 <spawn+0x54f>
  802561:	b8 07 00 00 00       	mov    $0x7,%eax
  802566:	cd 30                	int    $0x30
  802568:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80256e:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  802574:	85 c0                	test   %eax,%eax
  802576:	0f 88 55 04 00 00    	js     8029d1 <spawn+0x4f7>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  80257c:	89 c6                	mov    %eax,%esi
  80257e:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802584:	6b f6 78             	imul   $0x78,%esi,%esi
  802587:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80258d:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802593:	b9 11 00 00 00       	mov    $0x11,%ecx
  802598:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  80259a:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8025a0:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025a6:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8025ab:	be 00 00 00 00       	mov    $0x0,%esi
  8025b0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025b3:	eb 13                	jmp    8025c8 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8025b5:	83 ec 0c             	sub    $0xc,%esp
  8025b8:	50                   	push   %eax
  8025b9:	e8 7d ea ff ff       	call   80103b <strlen>
  8025be:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8025c2:	83 c3 01             	add    $0x1,%ebx
  8025c5:	83 c4 10             	add    $0x10,%esp
  8025c8:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8025cf:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8025d2:	85 c0                	test   %eax,%eax
  8025d4:	75 df                	jne    8025b5 <spawn+0xdb>
  8025d6:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8025dc:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8025e2:	bf 00 10 40 00       	mov    $0x401000,%edi
  8025e7:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8025e9:	89 fa                	mov    %edi,%edx
  8025eb:	83 e2 fc             	and    $0xfffffffc,%edx
  8025ee:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8025f5:	29 c2                	sub    %eax,%edx
  8025f7:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  8025fd:	8d 42 f8             	lea    -0x8(%edx),%eax
  802600:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  802605:	0f 86 d6 03 00 00    	jbe    8029e1 <spawn+0x507>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  80260b:	83 ec 04             	sub    $0x4,%esp
  80260e:	6a 07                	push   $0x7
  802610:	68 00 00 40 00       	push   $0x400000
  802615:	6a 00                	push   $0x0
  802617:	e8 55 ef ff ff       	call   801571 <sys_page_alloc>
  80261c:	83 c4 10             	add    $0x10,%esp
  80261f:	85 c0                	test   %eax,%eax
  802621:	0f 88 02 04 00 00    	js     802a29 <spawn+0x54f>
  802627:	be 00 00 00 00       	mov    $0x0,%esi
  80262c:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  802632:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  802635:	eb 30                	jmp    802667 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  802637:	8d 87 00 d0 3f ee    	lea    -0x11c03000(%edi),%eax
  80263d:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  802643:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  802646:	83 ec 08             	sub    $0x8,%esp
  802649:	ff 34 b3             	pushl  (%ebx,%esi,4)
  80264c:	57                   	push   %edi
  80264d:	e8 22 ea ff ff       	call   801074 <strcpy>
		string_store += strlen(argv[i]) + 1;
  802652:	83 c4 04             	add    $0x4,%esp
  802655:	ff 34 b3             	pushl  (%ebx,%esi,4)
  802658:	e8 de e9 ff ff       	call   80103b <strlen>
  80265d:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  802661:	83 c6 01             	add    $0x1,%esi
  802664:	83 c4 10             	add    $0x10,%esp
  802667:	3b b5 90 fd ff ff    	cmp    -0x270(%ebp),%esi
  80266d:	7c c8                	jl     802637 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80266f:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802675:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  80267b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  802682:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802688:	74 19                	je     8026a3 <spawn+0x1c9>
  80268a:	68 5c 3a 80 00       	push   $0x803a5c
  80268f:	68 49 34 80 00       	push   $0x803449
  802694:	68 f1 00 00 00       	push   $0xf1
  802699:	68 f0 39 80 00       	push   $0x8039f0
  80269e:	e8 74 e3 ff ff       	call   800a17 <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8026a3:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8026a9:	89 f8                	mov    %edi,%eax
  8026ab:	2d 00 30 c0 11       	sub    $0x11c03000,%eax
  8026b0:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8026b3:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8026b9:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8026bc:	8d 87 f8 cf 3f ee    	lea    -0x11c03008(%edi),%eax
  8026c2:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8026c8:	83 ec 0c             	sub    $0xc,%esp
  8026cb:	6a 07                	push   $0x7
  8026cd:	68 00 d0 7f ee       	push   $0xee7fd000
  8026d2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8026d8:	68 00 00 40 00       	push   $0x400000
  8026dd:	6a 00                	push   $0x0
  8026df:	e8 d0 ee ff ff       	call   8015b4 <sys_page_map>
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	83 c4 20             	add    $0x20,%esp
  8026e9:	85 c0                	test   %eax,%eax
  8026eb:	0f 88 24 03 00 00    	js     802a15 <spawn+0x53b>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8026f1:	83 ec 08             	sub    $0x8,%esp
  8026f4:	68 00 00 40 00       	push   $0x400000
  8026f9:	6a 00                	push   $0x0
  8026fb:	e8 f6 ee ff ff       	call   8015f6 <sys_page_unmap>
  802700:	89 c3                	mov    %eax,%ebx
  802702:	83 c4 10             	add    $0x10,%esp
  802705:	85 c0                	test   %eax,%eax
  802707:	0f 88 08 03 00 00    	js     802a15 <spawn+0x53b>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  80270d:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802713:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  80271a:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802720:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  802727:	00 00 00 
  80272a:	e9 84 01 00 00       	jmp    8028b3 <spawn+0x3d9>
		if (ph->p_type != ELF_PROG_LOAD)
  80272f:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  802735:	83 38 01             	cmpl   $0x1,(%eax)
  802738:	0f 85 67 01 00 00    	jne    8028a5 <spawn+0x3cb>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80273e:	89 c1                	mov    %eax,%ecx
  802740:	8b 40 18             	mov    0x18(%eax),%eax
  802743:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802749:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  80274c:	83 f8 01             	cmp    $0x1,%eax
  80274f:	19 c0                	sbb    %eax,%eax
  802751:	83 e0 fe             	and    $0xfffffffe,%eax
  802754:	83 c0 07             	add    $0x7,%eax
  802757:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  80275d:	89 c8                	mov    %ecx,%eax
  80275f:	8b 49 04             	mov    0x4(%ecx),%ecx
  802762:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
  802768:	8b 78 10             	mov    0x10(%eax),%edi
  80276b:	8b 48 14             	mov    0x14(%eax),%ecx
  80276e:	89 8d 90 fd ff ff    	mov    %ecx,-0x270(%ebp)
  802774:	8b 70 08             	mov    0x8(%eax),%esi
{
	int i, r;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  802777:	89 f0                	mov    %esi,%eax
  802779:	25 ff 0f 00 00       	and    $0xfff,%eax
  80277e:	74 10                	je     802790 <spawn+0x2b6>
		va -= i;
  802780:	29 c6                	sub    %eax,%esi
		memsz += i;
  802782:	01 85 90 fd ff ff    	add    %eax,-0x270(%ebp)
		filesz += i;
  802788:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  80278a:	29 85 80 fd ff ff    	sub    %eax,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802790:	bb 00 00 00 00       	mov    $0x0,%ebx
  802795:	e9 f9 00 00 00       	jmp    802893 <spawn+0x3b9>
		if (i >= filesz) {
  80279a:	39 fb                	cmp    %edi,%ebx
  80279c:	72 27                	jb     8027c5 <spawn+0x2eb>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  80279e:	83 ec 04             	sub    $0x4,%esp
  8027a1:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8027a7:	56                   	push   %esi
  8027a8:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8027ae:	e8 be ed ff ff       	call   801571 <sys_page_alloc>
  8027b3:	83 c4 10             	add    $0x10,%esp
  8027b6:	85 c0                	test   %eax,%eax
  8027b8:	0f 89 c9 00 00 00    	jns    802887 <spawn+0x3ad>
  8027be:	89 c7                	mov    %eax,%edi
  8027c0:	e9 2d 02 00 00       	jmp    8029f2 <spawn+0x518>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8027c5:	83 ec 04             	sub    $0x4,%esp
  8027c8:	6a 07                	push   $0x7
  8027ca:	68 00 00 40 00       	push   $0x400000
  8027cf:	6a 00                	push   $0x0
  8027d1:	e8 9b ed ff ff       	call   801571 <sys_page_alloc>
  8027d6:	83 c4 10             	add    $0x10,%esp
  8027d9:	85 c0                	test   %eax,%eax
  8027db:	0f 88 07 02 00 00    	js     8029e8 <spawn+0x50e>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  8027e1:	83 ec 08             	sub    $0x8,%esp
  8027e4:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  8027ea:	03 85 80 fd ff ff    	add    -0x280(%ebp),%eax
  8027f0:	50                   	push   %eax
  8027f1:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8027f7:	e8 fd f7 ff ff       	call   801ff9 <seek>
  8027fc:	83 c4 10             	add    $0x10,%esp
  8027ff:	85 c0                	test   %eax,%eax
  802801:	0f 88 e5 01 00 00    	js     8029ec <spawn+0x512>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  802807:	83 ec 04             	sub    $0x4,%esp
  80280a:	89 fa                	mov    %edi,%edx
  80280c:	2b 95 94 fd ff ff    	sub    -0x26c(%ebp),%edx
  802812:	89 d0                	mov    %edx,%eax
  802814:	81 fa 00 10 00 00    	cmp    $0x1000,%edx
  80281a:	76 05                	jbe    802821 <spawn+0x347>
  80281c:	b8 00 10 00 00       	mov    $0x1000,%eax
  802821:	50                   	push   %eax
  802822:	68 00 00 40 00       	push   $0x400000
  802827:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80282d:	e8 f6 f6 ff ff       	call   801f28 <readn>
  802832:	83 c4 10             	add    $0x10,%esp
  802835:	85 c0                	test   %eax,%eax
  802837:	0f 88 b3 01 00 00    	js     8029f0 <spawn+0x516>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80283d:	83 ec 0c             	sub    $0xc,%esp
  802840:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  802846:	56                   	push   %esi
  802847:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80284d:	68 00 00 40 00       	push   $0x400000
  802852:	6a 00                	push   $0x0
  802854:	e8 5b ed ff ff       	call   8015b4 <sys_page_map>
  802859:	83 c4 20             	add    $0x20,%esp
  80285c:	85 c0                	test   %eax,%eax
  80285e:	79 15                	jns    802875 <spawn+0x39b>
				panic("spawn: sys_page_map data: %i", r);
  802860:	50                   	push   %eax
  802861:	68 fc 39 80 00       	push   $0x8039fc
  802866:	68 23 01 00 00       	push   $0x123
  80286b:	68 f0 39 80 00       	push   $0x8039f0
  802870:	e8 a2 e1 ff ff       	call   800a17 <_panic>
			sys_page_unmap(0, UTEMP);
  802875:	83 ec 08             	sub    $0x8,%esp
  802878:	68 00 00 40 00       	push   $0x400000
  80287d:	6a 00                	push   $0x0
  80287f:	e8 72 ed ff ff       	call   8015f6 <sys_page_unmap>
  802884:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  802887:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80288d:	81 c6 00 10 00 00    	add    $0x1000,%esi
  802893:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  802899:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  80289f:	0f 82 f5 fe ff ff    	jb     80279a <spawn+0x2c0>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8028a5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8028ac:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8028b3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8028ba:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8028c0:	0f 8c 69 fe ff ff    	jl     80272f <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8028c6:	83 ec 0c             	sub    $0xc,%esp
  8028c9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8028cf:	e8 83 f4 ff ff       	call   801d57 <close>
  8028d4:	83 c4 10             	add    $0x10,%esp
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  8028d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8028dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8028e1:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        {
                if (!(uvpd[pn >> 10] & PTE_P) && !(pn % NPTENTRIES))
  8028e7:	89 d8                	mov    %ebx,%eax
  8028e9:	c1 f8 0a             	sar    $0xa,%eax
  8028ec:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8028f3:	a8 01                	test   $0x1,%al
  8028f5:	75 10                	jne    802907 <spawn+0x42d>
  8028f7:	f7 c2 ff 03 00 00    	test   $0x3ff,%edx
  8028fd:	75 08                	jne    802907 <spawn+0x42d>
                {
                        pn += NPTENTRIES - 1;
  8028ff:	81 c3 ff 03 00 00    	add    $0x3ff,%ebx
  802905:	eb 54                	jmp    80295b <spawn+0x481>
                        continue;
                }
                if ((uvpt[pn] & PTE_P) && (uvpt[pn] & PTE_SHARE))
  802907:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80290e:	a8 01                	test   $0x1,%al
  802910:	74 49                	je     80295b <spawn+0x481>
  802912:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  802919:	f6 c4 04             	test   $0x4,%ah
  80291c:	74 3d                	je     80295b <spawn+0x481>
                {
                        va = (void*)(pn << PGSHIFT);
  80291e:	89 da                	mov    %ebx,%edx
  802920:	c1 e2 0c             	shl    $0xc,%edx
                        if ((sys_page_map(0, va, child, va, uvpt[pn] & PTE_SYSCALL)))
  802923:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80292a:	83 ec 0c             	sub    $0xc,%esp
  80292d:	25 07 0e 00 00       	and    $0xe07,%eax
  802932:	50                   	push   %eax
  802933:	52                   	push   %edx
  802934:	56                   	push   %esi
  802935:	52                   	push   %edx
  802936:	6a 00                	push   $0x0
  802938:	e8 77 ec ff ff       	call   8015b4 <sys_page_map>
  80293d:	83 c4 20             	add    $0x20,%esp
  802940:	85 c0                	test   %eax,%eax
  802942:	74 17                	je     80295b <spawn+0x481>
                                panic("copy_shared_pages");
  802944:	83 ec 04             	sub    $0x4,%esp
  802947:	68 19 3a 80 00       	push   $0x803a19
  80294c:	68 3c 01 00 00       	push   $0x13c
  802951:	68 f0 39 80 00       	push   $0x8039f0
  802956:	e8 bc e0 ff ff       	call   800a17 <_panic>
copy_shared_pages(envid_t child)
{
	// LAB 11: Your code here.
	int pn;
        void* va = NULL;
        for (pn = 0; pn < ((UXSTACKTOP - PGSIZE) >> PGSHIFT); pn++)
  80295b:	83 c3 01             	add    $0x1,%ebx
  80295e:	89 da                	mov    %ebx,%edx
  802960:	81 fb fe e7 0e 00    	cmp    $0xee7fe,%ebx
  802966:	0f 86 7b ff ff ff    	jbe    8028e7 <spawn+0x40d>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %i", r);

	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80296c:	83 ec 08             	sub    $0x8,%esp
  80296f:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802975:	50                   	push   %eax
  802976:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  80297c:	e8 f9 ec ff ff       	call   80167a <sys_env_set_trapframe>
  802981:	83 c4 10             	add    $0x10,%esp
  802984:	85 c0                	test   %eax,%eax
  802986:	79 15                	jns    80299d <spawn+0x4c3>
		panic("sys_env_set_trapframe: %i", r);
  802988:	50                   	push   %eax
  802989:	68 2b 3a 80 00       	push   $0x803a2b
  80298e:	68 85 00 00 00       	push   $0x85
  802993:	68 f0 39 80 00       	push   $0x8039f0
  802998:	e8 7a e0 ff ff       	call   800a17 <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  80299d:	83 ec 08             	sub    $0x8,%esp
  8029a0:	6a 02                	push   $0x2
  8029a2:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029a8:	e8 8b ec ff ff       	call   801638 <sys_env_set_status>
  8029ad:	83 c4 10             	add    $0x10,%esp
  8029b0:	85 c0                	test   %eax,%eax
  8029b2:	79 25                	jns    8029d9 <spawn+0x4ff>
		panic("sys_env_set_status: %i", r);
  8029b4:	50                   	push   %eax
  8029b5:	68 45 3a 80 00       	push   $0x803a45
  8029ba:	68 88 00 00 00       	push   $0x88
  8029bf:	68 f0 39 80 00       	push   $0x8039f0
  8029c4:	e8 4e e0 ff ff       	call   800a17 <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  8029c9:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8029cf:	eb 58                	jmp    802a29 <spawn+0x54f>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  8029d1:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8029d7:	eb 50                	jmp    802a29 <spawn+0x54f>
		panic("sys_env_set_trapframe: %i", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %i", r);

	return child;
  8029d9:	8b 85 74 fd ff ff    	mov    -0x28c(%ebp),%eax
  8029df:	eb 48                	jmp    802a29 <spawn+0x54f>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  8029e1:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  8029e6:	eb 41                	jmp    802a29 <spawn+0x54f>
  8029e8:	89 c7                	mov    %eax,%edi
  8029ea:	eb 06                	jmp    8029f2 <spawn+0x518>
  8029ec:	89 c7                	mov    %eax,%edi
  8029ee:	eb 02                	jmp    8029f2 <spawn+0x518>
  8029f0:	89 c7                	mov    %eax,%edi
		panic("sys_env_set_status: %i", r);

	return child;

error:
	sys_env_destroy(child);
  8029f2:	83 ec 0c             	sub    $0xc,%esp
  8029f5:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8029fb:	e8 f2 ea ff ff       	call   8014f2 <sys_env_destroy>
	close(fd);
  802a00:	83 c4 04             	add    $0x4,%esp
  802a03:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802a09:	e8 49 f3 ff ff       	call   801d57 <close>
	return r;
  802a0e:	83 c4 10             	add    $0x10,%esp
  802a11:	89 f8                	mov    %edi,%eax
  802a13:	eb 14                	jmp    802a29 <spawn+0x54f>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  802a15:	83 ec 08             	sub    $0x8,%esp
  802a18:	68 00 00 40 00       	push   $0x400000
  802a1d:	6a 00                	push   $0x0
  802a1f:	e8 d2 eb ff ff       	call   8015f6 <sys_page_unmap>
  802a24:	83 c4 10             	add    $0x10,%esp
  802a27:	89 d8                	mov    %ebx,%eax

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  802a29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a2c:	5b                   	pop    %ebx
  802a2d:	5e                   	pop    %esi
  802a2e:	5f                   	pop    %edi
  802a2f:	5d                   	pop    %ebp
  802a30:	c3                   	ret    

00802a31 <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  802a31:	55                   	push   %ebp
  802a32:	89 e5                	mov    %esp,%ebp
  802a34:	56                   	push   %esi
  802a35:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a36:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  802a39:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a3e:	eb 03                	jmp    802a43 <spawnl+0x12>
		argc++;
  802a40:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  802a43:	83 c2 04             	add    $0x4,%edx
  802a46:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  802a4a:	75 f4                	jne    802a40 <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  802a4c:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  802a53:	83 e2 f0             	and    $0xfffffff0,%edx
  802a56:	29 d4                	sub    %edx,%esp
  802a58:	8d 54 24 03          	lea    0x3(%esp),%edx
  802a5c:	c1 ea 02             	shr    $0x2,%edx
  802a5f:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  802a66:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802a68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802a6b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  802a72:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802a79:	00 
  802a7a:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a7c:	b8 00 00 00 00       	mov    $0x0,%eax
  802a81:	eb 0a                	jmp    802a8d <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  802a83:	83 c0 01             	add    $0x1,%eax
  802a86:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  802a8a:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  802a8d:	39 d0                	cmp    %edx,%eax
  802a8f:	75 f2                	jne    802a83 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  802a91:	83 ec 08             	sub    $0x8,%esp
  802a94:	56                   	push   %esi
  802a95:	ff 75 08             	pushl  0x8(%ebp)
  802a98:	e8 3d fa ff ff       	call   8024da <spawn>
}
  802a9d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802aa0:	5b                   	pop    %ebx
  802aa1:	5e                   	pop    %esi
  802aa2:	5d                   	pop    %ebp
  802aa3:	c3                   	ret    

00802aa4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802aa4:	55                   	push   %ebp
  802aa5:	89 e5                	mov    %esp,%ebp
  802aa7:	56                   	push   %esi
  802aa8:	53                   	push   %ebx
  802aa9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802aac:	83 ec 0c             	sub    $0xc,%esp
  802aaf:	ff 75 08             	pushl  0x8(%ebp)
  802ab2:	e8 11 f1 ff ff       	call   801bc8 <fd2data>
  802ab7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802ab9:	83 c4 08             	add    $0x8,%esp
  802abc:	68 82 3a 80 00       	push   $0x803a82
  802ac1:	53                   	push   %ebx
  802ac2:	e8 ad e5 ff ff       	call   801074 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802ac7:	8b 56 04             	mov    0x4(%esi),%edx
  802aca:	89 d0                	mov    %edx,%eax
  802acc:	2b 06                	sub    (%esi),%eax
  802ace:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802ad4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802adb:	00 00 00 
	stat->st_dev = &devpipe;
  802ade:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802ae5:	40 80 00 
	return 0;
}
  802ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  802aed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802af0:	5b                   	pop    %ebx
  802af1:	5e                   	pop    %esi
  802af2:	5d                   	pop    %ebp
  802af3:	c3                   	ret    

00802af4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802af4:	55                   	push   %ebp
  802af5:	89 e5                	mov    %esp,%ebp
  802af7:	53                   	push   %ebx
  802af8:	83 ec 0c             	sub    $0xc,%esp
  802afb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802afe:	53                   	push   %ebx
  802aff:	6a 00                	push   $0x0
  802b01:	e8 f0 ea ff ff       	call   8015f6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802b06:	89 1c 24             	mov    %ebx,(%esp)
  802b09:	e8 ba f0 ff ff       	call   801bc8 <fd2data>
  802b0e:	83 c4 08             	add    $0x8,%esp
  802b11:	50                   	push   %eax
  802b12:	6a 00                	push   $0x0
  802b14:	e8 dd ea ff ff       	call   8015f6 <sys_page_unmap>
}
  802b19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b1c:	c9                   	leave  
  802b1d:	c3                   	ret    

00802b1e <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802b1e:	55                   	push   %ebp
  802b1f:	89 e5                	mov    %esp,%ebp
  802b21:	57                   	push   %edi
  802b22:	56                   	push   %esi
  802b23:	53                   	push   %ebx
  802b24:	83 ec 1c             	sub    $0x1c,%esp
  802b27:	89 c7                	mov    %eax,%edi
  802b29:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802b2b:	a1 44 54 80 00       	mov    0x805444,%eax
  802b30:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802b33:	83 ec 0c             	sub    $0xc,%esp
  802b36:	57                   	push   %edi
  802b37:	e8 9b 04 00 00       	call   802fd7 <pageref>
  802b3c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802b3f:	89 34 24             	mov    %esi,(%esp)
  802b42:	e8 90 04 00 00       	call   802fd7 <pageref>
  802b47:	83 c4 10             	add    $0x10,%esp
  802b4a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802b4d:	0f 94 c0             	sete   %al
  802b50:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  802b53:	8b 15 44 54 80 00    	mov    0x805444,%edx
  802b59:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802b5c:	39 cb                	cmp    %ecx,%ebx
  802b5e:	74 15                	je     802b75 <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  802b60:	8b 52 58             	mov    0x58(%edx),%edx
  802b63:	50                   	push   %eax
  802b64:	52                   	push   %edx
  802b65:	53                   	push   %ebx
  802b66:	68 90 3a 80 00       	push   $0x803a90
  802b6b:	e8 80 df ff ff       	call   800af0 <cprintf>
  802b70:	83 c4 10             	add    $0x10,%esp
  802b73:	eb b6                	jmp    802b2b <_pipeisclosed+0xd>
	}
}
  802b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b78:	5b                   	pop    %ebx
  802b79:	5e                   	pop    %esi
  802b7a:	5f                   	pop    %edi
  802b7b:	5d                   	pop    %ebp
  802b7c:	c3                   	ret    

00802b7d <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802b7d:	55                   	push   %ebp
  802b7e:	89 e5                	mov    %esp,%ebp
  802b80:	57                   	push   %edi
  802b81:	56                   	push   %esi
  802b82:	53                   	push   %ebx
  802b83:	83 ec 28             	sub    $0x28,%esp
  802b86:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802b89:	56                   	push   %esi
  802b8a:	e8 39 f0 ff ff       	call   801bc8 <fd2data>
  802b8f:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802b91:	83 c4 10             	add    $0x10,%esp
  802b94:	bf 00 00 00 00       	mov    $0x0,%edi
  802b99:	eb 4b                	jmp    802be6 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802b9b:	89 da                	mov    %ebx,%edx
  802b9d:	89 f0                	mov    %esi,%eax
  802b9f:	e8 7a ff ff ff       	call   802b1e <_pipeisclosed>
  802ba4:	85 c0                	test   %eax,%eax
  802ba6:	75 48                	jne    802bf0 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802ba8:	e8 a5 e9 ff ff       	call   801552 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802bad:	8b 43 04             	mov    0x4(%ebx),%eax
  802bb0:	8b 0b                	mov    (%ebx),%ecx
  802bb2:	8d 51 20             	lea    0x20(%ecx),%edx
  802bb5:	39 d0                	cmp    %edx,%eax
  802bb7:	73 e2                	jae    802b9b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802bb9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802bbc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802bc0:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802bc3:	89 c2                	mov    %eax,%edx
  802bc5:	c1 fa 1f             	sar    $0x1f,%edx
  802bc8:	89 d1                	mov    %edx,%ecx
  802bca:	c1 e9 1b             	shr    $0x1b,%ecx
  802bcd:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802bd0:	83 e2 1f             	and    $0x1f,%edx
  802bd3:	29 ca                	sub    %ecx,%edx
  802bd5:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802bd9:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802bdd:	83 c0 01             	add    $0x1,%eax
  802be0:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802be3:	83 c7 01             	add    $0x1,%edi
  802be6:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802be9:	75 c2                	jne    802bad <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802beb:	8b 45 10             	mov    0x10(%ebp),%eax
  802bee:	eb 05                	jmp    802bf5 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802bf0:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802bf8:	5b                   	pop    %ebx
  802bf9:	5e                   	pop    %esi
  802bfa:	5f                   	pop    %edi
  802bfb:	5d                   	pop    %ebp
  802bfc:	c3                   	ret    

00802bfd <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802bfd:	55                   	push   %ebp
  802bfe:	89 e5                	mov    %esp,%ebp
  802c00:	57                   	push   %edi
  802c01:	56                   	push   %esi
  802c02:	53                   	push   %ebx
  802c03:	83 ec 18             	sub    $0x18,%esp
  802c06:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802c09:	57                   	push   %edi
  802c0a:	e8 b9 ef ff ff       	call   801bc8 <fd2data>
  802c0f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c11:	83 c4 10             	add    $0x10,%esp
  802c14:	bb 00 00 00 00       	mov    $0x0,%ebx
  802c19:	eb 3d                	jmp    802c58 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802c1b:	85 db                	test   %ebx,%ebx
  802c1d:	74 04                	je     802c23 <devpipe_read+0x26>
				return i;
  802c1f:	89 d8                	mov    %ebx,%eax
  802c21:	eb 44                	jmp    802c67 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  802c23:	89 f2                	mov    %esi,%edx
  802c25:	89 f8                	mov    %edi,%eax
  802c27:	e8 f2 fe ff ff       	call   802b1e <_pipeisclosed>
  802c2c:	85 c0                	test   %eax,%eax
  802c2e:	75 32                	jne    802c62 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802c30:	e8 1d e9 ff ff       	call   801552 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  802c35:	8b 06                	mov    (%esi),%eax
  802c37:	3b 46 04             	cmp    0x4(%esi),%eax
  802c3a:	74 df                	je     802c1b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802c3c:	99                   	cltd   
  802c3d:	c1 ea 1b             	shr    $0x1b,%edx
  802c40:	01 d0                	add    %edx,%eax
  802c42:	83 e0 1f             	and    $0x1f,%eax
  802c45:	29 d0                	sub    %edx,%eax
  802c47:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  802c4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802c4f:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  802c52:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802c55:	83 c3 01             	add    $0x1,%ebx
  802c58:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  802c5b:	75 d8                	jne    802c35 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  802c5d:	8b 45 10             	mov    0x10(%ebp),%eax
  802c60:	eb 05                	jmp    802c67 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802c62:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802c6a:	5b                   	pop    %ebx
  802c6b:	5e                   	pop    %esi
  802c6c:	5f                   	pop    %edi
  802c6d:	5d                   	pop    %ebp
  802c6e:	c3                   	ret    

00802c6f <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  802c6f:	55                   	push   %ebp
  802c70:	89 e5                	mov    %esp,%ebp
  802c72:	56                   	push   %esi
  802c73:	53                   	push   %ebx
  802c74:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802c77:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c7a:	50                   	push   %eax
  802c7b:	e8 5f ef ff ff       	call   801bdf <fd_alloc>
  802c80:	83 c4 10             	add    $0x10,%esp
  802c83:	89 c2                	mov    %eax,%edx
  802c85:	85 c0                	test   %eax,%eax
  802c87:	0f 88 2c 01 00 00    	js     802db9 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802c8d:	83 ec 04             	sub    $0x4,%esp
  802c90:	68 07 04 00 00       	push   $0x407
  802c95:	ff 75 f4             	pushl  -0xc(%ebp)
  802c98:	6a 00                	push   $0x0
  802c9a:	e8 d2 e8 ff ff       	call   801571 <sys_page_alloc>
  802c9f:	83 c4 10             	add    $0x10,%esp
  802ca2:	89 c2                	mov    %eax,%edx
  802ca4:	85 c0                	test   %eax,%eax
  802ca6:	0f 88 0d 01 00 00    	js     802db9 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802cac:	83 ec 0c             	sub    $0xc,%esp
  802caf:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802cb2:	50                   	push   %eax
  802cb3:	e8 27 ef ff ff       	call   801bdf <fd_alloc>
  802cb8:	89 c3                	mov    %eax,%ebx
  802cba:	83 c4 10             	add    $0x10,%esp
  802cbd:	85 c0                	test   %eax,%eax
  802cbf:	0f 88 e2 00 00 00    	js     802da7 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cc5:	83 ec 04             	sub    $0x4,%esp
  802cc8:	68 07 04 00 00       	push   $0x407
  802ccd:	ff 75 f0             	pushl  -0x10(%ebp)
  802cd0:	6a 00                	push   $0x0
  802cd2:	e8 9a e8 ff ff       	call   801571 <sys_page_alloc>
  802cd7:	89 c3                	mov    %eax,%ebx
  802cd9:	83 c4 10             	add    $0x10,%esp
  802cdc:	85 c0                	test   %eax,%eax
  802cde:	0f 88 c3 00 00 00    	js     802da7 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802ce4:	83 ec 0c             	sub    $0xc,%esp
  802ce7:	ff 75 f4             	pushl  -0xc(%ebp)
  802cea:	e8 d9 ee ff ff       	call   801bc8 <fd2data>
  802cef:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802cf1:	83 c4 0c             	add    $0xc,%esp
  802cf4:	68 07 04 00 00       	push   $0x407
  802cf9:	50                   	push   %eax
  802cfa:	6a 00                	push   $0x0
  802cfc:	e8 70 e8 ff ff       	call   801571 <sys_page_alloc>
  802d01:	89 c3                	mov    %eax,%ebx
  802d03:	83 c4 10             	add    $0x10,%esp
  802d06:	85 c0                	test   %eax,%eax
  802d08:	0f 88 89 00 00 00    	js     802d97 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802d0e:	83 ec 0c             	sub    $0xc,%esp
  802d11:	ff 75 f0             	pushl  -0x10(%ebp)
  802d14:	e8 af ee ff ff       	call   801bc8 <fd2data>
  802d19:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802d20:	50                   	push   %eax
  802d21:	6a 00                	push   $0x0
  802d23:	56                   	push   %esi
  802d24:	6a 00                	push   $0x0
  802d26:	e8 89 e8 ff ff       	call   8015b4 <sys_page_map>
  802d2b:	89 c3                	mov    %eax,%ebx
  802d2d:	83 c4 20             	add    $0x20,%esp
  802d30:	85 c0                	test   %eax,%eax
  802d32:	78 55                	js     802d89 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  802d34:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d3d:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802d3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802d42:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  802d49:	8b 15 3c 40 80 00    	mov    0x80403c,%edx
  802d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d52:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  802d54:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802d57:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  802d5e:	83 ec 0c             	sub    $0xc,%esp
  802d61:	ff 75 f4             	pushl  -0xc(%ebp)
  802d64:	e8 4f ee ff ff       	call   801bb8 <fd2num>
  802d69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d6c:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802d6e:	83 c4 04             	add    $0x4,%esp
  802d71:	ff 75 f0             	pushl  -0x10(%ebp)
  802d74:	e8 3f ee ff ff       	call   801bb8 <fd2num>
  802d79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802d7c:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802d7f:	83 c4 10             	add    $0x10,%esp
  802d82:	ba 00 00 00 00       	mov    $0x0,%edx
  802d87:	eb 30                	jmp    802db9 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802d89:	83 ec 08             	sub    $0x8,%esp
  802d8c:	56                   	push   %esi
  802d8d:	6a 00                	push   $0x0
  802d8f:	e8 62 e8 ff ff       	call   8015f6 <sys_page_unmap>
  802d94:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802d97:	83 ec 08             	sub    $0x8,%esp
  802d9a:	ff 75 f0             	pushl  -0x10(%ebp)
  802d9d:	6a 00                	push   $0x0
  802d9f:	e8 52 e8 ff ff       	call   8015f6 <sys_page_unmap>
  802da4:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802da7:	83 ec 08             	sub    $0x8,%esp
  802daa:	ff 75 f4             	pushl  -0xc(%ebp)
  802dad:	6a 00                	push   $0x0
  802daf:	e8 42 e8 ff ff       	call   8015f6 <sys_page_unmap>
  802db4:	83 c4 10             	add    $0x10,%esp
  802db7:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802db9:	89 d0                	mov    %edx,%eax
  802dbb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802dbe:	5b                   	pop    %ebx
  802dbf:	5e                   	pop    %esi
  802dc0:	5d                   	pop    %ebp
  802dc1:	c3                   	ret    

00802dc2 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802dc2:	55                   	push   %ebp
  802dc3:	89 e5                	mov    %esp,%ebp
  802dc5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802dcb:	50                   	push   %eax
  802dcc:	ff 75 08             	pushl  0x8(%ebp)
  802dcf:	e8 5a ee ff ff       	call   801c2e <fd_lookup>
  802dd4:	89 c2                	mov    %eax,%edx
  802dd6:	83 c4 10             	add    $0x10,%esp
  802dd9:	85 d2                	test   %edx,%edx
  802ddb:	78 18                	js     802df5 <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802ddd:	83 ec 0c             	sub    $0xc,%esp
  802de0:	ff 75 f4             	pushl  -0xc(%ebp)
  802de3:	e8 e0 ed ff ff       	call   801bc8 <fd2data>
	return _pipeisclosed(fd, p);
  802de8:	89 c2                	mov    %eax,%edx
  802dea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802ded:	e8 2c fd ff ff       	call   802b1e <_pipeisclosed>
  802df2:	83 c4 10             	add    $0x10,%esp
}
  802df5:	c9                   	leave  
  802df6:	c3                   	ret    

00802df7 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802df7:	55                   	push   %ebp
  802df8:	89 e5                	mov    %esp,%ebp
  802dfa:	57                   	push   %edi
  802dfb:	56                   	push   %esi
  802dfc:	53                   	push   %ebx
  802dfd:	83 ec 0c             	sub    $0xc,%esp
  802e00:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802e03:	85 f6                	test   %esi,%esi
  802e05:	75 16                	jne    802e1d <wait+0x26>
  802e07:	68 c1 3a 80 00       	push   $0x803ac1
  802e0c:	68 49 34 80 00       	push   $0x803449
  802e11:	6a 09                	push   $0x9
  802e13:	68 cc 3a 80 00       	push   $0x803acc
  802e18:	e8 fa db ff ff       	call   800a17 <_panic>
	e = &envs[ENVX(envid)];
  802e1d:	89 f3                	mov    %esi,%ebx
  802e1f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e25:	6b db 78             	imul   $0x78,%ebx,%ebx
  802e28:	8d 7b 40             	lea    0x40(%ebx),%edi
  802e2b:	83 c3 50             	add    $0x50,%ebx
  802e2e:	eb 05                	jmp    802e35 <wait+0x3e>
		sys_yield();
  802e30:	e8 1d e7 ff ff       	call   801552 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802e35:	8b 87 08 00 c0 ee    	mov    -0x113ffff8(%edi),%eax
  802e3b:	39 f0                	cmp    %esi,%eax
  802e3d:	75 0a                	jne    802e49 <wait+0x52>
  802e3f:	8b 83 04 00 c0 ee    	mov    -0x113ffffc(%ebx),%eax
  802e45:	85 c0                	test   %eax,%eax
  802e47:	75 e7                	jne    802e30 <wait+0x39>
		sys_yield();
}
  802e49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e4c:	5b                   	pop    %ebx
  802e4d:	5e                   	pop    %esi
  802e4e:	5f                   	pop    %edi
  802e4f:	5d                   	pop    %ebp
  802e50:	c3                   	ret    

00802e51 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802e51:	55                   	push   %ebp
  802e52:	89 e5                	mov    %esp,%ebp
  802e54:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802e57:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802e5e:	75 2c                	jne    802e8c <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  802e60:	83 ec 04             	sub    $0x4,%esp
  802e63:	6a 07                	push   $0x7
  802e65:	68 00 f0 7f ee       	push   $0xee7ff000
  802e6a:	6a 00                	push   $0x0
  802e6c:	e8 00 e7 ff ff       	call   801571 <sys_page_alloc>
  802e71:	83 c4 10             	add    $0x10,%esp
  802e74:	85 c0                	test   %eax,%eax
  802e76:	79 14                	jns    802e8c <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  802e78:	83 ec 04             	sub    $0x4,%esp
  802e7b:	68 d8 3a 80 00       	push   $0x803ad8
  802e80:	6a 1f                	push   $0x1f
  802e82:	68 3c 3b 80 00       	push   $0x803b3c
  802e87:	e8 8b db ff ff       	call   800a17 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802e8c:	8b 45 08             	mov    0x8(%ebp),%eax
  802e8f:	a3 00 70 80 00       	mov    %eax,0x807000
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802e94:	83 ec 08             	sub    $0x8,%esp
  802e97:	68 c0 2e 80 00       	push   $0x802ec0
  802e9c:	6a 00                	push   $0x0
  802e9e:	e8 19 e8 ff ff       	call   8016bc <sys_env_set_pgfault_upcall>
  802ea3:	83 c4 10             	add    $0x10,%esp
  802ea6:	85 c0                	test   %eax,%eax
  802ea8:	79 14                	jns    802ebe <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802eaa:	83 ec 04             	sub    $0x4,%esp
  802ead:	68 04 3b 80 00       	push   $0x803b04
  802eb2:	6a 25                	push   $0x25
  802eb4:	68 3c 3b 80 00       	push   $0x803b3c
  802eb9:	e8 59 db ff ff       	call   800a17 <_panic>
}
  802ebe:	c9                   	leave  
  802ebf:	c3                   	ret    

00802ec0 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802ec0:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802ec1:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  802ec6:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802ec8:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  802ecb:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  802ecd:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  802ed1:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  802ed5:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  802ed6:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  802ed9:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  802edb:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  802ede:	83 c4 04             	add    $0x4,%esp
	popal 
  802ee1:	61                   	popa   
	addl $4, %esp 
  802ee2:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  802ee5:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  802ee6:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  802ee7:	c3                   	ret    

00802ee8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802ee8:	55                   	push   %ebp
  802ee9:	89 e5                	mov    %esp,%ebp
  802eeb:	56                   	push   %esi
  802eec:	53                   	push   %ebx
  802eed:	8b 75 08             	mov    0x8(%ebp),%esi
  802ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  802ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  802ef6:	85 f6                	test   %esi,%esi
  802ef8:	74 06                	je     802f00 <ipc_recv+0x18>
  802efa:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  802f00:	85 db                	test   %ebx,%ebx
  802f02:	74 06                	je     802f0a <ipc_recv+0x22>
  802f04:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  802f0a:	83 f8 01             	cmp    $0x1,%eax
  802f0d:	19 d2                	sbb    %edx,%edx
  802f0f:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  802f11:	83 ec 0c             	sub    $0xc,%esp
  802f14:	50                   	push   %eax
  802f15:	e8 07 e8 ff ff       	call   801721 <sys_ipc_recv>
  802f1a:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  802f1c:	83 c4 10             	add    $0x10,%esp
  802f1f:	85 d2                	test   %edx,%edx
  802f21:	75 24                	jne    802f47 <ipc_recv+0x5f>
	if (from_env_store)
  802f23:	85 f6                	test   %esi,%esi
  802f25:	74 0a                	je     802f31 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  802f27:	a1 44 54 80 00       	mov    0x805444,%eax
  802f2c:	8b 40 70             	mov    0x70(%eax),%eax
  802f2f:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  802f31:	85 db                	test   %ebx,%ebx
  802f33:	74 0a                	je     802f3f <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  802f35:	a1 44 54 80 00       	mov    0x805444,%eax
  802f3a:	8b 40 74             	mov    0x74(%eax),%eax
  802f3d:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  802f3f:	a1 44 54 80 00       	mov    0x805444,%eax
  802f44:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  802f47:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f4a:	5b                   	pop    %ebx
  802f4b:	5e                   	pop    %esi
  802f4c:	5d                   	pop    %ebp
  802f4d:	c3                   	ret    

00802f4e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802f4e:	55                   	push   %ebp
  802f4f:	89 e5                	mov    %esp,%ebp
  802f51:	57                   	push   %edi
  802f52:	56                   	push   %esi
  802f53:	53                   	push   %ebx
  802f54:	83 ec 0c             	sub    $0xc,%esp
  802f57:	8b 7d 08             	mov    0x8(%ebp),%edi
  802f5a:	8b 75 0c             	mov    0xc(%ebp),%esi
  802f5d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  802f60:	83 fb 01             	cmp    $0x1,%ebx
  802f63:	19 c0                	sbb    %eax,%eax
  802f65:	09 c3                	or     %eax,%ebx
  802f67:	eb 1c                	jmp    802f85 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  802f69:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802f6c:	74 12                	je     802f80 <ipc_send+0x32>
  802f6e:	50                   	push   %eax
  802f6f:	68 4a 3b 80 00       	push   $0x803b4a
  802f74:	6a 36                	push   $0x36
  802f76:	68 61 3b 80 00       	push   $0x803b61
  802f7b:	e8 97 da ff ff       	call   800a17 <_panic>
		sys_yield();
  802f80:	e8 cd e5 ff ff       	call   801552 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802f85:	ff 75 14             	pushl  0x14(%ebp)
  802f88:	53                   	push   %ebx
  802f89:	56                   	push   %esi
  802f8a:	57                   	push   %edi
  802f8b:	e8 6e e7 ff ff       	call   8016fe <sys_ipc_try_send>
		if (ret == 0) break;
  802f90:	83 c4 10             	add    $0x10,%esp
  802f93:	85 c0                	test   %eax,%eax
  802f95:	75 d2                	jne    802f69 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  802f97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f9a:	5b                   	pop    %ebx
  802f9b:	5e                   	pop    %esi
  802f9c:	5f                   	pop    %edi
  802f9d:	5d                   	pop    %ebp
  802f9e:	c3                   	ret    

00802f9f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802f9f:	55                   	push   %ebp
  802fa0:	89 e5                	mov    %esp,%ebp
  802fa2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802fa5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802faa:	6b d0 78             	imul   $0x78,%eax,%edx
  802fad:	83 c2 50             	add    $0x50,%edx
  802fb0:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  802fb6:	39 ca                	cmp    %ecx,%edx
  802fb8:	75 0d                	jne    802fc7 <ipc_find_env+0x28>
			return envs[i].env_id;
  802fba:	6b c0 78             	imul   $0x78,%eax,%eax
  802fbd:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  802fc2:	8b 40 08             	mov    0x8(%eax),%eax
  802fc5:	eb 0e                	jmp    802fd5 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802fc7:	83 c0 01             	add    $0x1,%eax
  802fca:	3d 00 04 00 00       	cmp    $0x400,%eax
  802fcf:	75 d9                	jne    802faa <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802fd1:	66 b8 00 00          	mov    $0x0,%ax
}
  802fd5:	5d                   	pop    %ebp
  802fd6:	c3                   	ret    

00802fd7 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802fd7:	55                   	push   %ebp
  802fd8:	89 e5                	mov    %esp,%ebp
  802fda:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fdd:	89 d0                	mov    %edx,%eax
  802fdf:	c1 e8 16             	shr    $0x16,%eax
  802fe2:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802fe9:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fee:	f6 c1 01             	test   $0x1,%cl
  802ff1:	74 1d                	je     803010 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802ff3:	c1 ea 0c             	shr    $0xc,%edx
  802ff6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802ffd:	f6 c2 01             	test   $0x1,%dl
  803000:	74 0e                	je     803010 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803002:	c1 ea 0c             	shr    $0xc,%edx
  803005:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80300c:	ef 
  80300d:	0f b7 c0             	movzwl %ax,%eax
}
  803010:	5d                   	pop    %ebp
  803011:	c3                   	ret    
  803012:	66 90                	xchg   %ax,%ax
  803014:	66 90                	xchg   %ax,%ax
  803016:	66 90                	xchg   %ax,%ax
  803018:	66 90                	xchg   %ax,%ax
  80301a:	66 90                	xchg   %ax,%ax
  80301c:	66 90                	xchg   %ax,%ax
  80301e:	66 90                	xchg   %ax,%ax

00803020 <__udivdi3>:
  803020:	55                   	push   %ebp
  803021:	57                   	push   %edi
  803022:	56                   	push   %esi
  803023:	83 ec 10             	sub    $0x10,%esp
  803026:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80302a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80302e:	8b 74 24 24          	mov    0x24(%esp),%esi
  803032:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  803036:	85 d2                	test   %edx,%edx
  803038:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80303c:	89 34 24             	mov    %esi,(%esp)
  80303f:	89 c8                	mov    %ecx,%eax
  803041:	75 35                	jne    803078 <__udivdi3+0x58>
  803043:	39 f1                	cmp    %esi,%ecx
  803045:	0f 87 bd 00 00 00    	ja     803108 <__udivdi3+0xe8>
  80304b:	85 c9                	test   %ecx,%ecx
  80304d:	89 cd                	mov    %ecx,%ebp
  80304f:	75 0b                	jne    80305c <__udivdi3+0x3c>
  803051:	b8 01 00 00 00       	mov    $0x1,%eax
  803056:	31 d2                	xor    %edx,%edx
  803058:	f7 f1                	div    %ecx
  80305a:	89 c5                	mov    %eax,%ebp
  80305c:	89 f0                	mov    %esi,%eax
  80305e:	31 d2                	xor    %edx,%edx
  803060:	f7 f5                	div    %ebp
  803062:	89 c6                	mov    %eax,%esi
  803064:	89 f8                	mov    %edi,%eax
  803066:	f7 f5                	div    %ebp
  803068:	89 f2                	mov    %esi,%edx
  80306a:	83 c4 10             	add    $0x10,%esp
  80306d:	5e                   	pop    %esi
  80306e:	5f                   	pop    %edi
  80306f:	5d                   	pop    %ebp
  803070:	c3                   	ret    
  803071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803078:	3b 14 24             	cmp    (%esp),%edx
  80307b:	77 7b                	ja     8030f8 <__udivdi3+0xd8>
  80307d:	0f bd f2             	bsr    %edx,%esi
  803080:	83 f6 1f             	xor    $0x1f,%esi
  803083:	0f 84 97 00 00 00    	je     803120 <__udivdi3+0x100>
  803089:	bd 20 00 00 00       	mov    $0x20,%ebp
  80308e:	89 d7                	mov    %edx,%edi
  803090:	89 f1                	mov    %esi,%ecx
  803092:	29 f5                	sub    %esi,%ebp
  803094:	d3 e7                	shl    %cl,%edi
  803096:	89 c2                	mov    %eax,%edx
  803098:	89 e9                	mov    %ebp,%ecx
  80309a:	d3 ea                	shr    %cl,%edx
  80309c:	89 f1                	mov    %esi,%ecx
  80309e:	09 fa                	or     %edi,%edx
  8030a0:	8b 3c 24             	mov    (%esp),%edi
  8030a3:	d3 e0                	shl    %cl,%eax
  8030a5:	89 54 24 08          	mov    %edx,0x8(%esp)
  8030a9:	89 e9                	mov    %ebp,%ecx
  8030ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8030af:	8b 44 24 04          	mov    0x4(%esp),%eax
  8030b3:	89 fa                	mov    %edi,%edx
  8030b5:	d3 ea                	shr    %cl,%edx
  8030b7:	89 f1                	mov    %esi,%ecx
  8030b9:	d3 e7                	shl    %cl,%edi
  8030bb:	89 e9                	mov    %ebp,%ecx
  8030bd:	d3 e8                	shr    %cl,%eax
  8030bf:	09 c7                	or     %eax,%edi
  8030c1:	89 f8                	mov    %edi,%eax
  8030c3:	f7 74 24 08          	divl   0x8(%esp)
  8030c7:	89 d5                	mov    %edx,%ebp
  8030c9:	89 c7                	mov    %eax,%edi
  8030cb:	f7 64 24 0c          	mull   0xc(%esp)
  8030cf:	39 d5                	cmp    %edx,%ebp
  8030d1:	89 14 24             	mov    %edx,(%esp)
  8030d4:	72 11                	jb     8030e7 <__udivdi3+0xc7>
  8030d6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8030da:	89 f1                	mov    %esi,%ecx
  8030dc:	d3 e2                	shl    %cl,%edx
  8030de:	39 c2                	cmp    %eax,%edx
  8030e0:	73 5e                	jae    803140 <__udivdi3+0x120>
  8030e2:	3b 2c 24             	cmp    (%esp),%ebp
  8030e5:	75 59                	jne    803140 <__udivdi3+0x120>
  8030e7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8030ea:	31 f6                	xor    %esi,%esi
  8030ec:	89 f2                	mov    %esi,%edx
  8030ee:	83 c4 10             	add    $0x10,%esp
  8030f1:	5e                   	pop    %esi
  8030f2:	5f                   	pop    %edi
  8030f3:	5d                   	pop    %ebp
  8030f4:	c3                   	ret    
  8030f5:	8d 76 00             	lea    0x0(%esi),%esi
  8030f8:	31 f6                	xor    %esi,%esi
  8030fa:	31 c0                	xor    %eax,%eax
  8030fc:	89 f2                	mov    %esi,%edx
  8030fe:	83 c4 10             	add    $0x10,%esp
  803101:	5e                   	pop    %esi
  803102:	5f                   	pop    %edi
  803103:	5d                   	pop    %ebp
  803104:	c3                   	ret    
  803105:	8d 76 00             	lea    0x0(%esi),%esi
  803108:	89 f2                	mov    %esi,%edx
  80310a:	31 f6                	xor    %esi,%esi
  80310c:	89 f8                	mov    %edi,%eax
  80310e:	f7 f1                	div    %ecx
  803110:	89 f2                	mov    %esi,%edx
  803112:	83 c4 10             	add    $0x10,%esp
  803115:	5e                   	pop    %esi
  803116:	5f                   	pop    %edi
  803117:	5d                   	pop    %ebp
  803118:	c3                   	ret    
  803119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803120:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  803124:	76 0b                	jbe    803131 <__udivdi3+0x111>
  803126:	31 c0                	xor    %eax,%eax
  803128:	3b 14 24             	cmp    (%esp),%edx
  80312b:	0f 83 37 ff ff ff    	jae    803068 <__udivdi3+0x48>
  803131:	b8 01 00 00 00       	mov    $0x1,%eax
  803136:	e9 2d ff ff ff       	jmp    803068 <__udivdi3+0x48>
  80313b:	90                   	nop
  80313c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803140:	89 f8                	mov    %edi,%eax
  803142:	31 f6                	xor    %esi,%esi
  803144:	e9 1f ff ff ff       	jmp    803068 <__udivdi3+0x48>
  803149:	66 90                	xchg   %ax,%ax
  80314b:	66 90                	xchg   %ax,%ax
  80314d:	66 90                	xchg   %ax,%ax
  80314f:	90                   	nop

00803150 <__umoddi3>:
  803150:	55                   	push   %ebp
  803151:	57                   	push   %edi
  803152:	56                   	push   %esi
  803153:	83 ec 20             	sub    $0x20,%esp
  803156:	8b 44 24 34          	mov    0x34(%esp),%eax
  80315a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80315e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803162:	89 c6                	mov    %eax,%esi
  803164:	89 44 24 10          	mov    %eax,0x10(%esp)
  803168:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80316c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  803170:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803174:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  803178:	89 74 24 18          	mov    %esi,0x18(%esp)
  80317c:	85 c0                	test   %eax,%eax
  80317e:	89 c2                	mov    %eax,%edx
  803180:	75 1e                	jne    8031a0 <__umoddi3+0x50>
  803182:	39 f7                	cmp    %esi,%edi
  803184:	76 52                	jbe    8031d8 <__umoddi3+0x88>
  803186:	89 c8                	mov    %ecx,%eax
  803188:	89 f2                	mov    %esi,%edx
  80318a:	f7 f7                	div    %edi
  80318c:	89 d0                	mov    %edx,%eax
  80318e:	31 d2                	xor    %edx,%edx
  803190:	83 c4 20             	add    $0x20,%esp
  803193:	5e                   	pop    %esi
  803194:	5f                   	pop    %edi
  803195:	5d                   	pop    %ebp
  803196:	c3                   	ret    
  803197:	89 f6                	mov    %esi,%esi
  803199:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8031a0:	39 f0                	cmp    %esi,%eax
  8031a2:	77 5c                	ja     803200 <__umoddi3+0xb0>
  8031a4:	0f bd e8             	bsr    %eax,%ebp
  8031a7:	83 f5 1f             	xor    $0x1f,%ebp
  8031aa:	75 64                	jne    803210 <__umoddi3+0xc0>
  8031ac:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8031b0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8031b4:	0f 86 f6 00 00 00    	jbe    8032b0 <__umoddi3+0x160>
  8031ba:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8031be:	0f 82 ec 00 00 00    	jb     8032b0 <__umoddi3+0x160>
  8031c4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8031c8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8031cc:	83 c4 20             	add    $0x20,%esp
  8031cf:	5e                   	pop    %esi
  8031d0:	5f                   	pop    %edi
  8031d1:	5d                   	pop    %ebp
  8031d2:	c3                   	ret    
  8031d3:	90                   	nop
  8031d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8031d8:	85 ff                	test   %edi,%edi
  8031da:	89 fd                	mov    %edi,%ebp
  8031dc:	75 0b                	jne    8031e9 <__umoddi3+0x99>
  8031de:	b8 01 00 00 00       	mov    $0x1,%eax
  8031e3:	31 d2                	xor    %edx,%edx
  8031e5:	f7 f7                	div    %edi
  8031e7:	89 c5                	mov    %eax,%ebp
  8031e9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8031ed:	31 d2                	xor    %edx,%edx
  8031ef:	f7 f5                	div    %ebp
  8031f1:	89 c8                	mov    %ecx,%eax
  8031f3:	f7 f5                	div    %ebp
  8031f5:	eb 95                	jmp    80318c <__umoddi3+0x3c>
  8031f7:	89 f6                	mov    %esi,%esi
  8031f9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803200:	89 c8                	mov    %ecx,%eax
  803202:	89 f2                	mov    %esi,%edx
  803204:	83 c4 20             	add    $0x20,%esp
  803207:	5e                   	pop    %esi
  803208:	5f                   	pop    %edi
  803209:	5d                   	pop    %ebp
  80320a:	c3                   	ret    
  80320b:	90                   	nop
  80320c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803210:	b8 20 00 00 00       	mov    $0x20,%eax
  803215:	89 e9                	mov    %ebp,%ecx
  803217:	29 e8                	sub    %ebp,%eax
  803219:	d3 e2                	shl    %cl,%edx
  80321b:	89 c7                	mov    %eax,%edi
  80321d:	89 44 24 18          	mov    %eax,0x18(%esp)
  803221:	8b 44 24 0c          	mov    0xc(%esp),%eax
  803225:	89 f9                	mov    %edi,%ecx
  803227:	d3 e8                	shr    %cl,%eax
  803229:	89 c1                	mov    %eax,%ecx
  80322b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80322f:	09 d1                	or     %edx,%ecx
  803231:	89 fa                	mov    %edi,%edx
  803233:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  803237:	89 e9                	mov    %ebp,%ecx
  803239:	d3 e0                	shl    %cl,%eax
  80323b:	89 f9                	mov    %edi,%ecx
  80323d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  803241:	89 f0                	mov    %esi,%eax
  803243:	d3 e8                	shr    %cl,%eax
  803245:	89 e9                	mov    %ebp,%ecx
  803247:	89 c7                	mov    %eax,%edi
  803249:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80324d:	d3 e6                	shl    %cl,%esi
  80324f:	89 d1                	mov    %edx,%ecx
  803251:	89 fa                	mov    %edi,%edx
  803253:	d3 e8                	shr    %cl,%eax
  803255:	89 e9                	mov    %ebp,%ecx
  803257:	09 f0                	or     %esi,%eax
  803259:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80325d:	f7 74 24 10          	divl   0x10(%esp)
  803261:	d3 e6                	shl    %cl,%esi
  803263:	89 d1                	mov    %edx,%ecx
  803265:	f7 64 24 0c          	mull   0xc(%esp)
  803269:	39 d1                	cmp    %edx,%ecx
  80326b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80326f:	89 d7                	mov    %edx,%edi
  803271:	89 c6                	mov    %eax,%esi
  803273:	72 0a                	jb     80327f <__umoddi3+0x12f>
  803275:	39 44 24 14          	cmp    %eax,0x14(%esp)
  803279:	73 10                	jae    80328b <__umoddi3+0x13b>
  80327b:	39 d1                	cmp    %edx,%ecx
  80327d:	75 0c                	jne    80328b <__umoddi3+0x13b>
  80327f:	89 d7                	mov    %edx,%edi
  803281:	89 c6                	mov    %eax,%esi
  803283:	2b 74 24 0c          	sub    0xc(%esp),%esi
  803287:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80328b:	89 ca                	mov    %ecx,%edx
  80328d:	89 e9                	mov    %ebp,%ecx
  80328f:	8b 44 24 14          	mov    0x14(%esp),%eax
  803293:	29 f0                	sub    %esi,%eax
  803295:	19 fa                	sbb    %edi,%edx
  803297:	d3 e8                	shr    %cl,%eax
  803299:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80329e:	89 d7                	mov    %edx,%edi
  8032a0:	d3 e7                	shl    %cl,%edi
  8032a2:	89 e9                	mov    %ebp,%ecx
  8032a4:	09 f8                	or     %edi,%eax
  8032a6:	d3 ea                	shr    %cl,%edx
  8032a8:	83 c4 20             	add    $0x20,%esp
  8032ab:	5e                   	pop    %esi
  8032ac:	5f                   	pop    %edi
  8032ad:	5d                   	pop    %ebp
  8032ae:	c3                   	ret    
  8032af:	90                   	nop
  8032b0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8032b4:	29 f9                	sub    %edi,%ecx
  8032b6:	19 c6                	sbb    %eax,%esi
  8032b8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8032bc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8032c0:	e9 ff fe ff ff       	jmp    8031c4 <__umoddi3+0x74>
