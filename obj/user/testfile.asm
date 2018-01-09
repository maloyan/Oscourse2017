
obj/user/testfile:     file format elf32-i386


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
  80002c:	e8 f6 05 00 00       	call   800627 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 9d 0c 00 00       	call   800ce4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  800054:	e8 5c 13 00 00       	call   8013b5 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 fc 12 00 00       	call   801364 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 85 12 00 00       	call   8012fe <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 c0 23 80 00       	mov    $0x8023c0,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	89 c2                	mov    %eax,%edx
  80009b:	c1 ea 1f             	shr    $0x1f,%edx
  80009e:	84 d2                	test   %dl,%dl
  8000a0:	74 17                	je     8000b9 <umain+0x3b>
  8000a2:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %i", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 cb 23 80 00       	push   $0x8023cb
  8000ad:	6a 20                	push   $0x20
  8000af:	68 e5 23 80 00       	push   $0x8023e5
  8000b4:	e8 ce 05 00 00       	call   800687 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 80 25 80 00       	push   $0x802580
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 e5 23 80 00       	push   $0x8023e5
  8000cc:	e8 b6 05 00 00       	call   800687 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 f5 23 80 00       	mov    $0x8023f5,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %i", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 fe 23 80 00       	push   $0x8023fe
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 e5 23 80 00       	push   $0x8023e5
  8000f1:	e8 91 05 00 00       	call   800687 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 a4 25 80 00       	push   $0x8025a4
  800119:	6a 27                	push   $0x27
  80011b:	68 e5 23 80 00       	push   $0x8023e5
  800120:	e8 62 05 00 00       	call   800687 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 16 24 80 00       	push   $0x802416
  80012d:	e8 2e 06 00 00       	call   800760 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 30 80 00    	call   *0x80301c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %i", r);
  80014e:	50                   	push   %eax
  80014f:	68 2a 24 80 00       	push   $0x80242a
  800154:	6a 2b                	push   $0x2b
  800156:	68 e5 23 80 00       	push   $0x8023e5
  80015b:	e8 27 05 00 00       	call   800687 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 30 80 00    	pushl  0x803000
  800169:	e8 3d 0b 00 00       	call   800cab <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 30 80 00    	pushl  0x803000
  80017f:	e8 27 0b 00 00       	call   800cab <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 d4 25 80 00       	push   $0x8025d4
  80018f:	6a 2d                	push   $0x2d
  800191:	68 e5 23 80 00       	push   $0x8023e5
  800196:	e8 ec 04 00 00       	call   800687 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 38 24 80 00       	push   $0x802438
  8001a3:	e8 b8 05 00 00       	call   800760 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 6b 0c 00 00       	call   800e29 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 30 80 00    	call   *0x803010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %i", r);
  8001d9:	50                   	push   %eax
  8001da:	68 4b 24 80 00       	push   $0x80244b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 e5 23 80 00       	push   $0x8023e5
  8001e6:	e8 9c 04 00 00       	call   800687 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 30 80 00    	pushl  0x803000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 8e 0b 00 00       	call   800d8e <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 59 24 80 00       	push   $0x802459
  80020f:	6a 34                	push   $0x34
  800211:	68 e5 23 80 00       	push   $0x8023e5
  800216:	e8 6c 04 00 00       	call   800687 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 77 24 80 00       	push   $0x802477
  800223:	e8 38 05 00 00       	call   800760 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 30 80 00    	call   *0x803018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %i", r);
  80023c:	50                   	push   %eax
  80023d:	68 8a 24 80 00       	push   $0x80248a
  800242:	6a 38                	push   $0x38
  800244:	68 e5 23 80 00       	push   $0x8023e5
  800249:	e8 39 04 00 00       	call   800687 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 99 24 80 00       	push   $0x802499
  800256:	e8 05 05 00 00       	call   800760 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 e9 0e 00 00       	call   801173 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 30 80 00    	call   *0x803010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %i", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 fc 25 80 00       	push   $0x8025fc
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 e5 23 80 00       	push   $0x8023e5
  8002b8:	e8 ca 03 00 00       	call   800687 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ad 24 80 00       	push   $0x8024ad
  8002c5:	e8 96 04 00 00       	call   800760 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 c3 24 80 00       	mov    $0x8024c3,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %i", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 cd 24 80 00       	push   $0x8024cd
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 e5 23 80 00       	push   $0x8023e5
  8002ed:	e8 95 03 00 00       	call   800687 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 30 80 00    	pushl  0x803000
  800301:	e8 a5 09 00 00       	call   800cab <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 30 80 00    	pushl  0x803000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 30 80 00    	pushl  0x803000
  800322:	e8 84 09 00 00       	call   800cab <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %i", r);
  80032e:	53                   	push   %ebx
  80032f:	68 e6 24 80 00       	push   $0x8024e6
  800334:	6a 4b                	push   $0x4b
  800336:	68 e5 23 80 00       	push   $0x8023e5
  80033b:	e8 47 03 00 00       	call   800687 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 f5 24 80 00       	push   $0x8024f5
  800348:	e8 13 04 00 00       	call   800760 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 bc 0a 00 00       	call   800e29 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 30 80 00    	call   *0x803010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %i", r);
  80038a:	50                   	push   %eax
  80038b:	68 34 26 80 00       	push   $0x802634
  800390:	6a 51                	push   $0x51
  800392:	68 e5 23 80 00       	push   $0x8023e5
  800397:	e8 eb 02 00 00       	call   800687 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 30 80 00    	pushl  0x803000
  8003a5:	e8 01 09 00 00       	call   800cab <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 d8                	cmp    %ebx,%eax
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 54 26 80 00       	push   $0x802654
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 e5 23 80 00       	push   $0x8023e5
  8003be:	e8 c4 02 00 00       	call   800687 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 30 80 00    	pushl  0x803000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 b6 09 00 00       	call   800d8e <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 8c 26 80 00       	push   $0x80268c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 e5 23 80 00       	push   $0x8023e5
  8003ee:	e8 94 02 00 00       	call   800687 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 bc 26 80 00       	push   $0x8026bc
  8003fb:	e8 60 03 00 00       	call   800760 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 c0 23 80 00       	push   $0x8023c0
  80040a:	e8 48 17 00 00       	call   801b57 <open>
  80040f:	89 c2                	mov    %eax,%edx
  800411:	c1 ea 1f             	shr    $0x1f,%edx
  800414:	83 c4 10             	add    $0x10,%esp
  800417:	84 d2                	test   %dl,%dl
  800419:	74 17                	je     800432 <umain+0x3b4>
  80041b:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %i", r);
  800420:	50                   	push   %eax
  800421:	68 d1 23 80 00       	push   $0x8023d1
  800426:	6a 5a                	push   $0x5a
  800428:	68 e5 23 80 00       	push   $0x8023e5
  80042d:	e8 55 02 00 00       	call   800687 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 09 25 80 00       	push   $0x802509
  80043e:	6a 5c                	push   $0x5c
  800440:	68 e5 23 80 00       	push   $0x8023e5
  800445:	e8 3d 02 00 00       	call   800687 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 f5 23 80 00       	push   $0x8023f5
  800454:	e8 fe 16 00 00       	call   801b57 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %i", r);
  800460:	50                   	push   %eax
  800461:	68 04 24 80 00       	push   $0x802404
  800466:	6a 5f                	push   $0x5f
  800468:	68 e5 23 80 00       	push   $0x8023e5
  80046d:	e8 15 02 00 00       	call   800687 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 e0 26 80 00       	push   $0x8026e0
  800498:	6a 62                	push   $0x62
  80049a:	68 e5 23 80 00       	push   $0x8023e5
  80049f:	e8 e3 01 00 00       	call   800687 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 1c 24 80 00       	push   $0x80241c
  8004ac:	e8 af 02 00 00       	call   800760 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 24 25 80 00       	push   $0x802524
  8004be:	e8 94 16 00 00       	call   801b57 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %i", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 29 25 80 00       	push   $0x802529
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 e5 23 80 00       	push   $0x8023e5
  8004d9:	e8 a9 01 00 00       	call   800687 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 35 09 00 00       	call   800e29 <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %i", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 8b 12 00 00       	call   8017a2 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %i", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 38 25 80 00       	push   $0x802538
  800528:	6a 6c                	push   $0x6c
  80052a:	68 e5 23 80 00       	push   $0x8023e5
  80052f:	e8 53 01 00 00       	call   800687 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %i", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %i", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 40 10 00 00       	call   80158c <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 24 25 80 00       	push   $0x802524
  800556:	e8 fc 15 00 00       	call   801b57 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %i", f);
  800564:	50                   	push   %eax
  800565:	68 4a 25 80 00       	push   $0x80254a
  80056a:	6a 71                	push   $0x71
  80056c:	68 e5 23 80 00       	push   $0x8023e5
  800571:	e8 11 01 00 00       	call   800687 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %i", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 c7 11 00 00       	call   80175d <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %i", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 58 25 80 00       	push   $0x802558
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 e5 23 80 00       	push   $0x8023e5
  8005ae:	e8 d4 00 00 00       	call   800687 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 08 27 80 00       	push   $0x802708
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 e5 23 80 00       	push   $0x8023e5
  8005d0:	e8 b2 00 00 00       	call   800687 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 34 27 80 00       	push   $0x802734
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 e5 23 80 00       	push   $0x8023e5
  8005f0:	e8 92 00 00 00       	call   800687 <_panic>
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %i", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005f5:	8d 98 00 02 00 00    	lea    0x200(%eax),%ebx
  8005fb:	81 fb ff df 01 00    	cmp    $0x1dfff,%ebx
  800601:	0f 8e 7a ff ff ff    	jle    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800607:	83 ec 0c             	sub    $0xc,%esp
  80060a:	56                   	push   %esi
  80060b:	e8 7c 0f 00 00       	call   80158c <close>
	cprintf("large file is good\n");
  800610:	c7 04 24 69 25 80 00 	movl   $0x802569,(%esp)
  800617:	e8 44 01 00 00       	call   800760 <cprintf>
  80061c:	83 c4 10             	add    $0x10,%esp
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	56                   	push   %esi
  80062b:	53                   	push   %ebx
  80062c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80062f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800632:	e8 79 0a 00 00       	call   8010b0 <sys_getenvid>
  800637:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063c:	6b c0 78             	imul   $0x78,%eax,%eax
  80063f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800644:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800649:	85 db                	test   %ebx,%ebx
  80064b:	7e 07                	jle    800654 <libmain+0x2d>
		binaryname = argv[0];
  80064d:	8b 06                	mov    (%esi),%eax
  80064f:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	56                   	push   %esi
  800658:	53                   	push   %ebx
  800659:	e8 20 fa ff ff       	call   80007e <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80065e:	e8 0a 00 00 00       	call   80066d <exit>
  800663:	83 c4 10             	add    $0x10,%esp
#endif
}
  800666:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800669:	5b                   	pop    %ebx
  80066a:	5e                   	pop    %esi
  80066b:	5d                   	pop    %ebp
  80066c:	c3                   	ret    

0080066d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066d:	55                   	push   %ebp
  80066e:	89 e5                	mov    %esp,%ebp
  800670:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800673:	e8 41 0f 00 00       	call   8015b9 <close_all>
	sys_env_destroy(0);
  800678:	83 ec 0c             	sub    $0xc,%esp
  80067b:	6a 00                	push   $0x0
  80067d:	e8 ed 09 00 00       	call   80106f <sys_env_destroy>
  800682:	83 c4 10             	add    $0x10,%esp
}
  800685:	c9                   	leave  
  800686:	c3                   	ret    

00800687 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800687:	55                   	push   %ebp
  800688:	89 e5                	mov    %esp,%ebp
  80068a:	56                   	push   %esi
  80068b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80068f:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800695:	e8 16 0a 00 00       	call   8010b0 <sys_getenvid>
  80069a:	83 ec 0c             	sub    $0xc,%esp
  80069d:	ff 75 0c             	pushl  0xc(%ebp)
  8006a0:	ff 75 08             	pushl  0x8(%ebp)
  8006a3:	56                   	push   %esi
  8006a4:	50                   	push   %eax
  8006a5:	68 8c 27 80 00       	push   $0x80278c
  8006aa:	e8 b1 00 00 00       	call   800760 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006af:	83 c4 18             	add    $0x18,%esp
  8006b2:	53                   	push   %ebx
  8006b3:	ff 75 10             	pushl  0x10(%ebp)
  8006b6:	e8 54 00 00 00       	call   80070f <vcprintf>
	cprintf("\n");
  8006bb:	c7 04 24 88 24 80 00 	movl   $0x802488,(%esp)
  8006c2:	e8 99 00 00 00       	call   800760 <cprintf>
  8006c7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006ca:	cc                   	int3   
  8006cb:	eb fd                	jmp    8006ca <_panic+0x43>

008006cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	53                   	push   %ebx
  8006d1:	83 ec 04             	sub    $0x4,%esp
  8006d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d7:	8b 13                	mov    (%ebx),%edx
  8006d9:	8d 42 01             	lea    0x1(%edx),%eax
  8006dc:	89 03                	mov    %eax,(%ebx)
  8006de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006ea:	75 1a                	jne    800706 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ec:	83 ec 08             	sub    $0x8,%esp
  8006ef:	68 ff 00 00 00       	push   $0xff
  8006f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f7:	50                   	push   %eax
  8006f8:	e8 35 09 00 00       	call   801032 <sys_cputs>
		b->idx = 0;
  8006fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800703:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800706:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070d:	c9                   	leave  
  80070e:	c3                   	ret    

0080070f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800718:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80071f:	00 00 00 
	b.cnt = 0;
  800722:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800729:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072c:	ff 75 0c             	pushl  0xc(%ebp)
  80072f:	ff 75 08             	pushl  0x8(%ebp)
  800732:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800738:	50                   	push   %eax
  800739:	68 cd 06 80 00       	push   $0x8006cd
  80073e:	e8 4f 01 00 00       	call   800892 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800743:	83 c4 08             	add    $0x8,%esp
  800746:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800752:	50                   	push   %eax
  800753:	e8 da 08 00 00       	call   801032 <sys_cputs>

	return b.cnt;
}
  800758:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075e:	c9                   	leave  
  80075f:	c3                   	ret    

00800760 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800766:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800769:	50                   	push   %eax
  80076a:	ff 75 08             	pushl  0x8(%ebp)
  80076d:	e8 9d ff ff ff       	call   80070f <vcprintf>
	va_end(ap);

	return cnt;
}
  800772:	c9                   	leave  
  800773:	c3                   	ret    

00800774 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	57                   	push   %edi
  800778:	56                   	push   %esi
  800779:	53                   	push   %ebx
  80077a:	83 ec 1c             	sub    $0x1c,%esp
  80077d:	89 c7                	mov    %eax,%edi
  80077f:	89 d6                	mov    %edx,%esi
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
  800787:	89 d1                	mov    %edx,%ecx
  800789:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80078f:	8b 45 10             	mov    0x10(%ebp),%eax
  800792:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800795:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800798:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80079f:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8007a2:	72 05                	jb     8007a9 <printnum+0x35>
  8007a4:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8007a7:	77 3e                	ja     8007e7 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a9:	83 ec 0c             	sub    $0xc,%esp
  8007ac:	ff 75 18             	pushl  0x18(%ebp)
  8007af:	83 eb 01             	sub    $0x1,%ebx
  8007b2:	53                   	push   %ebx
  8007b3:	50                   	push   %eax
  8007b4:	83 ec 08             	sub    $0x8,%esp
  8007b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8007bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c3:	e8 48 19 00 00       	call   802110 <__udivdi3>
  8007c8:	83 c4 18             	add    $0x18,%esp
  8007cb:	52                   	push   %edx
  8007cc:	50                   	push   %eax
  8007cd:	89 f2                	mov    %esi,%edx
  8007cf:	89 f8                	mov    %edi,%eax
  8007d1:	e8 9e ff ff ff       	call   800774 <printnum>
  8007d6:	83 c4 20             	add    $0x20,%esp
  8007d9:	eb 13                	jmp    8007ee <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	56                   	push   %esi
  8007df:	ff 75 18             	pushl  0x18(%ebp)
  8007e2:	ff d7                	call   *%edi
  8007e4:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007e7:	83 eb 01             	sub    $0x1,%ebx
  8007ea:	85 db                	test   %ebx,%ebx
  8007ec:	7f ed                	jg     8007db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	56                   	push   %esi
  8007f2:	83 ec 04             	sub    $0x4,%esp
  8007f5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007f8:	ff 75 e0             	pushl  -0x20(%ebp)
  8007fb:	ff 75 dc             	pushl  -0x24(%ebp)
  8007fe:	ff 75 d8             	pushl  -0x28(%ebp)
  800801:	e8 3a 1a 00 00       	call   802240 <__umoddi3>
  800806:	83 c4 14             	add    $0x14,%esp
  800809:	0f be 80 af 27 80 00 	movsbl 0x8027af(%eax),%eax
  800810:	50                   	push   %eax
  800811:	ff d7                	call   *%edi
  800813:	83 c4 10             	add    $0x10,%esp
}
  800816:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5f                   	pop    %edi
  80081c:	5d                   	pop    %ebp
  80081d:	c3                   	ret    

