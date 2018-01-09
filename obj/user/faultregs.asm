
obj/user/faultregs:     file format elf32-i386


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
  80002c:	e8 60 05 00 00       	call   800591 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 f1 23 80 00       	push   $0x8023f1
  800049:	68 c0 23 80 00       	push   $0x8023c0
  80004e:	e8 77 06 00 00       	call   8006ca <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 d0 23 80 00       	push   $0x8023d0
  80005c:	68 d4 23 80 00       	push   $0x8023d4
  800061:	e8 64 06 00 00       	call   8006ca <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 e4 23 80 00       	push   $0x8023e4
  800077:	e8 4e 06 00 00       	call   8006ca <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 e8 23 80 00       	push   $0x8023e8
  80008e:	e8 37 06 00 00       	call   8006ca <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 f2 23 80 00       	push   $0x8023f2
  8000a6:	68 d4 23 80 00       	push   $0x8023d4
  8000ab:	e8 1a 06 00 00       	call   8006ca <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 e4 23 80 00       	push   $0x8023e4
  8000c3:	e8 02 06 00 00       	call   8006ca <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 e8 23 80 00       	push   $0x8023e8
  8000d5:	e8 f0 05 00 00       	call   8006ca <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 f6 23 80 00       	push   $0x8023f6
  8000ed:	68 d4 23 80 00       	push   $0x8023d4
  8000f2:	e8 d3 05 00 00       	call   8006ca <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 e4 23 80 00       	push   $0x8023e4
  80010a:	e8 bb 05 00 00       	call   8006ca <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 e8 23 80 00       	push   $0x8023e8
  80011c:	e8 a9 05 00 00       	call   8006ca <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 fa 23 80 00       	push   $0x8023fa
  800134:	68 d4 23 80 00       	push   $0x8023d4
  800139:	e8 8c 05 00 00       	call   8006ca <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 e4 23 80 00       	push   $0x8023e4
  800151:	e8 74 05 00 00       	call   8006ca <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 e8 23 80 00       	push   $0x8023e8
  800163:	e8 62 05 00 00       	call   8006ca <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 fe 23 80 00       	push   $0x8023fe
  80017b:	68 d4 23 80 00       	push   $0x8023d4
  800180:	e8 45 05 00 00       	call   8006ca <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 e4 23 80 00       	push   $0x8023e4
  800198:	e8 2d 05 00 00       	call   8006ca <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 e8 23 80 00       	push   $0x8023e8
  8001aa:	e8 1b 05 00 00       	call   8006ca <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 02 24 80 00       	push   $0x802402
  8001c2:	68 d4 23 80 00       	push   $0x8023d4
  8001c7:	e8 fe 04 00 00       	call   8006ca <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 e4 23 80 00       	push   $0x8023e4
  8001df:	e8 e6 04 00 00       	call   8006ca <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 e8 23 80 00       	push   $0x8023e8
  8001f1:	e8 d4 04 00 00       	call   8006ca <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 06 24 80 00       	push   $0x802406
  800209:	68 d4 23 80 00       	push   $0x8023d4
  80020e:	e8 b7 04 00 00       	call   8006ca <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 e4 23 80 00       	push   $0x8023e4
  800226:	e8 9f 04 00 00       	call   8006ca <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 e8 23 80 00       	push   $0x8023e8
  800238:	e8 8d 04 00 00       	call   8006ca <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 0a 24 80 00       	push   $0x80240a
  800250:	68 d4 23 80 00       	push   $0x8023d4
  800255:	e8 70 04 00 00       	call   8006ca <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 e4 23 80 00       	push   $0x8023e4
  80026d:	e8 58 04 00 00       	call   8006ca <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 e8 23 80 00       	push   $0x8023e8
  80027f:	e8 46 04 00 00       	call   8006ca <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 0e 24 80 00       	push   $0x80240e
  800297:	68 d4 23 80 00       	push   $0x8023d4
  80029c:	e8 29 04 00 00       	call   8006ca <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 e4 23 80 00       	push   $0x8023e4
  8002b4:	e8 11 04 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 15 24 80 00       	push   $0x802415
  8002c4:	68 d4 23 80 00       	push   $0x8023d4
  8002c9:	e8 fc 03 00 00       	call   8006ca <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	75 57                	jne    800330 <check_regs+0x2fd>
  8002d9:	eb 2f                	jmp    80030a <check_regs+0x2d7>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 e8 23 80 00       	push   $0x8023e8
  8002e3:	e8 e2 03 00 00       	call   8006ca <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 15 24 80 00       	push   $0x802415
  8002f3:	68 d4 23 80 00       	push   $0x8023d4
  8002f8:	e8 cd 03 00 00       	call   8006ca <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 e4 23 80 00       	push   $0x8023e4
  800312:	e8 b3 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 19 24 80 00       	push   $0x802419
  800322:	e8 a3 03 00 00       	call   8006ca <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 e8 23 80 00       	push   $0x8023e8
  800338:	e8 8d 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 19 24 80 00       	push   $0x802419
  800348:	e8 7d 03 00 00       	call   8006ca <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 e4 23 80 00       	push   $0x8023e4
  80035a:	e8 6b 03 00 00       	call   8006ca <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 e8 23 80 00       	push   $0x8023e8
  80036c:	e8 59 03 00 00       	call   8006ca <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 e4 23 80 00       	push   $0x8023e4
  80037e:	e8 47 03 00 00       	call   8006ca <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 19 24 80 00       	push   $0x802419
  80038e:	e8 37 03 00 00       	call   8006ca <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 80 24 80 00       	push   $0x802480
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 27 24 80 00       	push   $0x802427
  8003c6:	e8 26 02 00 00       	call   8005f1 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  800425:	8b 40 30             	mov    0x30(%eax),%eax
  800428:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	68 3f 24 80 00       	push   $0x80243f
  800435:	68 4d 24 80 00       	push   $0x80244d
  80043a:	b9 40 40 80 00       	mov    $0x804040,%ecx
  80043f:	ba 38 24 80 00       	mov    $0x802438,%edx
  800444:	b8 80 40 80 00       	mov    $0x804080,%eax
  800449:	e8 e5 fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  80044e:	83 c4 0c             	add    $0xc,%esp
  800451:	6a 07                	push   $0x7
  800453:	68 00 00 40 00       	push   $0x400000
  800458:	6a 00                	push   $0x0
  80045a:	e8 f9 0b 00 00       	call   801058 <sys_page_alloc>
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	85 c0                	test   %eax,%eax
  800464:	79 12                	jns    800478 <pgfault+0xd8>
		panic("sys_page_alloc: %i", r);
  800466:	50                   	push   %eax
  800467:	68 54 24 80 00       	push   $0x802454
  80046c:	6a 5c                	push   $0x5c
  80046e:	68 27 24 80 00       	push   $0x802427
  800473:	e8 79 01 00 00       	call   8005f1 <_panic>
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <umain>:

void
umain(int argc, char **argv)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800480:	68 a0 03 80 00       	push   $0x8003a0
  800485:	e8 de 0d 00 00       	call   801268 <set_pgfault_handler>

	__asm __volatile(
  80048a:	50                   	push   %eax
  80048b:	9c                   	pushf  
  80048c:	58                   	pop    %eax
  80048d:	0d d5 08 00 00       	or     $0x8d5,%eax
  800492:	50                   	push   %eax
  800493:	9d                   	popf   
  800494:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  800499:	8d 05 d4 04 80 00    	lea    0x8004d4,%eax
  80049f:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004a4:	58                   	pop    %eax
  8004a5:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004ab:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b1:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004b7:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004bd:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c3:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004c9:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004ce:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004d4:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004db:	00 00 00 
  8004de:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004e4:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004ea:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f0:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004f6:	89 15 14 40 80 00    	mov    %edx,0x804014
  8004fc:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800502:	a3 1c 40 80 00       	mov    %eax,0x80401c
  800507:	89 25 28 40 80 00    	mov    %esp,0x804028
  80050d:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800513:	8b 35 84 40 80 00    	mov    0x804084,%esi
  800519:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  80051f:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  800525:	8b 15 94 40 80 00    	mov    0x804094,%edx
  80052b:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800531:	a1 9c 40 80 00       	mov    0x80409c,%eax
  800536:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  80053c:	50                   	push   %eax
  80053d:	9c                   	pushf  
  80053e:	58                   	pop    %eax
  80053f:	a3 24 40 80 00       	mov    %eax,0x804024
  800544:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  80054f:	74 10                	je     800561 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	68 b4 24 80 00       	push   $0x8024b4
  800559:	e8 6c 01 00 00       	call   8006ca <cprintf>
  80055e:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800561:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  800566:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  80056b:	83 ec 08             	sub    $0x8,%esp
  80056e:	68 67 24 80 00       	push   $0x802467
  800573:	68 78 24 80 00       	push   $0x802478
  800578:	b9 00 40 80 00       	mov    $0x804000,%ecx
  80057d:	ba 38 24 80 00       	mov    $0x802438,%edx
  800582:	b8 80 40 80 00       	mov    $0x804080,%eax
  800587:	e8 a7 fa ff ff       	call   800033 <check_regs>
  80058c:	83 c4 10             	add    $0x10,%esp
}
  80058f:	c9                   	leave  
  800590:	c3                   	ret    

00800591 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800591:	55                   	push   %ebp
  800592:	89 e5                	mov    %esp,%ebp
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800599:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  80059c:	e8 79 0a 00 00       	call   80101a <sys_getenvid>
  8005a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005a6:	6b c0 78             	imul   $0x78,%eax,%eax
  8005a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005ae:	a3 b0 40 80 00       	mov    %eax,0x8040b0

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005b3:	85 db                	test   %ebx,%ebx
  8005b5:	7e 07                	jle    8005be <libmain+0x2d>
		binaryname = argv[0];
  8005b7:	8b 06                	mov    (%esi),%eax
  8005b9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	53                   	push   %ebx
  8005c3:	e8 b2 fe ff ff       	call   80047a <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  8005c8:	e8 0a 00 00 00       	call   8005d7 <exit>
  8005cd:	83 c4 10             	add    $0x10,%esp
#endif
}
  8005d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d3:	5b                   	pop    %ebx
  8005d4:	5e                   	pop    %esi
  8005d5:	5d                   	pop    %ebp
  8005d6:	c3                   	ret    

008005d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005d7:	55                   	push   %ebp
  8005d8:	89 e5                	mov    %esp,%ebp
  8005da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005dd:	e8 e9 0e 00 00       	call   8014cb <close_all>
	sys_env_destroy(0);
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	6a 00                	push   $0x0
  8005e7:	e8 ed 09 00 00       	call   800fd9 <sys_env_destroy>
  8005ec:	83 c4 10             	add    $0x10,%esp
}
  8005ef:	c9                   	leave  
  8005f0:	c3                   	ret    

008005f1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f1:	55                   	push   %ebp
  8005f2:	89 e5                	mov    %esp,%ebp
  8005f4:	56                   	push   %esi
  8005f5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005f6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005f9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8005ff:	e8 16 0a 00 00       	call   80101a <sys_getenvid>
  800604:	83 ec 0c             	sub    $0xc,%esp
  800607:	ff 75 0c             	pushl  0xc(%ebp)
  80060a:	ff 75 08             	pushl  0x8(%ebp)
  80060d:	56                   	push   %esi
  80060e:	50                   	push   %eax
  80060f:	68 e0 24 80 00       	push   $0x8024e0
  800614:	e8 b1 00 00 00       	call   8006ca <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800619:	83 c4 18             	add    $0x18,%esp
  80061c:	53                   	push   %ebx
  80061d:	ff 75 10             	pushl  0x10(%ebp)
  800620:	e8 54 00 00 00       	call   800679 <vcprintf>
	cprintf("\n");
  800625:	c7 04 24 f0 23 80 00 	movl   $0x8023f0,(%esp)
  80062c:	e8 99 00 00 00       	call   8006ca <cprintf>
  800631:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800634:	cc                   	int3   
  800635:	eb fd                	jmp    800634 <_panic+0x43>

00800637 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 04             	sub    $0x4,%esp
  80063e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800641:	8b 13                	mov    (%ebx),%edx
  800643:	8d 42 01             	lea    0x1(%edx),%eax
  800646:	89 03                	mov    %eax,(%ebx)
  800648:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80064b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80064f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800654:	75 1a                	jne    800670 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	68 ff 00 00 00       	push   $0xff
  80065e:	8d 43 08             	lea    0x8(%ebx),%eax
  800661:	50                   	push   %eax
  800662:	e8 35 09 00 00       	call   800f9c <sys_cputs>
		b->idx = 0;
  800667:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80066d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800670:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800674:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800677:	c9                   	leave  
  800678:	c3                   	ret    

00800679 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800679:	55                   	push   %ebp
  80067a:	89 e5                	mov    %esp,%ebp
  80067c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800682:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800689:	00 00 00 
	b.cnt = 0;
  80068c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800693:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800696:	ff 75 0c             	pushl  0xc(%ebp)
  800699:	ff 75 08             	pushl  0x8(%ebp)
  80069c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a2:	50                   	push   %eax
  8006a3:	68 37 06 80 00       	push   $0x800637
  8006a8:	e8 4f 01 00 00       	call   8007fc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006ad:	83 c4 08             	add    $0x8,%esp
  8006b0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006b6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006bc:	50                   	push   %eax
  8006bd:	e8 da 08 00 00       	call   800f9c <sys_cputs>

	return b.cnt;
}
  8006c2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c8:	c9                   	leave  
  8006c9:	c3                   	ret    

008006ca <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006ca:	55                   	push   %ebp
  8006cb:	89 e5                	mov    %esp,%ebp
  8006cd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d3:	50                   	push   %eax
  8006d4:	ff 75 08             	pushl  0x8(%ebp)
  8006d7:	e8 9d ff ff ff       	call   800679 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006dc:	c9                   	leave  
  8006dd:	c3                   	ret    