0080081e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800821:	83 fa 01             	cmp    $0x1,%edx
  800824:	7e 0e                	jle    800834 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800826:	8b 10                	mov    (%eax),%edx
  800828:	8d 4a 08             	lea    0x8(%edx),%ecx
  80082b:	89 08                	mov    %ecx,(%eax)
  80082d:	8b 02                	mov    (%edx),%eax
  80082f:	8b 52 04             	mov    0x4(%edx),%edx
  800832:	eb 22                	jmp    800856 <getuint+0x38>
	else if (lflag)
  800834:	85 d2                	test   %edx,%edx
  800836:	74 10                	je     800848 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800838:	8b 10                	mov    (%eax),%edx
  80083a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80083d:	89 08                	mov    %ecx,(%eax)
  80083f:	8b 02                	mov    (%edx),%eax
  800841:	ba 00 00 00 00       	mov    $0x0,%edx
  800846:	eb 0e                	jmp    800856 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80084d:	89 08                	mov    %ecx,(%eax)
  80084f:	8b 02                	mov    (%edx),%eax
  800851:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800856:	5d                   	pop    %ebp
  800857:	c3                   	ret    

00800858 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800858:	55                   	push   %ebp
  800859:	89 e5                	mov    %esp,%ebp
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80085e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800862:	8b 10                	mov    (%eax),%edx
  800864:	3b 50 04             	cmp    0x4(%eax),%edx
  800867:	73 0a                	jae    800873 <sprintputch+0x1b>
		*b->buf++ = ch;
  800869:	8d 4a 01             	lea    0x1(%edx),%ecx
  80086c:	89 08                	mov    %ecx,(%eax)
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	88 02                	mov    %al,(%edx)
}
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800875:	55                   	push   %ebp
  800876:	89 e5                	mov    %esp,%ebp
  800878:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80087b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80087e:	50                   	push   %eax
  80087f:	ff 75 10             	pushl  0x10(%ebp)
  800882:	ff 75 0c             	pushl  0xc(%ebp)
  800885:	ff 75 08             	pushl  0x8(%ebp)
  800888:	e8 05 00 00 00       	call   800892 <vprintfmt>
	va_end(ap);
  80088d:	83 c4 10             	add    $0x10,%esp
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	57                   	push   %edi
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
  800898:	83 ec 2c             	sub    $0x2c,%esp
  80089b:	8b 75 08             	mov    0x8(%ebp),%esi
  80089e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8008a4:	eb 12                	jmp    8008b8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8008a6:	85 c0                	test   %eax,%eax
  8008a8:	0f 84 8d 03 00 00    	je     800c3b <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	53                   	push   %ebx
  8008b2:	50                   	push   %eax
  8008b3:	ff d6                	call   *%esi
  8008b5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008b8:	83 c7 01             	add    $0x1,%edi
  8008bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8008bf:	83 f8 25             	cmp    $0x25,%eax
  8008c2:	75 e2                	jne    8008a6 <vprintfmt+0x14>
  8008c4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8008c8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8008cf:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008d6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8008e2:	eb 07                	jmp    8008eb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008e7:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008eb:	8d 47 01             	lea    0x1(%edi),%eax
  8008ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008f1:	0f b6 07             	movzbl (%edi),%eax
  8008f4:	0f b6 c8             	movzbl %al,%ecx
  8008f7:	83 e8 23             	sub    $0x23,%eax
  8008fa:	3c 55                	cmp    $0x55,%al
  8008fc:	0f 87 1e 03 00 00    	ja     800c20 <vprintfmt+0x38e>
  800902:	0f b6 c0             	movzbl %al,%eax
  800905:	ff 24 85 00 29 80 00 	jmp    *0x802900(,%eax,4)
  80090c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80090f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800913:	eb d6                	jmp    8008eb <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800915:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800918:	b8 00 00 00 00       	mov    $0x0,%eax
  80091d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800920:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800923:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800927:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80092a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80092d:	83 fa 09             	cmp    $0x9,%edx
  800930:	77 38                	ja     80096a <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800932:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800935:	eb e9                	jmp    800920 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800937:	8b 45 14             	mov    0x14(%ebp),%eax
  80093a:	8d 48 04             	lea    0x4(%eax),%ecx
  80093d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800940:	8b 00                	mov    (%eax),%eax
  800942:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800945:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800948:	eb 26                	jmp    800970 <vprintfmt+0xde>
  80094a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80094d:	89 c8                	mov    %ecx,%eax
  80094f:	c1 f8 1f             	sar    $0x1f,%eax
  800952:	f7 d0                	not    %eax
  800954:	21 c1                	and    %eax,%ecx
  800956:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800959:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80095c:	eb 8d                	jmp    8008eb <vprintfmt+0x59>
  80095e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800961:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800968:	eb 81                	jmp    8008eb <vprintfmt+0x59>
  80096a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80096d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800970:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800974:	0f 89 71 ff ff ff    	jns    8008eb <vprintfmt+0x59>
				width = precision, precision = -1;
  80097a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80097d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800980:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800987:	e9 5f ff ff ff       	jmp    8008eb <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80098c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80098f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800992:	e9 54 ff ff ff       	jmp    8008eb <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800997:	8b 45 14             	mov    0x14(%ebp),%eax
  80099a:	8d 50 04             	lea    0x4(%eax),%edx
  80099d:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a0:	83 ec 08             	sub    $0x8,%esp
  8009a3:	53                   	push   %ebx
  8009a4:	ff 30                	pushl  (%eax)
  8009a6:	ff d6                	call   *%esi
			break;
  8009a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8009ae:	e9 05 ff ff ff       	jmp    8008b8 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8009b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b6:	8d 50 04             	lea    0x4(%eax),%edx
  8009b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bc:	8b 00                	mov    (%eax),%eax
  8009be:	99                   	cltd   
  8009bf:	31 d0                	xor    %edx,%eax
  8009c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009c3:	83 f8 0f             	cmp    $0xf,%eax
  8009c6:	7f 0b                	jg     8009d3 <vprintfmt+0x141>
  8009c8:	8b 14 85 80 2a 80 00 	mov    0x802a80(,%eax,4),%edx
  8009cf:	85 d2                	test   %edx,%edx
  8009d1:	75 18                	jne    8009eb <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8009d3:	50                   	push   %eax
  8009d4:	68 c7 27 80 00       	push   $0x8027c7
  8009d9:	53                   	push   %ebx
  8009da:	56                   	push   %esi
  8009db:	e8 95 fe ff ff       	call   800875 <printfmt>
  8009e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009e6:	e9 cd fe ff ff       	jmp    8008b8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009eb:	52                   	push   %edx
  8009ec:	68 d1 2b 80 00       	push   $0x802bd1
  8009f1:	53                   	push   %ebx
  8009f2:	56                   	push   %esi
  8009f3:	e8 7d fe ff ff       	call   800875 <printfmt>
  8009f8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009fe:	e9 b5 fe ff ff       	jmp    8008b8 <vprintfmt+0x26>
  800a03:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800a06:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800a09:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a0c:	8b 45 14             	mov    0x14(%ebp),%eax
  800a0f:	8d 50 04             	lea    0x4(%eax),%edx
  800a12:	89 55 14             	mov    %edx,0x14(%ebp)
  800a15:	8b 38                	mov    (%eax),%edi
  800a17:	85 ff                	test   %edi,%edi
  800a19:	75 05                	jne    800a20 <vprintfmt+0x18e>
				p = "(null)";
  800a1b:	bf c0 27 80 00       	mov    $0x8027c0,%edi
			if (width > 0 && padc != '-')
  800a20:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800a24:	0f 84 91 00 00 00    	je     800abb <vprintfmt+0x229>
  800a2a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800a2e:	0f 8e 95 00 00 00    	jle    800ac9 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a34:	83 ec 08             	sub    $0x8,%esp
  800a37:	51                   	push   %ecx
  800a38:	57                   	push   %edi
  800a39:	e8 85 02 00 00       	call   800cc3 <strnlen>
  800a3e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a41:	29 c1                	sub    %eax,%ecx
  800a43:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800a46:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a49:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a4d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a50:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a53:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a55:	eb 0f                	jmp    800a66 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800a57:	83 ec 08             	sub    $0x8,%esp
  800a5a:	53                   	push   %ebx
  800a5b:	ff 75 e0             	pushl  -0x20(%ebp)
  800a5e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a60:	83 ef 01             	sub    $0x1,%edi
  800a63:	83 c4 10             	add    $0x10,%esp
  800a66:	85 ff                	test   %edi,%edi
  800a68:	7f ed                	jg     800a57 <vprintfmt+0x1c5>
  800a6a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a6d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a70:	89 c8                	mov    %ecx,%eax
  800a72:	c1 f8 1f             	sar    $0x1f,%eax
  800a75:	f7 d0                	not    %eax
  800a77:	21 c8                	and    %ecx,%eax
  800a79:	29 c1                	sub    %eax,%ecx
  800a7b:	89 75 08             	mov    %esi,0x8(%ebp)
  800a7e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a81:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a84:	89 cb                	mov    %ecx,%ebx
  800a86:	eb 4d                	jmp    800ad5 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a88:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a8c:	74 1b                	je     800aa9 <vprintfmt+0x217>
  800a8e:	0f be c0             	movsbl %al,%eax
  800a91:	83 e8 20             	sub    $0x20,%eax
  800a94:	83 f8 5e             	cmp    $0x5e,%eax
  800a97:	76 10                	jbe    800aa9 <vprintfmt+0x217>
					putch('?', putdat);
  800a99:	83 ec 08             	sub    $0x8,%esp
  800a9c:	ff 75 0c             	pushl  0xc(%ebp)
  800a9f:	6a 3f                	push   $0x3f
  800aa1:	ff 55 08             	call   *0x8(%ebp)
  800aa4:	83 c4 10             	add    $0x10,%esp
  800aa7:	eb 0d                	jmp    800ab6 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800aa9:	83 ec 08             	sub    $0x8,%esp
  800aac:	ff 75 0c             	pushl  0xc(%ebp)
  800aaf:	52                   	push   %edx
  800ab0:	ff 55 08             	call   *0x8(%ebp)
  800ab3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800ab6:	83 eb 01             	sub    $0x1,%ebx
  800ab9:	eb 1a                	jmp    800ad5 <vprintfmt+0x243>
  800abb:	89 75 08             	mov    %esi,0x8(%ebp)
  800abe:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800ac1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ac4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ac7:	eb 0c                	jmp    800ad5 <vprintfmt+0x243>
  800ac9:	89 75 08             	mov    %esi,0x8(%ebp)
  800acc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800acf:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800ad2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800ad5:	83 c7 01             	add    $0x1,%edi
  800ad8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800adc:	0f be d0             	movsbl %al,%edx
  800adf:	85 d2                	test   %edx,%edx
  800ae1:	74 23                	je     800b06 <vprintfmt+0x274>
  800ae3:	85 f6                	test   %esi,%esi
  800ae5:	78 a1                	js     800a88 <vprintfmt+0x1f6>
  800ae7:	83 ee 01             	sub    $0x1,%esi
  800aea:	79 9c                	jns    800a88 <vprintfmt+0x1f6>
  800aec:	89 df                	mov    %ebx,%edi
  800aee:	8b 75 08             	mov    0x8(%ebp),%esi
  800af1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800af4:	eb 18                	jmp    800b0e <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800af6:	83 ec 08             	sub    $0x8,%esp
  800af9:	53                   	push   %ebx
  800afa:	6a 20                	push   $0x20
  800afc:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800afe:	83 ef 01             	sub    $0x1,%edi
  800b01:	83 c4 10             	add    $0x10,%esp
  800b04:	eb 08                	jmp    800b0e <vprintfmt+0x27c>
  800b06:	89 df                	mov    %ebx,%edi
  800b08:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b0e:	85 ff                	test   %edi,%edi
  800b10:	7f e4                	jg     800af6 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b12:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b15:	e9 9e fd ff ff       	jmp    8008b8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b1a:	83 fa 01             	cmp    $0x1,%edx
  800b1d:	7e 16                	jle    800b35 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800b1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b22:	8d 50 08             	lea    0x8(%eax),%edx
  800b25:	89 55 14             	mov    %edx,0x14(%ebp)
  800b28:	8b 50 04             	mov    0x4(%eax),%edx
  800b2b:	8b 00                	mov    (%eax),%eax
  800b2d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b30:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b33:	eb 32                	jmp    800b67 <vprintfmt+0x2d5>
	else if (lflag)
  800b35:	85 d2                	test   %edx,%edx
  800b37:	74 18                	je     800b51 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800b39:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3c:	8d 50 04             	lea    0x4(%eax),%edx
  800b3f:	89 55 14             	mov    %edx,0x14(%ebp)
  800b42:	8b 00                	mov    (%eax),%eax
  800b44:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b47:	89 c1                	mov    %eax,%ecx
  800b49:	c1 f9 1f             	sar    $0x1f,%ecx
  800b4c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b4f:	eb 16                	jmp    800b67 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800b51:	8b 45 14             	mov    0x14(%ebp),%eax
  800b54:	8d 50 04             	lea    0x4(%eax),%edx
  800b57:	89 55 14             	mov    %edx,0x14(%ebp)
  800b5a:	8b 00                	mov    (%eax),%eax
  800b5c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b5f:	89 c1                	mov    %eax,%ecx
  800b61:	c1 f9 1f             	sar    $0x1f,%ecx
  800b64:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b67:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b6a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b6d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b72:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b76:	79 74                	jns    800bec <vprintfmt+0x35a>
				putch('-', putdat);
  800b78:	83 ec 08             	sub    $0x8,%esp
  800b7b:	53                   	push   %ebx
  800b7c:	6a 2d                	push   $0x2d
  800b7e:	ff d6                	call   *%esi
				num = -(long long) num;
  800b80:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800b83:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800b86:	f7 d8                	neg    %eax
  800b88:	83 d2 00             	adc    $0x0,%edx
  800b8b:	f7 da                	neg    %edx
  800b8d:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b90:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800b95:	eb 55                	jmp    800bec <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b97:	8d 45 14             	lea    0x14(%ebp),%eax
  800b9a:	e8 7f fc ff ff       	call   80081e <getuint>
			base = 10;
  800b9f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800ba4:	eb 46                	jmp    800bec <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800ba6:	8d 45 14             	lea    0x14(%ebp),%eax
  800ba9:	e8 70 fc ff ff       	call   80081e <getuint>
			base = 8;
  800bae:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800bb3:	eb 37                	jmp    800bec <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800bb5:	83 ec 08             	sub    $0x8,%esp
  800bb8:	53                   	push   %ebx
  800bb9:	6a 30                	push   $0x30
  800bbb:	ff d6                	call   *%esi
			putch('x', putdat);
  800bbd:	83 c4 08             	add    $0x8,%esp
  800bc0:	53                   	push   %ebx
  800bc1:	6a 78                	push   $0x78
  800bc3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800bc5:	8b 45 14             	mov    0x14(%ebp),%eax
  800bc8:	8d 50 04             	lea    0x4(%eax),%edx
  800bcb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800bce:	8b 00                	mov    (%eax),%eax
  800bd0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800bd5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800bd8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800bdd:	eb 0d                	jmp    800bec <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800bdf:	8d 45 14             	lea    0x14(%ebp),%eax
  800be2:	e8 37 fc ff ff       	call   80081e <getuint>
			base = 16;
  800be7:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bec:	83 ec 0c             	sub    $0xc,%esp
  800bef:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800bf3:	57                   	push   %edi
  800bf4:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf7:	51                   	push   %ecx
  800bf8:	52                   	push   %edx
  800bf9:	50                   	push   %eax
  800bfa:	89 da                	mov    %ebx,%edx
  800bfc:	89 f0                	mov    %esi,%eax
  800bfe:	e8 71 fb ff ff       	call   800774 <printnum>
			break;
  800c03:	83 c4 20             	add    $0x20,%esp
  800c06:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c09:	e9 aa fc ff ff       	jmp    8008b8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c0e:	83 ec 08             	sub    $0x8,%esp
  800c11:	53                   	push   %ebx
  800c12:	51                   	push   %ecx
  800c13:	ff d6                	call   *%esi
			break;
  800c15:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c1b:	e9 98 fc ff ff       	jmp    8008b8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c20:	83 ec 08             	sub    $0x8,%esp
  800c23:	53                   	push   %ebx
  800c24:	6a 25                	push   $0x25
  800c26:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c28:	83 c4 10             	add    $0x10,%esp
  800c2b:	eb 03                	jmp    800c30 <vprintfmt+0x39e>
  800c2d:	83 ef 01             	sub    $0x1,%edi
  800c30:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c34:	75 f7                	jne    800c2d <vprintfmt+0x39b>
  800c36:	e9 7d fc ff ff       	jmp    8008b8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 18             	sub    $0x18,%esp
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c52:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c56:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	74 26                	je     800c8a <vsnprintf+0x47>
  800c64:	85 d2                	test   %edx,%edx
  800c66:	7e 22                	jle    800c8a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c68:	ff 75 14             	pushl  0x14(%ebp)
  800c6b:	ff 75 10             	pushl  0x10(%ebp)
  800c6e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c71:	50                   	push   %eax
  800c72:	68 58 08 80 00       	push   $0x800858
  800c77:	e8 16 fc ff ff       	call   800892 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c7c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c7f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c85:	83 c4 10             	add    $0x10,%esp
  800c88:	eb 05                	jmp    800c8f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c8f:	c9                   	leave  
  800c90:	c3                   	ret    

00800c91 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c91:	55                   	push   %ebp
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c97:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c9a:	50                   	push   %eax
  800c9b:	ff 75 10             	pushl  0x10(%ebp)
  800c9e:	ff 75 0c             	pushl  0xc(%ebp)
  800ca1:	ff 75 08             	pushl  0x8(%ebp)
  800ca4:	e8 9a ff ff ff       	call   800c43 <vsnprintf>
	va_end(ap);

	return rc;
}
  800ca9:	c9                   	leave  
  800caa:	c3                   	ret    

00800cab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800cab:	55                   	push   %ebp
  800cac:	89 e5                	mov    %esp,%ebp
  800cae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	eb 03                	jmp    800cbb <strlen+0x10>
		n++;
  800cb8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cbb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800cbf:	75 f7                	jne    800cb8 <strlen+0xd>
		n++;
	return n;
}
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800ccc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd1:	eb 03                	jmp    800cd6 <strnlen+0x13>
		n++;
  800cd3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cd6:	39 c2                	cmp    %eax,%edx
  800cd8:	74 08                	je     800ce2 <strnlen+0x1f>
  800cda:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cde:	75 f3                	jne    800cd3 <strnlen+0x10>
  800ce0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	53                   	push   %ebx
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cee:	89 c2                	mov    %eax,%edx
  800cf0:	83 c2 01             	add    $0x1,%edx
  800cf3:	83 c1 01             	add    $0x1,%ecx
  800cf6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cfa:	88 5a ff             	mov    %bl,-0x1(%edx)
  800cfd:	84 db                	test   %bl,%bl
  800cff:	75 ef                	jne    800cf0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d01:	5b                   	pop    %ebx
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	53                   	push   %ebx
  800d08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d0b:	53                   	push   %ebx
  800d0c:	e8 9a ff ff ff       	call   800cab <strlen>
  800d11:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d14:	ff 75 0c             	pushl  0xc(%ebp)
  800d17:	01 d8                	add    %ebx,%eax
  800d19:	50                   	push   %eax
  800d1a:	e8 c5 ff ff ff       	call   800ce4 <strcpy>
	return dst;
}
  800d1f:	89 d8                	mov    %ebx,%eax
  800d21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d24:	c9                   	leave  
  800d25:	c3                   	ret    

00800d26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d31:	89 f3                	mov    %esi,%ebx
  800d33:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d36:	89 f2                	mov    %esi,%edx
  800d38:	eb 0f                	jmp    800d49 <strncpy+0x23>
		*dst++ = *src;
  800d3a:	83 c2 01             	add    $0x1,%edx
  800d3d:	0f b6 01             	movzbl (%ecx),%eax
  800d40:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d43:	80 39 01             	cmpb   $0x1,(%ecx)
  800d46:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d49:	39 da                	cmp    %ebx,%edx
  800d4b:	75 ed                	jne    800d3a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d4d:	89 f0                	mov    %esi,%eax
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5d                   	pop    %ebp
  800d52:	c3                   	ret    

00800d53 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	8b 75 08             	mov    0x8(%ebp),%esi
  800d5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5e:	8b 55 10             	mov    0x10(%ebp),%edx
  800d61:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d63:	85 d2                	test   %edx,%edx
  800d65:	74 21                	je     800d88 <strlcpy+0x35>
  800d67:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d6b:	89 f2                	mov    %esi,%edx
  800d6d:	eb 09                	jmp    800d78 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d6f:	83 c2 01             	add    $0x1,%edx
  800d72:	83 c1 01             	add    $0x1,%ecx
  800d75:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d78:	39 c2                	cmp    %eax,%edx
  800d7a:	74 09                	je     800d85 <strlcpy+0x32>
  800d7c:	0f b6 19             	movzbl (%ecx),%ebx
  800d7f:	84 db                	test   %bl,%bl
  800d81:	75 ec                	jne    800d6f <strlcpy+0x1c>
  800d83:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d85:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d88:	29 f0                	sub    %esi,%eax
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5d                   	pop    %ebp
  800d8d:	c3                   	ret    

00800d8e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d94:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d97:	eb 06                	jmp    800d9f <strcmp+0x11>
		p++, q++;
  800d99:	83 c1 01             	add    $0x1,%ecx
  800d9c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d9f:	0f b6 01             	movzbl (%ecx),%eax
  800da2:	84 c0                	test   %al,%al
  800da4:	74 04                	je     800daa <strcmp+0x1c>
  800da6:	3a 02                	cmp    (%edx),%al
  800da8:	74 ef                	je     800d99 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800daa:	0f b6 c0             	movzbl %al,%eax
  800dad:	0f b6 12             	movzbl (%edx),%edx
  800db0:	29 d0                	sub    %edx,%eax
}
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	53                   	push   %ebx
  800db8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dbe:	89 c3                	mov    %eax,%ebx
  800dc0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800dc3:	eb 06                	jmp    800dcb <strncmp+0x17>
		n--, p++, q++;
  800dc5:	83 c0 01             	add    $0x1,%eax
  800dc8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dcb:	39 d8                	cmp    %ebx,%eax
  800dcd:	74 15                	je     800de4 <strncmp+0x30>
  800dcf:	0f b6 08             	movzbl (%eax),%ecx
  800dd2:	84 c9                	test   %cl,%cl
  800dd4:	74 04                	je     800dda <strncmp+0x26>
  800dd6:	3a 0a                	cmp    (%edx),%cl
  800dd8:	74 eb                	je     800dc5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dda:	0f b6 00             	movzbl (%eax),%eax
  800ddd:	0f b6 12             	movzbl (%edx),%edx
  800de0:	29 d0                	sub    %edx,%eax
  800de2:	eb 05                	jmp    800de9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800de4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800de9:	5b                   	pop    %ebx
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
  800df2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800df6:	eb 07                	jmp    800dff <strchr+0x13>
		if (*s == c)
  800df8:	38 ca                	cmp    %cl,%dl
  800dfa:	74 0f                	je     800e0b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfc:	83 c0 01             	add    $0x1,%eax
  800dff:	0f b6 10             	movzbl (%eax),%edx
  800e02:	84 d2                	test   %dl,%dl
  800e04:	75 f2                	jne    800df8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
  800e13:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e17:	eb 03                	jmp    800e1c <strfind+0xf>
  800e19:	83 c0 01             	add    $0x1,%eax
  800e1c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e1f:	84 d2                	test   %dl,%dl
  800e21:	74 04                	je     800e27 <strfind+0x1a>
  800e23:	38 ca                	cmp    %cl,%dl
  800e25:	75 f2                	jne    800e19 <strfind+0xc>
			break;
	return (char *) s;
}
  800e27:	5d                   	pop    %ebp
  800e28:	c3                   	ret    

00800e29 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e32:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800e35:	85 c9                	test   %ecx,%ecx
  800e37:	74 36                	je     800e6f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e39:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e3f:	75 28                	jne    800e69 <memset+0x40>
  800e41:	f6 c1 03             	test   $0x3,%cl
  800e44:	75 23                	jne    800e69 <memset+0x40>
		c &= 0xFF;
  800e46:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e4a:	89 d3                	mov    %edx,%ebx
  800e4c:	c1 e3 08             	shl    $0x8,%ebx
  800e4f:	89 d6                	mov    %edx,%esi
  800e51:	c1 e6 18             	shl    $0x18,%esi
  800e54:	89 d0                	mov    %edx,%eax
  800e56:	c1 e0 10             	shl    $0x10,%eax
  800e59:	09 f0                	or     %esi,%eax
  800e5b:	09 c2                	or     %eax,%edx
  800e5d:	89 d0                	mov    %edx,%eax
  800e5f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e61:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e64:	fc                   	cld    
  800e65:	f3 ab                	rep stos %eax,%es:(%edi)
  800e67:	eb 06                	jmp    800e6f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6c:	fc                   	cld    
  800e6d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e6f:	89 f8                	mov    %edi,%eax
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5f                   	pop    %edi
  800e74:	5d                   	pop    %ebp
  800e75:	c3                   	ret    

00800e76 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	57                   	push   %edi
  800e7a:	56                   	push   %esi
  800e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e81:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e84:	39 c6                	cmp    %eax,%esi
  800e86:	73 35                	jae    800ebd <memmove+0x47>
  800e88:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e8b:	39 d0                	cmp    %edx,%eax
  800e8d:	73 2e                	jae    800ebd <memmove+0x47>
		s += n;
		d += n;
  800e8f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800e92:	89 d6                	mov    %edx,%esi
  800e94:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e9c:	75 13                	jne    800eb1 <memmove+0x3b>
  800e9e:	f6 c1 03             	test   $0x3,%cl
  800ea1:	75 0e                	jne    800eb1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ea3:	83 ef 04             	sub    $0x4,%edi
  800ea6:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ea9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800eac:	fd                   	std    
  800ead:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800eaf:	eb 09                	jmp    800eba <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800eb1:	83 ef 01             	sub    $0x1,%edi
  800eb4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800eb7:	fd                   	std    
  800eb8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800eba:	fc                   	cld    
  800ebb:	eb 1d                	jmp    800eda <memmove+0x64>
  800ebd:	89 f2                	mov    %esi,%edx
  800ebf:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ec1:	f6 c2 03             	test   $0x3,%dl
  800ec4:	75 0f                	jne    800ed5 <memmove+0x5f>
  800ec6:	f6 c1 03             	test   $0x3,%cl
  800ec9:	75 0a                	jne    800ed5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ecb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800ece:	89 c7                	mov    %eax,%edi
  800ed0:	fc                   	cld    
  800ed1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ed3:	eb 05                	jmp    800eda <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ed5:	89 c7                	mov    %eax,%edi
  800ed7:	fc                   	cld    
  800ed8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eda:	5e                   	pop    %esi
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ee1:	ff 75 10             	pushl  0x10(%ebp)
  800ee4:	ff 75 0c             	pushl  0xc(%ebp)
  800ee7:	ff 75 08             	pushl  0x8(%ebp)
  800eea:	e8 87 ff ff ff       	call   800e76 <memmove>
}
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    

00800ef1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	56                   	push   %esi
  800ef5:	53                   	push   %ebx
  800ef6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800efc:	89 c6                	mov    %eax,%esi
  800efe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f01:	eb 1a                	jmp    800f1d <memcmp+0x2c>
		if (*s1 != *s2)
  800f03:	0f b6 08             	movzbl (%eax),%ecx
  800f06:	0f b6 1a             	movzbl (%edx),%ebx
  800f09:	38 d9                	cmp    %bl,%cl
  800f0b:	74 0a                	je     800f17 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f0d:	0f b6 c1             	movzbl %cl,%eax
  800f10:	0f b6 db             	movzbl %bl,%ebx
  800f13:	29 d8                	sub    %ebx,%eax
  800f15:	eb 0f                	jmp    800f26 <memcmp+0x35>
		s1++, s2++;
  800f17:	83 c0 01             	add    $0x1,%eax
  800f1a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f1d:	39 f0                	cmp    %esi,%eax
  800f1f:	75 e2                	jne    800f03 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800f33:	89 c2                	mov    %eax,%edx
  800f35:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f38:	eb 07                	jmp    800f41 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f3a:	38 08                	cmp    %cl,(%eax)
  800f3c:	74 07                	je     800f45 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f3e:	83 c0 01             	add    $0x1,%eax
  800f41:	39 d0                	cmp    %edx,%eax
  800f43:	72 f5                	jb     800f3a <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f45:	5d                   	pop    %ebp
  800f46:	c3                   	ret    

00800f47 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f47:	55                   	push   %ebp
  800f48:	89 e5                	mov    %esp,%ebp
  800f4a:	57                   	push   %edi
  800f4b:	56                   	push   %esi
  800f4c:	53                   	push   %ebx
  800f4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f53:	eb 03                	jmp    800f58 <strtol+0x11>
		s++;
  800f55:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f58:	0f b6 01             	movzbl (%ecx),%eax
  800f5b:	3c 09                	cmp    $0x9,%al
  800f5d:	74 f6                	je     800f55 <strtol+0xe>
  800f5f:	3c 20                	cmp    $0x20,%al
  800f61:	74 f2                	je     800f55 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f63:	3c 2b                	cmp    $0x2b,%al
  800f65:	75 0a                	jne    800f71 <strtol+0x2a>
		s++;
  800f67:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f6a:	bf 00 00 00 00       	mov    $0x0,%edi
  800f6f:	eb 10                	jmp    800f81 <strtol+0x3a>
  800f71:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f76:	3c 2d                	cmp    $0x2d,%al
  800f78:	75 07                	jne    800f81 <strtol+0x3a>
		s++, neg = 1;
  800f7a:	8d 49 01             	lea    0x1(%ecx),%ecx
  800f7d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f81:	85 db                	test   %ebx,%ebx
  800f83:	0f 94 c0             	sete   %al
  800f86:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f8c:	75 19                	jne    800fa7 <strtol+0x60>
  800f8e:	80 39 30             	cmpb   $0x30,(%ecx)
  800f91:	75 14                	jne    800fa7 <strtol+0x60>
  800f93:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f97:	0f 85 8a 00 00 00    	jne    801027 <strtol+0xe0>
		s += 2, base = 16;
  800f9d:	83 c1 02             	add    $0x2,%ecx
  800fa0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800fa5:	eb 16                	jmp    800fbd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800fa7:	84 c0                	test   %al,%al
  800fa9:	74 12                	je     800fbd <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800fab:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fb0:	80 39 30             	cmpb   $0x30,(%ecx)
  800fb3:	75 08                	jne    800fbd <strtol+0x76>
		s++, base = 8;
  800fb5:	83 c1 01             	add    $0x1,%ecx
  800fb8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fbd:	b8 00 00 00 00       	mov    $0x0,%eax
  800fc2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fc5:	0f b6 11             	movzbl (%ecx),%edx
  800fc8:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fcb:	89 f3                	mov    %esi,%ebx
  800fcd:	80 fb 09             	cmp    $0x9,%bl
  800fd0:	77 08                	ja     800fda <strtol+0x93>
			dig = *s - '0';
  800fd2:	0f be d2             	movsbl %dl,%edx
  800fd5:	83 ea 30             	sub    $0x30,%edx
  800fd8:	eb 22                	jmp    800ffc <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800fda:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fdd:	89 f3                	mov    %esi,%ebx
  800fdf:	80 fb 19             	cmp    $0x19,%bl
  800fe2:	77 08                	ja     800fec <strtol+0xa5>
			dig = *s - 'a' + 10;
  800fe4:	0f be d2             	movsbl %dl,%edx
  800fe7:	83 ea 57             	sub    $0x57,%edx
  800fea:	eb 10                	jmp    800ffc <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800fec:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fef:	89 f3                	mov    %esi,%ebx
  800ff1:	80 fb 19             	cmp    $0x19,%bl
  800ff4:	77 16                	ja     80100c <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ff6:	0f be d2             	movsbl %dl,%edx
  800ff9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ffc:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fff:	7d 0f                	jge    801010 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  801001:	83 c1 01             	add    $0x1,%ecx
  801004:	0f af 45 10          	imul   0x10(%ebp),%eax
  801008:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80100a:	eb b9                	jmp    800fc5 <strtol+0x7e>
  80100c:	89 c2                	mov    %eax,%edx
  80100e:	eb 02                	jmp    801012 <strtol+0xcb>
  801010:	89 c2                	mov    %eax,%edx

	if (endptr)
  801012:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801016:	74 05                	je     80101d <strtol+0xd6>
		*endptr = (char *) s;
  801018:	8b 75 0c             	mov    0xc(%ebp),%esi
  80101b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80101d:	85 ff                	test   %edi,%edi
  80101f:	74 0c                	je     80102d <strtol+0xe6>
  801021:	89 d0                	mov    %edx,%eax
  801023:	f7 d8                	neg    %eax
  801025:	eb 06                	jmp    80102d <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801027:	84 c0                	test   %al,%al
  801029:	75 8a                	jne    800fb5 <strtol+0x6e>
  80102b:	eb 90                	jmp    800fbd <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  80102d:	5b                   	pop    %ebx
  80102e:	5e                   	pop    %esi
  80102f:	5f                   	pop    %edi
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    