008006de <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006de:	55                   	push   %ebp
  8006df:	89 e5                	mov    %esp,%ebp
  8006e1:	57                   	push   %edi
  8006e2:	56                   	push   %esi
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 1c             	sub    $0x1c,%esp
  8006e7:	89 c7                	mov    %eax,%edi
  8006e9:	89 d6                	mov    %edx,%esi
  8006eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f1:	89 d1                	mov    %edx,%ecx
  8006f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006ff:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800702:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800709:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  80070c:	72 05                	jb     800713 <printnum+0x35>
  80070e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  800711:	77 3e                	ja     800751 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800713:	83 ec 0c             	sub    $0xc,%esp
  800716:	ff 75 18             	pushl  0x18(%ebp)
  800719:	83 eb 01             	sub    $0x1,%ebx
  80071c:	53                   	push   %ebx
  80071d:	50                   	push   %eax
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	ff 75 e4             	pushl  -0x1c(%ebp)
  800724:	ff 75 e0             	pushl  -0x20(%ebp)
  800727:	ff 75 dc             	pushl  -0x24(%ebp)
  80072a:	ff 75 d8             	pushl  -0x28(%ebp)
  80072d:	e8 de 19 00 00       	call   802110 <__udivdi3>
  800732:	83 c4 18             	add    $0x18,%esp
  800735:	52                   	push   %edx
  800736:	50                   	push   %eax
  800737:	89 f2                	mov    %esi,%edx
  800739:	89 f8                	mov    %edi,%eax
  80073b:	e8 9e ff ff ff       	call   8006de <printnum>
  800740:	83 c4 20             	add    $0x20,%esp
  800743:	eb 13                	jmp    800758 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	56                   	push   %esi
  800749:	ff 75 18             	pushl  0x18(%ebp)
  80074c:	ff d7                	call   *%edi
  80074e:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800751:	83 eb 01             	sub    $0x1,%ebx
  800754:	85 db                	test   %ebx,%ebx
  800756:	7f ed                	jg     800745 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800758:	83 ec 08             	sub    $0x8,%esp
  80075b:	56                   	push   %esi
  80075c:	83 ec 04             	sub    $0x4,%esp
  80075f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800762:	ff 75 e0             	pushl  -0x20(%ebp)
  800765:	ff 75 dc             	pushl  -0x24(%ebp)
  800768:	ff 75 d8             	pushl  -0x28(%ebp)
  80076b:	e8 d0 1a 00 00       	call   802240 <__umoddi3>
  800770:	83 c4 14             	add    $0x14,%esp
  800773:	0f be 80 03 25 80 00 	movsbl 0x802503(%eax),%eax
  80077a:	50                   	push   %eax
  80077b:	ff d7                	call   *%edi
  80077d:	83 c4 10             	add    $0x10,%esp
}
  800780:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800783:	5b                   	pop    %ebx
  800784:	5e                   	pop    %esi
  800785:	5f                   	pop    %edi
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800788:	55                   	push   %ebp
  800789:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80078b:	83 fa 01             	cmp    $0x1,%edx
  80078e:	7e 0e                	jle    80079e <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800790:	8b 10                	mov    (%eax),%edx
  800792:	8d 4a 08             	lea    0x8(%edx),%ecx
  800795:	89 08                	mov    %ecx,(%eax)
  800797:	8b 02                	mov    (%edx),%eax
  800799:	8b 52 04             	mov    0x4(%edx),%edx
  80079c:	eb 22                	jmp    8007c0 <getuint+0x38>
	else if (lflag)
  80079e:	85 d2                	test   %edx,%edx
  8007a0:	74 10                	je     8007b2 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8007a2:	8b 10                	mov    (%eax),%edx
  8007a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 02                	mov    (%edx),%eax
  8007ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b0:	eb 0e                	jmp    8007c0 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8007b2:	8b 10                	mov    (%eax),%edx
  8007b4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8007b7:	89 08                	mov    %ecx,(%eax)
  8007b9:	8b 02                	mov    (%edx),%eax
  8007bb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8007c0:	5d                   	pop    %ebp
  8007c1:	c3                   	ret    

008007c2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8007c2:	55                   	push   %ebp
  8007c3:	89 e5                	mov    %esp,%ebp
  8007c5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8007c8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8007cc:	8b 10                	mov    (%eax),%edx
  8007ce:	3b 50 04             	cmp    0x4(%eax),%edx
  8007d1:	73 0a                	jae    8007dd <sprintputch+0x1b>
		*b->buf++ = ch;
  8007d3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007d6:	89 08                	mov    %ecx,(%eax)
  8007d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8007db:	88 02                	mov    %al,(%edx)
}
  8007dd:	5d                   	pop    %ebp
  8007de:	c3                   	ret    

008007df <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007df:	55                   	push   %ebp
  8007e0:	89 e5                	mov    %esp,%ebp
  8007e2:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007e5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007e8:	50                   	push   %eax
  8007e9:	ff 75 10             	pushl  0x10(%ebp)
  8007ec:	ff 75 0c             	pushl  0xc(%ebp)
  8007ef:	ff 75 08             	pushl  0x8(%ebp)
  8007f2:	e8 05 00 00 00       	call   8007fc <vprintfmt>
	va_end(ap);
  8007f7:	83 c4 10             	add    $0x10,%esp
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	57                   	push   %edi
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	83 ec 2c             	sub    $0x2c,%esp
  800805:	8b 75 08             	mov    0x8(%ebp),%esi
  800808:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80080b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80080e:	eb 12                	jmp    800822 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800810:	85 c0                	test   %eax,%eax
  800812:	0f 84 8d 03 00 00    	je     800ba5 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	50                   	push   %eax
  80081d:	ff d6                	call   *%esi
  80081f:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800822:	83 c7 01             	add    $0x1,%edi
  800825:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800829:	83 f8 25             	cmp    $0x25,%eax
  80082c:	75 e2                	jne    800810 <vprintfmt+0x14>
  80082e:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800832:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800839:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800840:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800847:	ba 00 00 00 00       	mov    $0x0,%edx
  80084c:	eb 07                	jmp    800855 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80084e:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800851:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800855:	8d 47 01             	lea    0x1(%edi),%eax
  800858:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80085b:	0f b6 07             	movzbl (%edi),%eax
  80085e:	0f b6 c8             	movzbl %al,%ecx
  800861:	83 e8 23             	sub    $0x23,%eax
  800864:	3c 55                	cmp    $0x55,%al
  800866:	0f 87 1e 03 00 00    	ja     800b8a <vprintfmt+0x38e>
  80086c:	0f b6 c0             	movzbl %al,%eax
  80086f:	ff 24 85 40 26 80 00 	jmp    *0x802640(,%eax,4)
  800876:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800879:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80087d:	eb d6                	jmp    800855 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800882:	b8 00 00 00 00       	mov    $0x0,%eax
  800887:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80088a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80088d:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800891:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  800894:	8d 51 d0             	lea    -0x30(%ecx),%edx
  800897:	83 fa 09             	cmp    $0x9,%edx
  80089a:	77 38                	ja     8008d4 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80089c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80089f:	eb e9                	jmp    80088a <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8008a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a4:	8d 48 04             	lea    0x4(%eax),%ecx
  8008a7:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8008aa:	8b 00                	mov    (%eax),%eax
  8008ac:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8008b2:	eb 26                	jmp    8008da <vprintfmt+0xde>
  8008b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8008b7:	89 c8                	mov    %ecx,%eax
  8008b9:	c1 f8 1f             	sar    $0x1f,%eax
  8008bc:	f7 d0                	not    %eax
  8008be:	21 c1                	and    %eax,%ecx
  8008c0:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008c6:	eb 8d                	jmp    800855 <vprintfmt+0x59>
  8008c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008cb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008d2:	eb 81                	jmp    800855 <vprintfmt+0x59>
  8008d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8008d7:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008da:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008de:	0f 89 71 ff ff ff    	jns    800855 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008e4:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008e7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008ea:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008f1:	e9 5f ff ff ff       	jmp    800855 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008f6:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008fc:	e9 54 ff ff ff       	jmp    800855 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800901:	8b 45 14             	mov    0x14(%ebp),%eax
  800904:	8d 50 04             	lea    0x4(%eax),%edx
  800907:	89 55 14             	mov    %edx,0x14(%ebp)
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	ff 30                	pushl  (%eax)
  800910:	ff d6                	call   *%esi
			break;
  800912:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800915:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800918:	e9 05 ff ff ff       	jmp    800822 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  80091d:	8b 45 14             	mov    0x14(%ebp),%eax
  800920:	8d 50 04             	lea    0x4(%eax),%edx
  800923:	89 55 14             	mov    %edx,0x14(%ebp)
  800926:	8b 00                	mov    (%eax),%eax
  800928:	99                   	cltd   
  800929:	31 d0                	xor    %edx,%eax
  80092b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80092d:	83 f8 0f             	cmp    $0xf,%eax
  800930:	7f 0b                	jg     80093d <vprintfmt+0x141>
  800932:	8b 14 85 c0 27 80 00 	mov    0x8027c0(,%eax,4),%edx
  800939:	85 d2                	test   %edx,%edx
  80093b:	75 18                	jne    800955 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  80093d:	50                   	push   %eax
  80093e:	68 1b 25 80 00       	push   $0x80251b
  800943:	53                   	push   %ebx
  800944:	56                   	push   %esi
  800945:	e8 95 fe ff ff       	call   8007df <printfmt>
  80094a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80094d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800950:	e9 cd fe ff ff       	jmp    800822 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800955:	52                   	push   %edx
  800956:	68 61 29 80 00       	push   $0x802961
  80095b:	53                   	push   %ebx
  80095c:	56                   	push   %esi
  80095d:	e8 7d fe ff ff       	call   8007df <printfmt>
  800962:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800965:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800968:	e9 b5 fe ff ff       	jmp    800822 <vprintfmt+0x26>
  80096d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800970:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800973:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800976:	8b 45 14             	mov    0x14(%ebp),%eax
  800979:	8d 50 04             	lea    0x4(%eax),%edx
  80097c:	89 55 14             	mov    %edx,0x14(%ebp)
  80097f:	8b 38                	mov    (%eax),%edi
  800981:	85 ff                	test   %edi,%edi
  800983:	75 05                	jne    80098a <vprintfmt+0x18e>
				p = "(null)";
  800985:	bf 14 25 80 00       	mov    $0x802514,%edi
			if (width > 0 && padc != '-')
  80098a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80098e:	0f 84 91 00 00 00    	je     800a25 <vprintfmt+0x229>
  800994:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800998:	0f 8e 95 00 00 00    	jle    800a33 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  80099e:	83 ec 08             	sub    $0x8,%esp
  8009a1:	51                   	push   %ecx
  8009a2:	57                   	push   %edi
  8009a3:	e8 85 02 00 00       	call   800c2d <strnlen>
  8009a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009ab:	29 c1                	sub    %eax,%ecx
  8009ad:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8009b0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8009b3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8009b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009ba:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8009bd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009bf:	eb 0f                	jmp    8009d0 <vprintfmt+0x1d4>
					putch(padc, putdat);
  8009c1:	83 ec 08             	sub    $0x8,%esp
  8009c4:	53                   	push   %ebx
  8009c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8009c8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009ca:	83 ef 01             	sub    $0x1,%edi
  8009cd:	83 c4 10             	add    $0x10,%esp
  8009d0:	85 ff                	test   %edi,%edi
  8009d2:	7f ed                	jg     8009c1 <vprintfmt+0x1c5>
  8009d4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009d7:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8009da:	89 c8                	mov    %ecx,%eax
  8009dc:	c1 f8 1f             	sar    $0x1f,%eax
  8009df:	f7 d0                	not    %eax
  8009e1:	21 c8                	and    %ecx,%eax
  8009e3:	29 c1                	sub    %eax,%ecx
  8009e5:	89 75 08             	mov    %esi,0x8(%ebp)
  8009e8:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009eb:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009ee:	89 cb                	mov    %ecx,%ebx
  8009f0:	eb 4d                	jmp    800a3f <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009f6:	74 1b                	je     800a13 <vprintfmt+0x217>
  8009f8:	0f be c0             	movsbl %al,%eax
  8009fb:	83 e8 20             	sub    $0x20,%eax
  8009fe:	83 f8 5e             	cmp    $0x5e,%eax
  800a01:	76 10                	jbe    800a13 <vprintfmt+0x217>
					putch('?', putdat);
  800a03:	83 ec 08             	sub    $0x8,%esp
  800a06:	ff 75 0c             	pushl  0xc(%ebp)
  800a09:	6a 3f                	push   $0x3f
  800a0b:	ff 55 08             	call   *0x8(%ebp)
  800a0e:	83 c4 10             	add    $0x10,%esp
  800a11:	eb 0d                	jmp    800a20 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  800a13:	83 ec 08             	sub    $0x8,%esp
  800a16:	ff 75 0c             	pushl  0xc(%ebp)
  800a19:	52                   	push   %edx
  800a1a:	ff 55 08             	call   *0x8(%ebp)
  800a1d:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a20:	83 eb 01             	sub    $0x1,%ebx
  800a23:	eb 1a                	jmp    800a3f <vprintfmt+0x243>
  800a25:	89 75 08             	mov    %esi,0x8(%ebp)
  800a28:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a2b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a2e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a31:	eb 0c                	jmp    800a3f <vprintfmt+0x243>
  800a33:	89 75 08             	mov    %esi,0x8(%ebp)
  800a36:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a39:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a3c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a3f:	83 c7 01             	add    $0x1,%edi
  800a42:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a46:	0f be d0             	movsbl %al,%edx
  800a49:	85 d2                	test   %edx,%edx
  800a4b:	74 23                	je     800a70 <vprintfmt+0x274>
  800a4d:	85 f6                	test   %esi,%esi
  800a4f:	78 a1                	js     8009f2 <vprintfmt+0x1f6>
  800a51:	83 ee 01             	sub    $0x1,%esi
  800a54:	79 9c                	jns    8009f2 <vprintfmt+0x1f6>
  800a56:	89 df                	mov    %ebx,%edi
  800a58:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a5e:	eb 18                	jmp    800a78 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a60:	83 ec 08             	sub    $0x8,%esp
  800a63:	53                   	push   %ebx
  800a64:	6a 20                	push   $0x20
  800a66:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a68:	83 ef 01             	sub    $0x1,%edi
  800a6b:	83 c4 10             	add    $0x10,%esp
  800a6e:	eb 08                	jmp    800a78 <vprintfmt+0x27c>
  800a70:	89 df                	mov    %ebx,%edi
  800a72:	8b 75 08             	mov    0x8(%ebp),%esi
  800a75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a78:	85 ff                	test   %edi,%edi
  800a7a:	7f e4                	jg     800a60 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a7f:	e9 9e fd ff ff       	jmp    800822 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a84:	83 fa 01             	cmp    $0x1,%edx
  800a87:	7e 16                	jle    800a9f <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800a89:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8c:	8d 50 08             	lea    0x8(%eax),%edx
  800a8f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a92:	8b 50 04             	mov    0x4(%eax),%edx
  800a95:	8b 00                	mov    (%eax),%eax
  800a97:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a9a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a9d:	eb 32                	jmp    800ad1 <vprintfmt+0x2d5>
	else if (lflag)
  800a9f:	85 d2                	test   %edx,%edx
  800aa1:	74 18                	je     800abb <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  800aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa6:	8d 50 04             	lea    0x4(%eax),%edx
  800aa9:	89 55 14             	mov    %edx,0x14(%ebp)
  800aac:	8b 00                	mov    (%eax),%eax
  800aae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ab1:	89 c1                	mov    %eax,%ecx
  800ab3:	c1 f9 1f             	sar    $0x1f,%ecx
  800ab6:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ab9:	eb 16                	jmp    800ad1 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800abb:	8b 45 14             	mov    0x14(%ebp),%eax
  800abe:	8d 50 04             	lea    0x4(%eax),%edx
  800ac1:	89 55 14             	mov    %edx,0x14(%ebp)
  800ac4:	8b 00                	mov    (%eax),%eax
  800ac6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800ac9:	89 c1                	mov    %eax,%ecx
  800acb:	c1 f9 1f             	sar    $0x1f,%ecx
  800ace:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ad1:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800ad4:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800ad7:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800adc:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ae0:	79 74                	jns    800b56 <vprintfmt+0x35a>
				putch('-', putdat);
  800ae2:	83 ec 08             	sub    $0x8,%esp
  800ae5:	53                   	push   %ebx
  800ae6:	6a 2d                	push   $0x2d
  800ae8:	ff d6                	call   *%esi
				num = -(long long) num;
  800aea:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800aed:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800af0:	f7 d8                	neg    %eax
  800af2:	83 d2 00             	adc    $0x0,%edx
  800af5:	f7 da                	neg    %edx
  800af7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800afa:	b9 0a 00 00 00       	mov    $0xa,%ecx
  800aff:	eb 55                	jmp    800b56 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800b01:	8d 45 14             	lea    0x14(%ebp),%eax
  800b04:	e8 7f fc ff ff       	call   800788 <getuint>
			base = 10;
  800b09:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  800b0e:	eb 46                	jmp    800b56 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  800b10:	8d 45 14             	lea    0x14(%ebp),%eax
  800b13:	e8 70 fc ff ff       	call   800788 <getuint>
			base = 8;
  800b18:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  800b1d:	eb 37                	jmp    800b56 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  800b1f:	83 ec 08             	sub    $0x8,%esp
  800b22:	53                   	push   %ebx
  800b23:	6a 30                	push   $0x30
  800b25:	ff d6                	call   *%esi
			putch('x', putdat);
  800b27:	83 c4 08             	add    $0x8,%esp
  800b2a:	53                   	push   %ebx
  800b2b:	6a 78                	push   $0x78
  800b2d:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b2f:	8b 45 14             	mov    0x14(%ebp),%eax
  800b32:	8d 50 04             	lea    0x4(%eax),%edx
  800b35:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800b38:	8b 00                	mov    (%eax),%eax
  800b3a:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b3f:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800b42:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  800b47:	eb 0d                	jmp    800b56 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800b49:	8d 45 14             	lea    0x14(%ebp),%eax
  800b4c:	e8 37 fc ff ff       	call   800788 <getuint>
			base = 16;
  800b51:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  800b56:	83 ec 0c             	sub    $0xc,%esp
  800b59:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800b5d:	57                   	push   %edi
  800b5e:	ff 75 e0             	pushl  -0x20(%ebp)
  800b61:	51                   	push   %ecx
  800b62:	52                   	push   %edx
  800b63:	50                   	push   %eax
  800b64:	89 da                	mov    %ebx,%edx
  800b66:	89 f0                	mov    %esi,%eax
  800b68:	e8 71 fb ff ff       	call   8006de <printnum>
			break;
  800b6d:	83 c4 20             	add    $0x20,%esp
  800b70:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800b73:	e9 aa fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800b78:	83 ec 08             	sub    $0x8,%esp
  800b7b:	53                   	push   %ebx
  800b7c:	51                   	push   %ecx
  800b7d:	ff d6                	call   *%esi
			break;
  800b7f:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b82:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800b85:	e9 98 fc ff ff       	jmp    800822 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800b8a:	83 ec 08             	sub    $0x8,%esp
  800b8d:	53                   	push   %ebx
  800b8e:	6a 25                	push   $0x25
  800b90:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b92:	83 c4 10             	add    $0x10,%esp
  800b95:	eb 03                	jmp    800b9a <vprintfmt+0x39e>
  800b97:	83 ef 01             	sub    $0x1,%edi
  800b9a:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800b9e:	75 f7                	jne    800b97 <vprintfmt+0x39b>
  800ba0:	e9 7d fc ff ff       	jmp    800822 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800ba5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba8:	5b                   	pop    %ebx
  800ba9:	5e                   	pop    %esi
  800baa:	5f                   	pop    %edi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	83 ec 18             	sub    $0x18,%esp
  800bb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800bb9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800bbc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800bc0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800bc3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bca:	85 c0                	test   %eax,%eax
  800bcc:	74 26                	je     800bf4 <vsnprintf+0x47>
  800bce:	85 d2                	test   %edx,%edx
  800bd0:	7e 22                	jle    800bf4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bd2:	ff 75 14             	pushl  0x14(%ebp)
  800bd5:	ff 75 10             	pushl  0x10(%ebp)
  800bd8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bdb:	50                   	push   %eax
  800bdc:	68 c2 07 80 00       	push   $0x8007c2
  800be1:	e8 16 fc ff ff       	call   8007fc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800be6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800be9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800bef:	83 c4 10             	add    $0x10,%esp
  800bf2:	eb 05                	jmp    800bf9 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800bf4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800bf9:	c9                   	leave  
  800bfa:	c3                   	ret    