00801032 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	57                   	push   %edi
  801036:	56                   	push   %esi
  801037:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801038:	b8 00 00 00 00       	mov    $0x0,%eax
  80103d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801040:	8b 55 08             	mov    0x8(%ebp),%edx
  801043:	89 c3                	mov    %eax,%ebx
  801045:	89 c7                	mov    %eax,%edi
  801047:	89 c6                	mov    %eax,%esi
  801049:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80104b:	5b                   	pop    %ebx
  80104c:	5e                   	pop    %esi
  80104d:	5f                   	pop    %edi
  80104e:	5d                   	pop    %ebp
  80104f:	c3                   	ret    

00801050 <sys_cgetc>:

int
sys_cgetc(void)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	57                   	push   %edi
  801054:	56                   	push   %esi
  801055:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801056:	ba 00 00 00 00       	mov    $0x0,%edx
  80105b:	b8 01 00 00 00       	mov    $0x1,%eax
  801060:	89 d1                	mov    %edx,%ecx
  801062:	89 d3                	mov    %edx,%ebx
  801064:	89 d7                	mov    %edx,%edi
  801066:	89 d6                	mov    %edx,%esi
  801068:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80106a:	5b                   	pop    %ebx
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    

0080106f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80106f:	55                   	push   %ebp
  801070:	89 e5                	mov    %esp,%ebp
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	53                   	push   %ebx
  801075:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801078:	b9 00 00 00 00       	mov    $0x0,%ecx
  80107d:	b8 03 00 00 00       	mov    $0x3,%eax
  801082:	8b 55 08             	mov    0x8(%ebp),%edx
  801085:	89 cb                	mov    %ecx,%ebx
  801087:	89 cf                	mov    %ecx,%edi
  801089:	89 ce                	mov    %ecx,%esi
  80108b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80108d:	85 c0                	test   %eax,%eax
  80108f:	7e 17                	jle    8010a8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  801091:	83 ec 0c             	sub    $0xc,%esp
  801094:	50                   	push   %eax
  801095:	6a 03                	push   $0x3
  801097:	68 df 2a 80 00       	push   $0x802adf
  80109c:	6a 23                	push   $0x23
  80109e:	68 fc 2a 80 00       	push   $0x802afc
  8010a3:	e8 df f5 ff ff       	call   800687 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ab:	5b                   	pop    %ebx
  8010ac:	5e                   	pop    %esi
  8010ad:	5f                   	pop    %edi
  8010ae:	5d                   	pop    %ebp
  8010af:	c3                   	ret    

008010b0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010bb:	b8 02 00 00 00       	mov    $0x2,%eax
  8010c0:	89 d1                	mov    %edx,%ecx
  8010c2:	89 d3                	mov    %edx,%ebx
  8010c4:	89 d7                	mov    %edx,%edi
  8010c6:	89 d6                	mov    %edx,%esi
  8010c8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010ca:	5b                   	pop    %ebx
  8010cb:	5e                   	pop    %esi
  8010cc:	5f                   	pop    %edi
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    

008010cf <sys_yield>:

void
sys_yield(void)
{
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	57                   	push   %edi
  8010d3:	56                   	push   %esi
  8010d4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8010da:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010df:	89 d1                	mov    %edx,%ecx
  8010e1:	89 d3                	mov    %edx,%ebx
  8010e3:	89 d7                	mov    %edx,%edi
  8010e5:	89 d6                	mov    %edx,%esi
  8010e7:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010e9:	5b                   	pop    %ebx
  8010ea:	5e                   	pop    %esi
  8010eb:	5f                   	pop    %edi
  8010ec:	5d                   	pop    %ebp
  8010ed:	c3                   	ret    

008010ee <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	57                   	push   %edi
  8010f2:	56                   	push   %esi
  8010f3:	53                   	push   %ebx
  8010f4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f7:	be 00 00 00 00       	mov    $0x0,%esi
  8010fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801101:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801104:	8b 55 08             	mov    0x8(%ebp),%edx
  801107:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80110a:	89 f7                	mov    %esi,%edi
  80110c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80110e:	85 c0                	test   %eax,%eax
  801110:	7e 17                	jle    801129 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  801112:	83 ec 0c             	sub    $0xc,%esp
  801115:	50                   	push   %eax
  801116:	6a 04                	push   $0x4
  801118:	68 df 2a 80 00       	push   $0x802adf
  80111d:	6a 23                	push   $0x23
  80111f:	68 fc 2a 80 00       	push   $0x802afc
  801124:	e8 5e f5 ff ff       	call   800687 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801129:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80112c:	5b                   	pop    %ebx
  80112d:	5e                   	pop    %esi
  80112e:	5f                   	pop    %edi
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	57                   	push   %edi
  801135:	56                   	push   %esi
  801136:	53                   	push   %ebx
  801137:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80113a:	b8 05 00 00 00       	mov    $0x5,%eax
  80113f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801142:	8b 55 08             	mov    0x8(%ebp),%edx
  801145:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801148:	8b 7d 14             	mov    0x14(%ebp),%edi
  80114b:	8b 75 18             	mov    0x18(%ebp),%esi
  80114e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801150:	85 c0                	test   %eax,%eax
  801152:	7e 17                	jle    80116b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	50                   	push   %eax
  801158:	6a 05                	push   $0x5
  80115a:	68 df 2a 80 00       	push   $0x802adf
  80115f:	6a 23                	push   $0x23
  801161:	68 fc 2a 80 00       	push   $0x802afc
  801166:	e8 1c f5 ff ff       	call   800687 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80116b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80116e:	5b                   	pop    %ebx
  80116f:	5e                   	pop    %esi
  801170:	5f                   	pop    %edi
  801171:	5d                   	pop    %ebp
  801172:	c3                   	ret    

00801173 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80117c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801181:	b8 06 00 00 00       	mov    $0x6,%eax
  801186:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801189:	8b 55 08             	mov    0x8(%ebp),%edx
  80118c:	89 df                	mov    %ebx,%edi
  80118e:	89 de                	mov    %ebx,%esi
  801190:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801192:	85 c0                	test   %eax,%eax
  801194:	7e 17                	jle    8011ad <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	50                   	push   %eax
  80119a:	6a 06                	push   $0x6
  80119c:	68 df 2a 80 00       	push   $0x802adf
  8011a1:	6a 23                	push   $0x23
  8011a3:	68 fc 2a 80 00       	push   $0x802afc
  8011a8:	e8 da f4 ff ff       	call   800687 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8011ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b0:	5b                   	pop    %ebx
  8011b1:	5e                   	pop    %esi
  8011b2:	5f                   	pop    %edi
  8011b3:	5d                   	pop    %ebp
  8011b4:	c3                   	ret    

008011b5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	57                   	push   %edi
  8011b9:	56                   	push   %esi
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8011c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ce:	89 df                	mov    %ebx,%edi
  8011d0:	89 de                	mov    %ebx,%esi
  8011d2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	7e 17                	jle    8011ef <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011d8:	83 ec 0c             	sub    $0xc,%esp
  8011db:	50                   	push   %eax
  8011dc:	6a 08                	push   $0x8
  8011de:	68 df 2a 80 00       	push   $0x802adf
  8011e3:	6a 23                	push   $0x23
  8011e5:	68 fc 2a 80 00       	push   $0x802afc
  8011ea:	e8 98 f4 ff ff       	call   800687 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f2:	5b                   	pop    %ebx
  8011f3:	5e                   	pop    %esi
  8011f4:	5f                   	pop    %edi
  8011f5:	5d                   	pop    %ebp
  8011f6:	c3                   	ret    

008011f7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	57                   	push   %edi
  8011fb:	56                   	push   %esi
  8011fc:	53                   	push   %ebx
  8011fd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801200:	bb 00 00 00 00       	mov    $0x0,%ebx
  801205:	b8 09 00 00 00       	mov    $0x9,%eax
  80120a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80120d:	8b 55 08             	mov    0x8(%ebp),%edx
  801210:	89 df                	mov    %ebx,%edi
  801212:	89 de                	mov    %ebx,%esi
  801214:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801216:	85 c0                	test   %eax,%eax
  801218:	7e 17                	jle    801231 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80121a:	83 ec 0c             	sub    $0xc,%esp
  80121d:	50                   	push   %eax
  80121e:	6a 09                	push   $0x9
  801220:	68 df 2a 80 00       	push   $0x802adf
  801225:	6a 23                	push   $0x23
  801227:	68 fc 2a 80 00       	push   $0x802afc
  80122c:	e8 56 f4 ff ff       	call   800687 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  801231:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801234:	5b                   	pop    %ebx
  801235:	5e                   	pop    %esi
  801236:	5f                   	pop    %edi
  801237:	5d                   	pop    %ebp
  801238:	c3                   	ret    

00801239 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	57                   	push   %edi
  80123d:	56                   	push   %esi
  80123e:	53                   	push   %ebx
  80123f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801242:	bb 00 00 00 00       	mov    $0x0,%ebx
  801247:	b8 0a 00 00 00       	mov    $0xa,%eax
  80124c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80124f:	8b 55 08             	mov    0x8(%ebp),%edx
  801252:	89 df                	mov    %ebx,%edi
  801254:	89 de                	mov    %ebx,%esi
  801256:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801258:	85 c0                	test   %eax,%eax
  80125a:	7e 17                	jle    801273 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80125c:	83 ec 0c             	sub    $0xc,%esp
  80125f:	50                   	push   %eax
  801260:	6a 0a                	push   $0xa
  801262:	68 df 2a 80 00       	push   $0x802adf
  801267:	6a 23                	push   $0x23
  801269:	68 fc 2a 80 00       	push   $0x802afc
  80126e:	e8 14 f4 ff ff       	call   800687 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  801273:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801276:	5b                   	pop    %ebx
  801277:	5e                   	pop    %esi
  801278:	5f                   	pop    %edi
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    

0080127b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	57                   	push   %edi
  80127f:	56                   	push   %esi
  801280:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801281:	be 00 00 00 00       	mov    $0x0,%esi
  801286:	b8 0c 00 00 00       	mov    $0xc,%eax
  80128b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80128e:	8b 55 08             	mov    0x8(%ebp),%edx
  801291:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801294:	8b 7d 14             	mov    0x14(%ebp),%edi
  801297:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801299:	5b                   	pop    %ebx
  80129a:	5e                   	pop    %esi
  80129b:	5f                   	pop    %edi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    

0080129e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80129e:	55                   	push   %ebp
  80129f:	89 e5                	mov    %esp,%ebp
  8012a1:	57                   	push   %edi
  8012a2:	56                   	push   %esi
  8012a3:	53                   	push   %ebx
  8012a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012ac:	b8 0d 00 00 00       	mov    $0xd,%eax
  8012b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8012b4:	89 cb                	mov    %ecx,%ebx
  8012b6:	89 cf                	mov    %ecx,%edi
  8012b8:	89 ce                	mov    %ecx,%esi
  8012ba:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012bc:	85 c0                	test   %eax,%eax
  8012be:	7e 17                	jle    8012d7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012c0:	83 ec 0c             	sub    $0xc,%esp
  8012c3:	50                   	push   %eax
  8012c4:	6a 0d                	push   $0xd
  8012c6:	68 df 2a 80 00       	push   $0x802adf
  8012cb:	6a 23                	push   $0x23
  8012cd:	68 fc 2a 80 00       	push   $0x802afc
  8012d2:	e8 b0 f3 ff ff       	call   800687 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012da:	5b                   	pop    %ebx
  8012db:	5e                   	pop    %esi
  8012dc:	5f                   	pop    %edi
  8012dd:	5d                   	pop    %ebp
  8012de:	c3                   	ret    

008012df <sys_gettime>:

int sys_gettime(void)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	57                   	push   %edi
  8012e3:	56                   	push   %esi
  8012e4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ea:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012ef:	89 d1                	mov    %edx,%ecx
  8012f1:	89 d3                	mov    %edx,%ebx
  8012f3:	89 d7                	mov    %edx,%edi
  8012f5:	89 d6                	mov    %edx,%esi
  8012f7:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  8012f9:	5b                   	pop    %ebx
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    

008012fe <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	56                   	push   %esi
  801302:	53                   	push   %ebx
  801303:	8b 75 08             	mov    0x8(%ebp),%esi
  801306:	8b 45 0c             	mov    0xc(%ebp),%eax
  801309:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  80130c:	85 f6                	test   %esi,%esi
  80130e:	74 06                	je     801316 <ipc_recv+0x18>
  801310:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801316:	85 db                	test   %ebx,%ebx
  801318:	74 06                	je     801320 <ipc_recv+0x22>
  80131a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801320:	83 f8 01             	cmp    $0x1,%eax
  801323:	19 d2                	sbb    %edx,%edx
  801325:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	50                   	push   %eax
  80132b:	e8 6e ff ff ff       	call   80129e <sys_ipc_recv>
  801330:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	85 d2                	test   %edx,%edx
  801337:	75 24                	jne    80135d <ipc_recv+0x5f>
	if (from_env_store)
  801339:	85 f6                	test   %esi,%esi
  80133b:	74 0a                	je     801347 <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  80133d:	a1 04 40 80 00       	mov    0x804004,%eax
  801342:	8b 40 70             	mov    0x70(%eax),%eax
  801345:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801347:	85 db                	test   %ebx,%ebx
  801349:	74 0a                	je     801355 <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  80134b:	a1 04 40 80 00       	mov    0x804004,%eax
  801350:	8b 40 74             	mov    0x74(%eax),%eax
  801353:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801355:	a1 04 40 80 00       	mov    0x804004,%eax
  80135a:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  80135d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801360:	5b                   	pop    %ebx
  801361:	5e                   	pop    %esi
  801362:	5d                   	pop    %ebp
  801363:	c3                   	ret    

00801364 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	57                   	push   %edi
  801368:	56                   	push   %esi
  801369:	53                   	push   %ebx
  80136a:	83 ec 0c             	sub    $0xc,%esp
  80136d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801370:	8b 75 0c             	mov    0xc(%ebp),%esi
  801373:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801376:	83 fb 01             	cmp    $0x1,%ebx
  801379:	19 c0                	sbb    %eax,%eax
  80137b:	09 c3                	or     %eax,%ebx
  80137d:	eb 1c                	jmp    80139b <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  80137f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801382:	74 12                	je     801396 <ipc_send+0x32>
  801384:	50                   	push   %eax
  801385:	68 0a 2b 80 00       	push   $0x802b0a
  80138a:	6a 36                	push   $0x36
  80138c:	68 21 2b 80 00       	push   $0x802b21
  801391:	e8 f1 f2 ff ff       	call   800687 <_panic>
		sys_yield();
  801396:	e8 34 fd ff ff       	call   8010cf <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  80139b:	ff 75 14             	pushl  0x14(%ebp)
  80139e:	53                   	push   %ebx
  80139f:	56                   	push   %esi
  8013a0:	57                   	push   %edi
  8013a1:	e8 d5 fe ff ff       	call   80127b <sys_ipc_try_send>
		if (ret == 0) break;
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	75 d2                	jne    80137f <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  8013ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b0:	5b                   	pop    %ebx
  8013b1:	5e                   	pop    %esi
  8013b2:	5f                   	pop    %edi
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013bb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013c0:	6b d0 78             	imul   $0x78,%eax,%edx
  8013c3:	83 c2 50             	add    $0x50,%edx
  8013c6:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  8013cc:	39 ca                	cmp    %ecx,%edx
  8013ce:	75 0d                	jne    8013dd <ipc_find_env+0x28>
			return envs[i].env_id;
  8013d0:	6b c0 78             	imul   $0x78,%eax,%eax
  8013d3:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8013d8:	8b 40 08             	mov    0x8(%eax),%eax
  8013db:	eb 0e                	jmp    8013eb <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8013dd:	83 c0 01             	add    $0x1,%eax
  8013e0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8013e5:	75 d9                	jne    8013c0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8013e7:	66 b8 00 00          	mov    $0x0,%ax
}
  8013eb:	5d                   	pop    %ebp
  8013ec:	c3                   	ret    