00800bfb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c01:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c04:	50                   	push   %eax
  800c05:	ff 75 10             	pushl  0x10(%ebp)
  800c08:	ff 75 0c             	pushl  0xc(%ebp)
  800c0b:	ff 75 08             	pushl  0x8(%ebp)
  800c0e:	e8 9a ff ff ff       	call   800bad <vsnprintf>
	va_end(ap);

	return rc;
}
  800c13:	c9                   	leave  
  800c14:	c3                   	ret    

00800c15 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800c20:	eb 03                	jmp    800c25 <strlen+0x10>
		n++;
  800c22:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c25:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800c29:	75 f7                	jne    800c22 <strlen+0xd>
		n++;
	return n;
}
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c33:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c36:	ba 00 00 00 00       	mov    $0x0,%edx
  800c3b:	eb 03                	jmp    800c40 <strnlen+0x13>
		n++;
  800c3d:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c40:	39 c2                	cmp    %eax,%edx
  800c42:	74 08                	je     800c4c <strnlen+0x1f>
  800c44:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800c48:	75 f3                	jne    800c3d <strnlen+0x10>
  800c4a:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	53                   	push   %ebx
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c58:	89 c2                	mov    %eax,%edx
  800c5a:	83 c2 01             	add    $0x1,%edx
  800c5d:	83 c1 01             	add    $0x1,%ecx
  800c60:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800c64:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c67:	84 db                	test   %bl,%bl
  800c69:	75 ef                	jne    800c5a <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800c6b:	5b                   	pop    %ebx
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	53                   	push   %ebx
  800c72:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c75:	53                   	push   %ebx
  800c76:	e8 9a ff ff ff       	call   800c15 <strlen>
  800c7b:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800c7e:	ff 75 0c             	pushl  0xc(%ebp)
  800c81:	01 d8                	add    %ebx,%eax
  800c83:	50                   	push   %eax
  800c84:	e8 c5 ff ff ff       	call   800c4e <strcpy>
	return dst;
}
  800c89:	89 d8                	mov    %ebx,%eax
  800c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    

00800c90 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c90:	55                   	push   %ebp
  800c91:	89 e5                	mov    %esp,%ebp
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	8b 75 08             	mov    0x8(%ebp),%esi
  800c98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9b:	89 f3                	mov    %esi,%ebx
  800c9d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ca0:	89 f2                	mov    %esi,%edx
  800ca2:	eb 0f                	jmp    800cb3 <strncpy+0x23>
		*dst++ = *src;
  800ca4:	83 c2 01             	add    $0x1,%edx
  800ca7:	0f b6 01             	movzbl (%ecx),%eax
  800caa:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800cad:	80 39 01             	cmpb   $0x1,(%ecx)
  800cb0:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cb3:	39 da                	cmp    %ebx,%edx
  800cb5:	75 ed                	jne    800ca4 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800cb7:	89 f0                	mov    %esi,%eax
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	8b 75 08             	mov    0x8(%ebp),%esi
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 10             	mov    0x10(%ebp),%edx
  800ccb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ccd:	85 d2                	test   %edx,%edx
  800ccf:	74 21                	je     800cf2 <strlcpy+0x35>
  800cd1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800cd5:	89 f2                	mov    %esi,%edx
  800cd7:	eb 09                	jmp    800ce2 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800cd9:	83 c2 01             	add    $0x1,%edx
  800cdc:	83 c1 01             	add    $0x1,%ecx
  800cdf:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ce2:	39 c2                	cmp    %eax,%edx
  800ce4:	74 09                	je     800cef <strlcpy+0x32>
  800ce6:	0f b6 19             	movzbl (%ecx),%ebx
  800ce9:	84 db                	test   %bl,%bl
  800ceb:	75 ec                	jne    800cd9 <strlcpy+0x1c>
  800ced:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cef:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800cf2:	29 f0                	sub    %esi,%eax
}
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfe:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d01:	eb 06                	jmp    800d09 <strcmp+0x11>
		p++, q++;
  800d03:	83 c1 01             	add    $0x1,%ecx
  800d06:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d09:	0f b6 01             	movzbl (%ecx),%eax
  800d0c:	84 c0                	test   %al,%al
  800d0e:	74 04                	je     800d14 <strcmp+0x1c>
  800d10:	3a 02                	cmp    (%edx),%al
  800d12:	74 ef                	je     800d03 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d14:	0f b6 c0             	movzbl %al,%eax
  800d17:	0f b6 12             	movzbl (%edx),%edx
  800d1a:	29 d0                	sub    %edx,%eax
}
  800d1c:	5d                   	pop    %ebp
  800d1d:	c3                   	ret    

00800d1e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	53                   	push   %ebx
  800d22:	8b 45 08             	mov    0x8(%ebp),%eax
  800d25:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d28:	89 c3                	mov    %eax,%ebx
  800d2a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800d2d:	eb 06                	jmp    800d35 <strncmp+0x17>
		n--, p++, q++;
  800d2f:	83 c0 01             	add    $0x1,%eax
  800d32:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d35:	39 d8                	cmp    %ebx,%eax
  800d37:	74 15                	je     800d4e <strncmp+0x30>
  800d39:	0f b6 08             	movzbl (%eax),%ecx
  800d3c:	84 c9                	test   %cl,%cl
  800d3e:	74 04                	je     800d44 <strncmp+0x26>
  800d40:	3a 0a                	cmp    (%edx),%cl
  800d42:	74 eb                	je     800d2f <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d44:	0f b6 00             	movzbl (%eax),%eax
  800d47:	0f b6 12             	movzbl (%edx),%edx
  800d4a:	29 d0                	sub    %edx,%eax
  800d4c:	eb 05                	jmp    800d53 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800d4e:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d53:	5b                   	pop    %ebx
  800d54:	5d                   	pop    %ebp
  800d55:	c3                   	ret    

00800d56 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d56:	55                   	push   %ebp
  800d57:	89 e5                	mov    %esp,%ebp
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d60:	eb 07                	jmp    800d69 <strchr+0x13>
		if (*s == c)
  800d62:	38 ca                	cmp    %cl,%dl
  800d64:	74 0f                	je     800d75 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d66:	83 c0 01             	add    $0x1,%eax
  800d69:	0f b6 10             	movzbl (%eax),%edx
  800d6c:	84 d2                	test   %dl,%dl
  800d6e:	75 f2                	jne    800d62 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800d70:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d81:	eb 03                	jmp    800d86 <strfind+0xf>
  800d83:	83 c0 01             	add    $0x1,%eax
  800d86:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800d89:	84 d2                	test   %dl,%dl
  800d8b:	74 04                	je     800d91 <strfind+0x1a>
  800d8d:	38 ca                	cmp    %cl,%dl
  800d8f:	75 f2                	jne    800d83 <strfind+0xc>
			break;
	return (char *) s;
}
  800d91:	5d                   	pop    %ebp
  800d92:	c3                   	ret    

00800d93 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	57                   	push   %edi
  800d97:	56                   	push   %esi
  800d98:	53                   	push   %ebx
  800d99:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800d9f:	85 c9                	test   %ecx,%ecx
  800da1:	74 36                	je     800dd9 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da3:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800da9:	75 28                	jne    800dd3 <memset+0x40>
  800dab:	f6 c1 03             	test   $0x3,%cl
  800dae:	75 23                	jne    800dd3 <memset+0x40>
		c &= 0xFF;
  800db0:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db4:	89 d3                	mov    %edx,%ebx
  800db6:	c1 e3 08             	shl    $0x8,%ebx
  800db9:	89 d6                	mov    %edx,%esi
  800dbb:	c1 e6 18             	shl    $0x18,%esi
  800dbe:	89 d0                	mov    %edx,%eax
  800dc0:	c1 e0 10             	shl    $0x10,%eax
  800dc3:	09 f0                	or     %esi,%eax
  800dc5:	09 c2                	or     %eax,%edx
  800dc7:	89 d0                	mov    %edx,%eax
  800dc9:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800dcb:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800dce:	fc                   	cld    
  800dcf:	f3 ab                	rep stos %eax,%es:(%edi)
  800dd1:	eb 06                	jmp    800dd9 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd6:	fc                   	cld    
  800dd7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd9:	89 f8                	mov    %edi,%eax
  800ddb:	5b                   	pop    %ebx
  800ddc:	5e                   	pop    %esi
  800ddd:	5f                   	pop    %edi
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	57                   	push   %edi
  800de4:	56                   	push   %esi
  800de5:	8b 45 08             	mov    0x8(%ebp),%eax
  800de8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800deb:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800dee:	39 c6                	cmp    %eax,%esi
  800df0:	73 35                	jae    800e27 <memmove+0x47>
  800df2:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df5:	39 d0                	cmp    %edx,%eax
  800df7:	73 2e                	jae    800e27 <memmove+0x47>
		s += n;
		d += n;
  800df9:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800dfc:	89 d6                	mov    %edx,%esi
  800dfe:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e00:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e06:	75 13                	jne    800e1b <memmove+0x3b>
  800e08:	f6 c1 03             	test   $0x3,%cl
  800e0b:	75 0e                	jne    800e1b <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800e0d:	83 ef 04             	sub    $0x4,%edi
  800e10:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e13:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800e16:	fd                   	std    
  800e17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e19:	eb 09                	jmp    800e24 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800e1b:	83 ef 01             	sub    $0x1,%edi
  800e1e:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e21:	fd                   	std    
  800e22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e24:	fc                   	cld    
  800e25:	eb 1d                	jmp    800e44 <memmove+0x64>
  800e27:	89 f2                	mov    %esi,%edx
  800e29:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2b:	f6 c2 03             	test   $0x3,%dl
  800e2e:	75 0f                	jne    800e3f <memmove+0x5f>
  800e30:	f6 c1 03             	test   $0x3,%cl
  800e33:	75 0a                	jne    800e3f <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800e35:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800e38:	89 c7                	mov    %eax,%edi
  800e3a:	fc                   	cld    
  800e3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e3d:	eb 05                	jmp    800e44 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e3f:	89 c7                	mov    %eax,%edi
  800e41:	fc                   	cld    
  800e42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e44:	5e                   	pop    %esi
  800e45:	5f                   	pop    %edi
  800e46:	5d                   	pop    %ebp
  800e47:	c3                   	ret    

00800e48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e48:	55                   	push   %ebp
  800e49:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800e4b:	ff 75 10             	pushl  0x10(%ebp)
  800e4e:	ff 75 0c             	pushl  0xc(%ebp)
  800e51:	ff 75 08             	pushl  0x8(%ebp)
  800e54:	e8 87 ff ff ff       	call   800de0 <memmove>
}
  800e59:	c9                   	leave  
  800e5a:	c3                   	ret    

00800e5b <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e5b:	55                   	push   %ebp
  800e5c:	89 e5                	mov    %esp,%ebp
  800e5e:	56                   	push   %esi
  800e5f:	53                   	push   %ebx
  800e60:	8b 45 08             	mov    0x8(%ebp),%eax
  800e63:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e66:	89 c6                	mov    %eax,%esi
  800e68:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e6b:	eb 1a                	jmp    800e87 <memcmp+0x2c>
		if (*s1 != *s2)
  800e6d:	0f b6 08             	movzbl (%eax),%ecx
  800e70:	0f b6 1a             	movzbl (%edx),%ebx
  800e73:	38 d9                	cmp    %bl,%cl
  800e75:	74 0a                	je     800e81 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800e77:	0f b6 c1             	movzbl %cl,%eax
  800e7a:	0f b6 db             	movzbl %bl,%ebx
  800e7d:	29 d8                	sub    %ebx,%eax
  800e7f:	eb 0f                	jmp    800e90 <memcmp+0x35>
		s1++, s2++;
  800e81:	83 c0 01             	add    $0x1,%eax
  800e84:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e87:	39 f0                	cmp    %esi,%eax
  800e89:	75 e2                	jne    800e6d <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5d                   	pop    %ebp
  800e93:	c3                   	ret    

00800e94 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800e9d:	89 c2                	mov    %eax,%edx
  800e9f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ea2:	eb 07                	jmp    800eab <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ea4:	38 08                	cmp    %cl,(%eax)
  800ea6:	74 07                	je     800eaf <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ea8:	83 c0 01             	add    $0x1,%eax
  800eab:	39 d0                	cmp    %edx,%eax
  800ead:	72 f5                	jb     800ea4 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	57                   	push   %edi
  800eb5:	56                   	push   %esi
  800eb6:	53                   	push   %ebx
  800eb7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ebd:	eb 03                	jmp    800ec2 <strtol+0x11>
		s++;
  800ebf:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ec2:	0f b6 01             	movzbl (%ecx),%eax
  800ec5:	3c 09                	cmp    $0x9,%al
  800ec7:	74 f6                	je     800ebf <strtol+0xe>
  800ec9:	3c 20                	cmp    $0x20,%al
  800ecb:	74 f2                	je     800ebf <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ecd:	3c 2b                	cmp    $0x2b,%al
  800ecf:	75 0a                	jne    800edb <strtol+0x2a>
		s++;
  800ed1:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ed4:	bf 00 00 00 00       	mov    $0x0,%edi
  800ed9:	eb 10                	jmp    800eeb <strtol+0x3a>
  800edb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ee0:	3c 2d                	cmp    $0x2d,%al
  800ee2:	75 07                	jne    800eeb <strtol+0x3a>
		s++, neg = 1;
  800ee4:	8d 49 01             	lea    0x1(%ecx),%ecx
  800ee7:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800eeb:	85 db                	test   %ebx,%ebx
  800eed:	0f 94 c0             	sete   %al
  800ef0:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ef6:	75 19                	jne    800f11 <strtol+0x60>
  800ef8:	80 39 30             	cmpb   $0x30,(%ecx)
  800efb:	75 14                	jne    800f11 <strtol+0x60>
  800efd:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f01:	0f 85 8a 00 00 00    	jne    800f91 <strtol+0xe0>
		s += 2, base = 16;
  800f07:	83 c1 02             	add    $0x2,%ecx
  800f0a:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f0f:	eb 16                	jmp    800f27 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800f11:	84 c0                	test   %al,%al
  800f13:	74 12                	je     800f27 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f15:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f1a:	80 39 30             	cmpb   $0x30,(%ecx)
  800f1d:	75 08                	jne    800f27 <strtol+0x76>
		s++, base = 8;
  800f1f:	83 c1 01             	add    $0x1,%ecx
  800f22:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800f27:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2c:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f2f:	0f b6 11             	movzbl (%ecx),%edx
  800f32:	8d 72 d0             	lea    -0x30(%edx),%esi
  800f35:	89 f3                	mov    %esi,%ebx
  800f37:	80 fb 09             	cmp    $0x9,%bl
  800f3a:	77 08                	ja     800f44 <strtol+0x93>
			dig = *s - '0';
  800f3c:	0f be d2             	movsbl %dl,%edx
  800f3f:	83 ea 30             	sub    $0x30,%edx
  800f42:	eb 22                	jmp    800f66 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800f44:	8d 72 9f             	lea    -0x61(%edx),%esi
  800f47:	89 f3                	mov    %esi,%ebx
  800f49:	80 fb 19             	cmp    $0x19,%bl
  800f4c:	77 08                	ja     800f56 <strtol+0xa5>
			dig = *s - 'a' + 10;
  800f4e:	0f be d2             	movsbl %dl,%edx
  800f51:	83 ea 57             	sub    $0x57,%edx
  800f54:	eb 10                	jmp    800f66 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800f56:	8d 72 bf             	lea    -0x41(%edx),%esi
  800f59:	89 f3                	mov    %esi,%ebx
  800f5b:	80 fb 19             	cmp    $0x19,%bl
  800f5e:	77 16                	ja     800f76 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800f60:	0f be d2             	movsbl %dl,%edx
  800f63:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800f66:	3b 55 10             	cmp    0x10(%ebp),%edx
  800f69:	7d 0f                	jge    800f7a <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800f6b:	83 c1 01             	add    $0x1,%ecx
  800f6e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800f72:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800f74:	eb b9                	jmp    800f2f <strtol+0x7e>
  800f76:	89 c2                	mov    %eax,%edx
  800f78:	eb 02                	jmp    800f7c <strtol+0xcb>
  800f7a:	89 c2                	mov    %eax,%edx

	if (endptr)
  800f7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800f80:	74 05                	je     800f87 <strtol+0xd6>
		*endptr = (char *) s;
  800f82:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f85:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800f87:	85 ff                	test   %edi,%edi
  800f89:	74 0c                	je     800f97 <strtol+0xe6>
  800f8b:	89 d0                	mov    %edx,%eax
  800f8d:	f7 d8                	neg    %eax
  800f8f:	eb 06                	jmp    800f97 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f91:	84 c0                	test   %al,%al
  800f93:	75 8a                	jne    800f1f <strtol+0x6e>
  800f95:	eb 90                	jmp    800f27 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800f97:	5b                   	pop    %ebx
  800f98:	5e                   	pop    %esi
  800f99:	5f                   	pop    %edi
  800f9a:	5d                   	pop    %ebp
  800f9b:	c3                   	ret    

00800f9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800faa:	8b 55 08             	mov    0x8(%ebp),%edx
  800fad:	89 c3                	mov    %eax,%ebx
  800faf:	89 c7                	mov    %eax,%edi
  800fb1:	89 c6                	mov    %eax,%esi
  800fb3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800fb5:	5b                   	pop    %ebx
  800fb6:	5e                   	pop    %esi
  800fb7:	5f                   	pop    %edi
  800fb8:	5d                   	pop    %ebp
  800fb9:	c3                   	ret    

00800fba <sys_cgetc>:

int
sys_cgetc(void)
{
  800fba:	55                   	push   %ebp
  800fbb:	89 e5                	mov    %esp,%ebp
  800fbd:	57                   	push   %edi
  800fbe:	56                   	push   %esi
  800fbf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc0:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc5:	b8 01 00 00 00       	mov    $0x1,%eax
  800fca:	89 d1                	mov    %edx,%ecx
  800fcc:	89 d3                	mov    %edx,%ebx
  800fce:	89 d7                	mov    %edx,%edi
  800fd0:	89 d6                	mov    %edx,%esi
  800fd2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5f                   	pop    %edi
  800fd7:	5d                   	pop    %ebp
  800fd8:	c3                   	ret    

00800fd9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	53                   	push   %ebx
  800fdf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fe2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe7:	b8 03 00 00 00       	mov    $0x3,%eax
  800fec:	8b 55 08             	mov    0x8(%ebp),%edx
  800fef:	89 cb                	mov    %ecx,%ebx
  800ff1:	89 cf                	mov    %ecx,%edi
  800ff3:	89 ce                	mov    %ecx,%esi
  800ff5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	7e 17                	jle    801012 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	50                   	push   %eax
  800fff:	6a 03                	push   $0x3
  801001:	68 1f 28 80 00       	push   $0x80281f
  801006:	6a 23                	push   $0x23
  801008:	68 3c 28 80 00       	push   $0x80283c
  80100d:	e8 df f5 ff ff       	call   8005f1 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801012:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801015:	5b                   	pop    %ebx
  801016:	5e                   	pop    %esi
  801017:	5f                   	pop    %edi
  801018:	5d                   	pop    %ebp
  801019:	c3                   	ret    

0080101a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80101a:	55                   	push   %ebp
  80101b:	89 e5                	mov    %esp,%ebp
  80101d:	57                   	push   %edi
  80101e:	56                   	push   %esi
  80101f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801020:	ba 00 00 00 00       	mov    $0x0,%edx
  801025:	b8 02 00 00 00       	mov    $0x2,%eax
  80102a:	89 d1                	mov    %edx,%ecx
  80102c:	89 d3                	mov    %edx,%ebx
  80102e:	89 d7                	mov    %edx,%edi
  801030:	89 d6                	mov    %edx,%esi
  801032:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_yield>:

void
sys_yield(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103f:	ba 00 00 00 00       	mov    $0x0,%edx
  801044:	b8 0b 00 00 00       	mov    $0xb,%eax
  801049:	89 d1                	mov    %edx,%ecx
  80104b:	89 d3                	mov    %edx,%ebx
  80104d:	89 d7                	mov    %edx,%edi
  80104f:	89 d6                	mov    %edx,%esi
  801051:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	be 00 00 00 00       	mov    $0x0,%esi
  801066:	b8 04 00 00 00       	mov    $0x4,%eax
  80106b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801074:	89 f7                	mov    %esi,%edi
  801076:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801078:	85 c0                	test   %eax,%eax
  80107a:	7e 17                	jle    801093 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107c:	83 ec 0c             	sub    $0xc,%esp
  80107f:	50                   	push   %eax
  801080:	6a 04                	push   $0x4
  801082:	68 1f 28 80 00       	push   $0x80281f
  801087:	6a 23                	push   $0x23
  801089:	68 3c 28 80 00       	push   $0x80283c
  80108e:	e8 5e f5 ff ff       	call   8005f1 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801096:	5b                   	pop    %ebx
  801097:	5e                   	pop    %esi
  801098:	5f                   	pop    %edi
  801099:	5d                   	pop    %ebp
  80109a:	c3                   	ret    

0080109b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8010a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8010af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8010b5:	8b 75 18             	mov    0x18(%ebp),%esi
  8010b8:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	7e 17                	jle    8010d5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	50                   	push   %eax
  8010c2:	6a 05                	push   $0x5
  8010c4:	68 1f 28 80 00       	push   $0x80281f
  8010c9:	6a 23                	push   $0x23
  8010cb:	68 3c 28 80 00       	push   $0x80283c
  8010d0:	e8 1c f5 ff ff       	call   8005f1 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d8:	5b                   	pop    %ebx
  8010d9:	5e                   	pop    %esi
  8010da:	5f                   	pop    %edi
  8010db:	5d                   	pop    %ebp
  8010dc:	c3                   	ret    

008010dd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	57                   	push   %edi
  8010e1:	56                   	push   %esi
  8010e2:	53                   	push   %ebx
  8010e3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8010f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f6:	89 df                	mov    %ebx,%edi
  8010f8:	89 de                	mov    %ebx,%esi
  8010fa:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010fc:	85 c0                	test   %eax,%eax
  8010fe:	7e 17                	jle    801117 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801100:	83 ec 0c             	sub    $0xc,%esp
  801103:	50                   	push   %eax
  801104:	6a 06                	push   $0x6
  801106:	68 1f 28 80 00       	push   $0x80281f
  80110b:	6a 23                	push   $0x23
  80110d:	68 3c 28 80 00       	push   $0x80283c
  801112:	e8 da f4 ff ff       	call   8005f1 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801117:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111a:	5b                   	pop    %ebx
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    

0080111f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801128:	bb 00 00 00 00       	mov    $0x0,%ebx
  80112d:	b8 08 00 00 00       	mov    $0x8,%eax
  801132:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801135:	8b 55 08             	mov    0x8(%ebp),%edx
  801138:	89 df                	mov    %ebx,%edi
  80113a:	89 de                	mov    %ebx,%esi
  80113c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80113e:	85 c0                	test   %eax,%eax
  801140:	7e 17                	jle    801159 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	50                   	push   %eax
  801146:	6a 08                	push   $0x8
  801148:	68 1f 28 80 00       	push   $0x80281f
  80114d:	6a 23                	push   $0x23
  80114f:	68 3c 28 80 00       	push   $0x80283c
  801154:	e8 98 f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801159:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80115c:	5b                   	pop    %ebx
  80115d:	5e                   	pop    %esi
  80115e:	5f                   	pop    %edi
  80115f:	5d                   	pop    %ebp
  801160:	c3                   	ret    

00801161 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	57                   	push   %edi
  801165:	56                   	push   %esi
  801166:	53                   	push   %ebx
  801167:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80116a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116f:	b8 09 00 00 00       	mov    $0x9,%eax
  801174:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801177:	8b 55 08             	mov    0x8(%ebp),%edx
  80117a:	89 df                	mov    %ebx,%edi
  80117c:	89 de                	mov    %ebx,%esi
  80117e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801180:	85 c0                	test   %eax,%eax
  801182:	7e 17                	jle    80119b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	50                   	push   %eax
  801188:	6a 09                	push   $0x9
  80118a:	68 1f 28 80 00       	push   $0x80281f
  80118f:	6a 23                	push   $0x23
  801191:	68 3c 28 80 00       	push   $0x80283c
  801196:	e8 56 f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80119b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119e:	5b                   	pop    %ebx
  80119f:	5e                   	pop    %esi
  8011a0:	5f                   	pop    %edi
  8011a1:	5d                   	pop    %ebp
  8011a2:	c3                   	ret    

008011a3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8011a3:	55                   	push   %ebp
  8011a4:	89 e5                	mov    %esp,%ebp
  8011a6:	57                   	push   %edi
  8011a7:	56                   	push   %esi
  8011a8:	53                   	push   %ebx
  8011a9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ac:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8011b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bc:	89 df                	mov    %ebx,%edi
  8011be:	89 de                	mov    %ebx,%esi
  8011c0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	7e 17                	jle    8011dd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c6:	83 ec 0c             	sub    $0xc,%esp
  8011c9:	50                   	push   %eax
  8011ca:	6a 0a                	push   $0xa
  8011cc:	68 1f 28 80 00       	push   $0x80281f
  8011d1:	6a 23                	push   $0x23
  8011d3:	68 3c 28 80 00       	push   $0x80283c
  8011d8:	e8 14 f4 ff ff       	call   8005f1 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8011dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e0:	5b                   	pop    %ebx
  8011e1:	5e                   	pop    %esi
  8011e2:	5f                   	pop    %edi
  8011e3:	5d                   	pop    %ebp
  8011e4:	c3                   	ret    

008011e5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011eb:	be 00 00 00 00       	mov    $0x0,%esi
  8011f0:	b8 0c 00 00 00       	mov    $0xc,%eax
  8011f5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011fe:	8b 7d 14             	mov    0x14(%ebp),%edi
  801201:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5f                   	pop    %edi
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	57                   	push   %edi
  80120c:	56                   	push   %esi
  80120d:	53                   	push   %ebx
  80120e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801211:	b9 00 00 00 00       	mov    $0x0,%ecx
  801216:	b8 0d 00 00 00       	mov    $0xd,%eax
  80121b:	8b 55 08             	mov    0x8(%ebp),%edx
  80121e:	89 cb                	mov    %ecx,%ebx
  801220:	89 cf                	mov    %ecx,%edi
  801222:	89 ce                	mov    %ecx,%esi
  801224:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801226:	85 c0                	test   %eax,%eax
  801228:	7e 17                	jle    801241 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80122a:	83 ec 0c             	sub    $0xc,%esp
  80122d:	50                   	push   %eax
  80122e:	6a 0d                	push   $0xd
  801230:	68 1f 28 80 00       	push   $0x80281f
  801235:	6a 23                	push   $0x23
  801237:	68 3c 28 80 00       	push   $0x80283c
  80123c:	e8 b0 f3 ff ff       	call   8005f1 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <sys_gettime>:

int sys_gettime(void)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80124f:	ba 00 00 00 00       	mov    $0x0,%edx
  801254:	b8 0e 00 00 00       	mov    $0xe,%eax
  801259:	89 d1                	mov    %edx,%ecx
  80125b:	89 d3                	mov    %edx,%ebx
  80125d:	89 d7                	mov    %edx,%edi
  80125f:	89 d6                	mov    %edx,%esi
  801261:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  80126e:	83 3d b4 40 80 00 00 	cmpl   $0x0,0x8040b4
  801275:	75 2c                	jne    8012a3 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  801277:	83 ec 04             	sub    $0x4,%esp
  80127a:	6a 07                	push   $0x7
  80127c:	68 00 f0 7f ee       	push   $0xee7ff000
  801281:	6a 00                	push   $0x0
  801283:	e8 d0 fd ff ff       	call   801058 <sys_page_alloc>
  801288:	83 c4 10             	add    $0x10,%esp
  80128b:	85 c0                	test   %eax,%eax
  80128d:	79 14                	jns    8012a3 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  80128f:	83 ec 04             	sub    $0x4,%esp
  801292:	68 4c 28 80 00       	push   $0x80284c
  801297:	6a 1f                	push   $0x1f
  801299:	68 ae 28 80 00       	push   $0x8028ae
  80129e:	e8 4e f3 ff ff       	call   8005f1 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8012a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012a6:	a3 b4 40 80 00       	mov    %eax,0x8040b4
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  8012ab:	83 ec 08             	sub    $0x8,%esp
  8012ae:	68 d7 12 80 00       	push   $0x8012d7
  8012b3:	6a 00                	push   $0x0
  8012b5:	e8 e9 fe ff ff       	call   8011a3 <sys_env_set_pgfault_upcall>
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	85 c0                	test   %eax,%eax
  8012bf:	79 14                	jns    8012d5 <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  8012c1:	83 ec 04             	sub    $0x4,%esp
  8012c4:	68 78 28 80 00       	push   $0x802878
  8012c9:	6a 25                	push   $0x25
  8012cb:	68 ae 28 80 00       	push   $0x8028ae
  8012d0:	e8 1c f3 ff ff       	call   8005f1 <_panic>
}
  8012d5:	c9                   	leave  
  8012d6:	c3                   	ret    

008012d7 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8012d7:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8012d8:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	call *%eax
  8012dd:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8012df:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  8012e2:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  8012e4:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  8012e8:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  8012ec:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  8012ed:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  8012f0:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  8012f2:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  8012f5:	83 c4 04             	add    $0x4,%esp
	popal 
  8012f8:	61                   	popa   
	addl $4, %esp 
  8012f9:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  8012fc:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  8012fd:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  8012fe:	c3                   	ret    

008012ff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	05 00 00 00 30       	add    $0x30000000,%eax
  80130a:	c1 e8 0c             	shr    $0xc,%eax
}
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    