008013ed <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f3:	05 00 00 00 30       	add    $0x30000000,%eax
  8013f8:	c1 e8 0c             	shr    $0xc,%eax
}
  8013fb:	5d                   	pop    %ebp
  8013fc:	c3                   	ret    

008013fd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013fd:	55                   	push   %ebp
  8013fe:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801400:	8b 45 08             	mov    0x8(%ebp),%eax
  801403:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  801408:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80140d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80141a:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80141f:	89 c2                	mov    %eax,%edx
  801421:	c1 ea 16             	shr    $0x16,%edx
  801424:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80142b:	f6 c2 01             	test   $0x1,%dl
  80142e:	74 11                	je     801441 <fd_alloc+0x2d>
  801430:	89 c2                	mov    %eax,%edx
  801432:	c1 ea 0c             	shr    $0xc,%edx
  801435:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80143c:	f6 c2 01             	test   $0x1,%dl
  80143f:	75 09                	jne    80144a <fd_alloc+0x36>
			*fd_store = fd;
  801441:	89 01                	mov    %eax,(%ecx)
			return 0;
  801443:	b8 00 00 00 00       	mov    $0x0,%eax
  801448:	eb 17                	jmp    801461 <fd_alloc+0x4d>
  80144a:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  80144f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801454:	75 c9                	jne    80141f <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801456:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80145c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801461:	5d                   	pop    %ebp
  801462:	c3                   	ret    

00801463 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801469:	83 f8 1f             	cmp    $0x1f,%eax
  80146c:	77 36                	ja     8014a4 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80146e:	c1 e0 0c             	shl    $0xc,%eax
  801471:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801476:	89 c2                	mov    %eax,%edx
  801478:	c1 ea 16             	shr    $0x16,%edx
  80147b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801482:	f6 c2 01             	test   $0x1,%dl
  801485:	74 24                	je     8014ab <fd_lookup+0x48>
  801487:	89 c2                	mov    %eax,%edx
  801489:	c1 ea 0c             	shr    $0xc,%edx
  80148c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801493:	f6 c2 01             	test   $0x1,%dl
  801496:	74 1a                	je     8014b2 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801498:	8b 55 0c             	mov    0xc(%ebp),%edx
  80149b:	89 02                	mov    %eax,(%edx)
	return 0;
  80149d:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a2:	eb 13                	jmp    8014b7 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a9:	eb 0c                	jmp    8014b7 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014b0:	eb 05                	jmp    8014b7 <fd_lookup+0x54>
  8014b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8014b7:	5d                   	pop    %ebp
  8014b8:	c3                   	ret    

008014b9 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	83 ec 08             	sub    $0x8,%esp
  8014bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014c2:	ba a8 2b 80 00       	mov    $0x802ba8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014c7:	eb 13                	jmp    8014dc <dev_lookup+0x23>
  8014c9:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8014cc:	39 08                	cmp    %ecx,(%eax)
  8014ce:	75 0c                	jne    8014dc <dev_lookup+0x23>
			*dev = devtab[i];
  8014d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014d3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8014da:	eb 2e                	jmp    80150a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8014dc:	8b 02                	mov    (%edx),%eax
  8014de:	85 c0                	test   %eax,%eax
  8014e0:	75 e7                	jne    8014c9 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014e2:	a1 04 40 80 00       	mov    0x804004,%eax
  8014e7:	8b 40 48             	mov    0x48(%eax),%eax
  8014ea:	83 ec 04             	sub    $0x4,%esp
  8014ed:	51                   	push   %ecx
  8014ee:	50                   	push   %eax
  8014ef:	68 2c 2b 80 00       	push   $0x802b2c
  8014f4:	e8 67 f2 ff ff       	call   800760 <cprintf>
	*dev = 0;
  8014f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014fc:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80150a:	c9                   	leave  
  80150b:	c3                   	ret    

0080150c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	56                   	push   %esi
  801510:	53                   	push   %ebx
  801511:	83 ec 10             	sub    $0x10,%esp
  801514:	8b 75 08             	mov    0x8(%ebp),%esi
  801517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80151a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151d:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80151e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801524:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801527:	50                   	push   %eax
  801528:	e8 36 ff ff ff       	call   801463 <fd_lookup>
  80152d:	83 c4 08             	add    $0x8,%esp
  801530:	85 c0                	test   %eax,%eax
  801532:	78 05                	js     801539 <fd_close+0x2d>
	    || fd != fd2)
  801534:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801537:	74 0b                	je     801544 <fd_close+0x38>
		return (must_exist ? r : 0);
  801539:	80 fb 01             	cmp    $0x1,%bl
  80153c:	19 d2                	sbb    %edx,%edx
  80153e:	f7 d2                	not    %edx
  801540:	21 d0                	and    %edx,%eax
  801542:	eb 41                	jmp    801585 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154a:	50                   	push   %eax
  80154b:	ff 36                	pushl  (%esi)
  80154d:	e8 67 ff ff ff       	call   8014b9 <dev_lookup>
  801552:	89 c3                	mov    %eax,%ebx
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	78 1a                	js     801575 <fd_close+0x69>
		if (dev->dev_close)
  80155b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155e:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801561:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801566:	85 c0                	test   %eax,%eax
  801568:	74 0b                	je     801575 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80156a:	83 ec 0c             	sub    $0xc,%esp
  80156d:	56                   	push   %esi
  80156e:	ff d0                	call   *%eax
  801570:	89 c3                	mov    %eax,%ebx
  801572:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	56                   	push   %esi
  801579:	6a 00                	push   $0x0
  80157b:	e8 f3 fb ff ff       	call   801173 <sys_page_unmap>
	return r;
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	89 d8                	mov    %ebx,%eax
}
  801585:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801588:	5b                   	pop    %ebx
  801589:	5e                   	pop    %esi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    

0080158c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	ff 75 08             	pushl  0x8(%ebp)
  801599:	e8 c5 fe ff ff       	call   801463 <fd_lookup>
  80159e:	89 c2                	mov    %eax,%edx
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	85 d2                	test   %edx,%edx
  8015a5:	78 10                	js     8015b7 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	6a 01                	push   $0x1
  8015ac:	ff 75 f4             	pushl  -0xc(%ebp)
  8015af:	e8 58 ff ff ff       	call   80150c <fd_close>
  8015b4:	83 c4 10             	add    $0x10,%esp
}
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <close_all>:

void
close_all(void)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	53                   	push   %ebx
  8015bd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8015c5:	83 ec 0c             	sub    $0xc,%esp
  8015c8:	53                   	push   %ebx
  8015c9:	e8 be ff ff ff       	call   80158c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015ce:	83 c3 01             	add    $0x1,%ebx
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	83 fb 20             	cmp    $0x20,%ebx
  8015d7:	75 ec                	jne    8015c5 <close_all+0xc>
		close(i);
}
  8015d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dc:	c9                   	leave  
  8015dd:	c3                   	ret    

008015de <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	57                   	push   %edi
  8015e2:	56                   	push   %esi
  8015e3:	53                   	push   %ebx
  8015e4:	83 ec 2c             	sub    $0x2c,%esp
  8015e7:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	ff 75 08             	pushl  0x8(%ebp)
  8015f1:	e8 6d fe ff ff       	call   801463 <fd_lookup>
  8015f6:	89 c2                	mov    %eax,%edx
  8015f8:	83 c4 08             	add    $0x8,%esp
  8015fb:	85 d2                	test   %edx,%edx
  8015fd:	0f 88 c1 00 00 00    	js     8016c4 <dup+0xe6>
		return r;
	close(newfdnum);
  801603:	83 ec 0c             	sub    $0xc,%esp
  801606:	56                   	push   %esi
  801607:	e8 80 ff ff ff       	call   80158c <close>

	newfd = INDEX2FD(newfdnum);
  80160c:	89 f3                	mov    %esi,%ebx
  80160e:	c1 e3 0c             	shl    $0xc,%ebx
  801611:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801617:	83 c4 04             	add    $0x4,%esp
  80161a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161d:	e8 db fd ff ff       	call   8013fd <fd2data>
  801622:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801624:	89 1c 24             	mov    %ebx,(%esp)
  801627:	e8 d1 fd ff ff       	call   8013fd <fd2data>
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801632:	89 f8                	mov    %edi,%eax
  801634:	c1 e8 16             	shr    $0x16,%eax
  801637:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80163e:	a8 01                	test   $0x1,%al
  801640:	74 37                	je     801679 <dup+0x9b>
  801642:	89 f8                	mov    %edi,%eax
  801644:	c1 e8 0c             	shr    $0xc,%eax
  801647:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80164e:	f6 c2 01             	test   $0x1,%dl
  801651:	74 26                	je     801679 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801653:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80165a:	83 ec 0c             	sub    $0xc,%esp
  80165d:	25 07 0e 00 00       	and    $0xe07,%eax
  801662:	50                   	push   %eax
  801663:	ff 75 d4             	pushl  -0x2c(%ebp)
  801666:	6a 00                	push   $0x0
  801668:	57                   	push   %edi
  801669:	6a 00                	push   $0x0
  80166b:	e8 c1 fa ff ff       	call   801131 <sys_page_map>
  801670:	89 c7                	mov    %eax,%edi
  801672:	83 c4 20             	add    $0x20,%esp
  801675:	85 c0                	test   %eax,%eax
  801677:	78 2e                	js     8016a7 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801679:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80167c:	89 d0                	mov    %edx,%eax
  80167e:	c1 e8 0c             	shr    $0xc,%eax
  801681:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801688:	83 ec 0c             	sub    $0xc,%esp
  80168b:	25 07 0e 00 00       	and    $0xe07,%eax
  801690:	50                   	push   %eax
  801691:	53                   	push   %ebx
  801692:	6a 00                	push   $0x0
  801694:	52                   	push   %edx
  801695:	6a 00                	push   $0x0
  801697:	e8 95 fa ff ff       	call   801131 <sys_page_map>
  80169c:	89 c7                	mov    %eax,%edi
  80169e:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8016a1:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016a3:	85 ff                	test   %edi,%edi
  8016a5:	79 1d                	jns    8016c4 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	53                   	push   %ebx
  8016ab:	6a 00                	push   $0x0
  8016ad:	e8 c1 fa ff ff       	call   801173 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016b2:	83 c4 08             	add    $0x8,%esp
  8016b5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8016b8:	6a 00                	push   $0x0
  8016ba:	e8 b4 fa ff ff       	call   801173 <sys_page_unmap>
	return r;
  8016bf:	83 c4 10             	add    $0x10,%esp
  8016c2:	89 f8                	mov    %edi,%eax
}
  8016c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c7:	5b                   	pop    %ebx
  8016c8:	5e                   	pop    %esi
  8016c9:	5f                   	pop    %edi
  8016ca:	5d                   	pop    %ebp
  8016cb:	c3                   	ret    

008016cc <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 14             	sub    $0x14,%esp
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d9:	50                   	push   %eax
  8016da:	53                   	push   %ebx
  8016db:	e8 83 fd ff ff       	call   801463 <fd_lookup>
  8016e0:	83 c4 08             	add    $0x8,%esp
  8016e3:	89 c2                	mov    %eax,%edx
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 6d                	js     801756 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016e9:	83 ec 08             	sub    $0x8,%esp
  8016ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ef:	50                   	push   %eax
  8016f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016f3:	ff 30                	pushl  (%eax)
  8016f5:	e8 bf fd ff ff       	call   8014b9 <dev_lookup>
  8016fa:	83 c4 10             	add    $0x10,%esp
  8016fd:	85 c0                	test   %eax,%eax
  8016ff:	78 4c                	js     80174d <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801701:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801704:	8b 42 08             	mov    0x8(%edx),%eax
  801707:	83 e0 03             	and    $0x3,%eax
  80170a:	83 f8 01             	cmp    $0x1,%eax
  80170d:	75 21                	jne    801730 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80170f:	a1 04 40 80 00       	mov    0x804004,%eax
  801714:	8b 40 48             	mov    0x48(%eax),%eax
  801717:	83 ec 04             	sub    $0x4,%esp
  80171a:	53                   	push   %ebx
  80171b:	50                   	push   %eax
  80171c:	68 6d 2b 80 00       	push   $0x802b6d
  801721:	e8 3a f0 ff ff       	call   800760 <cprintf>
		return -E_INVAL;
  801726:	83 c4 10             	add    $0x10,%esp
  801729:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80172e:	eb 26                	jmp    801756 <read+0x8a>
	}
	if (!dev->dev_read)
  801730:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801733:	8b 40 08             	mov    0x8(%eax),%eax
  801736:	85 c0                	test   %eax,%eax
  801738:	74 17                	je     801751 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80173a:	83 ec 04             	sub    $0x4,%esp
  80173d:	ff 75 10             	pushl  0x10(%ebp)
  801740:	ff 75 0c             	pushl  0xc(%ebp)
  801743:	52                   	push   %edx
  801744:	ff d0                	call   *%eax
  801746:	89 c2                	mov    %eax,%edx
  801748:	83 c4 10             	add    $0x10,%esp
  80174b:	eb 09                	jmp    801756 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	eb 05                	jmp    801756 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801751:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801756:	89 d0                	mov    %edx,%eax
  801758:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80175d:	55                   	push   %ebp
  80175e:	89 e5                	mov    %esp,%ebp
  801760:	57                   	push   %edi
  801761:	56                   	push   %esi
  801762:	53                   	push   %ebx
  801763:	83 ec 0c             	sub    $0xc,%esp
  801766:	8b 7d 08             	mov    0x8(%ebp),%edi
  801769:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80176c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801771:	eb 21                	jmp    801794 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801773:	83 ec 04             	sub    $0x4,%esp
  801776:	89 f0                	mov    %esi,%eax
  801778:	29 d8                	sub    %ebx,%eax
  80177a:	50                   	push   %eax
  80177b:	89 d8                	mov    %ebx,%eax
  80177d:	03 45 0c             	add    0xc(%ebp),%eax
  801780:	50                   	push   %eax
  801781:	57                   	push   %edi
  801782:	e8 45 ff ff ff       	call   8016cc <read>
		if (m < 0)
  801787:	83 c4 10             	add    $0x10,%esp
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 0c                	js     80179a <readn+0x3d>
			return m;
		if (m == 0)
  80178e:	85 c0                	test   %eax,%eax
  801790:	74 06                	je     801798 <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801792:	01 c3                	add    %eax,%ebx
  801794:	39 f3                	cmp    %esi,%ebx
  801796:	72 db                	jb     801773 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  801798:	89 d8                	mov    %ebx,%eax
}
  80179a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5f                   	pop    %edi
  8017a0:	5d                   	pop    %ebp
  8017a1:	c3                   	ret    