0080130f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80131a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80131f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801324:	5d                   	pop    %ebp
  801325:	c3                   	ret    

00801326 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801326:	55                   	push   %ebp
  801327:	89 e5                	mov    %esp,%ebp
  801329:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801331:	89 c2                	mov    %eax,%edx
  801333:	c1 ea 16             	shr    $0x16,%edx
  801336:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80133d:	f6 c2 01             	test   $0x1,%dl
  801340:	74 11                	je     801353 <fd_alloc+0x2d>
  801342:	89 c2                	mov    %eax,%edx
  801344:	c1 ea 0c             	shr    $0xc,%edx
  801347:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80134e:	f6 c2 01             	test   $0x1,%dl
  801351:	75 09                	jne    80135c <fd_alloc+0x36>
			*fd_store = fd;
  801353:	89 01                	mov    %eax,(%ecx)
			return 0;
  801355:	b8 00 00 00 00       	mov    $0x0,%eax
  80135a:	eb 17                	jmp    801373 <fd_alloc+0x4d>
  80135c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801361:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801366:	75 c9                	jne    801331 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801368:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80136e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801373:	5d                   	pop    %ebp
  801374:	c3                   	ret    

00801375 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801375:	55                   	push   %ebp
  801376:	89 e5                	mov    %esp,%ebp
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80137b:	83 f8 1f             	cmp    $0x1f,%eax
  80137e:	77 36                	ja     8013b6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801380:	c1 e0 0c             	shl    $0xc,%eax
  801383:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801388:	89 c2                	mov    %eax,%edx
  80138a:	c1 ea 16             	shr    $0x16,%edx
  80138d:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801394:	f6 c2 01             	test   $0x1,%dl
  801397:	74 24                	je     8013bd <fd_lookup+0x48>
  801399:	89 c2                	mov    %eax,%edx
  80139b:	c1 ea 0c             	shr    $0xc,%edx
  80139e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013a5:	f6 c2 01             	test   $0x1,%dl
  8013a8:	74 1a                	je     8013c4 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8013aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ad:	89 02                	mov    %eax,(%edx)
	return 0;
  8013af:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b4:	eb 13                	jmp    8013c9 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013bb:	eb 0c                	jmp    8013c9 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8013bd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013c2:	eb 05                	jmp    8013c9 <fd_lookup+0x54>
  8013c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8013c9:	5d                   	pop    %ebp
  8013ca:	c3                   	ret    

008013cb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013cb:	55                   	push   %ebp
  8013cc:	89 e5                	mov    %esp,%ebp
  8013ce:	83 ec 08             	sub    $0x8,%esp
  8013d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013d4:	ba 38 29 80 00       	mov    $0x802938,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013d9:	eb 13                	jmp    8013ee <dev_lookup+0x23>
  8013db:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8013de:	39 08                	cmp    %ecx,(%eax)
  8013e0:	75 0c                	jne    8013ee <dev_lookup+0x23>
			*dev = devtab[i];
  8013e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e5:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ec:	eb 2e                	jmp    80141c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8013ee:	8b 02                	mov    (%edx),%eax
  8013f0:	85 c0                	test   %eax,%eax
  8013f2:	75 e7                	jne    8013db <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013f4:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8013f9:	8b 40 48             	mov    0x48(%eax),%eax
  8013fc:	83 ec 04             	sub    $0x4,%esp
  8013ff:	51                   	push   %ecx
  801400:	50                   	push   %eax
  801401:	68 bc 28 80 00       	push   $0x8028bc
  801406:	e8 bf f2 ff ff       	call   8006ca <cprintf>
	*dev = 0;
  80140b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80141c:	c9                   	leave  
  80141d:	c3                   	ret    

0080141e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	56                   	push   %esi
  801422:	53                   	push   %ebx
  801423:	83 ec 10             	sub    $0x10,%esp
  801426:	8b 75 08             	mov    0x8(%ebp),%esi
  801429:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80142c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142f:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801430:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801436:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801439:	50                   	push   %eax
  80143a:	e8 36 ff ff ff       	call   801375 <fd_lookup>
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	85 c0                	test   %eax,%eax
  801444:	78 05                	js     80144b <fd_close+0x2d>
	    || fd != fd2)
  801446:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801449:	74 0b                	je     801456 <fd_close+0x38>
		return (must_exist ? r : 0);
  80144b:	80 fb 01             	cmp    $0x1,%bl
  80144e:	19 d2                	sbb    %edx,%edx
  801450:	f7 d2                	not    %edx
  801452:	21 d0                	and    %edx,%eax
  801454:	eb 41                	jmp    801497 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801456:	83 ec 08             	sub    $0x8,%esp
  801459:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80145c:	50                   	push   %eax
  80145d:	ff 36                	pushl  (%esi)
  80145f:	e8 67 ff ff ff       	call   8013cb <dev_lookup>
  801464:	89 c3                	mov    %eax,%ebx
  801466:	83 c4 10             	add    $0x10,%esp
  801469:	85 c0                	test   %eax,%eax
  80146b:	78 1a                	js     801487 <fd_close+0x69>
		if (dev->dev_close)
  80146d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801470:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801473:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801478:	85 c0                	test   %eax,%eax
  80147a:	74 0b                	je     801487 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80147c:	83 ec 0c             	sub    $0xc,%esp
  80147f:	56                   	push   %esi
  801480:	ff d0                	call   *%eax
  801482:	89 c3                	mov    %eax,%ebx
  801484:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801487:	83 ec 08             	sub    $0x8,%esp
  80148a:	56                   	push   %esi
  80148b:	6a 00                	push   $0x0
  80148d:	e8 4b fc ff ff       	call   8010dd <sys_page_unmap>
	return r;
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	89 d8                	mov    %ebx,%eax
}
  801497:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149a:	5b                   	pop    %ebx
  80149b:	5e                   	pop    %esi
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
  8014a1:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a7:	50                   	push   %eax
  8014a8:	ff 75 08             	pushl  0x8(%ebp)
  8014ab:	e8 c5 fe ff ff       	call   801375 <fd_lookup>
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	83 c4 08             	add    $0x8,%esp
  8014b5:	85 d2                	test   %edx,%edx
  8014b7:	78 10                	js     8014c9 <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8014b9:	83 ec 08             	sub    $0x8,%esp
  8014bc:	6a 01                	push   $0x1
  8014be:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c1:	e8 58 ff ff ff       	call   80141e <fd_close>
  8014c6:	83 c4 10             	add    $0x10,%esp
}
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <close_all>:

void
close_all(void)
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	53                   	push   %ebx
  8014cf:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014d2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014d7:	83 ec 0c             	sub    $0xc,%esp
  8014da:	53                   	push   %ebx
  8014db:	e8 be ff ff ff       	call   80149e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014e0:	83 c3 01             	add    $0x1,%ebx
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	83 fb 20             	cmp    $0x20,%ebx
  8014e9:	75 ec                	jne    8014d7 <close_all+0xc>
		close(i);
}
  8014eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ee:	c9                   	leave  
  8014ef:	c3                   	ret    

008014f0 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	57                   	push   %edi
  8014f4:	56                   	push   %esi
  8014f5:	53                   	push   %ebx
  8014f6:	83 ec 2c             	sub    $0x2c,%esp
  8014f9:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014fc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	ff 75 08             	pushl  0x8(%ebp)
  801503:	e8 6d fe ff ff       	call   801375 <fd_lookup>
  801508:	89 c2                	mov    %eax,%edx
  80150a:	83 c4 08             	add    $0x8,%esp
  80150d:	85 d2                	test   %edx,%edx
  80150f:	0f 88 c1 00 00 00    	js     8015d6 <dup+0xe6>
		return r;
	close(newfdnum);
  801515:	83 ec 0c             	sub    $0xc,%esp
  801518:	56                   	push   %esi
  801519:	e8 80 ff ff ff       	call   80149e <close>

	newfd = INDEX2FD(newfdnum);
  80151e:	89 f3                	mov    %esi,%ebx
  801520:	c1 e3 0c             	shl    $0xc,%ebx
  801523:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801529:	83 c4 04             	add    $0x4,%esp
  80152c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80152f:	e8 db fd ff ff       	call   80130f <fd2data>
  801534:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801536:	89 1c 24             	mov    %ebx,(%esp)
  801539:	e8 d1 fd ff ff       	call   80130f <fd2data>
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801544:	89 f8                	mov    %edi,%eax
  801546:	c1 e8 16             	shr    $0x16,%eax
  801549:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801550:	a8 01                	test   $0x1,%al
  801552:	74 37                	je     80158b <dup+0x9b>
  801554:	89 f8                	mov    %edi,%eax
  801556:	c1 e8 0c             	shr    $0xc,%eax
  801559:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801560:	f6 c2 01             	test   $0x1,%dl
  801563:	74 26                	je     80158b <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801565:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	25 07 0e 00 00       	and    $0xe07,%eax
  801574:	50                   	push   %eax
  801575:	ff 75 d4             	pushl  -0x2c(%ebp)
  801578:	6a 00                	push   $0x0
  80157a:	57                   	push   %edi
  80157b:	6a 00                	push   $0x0
  80157d:	e8 19 fb ff ff       	call   80109b <sys_page_map>
  801582:	89 c7                	mov    %eax,%edi
  801584:	83 c4 20             	add    $0x20,%esp
  801587:	85 c0                	test   %eax,%eax
  801589:	78 2e                	js     8015b9 <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80158b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80158e:	89 d0                	mov    %edx,%eax
  801590:	c1 e8 0c             	shr    $0xc,%eax
  801593:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80159a:	83 ec 0c             	sub    $0xc,%esp
  80159d:	25 07 0e 00 00       	and    $0xe07,%eax
  8015a2:	50                   	push   %eax
  8015a3:	53                   	push   %ebx
  8015a4:	6a 00                	push   $0x0
  8015a6:	52                   	push   %edx
  8015a7:	6a 00                	push   $0x0
  8015a9:	e8 ed fa ff ff       	call   80109b <sys_page_map>
  8015ae:	89 c7                	mov    %eax,%edi
  8015b0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8015b3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b5:	85 ff                	test   %edi,%edi
  8015b7:	79 1d                	jns    8015d6 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	6a 00                	push   $0x0
  8015bf:	e8 19 fb ff ff       	call   8010dd <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015c4:	83 c4 08             	add    $0x8,%esp
  8015c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8015ca:	6a 00                	push   $0x0
  8015cc:	e8 0c fb ff ff       	call   8010dd <sys_page_unmap>
	return r;
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	89 f8                	mov    %edi,%eax
}
  8015d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5f                   	pop    %edi
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015de:	55                   	push   %ebp
  8015df:	89 e5                	mov    %esp,%ebp
  8015e1:	53                   	push   %ebx
  8015e2:	83 ec 14             	sub    $0x14,%esp
  8015e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015eb:	50                   	push   %eax
  8015ec:	53                   	push   %ebx
  8015ed:	e8 83 fd ff ff       	call   801375 <fd_lookup>
  8015f2:	83 c4 08             	add    $0x8,%esp
  8015f5:	89 c2                	mov    %eax,%edx
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 6d                	js     801668 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801601:	50                   	push   %eax
  801602:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801605:	ff 30                	pushl  (%eax)
  801607:	e8 bf fd ff ff       	call   8013cb <dev_lookup>
  80160c:	83 c4 10             	add    $0x10,%esp
  80160f:	85 c0                	test   %eax,%eax
  801611:	78 4c                	js     80165f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801613:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801616:	8b 42 08             	mov    0x8(%edx),%eax
  801619:	83 e0 03             	and    $0x3,%eax
  80161c:	83 f8 01             	cmp    $0x1,%eax
  80161f:	75 21                	jne    801642 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801621:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801626:	8b 40 48             	mov    0x48(%eax),%eax
  801629:	83 ec 04             	sub    $0x4,%esp
  80162c:	53                   	push   %ebx
  80162d:	50                   	push   %eax
  80162e:	68 fd 28 80 00       	push   $0x8028fd
  801633:	e8 92 f0 ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801640:	eb 26                	jmp    801668 <read+0x8a>
	}
	if (!dev->dev_read)
  801642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801645:	8b 40 08             	mov    0x8(%eax),%eax
  801648:	85 c0                	test   %eax,%eax
  80164a:	74 17                	je     801663 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80164c:	83 ec 04             	sub    $0x4,%esp
  80164f:	ff 75 10             	pushl  0x10(%ebp)
  801652:	ff 75 0c             	pushl  0xc(%ebp)
  801655:	52                   	push   %edx
  801656:	ff d0                	call   *%eax
  801658:	89 c2                	mov    %eax,%edx
  80165a:	83 c4 10             	add    $0x10,%esp
  80165d:	eb 09                	jmp    801668 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165f:	89 c2                	mov    %eax,%edx
  801661:	eb 05                	jmp    801668 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801663:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801668:	89 d0                	mov    %edx,%eax
  80166a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166d:	c9                   	leave  
  80166e:	c3                   	ret    