008017a2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017a2:	55                   	push   %ebp
  8017a3:	89 e5                	mov    %esp,%ebp
  8017a5:	53                   	push   %ebx
  8017a6:	83 ec 14             	sub    $0x14,%esp
  8017a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017af:	50                   	push   %eax
  8017b0:	53                   	push   %ebx
  8017b1:	e8 ad fc ff ff       	call   801463 <fd_lookup>
  8017b6:	83 c4 08             	add    $0x8,%esp
  8017b9:	89 c2                	mov    %eax,%edx
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 68                	js     801827 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017bf:	83 ec 08             	sub    $0x8,%esp
  8017c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c5:	50                   	push   %eax
  8017c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017c9:	ff 30                	pushl  (%eax)
  8017cb:	e8 e9 fc ff ff       	call   8014b9 <dev_lookup>
  8017d0:	83 c4 10             	add    $0x10,%esp
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 47                	js     80181e <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017da:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017de:	75 21                	jne    801801 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017e0:	a1 04 40 80 00       	mov    0x804004,%eax
  8017e5:	8b 40 48             	mov    0x48(%eax),%eax
  8017e8:	83 ec 04             	sub    $0x4,%esp
  8017eb:	53                   	push   %ebx
  8017ec:	50                   	push   %eax
  8017ed:	68 89 2b 80 00       	push   $0x802b89
  8017f2:	e8 69 ef ff ff       	call   800760 <cprintf>
		return -E_INVAL;
  8017f7:	83 c4 10             	add    $0x10,%esp
  8017fa:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017ff:	eb 26                	jmp    801827 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801801:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801804:	8b 52 0c             	mov    0xc(%edx),%edx
  801807:	85 d2                	test   %edx,%edx
  801809:	74 17                	je     801822 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80180b:	83 ec 04             	sub    $0x4,%esp
  80180e:	ff 75 10             	pushl  0x10(%ebp)
  801811:	ff 75 0c             	pushl  0xc(%ebp)
  801814:	50                   	push   %eax
  801815:	ff d2                	call   *%edx
  801817:	89 c2                	mov    %eax,%edx
  801819:	83 c4 10             	add    $0x10,%esp
  80181c:	eb 09                	jmp    801827 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181e:	89 c2                	mov    %eax,%edx
  801820:	eb 05                	jmp    801827 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801822:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801827:	89 d0                	mov    %edx,%eax
  801829:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <seek>:

int
seek(int fdnum, off_t offset)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801834:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801837:	50                   	push   %eax
  801838:	ff 75 08             	pushl  0x8(%ebp)
  80183b:	e8 23 fc ff ff       	call   801463 <fd_lookup>
  801840:	83 c4 08             	add    $0x8,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	78 0e                	js     801855 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801847:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80184a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80184d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801850:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801855:	c9                   	leave  
  801856:	c3                   	ret    

00801857 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801857:	55                   	push   %ebp
  801858:	89 e5                	mov    %esp,%ebp
  80185a:	53                   	push   %ebx
  80185b:	83 ec 14             	sub    $0x14,%esp
  80185e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801861:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801864:	50                   	push   %eax
  801865:	53                   	push   %ebx
  801866:	e8 f8 fb ff ff       	call   801463 <fd_lookup>
  80186b:	83 c4 08             	add    $0x8,%esp
  80186e:	89 c2                	mov    %eax,%edx
  801870:	85 c0                	test   %eax,%eax
  801872:	78 65                	js     8018d9 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801874:	83 ec 08             	sub    $0x8,%esp
  801877:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80187a:	50                   	push   %eax
  80187b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187e:	ff 30                	pushl  (%eax)
  801880:	e8 34 fc ff ff       	call   8014b9 <dev_lookup>
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	85 c0                	test   %eax,%eax
  80188a:	78 44                	js     8018d0 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80188c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80188f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801893:	75 21                	jne    8018b6 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801895:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80189a:	8b 40 48             	mov    0x48(%eax),%eax
  80189d:	83 ec 04             	sub    $0x4,%esp
  8018a0:	53                   	push   %ebx
  8018a1:	50                   	push   %eax
  8018a2:	68 4c 2b 80 00       	push   $0x802b4c
  8018a7:	e8 b4 ee ff ff       	call   800760 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018b4:	eb 23                	jmp    8018d9 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8018b6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b9:	8b 52 18             	mov    0x18(%edx),%edx
  8018bc:	85 d2                	test   %edx,%edx
  8018be:	74 14                	je     8018d4 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018c0:	83 ec 08             	sub    $0x8,%esp
  8018c3:	ff 75 0c             	pushl  0xc(%ebp)
  8018c6:	50                   	push   %eax
  8018c7:	ff d2                	call   *%edx
  8018c9:	89 c2                	mov    %eax,%edx
  8018cb:	83 c4 10             	add    $0x10,%esp
  8018ce:	eb 09                	jmp    8018d9 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018d0:	89 c2                	mov    %eax,%edx
  8018d2:	eb 05                	jmp    8018d9 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8018d4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8018d9:	89 d0                	mov    %edx,%eax
  8018db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018de:	c9                   	leave  
  8018df:	c3                   	ret    

008018e0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	53                   	push   %ebx
  8018e4:	83 ec 14             	sub    $0x14,%esp
  8018e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018ea:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018ed:	50                   	push   %eax
  8018ee:	ff 75 08             	pushl  0x8(%ebp)
  8018f1:	e8 6d fb ff ff       	call   801463 <fd_lookup>
  8018f6:	83 c4 08             	add    $0x8,%esp
  8018f9:	89 c2                	mov    %eax,%edx
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 58                	js     801957 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018ff:	83 ec 08             	sub    $0x8,%esp
  801902:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801905:	50                   	push   %eax
  801906:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801909:	ff 30                	pushl  (%eax)
  80190b:	e8 a9 fb ff ff       	call   8014b9 <dev_lookup>
  801910:	83 c4 10             	add    $0x10,%esp
  801913:	85 c0                	test   %eax,%eax
  801915:	78 37                	js     80194e <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801917:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80191a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80191e:	74 32                	je     801952 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801920:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801923:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80192a:	00 00 00 
	stat->st_isdir = 0;
  80192d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801934:	00 00 00 
	stat->st_dev = dev;
  801937:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80193d:	83 ec 08             	sub    $0x8,%esp
  801940:	53                   	push   %ebx
  801941:	ff 75 f0             	pushl  -0x10(%ebp)
  801944:	ff 50 14             	call   *0x14(%eax)
  801947:	89 c2                	mov    %eax,%edx
  801949:	83 c4 10             	add    $0x10,%esp
  80194c:	eb 09                	jmp    801957 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194e:	89 c2                	mov    %eax,%edx
  801950:	eb 05                	jmp    801957 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801952:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801957:	89 d0                	mov    %edx,%eax
  801959:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195c:	c9                   	leave  
  80195d:	c3                   	ret    

0080195e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	56                   	push   %esi
  801962:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801963:	83 ec 08             	sub    $0x8,%esp
  801966:	6a 00                	push   $0x0
  801968:	ff 75 08             	pushl  0x8(%ebp)
  80196b:	e8 e7 01 00 00       	call   801b57 <open>
  801970:	89 c3                	mov    %eax,%ebx
  801972:	83 c4 10             	add    $0x10,%esp
  801975:	85 db                	test   %ebx,%ebx
  801977:	78 1b                	js     801994 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801979:	83 ec 08             	sub    $0x8,%esp
  80197c:	ff 75 0c             	pushl  0xc(%ebp)
  80197f:	53                   	push   %ebx
  801980:	e8 5b ff ff ff       	call   8018e0 <fstat>
  801985:	89 c6                	mov    %eax,%esi
	close(fd);
  801987:	89 1c 24             	mov    %ebx,(%esp)
  80198a:	e8 fd fb ff ff       	call   80158c <close>
	return r;
  80198f:	83 c4 10             	add    $0x10,%esp
  801992:	89 f0                	mov    %esi,%eax
}
  801994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801997:	5b                   	pop    %ebx
  801998:	5e                   	pop    %esi
  801999:	5d                   	pop    %ebp
  80199a:	c3                   	ret    

0080199b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80199b:	55                   	push   %ebp
  80199c:	89 e5                	mov    %esp,%ebp
  80199e:	56                   	push   %esi
  80199f:	53                   	push   %ebx
  8019a0:	89 c6                	mov    %eax,%esi
  8019a2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019a4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019ab:	75 12                	jne    8019bf <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	6a 03                	push   $0x3
  8019b2:	e8 fe f9 ff ff       	call   8013b5 <ipc_find_env>
  8019b7:	a3 00 40 80 00       	mov    %eax,0x804000
  8019bc:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019bf:	6a 07                	push   $0x7
  8019c1:	68 00 50 80 00       	push   $0x805000
  8019c6:	56                   	push   %esi
  8019c7:	ff 35 00 40 80 00    	pushl  0x804000
  8019cd:	e8 92 f9 ff ff       	call   801364 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019d2:	83 c4 0c             	add    $0xc,%esp
  8019d5:	6a 00                	push   $0x0
  8019d7:	53                   	push   %ebx
  8019d8:	6a 00                	push   $0x0
  8019da:	e8 1f f9 ff ff       	call   8012fe <ipc_recv>
}
  8019df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e2:	5b                   	pop    %ebx
  8019e3:	5e                   	pop    %esi
  8019e4:	5d                   	pop    %ebp
  8019e5:	c3                   	ret    

008019e6 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801a04:	b8 02 00 00 00       	mov    $0x2,%eax
  801a09:	e8 8d ff ff ff       	call   80199b <fsipc>
}
  801a0e:	c9                   	leave  
  801a0f:	c3                   	ret    

00801a10 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a16:	8b 45 08             	mov    0x8(%ebp),%eax
  801a19:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a21:	ba 00 00 00 00       	mov    $0x0,%edx
  801a26:	b8 06 00 00 00       	mov    $0x6,%eax
  801a2b:	e8 6b ff ff ff       	call   80199b <fsipc>
}
  801a30:	c9                   	leave  
  801a31:	c3                   	ret    

00801a32 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	53                   	push   %ebx
  801a36:	83 ec 04             	sub    $0x4,%esp
  801a39:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a3c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3f:	8b 40 0c             	mov    0xc(%eax),%eax
  801a42:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a47:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a51:	e8 45 ff ff ff       	call   80199b <fsipc>
  801a56:	89 c2                	mov    %eax,%edx
  801a58:	85 d2                	test   %edx,%edx
  801a5a:	78 2c                	js     801a88 <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a5c:	83 ec 08             	sub    $0x8,%esp
  801a5f:	68 00 50 80 00       	push   $0x805000
  801a64:	53                   	push   %ebx
  801a65:	e8 7a f2 ff ff       	call   800ce4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a6a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a6f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a75:	a1 84 50 80 00       	mov    0x805084,%eax
  801a7a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a80:	83 c4 10             	add    $0x10,%esp
  801a83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	83 ec 08             	sub    $0x8,%esp
  801a93:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  801a96:	8b 55 08             	mov    0x8(%ebp),%edx
  801a99:	8b 52 0c             	mov    0xc(%edx),%edx
  801a9c:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  801aa2:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  801aa7:	76 05                	jbe    801aae <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  801aa9:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  801aae:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  801ab3:	83 ec 04             	sub    $0x4,%esp
  801ab6:	50                   	push   %eax
  801ab7:	ff 75 0c             	pushl  0xc(%ebp)
  801aba:	68 08 50 80 00       	push   $0x805008
  801abf:	e8 b2 f3 ff ff       	call   800e76 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  801ac4:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac9:	b8 04 00 00 00       	mov    $0x4,%eax
  801ace:	e8 c8 fe ff ff       	call   80199b <fsipc>
	return write;
}
  801ad3:	c9                   	leave  
  801ad4:	c3                   	ret    

00801ad5 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	56                   	push   %esi
  801ad9:	53                   	push   %ebx
  801ada:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801add:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae0:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ae8:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aee:	ba 00 00 00 00       	mov    $0x0,%edx
  801af3:	b8 03 00 00 00       	mov    $0x3,%eax
  801af8:	e8 9e fe ff ff       	call   80199b <fsipc>
  801afd:	89 c3                	mov    %eax,%ebx
  801aff:	85 c0                	test   %eax,%eax
  801b01:	78 4b                	js     801b4e <devfile_read+0x79>
		return r;
	assert(r <= n);
  801b03:	39 c6                	cmp    %eax,%esi
  801b05:	73 16                	jae    801b1d <devfile_read+0x48>
  801b07:	68 b8 2b 80 00       	push   $0x802bb8
  801b0c:	68 bf 2b 80 00       	push   $0x802bbf
  801b11:	6a 7c                	push   $0x7c
  801b13:	68 d4 2b 80 00       	push   $0x802bd4
  801b18:	e8 6a eb ff ff       	call   800687 <_panic>
	assert(r <= PGSIZE);
  801b1d:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b22:	7e 16                	jle    801b3a <devfile_read+0x65>
  801b24:	68 df 2b 80 00       	push   $0x802bdf
  801b29:	68 bf 2b 80 00       	push   $0x802bbf
  801b2e:	6a 7d                	push   $0x7d
  801b30:	68 d4 2b 80 00       	push   $0x802bd4
  801b35:	e8 4d eb ff ff       	call   800687 <_panic>
	memmove(buf, &fsipcbuf, r);
  801b3a:	83 ec 04             	sub    $0x4,%esp
  801b3d:	50                   	push   %eax
  801b3e:	68 00 50 80 00       	push   $0x805000
  801b43:	ff 75 0c             	pushl  0xc(%ebp)
  801b46:	e8 2b f3 ff ff       	call   800e76 <memmove>
	return r;
  801b4b:	83 c4 10             	add    $0x10,%esp
}
  801b4e:	89 d8                	mov    %ebx,%eax
  801b50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b53:	5b                   	pop    %ebx
  801b54:	5e                   	pop    %esi
  801b55:	5d                   	pop    %ebp
  801b56:	c3                   	ret    

00801b57 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801b57:	55                   	push   %ebp
  801b58:	89 e5                	mov    %esp,%ebp
  801b5a:	53                   	push   %ebx
  801b5b:	83 ec 20             	sub    $0x20,%esp
  801b5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801b61:	53                   	push   %ebx
  801b62:	e8 44 f1 ff ff       	call   800cab <strlen>
  801b67:	83 c4 10             	add    $0x10,%esp
  801b6a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b6f:	7f 67                	jg     801bd8 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b71:	83 ec 0c             	sub    $0xc,%esp
  801b74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b77:	50                   	push   %eax
  801b78:	e8 97 f8 ff ff       	call   801414 <fd_alloc>
  801b7d:	83 c4 10             	add    $0x10,%esp
		return r;
  801b80:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 57                	js     801bdd <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b86:	83 ec 08             	sub    $0x8,%esp
  801b89:	53                   	push   %ebx
  801b8a:	68 00 50 80 00       	push   $0x805000
  801b8f:	e8 50 f1 ff ff       	call   800ce4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b97:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b9f:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba4:	e8 f2 fd ff ff       	call   80199b <fsipc>
  801ba9:	89 c3                	mov    %eax,%ebx
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	79 14                	jns    801bc6 <open+0x6f>
		fd_close(fd, 0);
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	6a 00                	push   $0x0
  801bb7:	ff 75 f4             	pushl  -0xc(%ebp)
  801bba:	e8 4d f9 ff ff       	call   80150c <fd_close>
		return r;
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	89 da                	mov    %ebx,%edx
  801bc4:	eb 17                	jmp    801bdd <open+0x86>
	}

	return fd2num(fd);
  801bc6:	83 ec 0c             	sub    $0xc,%esp
  801bc9:	ff 75 f4             	pushl  -0xc(%ebp)
  801bcc:	e8 1c f8 ff ff       	call   8013ed <fd2num>
  801bd1:	89 c2                	mov    %eax,%edx
  801bd3:	83 c4 10             	add    $0x10,%esp
  801bd6:	eb 05                	jmp    801bdd <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801bd8:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801bdd:	89 d0                	mov    %edx,%eax
  801bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be2:	c9                   	leave  
  801be3:	c3                   	ret    

00801be4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bea:	ba 00 00 00 00       	mov    $0x0,%edx
  801bef:	b8 08 00 00 00       	mov    $0x8,%eax
  801bf4:	e8 a2 fd ff ff       	call   80199b <fsipc>
}
  801bf9:	c9                   	leave  
  801bfa:	c3                   	ret    

00801bfb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	56                   	push   %esi
  801bff:	53                   	push   %ebx
  801c00:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c03:	83 ec 0c             	sub    $0xc,%esp
  801c06:	ff 75 08             	pushl  0x8(%ebp)
  801c09:	e8 ef f7 ff ff       	call   8013fd <fd2data>
  801c0e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c10:	83 c4 08             	add    $0x8,%esp
  801c13:	68 eb 2b 80 00       	push   $0x802beb
  801c18:	53                   	push   %ebx
  801c19:	e8 c6 f0 ff ff       	call   800ce4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c1e:	8b 56 04             	mov    0x4(%esi),%edx
  801c21:	89 d0                	mov    %edx,%eax
  801c23:	2b 06                	sub    (%esi),%eax
  801c25:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c2b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c32:	00 00 00 
	stat->st_dev = &devpipe;
  801c35:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801c3c:	30 80 00 
	return 0;
}
  801c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801c44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c47:	5b                   	pop    %ebx
  801c48:	5e                   	pop    %esi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    

00801c4b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c4b:	55                   	push   %ebp
  801c4c:	89 e5                	mov    %esp,%ebp
  801c4e:	53                   	push   %ebx
  801c4f:	83 ec 0c             	sub    $0xc,%esp
  801c52:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c55:	53                   	push   %ebx
  801c56:	6a 00                	push   $0x0
  801c58:	e8 16 f5 ff ff       	call   801173 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c5d:	89 1c 24             	mov    %ebx,(%esp)
  801c60:	e8 98 f7 ff ff       	call   8013fd <fd2data>
  801c65:	83 c4 08             	add    $0x8,%esp
  801c68:	50                   	push   %eax
  801c69:	6a 00                	push   $0x0
  801c6b:	e8 03 f5 ff ff       	call   801173 <sys_page_unmap>
}
  801c70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c73:	c9                   	leave  
  801c74:	c3                   	ret    

00801c75 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801c75:	55                   	push   %ebp
  801c76:	89 e5                	mov    %esp,%ebp
  801c78:	57                   	push   %edi
  801c79:	56                   	push   %esi
  801c7a:	53                   	push   %ebx
  801c7b:	83 ec 1c             	sub    $0x1c,%esp
  801c7e:	89 c7                	mov    %eax,%edi
  801c80:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801c82:	a1 04 40 80 00       	mov    0x804004,%eax
  801c87:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c8a:	83 ec 0c             	sub    $0xc,%esp
  801c8d:	57                   	push   %edi
  801c8e:	e8 3f 04 00 00       	call   8020d2 <pageref>
  801c93:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c96:	89 34 24             	mov    %esi,(%esp)
  801c99:	e8 34 04 00 00       	call   8020d2 <pageref>
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ca4:	0f 94 c0             	sete   %al
  801ca7:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801caa:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cb0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cb3:	39 cb                	cmp    %ecx,%ebx
  801cb5:	74 15                	je     801ccc <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801cb7:	8b 52 58             	mov    0x58(%edx),%edx
  801cba:	50                   	push   %eax
  801cbb:	52                   	push   %edx
  801cbc:	53                   	push   %ebx
  801cbd:	68 f8 2b 80 00       	push   $0x802bf8
  801cc2:	e8 99 ea ff ff       	call   800760 <cprintf>
  801cc7:	83 c4 10             	add    $0x10,%esp
  801cca:	eb b6                	jmp    801c82 <_pipeisclosed+0xd>
	}
}
  801ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	57                   	push   %edi
  801cd8:	56                   	push   %esi
  801cd9:	53                   	push   %ebx
  801cda:	83 ec 28             	sub    $0x28,%esp
  801cdd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ce0:	56                   	push   %esi
  801ce1:	e8 17 f7 ff ff       	call   8013fd <fd2data>
  801ce6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ce8:	83 c4 10             	add    $0x10,%esp
  801ceb:	bf 00 00 00 00       	mov    $0x0,%edi
  801cf0:	eb 4b                	jmp    801d3d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801cf2:	89 da                	mov    %ebx,%edx
  801cf4:	89 f0                	mov    %esi,%eax
  801cf6:	e8 7a ff ff ff       	call   801c75 <_pipeisclosed>
  801cfb:	85 c0                	test   %eax,%eax
  801cfd:	75 48                	jne    801d47 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801cff:	e8 cb f3 ff ff       	call   8010cf <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d04:	8b 43 04             	mov    0x4(%ebx),%eax
  801d07:	8b 0b                	mov    (%ebx),%ecx
  801d09:	8d 51 20             	lea    0x20(%ecx),%edx
  801d0c:	39 d0                	cmp    %edx,%eax
  801d0e:	73 e2                	jae    801cf2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d13:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d17:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d1a:	89 c2                	mov    %eax,%edx
  801d1c:	c1 fa 1f             	sar    $0x1f,%edx
  801d1f:	89 d1                	mov    %edx,%ecx
  801d21:	c1 e9 1b             	shr    $0x1b,%ecx
  801d24:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d27:	83 e2 1f             	and    $0x1f,%edx
  801d2a:	29 ca                	sub    %ecx,%edx
  801d2c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d30:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d34:	83 c0 01             	add    $0x1,%eax
  801d37:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d3a:	83 c7 01             	add    $0x1,%edi
  801d3d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d40:	75 c2                	jne    801d04 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801d42:	8b 45 10             	mov    0x10(%ebp),%eax
  801d45:	eb 05                	jmp    801d4c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801d47:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d4f:	5b                   	pop    %ebx
  801d50:	5e                   	pop    %esi
  801d51:	5f                   	pop    %edi
  801d52:	5d                   	pop    %ebp
  801d53:	c3                   	ret    

00801d54 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	57                   	push   %edi
  801d58:	56                   	push   %esi
  801d59:	53                   	push   %ebx
  801d5a:	83 ec 18             	sub    $0x18,%esp
  801d5d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801d60:	57                   	push   %edi
  801d61:	e8 97 f6 ff ff       	call   8013fd <fd2data>
  801d66:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801d68:	83 c4 10             	add    $0x10,%esp
  801d6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d70:	eb 3d                	jmp    801daf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801d72:	85 db                	test   %ebx,%ebx
  801d74:	74 04                	je     801d7a <devpipe_read+0x26>
				return i;
  801d76:	89 d8                	mov    %ebx,%eax
  801d78:	eb 44                	jmp    801dbe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801d7a:	89 f2                	mov    %esi,%edx
  801d7c:	89 f8                	mov    %edi,%eax
  801d7e:	e8 f2 fe ff ff       	call   801c75 <_pipeisclosed>
  801d83:	85 c0                	test   %eax,%eax
  801d85:	75 32                	jne    801db9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801d87:	e8 43 f3 ff ff       	call   8010cf <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801d8c:	8b 06                	mov    (%esi),%eax
  801d8e:	3b 46 04             	cmp    0x4(%esi),%eax
  801d91:	74 df                	je     801d72 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d93:	99                   	cltd   
  801d94:	c1 ea 1b             	shr    $0x1b,%edx
  801d97:	01 d0                	add    %edx,%eax
  801d99:	83 e0 1f             	and    $0x1f,%eax
  801d9c:	29 d0                	sub    %edx,%eax
  801d9e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801da3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801da6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801da9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801dac:	83 c3 01             	add    $0x1,%ebx
  801daf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801db2:	75 d8                	jne    801d8c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801db4:	8b 45 10             	mov    0x10(%ebp),%eax
  801db7:	eb 05                	jmp    801dbe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801db9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc1:	5b                   	pop    %ebx
  801dc2:	5e                   	pop    %esi
  801dc3:	5f                   	pop    %edi
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    

00801dc6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	56                   	push   %esi
  801dca:	53                   	push   %ebx
  801dcb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801dce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd1:	50                   	push   %eax
  801dd2:	e8 3d f6 ff ff       	call   801414 <fd_alloc>
  801dd7:	83 c4 10             	add    $0x10,%esp
  801dda:	89 c2                	mov    %eax,%edx
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	0f 88 2c 01 00 00    	js     801f10 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de4:	83 ec 04             	sub    $0x4,%esp
  801de7:	68 07 04 00 00       	push   $0x407
  801dec:	ff 75 f4             	pushl  -0xc(%ebp)
  801def:	6a 00                	push   $0x0
  801df1:	e8 f8 f2 ff ff       	call   8010ee <sys_page_alloc>
  801df6:	83 c4 10             	add    $0x10,%esp
  801df9:	89 c2                	mov    %eax,%edx
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	0f 88 0d 01 00 00    	js     801f10 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801e03:	83 ec 0c             	sub    $0xc,%esp
  801e06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e09:	50                   	push   %eax
  801e0a:	e8 05 f6 ff ff       	call   801414 <fd_alloc>
  801e0f:	89 c3                	mov    %eax,%ebx
  801e11:	83 c4 10             	add    $0x10,%esp
  801e14:	85 c0                	test   %eax,%eax
  801e16:	0f 88 e2 00 00 00    	js     801efe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e1c:	83 ec 04             	sub    $0x4,%esp
  801e1f:	68 07 04 00 00       	push   $0x407
  801e24:	ff 75 f0             	pushl  -0x10(%ebp)
  801e27:	6a 00                	push   $0x0
  801e29:	e8 c0 f2 ff ff       	call   8010ee <sys_page_alloc>
  801e2e:	89 c3                	mov    %eax,%ebx
  801e30:	83 c4 10             	add    $0x10,%esp
  801e33:	85 c0                	test   %eax,%eax
  801e35:	0f 88 c3 00 00 00    	js     801efe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801e3b:	83 ec 0c             	sub    $0xc,%esp
  801e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801e41:	e8 b7 f5 ff ff       	call   8013fd <fd2data>
  801e46:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e48:	83 c4 0c             	add    $0xc,%esp
  801e4b:	68 07 04 00 00       	push   $0x407
  801e50:	50                   	push   %eax
  801e51:	6a 00                	push   $0x0
  801e53:	e8 96 f2 ff ff       	call   8010ee <sys_page_alloc>
  801e58:	89 c3                	mov    %eax,%ebx
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	85 c0                	test   %eax,%eax
  801e5f:	0f 88 89 00 00 00    	js     801eee <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	ff 75 f0             	pushl  -0x10(%ebp)
  801e6b:	e8 8d f5 ff ff       	call   8013fd <fd2data>
  801e70:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e77:	50                   	push   %eax
  801e78:	6a 00                	push   $0x0
  801e7a:	56                   	push   %esi
  801e7b:	6a 00                	push   $0x0
  801e7d:	e8 af f2 ff ff       	call   801131 <sys_page_map>
  801e82:	89 c3                	mov    %eax,%ebx
  801e84:	83 c4 20             	add    $0x20,%esp
  801e87:	85 c0                	test   %eax,%eax
  801e89:	78 55                	js     801ee0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801e8b:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801e91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e94:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801e96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ea0:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801ea6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801eab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801eae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801eb5:	83 ec 0c             	sub    $0xc,%esp
  801eb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801ebb:	e8 2d f5 ff ff       	call   8013ed <fd2num>
  801ec0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ec3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ec5:	83 c4 04             	add    $0x4,%esp
  801ec8:	ff 75 f0             	pushl  -0x10(%ebp)
  801ecb:	e8 1d f5 ff ff       	call   8013ed <fd2num>
  801ed0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ed3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	ba 00 00 00 00       	mov    $0x0,%edx
  801ede:	eb 30                	jmp    801f10 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801ee0:	83 ec 08             	sub    $0x8,%esp
  801ee3:	56                   	push   %esi
  801ee4:	6a 00                	push   $0x0
  801ee6:	e8 88 f2 ff ff       	call   801173 <sys_page_unmap>
  801eeb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801eee:	83 ec 08             	sub    $0x8,%esp
  801ef1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef4:	6a 00                	push   $0x0
  801ef6:	e8 78 f2 ff ff       	call   801173 <sys_page_unmap>
  801efb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801efe:	83 ec 08             	sub    $0x8,%esp
  801f01:	ff 75 f4             	pushl  -0xc(%ebp)
  801f04:	6a 00                	push   $0x0
  801f06:	e8 68 f2 ff ff       	call   801173 <sys_page_unmap>
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801f10:	89 d0                	mov    %edx,%eax
  801f12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f22:	50                   	push   %eax
  801f23:	ff 75 08             	pushl  0x8(%ebp)
  801f26:	e8 38 f5 ff ff       	call   801463 <fd_lookup>
  801f2b:	89 c2                	mov    %eax,%edx
  801f2d:	83 c4 10             	add    $0x10,%esp
  801f30:	85 d2                	test   %edx,%edx
  801f32:	78 18                	js     801f4c <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801f34:	83 ec 0c             	sub    $0xc,%esp
  801f37:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3a:	e8 be f4 ff ff       	call   8013fd <fd2data>
	return _pipeisclosed(fd, p);
  801f3f:	89 c2                	mov    %eax,%edx
  801f41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f44:	e8 2c fd ff ff       	call   801c75 <_pipeisclosed>
  801f49:	83 c4 10             	add    $0x10,%esp
}
  801f4c:	c9                   	leave  
  801f4d:	c3                   	ret    

00801f4e <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f4e:	55                   	push   %ebp
  801f4f:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801f51:	b8 00 00 00 00       	mov    $0x0,%eax
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    

00801f58 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f5e:	68 2c 2c 80 00       	push   $0x802c2c
  801f63:	ff 75 0c             	pushl  0xc(%ebp)
  801f66:	e8 79 ed ff ff       	call   800ce4 <strcpy>
	return 0;
}
  801f6b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    

00801f72 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f7e:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f83:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801f89:	eb 2e                	jmp    801fb9 <devcons_write+0x47>
		m = n - tot;
  801f8b:	8b 55 10             	mov    0x10(%ebp),%edx
  801f8e:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801f90:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801f95:	83 fa 7f             	cmp    $0x7f,%edx
  801f98:	77 02                	ja     801f9c <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801f9a:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801f9c:	83 ec 04             	sub    $0x4,%esp
  801f9f:	56                   	push   %esi
  801fa0:	03 45 0c             	add    0xc(%ebp),%eax
  801fa3:	50                   	push   %eax
  801fa4:	57                   	push   %edi
  801fa5:	e8 cc ee ff ff       	call   800e76 <memmove>
		sys_cputs(buf, m);
  801faa:	83 c4 08             	add    $0x8,%esp
  801fad:	56                   	push   %esi
  801fae:	57                   	push   %edi
  801faf:	e8 7e f0 ff ff       	call   801032 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801fb4:	01 f3                	add    %esi,%ebx
  801fb6:	83 c4 10             	add    $0x10,%esp
  801fb9:	89 d8                	mov    %ebx,%eax
  801fbb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fbe:	72 cb                	jb     801f8b <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801fc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc3:	5b                   	pop    %ebx
  801fc4:	5e                   	pop    %esi
  801fc5:	5f                   	pop    %edi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801fce:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801fd3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fd7:	75 07                	jne    801fe0 <devcons_read+0x18>
  801fd9:	eb 28                	jmp    802003 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801fdb:	e8 ef f0 ff ff       	call   8010cf <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801fe0:	e8 6b f0 ff ff       	call   801050 <sys_cgetc>
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	74 f2                	je     801fdb <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801fe9:	85 c0                	test   %eax,%eax
  801feb:	78 16                	js     802003 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801fed:	83 f8 04             	cmp    $0x4,%eax
  801ff0:	74 0c                	je     801ffe <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ff2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ff5:	88 02                	mov    %al,(%edx)
	return 1;
  801ff7:	b8 01 00 00 00       	mov    $0x1,%eax
  801ffc:	eb 05                	jmp    802003 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802003:	c9                   	leave  
  802004:	c3                   	ret    

00802005 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80200b:	8b 45 08             	mov    0x8(%ebp),%eax
  80200e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802011:	6a 01                	push   $0x1
  802013:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802016:	50                   	push   %eax
  802017:	e8 16 f0 ff ff       	call   801032 <sys_cputs>
  80201c:	83 c4 10             	add    $0x10,%esp
}
  80201f:	c9                   	leave  
  802020:	c3                   	ret    

00802021 <getchar>:

int
getchar(void)
{
  802021:	55                   	push   %ebp
  802022:	89 e5                	mov    %esp,%ebp
  802024:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802027:	6a 01                	push   $0x1
  802029:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80202c:	50                   	push   %eax
  80202d:	6a 00                	push   $0x0
  80202f:	e8 98 f6 ff ff       	call   8016cc <read>
	if (r < 0)
  802034:	83 c4 10             	add    $0x10,%esp
  802037:	85 c0                	test   %eax,%eax
  802039:	78 0f                	js     80204a <getchar+0x29>
		return r;
	if (r < 1)
  80203b:	85 c0                	test   %eax,%eax
  80203d:	7e 06                	jle    802045 <getchar+0x24>
		return -E_EOF;
	return c;
  80203f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802043:	eb 05                	jmp    80204a <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802045:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80204a:	c9                   	leave  
  80204b:	c3                   	ret    

0080204c <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
  80204f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802052:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802055:	50                   	push   %eax
  802056:	ff 75 08             	pushl  0x8(%ebp)
  802059:	e8 05 f4 ff ff       	call   801463 <fd_lookup>
  80205e:	83 c4 10             	add    $0x10,%esp
  802061:	85 c0                	test   %eax,%eax
  802063:	78 11                	js     802076 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802065:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802068:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80206e:	39 10                	cmp    %edx,(%eax)
  802070:	0f 94 c0             	sete   %al
  802073:	0f b6 c0             	movzbl %al,%eax
}
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <opencons>:

int
opencons(void)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80207e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802081:	50                   	push   %eax
  802082:	e8 8d f3 ff ff       	call   801414 <fd_alloc>
  802087:	83 c4 10             	add    $0x10,%esp
		return r;
  80208a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80208c:	85 c0                	test   %eax,%eax
  80208e:	78 3e                	js     8020ce <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802090:	83 ec 04             	sub    $0x4,%esp
  802093:	68 07 04 00 00       	push   $0x407
  802098:	ff 75 f4             	pushl  -0xc(%ebp)
  80209b:	6a 00                	push   $0x0
  80209d:	e8 4c f0 ff ff       	call   8010ee <sys_page_alloc>
  8020a2:	83 c4 10             	add    $0x10,%esp
		return r;
  8020a5:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	78 23                	js     8020ce <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8020ab:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8020b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020b6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020b9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020c0:	83 ec 0c             	sub    $0xc,%esp
  8020c3:	50                   	push   %eax
  8020c4:	e8 24 f3 ff ff       	call   8013ed <fd2num>
  8020c9:	89 c2                	mov    %eax,%edx
  8020cb:	83 c4 10             	add    $0x10,%esp
}
  8020ce:	89 d0                	mov    %edx,%eax
  8020d0:	c9                   	leave  
  8020d1:	c3                   	ret    

008020d2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d8:	89 d0                	mov    %edx,%eax
  8020da:	c1 e8 16             	shr    $0x16,%eax
  8020dd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020e4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020e9:	f6 c1 01             	test   $0x1,%cl
  8020ec:	74 1d                	je     80210b <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ee:	c1 ea 0c             	shr    $0xc,%edx
  8020f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f8:	f6 c2 01             	test   $0x1,%dl
  8020fb:	74 0e                	je     80210b <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020fd:	c1 ea 0c             	shr    $0xc,%edx
  802100:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802107:	ef 
  802108:	0f b7 c0             	movzwl %ax,%eax
}
  80210b:	5d                   	pop    %ebp
  80210c:	c3                   	ret    
  80210d:	66 90                	xchg   %ax,%ax
  80210f:	90                   	nop

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	57                   	push   %edi
  802112:	56                   	push   %esi
  802113:	83 ec 10             	sub    $0x10,%esp
  802116:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  80211a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  80211e:	8b 74 24 24          	mov    0x24(%esp),%esi
  802122:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  802126:	85 d2                	test   %edx,%edx
  802128:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80212c:	89 34 24             	mov    %esi,(%esp)
  80212f:	89 c8                	mov    %ecx,%eax
  802131:	75 35                	jne    802168 <__udivdi3+0x58>
  802133:	39 f1                	cmp    %esi,%ecx
  802135:	0f 87 bd 00 00 00    	ja     8021f8 <__udivdi3+0xe8>
  80213b:	85 c9                	test   %ecx,%ecx
  80213d:	89 cd                	mov    %ecx,%ebp
  80213f:	75 0b                	jne    80214c <__udivdi3+0x3c>
  802141:	b8 01 00 00 00       	mov    $0x1,%eax
  802146:	31 d2                	xor    %edx,%edx
  802148:	f7 f1                	div    %ecx
  80214a:	89 c5                	mov    %eax,%ebp
  80214c:	89 f0                	mov    %esi,%eax
  80214e:	31 d2                	xor    %edx,%edx
  802150:	f7 f5                	div    %ebp
  802152:	89 c6                	mov    %eax,%esi
  802154:	89 f8                	mov    %edi,%eax
  802156:	f7 f5                	div    %ebp
  802158:	89 f2                	mov    %esi,%edx
  80215a:	83 c4 10             	add    $0x10,%esp
  80215d:	5e                   	pop    %esi
  80215e:	5f                   	pop    %edi
  80215f:	5d                   	pop    %ebp
  802160:	c3                   	ret    
  802161:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802168:	3b 14 24             	cmp    (%esp),%edx
  80216b:	77 7b                	ja     8021e8 <__udivdi3+0xd8>
  80216d:	0f bd f2             	bsr    %edx,%esi
  802170:	83 f6 1f             	xor    $0x1f,%esi
  802173:	0f 84 97 00 00 00    	je     802210 <__udivdi3+0x100>
  802179:	bd 20 00 00 00       	mov    $0x20,%ebp
  80217e:	89 d7                	mov    %edx,%edi
  802180:	89 f1                	mov    %esi,%ecx
  802182:	29 f5                	sub    %esi,%ebp
  802184:	d3 e7                	shl    %cl,%edi
  802186:	89 c2                	mov    %eax,%edx
  802188:	89 e9                	mov    %ebp,%ecx
  80218a:	d3 ea                	shr    %cl,%edx
  80218c:	89 f1                	mov    %esi,%ecx
  80218e:	09 fa                	or     %edi,%edx
  802190:	8b 3c 24             	mov    (%esp),%edi
  802193:	d3 e0                	shl    %cl,%eax
  802195:	89 54 24 08          	mov    %edx,0x8(%esp)
  802199:	89 e9                	mov    %ebp,%ecx
  80219b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80219f:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021a3:	89 fa                	mov    %edi,%edx
  8021a5:	d3 ea                	shr    %cl,%edx
  8021a7:	89 f1                	mov    %esi,%ecx
  8021a9:	d3 e7                	shl    %cl,%edi
  8021ab:	89 e9                	mov    %ebp,%ecx
  8021ad:	d3 e8                	shr    %cl,%eax
  8021af:	09 c7                	or     %eax,%edi
  8021b1:	89 f8                	mov    %edi,%eax
  8021b3:	f7 74 24 08          	divl   0x8(%esp)
  8021b7:	89 d5                	mov    %edx,%ebp
  8021b9:	89 c7                	mov    %eax,%edi
  8021bb:	f7 64 24 0c          	mull   0xc(%esp)
  8021bf:	39 d5                	cmp    %edx,%ebp
  8021c1:	89 14 24             	mov    %edx,(%esp)
  8021c4:	72 11                	jb     8021d7 <__udivdi3+0xc7>
  8021c6:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021ca:	89 f1                	mov    %esi,%ecx
  8021cc:	d3 e2                	shl    %cl,%edx
  8021ce:	39 c2                	cmp    %eax,%edx
  8021d0:	73 5e                	jae    802230 <__udivdi3+0x120>
  8021d2:	3b 2c 24             	cmp    (%esp),%ebp
  8021d5:	75 59                	jne    802230 <__udivdi3+0x120>
  8021d7:	8d 47 ff             	lea    -0x1(%edi),%eax
  8021da:	31 f6                	xor    %esi,%esi
  8021dc:	89 f2                	mov    %esi,%edx
  8021de:	83 c4 10             	add    $0x10,%esp
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	31 f6                	xor    %esi,%esi
  8021ea:	31 c0                	xor    %eax,%eax
  8021ec:	89 f2                	mov    %esi,%edx
  8021ee:	83 c4 10             	add    $0x10,%esp
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	89 f2                	mov    %esi,%edx
  8021fa:	31 f6                	xor    %esi,%esi
  8021fc:	89 f8                	mov    %edi,%eax
  8021fe:	f7 f1                	div    %ecx
  802200:	89 f2                	mov    %esi,%edx
  802202:	83 c4 10             	add    $0x10,%esp
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  802214:	76 0b                	jbe    802221 <__udivdi3+0x111>
  802216:	31 c0                	xor    %eax,%eax
  802218:	3b 14 24             	cmp    (%esp),%edx
  80221b:	0f 83 37 ff ff ff    	jae    802158 <__udivdi3+0x48>
  802221:	b8 01 00 00 00       	mov    $0x1,%eax
  802226:	e9 2d ff ff ff       	jmp    802158 <__udivdi3+0x48>
  80222b:	90                   	nop
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 f8                	mov    %edi,%eax
  802232:	31 f6                	xor    %esi,%esi
  802234:	e9 1f ff ff ff       	jmp    802158 <__udivdi3+0x48>
  802239:	66 90                	xchg   %ax,%ax
  80223b:	66 90                	xchg   %ax,%ax
  80223d:	66 90                	xchg   %ax,%ax
  80223f:	90                   	nop

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	57                   	push   %edi
  802242:	56                   	push   %esi
  802243:	83 ec 20             	sub    $0x20,%esp
  802246:	8b 44 24 34          	mov    0x34(%esp),%eax
  80224a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80224e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802252:	89 c6                	mov    %eax,%esi
  802254:	89 44 24 10          	mov    %eax,0x10(%esp)
  802258:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80225c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  802260:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802264:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  802268:	89 74 24 18          	mov    %esi,0x18(%esp)
  80226c:	85 c0                	test   %eax,%eax
  80226e:	89 c2                	mov    %eax,%edx
  802270:	75 1e                	jne    802290 <__umoddi3+0x50>
  802272:	39 f7                	cmp    %esi,%edi
  802274:	76 52                	jbe    8022c8 <__umoddi3+0x88>
  802276:	89 c8                	mov    %ecx,%eax
  802278:	89 f2                	mov    %esi,%edx
  80227a:	f7 f7                	div    %edi
  80227c:	89 d0                	mov    %edx,%eax
  80227e:	31 d2                	xor    %edx,%edx
  802280:	83 c4 20             	add    $0x20,%esp
  802283:	5e                   	pop    %esi
  802284:	5f                   	pop    %edi
  802285:	5d                   	pop    %ebp
  802286:	c3                   	ret    
  802287:	89 f6                	mov    %esi,%esi
  802289:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802290:	39 f0                	cmp    %esi,%eax
  802292:	77 5c                	ja     8022f0 <__umoddi3+0xb0>
  802294:	0f bd e8             	bsr    %eax,%ebp
  802297:	83 f5 1f             	xor    $0x1f,%ebp
  80229a:	75 64                	jne    802300 <__umoddi3+0xc0>
  80229c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  8022a0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  8022a4:	0f 86 f6 00 00 00    	jbe    8023a0 <__umoddi3+0x160>
  8022aa:	3b 44 24 18          	cmp    0x18(%esp),%eax
  8022ae:	0f 82 ec 00 00 00    	jb     8023a0 <__umoddi3+0x160>
  8022b4:	8b 44 24 14          	mov    0x14(%esp),%eax
  8022b8:	8b 54 24 18          	mov    0x18(%esp),%edx
  8022bc:	83 c4 20             	add    $0x20,%esp
  8022bf:	5e                   	pop    %esi
  8022c0:	5f                   	pop    %edi
  8022c1:	5d                   	pop    %ebp
  8022c2:	c3                   	ret    
  8022c3:	90                   	nop
  8022c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c8:	85 ff                	test   %edi,%edi
  8022ca:	89 fd                	mov    %edi,%ebp
  8022cc:	75 0b                	jne    8022d9 <__umoddi3+0x99>
  8022ce:	b8 01 00 00 00       	mov    $0x1,%eax
  8022d3:	31 d2                	xor    %edx,%edx
  8022d5:	f7 f7                	div    %edi
  8022d7:	89 c5                	mov    %eax,%ebp
  8022d9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8022dd:	31 d2                	xor    %edx,%edx
  8022df:	f7 f5                	div    %ebp
  8022e1:	89 c8                	mov    %ecx,%eax
  8022e3:	f7 f5                	div    %ebp
  8022e5:	eb 95                	jmp    80227c <__umoddi3+0x3c>
  8022e7:	89 f6                	mov    %esi,%esi
  8022e9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8022f0:	89 c8                	mov    %ecx,%eax
  8022f2:	89 f2                	mov    %esi,%edx
  8022f4:	83 c4 20             	add    $0x20,%esp
  8022f7:	5e                   	pop    %esi
  8022f8:	5f                   	pop    %edi
  8022f9:	5d                   	pop    %ebp
  8022fa:	c3                   	ret    
  8022fb:	90                   	nop
  8022fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802300:	b8 20 00 00 00       	mov    $0x20,%eax
  802305:	89 e9                	mov    %ebp,%ecx
  802307:	29 e8                	sub    %ebp,%eax
  802309:	d3 e2                	shl    %cl,%edx
  80230b:	89 c7                	mov    %eax,%edi
  80230d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802311:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802315:	89 f9                	mov    %edi,%ecx
  802317:	d3 e8                	shr    %cl,%eax
  802319:	89 c1                	mov    %eax,%ecx
  80231b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80231f:	09 d1                	or     %edx,%ecx
  802321:	89 fa                	mov    %edi,%edx
  802323:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802327:	89 e9                	mov    %ebp,%ecx
  802329:	d3 e0                	shl    %cl,%eax
  80232b:	89 f9                	mov    %edi,%ecx
  80232d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802331:	89 f0                	mov    %esi,%eax
  802333:	d3 e8                	shr    %cl,%eax
  802335:	89 e9                	mov    %ebp,%ecx
  802337:	89 c7                	mov    %eax,%edi
  802339:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80233d:	d3 e6                	shl    %cl,%esi
  80233f:	89 d1                	mov    %edx,%ecx
  802341:	89 fa                	mov    %edi,%edx
  802343:	d3 e8                	shr    %cl,%eax
  802345:	89 e9                	mov    %ebp,%ecx
  802347:	09 f0                	or     %esi,%eax
  802349:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80234d:	f7 74 24 10          	divl   0x10(%esp)
  802351:	d3 e6                	shl    %cl,%esi
  802353:	89 d1                	mov    %edx,%ecx
  802355:	f7 64 24 0c          	mull   0xc(%esp)
  802359:	39 d1                	cmp    %edx,%ecx
  80235b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80235f:	89 d7                	mov    %edx,%edi
  802361:	89 c6                	mov    %eax,%esi
  802363:	72 0a                	jb     80236f <__umoddi3+0x12f>
  802365:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802369:	73 10                	jae    80237b <__umoddi3+0x13b>
  80236b:	39 d1                	cmp    %edx,%ecx
  80236d:	75 0c                	jne    80237b <__umoddi3+0x13b>
  80236f:	89 d7                	mov    %edx,%edi
  802371:	89 c6                	mov    %eax,%esi
  802373:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802377:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80237b:	89 ca                	mov    %ecx,%edx
  80237d:	89 e9                	mov    %ebp,%ecx
  80237f:	8b 44 24 14          	mov    0x14(%esp),%eax
  802383:	29 f0                	sub    %esi,%eax
  802385:	19 fa                	sbb    %edi,%edx
  802387:	d3 e8                	shr    %cl,%eax
  802389:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80238e:	89 d7                	mov    %edx,%edi
  802390:	d3 e7                	shl    %cl,%edi
  802392:	89 e9                	mov    %ebp,%ecx
  802394:	09 f8                	or     %edi,%eax
  802396:	d3 ea                	shr    %cl,%edx
  802398:	83 c4 20             	add    $0x20,%esp
  80239b:	5e                   	pop    %esi
  80239c:	5f                   	pop    %edi
  80239d:	5d                   	pop    %ebp
  80239e:	c3                   	ret    
  80239f:	90                   	nop
  8023a0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8023a4:	29 f9                	sub    %edi,%ecx
  8023a6:	19 c6                	sbb    %eax,%esi
  8023a8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8023ac:	89 74 24 18          	mov    %esi,0x18(%esp)
  8023b0:	e9 ff fe ff ff       	jmp    8022b4 <__umoddi3+0x74>