0080166f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80166f:	55                   	push   %ebp
  801670:	89 e5                	mov    %esp,%ebp
  801672:	57                   	push   %edi
  801673:	56                   	push   %esi
  801674:	53                   	push   %ebx
  801675:	83 ec 0c             	sub    $0xc,%esp
  801678:	8b 7d 08             	mov    0x8(%ebp),%edi
  80167b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80167e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801683:	eb 21                	jmp    8016a6 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801685:	83 ec 04             	sub    $0x4,%esp
  801688:	89 f0                	mov    %esi,%eax
  80168a:	29 d8                	sub    %ebx,%eax
  80168c:	50                   	push   %eax
  80168d:	89 d8                	mov    %ebx,%eax
  80168f:	03 45 0c             	add    0xc(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	57                   	push   %edi
  801694:	e8 45 ff ff ff       	call   8015de <read>
		if (m < 0)
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 0c                	js     8016ac <readn+0x3d>
			return m;
		if (m == 0)
  8016a0:	85 c0                	test   %eax,%eax
  8016a2:	74 06                	je     8016aa <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016a4:	01 c3                	add    %eax,%ebx
  8016a6:	39 f3                	cmp    %esi,%ebx
  8016a8:	72 db                	jb     801685 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8016aa:	89 d8                	mov    %ebx,%eax
}
  8016ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016af:	5b                   	pop    %ebx
  8016b0:	5e                   	pop    %esi
  8016b1:	5f                   	pop    %edi
  8016b2:	5d                   	pop    %ebp
  8016b3:	c3                   	ret    

008016b4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8016b4:	55                   	push   %ebp
  8016b5:	89 e5                	mov    %esp,%ebp
  8016b7:	53                   	push   %ebx
  8016b8:	83 ec 14             	sub    $0x14,%esp
  8016bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c1:	50                   	push   %eax
  8016c2:	53                   	push   %ebx
  8016c3:	e8 ad fc ff ff       	call   801375 <fd_lookup>
  8016c8:	83 c4 08             	add    $0x8,%esp
  8016cb:	89 c2                	mov    %eax,%edx
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 68                	js     801739 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d7:	50                   	push   %eax
  8016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016db:	ff 30                	pushl  (%eax)
  8016dd:	e8 e9 fc ff ff       	call   8013cb <dev_lookup>
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	85 c0                	test   %eax,%eax
  8016e7:	78 47                	js     801730 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016ec:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016f0:	75 21                	jne    801713 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016f2:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  8016f7:	8b 40 48             	mov    0x48(%eax),%eax
  8016fa:	83 ec 04             	sub    $0x4,%esp
  8016fd:	53                   	push   %ebx
  8016fe:	50                   	push   %eax
  8016ff:	68 19 29 80 00       	push   $0x802919
  801704:	e8 c1 ef ff ff       	call   8006ca <cprintf>
		return -E_INVAL;
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801711:	eb 26                	jmp    801739 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801713:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801716:	8b 52 0c             	mov    0xc(%edx),%edx
  801719:	85 d2                	test   %edx,%edx
  80171b:	74 17                	je     801734 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80171d:	83 ec 04             	sub    $0x4,%esp
  801720:	ff 75 10             	pushl  0x10(%ebp)
  801723:	ff 75 0c             	pushl  0xc(%ebp)
  801726:	50                   	push   %eax
  801727:	ff d2                	call   *%edx
  801729:	89 c2                	mov    %eax,%edx
  80172b:	83 c4 10             	add    $0x10,%esp
  80172e:	eb 09                	jmp    801739 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801730:	89 c2                	mov    %eax,%edx
  801732:	eb 05                	jmp    801739 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801734:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801739:	89 d0                	mov    %edx,%eax
  80173b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173e:	c9                   	leave  
  80173f:	c3                   	ret    

00801740 <seek>:

int
seek(int fdnum, off_t offset)
{
  801740:	55                   	push   %ebp
  801741:	89 e5                	mov    %esp,%ebp
  801743:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801746:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801749:	50                   	push   %eax
  80174a:	ff 75 08             	pushl  0x8(%ebp)
  80174d:	e8 23 fc ff ff       	call   801375 <fd_lookup>
  801752:	83 c4 08             	add    $0x8,%esp
  801755:	85 c0                	test   %eax,%eax
  801757:	78 0e                	js     801767 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801759:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80175c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80175f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801762:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801767:	c9                   	leave  
  801768:	c3                   	ret    

00801769 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801769:	55                   	push   %ebp
  80176a:	89 e5                	mov    %esp,%ebp
  80176c:	53                   	push   %ebx
  80176d:	83 ec 14             	sub    $0x14,%esp
  801770:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801773:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801776:	50                   	push   %eax
  801777:	53                   	push   %ebx
  801778:	e8 f8 fb ff ff       	call   801375 <fd_lookup>
  80177d:	83 c4 08             	add    $0x8,%esp
  801780:	89 c2                	mov    %eax,%edx
  801782:	85 c0                	test   %eax,%eax
  801784:	78 65                	js     8017eb <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801786:	83 ec 08             	sub    $0x8,%esp
  801789:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178c:	50                   	push   %eax
  80178d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801790:	ff 30                	pushl  (%eax)
  801792:	e8 34 fc ff ff       	call   8013cb <dev_lookup>
  801797:	83 c4 10             	add    $0x10,%esp
  80179a:	85 c0                	test   %eax,%eax
  80179c:	78 44                	js     8017e2 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80179e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017a1:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017a5:	75 21                	jne    8017c8 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8017a7:	a1 b0 40 80 00       	mov    0x8040b0,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017ac:	8b 40 48             	mov    0x48(%eax),%eax
  8017af:	83 ec 04             	sub    $0x4,%esp
  8017b2:	53                   	push   %ebx
  8017b3:	50                   	push   %eax
  8017b4:	68 dc 28 80 00       	push   $0x8028dc
  8017b9:	e8 0c ef ff ff       	call   8006ca <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017c6:	eb 23                	jmp    8017eb <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8017c8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017cb:	8b 52 18             	mov    0x18(%edx),%edx
  8017ce:	85 d2                	test   %edx,%edx
  8017d0:	74 14                	je     8017e6 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8017d2:	83 ec 08             	sub    $0x8,%esp
  8017d5:	ff 75 0c             	pushl  0xc(%ebp)
  8017d8:	50                   	push   %eax
  8017d9:	ff d2                	call   *%edx
  8017db:	89 c2                	mov    %eax,%edx
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	eb 09                	jmp    8017eb <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e2:	89 c2                	mov    %eax,%edx
  8017e4:	eb 05                	jmp    8017eb <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8017e6:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8017eb:	89 d0                	mov    %edx,%eax
  8017ed:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f0:	c9                   	leave  
  8017f1:	c3                   	ret    

008017f2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017f2:	55                   	push   %ebp
  8017f3:	89 e5                	mov    %esp,%ebp
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 14             	sub    $0x14,%esp
  8017f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017ff:	50                   	push   %eax
  801800:	ff 75 08             	pushl  0x8(%ebp)
  801803:	e8 6d fb ff ff       	call   801375 <fd_lookup>
  801808:	83 c4 08             	add    $0x8,%esp
  80180b:	89 c2                	mov    %eax,%edx
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 58                	js     801869 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801817:	50                   	push   %eax
  801818:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181b:	ff 30                	pushl  (%eax)
  80181d:	e8 a9 fb ff ff       	call   8013cb <dev_lookup>
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	85 c0                	test   %eax,%eax
  801827:	78 37                	js     801860 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801830:	74 32                	je     801864 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801832:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801835:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80183c:	00 00 00 
	stat->st_isdir = 0;
  80183f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801846:	00 00 00 
	stat->st_dev = dev;
  801849:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	53                   	push   %ebx
  801853:	ff 75 f0             	pushl  -0x10(%ebp)
  801856:	ff 50 14             	call   *0x14(%eax)
  801859:	89 c2                	mov    %eax,%edx
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	eb 09                	jmp    801869 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801860:	89 c2                	mov    %eax,%edx
  801862:	eb 05                	jmp    801869 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801864:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801869:	89 d0                	mov    %edx,%eax
  80186b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	56                   	push   %esi
  801874:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801875:	83 ec 08             	sub    $0x8,%esp
  801878:	6a 00                	push   $0x0
  80187a:	ff 75 08             	pushl  0x8(%ebp)
  80187d:	e8 e7 01 00 00       	call   801a69 <open>
  801882:	89 c3                	mov    %eax,%ebx
  801884:	83 c4 10             	add    $0x10,%esp
  801887:	85 db                	test   %ebx,%ebx
  801889:	78 1b                	js     8018a6 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	ff 75 0c             	pushl  0xc(%ebp)
  801891:	53                   	push   %ebx
  801892:	e8 5b ff ff ff       	call   8017f2 <fstat>
  801897:	89 c6                	mov    %eax,%esi
	close(fd);
  801899:	89 1c 24             	mov    %ebx,(%esp)
  80189c:	e8 fd fb ff ff       	call   80149e <close>
	return r;
  8018a1:	83 c4 10             	add    $0x10,%esp
  8018a4:	89 f0                	mov    %esi,%eax
}
  8018a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5e                   	pop    %esi
  8018ab:	5d                   	pop    %ebp
  8018ac:	c3                   	ret    

008018ad <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8018ad:	55                   	push   %ebp
  8018ae:	89 e5                	mov    %esp,%ebp
  8018b0:	56                   	push   %esi
  8018b1:	53                   	push   %ebx
  8018b2:	89 c6                	mov    %eax,%esi
  8018b4:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8018b6:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  8018bd:	75 12                	jne    8018d1 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018bf:	83 ec 0c             	sub    $0xc,%esp
  8018c2:	6a 03                	push   $0x3
  8018c4:	e8 d2 07 00 00       	call   80209b <ipc_find_env>
  8018c9:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  8018ce:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8018d1:	6a 07                	push   $0x7
  8018d3:	68 00 50 80 00       	push   $0x805000
  8018d8:	56                   	push   %esi
  8018d9:	ff 35 ac 40 80 00    	pushl  0x8040ac
  8018df:	e8 66 07 00 00       	call   80204a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018e4:	83 c4 0c             	add    $0xc,%esp
  8018e7:	6a 00                	push   $0x0
  8018e9:	53                   	push   %ebx
  8018ea:	6a 00                	push   $0x0
  8018ec:	e8 f3 06 00 00       	call   801fe4 <ipc_recv>
}
  8018f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	8b 40 0c             	mov    0xc(%eax),%eax
  801904:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801909:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801911:	ba 00 00 00 00       	mov    $0x0,%edx
  801916:	b8 02 00 00 00       	mov    $0x2,%eax
  80191b:	e8 8d ff ff ff       	call   8018ad <fsipc>
}
  801920:	c9                   	leave  
  801921:	c3                   	ret    

00801922 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801928:	8b 45 08             	mov    0x8(%ebp),%eax
  80192b:	8b 40 0c             	mov    0xc(%eax),%eax
  80192e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801933:	ba 00 00 00 00       	mov    $0x0,%edx
  801938:	b8 06 00 00 00       	mov    $0x6,%eax
  80193d:	e8 6b ff ff ff       	call   8018ad <fsipc>
}
  801942:	c9                   	leave  
  801943:	c3                   	ret    

00801944 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801944:	55                   	push   %ebp
  801945:	89 e5                	mov    %esp,%ebp
  801947:	53                   	push   %ebx
  801948:	83 ec 04             	sub    $0x4,%esp
  80194b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80194e:	8b 45 08             	mov    0x8(%ebp),%eax
  801951:	8b 40 0c             	mov    0xc(%eax),%eax
  801954:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801959:	ba 00 00 00 00       	mov    $0x0,%edx
  80195e:	b8 05 00 00 00       	mov    $0x5,%eax
  801963:	e8 45 ff ff ff       	call   8018ad <fsipc>
  801968:	89 c2                	mov    %eax,%edx
  80196a:	85 d2                	test   %edx,%edx
  80196c:	78 2c                	js     80199a <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80196e:	83 ec 08             	sub    $0x8,%esp
  801971:	68 00 50 80 00       	push   $0x805000
  801976:	53                   	push   %ebx
  801977:	e8 d2 f2 ff ff       	call   800c4e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80197c:	a1 80 50 80 00       	mov    0x805080,%eax
  801981:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801987:	a1 84 50 80 00       	mov    0x805084,%eax
  80198c:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801992:	83 c4 10             	add    $0x10,%esp
  801995:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80199a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 08             	sub    $0x8,%esp
  8019a5:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8019a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8019ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8019ae:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8019b4:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8019b9:	76 05                	jbe    8019c0 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8019bb:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8019c0:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8019c5:	83 ec 04             	sub    $0x4,%esp
  8019c8:	50                   	push   %eax
  8019c9:	ff 75 0c             	pushl  0xc(%ebp)
  8019cc:	68 08 50 80 00       	push   $0x805008
  8019d1:	e8 0a f4 ff ff       	call   800de0 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8019d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019db:	b8 04 00 00 00       	mov    $0x4,%eax
  8019e0:	e8 c8 fe ff ff       	call   8018ad <fsipc>
	return write;
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019fa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a00:	ba 00 00 00 00       	mov    $0x0,%edx
  801a05:	b8 03 00 00 00       	mov    $0x3,%eax
  801a0a:	e8 9e fe ff ff       	call   8018ad <fsipc>
  801a0f:	89 c3                	mov    %eax,%ebx
  801a11:	85 c0                	test   %eax,%eax
  801a13:	78 4b                	js     801a60 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801a15:	39 c6                	cmp    %eax,%esi
  801a17:	73 16                	jae    801a2f <devfile_read+0x48>
  801a19:	68 48 29 80 00       	push   $0x802948
  801a1e:	68 4f 29 80 00       	push   $0x80294f
  801a23:	6a 7c                	push   $0x7c
  801a25:	68 64 29 80 00       	push   $0x802964
  801a2a:	e8 c2 eb ff ff       	call   8005f1 <_panic>
	assert(r <= PGSIZE);
  801a2f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a34:	7e 16                	jle    801a4c <devfile_read+0x65>
  801a36:	68 6f 29 80 00       	push   $0x80296f
  801a3b:	68 4f 29 80 00       	push   $0x80294f
  801a40:	6a 7d                	push   $0x7d
  801a42:	68 64 29 80 00       	push   $0x802964
  801a47:	e8 a5 eb ff ff       	call   8005f1 <_panic>
	memmove(buf, &fsipcbuf, r);
  801a4c:	83 ec 04             	sub    $0x4,%esp
  801a4f:	50                   	push   %eax
  801a50:	68 00 50 80 00       	push   $0x805000
  801a55:	ff 75 0c             	pushl  0xc(%ebp)
  801a58:	e8 83 f3 ff ff       	call   800de0 <memmove>
	return r;
  801a5d:	83 c4 10             	add    $0x10,%esp
}
  801a60:	89 d8                	mov    %ebx,%eax
  801a62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a65:	5b                   	pop    %ebx
  801a66:	5e                   	pop    %esi
  801a67:	5d                   	pop    %ebp
  801a68:	c3                   	ret    

00801a69 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a69:	55                   	push   %ebp
  801a6a:	89 e5                	mov    %esp,%ebp
  801a6c:	53                   	push   %ebx
  801a6d:	83 ec 20             	sub    $0x20,%esp
  801a70:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801a73:	53                   	push   %ebx
  801a74:	e8 9c f1 ff ff       	call   800c15 <strlen>
  801a79:	83 c4 10             	add    $0x10,%esp
  801a7c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a81:	7f 67                	jg     801aea <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a83:	83 ec 0c             	sub    $0xc,%esp
  801a86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a89:	50                   	push   %eax
  801a8a:	e8 97 f8 ff ff       	call   801326 <fd_alloc>
  801a8f:	83 c4 10             	add    $0x10,%esp
		return r;
  801a92:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a94:	85 c0                	test   %eax,%eax
  801a96:	78 57                	js     801aef <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a98:	83 ec 08             	sub    $0x8,%esp
  801a9b:	53                   	push   %ebx
  801a9c:	68 00 50 80 00       	push   $0x805000
  801aa1:	e8 a8 f1 ff ff       	call   800c4e <strcpy>
	fsipcbuf.open.req_omode = mode;
  801aa6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801aa9:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801aae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab1:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab6:	e8 f2 fd ff ff       	call   8018ad <fsipc>
  801abb:	89 c3                	mov    %eax,%ebx
  801abd:	83 c4 10             	add    $0x10,%esp
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	79 14                	jns    801ad8 <open+0x6f>
		fd_close(fd, 0);
  801ac4:	83 ec 08             	sub    $0x8,%esp
  801ac7:	6a 00                	push   $0x0
  801ac9:	ff 75 f4             	pushl  -0xc(%ebp)
  801acc:	e8 4d f9 ff ff       	call   80141e <fd_close>
		return r;
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	89 da                	mov    %ebx,%edx
  801ad6:	eb 17                	jmp    801aef <open+0x86>
	}

	return fd2num(fd);
  801ad8:	83 ec 0c             	sub    $0xc,%esp
  801adb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ade:	e8 1c f8 ff ff       	call   8012ff <fd2num>
  801ae3:	89 c2                	mov    %eax,%edx
  801ae5:	83 c4 10             	add    $0x10,%esp
  801ae8:	eb 05                	jmp    801aef <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801aea:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801aef:	89 d0                	mov    %edx,%eax
  801af1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af4:	c9                   	leave  
  801af5:	c3                   	ret    

00801af6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801afc:	ba 00 00 00 00       	mov    $0x0,%edx
  801b01:	b8 08 00 00 00       	mov    $0x8,%eax
  801b06:	e8 a2 fd ff ff       	call   8018ad <fsipc>
}
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    

00801b0d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b0d:	55                   	push   %ebp
  801b0e:	89 e5                	mov    %esp,%ebp
  801b10:	56                   	push   %esi
  801b11:	53                   	push   %ebx
  801b12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b15:	83 ec 0c             	sub    $0xc,%esp
  801b18:	ff 75 08             	pushl  0x8(%ebp)
  801b1b:	e8 ef f7 ff ff       	call   80130f <fd2data>
  801b20:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b22:	83 c4 08             	add    $0x8,%esp
  801b25:	68 7b 29 80 00       	push   $0x80297b
  801b2a:	53                   	push   %ebx
  801b2b:	e8 1e f1 ff ff       	call   800c4e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b30:	8b 56 04             	mov    0x4(%esi),%edx
  801b33:	89 d0                	mov    %edx,%eax
  801b35:	2b 06                	sub    (%esi),%eax
  801b37:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b3d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b44:	00 00 00 
	stat->st_dev = &devpipe;
  801b47:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b4e:	30 80 00 
	return 0;
}
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
  801b56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    

00801b5d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b5d:	55                   	push   %ebp
  801b5e:	89 e5                	mov    %esp,%ebp
  801b60:	53                   	push   %ebx
  801b61:	83 ec 0c             	sub    $0xc,%esp
  801b64:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b67:	53                   	push   %ebx
  801b68:	6a 00                	push   $0x0
  801b6a:	e8 6e f5 ff ff       	call   8010dd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b6f:	89 1c 24             	mov    %ebx,(%esp)
  801b72:	e8 98 f7 ff ff       	call   80130f <fd2data>
  801b77:	83 c4 08             	add    $0x8,%esp
  801b7a:	50                   	push   %eax
  801b7b:	6a 00                	push   $0x0
  801b7d:	e8 5b f5 ff ff       	call   8010dd <sys_page_unmap>
}
  801b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b85:	c9                   	leave  
  801b86:	c3                   	ret    

00801b87 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 1c             	sub    $0x1c,%esp
  801b90:	89 c7                	mov    %eax,%edi
  801b92:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b94:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  801b99:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b9c:	83 ec 0c             	sub    $0xc,%esp
  801b9f:	57                   	push   %edi
  801ba0:	e8 2e 05 00 00       	call   8020d3 <pageref>
  801ba5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ba8:	89 34 24             	mov    %esi,(%esp)
  801bab:	e8 23 05 00 00       	call   8020d3 <pageref>
  801bb0:	83 c4 10             	add    $0x10,%esp
  801bb3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bb6:	0f 94 c0             	sete   %al
  801bb9:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  801bbc:	8b 15 b0 40 80 00    	mov    0x8040b0,%edx
  801bc2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bc5:	39 cb                	cmp    %ecx,%ebx
  801bc7:	74 15                	je     801bde <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  801bc9:	8b 52 58             	mov    0x58(%edx),%edx
  801bcc:	50                   	push   %eax
  801bcd:	52                   	push   %edx
  801bce:	53                   	push   %ebx
  801bcf:	68 88 29 80 00       	push   $0x802988
  801bd4:	e8 f1 ea ff ff       	call   8006ca <cprintf>
  801bd9:	83 c4 10             	add    $0x10,%esp
  801bdc:	eb b6                	jmp    801b94 <_pipeisclosed+0xd>
	}
}
  801bde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801be1:	5b                   	pop    %ebx
  801be2:	5e                   	pop    %esi
  801be3:	5f                   	pop    %edi
  801be4:	5d                   	pop    %ebp
  801be5:	c3                   	ret    

00801be6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	57                   	push   %edi
  801bea:	56                   	push   %esi
  801beb:	53                   	push   %ebx
  801bec:	83 ec 28             	sub    $0x28,%esp
  801bef:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801bf2:	56                   	push   %esi
  801bf3:	e8 17 f7 ff ff       	call   80130f <fd2data>
  801bf8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	bf 00 00 00 00       	mov    $0x0,%edi
  801c02:	eb 4b                	jmp    801c4f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801c04:	89 da                	mov    %ebx,%edx
  801c06:	89 f0                	mov    %esi,%eax
  801c08:	e8 7a ff ff ff       	call   801b87 <_pipeisclosed>
  801c0d:	85 c0                	test   %eax,%eax
  801c0f:	75 48                	jne    801c59 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801c11:	e8 23 f4 ff ff       	call   801039 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c16:	8b 43 04             	mov    0x4(%ebx),%eax
  801c19:	8b 0b                	mov    (%ebx),%ecx
  801c1b:	8d 51 20             	lea    0x20(%ecx),%edx
  801c1e:	39 d0                	cmp    %edx,%eax
  801c20:	73 e2                	jae    801c04 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c25:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c29:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c2c:	89 c2                	mov    %eax,%edx
  801c2e:	c1 fa 1f             	sar    $0x1f,%edx
  801c31:	89 d1                	mov    %edx,%ecx
  801c33:	c1 e9 1b             	shr    $0x1b,%ecx
  801c36:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c39:	83 e2 1f             	and    $0x1f,%edx
  801c3c:	29 ca                	sub    %ecx,%edx
  801c3e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c42:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c46:	83 c0 01             	add    $0x1,%eax
  801c49:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c4c:	83 c7 01             	add    $0x1,%edi
  801c4f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c52:	75 c2                	jne    801c16 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801c54:	8b 45 10             	mov    0x10(%ebp),%eax
  801c57:	eb 05                	jmp    801c5e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c59:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801c5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c61:	5b                   	pop    %ebx
  801c62:	5e                   	pop    %esi
  801c63:	5f                   	pop    %edi
  801c64:	5d                   	pop    %ebp
  801c65:	c3                   	ret    

00801c66 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	57                   	push   %edi
  801c6a:	56                   	push   %esi
  801c6b:	53                   	push   %ebx
  801c6c:	83 ec 18             	sub    $0x18,%esp
  801c6f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c72:	57                   	push   %edi
  801c73:	e8 97 f6 ff ff       	call   80130f <fd2data>
  801c78:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c7a:	83 c4 10             	add    $0x10,%esp
  801c7d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c82:	eb 3d                	jmp    801cc1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c84:	85 db                	test   %ebx,%ebx
  801c86:	74 04                	je     801c8c <devpipe_read+0x26>
				return i;
  801c88:	89 d8                	mov    %ebx,%eax
  801c8a:	eb 44                	jmp    801cd0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c8c:	89 f2                	mov    %esi,%edx
  801c8e:	89 f8                	mov    %edi,%eax
  801c90:	e8 f2 fe ff ff       	call   801b87 <_pipeisclosed>
  801c95:	85 c0                	test   %eax,%eax
  801c97:	75 32                	jne    801ccb <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c99:	e8 9b f3 ff ff       	call   801039 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c9e:	8b 06                	mov    (%esi),%eax
  801ca0:	3b 46 04             	cmp    0x4(%esi),%eax
  801ca3:	74 df                	je     801c84 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ca5:	99                   	cltd   
  801ca6:	c1 ea 1b             	shr    $0x1b,%edx
  801ca9:	01 d0                	add    %edx,%eax
  801cab:	83 e0 1f             	and    $0x1f,%eax
  801cae:	29 d0                	sub    %edx,%eax
  801cb0:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801cb5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb8:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801cbb:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801cbe:	83 c3 01             	add    $0x1,%ebx
  801cc1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801cc4:	75 d8                	jne    801c9e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801cc6:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc9:	eb 05                	jmp    801cd0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801ccb:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801cd0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    

00801cd8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801cd8:	55                   	push   %ebp
  801cd9:	89 e5                	mov    %esp,%ebp
  801cdb:	56                   	push   %esi
  801cdc:	53                   	push   %ebx
  801cdd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ce0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ce3:	50                   	push   %eax
  801ce4:	e8 3d f6 ff ff       	call   801326 <fd_alloc>
  801ce9:	83 c4 10             	add    $0x10,%esp
  801cec:	89 c2                	mov    %eax,%edx
  801cee:	85 c0                	test   %eax,%eax
  801cf0:	0f 88 2c 01 00 00    	js     801e22 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cf6:	83 ec 04             	sub    $0x4,%esp
  801cf9:	68 07 04 00 00       	push   $0x407
  801cfe:	ff 75 f4             	pushl  -0xc(%ebp)
  801d01:	6a 00                	push   $0x0
  801d03:	e8 50 f3 ff ff       	call   801058 <sys_page_alloc>
  801d08:	83 c4 10             	add    $0x10,%esp
  801d0b:	89 c2                	mov    %eax,%edx
  801d0d:	85 c0                	test   %eax,%eax
  801d0f:	0f 88 0d 01 00 00    	js     801e22 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801d15:	83 ec 0c             	sub    $0xc,%esp
  801d18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d1b:	50                   	push   %eax
  801d1c:	e8 05 f6 ff ff       	call   801326 <fd_alloc>
  801d21:	89 c3                	mov    %eax,%ebx
  801d23:	83 c4 10             	add    $0x10,%esp
  801d26:	85 c0                	test   %eax,%eax
  801d28:	0f 88 e2 00 00 00    	js     801e10 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d2e:	83 ec 04             	sub    $0x4,%esp
  801d31:	68 07 04 00 00       	push   $0x407
  801d36:	ff 75 f0             	pushl  -0x10(%ebp)
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 18 f3 ff ff       	call   801058 <sys_page_alloc>
  801d40:	89 c3                	mov    %eax,%ebx
  801d42:	83 c4 10             	add    $0x10,%esp
  801d45:	85 c0                	test   %eax,%eax
  801d47:	0f 88 c3 00 00 00    	js     801e10 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801d4d:	83 ec 0c             	sub    $0xc,%esp
  801d50:	ff 75 f4             	pushl  -0xc(%ebp)
  801d53:	e8 b7 f5 ff ff       	call   80130f <fd2data>
  801d58:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d5a:	83 c4 0c             	add    $0xc,%esp
  801d5d:	68 07 04 00 00       	push   $0x407
  801d62:	50                   	push   %eax
  801d63:	6a 00                	push   $0x0
  801d65:	e8 ee f2 ff ff       	call   801058 <sys_page_alloc>
  801d6a:	89 c3                	mov    %eax,%ebx
  801d6c:	83 c4 10             	add    $0x10,%esp
  801d6f:	85 c0                	test   %eax,%eax
  801d71:	0f 88 89 00 00 00    	js     801e00 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d77:	83 ec 0c             	sub    $0xc,%esp
  801d7a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7d:	e8 8d f5 ff ff       	call   80130f <fd2data>
  801d82:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d89:	50                   	push   %eax
  801d8a:	6a 00                	push   $0x0
  801d8c:	56                   	push   %esi
  801d8d:	6a 00                	push   $0x0
  801d8f:	e8 07 f3 ff ff       	call   80109b <sys_page_map>
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	83 c4 20             	add    $0x20,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	78 55                	js     801df2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d9d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801da3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da6:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801da8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dab:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801db2:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801db8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dbb:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcd:	e8 2d f5 ff ff       	call   8012ff <fd2num>
  801dd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dd7:	83 c4 04             	add    $0x4,%esp
  801dda:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddd:	e8 1d f5 ff ff       	call   8012ff <fd2num>
  801de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	ba 00 00 00 00       	mov    $0x0,%edx
  801df0:	eb 30                	jmp    801e22 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801df2:	83 ec 08             	sub    $0x8,%esp
  801df5:	56                   	push   %esi
  801df6:	6a 00                	push   $0x0
  801df8:	e8 e0 f2 ff ff       	call   8010dd <sys_page_unmap>
  801dfd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801e00:	83 ec 08             	sub    $0x8,%esp
  801e03:	ff 75 f0             	pushl  -0x10(%ebp)
  801e06:	6a 00                	push   $0x0
  801e08:	e8 d0 f2 ff ff       	call   8010dd <sys_page_unmap>
  801e0d:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801e10:	83 ec 08             	sub    $0x8,%esp
  801e13:	ff 75 f4             	pushl  -0xc(%ebp)
  801e16:	6a 00                	push   $0x0
  801e18:	e8 c0 f2 ff ff       	call   8010dd <sys_page_unmap>
  801e1d:	83 c4 10             	add    $0x10,%esp
  801e20:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801e22:	89 d0                	mov    %edx,%eax
  801e24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5d                   	pop    %ebp
  801e2a:	c3                   	ret    

00801e2b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801e2b:	55                   	push   %ebp
  801e2c:	89 e5                	mov    %esp,%ebp
  801e2e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e34:	50                   	push   %eax
  801e35:	ff 75 08             	pushl  0x8(%ebp)
  801e38:	e8 38 f5 ff ff       	call   801375 <fd_lookup>
  801e3d:	89 c2                	mov    %eax,%edx
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	85 d2                	test   %edx,%edx
  801e44:	78 18                	js     801e5e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4c:	e8 be f4 ff ff       	call   80130f <fd2data>
	return _pipeisclosed(fd, p);
  801e51:	89 c2                	mov    %eax,%edx
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	e8 2c fd ff ff       	call   801b87 <_pipeisclosed>
  801e5b:	83 c4 10             	add    $0x10,%esp
}
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e60:	55                   	push   %ebp
  801e61:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e63:	b8 00 00 00 00       	mov    $0x0,%eax
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    

00801e6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6a:	55                   	push   %ebp
  801e6b:	89 e5                	mov    %esp,%ebp
  801e6d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e70:	68 bc 29 80 00       	push   $0x8029bc
  801e75:	ff 75 0c             	pushl  0xc(%ebp)
  801e78:	e8 d1 ed ff ff       	call   800c4e <strcpy>
	return 0;
}
  801e7d:	b8 00 00 00 00       	mov    $0x0,%eax
  801e82:	c9                   	leave  
  801e83:	c3                   	ret    

00801e84 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e84:	55                   	push   %ebp
  801e85:	89 e5                	mov    %esp,%ebp
  801e87:	57                   	push   %edi
  801e88:	56                   	push   %esi
  801e89:	53                   	push   %ebx
  801e8a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e90:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e95:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9b:	eb 2e                	jmp    801ecb <devcons_write+0x47>
		m = n - tot;
  801e9d:	8b 55 10             	mov    0x10(%ebp),%edx
  801ea0:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801ea2:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801ea7:	83 fa 7f             	cmp    $0x7f,%edx
  801eaa:	77 02                	ja     801eae <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801eac:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801eae:	83 ec 04             	sub    $0x4,%esp
  801eb1:	56                   	push   %esi
  801eb2:	03 45 0c             	add    0xc(%ebp),%eax
  801eb5:	50                   	push   %eax
  801eb6:	57                   	push   %edi
  801eb7:	e8 24 ef ff ff       	call   800de0 <memmove>
		sys_cputs(buf, m);
  801ebc:	83 c4 08             	add    $0x8,%esp
  801ebf:	56                   	push   %esi
  801ec0:	57                   	push   %edi
  801ec1:	e8 d6 f0 ff ff       	call   800f9c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801ec6:	01 f3                	add    %esi,%ebx
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	89 d8                	mov    %ebx,%eax
  801ecd:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801ed0:	72 cb                	jb     801e9d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ed2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	5f                   	pop    %edi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    

00801eda <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eda:	55                   	push   %ebp
  801edb:	89 e5                	mov    %esp,%ebp
  801edd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801ee0:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801ee5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ee9:	75 07                	jne    801ef2 <devcons_read+0x18>
  801eeb:	eb 28                	jmp    801f15 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801eed:	e8 47 f1 ff ff       	call   801039 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ef2:	e8 c3 f0 ff ff       	call   800fba <sys_cgetc>
  801ef7:	85 c0                	test   %eax,%eax
  801ef9:	74 f2                	je     801eed <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 16                	js     801f15 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801eff:	83 f8 04             	cmp    $0x4,%eax
  801f02:	74 0c                	je     801f10 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801f04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f07:	88 02                	mov    %al,(%edx)
	return 1;
  801f09:	b8 01 00 00 00       	mov    $0x1,%eax
  801f0e:	eb 05                	jmp    801f15 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801f10:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801f15:	c9                   	leave  
  801f16:	c3                   	ret    

00801f17 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801f17:	55                   	push   %ebp
  801f18:	89 e5                	mov    %esp,%ebp
  801f1a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801f20:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801f23:	6a 01                	push   $0x1
  801f25:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f28:	50                   	push   %eax
  801f29:	e8 6e f0 ff ff       	call   800f9c <sys_cputs>
  801f2e:	83 c4 10             	add    $0x10,%esp
}
  801f31:	c9                   	leave  
  801f32:	c3                   	ret    

00801f33 <getchar>:

int
getchar(void)
{
  801f33:	55                   	push   %ebp
  801f34:	89 e5                	mov    %esp,%ebp
  801f36:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f39:	6a 01                	push   $0x1
  801f3b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f3e:	50                   	push   %eax
  801f3f:	6a 00                	push   $0x0
  801f41:	e8 98 f6 ff ff       	call   8015de <read>
	if (r < 0)
  801f46:	83 c4 10             	add    $0x10,%esp
  801f49:	85 c0                	test   %eax,%eax
  801f4b:	78 0f                	js     801f5c <getchar+0x29>
		return r;
	if (r < 1)
  801f4d:	85 c0                	test   %eax,%eax
  801f4f:	7e 06                	jle    801f57 <getchar+0x24>
		return -E_EOF;
	return c;
  801f51:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f55:	eb 05                	jmp    801f5c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f57:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f5c:	c9                   	leave  
  801f5d:	c3                   	ret    

00801f5e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f5e:	55                   	push   %ebp
  801f5f:	89 e5                	mov    %esp,%ebp
  801f61:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f67:	50                   	push   %eax
  801f68:	ff 75 08             	pushl  0x8(%ebp)
  801f6b:	e8 05 f4 ff ff       	call   801375 <fd_lookup>
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 11                	js     801f88 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f80:	39 10                	cmp    %edx,(%eax)
  801f82:	0f 94 c0             	sete   %al
  801f85:	0f b6 c0             	movzbl %al,%eax
}
  801f88:	c9                   	leave  
  801f89:	c3                   	ret    

00801f8a <opencons>:

int
opencons(void)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f90:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f93:	50                   	push   %eax
  801f94:	e8 8d f3 ff ff       	call   801326 <fd_alloc>
  801f99:	83 c4 10             	add    $0x10,%esp
		return r;
  801f9c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f9e:	85 c0                	test   %eax,%eax
  801fa0:	78 3e                	js     801fe0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fa2:	83 ec 04             	sub    $0x4,%esp
  801fa5:	68 07 04 00 00       	push   $0x407
  801faa:	ff 75 f4             	pushl  -0xc(%ebp)
  801fad:	6a 00                	push   $0x0
  801faf:	e8 a4 f0 ff ff       	call   801058 <sys_page_alloc>
  801fb4:	83 c4 10             	add    $0x10,%esp
		return r;
  801fb7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 23                	js     801fe0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801fbd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fcb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fd2:	83 ec 0c             	sub    $0xc,%esp
  801fd5:	50                   	push   %eax
  801fd6:	e8 24 f3 ff ff       	call   8012ff <fd2num>
  801fdb:	89 c2                	mov    %eax,%edx
  801fdd:	83 c4 10             	add    $0x10,%esp
}
  801fe0:	89 d0                	mov    %edx,%eax
  801fe2:	c9                   	leave  
  801fe3:	c3                   	ret    

00801fe4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fe4:	55                   	push   %ebp
  801fe5:	89 e5                	mov    %esp,%ebp
  801fe7:	56                   	push   %esi
  801fe8:	53                   	push   %ebx
  801fe9:	8b 75 08             	mov    0x8(%ebp),%esi
  801fec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801ff2:	85 f6                	test   %esi,%esi
  801ff4:	74 06                	je     801ffc <ipc_recv+0x18>
  801ff6:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801ffc:	85 db                	test   %ebx,%ebx
  801ffe:	74 06                	je     802006 <ipc_recv+0x22>
  802000:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  802006:	83 f8 01             	cmp    $0x1,%eax
  802009:	19 d2                	sbb    %edx,%edx
  80200b:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  80200d:	83 ec 0c             	sub    $0xc,%esp
  802010:	50                   	push   %eax
  802011:	e8 f2 f1 ff ff       	call   801208 <sys_ipc_recv>
  802016:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  802018:	83 c4 10             	add    $0x10,%esp
  80201b:	85 d2                	test   %edx,%edx
  80201d:	75 24                	jne    802043 <ipc_recv+0x5f>
	if (from_env_store)
  80201f:	85 f6                	test   %esi,%esi
  802021:	74 0a                	je     80202d <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  802023:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802028:	8b 40 70             	mov    0x70(%eax),%eax
  80202b:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  80202d:	85 db                	test   %ebx,%ebx
  80202f:	74 0a                	je     80203b <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  802031:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802036:	8b 40 74             	mov    0x74(%eax),%eax
  802039:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80203b:	a1 b0 40 80 00       	mov    0x8040b0,%eax
  802040:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  802043:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802046:	5b                   	pop    %ebx
  802047:	5e                   	pop    %esi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    

0080204a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	57                   	push   %edi
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	83 ec 0c             	sub    $0xc,%esp
  802053:	8b 7d 08             	mov    0x8(%ebp),%edi
  802056:	8b 75 0c             	mov    0xc(%ebp),%esi
  802059:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  80205c:	83 fb 01             	cmp    $0x1,%ebx
  80205f:	19 c0                	sbb    %eax,%eax
  802061:	09 c3                	or     %eax,%ebx
  802063:	eb 1c                	jmp    802081 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  802065:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802068:	74 12                	je     80207c <ipc_send+0x32>
  80206a:	50                   	push   %eax
  80206b:	68 c8 29 80 00       	push   $0x8029c8
  802070:	6a 36                	push   $0x36
  802072:	68 df 29 80 00       	push   $0x8029df
  802077:	e8 75 e5 ff ff       	call   8005f1 <_panic>
		sys_yield();
  80207c:	e8 b8 ef ff ff       	call   801039 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802081:	ff 75 14             	pushl  0x14(%ebp)
  802084:	53                   	push   %ebx
  802085:	56                   	push   %esi
  802086:	57                   	push   %edi
  802087:	e8 59 f1 ff ff       	call   8011e5 <sys_ipc_try_send>
		if (ret == 0) break;
  80208c:	83 c4 10             	add    $0x10,%esp
  80208f:	85 c0                	test   %eax,%eax
  802091:	75 d2                	jne    802065 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  802093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802096:	5b                   	pop    %ebx
  802097:	5e                   	pop    %esi
  802098:	5f                   	pop    %edi
  802099:	5d                   	pop    %ebp
  80209a:	c3                   	ret    

0080209b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80209b:	55                   	push   %ebp
  80209c:	89 e5                	mov    %esp,%ebp
  80209e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020a1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020a6:	6b d0 78             	imul   $0x78,%eax,%edx
  8020a9:	83 c2 50             	add    $0x50,%edx
  8020ac:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  8020b2:	39 ca                	cmp    %ecx,%edx
  8020b4:	75 0d                	jne    8020c3 <ipc_find_env+0x28>
			return envs[i].env_id;
  8020b6:	6b c0 78             	imul   $0x78,%eax,%eax
  8020b9:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  8020be:	8b 40 08             	mov    0x8(%eax),%eax
  8020c1:	eb 0e                	jmp    8020d1 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020c3:	83 c0 01             	add    $0x1,%eax
  8020c6:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020cb:	75 d9                	jne    8020a6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020cd:	66 b8 00 00          	mov    $0x0,%ax
}
  8020d1:	5d                   	pop    %ebp
  8020d2:	c3                   	ret    

008020d3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d3:	55                   	push   %ebp
  8020d4:	89 e5                	mov    %esp,%ebp
  8020d6:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d9:	89 d0                	mov    %edx,%eax
  8020db:	c1 e8 16             	shr    $0x16,%eax
  8020de:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020e5:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020ea:	f6 c1 01             	test   $0x1,%cl
  8020ed:	74 1d                	je     80210c <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020ef:	c1 ea 0c             	shr    $0xc,%edx
  8020f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020f9:	f6 c2 01             	test   $0x1,%dl
  8020fc:	74 0e                	je     80210c <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020fe:	c1 ea 0c             	shr    $0xc,%edx
  802101:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802108:	ef 
  802109:	0f b7 c0             	movzwl %ax,%eax
}
  80210c:	5d                   	pop    %ebp
  80210d:	c3                   	ret    
  80210e:	66 90                	xchg   %ax,%ax

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
