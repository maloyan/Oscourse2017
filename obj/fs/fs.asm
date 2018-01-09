
obj/fs/fs:     file format elf32-i386


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
  80002c:	e8 16 19 00 00       	call   801947 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <ide_wait_ready>:

static int diskno = 1;

static int
ide_wait_ready(bool check_error)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	89 c1                	mov    %eax,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800039:	ba f7 01 00 00       	mov    $0x1f7,%edx
  80003e:	ec                   	in     (%dx),%al
  80003f:	89 c3                	mov    %eax,%ebx
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
  800041:	83 e0 c0             	and    $0xffffffc0,%eax
  800044:	3c 40                	cmp    $0x40,%al
  800046:	75 f6                	jne    80003e <ide_wait_ready+0xb>
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
		return -1;
	return 0;
  800048:	b8 00 00 00 00       	mov    $0x0,%eax
	int r;

	while (((r = inb(0x1F7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
		/* do nothing */;

	if (check_error && (r & (IDE_DF|IDE_ERR)) != 0)
  80004d:	84 c9                	test   %cl,%cl
  80004f:	74 0b                	je     80005c <ide_wait_ready+0x29>
  800051:	f6 c3 21             	test   $0x21,%bl
  800054:	0f 95 c0             	setne  %al
  800057:	0f b6 c0             	movzbl %al,%eax
  80005a:	f7 d8                	neg    %eax
		return -1;
	return 0;
}
  80005c:	5b                   	pop    %ebx
  80005d:	5d                   	pop    %ebp
  80005e:	c3                   	ret    

0080005f <ide_probe_disk1>:

bool
ide_probe_disk1(void)
{
  80005f:	55                   	push   %ebp
  800060:	89 e5                	mov    %esp,%ebp
  800062:	53                   	push   %ebx
  800063:	83 ec 04             	sub    $0x4,%esp
	int r, x;

	// wait for Device 0 to be ready
	ide_wait_ready(0);
  800066:	b8 00 00 00 00       	mov    $0x0,%eax
  80006b:	e8 c3 ff ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800070:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800075:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80007a:	ee                   	out    %al,(%dx)

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  80007b:	b9 00 00 00 00       	mov    $0x0,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
  800080:	b2 f7                	mov    $0xf7,%dl
  800082:	eb 0b                	jmp    80008f <ide_probe_disk1+0x30>
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
	     x++)
  800084:	83 c1 01             	add    $0x1,%ecx

	// switch to Device 1
	outb(0x1F6, 0xE0 | (1<<4));

	// check for Device 1 to be ready for a while
	for (x = 0;
  800087:	81 f9 e8 03 00 00    	cmp    $0x3e8,%ecx
  80008d:	74 05                	je     800094 <ide_probe_disk1+0x35>
  80008f:	ec                   	in     (%dx),%al
	     x < 1000 && ((r = inb(0x1F7)) & (IDE_BSY|IDE_DF|IDE_ERR)) != 0;
  800090:	a8 a1                	test   $0xa1,%al
  800092:	75 f0                	jne    800084 <ide_probe_disk1+0x25>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800094:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800099:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
  80009e:	ee                   	out    %al,(%dx)
		/* do nothing */;

	// switch back to Device 0
	outb(0x1F6, 0xE0 | (0<<4));

	cprintf("Device 1 presence: %d\n", (x < 1000));
  80009f:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
  8000a5:	0f 9e c3             	setle  %bl
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	0f b6 c3             	movzbl %bl,%eax
  8000ae:	50                   	push   %eax
  8000af:	68 80 37 80 00       	push   $0x803780
  8000b4:	e8 c7 19 00 00       	call   801a80 <cprintf>
	return (x < 1000);
}
  8000b9:	89 d8                	mov    %ebx,%eax
  8000bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <ide_set_disk>:

void
ide_set_disk(int d)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 08             	sub    $0x8,%esp
  8000c6:	8b 45 08             	mov    0x8(%ebp),%eax
	if (d != 0 && d != 1)
  8000c9:	83 f8 01             	cmp    $0x1,%eax
  8000cc:	76 14                	jbe    8000e2 <ide_set_disk+0x22>
		panic("bad disk number");
  8000ce:	83 ec 04             	sub    $0x4,%esp
  8000d1:	68 97 37 80 00       	push   $0x803797
  8000d6:	6a 3a                	push   $0x3a
  8000d8:	68 a7 37 80 00       	push   $0x8037a7
  8000dd:	e8 c5 18 00 00       	call   8019a7 <_panic>
	diskno = d;
  8000e2:	a3 00 50 80 00       	mov    %eax,0x805000
}
  8000e7:	c9                   	leave  
  8000e8:	c3                   	ret    

008000e9 <ide_read>:


int
ide_read(uint32_t secno, void *dst, size_t nsecs)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8000f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000f8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	assert(nsecs <= 256);
  8000fb:	81 fe 00 01 00 00    	cmp    $0x100,%esi
  800101:	76 16                	jbe    800119 <ide_read+0x30>
  800103:	68 b0 37 80 00       	push   $0x8037b0
  800108:	68 bd 37 80 00       	push   $0x8037bd
  80010d:	6a 44                	push   $0x44
  80010f:	68 a7 37 80 00       	push   $0x8037a7
  800114:	e8 8e 18 00 00       	call   8019a7 <_panic>

	ide_wait_ready(0);
  800119:	b8 00 00 00 00       	mov    $0x0,%eax
  80011e:	e8 10 ff ff ff       	call   800033 <ide_wait_ready>
  800123:	ba f2 01 00 00       	mov    $0x1f2,%edx
  800128:	89 f0                	mov    %esi,%eax
  80012a:	ee                   	out    %al,(%dx)
  80012b:	b2 f3                	mov    $0xf3,%dl
  80012d:	89 f8                	mov    %edi,%eax
  80012f:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  800130:	89 f8                	mov    %edi,%eax
  800132:	c1 e8 08             	shr    $0x8,%eax
  800135:	b2 f4                	mov    $0xf4,%dl
  800137:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  800138:	89 f8                	mov    %edi,%eax
  80013a:	c1 e8 10             	shr    $0x10,%eax
  80013d:	b2 f5                	mov    $0xf5,%dl
  80013f:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  800140:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  800147:	83 e0 01             	and    $0x1,%eax
  80014a:	c1 e0 04             	shl    $0x4,%eax
  80014d:	83 c8 e0             	or     $0xffffffe0,%eax
  800150:	c1 ef 18             	shr    $0x18,%edi
  800153:	83 e7 0f             	and    $0xf,%edi
  800156:	09 f8                	or     %edi,%eax
  800158:	b2 f6                	mov    $0xf6,%dl
  80015a:	ee                   	out    %al,(%dx)
  80015b:	b2 f7                	mov    $0xf7,%dl
  80015d:	b8 20 00 00 00       	mov    $0x20,%eax
  800162:	ee                   	out    %al,(%dx)
  800163:	c1 e6 09             	shl    $0x9,%esi
  800166:	01 de                	add    %ebx,%esi
  800168:	eb 23                	jmp    80018d <ide_read+0xa4>
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80016a:	b8 01 00 00 00       	mov    $0x1,%eax
  80016f:	e8 bf fe ff ff       	call   800033 <ide_wait_ready>
  800174:	85 c0                	test   %eax,%eax
  800176:	78 1e                	js     800196 <ide_read+0xad>
}

static __inline void
insl(int port, void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\tinsl"			:
  800178:	89 df                	mov    %ebx,%edi
  80017a:	b9 80 00 00 00       	mov    $0x80,%ecx
  80017f:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800184:	fc                   	cld    
  800185:	f2 6d                	repnz insl (%dx),%es:(%edi)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x20);	// CMD 0x20 means read sector

	for (; nsecs > 0; nsecs--, dst += SECTSIZE) {
  800187:	81 c3 00 02 00 00    	add    $0x200,%ebx
  80018d:	39 f3                	cmp    %esi,%ebx
  80018f:	75 d9                	jne    80016a <ide_read+0x81>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		insl(0x1F0, dst, SECTSIZE/4);
	}

	return 0;
  800191:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800199:	5b                   	pop    %ebx
  80019a:	5e                   	pop    %esi
  80019b:	5f                   	pop    %edi
  80019c:	5d                   	pop    %ebp
  80019d:	c3                   	ret    

0080019e <ide_write>:

int
ide_write(uint32_t secno, const void *src, size_t nsecs)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	8b 75 08             	mov    0x8(%ebp),%esi
  8001aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8001ad:	8b 7d 10             	mov    0x10(%ebp),%edi
	int r;

	assert(nsecs <= 256);
  8001b0:	81 ff 00 01 00 00    	cmp    $0x100,%edi
  8001b6:	76 16                	jbe    8001ce <ide_write+0x30>
  8001b8:	68 b0 37 80 00       	push   $0x8037b0
  8001bd:	68 bd 37 80 00       	push   $0x8037bd
  8001c2:	6a 5d                	push   $0x5d
  8001c4:	68 a7 37 80 00       	push   $0x8037a7
  8001c9:	e8 d9 17 00 00       	call   8019a7 <_panic>

	ide_wait_ready(0);
  8001ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8001d3:	e8 5b fe ff ff       	call   800033 <ide_wait_ready>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
  8001d8:	ba f2 01 00 00       	mov    $0x1f2,%edx
  8001dd:	89 f8                	mov    %edi,%eax
  8001df:	ee                   	out    %al,(%dx)
  8001e0:	b2 f3                	mov    $0xf3,%dl
  8001e2:	89 f0                	mov    %esi,%eax
  8001e4:	ee                   	out    %al,(%dx)

	outb(0x1F2, nsecs);
	outb(0x1F3, secno & 0xFF);
	outb(0x1F4, (secno >> 8) & 0xFF);
  8001e5:	89 f0                	mov    %esi,%eax
  8001e7:	c1 e8 08             	shr    $0x8,%eax
  8001ea:	b2 f4                	mov    $0xf4,%dl
  8001ec:	ee                   	out    %al,(%dx)
	outb(0x1F5, (secno >> 16) & 0xFF);
  8001ed:	89 f0                	mov    %esi,%eax
  8001ef:	c1 e8 10             	shr    $0x10,%eax
  8001f2:	b2 f5                	mov    $0xf5,%dl
  8001f4:	ee                   	out    %al,(%dx)
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
  8001f5:	0f b6 05 00 50 80 00 	movzbl 0x805000,%eax
  8001fc:	83 e0 01             	and    $0x1,%eax
  8001ff:	c1 e0 04             	shl    $0x4,%eax
  800202:	83 c8 e0             	or     $0xffffffe0,%eax
  800205:	c1 ee 18             	shr    $0x18,%esi
  800208:	83 e6 0f             	and    $0xf,%esi
  80020b:	09 f0                	or     %esi,%eax
  80020d:	b2 f6                	mov    $0xf6,%dl
  80020f:	ee                   	out    %al,(%dx)
  800210:	b2 f7                	mov    $0xf7,%dl
  800212:	b8 30 00 00 00       	mov    $0x30,%eax
  800217:	ee                   	out    %al,(%dx)
  800218:	c1 e7 09             	shl    $0x9,%edi
  80021b:	01 df                	add    %ebx,%edi
  80021d:	eb 23                	jmp    800242 <ide_write+0xa4>
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
		if ((r = ide_wait_ready(1)) < 0)
  80021f:	b8 01 00 00 00       	mov    $0x1,%eax
  800224:	e8 0a fe ff ff       	call   800033 <ide_wait_ready>
  800229:	85 c0                	test   %eax,%eax
  80022b:	78 1e                	js     80024b <ide_write+0xad>
}

static __inline void
outsl(int port, const void *addr, int cnt)
{
	__asm __volatile("cld\n\trepne\n\toutsl"		:
  80022d:	89 de                	mov    %ebx,%esi
  80022f:	b9 80 00 00 00       	mov    $0x80,%ecx
  800234:	ba f0 01 00 00       	mov    $0x1f0,%edx
  800239:	fc                   	cld    
  80023a:	f2 6f                	repnz outsl %ds:(%esi),(%dx)
	outb(0x1F4, (secno >> 8) & 0xFF);
	outb(0x1F5, (secno >> 16) & 0xFF);
	outb(0x1F6, 0xE0 | ((diskno&1)<<4) | ((secno>>24)&0x0F));
	outb(0x1F7, 0x30);	// CMD 0x30 means write sector

	for (; nsecs > 0; nsecs--, src += SECTSIZE) {
  80023c:	81 c3 00 02 00 00    	add    $0x200,%ebx
  800242:	39 fb                	cmp    %edi,%ebx
  800244:	75 d9                	jne    80021f <ide_write+0x81>
		if ((r = ide_wait_ready(1)) < 0)
			return r;
		outsl(0x1F0, src, SECTSIZE/4);
	}

	return 0;
  800246:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80024b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024e:	5b                   	pop    %ebx
  80024f:	5e                   	pop    %esi
  800250:	5f                   	pop    %edi
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <bc_pgfault>:

// Fault any disk block that is read in to memory by
// loading it from disk.
static void
bc_pgfault(struct UTrapframe *utf)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	57                   	push   %edi
  800257:	56                   	push   %esi
  800258:	53                   	push   %ebx
  800259:	83 ec 1c             	sub    $0x1c,%esp
  80025c:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void *) utf->utf_fault_va;
  80025f:	8b 1a                	mov    (%edx),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800261:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800267:	89 c6                	mov    %eax,%esi
  800269:	c1 ee 0c             	shr    $0xc,%esi
	int r;

	void *pgva = ROUNDDOWN(addr, BLKSIZE);
  80026c:	89 df                	mov    %ebx,%edi
  80026e:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
	uint32_t secnum = blockno * BLKSECTS;
  800274:	8d 0c f5 00 00 00 00 	lea    0x0(,%esi,8),%ecx
  80027b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

	// Check that the fault was within the block cache region
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80027e:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800283:	76 1b                	jbe    8002a0 <bc_pgfault+0x4d>
		panic("page fault in FS: eip %p, va %p, err %04x",
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	ff 72 04             	pushl  0x4(%edx)
  80028b:	53                   	push   %ebx
  80028c:	ff 72 28             	pushl  0x28(%edx)
  80028f:	68 d4 37 80 00       	push   $0x8037d4
  800294:	6a 2a                	push   $0x2a
  800296:	68 8c 38 80 00       	push   $0x80388c
  80029b:	e8 07 17 00 00       	call   8019a7 <_panic>
		      (void *) utf->utf_eip, addr, utf->utf_err);

	// Sanity check the block number.
	if (super && blockno >= super->s_nblocks)
  8002a0:	a1 08 a0 80 00       	mov    0x80a008,%eax
  8002a5:	85 c0                	test   %eax,%eax
  8002a7:	74 17                	je     8002c0 <bc_pgfault+0x6d>
  8002a9:	3b 70 04             	cmp    0x4(%eax),%esi
  8002ac:	72 12                	jb     8002c0 <bc_pgfault+0x6d>
		panic("reading non-existent block %08x\n", blockno);
  8002ae:	56                   	push   %esi
  8002af:	68 00 38 80 00       	push   $0x803800
  8002b4:	6a 2e                	push   $0x2e
  8002b6:	68 8c 38 80 00       	push   $0x80388c
  8002bb:	e8 e7 16 00 00       	call   8019a7 <_panic>
	// of the block from the disk into that page.
	// Hint: first round addr to page boundary. fs/ide.c has code to read
	// the disk.
	//
	// LAB 10: you code here:
	if (sys_page_alloc(0, pgva, PTE_U | PTE_W | PTE_P))
  8002c0:	83 ec 04             	sub    $0x4,%esp
  8002c3:	6a 07                	push   $0x7
  8002c5:	57                   	push   %edi
  8002c6:	6a 00                	push   $0x0
  8002c8:	e8 41 21 00 00       	call   80240e <sys_page_alloc>
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	74 14                	je     8002e8 <bc_pgfault+0x95>
		panic("bc_pgfault: alloc");    
  8002d4:	83 ec 04             	sub    $0x4,%esp
  8002d7:	68 94 38 80 00       	push   $0x803894
  8002dc:	6a 37                	push   $0x37
  8002de:	68 8c 38 80 00       	push   $0x80388c
  8002e3:	e8 bf 16 00 00       	call   8019a7 <_panic>
	if (ide_read(secnum, pgva, BLKSECTS))
  8002e8:	83 ec 04             	sub    $0x4,%esp
  8002eb:	6a 08                	push   $0x8
  8002ed:	57                   	push   %edi
  8002ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002f1:	e8 f3 fd ff ff       	call   8000e9 <ide_read>
  8002f6:	83 c4 10             	add    $0x10,%esp
  8002f9:	85 c0                	test   %eax,%eax
  8002fb:	74 14                	je     800311 <bc_pgfault+0xbe>
		panic("bc_pgfault: ide read");
  8002fd:	83 ec 04             	sub    $0x4,%esp
  800300:	68 a6 38 80 00       	push   $0x8038a6
  800305:	6a 39                	push   $0x39
  800307:	68 8c 38 80 00       	push   $0x80388c
  80030c:	e8 96 16 00 00       	call   8019a7 <_panic>
	// Clear the dirty bit for the disk block page since we just read the
	// block from disk
	if ((r = sys_page_map(0, addr, 0, addr, uvpt[PGNUM(addr)] & PTE_SYSCALL)) < 0)
  800311:	89 d8                	mov    %ebx,%eax
  800313:	c1 e8 0c             	shr    $0xc,%eax
  800316:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	25 07 0e 00 00       	and    $0xe07,%eax
  800325:	50                   	push   %eax
  800326:	53                   	push   %ebx
  800327:	6a 00                	push   $0x0
  800329:	53                   	push   %ebx
  80032a:	6a 00                	push   $0x0
  80032c:	e8 20 21 00 00       	call   802451 <sys_page_map>
  800331:	83 c4 20             	add    $0x20,%esp
  800334:	85 c0                	test   %eax,%eax
  800336:	79 12                	jns    80034a <bc_pgfault+0xf7>
		panic("in bc_pgfault, sys_page_map: %i", r);
  800338:	50                   	push   %eax
  800339:	68 24 38 80 00       	push   $0x803824
  80033e:	6a 3d                	push   $0x3d
  800340:	68 8c 38 80 00       	push   $0x80388c
  800345:	e8 5d 16 00 00       	call   8019a7 <_panic>

	// Check that the block we read was allocated. (exercise for
	// the reader: why do we do this *after* reading the block
	// in?)
	if (bitmap && block_is_free(blockno))
  80034a:	83 3d 04 a0 80 00 00 	cmpl   $0x0,0x80a004
  800351:	74 22                	je     800375 <bc_pgfault+0x122>
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	56                   	push   %esi
  800357:	e8 61 03 00 00       	call   8006bd <block_is_free>
  80035c:	83 c4 10             	add    $0x10,%esp
  80035f:	84 c0                	test   %al,%al
  800361:	74 12                	je     800375 <bc_pgfault+0x122>
		panic("reading free block %08x\n", blockno);
  800363:	56                   	push   %esi
  800364:	68 bb 38 80 00       	push   $0x8038bb
  800369:	6a 43                	push   $0x43
  80036b:	68 8c 38 80 00       	push   $0x80388c
  800370:	e8 32 16 00 00       	call   8019a7 <_panic>
}
  800375:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800378:	5b                   	pop    %ebx
  800379:	5e                   	pop    %esi
  80037a:	5f                   	pop    %edi
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <diskaddr>:
#include "fs.h"

// Return the virtual address of this disk block.
void*
diskaddr(uint32_t blockno)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	8b 45 08             	mov    0x8(%ebp),%eax
	if (blockno == 0 || (super && blockno >= super->s_nblocks))
  800386:	85 c0                	test   %eax,%eax
  800388:	74 0f                	je     800399 <diskaddr+0x1c>
  80038a:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  800390:	85 d2                	test   %edx,%edx
  800392:	74 17                	je     8003ab <diskaddr+0x2e>
  800394:	3b 42 04             	cmp    0x4(%edx),%eax
  800397:	72 12                	jb     8003ab <diskaddr+0x2e>
		panic("bad block number %08x in diskaddr", blockno);
  800399:	50                   	push   %eax
  80039a:	68 44 38 80 00       	push   $0x803844
  80039f:	6a 09                	push   $0x9
  8003a1:	68 8c 38 80 00       	push   $0x80388c
  8003a6:	e8 fc 15 00 00       	call   8019a7 <_panic>
	return (char*) (DISKMAP + blockno * BLKSIZE);
  8003ab:	05 00 00 01 00       	add    $0x10000,%eax
  8003b0:	c1 e0 0c             	shl    $0xc,%eax
}
  8003b3:	c9                   	leave  
  8003b4:	c3                   	ret    

008003b5 <va_is_mapped>:

// Is this virtual address mapped?
bool
va_is_mapped(void *va)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	8b 55 08             	mov    0x8(%ebp),%edx
	return (uvpd[PDX(va)] & PTE_P) && (uvpt[PGNUM(va)] & PTE_P);
  8003bb:	89 d0                	mov    %edx,%eax
  8003bd:	c1 e8 16             	shr    $0x16,%eax
  8003c0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
  8003c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cc:	f6 c1 01             	test   $0x1,%cl
  8003cf:	74 0d                	je     8003de <va_is_mapped+0x29>
  8003d1:	c1 ea 0c             	shr    $0xc,%edx
  8003d4:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8003db:	83 e0 01             	and    $0x1,%eax
  8003de:	83 e0 01             	and    $0x1,%eax
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <va_is_dirty>:

// Is this virtual address dirty?
bool
va_is_dirty(void *va)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
	return (uvpt[PGNUM(va)] & PTE_D) != 0;
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	c1 e8 0c             	shr    $0xc,%eax
  8003ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8003f3:	c1 e8 06             	shr    $0x6,%eax
  8003f6:	83 e0 01             	and    $0x1,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <flush_block>:
// Hint: Use va_is_mapped, va_is_dirty, and ide_write.
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	57                   	push   %edi
  8003ff:	56                   	push   %esi
  800400:	53                   	push   %ebx
  800401:	83 ec 0c             	sub    $0xc,%esp
  800404:	8b 5d 08             	mov    0x8(%ebp),%ebx
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
	void *pgva = ROUNDDOWN(addr, BLKSIZE);
  800407:	89 de                	mov    %ebx,%esi
  800409:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	pte_t pte = uvpt[PGNUM(pgva)];
  80040f:	89 f0                	mov    %esi,%eax
  800411:	c1 e8 0c             	shr    $0xc,%eax
  800414:	8b 3c 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edi
	uint32_t secnum = blockno * BLKSECTS;
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
  80041b:	8d 83 00 00 00 f0    	lea    -0x10000000(%ebx),%eax
  800421:	3d ff ff ff bf       	cmp    $0xbfffffff,%eax
  800426:	76 12                	jbe    80043a <flush_block+0x3f>
		panic("flush_block of bad va %08x\n", (unsigned int)addr);
  800428:	53                   	push   %ebx
  800429:	68 d4 38 80 00       	push   $0x8038d4
  80042e:	6a 55                	push   $0x55
  800430:	68 8c 38 80 00       	push   $0x80388c
  800435:	e8 6d 15 00 00       	call   8019a7 <_panic>
	if (!va_is_mapped(pgva) || !va_is_dirty(pgva))
  80043a:	83 ec 0c             	sub    $0xc,%esp
  80043d:	56                   	push   %esi
  80043e:	e8 72 ff ff ff       	call   8003b5 <va_is_mapped>
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	84 c0                	test   %al,%al
  800448:	74 73                	je     8004bd <flush_block+0xc2>
  80044a:	83 ec 0c             	sub    $0xc,%esp
  80044d:	56                   	push   %esi
  80044e:	e8 90 ff ff ff       	call   8003e3 <va_is_dirty>
  800453:	83 c4 10             	add    $0x10,%esp
  800456:	84 c0                	test   %al,%al
  800458:	74 63                	je     8004bd <flush_block+0xc2>
	        return;
	if (ide_write(secnum, pgva, BLKSECTS))
  80045a:	83 ec 04             	sub    $0x4,%esp
  80045d:	6a 08                	push   $0x8
  80045f:	56                   	push   %esi
// Hint: Use the PTE_SYSCALL constant when calling sys_page_map.
// Hint: Don't forget to round addr down.
void
flush_block(void *addr)
{
	uint32_t blockno = ((uint32_t)addr - DISKMAP) / BLKSIZE;
  800460:	81 eb 00 00 00 10    	sub    $0x10000000,%ebx
  800466:	c1 eb 0c             	shr    $0xc,%ebx
	void *pgva = ROUNDDOWN(addr, BLKSIZE);
	pte_t pte = uvpt[PGNUM(pgva)];
	uint32_t secnum = blockno * BLKSECTS;
  800469:	c1 e3 03             	shl    $0x3,%ebx
	if (addr < (void*)DISKMAP || addr >= (void*)(DISKMAP + DISKSIZE))
		panic("flush_block of bad va %08x\n", (unsigned int)addr);
	if (!va_is_mapped(pgva) || !va_is_dirty(pgva))
	        return;
	if (ide_write(secnum, pgva, BLKSECTS))
  80046c:	53                   	push   %ebx
  80046d:	e8 2c fd ff ff       	call   80019e <ide_write>
  800472:	83 c4 10             	add    $0x10,%esp
  800475:	85 c0                	test   %eax,%eax
  800477:	74 14                	je     80048d <flush_block+0x92>
        	panic("flush_block: ide write");
  800479:	83 ec 04             	sub    $0x4,%esp
  80047c:	68 f0 38 80 00       	push   $0x8038f0
  800481:	6a 59                	push   $0x59
  800483:	68 8c 38 80 00       	push   $0x80388c
  800488:	e8 1a 15 00 00       	call   8019a7 <_panic>
	if (sys_page_map(0, pgva, 0, pgva, pte & PTE_SYSCALL))
  80048d:	83 ec 0c             	sub    $0xc,%esp
  800490:	81 e7 07 0e 00 00    	and    $0xe07,%edi
  800496:	57                   	push   %edi
  800497:	56                   	push   %esi
  800498:	6a 00                	push   $0x0
  80049a:	56                   	push   %esi
  80049b:	6a 00                	push   $0x0
  80049d:	e8 af 1f 00 00       	call   802451 <sys_page_map>
  8004a2:	83 c4 20             	add    $0x20,%esp
  8004a5:	85 c0                	test   %eax,%eax
  8004a7:	74 14                	je     8004bd <flush_block+0xc2>
        	panic("flush_block: map");
  8004a9:	83 ec 04             	sub    $0x4,%esp
  8004ac:	68 07 39 80 00       	push   $0x803907
  8004b1:	6a 5b                	push   $0x5b
  8004b3:	68 8c 38 80 00       	push   $0x80388c
  8004b8:	e8 ea 14 00 00       	call   8019a7 <_panic>
	// LAB 10: Your code here.
	//panic("flush_block not implemented");
}
  8004bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c0:	5b                   	pop    %ebx
  8004c1:	5e                   	pop    %esi
  8004c2:	5f                   	pop    %edi
  8004c3:	5d                   	pop    %ebp
  8004c4:	c3                   	ret    

008004c5 <bc_init>:
	cprintf("block cache is good\n");
}

void
bc_init(void)
{
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	81 ec 24 02 00 00    	sub    $0x224,%esp
	struct Super super;
	set_pgfault_handler(bc_pgfault);
  8004ce:	68 53 02 80 00       	push   $0x800253
  8004d3:	e8 46 21 00 00       	call   80261e <set_pgfault_handler>
check_bc(void)
{
	struct Super backup;

	// back up super block
	memmove(&backup, diskaddr(1), sizeof backup);
  8004d8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8004df:	e8 99 fe ff ff       	call   80037d <diskaddr>
  8004e4:	83 c4 0c             	add    $0xc,%esp
  8004e7:	68 08 01 00 00       	push   $0x108
  8004ec:	50                   	push   %eax
  8004ed:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  8004f3:	50                   	push   %eax
  8004f4:	e8 9d 1c 00 00       	call   802196 <memmove>

	// smash it
	strcpy(diskaddr(1), "OOPS!\n");
  8004f9:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800500:	e8 78 fe ff ff       	call   80037d <diskaddr>
  800505:	83 c4 08             	add    $0x8,%esp
  800508:	68 18 39 80 00       	push   $0x803918
  80050d:	50                   	push   %eax
  80050e:	e8 f1 1a 00 00       	call   802004 <strcpy>
	flush_block(diskaddr(1));
  800513:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80051a:	e8 5e fe ff ff       	call   80037d <diskaddr>
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	e8 d4 fe ff ff       	call   8003fb <flush_block>
	assert(va_is_mapped(diskaddr(1)));
  800527:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80052e:	e8 4a fe ff ff       	call   80037d <diskaddr>
  800533:	89 04 24             	mov    %eax,(%esp)
  800536:	e8 7a fe ff ff       	call   8003b5 <va_is_mapped>
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	84 c0                	test   %al,%al
  800540:	75 16                	jne    800558 <bc_init+0x93>
  800542:	68 3a 39 80 00       	push   $0x80393a
  800547:	68 bd 37 80 00       	push   $0x8037bd
  80054c:	6a 6d                	push   $0x6d
  80054e:	68 8c 38 80 00       	push   $0x80388c
  800553:	e8 4f 14 00 00       	call   8019a7 <_panic>
	assert(!va_is_dirty(diskaddr(1)));
  800558:	83 ec 0c             	sub    $0xc,%esp
  80055b:	6a 01                	push   $0x1
  80055d:	e8 1b fe ff ff       	call   80037d <diskaddr>
  800562:	89 04 24             	mov    %eax,(%esp)
  800565:	e8 79 fe ff ff       	call   8003e3 <va_is_dirty>
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	84 c0                	test   %al,%al
  80056f:	74 16                	je     800587 <bc_init+0xc2>
  800571:	68 1f 39 80 00       	push   $0x80391f
  800576:	68 bd 37 80 00       	push   $0x8037bd
  80057b:	6a 6e                	push   $0x6e
  80057d:	68 8c 38 80 00       	push   $0x80388c
  800582:	e8 20 14 00 00       	call   8019a7 <_panic>

	// clear it out
	sys_page_unmap(0, diskaddr(1));
  800587:	83 ec 0c             	sub    $0xc,%esp
  80058a:	6a 01                	push   $0x1
  80058c:	e8 ec fd ff ff       	call   80037d <diskaddr>
  800591:	83 c4 08             	add    $0x8,%esp
  800594:	50                   	push   %eax
  800595:	6a 00                	push   $0x0
  800597:	e8 f7 1e 00 00       	call   802493 <sys_page_unmap>
	assert(!va_is_mapped(diskaddr(1)));
  80059c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8005a3:	e8 d5 fd ff ff       	call   80037d <diskaddr>
  8005a8:	89 04 24             	mov    %eax,(%esp)
  8005ab:	e8 05 fe ff ff       	call   8003b5 <va_is_mapped>
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	84 c0                	test   %al,%al
  8005b5:	74 16                	je     8005cd <bc_init+0x108>
  8005b7:	68 39 39 80 00       	push   $0x803939
  8005bc:	68 bd 37 80 00       	push   $0x8037bd
  8005c1:	6a 72                	push   $0x72
  8005c3:	68 8c 38 80 00       	push   $0x80388c
  8005c8:	e8 da 13 00 00       	call   8019a7 <_panic>

	// read it back in
	assert(strcmp(diskaddr(1), "OOPS!\n") == 0);
  8005cd:	83 ec 0c             	sub    $0xc,%esp
  8005d0:	6a 01                	push   $0x1
  8005d2:	e8 a6 fd ff ff       	call   80037d <diskaddr>
  8005d7:	83 c4 08             	add    $0x8,%esp
  8005da:	68 18 39 80 00       	push   $0x803918
  8005df:	50                   	push   %eax
  8005e0:	e8 c9 1a 00 00       	call   8020ae <strcmp>
  8005e5:	83 c4 10             	add    $0x10,%esp
  8005e8:	85 c0                	test   %eax,%eax
  8005ea:	74 16                	je     800602 <bc_init+0x13d>
  8005ec:	68 68 38 80 00       	push   $0x803868
  8005f1:	68 bd 37 80 00       	push   $0x8037bd
  8005f6:	6a 75                	push   $0x75
  8005f8:	68 8c 38 80 00       	push   $0x80388c
  8005fd:	e8 a5 13 00 00       	call   8019a7 <_panic>

	// fix it
	memmove(diskaddr(1), &backup, sizeof backup);
  800602:	83 ec 0c             	sub    $0xc,%esp
  800605:	6a 01                	push   $0x1
  800607:	e8 71 fd ff ff       	call   80037d <diskaddr>
  80060c:	83 c4 0c             	add    $0xc,%esp
  80060f:	68 08 01 00 00       	push   $0x108
  800614:	8d 95 e8 fd ff ff    	lea    -0x218(%ebp),%edx
  80061a:	52                   	push   %edx
  80061b:	50                   	push   %eax
  80061c:	e8 75 1b 00 00       	call   802196 <memmove>
	flush_block(diskaddr(1));
  800621:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800628:	e8 50 fd ff ff       	call   80037d <diskaddr>
  80062d:	89 04 24             	mov    %eax,(%esp)
  800630:	e8 c6 fd ff ff       	call   8003fb <flush_block>

	cprintf("block cache is good\n");
  800635:	c7 04 24 54 39 80 00 	movl   $0x803954,(%esp)
  80063c:	e8 3f 14 00 00       	call   801a80 <cprintf>
	struct Super super;
	set_pgfault_handler(bc_pgfault);
	check_bc();

	// cache the super block by reading it once
	memmove(&super, diskaddr(1), sizeof super);
  800641:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800648:	e8 30 fd ff ff       	call   80037d <diskaddr>
  80064d:	83 c4 0c             	add    $0xc,%esp
  800650:	68 08 01 00 00       	push   $0x108
  800655:	50                   	push   %eax
  800656:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80065c:	50                   	push   %eax
  80065d:	e8 34 1b 00 00       	call   802196 <memmove>
  800662:	83 c4 10             	add    $0x10,%esp
}
  800665:	c9                   	leave  
  800666:	c3                   	ret    

00800667 <check_super>:
// --------------------------------------------------------------

// Validate the file system super-block.
void
check_super(void)
{
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	83 ec 08             	sub    $0x8,%esp
	if (super->s_magic != FS_MAGIC)
  80066d:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800672:	81 38 ae 30 05 4a    	cmpl   $0x4a0530ae,(%eax)
  800678:	74 14                	je     80068e <check_super+0x27>
		panic("bad file system magic number");
  80067a:	83 ec 04             	sub    $0x4,%esp
  80067d:	68 69 39 80 00       	push   $0x803969
  800682:	6a 0f                	push   $0xf
  800684:	68 86 39 80 00       	push   $0x803986
  800689:	e8 19 13 00 00       	call   8019a7 <_panic>

	if (super->s_nblocks > DISKSIZE/BLKSIZE)
  80068e:	81 78 04 00 00 0c 00 	cmpl   $0xc0000,0x4(%eax)
  800695:	76 14                	jbe    8006ab <check_super+0x44>
		panic("file system is too large");
  800697:	83 ec 04             	sub    $0x4,%esp
  80069a:	68 8e 39 80 00       	push   $0x80398e
  80069f:	6a 12                	push   $0x12
  8006a1:	68 86 39 80 00       	push   $0x803986
  8006a6:	e8 fc 12 00 00       	call   8019a7 <_panic>

	cprintf("superblock is good\n");
  8006ab:	83 ec 0c             	sub    $0xc,%esp
  8006ae:	68 a7 39 80 00       	push   $0x8039a7
  8006b3:	e8 c8 13 00 00       	call   801a80 <cprintf>
  8006b8:	83 c4 10             	add    $0x10,%esp
}
  8006bb:	c9                   	leave  
  8006bc:	c3                   	ret    

008006bd <block_is_free>:

// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (super == 0 || blockno >= super->s_nblocks)
  8006c3:	8b 15 08 a0 80 00    	mov    0x80a008,%edx
  8006c9:	85 d2                	test   %edx,%edx
  8006cb:	74 22                	je     8006ef <block_is_free+0x32>
		return 0;
  8006cd:	b8 00 00 00 00       	mov    $0x0,%eax
// Check to see if the block bitmap indicates that block 'blockno' is free.
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
  8006d2:	39 4a 04             	cmp    %ecx,0x4(%edx)
  8006d5:	76 1d                	jbe    8006f4 <block_is_free+0x37>
		return 0;
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
  8006d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8006dc:	d3 e0                	shl    %cl,%eax
  8006de:	c1 e9 05             	shr    $0x5,%ecx
  8006e1:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  8006e7:	85 04 8a             	test   %eax,(%edx,%ecx,4)
  8006ea:	0f 95 c0             	setne  %al
  8006ed:	eb 05                	jmp    8006f4 <block_is_free+0x37>
// Return 1 if the block is free, 0 if not.
bool
block_is_free(uint32_t blockno)
{
	if (super == 0 || blockno >= super->s_nblocks)
		return 0;
  8006ef:	b8 00 00 00 00       	mov    $0x0,%eax
	if (bitmap[blockno / 32] & (1 << (blockno % 32)))
		return 1;
	return 0;
}
  8006f4:	5d                   	pop    %ebp
  8006f5:	c3                   	ret    

008006f6 <free_block>:

// Mark a block free in the bitmap
void
free_block(uint32_t blockno)
{
  8006f6:	55                   	push   %ebp
  8006f7:	89 e5                	mov    %esp,%ebp
  8006f9:	53                   	push   %ebx
  8006fa:	83 ec 04             	sub    $0x4,%esp
  8006fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
	// Blockno zero is the null pointer of block numbers.
	if (blockno == 0)
  800700:	85 c9                	test   %ecx,%ecx
  800702:	75 14                	jne    800718 <free_block+0x22>
		panic("attempt to free zero block");
  800704:	83 ec 04             	sub    $0x4,%esp
  800707:	68 bb 39 80 00       	push   $0x8039bb
  80070c:	6a 2d                	push   $0x2d
  80070e:	68 86 39 80 00       	push   $0x803986
  800713:	e8 8f 12 00 00       	call   8019a7 <_panic>
	bitmap[blockno/32] |= 1<<(blockno%32);
  800718:	89 cb                	mov    %ecx,%ebx
  80071a:	c1 eb 05             	shr    $0x5,%ebx
  80071d:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  800723:	b8 01 00 00 00       	mov    $0x1,%eax
  800728:	d3 e0                	shl    %cl,%eax
  80072a:	09 04 9a             	or     %eax,(%edx,%ebx,4)
}
  80072d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800730:	c9                   	leave  
  800731:	c3                   	ret    

00800732 <alloc_block>:
// -E_NO_DISK if we are out of blocks.
//
// Hint: use free_block as an example for manipulating the bitmap.
int
alloc_block(void)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	57                   	push   %edi
  800736:	56                   	push   %esi
  800737:	53                   	push   %ebx
  800738:	83 ec 0c             	sub    $0xc,%esp
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	uint32_t blockno = 0;
	for (blockno = 0; blockno != super->s_nblocks * BLKBITSIZE; blockno++) {
  80073b:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800740:	8b 70 04             	mov    0x4(%eax),%esi
  800743:	c1 e6 0f             	shl    $0xf,%esi
  800746:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074b:	eb 58                	jmp    8007a5 <alloc_block+0x73>
			if (block_is_free(blockno)) {
  80074d:	53                   	push   %ebx
  80074e:	e8 6a ff ff ff       	call   8006bd <block_is_free>
  800753:	83 c4 04             	add    $0x4,%esp
  800756:	84 c0                	test   %al,%al
  800758:	74 48                	je     8007a2 <alloc_block+0x70>
				if (blockno == 0)
  80075a:	85 db                	test   %ebx,%ebx
  80075c:	75 14                	jne    800772 <alloc_block+0x40>
					panic("free zero block");
  80075e:	83 ec 04             	sub    $0x4,%esp
  800761:	68 c6 39 80 00       	push   $0x8039c6
  800766:	6a 43                	push   $0x43
  800768:	68 86 39 80 00       	push   $0x803986
  80076d:	e8 35 12 00 00       	call   8019a7 <_panic>
				bitmap[blockno/32] &= ~(1<<(blockno%32));
  800772:	89 df                	mov    %ebx,%edi
  800774:	c1 ef 05             	shr    $0x5,%edi
  800777:	a1 04 a0 80 00       	mov    0x80a004,%eax
  80077c:	89 de                	mov    %ebx,%esi
  80077e:	ba 01 00 00 00       	mov    $0x1,%edx
  800783:	89 d9                	mov    %ebx,%ecx
  800785:	d3 e2                	shl    %cl,%edx
  800787:	f7 d2                	not    %edx
  800789:	21 14 b8             	and    %edx,(%eax,%edi,4)
				flush_block(diskaddr(blockno));
  80078c:	83 ec 0c             	sub    $0xc,%esp
  80078f:	53                   	push   %ebx
  800790:	e8 e8 fb ff ff       	call   80037d <diskaddr>
  800795:	89 04 24             	mov    %eax,(%esp)
  800798:	e8 5e fc ff ff       	call   8003fb <flush_block>
				return blockno;
  80079d:	83 c4 10             	add    $0x10,%esp
  8007a0:	eb 0c                	jmp    8007ae <alloc_block+0x7c>
{
	// The bitmap consists of one or more blocks.  A single bitmap block
	// contains the in-use bits for BLKBITSIZE blocks.  There are
	// super->s_nblocks blocks in the disk altogether.
	uint32_t blockno = 0;
	for (blockno = 0; blockno != super->s_nblocks * BLKBITSIZE; blockno++) {
  8007a2:	83 c3 01             	add    $0x1,%ebx
  8007a5:	39 f3                	cmp    %esi,%ebx
  8007a7:	75 a4                	jne    80074d <alloc_block+0x1b>
				return blockno;
			}
	}
	// LAB 10: Your code here.
	//panic("alloc_block not implemented");
	return -E_NO_DISK;
  8007a9:	be f7 ff ff ff       	mov    $0xfffffff7,%esi
}
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5f                   	pop    %edi
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <file_block_walk>:
//
// Analogy: This is like pgdir_walk for files.
// Hint: Don't forget to clear any block you allocate.
static int
file_block_walk(struct File *f, uint32_t filebno, uint32_t **ppdiskbno, bool alloc)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	57                   	push   %edi
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 0c             	sub    $0xc,%esp
  8007c1:	89 ce                	mov    %ecx,%esi
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	if (filebno < NDIRECT) {
  8007c6:	83 fa 09             	cmp    $0x9,%edx
  8007c9:	77 10                	ja     8007db <file_block_walk+0x23>
		*ppdiskbno = &f->f_direct[filebno];
  8007cb:	8d 84 90 88 00 00 00 	lea    0x88(%eax,%edx,4),%eax
  8007d2:	89 06                	mov    %eax,(%esi)
		return 0;
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8007d9:	eb 7a                	jmp    800855 <file_block_walk+0x9d>
	}
	if (filebno < NDIRECT + NINDIRECT) {
  8007db:	81 fa 09 04 00 00    	cmp    $0x409,%edx
  8007e1:	77 5f                	ja     800842 <file_block_walk+0x8a>
  8007e3:	89 d3                	mov    %edx,%ebx
  8007e5:	89 c7                	mov    %eax,%edi
		if (!f->f_indirect) {
  8007e7:	83 b8 b0 00 00 00 00 	cmpl   $0x0,0xb0(%eax)
  8007ee:	75 2f                	jne    80081f <file_block_walk+0x67>
			if (!alloc)
  8007f0:	84 c9                	test   %cl,%cl
  8007f2:	74 55                	je     800849 <file_block_walk+0x91>
				return -E_NOT_FOUND;
			f->f_indirect = alloc_block();
  8007f4:	e8 39 ff ff ff       	call   800732 <alloc_block>
  8007f9:	89 87 b0 00 00 00    	mov    %eax,0xb0(%edi)
			if (!f->f_indirect)
  8007ff:	85 c0                	test   %eax,%eax
  800801:	74 4d                	je     800850 <file_block_walk+0x98>
				return -E_NO_DISK;
			memset(diskaddr(f->f_indirect), 0, BLKSIZE);
  800803:	83 ec 0c             	sub    $0xc,%esp
  800806:	50                   	push   %eax
  800807:	e8 71 fb ff ff       	call   80037d <diskaddr>
  80080c:	83 c4 0c             	add    $0xc,%esp
  80080f:	68 00 10 00 00       	push   $0x1000
  800814:	6a 00                	push   $0x0
  800816:	50                   	push   %eax
  800817:	e8 2d 19 00 00       	call   802149 <memset>
  80081c:	83 c4 10             	add    $0x10,%esp
		}
		uint32_t *ind_block = (uint32_t *)diskaddr(f->f_indirect);
  80081f:	83 ec 0c             	sub    $0xc,%esp
  800822:	ff b7 b0 00 00 00    	pushl  0xb0(%edi)
  800828:	e8 50 fb ff ff       	call   80037d <diskaddr>
		*ppdiskbno = &ind_block[filebno - NDIRECT];
  80082d:	8d 14 9d d8 ff ff ff 	lea    -0x28(,%ebx,4),%edx
  800834:	01 d0                	add    %edx,%eax
  800836:	89 06                	mov    %eax,(%esi)
		return 0;
  800838:	83 c4 10             	add    $0x10,%esp
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
  800840:	eb 13                	jmp    800855 <file_block_walk+0x9d>
	}
	return -E_INVAL;
  800842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800847:	eb 0c                	jmp    800855 <file_block_walk+0x9d>
		return 0;
	}
	if (filebno < NDIRECT + NINDIRECT) {
		if (!f->f_indirect) {
			if (!alloc)
				return -E_NOT_FOUND;
  800849:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  80084e:	eb 05                	jmp    800855 <file_block_walk+0x9d>
			f->f_indirect = alloc_block();
			if (!f->f_indirect)
				return -E_NO_DISK;
  800850:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
		return 0;
	}
	return -E_INVAL;
		// LAB 10: Your code here.
		//panic("file_block_walk not implemented");
}
  800855:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800858:	5b                   	pop    %ebx
  800859:	5e                   	pop    %esi
  80085a:	5f                   	pop    %edi
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <check_bitmap>:
//
// Check that all reserved blocks -- 0, 1, and the bitmap blocks themselves --
// are all marked as in-use.
void
check_bitmap(void)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	56                   	push   %esi
  800861:	53                   	push   %ebx
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800862:	a1 08 a0 80 00       	mov    0x80a008,%eax
  800867:	8b 70 04             	mov    0x4(%eax),%esi
  80086a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80086f:	eb 29                	jmp    80089a <check_bitmap+0x3d>
  800871:	8d 43 02             	lea    0x2(%ebx),%eax
		assert(!block_is_free(2+i));
  800874:	50                   	push   %eax
  800875:	e8 43 fe ff ff       	call   8006bd <block_is_free>
  80087a:	83 c4 04             	add    $0x4,%esp
  80087d:	84 c0                	test   %al,%al
  80087f:	74 16                	je     800897 <check_bitmap+0x3a>
  800881:	68 d6 39 80 00       	push   $0x8039d6
  800886:	68 bd 37 80 00       	push   $0x8037bd
  80088b:	6a 59                	push   $0x59
  80088d:	68 86 39 80 00       	push   $0x803986
  800892:	e8 10 11 00 00       	call   8019a7 <_panic>
check_bitmap(void)
{
	uint32_t i;

	// Make sure all bitmap blocks are marked in-use
	for (i = 0; i * BLKBITSIZE < super->s_nblocks; i++)
  800897:	83 c3 01             	add    $0x1,%ebx
  80089a:	89 d8                	mov    %ebx,%eax
  80089c:	c1 e0 0f             	shl    $0xf,%eax
  80089f:	39 c6                	cmp    %eax,%esi
  8008a1:	77 ce                	ja     800871 <check_bitmap+0x14>
		assert(!block_is_free(2+i));

	// Make sure the reserved and root blocks are marked in-use.
	assert(!block_is_free(0));
  8008a3:	83 ec 0c             	sub    $0xc,%esp
  8008a6:	6a 00                	push   $0x0
  8008a8:	e8 10 fe ff ff       	call   8006bd <block_is_free>
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	84 c0                	test   %al,%al
  8008b2:	74 16                	je     8008ca <check_bitmap+0x6d>
  8008b4:	68 ea 39 80 00       	push   $0x8039ea
  8008b9:	68 bd 37 80 00       	push   $0x8037bd
  8008be:	6a 5c                	push   $0x5c
  8008c0:	68 86 39 80 00       	push   $0x803986
  8008c5:	e8 dd 10 00 00       	call   8019a7 <_panic>
	assert(!block_is_free(1));
  8008ca:	83 ec 0c             	sub    $0xc,%esp
  8008cd:	6a 01                	push   $0x1
  8008cf:	e8 e9 fd ff ff       	call   8006bd <block_is_free>
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	84 c0                	test   %al,%al
  8008d9:	74 16                	je     8008f1 <check_bitmap+0x94>
  8008db:	68 fc 39 80 00       	push   $0x8039fc
  8008e0:	68 bd 37 80 00       	push   $0x8037bd
  8008e5:	6a 5d                	push   $0x5d
  8008e7:	68 86 39 80 00       	push   $0x803986
  8008ec:	e8 b6 10 00 00       	call   8019a7 <_panic>

	cprintf("bitmap is good\n");
  8008f1:	83 ec 0c             	sub    $0xc,%esp
  8008f4:	68 0e 3a 80 00       	push   $0x803a0e
  8008f9:	e8 82 11 00 00       	call   801a80 <cprintf>
  8008fe:	83 c4 10             	add    $0x10,%esp
}
  800901:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <fs_init>:


// Initialize the file system
void
fs_init(void)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 08             	sub    $0x8,%esp
	static_assert(sizeof(struct File) == 256);

	   // Find a JOS disk.  Use the second IDE disk (number 1) if availabl
	   if (ide_probe_disk1())
  80090e:	e8 4c f7 ff ff       	call   80005f <ide_probe_disk1>
  800913:	84 c0                	test   %al,%al
  800915:	74 0f                	je     800926 <fs_init+0x1e>
			   ide_set_disk(1);
  800917:	83 ec 0c             	sub    $0xc,%esp
  80091a:	6a 01                	push   $0x1
  80091c:	e8 9f f7 ff ff       	call   8000c0 <ide_set_disk>
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	eb 0d                	jmp    800933 <fs_init+0x2b>
	   else
			   ide_set_disk(0);
  800926:	83 ec 0c             	sub    $0xc,%esp
  800929:	6a 00                	push   $0x0
  80092b:	e8 90 f7 ff ff       	call   8000c0 <ide_set_disk>
  800930:	83 c4 10             	add    $0x10,%esp
	bc_init();
  800933:	e8 8d fb ff ff       	call   8004c5 <bc_init>

	// Set "super" to point to the super block.
	super = diskaddr(1);
  800938:	83 ec 0c             	sub    $0xc,%esp
  80093b:	6a 01                	push   $0x1
  80093d:	e8 3b fa ff ff       	call   80037d <diskaddr>
  800942:	a3 08 a0 80 00       	mov    %eax,0x80a008
	check_super();
  800947:	e8 1b fd ff ff       	call   800667 <check_super>

	// Set "bitmap" to the beginning of the first bitmap block.
	bitmap = diskaddr(2);
  80094c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800953:	e8 25 fa ff ff       	call   80037d <diskaddr>
  800958:	a3 04 a0 80 00       	mov    %eax,0x80a004
	check_bitmap();
  80095d:	e8 fb fe ff ff       	call   80085d <check_bitmap>
  800962:	83 c4 10             	add    $0x10,%esp
	
}
  800965:	c9                   	leave  
  800966:	c3                   	ret    

00800967 <file_get_block>:
//	-E_INVAL if filebno is out of range.
//
// Hint: Use file_block_walk and alloc_block.
int
file_get_block(struct File *f, uint32_t filebno, char **blk)
{
  800967:	55                   	push   %ebp
  800968:	89 e5                	mov    %esp,%ebp
  80096a:	53                   	push   %ebx
  80096b:	83 ec 20             	sub    $0x20,%esp
	uint32_t *pdiskbno;
	int r;
	if ((r = file_block_walk(f, filebno, &pdiskbno, 1)))
  80096e:	6a 01                	push   $0x1
  800970:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800973:	8b 55 0c             	mov    0xc(%ebp),%edx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	e8 3a fe ff ff       	call   8007b8 <file_block_walk>
  80097e:	89 c2                	mov    %eax,%edx
  800980:	83 c4 10             	add    $0x10,%esp
  800983:	85 d2                	test   %edx,%edx
  800985:	75 34                	jne    8009bb <file_get_block+0x54>
		return r;
	if (!*pdiskbno)
  800987:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80098a:	8b 13                	mov    (%ebx),%edx
  80098c:	85 d2                	test   %edx,%edx
  80098e:	75 15                	jne    8009a5 <file_get_block+0x3e>
		*pdiskbno = alloc_block();
  800990:	e8 9d fd ff ff       	call   800732 <alloc_block>
  800995:	89 03                	mov    %eax,(%ebx)
	if (!*pdiskbno)
  800997:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80099a:	8b 10                	mov    (%eax),%edx
		return -E_NO_DISK;
  80099c:	b8 f7 ff ff ff       	mov    $0xfffffff7,%eax
	int r;
	if ((r = file_block_walk(f, filebno, &pdiskbno, 1)))
		return r;
	if (!*pdiskbno)
		*pdiskbno = alloc_block();
	if (!*pdiskbno)
  8009a1:	85 d2                	test   %edx,%edx
  8009a3:	74 16                	je     8009bb <file_get_block+0x54>
		return -E_NO_DISK;
	*blk = (char *)diskaddr(*pdiskbno);
  8009a5:	83 ec 0c             	sub    $0xc,%esp
  8009a8:	52                   	push   %edx
  8009a9:	e8 cf f9 ff ff       	call   80037d <diskaddr>
  8009ae:	8b 55 10             	mov    0x10(%ebp),%edx
  8009b1:	89 02                	mov    %eax,(%edx)
	return 0;
  8009b3:	83 c4 10             	add    $0x10,%esp
  8009b6:	b8 00 00 00 00       	mov    $0x0,%eax
	   // LAB 10: Your code here.
	   // panic("file_get_block not implemented");
}
  8009bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <walk_path>:
// If we cannot find the file but find the directory
// it should be in, set *pdir and copy the final path
// element into lastelem.
static int
walk_path(const char *path, struct File **pdir, struct File **pf, char *lastelem)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	81 ec bc 00 00 00    	sub    $0xbc,%esp
  8009cc:	89 95 40 ff ff ff    	mov    %edx,-0xc0(%ebp)
  8009d2:	89 8d 3c ff ff ff    	mov    %ecx,-0xc4(%ebp)
  8009d8:	eb 03                	jmp    8009dd <walk_path+0x1d>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  8009da:	83 c0 01             	add    $0x1,%eax

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  8009dd:	80 38 2f             	cmpb   $0x2f,(%eax)
  8009e0:	74 f8                	je     8009da <walk_path+0x1a>
	int r;

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
  8009e2:	8b 0d 08 a0 80 00    	mov    0x80a008,%ecx
  8009e8:	83 c1 08             	add    $0x8,%ecx
  8009eb:	89 8d 4c ff ff ff    	mov    %ecx,-0xb4(%ebp)
	dir = 0;
	name[0] = 0;
  8009f1:	c6 85 68 ff ff ff 00 	movb   $0x0,-0x98(%ebp)

	if (pdir)
  8009f8:	8b 8d 40 ff ff ff    	mov    -0xc0(%ebp),%ecx
  8009fe:	85 c9                	test   %ecx,%ecx
  800a00:	74 06                	je     800a08 <walk_path+0x48>
		*pdir = 0;
  800a02:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	*pf = 0;
  800a08:	8b 8d 3c ff ff ff    	mov    -0xc4(%ebp),%ecx
  800a0e:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)

	// if (*path != '/')
	//	return -E_BAD_PATH;
	path = skip_slash(path);
	f = &super->s_root;
	dir = 0;
  800a14:	ba 00 00 00 00       	mov    $0x0,%edx
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a19:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800a1f:	e9 58 01 00 00       	jmp    800b7c <walk_path+0x1bc>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
  800a24:	83 c7 01             	add    $0x1,%edi
  800a27:	eb 02                	jmp    800a2b <walk_path+0x6b>
  800a29:	89 c7                	mov    %eax,%edi
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
  800a2b:	0f b6 17             	movzbl (%edi),%edx
  800a2e:	84 d2                	test   %dl,%dl
  800a30:	74 05                	je     800a37 <walk_path+0x77>
  800a32:	80 fa 2f             	cmp    $0x2f,%dl
  800a35:	75 ed                	jne    800a24 <walk_path+0x64>
			path++;
		if (path - p >= MAXNAMELEN)
  800a37:	89 fb                	mov    %edi,%ebx
  800a39:	29 c3                	sub    %eax,%ebx
  800a3b:	83 fb 7f             	cmp    $0x7f,%ebx
  800a3e:	0f 8f 62 01 00 00    	jg     800ba6 <walk_path+0x1e6>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
  800a44:	83 ec 04             	sub    $0x4,%esp
  800a47:	53                   	push   %ebx
  800a48:	50                   	push   %eax
  800a49:	56                   	push   %esi
  800a4a:	e8 47 17 00 00       	call   802196 <memmove>
		name[path - p] = '\0';
  800a4f:	c6 84 1d 68 ff ff ff 	movb   $0x0,-0x98(%ebp,%ebx,1)
  800a56:	00 
  800a57:	83 c4 10             	add    $0x10,%esp
  800a5a:	eb 03                	jmp    800a5f <walk_path+0x9f>
// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
		p++;
  800a5c:	83 c7 01             	add    $0x1,%edi

// Skip over slashes.
static const char*
skip_slash(const char *p)
{
	while (*p == '/')
  800a5f:	80 3f 2f             	cmpb   $0x2f,(%edi)
  800a62:	74 f8                	je     800a5c <walk_path+0x9c>
			return -E_BAD_PATH;
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
  800a64:	8b 85 4c ff ff ff    	mov    -0xb4(%ebp),%eax
  800a6a:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  800a71:	0f 85 36 01 00 00    	jne    800bad <walk_path+0x1ed>
	struct File *f;

	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
  800a77:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
  800a7d:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800a82:	74 19                	je     800a9d <walk_path+0xdd>
  800a84:	68 1e 3a 80 00       	push   $0x803a1e
  800a89:	68 bd 37 80 00       	push   $0x8037bd
  800a8e:	68 d0 00 00 00       	push   $0xd0
  800a93:	68 86 39 80 00       	push   $0x803986
  800a98:	e8 0a 0f 00 00       	call   8019a7 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800a9d:	99                   	cltd   
  800a9e:	c1 ea 14             	shr    $0x14,%edx
  800aa1:	01 d0                	add    %edx,%eax
  800aa3:	c1 f8 0c             	sar    $0xc,%eax
  800aa6:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)
	for (i = 0; i < nblock; i++) {
  800aac:	c7 85 50 ff ff ff 00 	movl   $0x0,-0xb0(%ebp)
  800ab3:	00 00 00 
  800ab6:	89 bd 44 ff ff ff    	mov    %edi,-0xbc(%ebp)
  800abc:	eb 5e                	jmp    800b1c <walk_path+0x15c>
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800abe:	83 ec 04             	sub    $0x4,%esp
  800ac1:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
  800ac7:	50                   	push   %eax
  800ac8:	ff b5 50 ff ff ff    	pushl  -0xb0(%ebp)
  800ace:	ff b5 4c ff ff ff    	pushl  -0xb4(%ebp)
  800ad4:	e8 8e fe ff ff       	call   800967 <file_get_block>
  800ad9:	83 c4 10             	add    $0x10,%esp
  800adc:	85 c0                	test   %eax,%eax
  800ade:	0f 88 ec 00 00 00    	js     800bd0 <walk_path+0x210>
			return r;
		f = (struct File*) blk;
  800ae4:	8b 9d 64 ff ff ff    	mov    -0x9c(%ebp),%ebx
  800aea:	8d bb 00 10 00 00    	lea    0x1000(%ebx),%edi
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800af0:	89 9d 54 ff ff ff    	mov    %ebx,-0xac(%ebp)
  800af6:	83 ec 08             	sub    $0x8,%esp
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
  800afb:	e8 ae 15 00 00       	call   8020ae <strcmp>
  800b00:	83 c4 10             	add    $0x10,%esp
  800b03:	85 c0                	test   %eax,%eax
  800b05:	0f 84 a9 00 00 00    	je     800bb4 <walk_path+0x1f4>
  800b0b:	81 c3 00 01 00 00    	add    $0x100,%ebx
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800b11:	39 fb                	cmp    %edi,%ebx
  800b13:	75 db                	jne    800af0 <walk_path+0x130>
	// Search dir for name.
	// We maintain the invariant that the size of a directory-file
	// is always a multiple of the file system's block size.
	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800b15:	83 85 50 ff ff ff 01 	addl   $0x1,-0xb0(%ebp)
  800b1c:	8b 8d 50 ff ff ff    	mov    -0xb0(%ebp),%ecx
  800b22:	39 8d 48 ff ff ff    	cmp    %ecx,-0xb8(%ebp)
  800b28:	75 94                	jne    800abe <walk_path+0xfe>
  800b2a:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
			if (strcmp(f[j].f_name, name) == 0) {
				*file = &f[j];
				return 0;
			}
	}
	return -E_NOT_FOUND;
  800b30:	bb f5 ff ff ff       	mov    $0xfffffff5,%ebx
  800b35:	e9 9e 00 00 00       	jmp    800bd8 <walk_path+0x218>

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800b3a:	80 3f 00             	cmpb   $0x0,(%edi)
  800b3d:	75 39                	jne    800b78 <walk_path+0x1b8>
				if (pdir)
  800b3f:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b45:	85 c0                	test   %eax,%eax
  800b47:	74 08                	je     800b51 <walk_path+0x191>
					*pdir = dir;
  800b49:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b4f:	89 08                	mov    %ecx,(%eax)
				if (lastelem)
  800b51:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b55:	74 15                	je     800b6c <walk_path+0x1ac>
					strcpy(lastelem, name);
  800b57:	83 ec 08             	sub    $0x8,%esp
  800b5a:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800b60:	50                   	push   %eax
  800b61:	ff 75 08             	pushl  0x8(%ebp)
  800b64:	e8 9b 14 00 00       	call   802004 <strcpy>
  800b69:	83 c4 10             	add    $0x10,%esp
				*pf = 0;
  800b6c:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b72:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
			}
			return r;
  800b78:	89 d8                	mov    %ebx,%eax
  800b7a:	eb 66                	jmp    800be2 <walk_path+0x222>
	name[0] = 0;

	if (pdir)
		*pdir = 0;
	*pf = 0;
	while (*path != '\0') {
  800b7c:	80 38 00             	cmpb   $0x0,(%eax)
  800b7f:	0f 85 a4 fe ff ff    	jne    800a29 <walk_path+0x69>
			}
			return r;
		}
	}

	if (pdir)
  800b85:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	74 02                	je     800b91 <walk_path+0x1d1>
		*pdir = dir;
  800b8f:	89 10                	mov    %edx,(%eax)
	*pf = f;
  800b91:	8b 85 3c ff ff ff    	mov    -0xc4(%ebp),%eax
  800b97:	8b 8d 4c ff ff ff    	mov    -0xb4(%ebp),%ecx
  800b9d:	89 08                	mov    %ecx,(%eax)
	return 0;
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	eb 3c                	jmp    800be2 <walk_path+0x222>
		dir = f;
		p = path;
		while (*path != '/' && *path != '\0')
			path++;
		if (path - p >= MAXNAMELEN)
			return -E_BAD_PATH;
  800ba6:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  800bab:	eb 35                	jmp    800be2 <walk_path+0x222>
		memmove(name, p, path - p);
		name[path - p] = '\0';
		path = skip_slash(path);

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;
  800bad:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800bb2:	eb 2e                	jmp    800be2 <walk_path+0x222>
  800bb4:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800bba:	8b 95 4c ff ff ff    	mov    -0xb4(%ebp),%edx
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
			if (strcmp(f[j].f_name, name) == 0) {
  800bc0:	8b 85 54 ff ff ff    	mov    -0xac(%ebp),%eax
  800bc6:	89 85 4c ff ff ff    	mov    %eax,-0xb4(%ebp)
  800bcc:	89 f8                	mov    %edi,%eax
  800bce:	eb ac                	jmp    800b7c <walk_path+0x1bc>
  800bd0:	8b bd 44 ff ff ff    	mov    -0xbc(%ebp),%edi
  800bd6:	89 c3                	mov    %eax,%ebx

		if (dir->f_type != FTYPE_DIR)
			return -E_NOT_FOUND;

		if ((r = dir_lookup(dir, name, &f)) < 0) {
			if (r == -E_NOT_FOUND && *path == '\0') {
  800bd8:	83 fb f5             	cmp    $0xfffffff5,%ebx
  800bdb:	75 9b                	jne    800b78 <walk_path+0x1b8>
  800bdd:	e9 58 ff ff ff       	jmp    800b3a <walk_path+0x17a>

	if (pdir)
		*pdir = dir;
	*pf = f;
	return 0;
}
  800be2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <file_open>:

// Open "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_open(const char *path, struct File **pf)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	83 ec 14             	sub    $0x14,%esp
	return walk_path(path, 0, pf, 0);
  800bf0:	6a 00                	push   $0x0
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	e8 be fd ff ff       	call   8009c0 <walk_path>
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <file_read>:
// Read count bytes from f into buf, starting from seek position
// offset.  This meant to mimic the standard pread function.
// Returns the number of bytes read, < 0 on error.
ssize_t
file_read(struct File *f, void *buf, size_t count, off_t offset)
{
  800c04:	55                   	push   %ebp
  800c05:	89 e5                	mov    %esp,%ebp
  800c07:	57                   	push   %edi
  800c08:	56                   	push   %esi
  800c09:	53                   	push   %ebx
  800c0a:	83 ec 2c             	sub    $0x2c,%esp
  800c0d:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800c10:	8b 4d 14             	mov    0x14(%ebp),%ecx
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c13:	8b 45 08             	mov    0x8(%ebp),%eax
  800c16:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
		return 0;
  800c1c:	b8 00 00 00 00       	mov    $0x0,%eax
{
	int r, bn;
	off_t pos;
	char *blk;

	if (offset >= f->f_size)
  800c21:	39 ca                	cmp    %ecx,%edx
  800c23:	0f 8e 83 00 00 00    	jle    800cac <file_read+0xa8>
		return 0;

	count = MIN(count, f->f_size - offset);
  800c29:	29 ca                	sub    %ecx,%edx
  800c2b:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800c2e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c31:	76 06                	jbe    800c39 <file_read+0x35>
  800c33:	8b 45 10             	mov    0x10(%ebp),%eax
  800c36:	89 45 d0             	mov    %eax,-0x30(%ebp)

	for (pos = offset; pos < offset + count; ) {
  800c39:	89 cb                	mov    %ecx,%ebx
  800c3b:	03 4d d0             	add    -0x30(%ebp),%ecx
  800c3e:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800c41:	eb 5f                	jmp    800ca2 <file_read+0x9e>
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800c43:	83 ec 04             	sub    $0x4,%esp
  800c46:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800c49:	50                   	push   %eax
  800c4a:	89 d8                	mov    %ebx,%eax
  800c4c:	c1 f8 1f             	sar    $0x1f,%eax
  800c4f:	c1 e8 14             	shr    $0x14,%eax
  800c52:	01 d8                	add    %ebx,%eax
  800c54:	c1 f8 0c             	sar    $0xc,%eax
  800c57:	50                   	push   %eax
  800c58:	ff 75 08             	pushl  0x8(%ebp)
  800c5b:	e8 07 fd ff ff       	call   800967 <file_get_block>
  800c60:	83 c4 10             	add    $0x10,%esp
  800c63:	85 c0                	test   %eax,%eax
  800c65:	78 45                	js     800cac <file_read+0xa8>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800c67:	89 da                	mov    %ebx,%edx
  800c69:	c1 fa 1f             	sar    $0x1f,%edx
  800c6c:	c1 ea 14             	shr    $0x14,%edx
  800c6f:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800c72:	25 ff 0f 00 00       	and    $0xfff,%eax
  800c77:	29 d0                	sub    %edx,%eax
  800c79:	ba 00 10 00 00       	mov    $0x1000,%edx
  800c7e:	29 c2                	sub    %eax,%edx
  800c80:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800c83:	29 f1                	sub    %esi,%ecx
  800c85:	89 d6                	mov    %edx,%esi
  800c87:	39 ca                	cmp    %ecx,%edx
  800c89:	76 02                	jbe    800c8d <file_read+0x89>
  800c8b:	89 ce                	mov    %ecx,%esi
		memmove(buf, blk + pos % BLKSIZE, bn);
  800c8d:	83 ec 04             	sub    $0x4,%esp
  800c90:	56                   	push   %esi
  800c91:	03 45 e4             	add    -0x1c(%ebp),%eax
  800c94:	50                   	push   %eax
  800c95:	57                   	push   %edi
  800c96:	e8 fb 14 00 00       	call   802196 <memmove>
		pos += bn;
  800c9b:	01 f3                	add    %esi,%ebx
		buf += bn;
  800c9d:	01 f7                	add    %esi,%edi
  800c9f:	83 c4 10             	add    $0x10,%esp
	if (offset >= f->f_size)
		return 0;

	count = MIN(count, f->f_size - offset);

	for (pos = offset; pos < offset + count; ) {
  800ca2:	89 de                	mov    %ebx,%esi
  800ca4:	3b 5d d4             	cmp    -0x2c(%ebp),%ebx
  800ca7:	72 9a                	jb     800c43 <file_read+0x3f>
		memmove(buf, blk + pos % BLKSIZE, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800ca9:	8b 45 d0             	mov    -0x30(%ebp),%eax
}
  800cac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5f                   	pop    %edi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <file_set_size>:
}

// Set the size of file f, truncating or extending as necessary.
int
file_set_size(struct File *f, off_t newsize)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 2c             	sub    $0x2c,%esp
  800cbd:	8b 7d 08             	mov    0x8(%ebp),%edi
	if (f->f_size > newsize)
  800cc0:	8b b7 80 00 00 00    	mov    0x80(%edi),%esi
  800cc6:	3b 75 0c             	cmp    0xc(%ebp),%esi
  800cc9:	0f 8e a3 00 00 00    	jle    800d72 <file_set_size+0xbe>
file_truncate_blocks(struct File *f, off_t newsize)
{
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
  800ccf:	81 c6 ff 0f 00 00    	add    $0xfff,%esi
  800cd5:	89 f0                	mov    %esi,%eax
  800cd7:	c1 f8 1f             	sar    $0x1f,%eax
  800cda:	c1 e8 14             	shr    $0x14,%eax
  800cdd:	01 c6                	add    %eax,%esi
  800cdf:	c1 fe 0c             	sar    $0xc,%esi
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
  800ce2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce5:	05 ff 0f 00 00       	add    $0xfff,%eax
  800cea:	99                   	cltd   
  800ceb:	c1 ea 14             	shr    $0x14,%edx
  800cee:	01 d0                	add    %edx,%eax
  800cf0:	c1 f8 0c             	sar    $0xc,%eax
  800cf3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800cf6:	89 c3                	mov    %eax,%ebx
  800cf8:	eb 39                	jmp    800d33 <file_set_size+0x7f>
file_free_block(struct File *f, uint32_t filebno)
{
	int r;
	uint32_t *ptr;

	if ((r = file_block_walk(f, filebno, &ptr, 0)) < 0)
  800cfa:	83 ec 0c             	sub    $0xc,%esp
  800cfd:	6a 00                	push   $0x0
  800cff:	8d 4d e4             	lea    -0x1c(%ebp),%ecx
  800d02:	89 da                	mov    %ebx,%edx
  800d04:	89 f8                	mov    %edi,%eax
  800d06:	e8 ad fa ff ff       	call   8007b8 <file_block_walk>
  800d0b:	83 c4 10             	add    $0x10,%esp
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	78 4d                	js     800d5f <file_set_size+0xab>
		return r;
	if (*ptr) {
  800d12:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d15:	8b 00                	mov    (%eax),%eax
  800d17:	85 c0                	test   %eax,%eax
  800d19:	74 15                	je     800d30 <file_set_size+0x7c>
		free_block(*ptr);
  800d1b:	83 ec 0c             	sub    $0xc,%esp
  800d1e:	50                   	push   %eax
  800d1f:	e8 d2 f9 ff ff       	call   8006f6 <free_block>
		*ptr = 0;
  800d24:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800d27:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  800d2d:	83 c4 10             	add    $0x10,%esp
	int r;
	uint32_t bno, old_nblocks, new_nblocks;

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
  800d30:	83 c3 01             	add    $0x1,%ebx
  800d33:	39 de                	cmp    %ebx,%esi
  800d35:	77 c3                	ja     800cfa <file_set_size+0x46>
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %i", r);

	if (new_nblocks <= NDIRECT && f->f_indirect) {
  800d37:	83 7d d4 0a          	cmpl   $0xa,-0x2c(%ebp)
  800d3b:	77 35                	ja     800d72 <file_set_size+0xbe>
  800d3d:	8b 87 b0 00 00 00    	mov    0xb0(%edi),%eax
  800d43:	85 c0                	test   %eax,%eax
  800d45:	74 2b                	je     800d72 <file_set_size+0xbe>
		free_block(f->f_indirect);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	e8 a6 f9 ff ff       	call   8006f6 <free_block>
		f->f_indirect = 0;
  800d50:	c7 87 b0 00 00 00 00 	movl   $0x0,0xb0(%edi)
  800d57:	00 00 00 
  800d5a:	83 c4 10             	add    $0x10,%esp
  800d5d:	eb 13                	jmp    800d72 <file_set_size+0xbe>

	old_nblocks = (f->f_size + BLKSIZE - 1) / BLKSIZE;
	new_nblocks = (newsize + BLKSIZE - 1) / BLKSIZE;
	for (bno = new_nblocks; bno < old_nblocks; bno++)
		if ((r = file_free_block(f, bno)) < 0)
			cprintf("warning: file_free_block: %i", r);
  800d5f:	83 ec 08             	sub    $0x8,%esp
  800d62:	50                   	push   %eax
  800d63:	68 3b 3a 80 00       	push   $0x803a3b
  800d68:	e8 13 0d 00 00       	call   801a80 <cprintf>
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	eb be                	jmp    800d30 <file_set_size+0x7c>
int
file_set_size(struct File *f, off_t newsize)
{
	if (f->f_size > newsize)
		file_truncate_blocks(f, newsize);
	f->f_size = newsize;
  800d72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d75:	89 87 80 00 00 00    	mov    %eax,0x80(%edi)
	flush_block(f);
  800d7b:	83 ec 0c             	sub    $0xc,%esp
  800d7e:	57                   	push   %edi
  800d7f:	e8 77 f6 ff ff       	call   8003fb <flush_block>
	return 0;
}
  800d84:	b8 00 00 00 00       	mov    $0x0,%eax
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <file_write>:
// offset.  This is meant to mimic the standard pwrite function.
// Extends the file if necessary.
// Returns the number of bytes written, < 0 on error.
int
file_write(struct File *f, const void *buf, size_t count, off_t offset)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 2c             	sub    $0x2c,%esp
  800d9a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800d9d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	int r, bn;
	off_t pos;
	char *blk;

	// Extend file if necessary
	if (offset + count > f->f_size)
  800da0:	89 d8                	mov    %ebx,%eax
  800da2:	03 45 10             	add    0x10(%ebp),%eax
  800da5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800da8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dab:	3b 81 80 00 00 00    	cmp    0x80(%ecx),%eax
  800db1:	76 72                	jbe    800e25 <file_write+0x94>
		if ((r = file_set_size(f, offset + count)) < 0)
  800db3:	83 ec 08             	sub    $0x8,%esp
  800db6:	50                   	push   %eax
  800db7:	51                   	push   %ecx
  800db8:	e8 f7 fe ff ff       	call   800cb4 <file_set_size>
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	78 6b                	js     800e2f <file_write+0x9e>
  800dc4:	eb 5f                	jmp    800e25 <file_write+0x94>
			return r;

	for (pos = offset; pos < offset + count; ) {
		if ((r = file_get_block(f, pos / BLKSIZE, &blk)) < 0)
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800dcc:	50                   	push   %eax
  800dcd:	89 d8                	mov    %ebx,%eax
  800dcf:	c1 f8 1f             	sar    $0x1f,%eax
  800dd2:	c1 e8 14             	shr    $0x14,%eax
  800dd5:	01 d8                	add    %ebx,%eax
  800dd7:	c1 f8 0c             	sar    $0xc,%eax
  800dda:	50                   	push   %eax
  800ddb:	ff 75 08             	pushl  0x8(%ebp)
  800dde:	e8 84 fb ff ff       	call   800967 <file_get_block>
  800de3:	83 c4 10             	add    $0x10,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	78 45                	js     800e2f <file_write+0x9e>
			return r;
		bn = MIN(BLKSIZE - pos % BLKSIZE, offset + count - pos);
  800dea:	89 da                	mov    %ebx,%edx
  800dec:	c1 fa 1f             	sar    $0x1f,%edx
  800def:	c1 ea 14             	shr    $0x14,%edx
  800df2:	8d 04 13             	lea    (%ebx,%edx,1),%eax
  800df5:	25 ff 0f 00 00       	and    $0xfff,%eax
  800dfa:	29 d0                	sub    %edx,%eax
  800dfc:	ba 00 10 00 00       	mov    $0x1000,%edx
  800e01:	29 c2                	sub    %eax,%edx
  800e03:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800e06:	29 f1                	sub    %esi,%ecx
  800e08:	89 d6                	mov    %edx,%esi
  800e0a:	39 ca                	cmp    %ecx,%edx
  800e0c:	76 02                	jbe    800e10 <file_write+0x7f>
  800e0e:	89 ce                	mov    %ecx,%esi
		memmove(blk + pos % BLKSIZE, buf, bn);
  800e10:	83 ec 04             	sub    $0x4,%esp
  800e13:	56                   	push   %esi
  800e14:	57                   	push   %edi
  800e15:	03 45 e4             	add    -0x1c(%ebp),%eax
  800e18:	50                   	push   %eax
  800e19:	e8 78 13 00 00       	call   802196 <memmove>
		pos += bn;
  800e1e:	01 f3                	add    %esi,%ebx
		buf += bn;
  800e20:	01 f7                	add    %esi,%edi
  800e22:	83 c4 10             	add    $0x10,%esp
	// Extend file if necessary
	if (offset + count > f->f_size)
		if ((r = file_set_size(f, offset + count)) < 0)
			return r;

	for (pos = offset; pos < offset + count; ) {
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
  800e2a:	77 9a                	ja     800dc6 <file_write+0x35>
		memmove(blk + pos % BLKSIZE, buf, bn);
		pos += bn;
		buf += bn;
	}

	return count;
  800e2c:	8b 45 10             	mov    0x10(%ebp),%eax
}
  800e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    

00800e37 <file_flush>:
// Loop over all the blocks in file.
// Translate the file block number into a disk block number
// and then check whether that disk block is dirty.  If so, write it out.
void
file_flush(struct File *f)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	56                   	push   %esi
  800e3b:	53                   	push   %ebx
  800e3c:	83 ec 10             	sub    $0x10,%esp
  800e3f:	8b 75 08             	mov    0x8(%ebp),%esi
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e42:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e47:	eb 3c                	jmp    800e85 <file_flush+0x4e>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e49:	83 ec 0c             	sub    $0xc,%esp
  800e4c:	6a 00                	push   $0x0
  800e4e:	8d 4d f4             	lea    -0xc(%ebp),%ecx
  800e51:	89 da                	mov    %ebx,%edx
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	e8 5e f9 ff ff       	call   8007b8 <file_block_walk>
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	85 c0                	test   %eax,%eax
  800e5f:	78 21                	js     800e82 <file_flush+0x4b>
			pdiskbno == NULL || *pdiskbno == 0)
  800e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
  800e64:	85 c0                	test   %eax,%eax
  800e66:	74 1a                	je     800e82 <file_flush+0x4b>
			pdiskbno == NULL || *pdiskbno == 0)
  800e68:	8b 00                	mov    (%eax),%eax
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	74 14                	je     800e82 <file_flush+0x4b>
			continue;
		flush_block(diskaddr(*pdiskbno));
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	50                   	push   %eax
  800e72:	e8 06 f5 ff ff       	call   80037d <diskaddr>
  800e77:	89 04 24             	mov    %eax,(%esp)
  800e7a:	e8 7c f5 ff ff       	call   8003fb <flush_block>
  800e7f:	83 c4 10             	add    $0x10,%esp
file_flush(struct File *f)
{
	int i;
	uint32_t *pdiskbno;

	for (i = 0; i < (f->f_size + BLKSIZE - 1) / BLKSIZE; i++) {
  800e82:	83 c3 01             	add    $0x1,%ebx
  800e85:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800e8b:	8d 88 ff 0f 00 00    	lea    0xfff(%eax),%ecx
  800e91:	89 c8                	mov    %ecx,%eax
  800e93:	c1 f8 1f             	sar    $0x1f,%eax
  800e96:	c1 e8 14             	shr    $0x14,%eax
  800e99:	01 c1                	add    %eax,%ecx
  800e9b:	c1 f9 0c             	sar    $0xc,%ecx
  800e9e:	39 cb                	cmp    %ecx,%ebx
  800ea0:	7c a7                	jl     800e49 <file_flush+0x12>
		if (file_block_walk(f, i, &pdiskbno, 0) < 0 ||
			pdiskbno == NULL || *pdiskbno == 0)
			continue;
		flush_block(diskaddr(*pdiskbno));
	}
	flush_block(f);
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	56                   	push   %esi
  800ea6:	e8 50 f5 ff ff       	call   8003fb <flush_block>
	if (f->f_indirect)
  800eab:	8b 86 b0 00 00 00    	mov    0xb0(%esi),%eax
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	74 14                	je     800ecc <file_flush+0x95>
		flush_block(diskaddr(f->f_indirect));
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	50                   	push   %eax
  800ebc:	e8 bc f4 ff ff       	call   80037d <diskaddr>
  800ec1:	89 04 24             	mov    %eax,(%esp)
  800ec4:	e8 32 f5 ff ff       	call   8003fb <flush_block>
  800ec9:	83 c4 10             	add    $0x10,%esp
}
  800ecc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ecf:	5b                   	pop    %ebx
  800ed0:	5e                   	pop    %esi
  800ed1:	5d                   	pop    %ebp
  800ed2:	c3                   	ret    

00800ed3 <file_create>:

// Create "path".  On success set *pf to point at the file and return 0.
// On error return < 0.
int
file_create(const char *path, struct File **pf)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	81 ec b8 00 00 00    	sub    $0xb8,%esp
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
  800edf:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800ee5:	50                   	push   %eax
  800ee6:	8d 8d 60 ff ff ff    	lea    -0xa0(%ebp),%ecx
  800eec:	8d 95 64 ff ff ff    	lea    -0x9c(%ebp),%edx
  800ef2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef5:	e8 c6 fa ff ff       	call   8009c0 <walk_path>
  800efa:	89 c2                	mov    %eax,%edx
  800efc:	83 c4 10             	add    $0x10,%esp
  800eff:	85 c0                	test   %eax,%eax
  800f01:	0f 84 cc 00 00 00    	je     800fd3 <file_create+0x100>
		return -E_FILE_EXISTS;
	if (r != -E_NOT_FOUND || dir == 0)
  800f07:	83 fa f5             	cmp    $0xfffffff5,%edx
  800f0a:	0f 85 07 01 00 00    	jne    801017 <file_create+0x144>
  800f10:	8b b5 64 ff ff ff    	mov    -0x9c(%ebp),%esi
  800f16:	85 f6                	test   %esi,%esi
  800f18:	0f 84 bc 00 00 00    	je     800fda <file_create+0x107>
	int r;
	uint32_t nblock, i, j;
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
  800f1e:	8b 86 80 00 00 00    	mov    0x80(%esi),%eax
  800f24:	a9 ff 0f 00 00       	test   $0xfff,%eax
  800f29:	74 19                	je     800f44 <file_create+0x71>
  800f2b:	68 1e 3a 80 00       	push   $0x803a1e
  800f30:	68 bd 37 80 00       	push   $0x8037bd
  800f35:	68 e9 00 00 00       	push   $0xe9
  800f3a:	68 86 39 80 00       	push   $0x803986
  800f3f:	e8 63 0a 00 00       	call   8019a7 <_panic>
	nblock = dir->f_size / BLKSIZE;
  800f44:	99                   	cltd   
  800f45:	c1 ea 14             	shr    $0x14,%edx
  800f48:	01 d0                	add    %edx,%eax
  800f4a:	c1 f8 0c             	sar    $0xc,%eax
  800f4d:	89 85 54 ff ff ff    	mov    %eax,-0xac(%ebp)
	for (i = 0; i < nblock; i++) {
  800f53:	bb 00 00 00 00       	mov    $0x0,%ebx
		if ((r = file_get_block(dir, i, &blk)) < 0)
  800f58:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  800f5e:	eb 3b                	jmp    800f9b <file_create+0xc8>
  800f60:	83 ec 04             	sub    $0x4,%esp
  800f63:	57                   	push   %edi
  800f64:	53                   	push   %ebx
  800f65:	56                   	push   %esi
  800f66:	e8 fc f9 ff ff       	call   800967 <file_get_block>
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	0f 88 a1 00 00 00    	js     801017 <file_create+0x144>
			return r;
		f = (struct File*) blk;
  800f76:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800f7c:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
		for (j = 0; j < BLKFILES; j++)
			if (f[j].f_name[0] == '\0') {
  800f82:	80 38 00             	cmpb   $0x0,(%eax)
  800f85:	75 08                	jne    800f8f <file_create+0xbc>
				*file = &f[j];
  800f87:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800f8d:	eb 52                	jmp    800fe1 <file_create+0x10e>
  800f8f:	05 00 01 00 00       	add    $0x100,%eax
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
		if ((r = file_get_block(dir, i, &blk)) < 0)
			return r;
		f = (struct File*) blk;
		for (j = 0; j < BLKFILES; j++)
  800f94:	39 d0                	cmp    %edx,%eax
  800f96:	75 ea                	jne    800f82 <file_create+0xaf>
	char *blk;
	struct File *f;

	assert((dir->f_size % BLKSIZE) == 0);
	nblock = dir->f_size / BLKSIZE;
	for (i = 0; i < nblock; i++) {
  800f98:	83 c3 01             	add    $0x1,%ebx
  800f9b:	39 9d 54 ff ff ff    	cmp    %ebx,-0xac(%ebp)
  800fa1:	75 bd                	jne    800f60 <file_create+0x8d>
			if (f[j].f_name[0] == '\0') {
				*file = &f[j];
				return 0;
			}
	}
	dir->f_size += BLKSIZE;
  800fa3:	81 86 80 00 00 00 00 	addl   $0x1000,0x80(%esi)
  800faa:	10 00 00 
	if ((r = file_get_block(dir, i, &blk)) < 0)
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
  800fb6:	50                   	push   %eax
  800fb7:	53                   	push   %ebx
  800fb8:	56                   	push   %esi
  800fb9:	e8 a9 f9 ff ff       	call   800967 <file_get_block>
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 52                	js     801017 <file_create+0x144>
		return r;
	f = (struct File*) blk;
	*file = &f[0];
  800fc5:	8b 85 5c ff ff ff    	mov    -0xa4(%ebp),%eax
  800fcb:	89 85 60 ff ff ff    	mov    %eax,-0xa0(%ebp)
  800fd1:	eb 0e                	jmp    800fe1 <file_create+0x10e>
	char name[MAXNAMELEN];
	int r;
	struct File *dir, *f;

	if ((r = walk_path(path, &dir, &f, name)) == 0)
		return -E_FILE_EXISTS;
  800fd3:	b8 f3 ff ff ff       	mov    $0xfffffff3,%eax
  800fd8:	eb 3d                	jmp    801017 <file_create+0x144>
	if (r != -E_NOT_FOUND || dir == 0)
		return r;
  800fda:	b8 f5 ff ff ff       	mov    $0xfffffff5,%eax
  800fdf:	eb 36                	jmp    801017 <file_create+0x144>
	if ((r = dir_alloc_file(dir, &f)) < 0)
		return r;

	strcpy(f->f_name, name);
  800fe1:	83 ec 08             	sub    $0x8,%esp
  800fe4:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	ff b5 60 ff ff ff    	pushl  -0xa0(%ebp)
  800ff1:	e8 0e 10 00 00       	call   802004 <strcpy>
	*pf = f;
  800ff6:	8b 95 60 ff ff ff    	mov    -0xa0(%ebp),%edx
  800ffc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fff:	89 10                	mov    %edx,(%eax)
	file_flush(dir);
  801001:	83 c4 04             	add    $0x4,%esp
  801004:	ff b5 64 ff ff ff    	pushl  -0x9c(%ebp)
  80100a:	e8 28 fe ff ff       	call   800e37 <file_flush>
	return 0;
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801017:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101a:	5b                   	pop    %ebx
  80101b:	5e                   	pop    %esi
  80101c:	5f                   	pop    %edi
  80101d:	5d                   	pop    %ebp
  80101e:	c3                   	ret    

0080101f <fs_sync>:


// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
  80101f:	55                   	push   %ebp
  801020:	89 e5                	mov    %esp,%ebp
  801022:	53                   	push   %ebx
  801023:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  801026:	bb 01 00 00 00       	mov    $0x1,%ebx
  80102b:	eb 17                	jmp    801044 <fs_sync+0x25>
		flush_block(diskaddr(i));
  80102d:	83 ec 0c             	sub    $0xc,%esp
  801030:	53                   	push   %ebx
  801031:	e8 47 f3 ff ff       	call   80037d <diskaddr>
  801036:	89 04 24             	mov    %eax,(%esp)
  801039:	e8 bd f3 ff ff       	call   8003fb <flush_block>
// Sync the entire file system.  A big hammer.
void
fs_sync(void)
{
	int i;
	for (i = 1; i < super->s_nblocks; i++)
  80103e:	83 c3 01             	add    $0x1,%ebx
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	a1 08 a0 80 00       	mov    0x80a008,%eax
  801049:	3b 58 04             	cmp    0x4(%eax),%ebx
  80104c:	72 df                	jb     80102d <fs_sync+0xe>
		flush_block(diskaddr(i));
}
  80104e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801051:	c9                   	leave  
  801052:	c3                   	ret    

00801053 <serve_sync>:
}


int
serve_sync(envid_t envid, union Fsipc *req)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	83 ec 08             	sub    $0x8,%esp
	fs_sync();
  801059:	e8 c1 ff ff ff       	call   80101f <fs_sync>
	return 0;
}
  80105e:	b8 00 00 00 00       	mov    $0x0,%eax
  801063:	c9                   	leave  
  801064:	c3                   	ret    

00801065 <serve_init>:
// Virtual address at which to receive page mappings containing client requests.
union Fsipc *fsreq = (union Fsipc *)0x0ffff000;

void
serve_init(void)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	ba 80 50 80 00       	mov    $0x805080,%edx
	int i;
	uintptr_t va = FILEVA;
  80106d:	b9 00 00 00 d0       	mov    $0xd0000000,%ecx
	for (i = 0; i < MAXOPEN; i++) {
  801072:	b8 00 00 00 00       	mov    $0x0,%eax
		opentab[i].o_fileid = i;
  801077:	89 02                	mov    %eax,(%edx)
		opentab[i].o_fd = (struct Fd*) va;
  801079:	89 4a 0c             	mov    %ecx,0xc(%edx)
		va += PGSIZE;
  80107c:	81 c1 00 10 00 00    	add    $0x1000,%ecx
void
serve_init(void)
{
	int i;
	uintptr_t va = FILEVA;
	for (i = 0; i < MAXOPEN; i++) {
  801082:	83 c0 01             	add    $0x1,%eax
  801085:	83 c2 10             	add    $0x10,%edx
  801088:	3d 00 04 00 00       	cmp    $0x400,%eax
  80108d:	75 e8                	jne    801077 <serve_init+0x12>
		opentab[i].o_fileid = i;
		opentab[i].o_fd = (struct Fd*) va;
		va += PGSIZE;
	}
}
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    

00801091 <openfile_alloc>:

// Allocate an open file.
int
openfile_alloc(struct OpenFile **o)
{
  801091:	55                   	push   %ebp
  801092:	89 e5                	mov    %esp,%ebp
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	8b 75 08             	mov    0x8(%ebp),%esi
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801099:	bb 00 00 00 00       	mov    $0x0,%ebx
		switch (pageref(opentab[i].o_fd)) {
  80109e:	83 ec 0c             	sub    $0xc,%esp
  8010a1:	89 d8                	mov    %ebx,%eax
  8010a3:	c1 e0 04             	shl    $0x4,%eax
  8010a6:	ff b0 8c 50 80 00    	pushl  0x80508c(%eax)
  8010ac:	e8 01 1f 00 00       	call   802fb2 <pageref>
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	74 07                	je     8010bf <openfile_alloc+0x2e>
  8010b8:	83 f8 01             	cmp    $0x1,%eax
  8010bb:	74 22                	je     8010df <openfile_alloc+0x4e>
  8010bd:	eb 53                	jmp    801112 <openfile_alloc+0x81>
		case 0:
			if ((r = sys_page_alloc(0, opentab[i].o_fd, PTE_P|PTE_U|PTE_W)) < 0)
  8010bf:	83 ec 04             	sub    $0x4,%esp
  8010c2:	6a 07                	push   $0x7
  8010c4:	89 d8                	mov    %ebx,%eax
  8010c6:	c1 e0 04             	shl    $0x4,%eax
  8010c9:	ff b0 8c 50 80 00    	pushl  0x80508c(%eax)
  8010cf:	6a 00                	push   $0x0
  8010d1:	e8 38 13 00 00       	call   80240e <sys_page_alloc>
  8010d6:	89 c2                	mov    %eax,%edx
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	85 d2                	test   %edx,%edx
  8010dd:	78 43                	js     801122 <openfile_alloc+0x91>
				return r;
			/* fall through */
		case 1:
			opentab[i].o_fileid += MAXOPEN;
  8010df:	c1 e3 04             	shl    $0x4,%ebx
  8010e2:	8d 83 80 50 80 00    	lea    0x805080(%ebx),%eax
  8010e8:	81 83 80 50 80 00 00 	addl   $0x400,0x805080(%ebx)
  8010ef:	04 00 00 
			*o = &opentab[i];
  8010f2:	89 06                	mov    %eax,(%esi)
			memset(opentab[i].o_fd, 0, PGSIZE);
  8010f4:	83 ec 04             	sub    $0x4,%esp
  8010f7:	68 00 10 00 00       	push   $0x1000
  8010fc:	6a 00                	push   $0x0
  8010fe:	ff b3 8c 50 80 00    	pushl  0x80508c(%ebx)
  801104:	e8 40 10 00 00       	call   802149 <memset>
			return (*o)->o_fileid;
  801109:	8b 06                	mov    (%esi),%eax
  80110b:	8b 00                	mov    (%eax),%eax
  80110d:	83 c4 10             	add    $0x10,%esp
  801110:	eb 10                	jmp    801122 <openfile_alloc+0x91>
openfile_alloc(struct OpenFile **o)
{
	int i, r;

	// Find an available open-file table entry
	for (i = 0; i < MAXOPEN; i++) {
  801112:	83 c3 01             	add    $0x1,%ebx
  801115:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80111b:	75 81                	jne    80109e <openfile_alloc+0xd>
			*o = &opentab[i];
			memset(opentab[i].o_fd, 0, PGSIZE);
			return (*o)->o_fileid;
		}
	}
	return -E_MAX_OPEN;
  80111d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5d                   	pop    %ebp
  801128:	c3                   	ret    

00801129 <openfile_lookup>:

// Look up an open file for envid.
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	57                   	push   %edi
  80112d:	56                   	push   %esi
  80112e:	53                   	push   %ebx
  80112f:	83 ec 18             	sub    $0x18,%esp
  801132:	8b 7d 0c             	mov    0xc(%ebp),%edi
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801135:	89 fb                	mov    %edi,%ebx
  801137:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  80113d:	89 de                	mov    %ebx,%esi
  80113f:	c1 e6 04             	shl    $0x4,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  801142:	ff b6 8c 50 80 00    	pushl  0x80508c(%esi)
int
openfile_lookup(envid_t envid, uint32_t fileid, struct OpenFile **po)
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
  801148:	81 c6 80 50 80 00    	add    $0x805080,%esi
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
  80114e:	e8 5f 1e 00 00       	call   802fb2 <pageref>
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	83 f8 01             	cmp    $0x1,%eax
  801159:	7e 17                	jle    801172 <openfile_lookup+0x49>
  80115b:	c1 e3 04             	shl    $0x4,%ebx
  80115e:	39 bb 80 50 80 00    	cmp    %edi,0x805080(%ebx)
  801164:	75 13                	jne    801179 <openfile_lookup+0x50>
		return -E_INVAL;
	*po = o;
  801166:	8b 45 10             	mov    0x10(%ebp),%eax
  801169:	89 30                	mov    %esi,(%eax)
	return 0;
  80116b:	b8 00 00 00 00       	mov    $0x0,%eax
  801170:	eb 0c                	jmp    80117e <openfile_lookup+0x55>
{
	struct OpenFile *o;

	o = &opentab[fileid % MAXOPEN];
	if (pageref(o->o_fd) <= 1 || o->o_fileid != fileid)
		return -E_INVAL;
  801172:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801177:	eb 05                	jmp    80117e <openfile_lookup+0x55>
  801179:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	*po = o;
	return 0;
}
  80117e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    

00801186 <serve_set_size>:

// Set the size of req->req_fileid to req->req_size bytes, truncating
// or extending the file as necessary.
int
serve_set_size(envid_t envid, struct Fsreq_set_size *req)
{
  801186:	55                   	push   %ebp
  801187:	89 e5                	mov    %esp,%ebp
  801189:	53                   	push   %ebx
  80118a:	83 ec 18             	sub    $0x18,%esp
  80118d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Every file system IPC call has the same general structure.
	// Here's how it goes.

	// First, use openfile_lookup to find the relevant open file.
	// On failure, return the error code to the client with ipc_send.
	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  801190:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801193:	50                   	push   %eax
  801194:	ff 33                	pushl  (%ebx)
  801196:	ff 75 08             	pushl  0x8(%ebp)
  801199:	e8 8b ff ff ff       	call   801129 <openfile_lookup>
  80119e:	89 c2                	mov    %eax,%edx
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	85 d2                	test   %edx,%edx
  8011a5:	78 14                	js     8011bb <serve_set_size+0x35>
		return r;

	// Second, call the relevant file system function (from fs/fs.c).
	// On failure, return the error code to the client.
	return file_set_size(o->o_file, req->req_size);
  8011a7:	83 ec 08             	sub    $0x8,%esp
  8011aa:	ff 73 04             	pushl  0x4(%ebx)
  8011ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b0:	ff 70 04             	pushl  0x4(%eax)
  8011b3:	e8 fc fa ff ff       	call   800cb4 <file_set_size>
  8011b8:	83 c4 10             	add    $0x10,%esp
}
  8011bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011be:	c9                   	leave  
  8011bf:	c3                   	ret    

008011c0 <serve_read>:
// in ipc->read.req_fileid.  Return the bytes read from the file to
// the caller in ipc->readRet, then update the seek position.  Returns
// the number of bytes successfully read, or < 0 on error.
int
serve_read(envid_t envid, union Fsipc *ipc)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 14             	sub    $0x14,%esp
  8011c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fsreq_read *req = &ipc->read;
	struct Fsret_read *ret = &ipc->readRet;
 	struct OpenFile *open = NULL;
  8011cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int res;
	if ((res = openfile_lookup(envid, ipc->read.req_fileid, &open)))
  8011d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	ff 33                	pushl  (%ebx)
  8011d8:	ff 75 08             	pushl  0x8(%ebp)
  8011db:	e8 49 ff ff ff       	call   801129 <openfile_lookup>
  8011e0:	83 c4 10             	add    $0x10,%esp
        	return res;
  8011e3:	89 c2                	mov    %eax,%edx
{
	struct Fsreq_read *req = &ipc->read;
	struct Fsret_read *ret = &ipc->readRet;
 	struct OpenFile *open = NULL;
	int res;
	if ((res = openfile_lookup(envid, ipc->read.req_fileid, &open)))
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	75 32                	jne    80121b <serve_read+0x5b>
        	return res;
	struct File *file = open->o_file;
  8011e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
    	struct Fd *fd = open->o_fd;
  8011ec:	8b 72 0c             	mov    0xc(%edx),%esi
	size_t readsize = req->req_n < PGSIZE ? req->req_n : PGSIZE;
	ssize_t read;
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
   	if ((read = file_read(file, ret->ret_buf, readsize, fd->fd_offset)) < 0)
  8011ef:	ff 76 04             	pushl  0x4(%esi)
	int res;
	if ((res = openfile_lookup(envid, ipc->read.req_fileid, &open)))
        	return res;
	struct File *file = open->o_file;
    	struct Fd *fd = open->o_fd;
	size_t readsize = req->req_n < PGSIZE ? req->req_n : PGSIZE;
  8011f2:	8b 43 04             	mov    0x4(%ebx),%eax
  8011f5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8011fa:	76 05                	jbe    801201 <serve_read+0x41>
  8011fc:	b8 00 10 00 00       	mov    $0x1000,%eax
	ssize_t read;
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
   	if ((read = file_read(file, ret->ret_buf, readsize, fd->fd_offset)) < 0)
  801201:	50                   	push   %eax
  801202:	53                   	push   %ebx
  801203:	ff 72 04             	pushl  0x4(%edx)
  801206:	e8 f9 f9 ff ff       	call   800c04 <file_read>
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 07                	js     801219 <serve_read+0x59>
	        return read;
	fd->fd_offset += read;
  801212:	01 46 04             	add    %eax,0x4(%esi)
	return read;
  801215:	89 c2                	mov    %eax,%edx
  801217:	eb 02                	jmp    80121b <serve_read+0x5b>
	size_t readsize = req->req_n < PGSIZE ? req->req_n : PGSIZE;
	ssize_t read;
	if (debug)
		cprintf("serve_read %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
   	if ((read = file_read(file, ret->ret_buf, readsize, fd->fd_offset)) < 0)
	        return read;
  801219:	89 c2                	mov    %eax,%edx
	fd->fd_offset += read;
	return read;
	// Lab 10: Your code here:
}
  80121b:	89 d0                	mov    %edx,%eax
  80121d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801220:	5b                   	pop    %ebx
  801221:	5e                   	pop    %esi
  801222:	5d                   	pop    %ebp
  801223:	c3                   	ret    

00801224 <serve_write>:
// the current seek position, and update the seek position
// accordingly.  Extend the file if necessary.  Returns the number of
// bytes written, or < 0 on error.
int
serve_write(envid_t envid, struct Fsreq_write *req)
{
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	56                   	push   %esi
  801228:	53                   	push   %ebx
  801229:	83 ec 14             	sub    $0x14,%esp
  80122c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
	struct OpenFile *open = NULL;
  80122f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	int res;
	if ((res = openfile_lookup(envid, req->req_fileid, &open)))
  801236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	ff 33                	pushl  (%ebx)
  80123c:	ff 75 08             	pushl  0x8(%ebp)
  80123f:	e8 e5 fe ff ff       	call   801129 <openfile_lookup>
  801244:	83 c4 10             	add    $0x10,%esp
        	return res;
  801247:	89 c2                	mov    %eax,%edx
{
	if (debug)
		cprintf("serve_write %08x %08x %08x\n", envid, req->req_fileid, req->req_n);
	struct OpenFile *open = NULL;
	int res;
	if ((res = openfile_lookup(envid, req->req_fileid, &open)))
  801249:	85 c0                	test   %eax,%eax
  80124b:	75 49                	jne    801296 <serve_write+0x72>
        	return res;
	struct File *file = open->o_file;
  80124d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801250:	8b 50 04             	mov    0x4(%eax),%edx
    	struct Fd *fd = open->o_fd;
  801253:	8b 70 0c             	mov    0xc(%eax),%esi
	size_t writesize = req->req_n < PGSIZE ? req->req_n : PGSIZE;
  801256:	8b 43 04             	mov    0x4(%ebx),%eax
  801259:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80125e:	76 05                	jbe    801265 <serve_write+0x41>
  801260:	b8 00 10 00 00       	mov    $0x1000,%eax
	ssize_t write;
	if (fd->fd_offset + writesize > file->f_size)
  801265:	89 c1                	mov    %eax,%ecx
  801267:	03 4e 04             	add    0x4(%esi),%ecx
  80126a:	3b 8a 80 00 00 00    	cmp    0x80(%edx),%ecx
  801270:	76 06                	jbe    801278 <serve_write+0x54>
	        file->f_size = fd->fd_offset + writesize;
  801272:	89 8a 80 00 00 00    	mov    %ecx,0x80(%edx)
	if ((write = file_write(file, req->req_buf, writesize, fd->fd_offset)) < 0)
  801278:	ff 76 04             	pushl  0x4(%esi)
  80127b:	50                   	push   %eax
  80127c:	83 c3 08             	add    $0x8,%ebx
  80127f:	53                   	push   %ebx
  801280:	52                   	push   %edx
  801281:	e8 0b fb ff ff       	call   800d91 <file_write>
  801286:	83 c4 10             	add    $0x10,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 07                	js     801294 <serve_write+0x70>
        	return write;
	fd->fd_offset += write;
  80128d:	01 46 04             	add    %eax,0x4(%esi)
	return write;
  801290:	89 c2                	mov    %eax,%edx
  801292:	eb 02                	jmp    801296 <serve_write+0x72>
	size_t writesize = req->req_n < PGSIZE ? req->req_n : PGSIZE;
	ssize_t write;
	if (fd->fd_offset + writesize > file->f_size)
	        file->f_size = fd->fd_offset + writesize;
	if ((write = file_write(file, req->req_buf, writesize, fd->fd_offset)) < 0)
        	return write;
  801294:	89 c2                	mov    %eax,%edx
	fd->fd_offset += write;
	return write;
	// LAB 10: Your code here.
	//panic("serve_write not implemented");
}
  801296:	89 d0                	mov    %edx,%eax
  801298:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80129b:	5b                   	pop    %ebx
  80129c:	5e                   	pop    %esi
  80129d:	5d                   	pop    %ebp
  80129e:	c3                   	ret    

0080129f <serve_stat>:

// Stat ipc->stat.req_fileid.  Return the file's struct Stat to the
// caller in ipc->statRet.
int
serve_stat(envid_t envid, union Fsipc *ipc)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	53                   	push   %ebx
  8012a3:	83 ec 18             	sub    $0x18,%esp
  8012a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	if (debug)
		cprintf("serve_stat %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  8012a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ac:	50                   	push   %eax
  8012ad:	ff 33                	pushl  (%ebx)
  8012af:	ff 75 08             	pushl  0x8(%ebp)
  8012b2:	e8 72 fe ff ff       	call   801129 <openfile_lookup>
  8012b7:	89 c2                	mov    %eax,%edx
  8012b9:	83 c4 10             	add    $0x10,%esp
  8012bc:	85 d2                	test   %edx,%edx
  8012be:	78 3f                	js     8012ff <serve_stat+0x60>
		return r;

	strcpy(ret->ret_name, o->o_file->f_name);
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c6:	ff 70 04             	pushl  0x4(%eax)
  8012c9:	53                   	push   %ebx
  8012ca:	e8 35 0d 00 00       	call   802004 <strcpy>
	ret->ret_size = o->o_file->f_size;
  8012cf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012d2:	8b 50 04             	mov    0x4(%eax),%edx
  8012d5:	8b 92 80 00 00 00    	mov    0x80(%edx),%edx
  8012db:	89 93 80 00 00 00    	mov    %edx,0x80(%ebx)
	ret->ret_isdir = (o->o_file->f_type == FTYPE_DIR);
  8012e1:	8b 40 04             	mov    0x4(%eax),%eax
  8012e4:	83 c4 10             	add    $0x10,%esp
  8012e7:	83 b8 84 00 00 00 01 	cmpl   $0x1,0x84(%eax)
  8012ee:	0f 94 c0             	sete   %al
  8012f1:	0f b6 c0             	movzbl %al,%eax
  8012f4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801302:	c9                   	leave  
  801303:	c3                   	ret    

00801304 <serve_flush>:

// Flush all data and metadata of req->req_fileid to disk.
int
serve_flush(envid_t envid, struct Fsreq_flush *req)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	if (debug)
		cprintf("serve_flush %08x %08x\n", envid, req->req_fileid);

	if ((r = openfile_lookup(envid, req->req_fileid, &o)) < 0)
  80130a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801311:	ff 30                	pushl  (%eax)
  801313:	ff 75 08             	pushl  0x8(%ebp)
  801316:	e8 0e fe ff ff       	call   801129 <openfile_lookup>
  80131b:	89 c2                	mov    %eax,%edx
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 d2                	test   %edx,%edx
  801322:	78 16                	js     80133a <serve_flush+0x36>
		return r;
	file_flush(o->o_file);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132a:	ff 70 04             	pushl  0x4(%eax)
  80132d:	e8 05 fb ff ff       	call   800e37 <file_flush>
	return 0;
  801332:	83 c4 10             	add    $0x10,%esp
  801335:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80133a:	c9                   	leave  
  80133b:	c3                   	ret    

0080133c <serve_open>:
// permissions to return to the calling environment in *pg_store and
// *perm_store respectively.
int
serve_open(envid_t envid, struct Fsreq_open *req,
	   void **pg_store, int *perm_store)
{
  80133c:	55                   	push   %ebp
  80133d:	89 e5                	mov    %esp,%ebp
  80133f:	53                   	push   %ebx
  801340:	81 ec 18 04 00 00    	sub    $0x418,%esp
  801346:	8b 5d 0c             	mov    0xc(%ebp),%ebx

	if (debug)
		cprintf("serve_open %08x %s 0x%x\n", envid, req->req_path, req->req_omode);

	// Copy in the path, making sure it's null-terminated
	memmove(path, req->req_path, MAXPATHLEN);
  801349:	68 00 04 00 00       	push   $0x400
  80134e:	53                   	push   %ebx
  80134f:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801355:	50                   	push   %eax
  801356:	e8 3b 0e 00 00       	call   802196 <memmove>
	path[MAXPATHLEN-1] = 0;
  80135b:	c6 45 f7 00          	movb   $0x0,-0x9(%ebp)

	// Find an open file ID
	if ((r = openfile_alloc(&o)) < 0) {
  80135f:	8d 85 f0 fb ff ff    	lea    -0x410(%ebp),%eax
  801365:	89 04 24             	mov    %eax,(%esp)
  801368:	e8 24 fd ff ff       	call   801091 <openfile_alloc>
  80136d:	83 c4 10             	add    $0x10,%esp
  801370:	85 c0                	test   %eax,%eax
  801372:	0f 88 f0 00 00 00    	js     801468 <serve_open+0x12c>
		return r;
	}
	fileid = r;

	// Open the file
	if (req->req_omode & O_CREAT) {
  801378:	f6 83 01 04 00 00 01 	testb  $0x1,0x401(%ebx)
  80137f:	74 33                	je     8013b4 <serve_open+0x78>
		if ((r = file_create(path, &f)) < 0) {
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  80138a:	50                   	push   %eax
  80138b:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	e8 3c fb ff ff       	call   800ed3 <file_create>
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	85 c0                	test   %eax,%eax
  80139c:	79 37                	jns    8013d5 <serve_open+0x99>
			if (!(req->req_omode & O_EXCL) && r == -E_FILE_EXISTS)
  80139e:	83 f8 f3             	cmp    $0xfffffff3,%eax
  8013a1:	0f 85 c1 00 00 00    	jne    801468 <serve_open+0x12c>
  8013a7:	f6 83 01 04 00 00 04 	testb  $0x4,0x401(%ebx)
  8013ae:	0f 85 b4 00 00 00    	jne    801468 <serve_open+0x12c>
				cprintf("file_create failed: %i", r);
			return r;
		}
	} else {
try_open:
		if ((r = file_open(path, &f)) < 0) {
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013bd:	50                   	push   %eax
  8013be:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  8013c4:	50                   	push   %eax
  8013c5:	e8 20 f8 ff ff       	call   800bea <file_open>
  8013ca:	83 c4 10             	add    $0x10,%esp
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	0f 88 93 00 00 00    	js     801468 <serve_open+0x12c>
			return r;
		}
	}

	// Truncate
	if (req->req_omode & O_TRUNC) {
  8013d5:	f6 83 01 04 00 00 02 	testb  $0x2,0x401(%ebx)
  8013dc:	74 17                	je     8013f5 <serve_open+0xb9>
		if ((r = file_set_size(f, 0)) < 0) {
  8013de:	83 ec 08             	sub    $0x8,%esp
  8013e1:	6a 00                	push   $0x0
  8013e3:	ff b5 f4 fb ff ff    	pushl  -0x40c(%ebp)
  8013e9:	e8 c6 f8 ff ff       	call   800cb4 <file_set_size>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 73                	js     801468 <serve_open+0x12c>
			if (debug)
				cprintf("file_set_size failed: %i", r);
			return r;
		}
	}
	if ((r = file_open(path, &f)) < 0) {
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	8d 85 f4 fb ff ff    	lea    -0x40c(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	8d 85 f8 fb ff ff    	lea    -0x408(%ebp),%eax
  801405:	50                   	push   %eax
  801406:	e8 df f7 ff ff       	call   800bea <file_open>
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 56                	js     801468 <serve_open+0x12c>
			cprintf("file_open failed: %i", r);
		return r;
	}

	// Save the file pointer
	o->o_file = f;
  801412:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801418:	8b 95 f4 fb ff ff    	mov    -0x40c(%ebp),%edx
  80141e:	89 50 04             	mov    %edx,0x4(%eax)

	// Fill out the Fd structure
	o->o_fd->fd_file.id = o->o_fileid;
  801421:	8b 50 0c             	mov    0xc(%eax),%edx
  801424:	8b 08                	mov    (%eax),%ecx
  801426:	89 4a 0c             	mov    %ecx,0xc(%edx)
	o->o_fd->fd_omode = req->req_omode & O_ACCMODE;
  801429:	8b 48 0c             	mov    0xc(%eax),%ecx
  80142c:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  801432:	83 e2 03             	and    $0x3,%edx
  801435:	89 51 08             	mov    %edx,0x8(%ecx)
	o->o_fd->fd_dev_id = devfile.dev_id;
  801438:	8b 40 0c             	mov    0xc(%eax),%eax
  80143b:	8b 15 84 90 80 00    	mov    0x809084,%edx
  801441:	89 10                	mov    %edx,(%eax)
	o->o_mode = req->req_omode;
  801443:	8b 85 f0 fb ff ff    	mov    -0x410(%ebp),%eax
  801449:	8b 93 00 04 00 00    	mov    0x400(%ebx),%edx
  80144f:	89 50 08             	mov    %edx,0x8(%eax)
	if (debug)
		cprintf("sending success, page %08x\n", (uintptr_t) o->o_fd);

	// Share the FD page with the caller by setting *pg_store,
	// store its permission in *perm_store
	*pg_store = o->o_fd;
  801452:	8b 50 0c             	mov    0xc(%eax),%edx
  801455:	8b 45 10             	mov    0x10(%ebp),%eax
  801458:	89 10                	mov    %edx,(%eax)
	*perm_store = PTE_P|PTE_U|PTE_W|PTE_SHARE;
  80145a:	8b 45 14             	mov    0x14(%ebp),%eax
  80145d:	c7 00 07 04 00 00    	movl   $0x407,(%eax)

	return 0;
  801463:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801468:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <serve>:
};
#define NHANDLERS (sizeof(handlers)/sizeof(handlers[0]))

void
serve(void)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
  801472:	83 ec 10             	sub    $0x10,%esp
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801475:	8d 5d f0             	lea    -0x10(%ebp),%ebx
  801478:	8d 75 f4             	lea    -0xc(%ebp),%esi
	uint32_t req, whom;
	int perm, r;
	void *pg;

	while (1) {
		perm = 0;
  80147b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
		req = ipc_recv((int32_t *) &whom, fsreq, &perm);
  801482:	83 ec 04             	sub    $0x4,%esp
  801485:	53                   	push   %ebx
  801486:	ff 35 64 50 80 00    	pushl  0x805064
  80148c:	56                   	push   %esi
  80148d:	e8 23 12 00 00       	call   8026b5 <ipc_recv>
		if (debug)
			cprintf("fs req %d from %08x [page %08x: %s]\n",
				req, whom, uvpt[PGNUM(fsreq)], (char *) fsreq);

		// All requests must contain an argument page
		if (!(perm & PTE_P)) {
  801492:	83 c4 10             	add    $0x10,%esp
  801495:	f6 45 f0 01          	testb  $0x1,-0x10(%ebp)
  801499:	75 15                	jne    8014b0 <serve+0x43>
			cprintf("Invalid request from %08x: no argument page\n",
  80149b:	83 ec 08             	sub    $0x8,%esp
  80149e:	ff 75 f4             	pushl  -0xc(%ebp)
  8014a1:	68 58 3a 80 00       	push   $0x803a58
  8014a6:	e8 d5 05 00 00       	call   801a80 <cprintf>
				whom);
			continue; // just leave it hanging...
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb cb                	jmp    80147b <serve+0xe>
		}

		pg = NULL;
  8014b0:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
		if (req == FSREQ_OPEN) {
  8014b7:	83 f8 01             	cmp    $0x1,%eax
  8014ba:	75 18                	jne    8014d4 <serve+0x67>
			r = serve_open(whom, (struct Fsreq_open*)fsreq, &pg, &perm);
  8014bc:	53                   	push   %ebx
  8014bd:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8014c0:	50                   	push   %eax
  8014c1:	ff 35 64 50 80 00    	pushl  0x805064
  8014c7:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ca:	e8 6d fe ff ff       	call   80133c <serve_open>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	eb 3c                	jmp    801510 <serve+0xa3>
		} else if (req < NHANDLERS && handlers[req]) {
  8014d4:	83 f8 08             	cmp    $0x8,%eax
  8014d7:	77 1e                	ja     8014f7 <serve+0x8a>
  8014d9:	8b 14 85 40 50 80 00 	mov    0x805040(,%eax,4),%edx
  8014e0:	85 d2                	test   %edx,%edx
  8014e2:	74 13                	je     8014f7 <serve+0x8a>
			r = handlers[req](whom, fsreq);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	ff 35 64 50 80 00    	pushl  0x805064
  8014ed:	ff 75 f4             	pushl  -0xc(%ebp)
  8014f0:	ff d2                	call   *%edx
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	eb 19                	jmp    801510 <serve+0xa3>
		} else {
			cprintf("Invalid request code %d from %08x\n", req, whom);
  8014f7:	83 ec 04             	sub    $0x4,%esp
  8014fa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014fd:	50                   	push   %eax
  8014fe:	68 88 3a 80 00       	push   $0x803a88
  801503:	e8 78 05 00 00       	call   801a80 <cprintf>
  801508:	83 c4 10             	add    $0x10,%esp
			r = -E_INVAL;
  80150b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		}
		ipc_send(whom, r, pg, perm);
  801510:	ff 75 f0             	pushl  -0x10(%ebp)
  801513:	ff 75 ec             	pushl  -0x14(%ebp)
  801516:	50                   	push   %eax
  801517:	ff 75 f4             	pushl  -0xc(%ebp)
  80151a:	e8 fc 11 00 00       	call   80271b <ipc_send>
		sys_page_unmap(0, fsreq);
  80151f:	83 c4 08             	add    $0x8,%esp
  801522:	ff 35 64 50 80 00    	pushl  0x805064
  801528:	6a 00                	push   $0x0
  80152a:	e8 64 0f 00 00       	call   802493 <sys_page_unmap>
  80152f:	83 c4 10             	add    $0x10,%esp
  801532:	e9 44 ff ff ff       	jmp    80147b <serve+0xe>

00801537 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	83 ec 14             	sub    $0x14,%esp
	static_assert(sizeof(struct File) == 256);
	binaryname = "fs";
  80153d:	c7 05 80 90 80 00 ab 	movl   $0x803aab,0x809080
  801544:	3a 80 00 
	cprintf("FS is running\n");
  801547:	68 ae 3a 80 00       	push   $0x803aae
  80154c:	e8 2f 05 00 00       	call   801a80 <cprintf>
}

static __inline void
outw(int port, uint16_t data)
{
	__asm __volatile("outw %0,%w1" : : "a" (data), "d" (port));
  801551:	ba 00 8a 00 00       	mov    $0x8a00,%edx
  801556:	b8 00 8a ff ff       	mov    $0xffff8a00,%eax
  80155b:	66 ef                	out    %ax,(%dx)

	// Check that we are able to do I/O
	outw(0x8A00, 0x8A00);
	cprintf("FS can do I/O\n");
  80155d:	c7 04 24 bd 3a 80 00 	movl   $0x803abd,(%esp)
  801564:	e8 17 05 00 00       	call   801a80 <cprintf>

	serve_init();
  801569:	e8 f7 fa ff ff       	call   801065 <serve_init>
	fs_init();
  80156e:	e8 95 f3 ff ff       	call   800908 <fs_init>
        fs_test();
  801573:	e8 05 00 00 00       	call   80157d <fs_test>
	serve();
  801578:	e8 f0 fe ff ff       	call   80146d <serve>

0080157d <fs_test>:

static char *msg = "This is the NEW message of the day!\n\n";

void
fs_test(void)
{
  80157d:	55                   	push   %ebp
  80157e:	89 e5                	mov    %esp,%ebp
  801580:	53                   	push   %ebx
  801581:	83 ec 18             	sub    $0x18,%esp
	int r;
	char *blk;
	uint32_t *bits;

	// back up bitmap
	if ((r = sys_page_alloc(0, (void*) PGSIZE, PTE_P|PTE_U|PTE_W)) < 0)
  801584:	6a 07                	push   $0x7
  801586:	68 00 10 00 00       	push   $0x1000
  80158b:	6a 00                	push   $0x0
  80158d:	e8 7c 0e 00 00       	call   80240e <sys_page_alloc>
  801592:	83 c4 10             	add    $0x10,%esp
  801595:	85 c0                	test   %eax,%eax
  801597:	79 12                	jns    8015ab <fs_test+0x2e>
		panic("sys_page_alloc: %i", r);
  801599:	50                   	push   %eax
  80159a:	68 cc 3a 80 00       	push   $0x803acc
  80159f:	6a 12                	push   $0x12
  8015a1:	68 df 3a 80 00       	push   $0x803adf
  8015a6:	e8 fc 03 00 00       	call   8019a7 <_panic>
	bits = (uint32_t*) PGSIZE;
	memmove(bits, bitmap, PGSIZE);
  8015ab:	83 ec 04             	sub    $0x4,%esp
  8015ae:	68 00 10 00 00       	push   $0x1000
  8015b3:	ff 35 04 a0 80 00    	pushl  0x80a004
  8015b9:	68 00 10 00 00       	push   $0x1000
  8015be:	e8 d3 0b 00 00       	call   802196 <memmove>
	// allocate block
	if ((r = alloc_block()) < 0)
  8015c3:	e8 6a f1 ff ff       	call   800732 <alloc_block>
  8015c8:	83 c4 10             	add    $0x10,%esp
  8015cb:	85 c0                	test   %eax,%eax
  8015cd:	79 12                	jns    8015e1 <fs_test+0x64>
		panic("alloc_block: %i", r);
  8015cf:	50                   	push   %eax
  8015d0:	68 e9 3a 80 00       	push   $0x803ae9
  8015d5:	6a 17                	push   $0x17
  8015d7:	68 df 3a 80 00       	push   $0x803adf
  8015dc:	e8 c6 03 00 00       	call   8019a7 <_panic>
	// check that block was free
	assert(bits[r/32] & (1 << (r%32)));
  8015e1:	99                   	cltd   
  8015e2:	c1 ea 1b             	shr    $0x1b,%edx
  8015e5:	01 d0                	add    %edx,%eax
  8015e7:	89 c3                	mov    %eax,%ebx
  8015e9:	c1 fb 05             	sar    $0x5,%ebx
  8015ec:	83 e0 1f             	and    $0x1f,%eax
  8015ef:	29 d0                	sub    %edx,%eax
  8015f1:	89 c1                	mov    %eax,%ecx
  8015f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015f8:	d3 e0                	shl    %cl,%eax
  8015fa:	85 04 9d 00 10 00 00 	test   %eax,0x1000(,%ebx,4)
  801601:	75 16                	jne    801619 <fs_test+0x9c>
  801603:	68 f9 3a 80 00       	push   $0x803af9
  801608:	68 bd 37 80 00       	push   $0x8037bd
  80160d:	6a 19                	push   $0x19
  80160f:	68 df 3a 80 00       	push   $0x803adf
  801614:	e8 8e 03 00 00       	call   8019a7 <_panic>
	// and is not free any more
	assert(!(bitmap[r/32] & (1 << (r%32))));
  801619:	8b 15 04 a0 80 00    	mov    0x80a004,%edx
  80161f:	85 04 9a             	test   %eax,(%edx,%ebx,4)
  801622:	74 16                	je     80163a <fs_test+0xbd>
  801624:	68 74 3c 80 00       	push   $0x803c74
  801629:	68 bd 37 80 00       	push   $0x8037bd
  80162e:	6a 1b                	push   $0x1b
  801630:	68 df 3a 80 00       	push   $0x803adf
  801635:	e8 6d 03 00 00       	call   8019a7 <_panic>
	cprintf("alloc_block is good\n");
  80163a:	83 ec 0c             	sub    $0xc,%esp
  80163d:	68 14 3b 80 00       	push   $0x803b14
  801642:	e8 39 04 00 00       	call   801a80 <cprintf>

	if ((r = file_open("/not-found", &f)) < 0 && r != -E_NOT_FOUND)
  801647:	83 c4 08             	add    $0x8,%esp
  80164a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164d:	50                   	push   %eax
  80164e:	68 29 3b 80 00       	push   $0x803b29
  801653:	e8 92 f5 ff ff       	call   800bea <file_open>
  801658:	89 c2                	mov    %eax,%edx
  80165a:	c1 ea 1f             	shr    $0x1f,%edx
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	84 d2                	test   %dl,%dl
  801662:	74 17                	je     80167b <fs_test+0xfe>
  801664:	83 f8 f5             	cmp    $0xfffffff5,%eax
  801667:	74 12                	je     80167b <fs_test+0xfe>
		panic("file_open /not-found: %i", r);
  801669:	50                   	push   %eax
  80166a:	68 34 3b 80 00       	push   $0x803b34
  80166f:	6a 1f                	push   $0x1f
  801671:	68 df 3a 80 00       	push   $0x803adf
  801676:	e8 2c 03 00 00       	call   8019a7 <_panic>
	else if (r == 0)
  80167b:	85 c0                	test   %eax,%eax
  80167d:	75 14                	jne    801693 <fs_test+0x116>
		panic("file_open /not-found succeeded!");
  80167f:	83 ec 04             	sub    $0x4,%esp
  801682:	68 94 3c 80 00       	push   $0x803c94
  801687:	6a 21                	push   $0x21
  801689:	68 df 3a 80 00       	push   $0x803adf
  80168e:	e8 14 03 00 00       	call   8019a7 <_panic>
	if ((r = file_open("/newmotd", &f)) < 0)
  801693:	83 ec 08             	sub    $0x8,%esp
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	68 4d 3b 80 00       	push   $0x803b4d
  80169f:	e8 46 f5 ff ff       	call   800bea <file_open>
  8016a4:	83 c4 10             	add    $0x10,%esp
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	79 12                	jns    8016bd <fs_test+0x140>
		panic("file_open /newmotd: %i", r);
  8016ab:	50                   	push   %eax
  8016ac:	68 56 3b 80 00       	push   $0x803b56
  8016b1:	6a 23                	push   $0x23
  8016b3:	68 df 3a 80 00       	push   $0x803adf
  8016b8:	e8 ea 02 00 00       	call   8019a7 <_panic>
	cprintf("file_open is good\n");
  8016bd:	83 ec 0c             	sub    $0xc,%esp
  8016c0:	68 6d 3b 80 00       	push   $0x803b6d
  8016c5:	e8 b6 03 00 00       	call   801a80 <cprintf>

	if ((r = file_get_block(f, 0, &blk)) < 0)
  8016ca:	83 c4 0c             	add    $0xc,%esp
  8016cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016d0:	50                   	push   %eax
  8016d1:	6a 00                	push   $0x0
  8016d3:	ff 75 f4             	pushl  -0xc(%ebp)
  8016d6:	e8 8c f2 ff ff       	call   800967 <file_get_block>
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	79 12                	jns    8016f4 <fs_test+0x177>
		panic("file_get_block: %i", r);
  8016e2:	50                   	push   %eax
  8016e3:	68 80 3b 80 00       	push   $0x803b80
  8016e8:	6a 27                	push   $0x27
  8016ea:	68 df 3a 80 00       	push   $0x803adf
  8016ef:	e8 b3 02 00 00       	call   8019a7 <_panic>
	if (strcmp(blk, msg) != 0)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	68 b4 3c 80 00       	push   $0x803cb4
  8016fc:	ff 75 f0             	pushl  -0x10(%ebp)
  8016ff:	e8 aa 09 00 00       	call   8020ae <strcmp>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	74 14                	je     80171f <fs_test+0x1a2>
		panic("file_get_block returned wrong data");
  80170b:	83 ec 04             	sub    $0x4,%esp
  80170e:	68 dc 3c 80 00       	push   $0x803cdc
  801713:	6a 29                	push   $0x29
  801715:	68 df 3a 80 00       	push   $0x803adf
  80171a:	e8 88 02 00 00       	call   8019a7 <_panic>
	cprintf("file_get_block is good\n");
  80171f:	83 ec 0c             	sub    $0xc,%esp
  801722:	68 93 3b 80 00       	push   $0x803b93
  801727:	e8 54 03 00 00       	call   801a80 <cprintf>

	*(volatile char*)blk = *(volatile char*)blk;
  80172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172f:	0f b6 10             	movzbl (%eax),%edx
  801732:	88 10                	mov    %dl,(%eax)
	assert((uvpt[PGNUM(blk)] & PTE_D));
  801734:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801737:	c1 e8 0c             	shr    $0xc,%eax
  80173a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	a8 40                	test   $0x40,%al
  801746:	75 16                	jne    80175e <fs_test+0x1e1>
  801748:	68 ac 3b 80 00       	push   $0x803bac
  80174d:	68 bd 37 80 00       	push   $0x8037bd
  801752:	6a 2d                	push   $0x2d
  801754:	68 df 3a 80 00       	push   $0x803adf
  801759:	e8 49 02 00 00       	call   8019a7 <_panic>
	file_flush(f);
  80175e:	83 ec 0c             	sub    $0xc,%esp
  801761:	ff 75 f4             	pushl  -0xc(%ebp)
  801764:	e8 ce f6 ff ff       	call   800e37 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  801769:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176c:	c1 e8 0c             	shr    $0xc,%eax
  80176f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	a8 40                	test   $0x40,%al
  80177b:	74 16                	je     801793 <fs_test+0x216>
  80177d:	68 ab 3b 80 00       	push   $0x803bab
  801782:	68 bd 37 80 00       	push   $0x8037bd
  801787:	6a 2f                	push   $0x2f
  801789:	68 df 3a 80 00       	push   $0x803adf
  80178e:	e8 14 02 00 00       	call   8019a7 <_panic>
	cprintf("file_flush is good\n");
  801793:	83 ec 0c             	sub    $0xc,%esp
  801796:	68 c7 3b 80 00       	push   $0x803bc7
  80179b:	e8 e0 02 00 00       	call   801a80 <cprintf>

	if ((r = file_set_size(f, 0)) < 0)
  8017a0:	83 c4 08             	add    $0x8,%esp
  8017a3:	6a 00                	push   $0x0
  8017a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a8:	e8 07 f5 ff ff       	call   800cb4 <file_set_size>
  8017ad:	83 c4 10             	add    $0x10,%esp
  8017b0:	85 c0                	test   %eax,%eax
  8017b2:	79 12                	jns    8017c6 <fs_test+0x249>
		panic("file_set_size: %i", r);
  8017b4:	50                   	push   %eax
  8017b5:	68 db 3b 80 00       	push   $0x803bdb
  8017ba:	6a 33                	push   $0x33
  8017bc:	68 df 3a 80 00       	push   $0x803adf
  8017c1:	e8 e1 01 00 00       	call   8019a7 <_panic>
	assert(f->f_direct[0] == 0);
  8017c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c9:	83 b8 88 00 00 00 00 	cmpl   $0x0,0x88(%eax)
  8017d0:	74 16                	je     8017e8 <fs_test+0x26b>
  8017d2:	68 ed 3b 80 00       	push   $0x803bed
  8017d7:	68 bd 37 80 00       	push   $0x8037bd
  8017dc:	6a 34                	push   $0x34
  8017de:	68 df 3a 80 00       	push   $0x803adf
  8017e3:	e8 bf 01 00 00       	call   8019a7 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  8017e8:	c1 e8 0c             	shr    $0xc,%eax
  8017eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8017f2:	a8 40                	test   $0x40,%al
  8017f4:	74 16                	je     80180c <fs_test+0x28f>
  8017f6:	68 01 3c 80 00       	push   $0x803c01
  8017fb:	68 bd 37 80 00       	push   $0x8037bd
  801800:	6a 35                	push   $0x35
  801802:	68 df 3a 80 00       	push   $0x803adf
  801807:	e8 9b 01 00 00       	call   8019a7 <_panic>
	cprintf("file_truncate is good\n");
  80180c:	83 ec 0c             	sub    $0xc,%esp
  80180f:	68 1b 3c 80 00       	push   $0x803c1b
  801814:	e8 67 02 00 00       	call   801a80 <cprintf>

	if ((r = file_set_size(f, strlen(msg))) < 0)
  801819:	c7 04 24 b4 3c 80 00 	movl   $0x803cb4,(%esp)
  801820:	e8 a6 07 00 00       	call   801fcb <strlen>
  801825:	83 c4 08             	add    $0x8,%esp
  801828:	50                   	push   %eax
  801829:	ff 75 f4             	pushl  -0xc(%ebp)
  80182c:	e8 83 f4 ff ff       	call   800cb4 <file_set_size>
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	85 c0                	test   %eax,%eax
  801836:	79 12                	jns    80184a <fs_test+0x2cd>
		panic("file_set_size 2: %i", r);
  801838:	50                   	push   %eax
  801839:	68 32 3c 80 00       	push   $0x803c32
  80183e:	6a 39                	push   $0x39
  801840:	68 df 3a 80 00       	push   $0x803adf
  801845:	e8 5d 01 00 00       	call   8019a7 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80184a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80184d:	89 c2                	mov    %eax,%edx
  80184f:	c1 ea 0c             	shr    $0xc,%edx
  801852:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801859:	f6 c2 40             	test   $0x40,%dl
  80185c:	74 16                	je     801874 <fs_test+0x2f7>
  80185e:	68 01 3c 80 00       	push   $0x803c01
  801863:	68 bd 37 80 00       	push   $0x8037bd
  801868:	6a 3a                	push   $0x3a
  80186a:	68 df 3a 80 00       	push   $0x803adf
  80186f:	e8 33 01 00 00       	call   8019a7 <_panic>
	if ((r = file_get_block(f, 0, &blk)) < 0)
  801874:	83 ec 04             	sub    $0x4,%esp
  801877:	8d 55 f0             	lea    -0x10(%ebp),%edx
  80187a:	52                   	push   %edx
  80187b:	6a 00                	push   $0x0
  80187d:	50                   	push   %eax
  80187e:	e8 e4 f0 ff ff       	call   800967 <file_get_block>
  801883:	83 c4 10             	add    $0x10,%esp
  801886:	85 c0                	test   %eax,%eax
  801888:	79 12                	jns    80189c <fs_test+0x31f>
		panic("file_get_block 2: %i", r);
  80188a:	50                   	push   %eax
  80188b:	68 46 3c 80 00       	push   $0x803c46
  801890:	6a 3c                	push   $0x3c
  801892:	68 df 3a 80 00       	push   $0x803adf
  801897:	e8 0b 01 00 00       	call   8019a7 <_panic>
	strcpy(blk, msg);
  80189c:	83 ec 08             	sub    $0x8,%esp
  80189f:	68 b4 3c 80 00       	push   $0x803cb4
  8018a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8018a7:	e8 58 07 00 00       	call   802004 <strcpy>
	assert((uvpt[PGNUM(blk)] & PTE_D));
  8018ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018af:	c1 e8 0c             	shr    $0xc,%eax
  8018b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	a8 40                	test   $0x40,%al
  8018be:	75 16                	jne    8018d6 <fs_test+0x359>
  8018c0:	68 ac 3b 80 00       	push   $0x803bac
  8018c5:	68 bd 37 80 00       	push   $0x8037bd
  8018ca:	6a 3e                	push   $0x3e
  8018cc:	68 df 3a 80 00       	push   $0x803adf
  8018d1:	e8 d1 00 00 00       	call   8019a7 <_panic>
	file_flush(f);
  8018d6:	83 ec 0c             	sub    $0xc,%esp
  8018d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8018dc:	e8 56 f5 ff ff       	call   800e37 <file_flush>
	assert(!(uvpt[PGNUM(blk)] & PTE_D));
  8018e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018e4:	c1 e8 0c             	shr    $0xc,%eax
  8018e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8018ee:	83 c4 10             	add    $0x10,%esp
  8018f1:	a8 40                	test   $0x40,%al
  8018f3:	74 16                	je     80190b <fs_test+0x38e>
  8018f5:	68 ab 3b 80 00       	push   $0x803bab
  8018fa:	68 bd 37 80 00       	push   $0x8037bd
  8018ff:	6a 40                	push   $0x40
  801901:	68 df 3a 80 00       	push   $0x803adf
  801906:	e8 9c 00 00 00       	call   8019a7 <_panic>
	assert(!(uvpt[PGNUM(f)] & PTE_D));
  80190b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190e:	c1 e8 0c             	shr    $0xc,%eax
  801911:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801918:	a8 40                	test   $0x40,%al
  80191a:	74 16                	je     801932 <fs_test+0x3b5>
  80191c:	68 01 3c 80 00       	push   $0x803c01
  801921:	68 bd 37 80 00       	push   $0x8037bd
  801926:	6a 41                	push   $0x41
  801928:	68 df 3a 80 00       	push   $0x803adf
  80192d:	e8 75 00 00 00       	call   8019a7 <_panic>
	cprintf("file rewrite is good\n");
  801932:	83 ec 0c             	sub    $0xc,%esp
  801935:	68 5b 3c 80 00       	push   $0x803c5b
  80193a:	e8 41 01 00 00       	call   801a80 <cprintf>
  80193f:	83 c4 10             	add    $0x10,%esp
}
  801942:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801945:	c9                   	leave  
  801946:	c3                   	ret    

00801947 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  801947:	55                   	push   %ebp
  801948:	89 e5                	mov    %esp,%ebp
  80194a:	56                   	push   %esi
  80194b:	53                   	push   %ebx
  80194c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80194f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  801952:	e8 79 0a 00 00       	call   8023d0 <sys_getenvid>
  801957:	25 ff 03 00 00       	and    $0x3ff,%eax
  80195c:	6b c0 78             	imul   $0x78,%eax,%eax
  80195f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801964:	a3 0c a0 80 00       	mov    %eax,0x80a00c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  801969:	85 db                	test   %ebx,%ebx
  80196b:	7e 07                	jle    801974 <libmain+0x2d>
		binaryname = argv[0];
  80196d:	8b 06                	mov    (%esi),%eax
  80196f:	a3 80 90 80 00       	mov    %eax,0x809080

	// call user main routine
	umain(argc, argv);
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	e8 b9 fb ff ff       	call   801537 <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  80197e:	e8 0a 00 00 00       	call   80198d <exit>
  801983:	83 c4 10             	add    $0x10,%esp
#endif
}
  801986:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801989:	5b                   	pop    %ebx
  80198a:	5e                   	pop    %esi
  80198b:	5d                   	pop    %ebp
  80198c:	c3                   	ret    

0080198d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 08             	sub    $0x8,%esp
	close_all();
  801993:	e8 d8 0f 00 00       	call   802970 <close_all>
	sys_env_destroy(0);
  801998:	83 ec 0c             	sub    $0xc,%esp
  80199b:	6a 00                	push   $0x0
  80199d:	e8 ed 09 00 00       	call   80238f <sys_env_destroy>
  8019a2:	83 c4 10             	add    $0x10,%esp
}
  8019a5:	c9                   	leave  
  8019a6:	c3                   	ret    

008019a7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019a7:	55                   	push   %ebp
  8019a8:	89 e5                	mov    %esp,%ebp
  8019aa:	56                   	push   %esi
  8019ab:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8019ac:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019af:	8b 35 80 90 80 00    	mov    0x809080,%esi
  8019b5:	e8 16 0a 00 00       	call   8023d0 <sys_getenvid>
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	ff 75 0c             	pushl  0xc(%ebp)
  8019c0:	ff 75 08             	pushl  0x8(%ebp)
  8019c3:	56                   	push   %esi
  8019c4:	50                   	push   %eax
  8019c5:	68 0c 3d 80 00       	push   $0x803d0c
  8019ca:	e8 b1 00 00 00       	call   801a80 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019cf:	83 c4 18             	add    $0x18,%esp
  8019d2:	53                   	push   %ebx
  8019d3:	ff 75 10             	pushl  0x10(%ebp)
  8019d6:	e8 54 00 00 00       	call   801a2f <vcprintf>
	cprintf("\n");
  8019db:	c7 04 24 1d 39 80 00 	movl   $0x80391d,(%esp)
  8019e2:	e8 99 00 00 00       	call   801a80 <cprintf>
  8019e7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8019ea:	cc                   	int3   
  8019eb:	eb fd                	jmp    8019ea <_panic+0x43>

008019ed <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	53                   	push   %ebx
  8019f1:	83 ec 04             	sub    $0x4,%esp
  8019f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8019f7:	8b 13                	mov    (%ebx),%edx
  8019f9:	8d 42 01             	lea    0x1(%edx),%eax
  8019fc:	89 03                	mov    %eax,(%ebx)
  8019fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a01:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801a05:	3d ff 00 00 00       	cmp    $0xff,%eax
  801a0a:	75 1a                	jne    801a26 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801a0c:	83 ec 08             	sub    $0x8,%esp
  801a0f:	68 ff 00 00 00       	push   $0xff
  801a14:	8d 43 08             	lea    0x8(%ebx),%eax
  801a17:	50                   	push   %eax
  801a18:	e8 35 09 00 00       	call   802352 <sys_cputs>
		b->idx = 0;
  801a1d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801a23:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801a26:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801a2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801a38:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801a3f:	00 00 00 
	b.cnt = 0;
  801a42:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801a49:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801a4c:	ff 75 0c             	pushl  0xc(%ebp)
  801a4f:	ff 75 08             	pushl  0x8(%ebp)
  801a52:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801a58:	50                   	push   %eax
  801a59:	68 ed 19 80 00       	push   $0x8019ed
  801a5e:	e8 4f 01 00 00       	call   801bb2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801a63:	83 c4 08             	add    $0x8,%esp
  801a66:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801a6c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801a72:	50                   	push   %eax
  801a73:	e8 da 08 00 00       	call   802352 <sys_cputs>

	return b.cnt;
}
  801a78:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801a7e:	c9                   	leave  
  801a7f:	c3                   	ret    

00801a80 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801a86:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801a89:	50                   	push   %eax
  801a8a:	ff 75 08             	pushl  0x8(%ebp)
  801a8d:	e8 9d ff ff ff       	call   801a2f <vcprintf>
	va_end(ap);

	return cnt;
}
  801a92:	c9                   	leave  
  801a93:	c3                   	ret    

00801a94 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	57                   	push   %edi
  801a98:	56                   	push   %esi
  801a99:	53                   	push   %ebx
  801a9a:	83 ec 1c             	sub    $0x1c,%esp
  801a9d:	89 c7                	mov    %eax,%edi
  801a9f:	89 d6                	mov    %edx,%esi
  801aa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aa7:	89 d1                	mov    %edx,%ecx
  801aa9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801aac:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801aaf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ab2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801ab5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ab8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801abf:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  801ac2:	72 05                	jb     801ac9 <printnum+0x35>
  801ac4:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  801ac7:	77 3e                	ja     801b07 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	ff 75 18             	pushl  0x18(%ebp)
  801acf:	83 eb 01             	sub    $0x1,%ebx
  801ad2:	53                   	push   %ebx
  801ad3:	50                   	push   %eax
  801ad4:	83 ec 08             	sub    $0x8,%esp
  801ad7:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ada:	ff 75 e0             	pushl  -0x20(%ebp)
  801add:	ff 75 dc             	pushl  -0x24(%ebp)
  801ae0:	ff 75 d8             	pushl  -0x28(%ebp)
  801ae3:	e8 e8 19 00 00       	call   8034d0 <__udivdi3>
  801ae8:	83 c4 18             	add    $0x18,%esp
  801aeb:	52                   	push   %edx
  801aec:	50                   	push   %eax
  801aed:	89 f2                	mov    %esi,%edx
  801aef:	89 f8                	mov    %edi,%eax
  801af1:	e8 9e ff ff ff       	call   801a94 <printnum>
  801af6:	83 c4 20             	add    $0x20,%esp
  801af9:	eb 13                	jmp    801b0e <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801afb:	83 ec 08             	sub    $0x8,%esp
  801afe:	56                   	push   %esi
  801aff:	ff 75 18             	pushl  0x18(%ebp)
  801b02:	ff d7                	call   *%edi
  801b04:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801b07:	83 eb 01             	sub    $0x1,%ebx
  801b0a:	85 db                	test   %ebx,%ebx
  801b0c:	7f ed                	jg     801afb <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801b0e:	83 ec 08             	sub    $0x8,%esp
  801b11:	56                   	push   %esi
  801b12:	83 ec 04             	sub    $0x4,%esp
  801b15:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b18:	ff 75 e0             	pushl  -0x20(%ebp)
  801b1b:	ff 75 dc             	pushl  -0x24(%ebp)
  801b1e:	ff 75 d8             	pushl  -0x28(%ebp)
  801b21:	e8 da 1a 00 00       	call   803600 <__umoddi3>
  801b26:	83 c4 14             	add    $0x14,%esp
  801b29:	0f be 80 2f 3d 80 00 	movsbl 0x803d2f(%eax),%eax
  801b30:	50                   	push   %eax
  801b31:	ff d7                	call   *%edi
  801b33:	83 c4 10             	add    $0x10,%esp
}
  801b36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b39:	5b                   	pop    %ebx
  801b3a:	5e                   	pop    %esi
  801b3b:	5f                   	pop    %edi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  801b41:	83 fa 01             	cmp    $0x1,%edx
  801b44:	7e 0e                	jle    801b54 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  801b46:	8b 10                	mov    (%eax),%edx
  801b48:	8d 4a 08             	lea    0x8(%edx),%ecx
  801b4b:	89 08                	mov    %ecx,(%eax)
  801b4d:	8b 02                	mov    (%edx),%eax
  801b4f:	8b 52 04             	mov    0x4(%edx),%edx
  801b52:	eb 22                	jmp    801b76 <getuint+0x38>
	else if (lflag)
  801b54:	85 d2                	test   %edx,%edx
  801b56:	74 10                	je     801b68 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  801b58:	8b 10                	mov    (%eax),%edx
  801b5a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b5d:	89 08                	mov    %ecx,(%eax)
  801b5f:	8b 02                	mov    (%edx),%eax
  801b61:	ba 00 00 00 00       	mov    $0x0,%edx
  801b66:	eb 0e                	jmp    801b76 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801b68:	8b 10                	mov    (%eax),%edx
  801b6a:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b6d:	89 08                	mov    %ecx,(%eax)
  801b6f:	8b 02                	mov    (%edx),%eax
  801b71:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801b76:	5d                   	pop    %ebp
  801b77:	c3                   	ret    

00801b78 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801b7e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801b82:	8b 10                	mov    (%eax),%edx
  801b84:	3b 50 04             	cmp    0x4(%eax),%edx
  801b87:	73 0a                	jae    801b93 <sprintputch+0x1b>
		*b->buf++ = ch;
  801b89:	8d 4a 01             	lea    0x1(%edx),%ecx
  801b8c:	89 08                	mov    %ecx,(%eax)
  801b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b91:	88 02                	mov    %al,(%edx)
}
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    

00801b95 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801b9b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801b9e:	50                   	push   %eax
  801b9f:	ff 75 10             	pushl  0x10(%ebp)
  801ba2:	ff 75 0c             	pushl  0xc(%ebp)
  801ba5:	ff 75 08             	pushl  0x8(%ebp)
  801ba8:	e8 05 00 00 00       	call   801bb2 <vprintfmt>
	va_end(ap);
  801bad:	83 c4 10             	add    $0x10,%esp
}
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	57                   	push   %edi
  801bb6:	56                   	push   %esi
  801bb7:	53                   	push   %ebx
  801bb8:	83 ec 2c             	sub    $0x2c,%esp
  801bbb:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801bc1:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bc4:	eb 12                	jmp    801bd8 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	0f 84 8d 03 00 00    	je     801f5b <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  801bce:	83 ec 08             	sub    $0x8,%esp
  801bd1:	53                   	push   %ebx
  801bd2:	50                   	push   %eax
  801bd3:	ff d6                	call   *%esi
  801bd5:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801bd8:	83 c7 01             	add    $0x1,%edi
  801bdb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801bdf:	83 f8 25             	cmp    $0x25,%eax
  801be2:	75 e2                	jne    801bc6 <vprintfmt+0x14>
  801be4:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801be8:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801bef:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801bf6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801bfd:	ba 00 00 00 00       	mov    $0x0,%edx
  801c02:	eb 07                	jmp    801c0b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c04:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801c07:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c0b:	8d 47 01             	lea    0x1(%edi),%eax
  801c0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c11:	0f b6 07             	movzbl (%edi),%eax
  801c14:	0f b6 c8             	movzbl %al,%ecx
  801c17:	83 e8 23             	sub    $0x23,%eax
  801c1a:	3c 55                	cmp    $0x55,%al
  801c1c:	0f 87 1e 03 00 00    	ja     801f40 <vprintfmt+0x38e>
  801c22:	0f b6 c0             	movzbl %al,%eax
  801c25:	ff 24 85 80 3e 80 00 	jmp    *0x803e80(,%eax,4)
  801c2c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801c2f:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  801c33:	eb d6                	jmp    801c0b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c35:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c38:	b8 00 00 00 00       	mov    $0x0,%eax
  801c3d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801c40:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801c43:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  801c47:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  801c4a:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801c4d:	83 fa 09             	cmp    $0x9,%edx
  801c50:	77 38                	ja     801c8a <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801c52:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801c55:	eb e9                	jmp    801c40 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  801c57:	8b 45 14             	mov    0x14(%ebp),%eax
  801c5a:	8d 48 04             	lea    0x4(%eax),%ecx
  801c5d:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801c60:	8b 00                	mov    (%eax),%eax
  801c62:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c65:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801c68:	eb 26                	jmp    801c90 <vprintfmt+0xde>
  801c6a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801c6d:	89 c8                	mov    %ecx,%eax
  801c6f:	c1 f8 1f             	sar    $0x1f,%eax
  801c72:	f7 d0                	not    %eax
  801c74:	21 c1                	and    %eax,%ecx
  801c76:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801c79:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801c7c:	eb 8d                	jmp    801c0b <vprintfmt+0x59>
  801c7e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801c81:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801c88:	eb 81                	jmp    801c0b <vprintfmt+0x59>
  801c8a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801c8d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  801c90:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801c94:	0f 89 71 ff ff ff    	jns    801c0b <vprintfmt+0x59>
				width = precision, precision = -1;
  801c9a:	8b 45 d0             	mov    -0x30(%ebp),%eax
  801c9d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801ca0:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  801ca7:	e9 5f ff ff ff       	jmp    801c0b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801cac:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801caf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801cb2:	e9 54 ff ff ff       	jmp    801c0b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801cb7:	8b 45 14             	mov    0x14(%ebp),%eax
  801cba:	8d 50 04             	lea    0x4(%eax),%edx
  801cbd:	89 55 14             	mov    %edx,0x14(%ebp)
  801cc0:	83 ec 08             	sub    $0x8,%esp
  801cc3:	53                   	push   %ebx
  801cc4:	ff 30                	pushl  (%eax)
  801cc6:	ff d6                	call   *%esi
			break;
  801cc8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801ccb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801cce:	e9 05 ff ff ff       	jmp    801bd8 <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  801cd3:	8b 45 14             	mov    0x14(%ebp),%eax
  801cd6:	8d 50 04             	lea    0x4(%eax),%edx
  801cd9:	89 55 14             	mov    %edx,0x14(%ebp)
  801cdc:	8b 00                	mov    (%eax),%eax
  801cde:	99                   	cltd   
  801cdf:	31 d0                	xor    %edx,%eax
  801ce1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801ce3:	83 f8 0f             	cmp    $0xf,%eax
  801ce6:	7f 0b                	jg     801cf3 <vprintfmt+0x141>
  801ce8:	8b 14 85 00 40 80 00 	mov    0x804000(,%eax,4),%edx
  801cef:	85 d2                	test   %edx,%edx
  801cf1:	75 18                	jne    801d0b <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  801cf3:	50                   	push   %eax
  801cf4:	68 47 3d 80 00       	push   $0x803d47
  801cf9:	53                   	push   %ebx
  801cfa:	56                   	push   %esi
  801cfb:	e8 95 fe ff ff       	call   801b95 <printfmt>
  801d00:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d03:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801d06:	e9 cd fe ff ff       	jmp    801bd8 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801d0b:	52                   	push   %edx
  801d0c:	68 cf 37 80 00       	push   $0x8037cf
  801d11:	53                   	push   %ebx
  801d12:	56                   	push   %esi
  801d13:	e8 7d fe ff ff       	call   801b95 <printfmt>
  801d18:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801d1b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801d1e:	e9 b5 fe ff ff       	jmp    801bd8 <vprintfmt+0x26>
  801d23:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801d26:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801d29:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801d2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801d2f:	8d 50 04             	lea    0x4(%eax),%edx
  801d32:	89 55 14             	mov    %edx,0x14(%ebp)
  801d35:	8b 38                	mov    (%eax),%edi
  801d37:	85 ff                	test   %edi,%edi
  801d39:	75 05                	jne    801d40 <vprintfmt+0x18e>
				p = "(null)";
  801d3b:	bf 40 3d 80 00       	mov    $0x803d40,%edi
			if (width > 0 && padc != '-')
  801d40:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  801d44:	0f 84 91 00 00 00    	je     801ddb <vprintfmt+0x229>
  801d4a:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801d4e:	0f 8e 95 00 00 00    	jle    801de9 <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  801d54:	83 ec 08             	sub    $0x8,%esp
  801d57:	51                   	push   %ecx
  801d58:	57                   	push   %edi
  801d59:	e8 85 02 00 00       	call   801fe3 <strnlen>
  801d5e:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d61:	29 c1                	sub    %eax,%ecx
  801d63:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801d66:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801d69:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801d6d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d70:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801d73:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d75:	eb 0f                	jmp    801d86 <vprintfmt+0x1d4>
					putch(padc, putdat);
  801d77:	83 ec 08             	sub    $0x8,%esp
  801d7a:	53                   	push   %ebx
  801d7b:	ff 75 e0             	pushl  -0x20(%ebp)
  801d7e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801d80:	83 ef 01             	sub    $0x1,%edi
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	85 ff                	test   %edi,%edi
  801d88:	7f ed                	jg     801d77 <vprintfmt+0x1c5>
  801d8a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801d8d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	c1 f8 1f             	sar    $0x1f,%eax
  801d95:	f7 d0                	not    %eax
  801d97:	21 c8                	and    %ecx,%eax
  801d99:	29 c1                	sub    %eax,%ecx
  801d9b:	89 75 08             	mov    %esi,0x8(%ebp)
  801d9e:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801da1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801da4:	89 cb                	mov    %ecx,%ebx
  801da6:	eb 4d                	jmp    801df5 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801da8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801dac:	74 1b                	je     801dc9 <vprintfmt+0x217>
  801dae:	0f be c0             	movsbl %al,%eax
  801db1:	83 e8 20             	sub    $0x20,%eax
  801db4:	83 f8 5e             	cmp    $0x5e,%eax
  801db7:	76 10                	jbe    801dc9 <vprintfmt+0x217>
					putch('?', putdat);
  801db9:	83 ec 08             	sub    $0x8,%esp
  801dbc:	ff 75 0c             	pushl  0xc(%ebp)
  801dbf:	6a 3f                	push   $0x3f
  801dc1:	ff 55 08             	call   *0x8(%ebp)
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	eb 0d                	jmp    801dd6 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  801dc9:	83 ec 08             	sub    $0x8,%esp
  801dcc:	ff 75 0c             	pushl  0xc(%ebp)
  801dcf:	52                   	push   %edx
  801dd0:	ff 55 08             	call   *0x8(%ebp)
  801dd3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801dd6:	83 eb 01             	sub    $0x1,%ebx
  801dd9:	eb 1a                	jmp    801df5 <vprintfmt+0x243>
  801ddb:	89 75 08             	mov    %esi,0x8(%ebp)
  801dde:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801de1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801de4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801de7:	eb 0c                	jmp    801df5 <vprintfmt+0x243>
  801de9:	89 75 08             	mov    %esi,0x8(%ebp)
  801dec:	8b 75 d0             	mov    -0x30(%ebp),%esi
  801def:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801df2:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801df5:	83 c7 01             	add    $0x1,%edi
  801df8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801dfc:	0f be d0             	movsbl %al,%edx
  801dff:	85 d2                	test   %edx,%edx
  801e01:	74 23                	je     801e26 <vprintfmt+0x274>
  801e03:	85 f6                	test   %esi,%esi
  801e05:	78 a1                	js     801da8 <vprintfmt+0x1f6>
  801e07:	83 ee 01             	sub    $0x1,%esi
  801e0a:	79 9c                	jns    801da8 <vprintfmt+0x1f6>
  801e0c:	89 df                	mov    %ebx,%edi
  801e0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801e11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e14:	eb 18                	jmp    801e2e <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801e16:	83 ec 08             	sub    $0x8,%esp
  801e19:	53                   	push   %ebx
  801e1a:	6a 20                	push   $0x20
  801e1c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  801e1e:	83 ef 01             	sub    $0x1,%edi
  801e21:	83 c4 10             	add    $0x10,%esp
  801e24:	eb 08                	jmp    801e2e <vprintfmt+0x27c>
  801e26:	89 df                	mov    %ebx,%edi
  801e28:	8b 75 08             	mov    0x8(%ebp),%esi
  801e2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801e2e:	85 ff                	test   %edi,%edi
  801e30:	7f e4                	jg     801e16 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801e32:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801e35:	e9 9e fd ff ff       	jmp    801bd8 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801e3a:	83 fa 01             	cmp    $0x1,%edx
  801e3d:	7e 16                	jle    801e55 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  801e3f:	8b 45 14             	mov    0x14(%ebp),%eax
  801e42:	8d 50 08             	lea    0x8(%eax),%edx
  801e45:	89 55 14             	mov    %edx,0x14(%ebp)
  801e48:	8b 50 04             	mov    0x4(%eax),%edx
  801e4b:	8b 00                	mov    (%eax),%eax
  801e4d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e50:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801e53:	eb 32                	jmp    801e87 <vprintfmt+0x2d5>
	else if (lflag)
  801e55:	85 d2                	test   %edx,%edx
  801e57:	74 18                	je     801e71 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  801e59:	8b 45 14             	mov    0x14(%ebp),%eax
  801e5c:	8d 50 04             	lea    0x4(%eax),%edx
  801e5f:	89 55 14             	mov    %edx,0x14(%ebp)
  801e62:	8b 00                	mov    (%eax),%eax
  801e64:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e67:	89 c1                	mov    %eax,%ecx
  801e69:	c1 f9 1f             	sar    $0x1f,%ecx
  801e6c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801e6f:	eb 16                	jmp    801e87 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  801e71:	8b 45 14             	mov    0x14(%ebp),%eax
  801e74:	8d 50 04             	lea    0x4(%eax),%edx
  801e77:	89 55 14             	mov    %edx,0x14(%ebp)
  801e7a:	8b 00                	mov    (%eax),%eax
  801e7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801e7f:	89 c1                	mov    %eax,%ecx
  801e81:	c1 f9 1f             	sar    $0x1f,%ecx
  801e84:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801e87:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801e8a:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801e8d:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801e92:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801e96:	79 74                	jns    801f0c <vprintfmt+0x35a>
				putch('-', putdat);
  801e98:	83 ec 08             	sub    $0x8,%esp
  801e9b:	53                   	push   %ebx
  801e9c:	6a 2d                	push   $0x2d
  801e9e:	ff d6                	call   *%esi
				num = -(long long) num;
  801ea0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801ea3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  801ea6:	f7 d8                	neg    %eax
  801ea8:	83 d2 00             	adc    $0x0,%edx
  801eab:	f7 da                	neg    %edx
  801ead:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801eb0:	b9 0a 00 00 00       	mov    $0xa,%ecx
  801eb5:	eb 55                	jmp    801f0c <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801eb7:	8d 45 14             	lea    0x14(%ebp),%eax
  801eba:	e8 7f fc ff ff       	call   801b3e <getuint>
			base = 10;
  801ebf:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  801ec4:	eb 46                	jmp    801f0c <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  801ec6:	8d 45 14             	lea    0x14(%ebp),%eax
  801ec9:	e8 70 fc ff ff       	call   801b3e <getuint>
			base = 8;
  801ece:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  801ed3:	eb 37                	jmp    801f0c <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  801ed5:	83 ec 08             	sub    $0x8,%esp
  801ed8:	53                   	push   %ebx
  801ed9:	6a 30                	push   $0x30
  801edb:	ff d6                	call   *%esi
			putch('x', putdat);
  801edd:	83 c4 08             	add    $0x8,%esp
  801ee0:	53                   	push   %ebx
  801ee1:	6a 78                	push   $0x78
  801ee3:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801ee5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ee8:	8d 50 04             	lea    0x4(%eax),%edx
  801eeb:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  801eee:	8b 00                	mov    (%eax),%eax
  801ef0:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801ef5:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  801ef8:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  801efd:	eb 0d                	jmp    801f0c <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  801eff:	8d 45 14             	lea    0x14(%ebp),%eax
  801f02:	e8 37 fc ff ff       	call   801b3e <getuint>
			base = 16;
  801f07:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  801f0c:	83 ec 0c             	sub    $0xc,%esp
  801f0f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801f13:	57                   	push   %edi
  801f14:	ff 75 e0             	pushl  -0x20(%ebp)
  801f17:	51                   	push   %ecx
  801f18:	52                   	push   %edx
  801f19:	50                   	push   %eax
  801f1a:	89 da                	mov    %ebx,%edx
  801f1c:	89 f0                	mov    %esi,%eax
  801f1e:	e8 71 fb ff ff       	call   801a94 <printnum>
			break;
  801f23:	83 c4 20             	add    $0x20,%esp
  801f26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801f29:	e9 aa fc ff ff       	jmp    801bd8 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801f2e:	83 ec 08             	sub    $0x8,%esp
  801f31:	53                   	push   %ebx
  801f32:	51                   	push   %ecx
  801f33:	ff d6                	call   *%esi
			break;
  801f35:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801f38:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801f3b:	e9 98 fc ff ff       	jmp    801bd8 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801f40:	83 ec 08             	sub    $0x8,%esp
  801f43:	53                   	push   %ebx
  801f44:	6a 25                	push   $0x25
  801f46:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801f48:	83 c4 10             	add    $0x10,%esp
  801f4b:	eb 03                	jmp    801f50 <vprintfmt+0x39e>
  801f4d:	83 ef 01             	sub    $0x1,%edi
  801f50:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801f54:	75 f7                	jne    801f4d <vprintfmt+0x39b>
  801f56:	e9 7d fc ff ff       	jmp    801bd8 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801f5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5e:	5b                   	pop    %ebx
  801f5f:	5e                   	pop    %esi
  801f60:	5f                   	pop    %edi
  801f61:	5d                   	pop    %ebp
  801f62:	c3                   	ret    

00801f63 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801f63:	55                   	push   %ebp
  801f64:	89 e5                	mov    %esp,%ebp
  801f66:	83 ec 18             	sub    $0x18,%esp
  801f69:	8b 45 08             	mov    0x8(%ebp),%eax
  801f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801f6f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801f72:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801f76:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801f79:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801f80:	85 c0                	test   %eax,%eax
  801f82:	74 26                	je     801faa <vsnprintf+0x47>
  801f84:	85 d2                	test   %edx,%edx
  801f86:	7e 22                	jle    801faa <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801f88:	ff 75 14             	pushl  0x14(%ebp)
  801f8b:	ff 75 10             	pushl  0x10(%ebp)
  801f8e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801f91:	50                   	push   %eax
  801f92:	68 78 1b 80 00       	push   $0x801b78
  801f97:	e8 16 fc ff ff       	call   801bb2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801f9c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801f9f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801fa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa5:	83 c4 10             	add    $0x10,%esp
  801fa8:	eb 05                	jmp    801faf <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801faa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801faf:	c9                   	leave  
  801fb0:	c3                   	ret    

00801fb1 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801fb7:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801fba:	50                   	push   %eax
  801fbb:	ff 75 10             	pushl  0x10(%ebp)
  801fbe:	ff 75 0c             	pushl  0xc(%ebp)
  801fc1:	ff 75 08             	pushl  0x8(%ebp)
  801fc4:	e8 9a ff ff ff       	call   801f63 <vsnprintf>
	va_end(ap);

	return rc;
}
  801fc9:	c9                   	leave  
  801fca:	c3                   	ret    

00801fcb <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801fcb:	55                   	push   %ebp
  801fcc:	89 e5                	mov    %esp,%ebp
  801fce:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801fd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd6:	eb 03                	jmp    801fdb <strlen+0x10>
		n++;
  801fd8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801fdb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801fdf:	75 f7                	jne    801fd8 <strlen+0xd>
		n++;
	return n;
}
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    

00801fe3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801fe3:	55                   	push   %ebp
  801fe4:	89 e5                	mov    %esp,%ebp
  801fe6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801fec:	ba 00 00 00 00       	mov    $0x0,%edx
  801ff1:	eb 03                	jmp    801ff6 <strnlen+0x13>
		n++;
  801ff3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ff6:	39 c2                	cmp    %eax,%edx
  801ff8:	74 08                	je     802002 <strnlen+0x1f>
  801ffa:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801ffe:	75 f3                	jne    801ff3 <strnlen+0x10>
  802000:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    

00802004 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	53                   	push   %ebx
  802008:	8b 45 08             	mov    0x8(%ebp),%eax
  80200b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80200e:	89 c2                	mov    %eax,%edx
  802010:	83 c2 01             	add    $0x1,%edx
  802013:	83 c1 01             	add    $0x1,%ecx
  802016:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80201a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80201d:	84 db                	test   %bl,%bl
  80201f:	75 ef                	jne    802010 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  802021:	5b                   	pop    %ebx
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    

00802024 <strcat>:

char *
strcat(char *dst, const char *src)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	53                   	push   %ebx
  802028:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80202b:	53                   	push   %ebx
  80202c:	e8 9a ff ff ff       	call   801fcb <strlen>
  802031:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  802034:	ff 75 0c             	pushl  0xc(%ebp)
  802037:	01 d8                	add    %ebx,%eax
  802039:	50                   	push   %eax
  80203a:	e8 c5 ff ff ff       	call   802004 <strcpy>
	return dst;
}
  80203f:	89 d8                	mov    %ebx,%eax
  802041:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802044:	c9                   	leave  
  802045:	c3                   	ret    

00802046 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	56                   	push   %esi
  80204a:	53                   	push   %ebx
  80204b:	8b 75 08             	mov    0x8(%ebp),%esi
  80204e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802051:	89 f3                	mov    %esi,%ebx
  802053:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802056:	89 f2                	mov    %esi,%edx
  802058:	eb 0f                	jmp    802069 <strncpy+0x23>
		*dst++ = *src;
  80205a:	83 c2 01             	add    $0x1,%edx
  80205d:	0f b6 01             	movzbl (%ecx),%eax
  802060:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  802063:	80 39 01             	cmpb   $0x1,(%ecx)
  802066:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  802069:	39 da                	cmp    %ebx,%edx
  80206b:	75 ed                	jne    80205a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80206d:	89 f0                	mov    %esi,%eax
  80206f:	5b                   	pop    %ebx
  802070:	5e                   	pop    %esi
  802071:	5d                   	pop    %ebp
  802072:	c3                   	ret    

00802073 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  802073:	55                   	push   %ebp
  802074:	89 e5                	mov    %esp,%ebp
  802076:	56                   	push   %esi
  802077:	53                   	push   %ebx
  802078:	8b 75 08             	mov    0x8(%ebp),%esi
  80207b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80207e:	8b 55 10             	mov    0x10(%ebp),%edx
  802081:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  802083:	85 d2                	test   %edx,%edx
  802085:	74 21                	je     8020a8 <strlcpy+0x35>
  802087:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80208b:	89 f2                	mov    %esi,%edx
  80208d:	eb 09                	jmp    802098 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80208f:	83 c2 01             	add    $0x1,%edx
  802092:	83 c1 01             	add    $0x1,%ecx
  802095:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  802098:	39 c2                	cmp    %eax,%edx
  80209a:	74 09                	je     8020a5 <strlcpy+0x32>
  80209c:	0f b6 19             	movzbl (%ecx),%ebx
  80209f:	84 db                	test   %bl,%bl
  8020a1:	75 ec                	jne    80208f <strlcpy+0x1c>
  8020a3:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8020a5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8020a8:	29 f0                	sub    %esi,%eax
}
  8020aa:	5b                   	pop    %ebx
  8020ab:	5e                   	pop    %esi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    

008020ae <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8020ae:	55                   	push   %ebp
  8020af:	89 e5                	mov    %esp,%ebp
  8020b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8020b7:	eb 06                	jmp    8020bf <strcmp+0x11>
		p++, q++;
  8020b9:	83 c1 01             	add    $0x1,%ecx
  8020bc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8020bf:	0f b6 01             	movzbl (%ecx),%eax
  8020c2:	84 c0                	test   %al,%al
  8020c4:	74 04                	je     8020ca <strcmp+0x1c>
  8020c6:	3a 02                	cmp    (%edx),%al
  8020c8:	74 ef                	je     8020b9 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8020ca:	0f b6 c0             	movzbl %al,%eax
  8020cd:	0f b6 12             	movzbl (%edx),%edx
  8020d0:	29 d0                	sub    %edx,%eax
}
  8020d2:	5d                   	pop    %ebp
  8020d3:	c3                   	ret    

008020d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8020d4:	55                   	push   %ebp
  8020d5:	89 e5                	mov    %esp,%ebp
  8020d7:	53                   	push   %ebx
  8020d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8020db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020de:	89 c3                	mov    %eax,%ebx
  8020e0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8020e3:	eb 06                	jmp    8020eb <strncmp+0x17>
		n--, p++, q++;
  8020e5:	83 c0 01             	add    $0x1,%eax
  8020e8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8020eb:	39 d8                	cmp    %ebx,%eax
  8020ed:	74 15                	je     802104 <strncmp+0x30>
  8020ef:	0f b6 08             	movzbl (%eax),%ecx
  8020f2:	84 c9                	test   %cl,%cl
  8020f4:	74 04                	je     8020fa <strncmp+0x26>
  8020f6:	3a 0a                	cmp    (%edx),%cl
  8020f8:	74 eb                	je     8020e5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8020fa:	0f b6 00             	movzbl (%eax),%eax
  8020fd:	0f b6 12             	movzbl (%edx),%edx
  802100:	29 d0                	sub    %edx,%eax
  802102:	eb 05                	jmp    802109 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  802104:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  802109:	5b                   	pop    %ebx
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    

0080210c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80210c:	55                   	push   %ebp
  80210d:	89 e5                	mov    %esp,%ebp
  80210f:	8b 45 08             	mov    0x8(%ebp),%eax
  802112:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802116:	eb 07                	jmp    80211f <strchr+0x13>
		if (*s == c)
  802118:	38 ca                	cmp    %cl,%dl
  80211a:	74 0f                	je     80212b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80211c:	83 c0 01             	add    $0x1,%eax
  80211f:	0f b6 10             	movzbl (%eax),%edx
  802122:	84 d2                	test   %dl,%dl
  802124:	75 f2                	jne    802118 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  802126:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80212b:	5d                   	pop    %ebp
  80212c:	c3                   	ret    

0080212d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80212d:	55                   	push   %ebp
  80212e:	89 e5                	mov    %esp,%ebp
  802130:	8b 45 08             	mov    0x8(%ebp),%eax
  802133:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  802137:	eb 03                	jmp    80213c <strfind+0xf>
  802139:	83 c0 01             	add    $0x1,%eax
  80213c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80213f:	84 d2                	test   %dl,%dl
  802141:	74 04                	je     802147 <strfind+0x1a>
  802143:	38 ca                	cmp    %cl,%dl
  802145:	75 f2                	jne    802139 <strfind+0xc>
			break;
	return (char *) s;
}
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    

00802149 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	57                   	push   %edi
  80214d:	56                   	push   %esi
  80214e:	53                   	push   %ebx
  80214f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802152:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  802155:	85 c9                	test   %ecx,%ecx
  802157:	74 36                	je     80218f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  802159:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80215f:	75 28                	jne    802189 <memset+0x40>
  802161:	f6 c1 03             	test   $0x3,%cl
  802164:	75 23                	jne    802189 <memset+0x40>
		c &= 0xFF;
  802166:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80216a:	89 d3                	mov    %edx,%ebx
  80216c:	c1 e3 08             	shl    $0x8,%ebx
  80216f:	89 d6                	mov    %edx,%esi
  802171:	c1 e6 18             	shl    $0x18,%esi
  802174:	89 d0                	mov    %edx,%eax
  802176:	c1 e0 10             	shl    $0x10,%eax
  802179:	09 f0                	or     %esi,%eax
  80217b:	09 c2                	or     %eax,%edx
  80217d:	89 d0                	mov    %edx,%eax
  80217f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  802181:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  802184:	fc                   	cld    
  802185:	f3 ab                	rep stos %eax,%es:(%edi)
  802187:	eb 06                	jmp    80218f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  802189:	8b 45 0c             	mov    0xc(%ebp),%eax
  80218c:	fc                   	cld    
  80218d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80218f:	89 f8                	mov    %edi,%eax
  802191:	5b                   	pop    %ebx
  802192:	5e                   	pop    %esi
  802193:	5f                   	pop    %edi
  802194:	5d                   	pop    %ebp
  802195:	c3                   	ret    

00802196 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  802196:	55                   	push   %ebp
  802197:	89 e5                	mov    %esp,%ebp
  802199:	57                   	push   %edi
  80219a:	56                   	push   %esi
  80219b:	8b 45 08             	mov    0x8(%ebp),%eax
  80219e:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8021a4:	39 c6                	cmp    %eax,%esi
  8021a6:	73 35                	jae    8021dd <memmove+0x47>
  8021a8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8021ab:	39 d0                	cmp    %edx,%eax
  8021ad:	73 2e                	jae    8021dd <memmove+0x47>
		s += n;
		d += n;
  8021af:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  8021b2:	89 d6                	mov    %edx,%esi
  8021b4:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021b6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8021bc:	75 13                	jne    8021d1 <memmove+0x3b>
  8021be:	f6 c1 03             	test   $0x3,%cl
  8021c1:	75 0e                	jne    8021d1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8021c3:	83 ef 04             	sub    $0x4,%edi
  8021c6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8021c9:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  8021cc:	fd                   	std    
  8021cd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021cf:	eb 09                	jmp    8021da <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8021d1:	83 ef 01             	sub    $0x1,%edi
  8021d4:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8021d7:	fd                   	std    
  8021d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8021da:	fc                   	cld    
  8021db:	eb 1d                	jmp    8021fa <memmove+0x64>
  8021dd:	89 f2                	mov    %esi,%edx
  8021df:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8021e1:	f6 c2 03             	test   $0x3,%dl
  8021e4:	75 0f                	jne    8021f5 <memmove+0x5f>
  8021e6:	f6 c1 03             	test   $0x3,%cl
  8021e9:	75 0a                	jne    8021f5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8021eb:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  8021ee:	89 c7                	mov    %eax,%edi
  8021f0:	fc                   	cld    
  8021f1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8021f3:	eb 05                	jmp    8021fa <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8021f5:	89 c7                	mov    %eax,%edi
  8021f7:	fc                   	cld    
  8021f8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8021fa:	5e                   	pop    %esi
  8021fb:	5f                   	pop    %edi
  8021fc:	5d                   	pop    %ebp
  8021fd:	c3                   	ret    

008021fe <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8021fe:	55                   	push   %ebp
  8021ff:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  802201:	ff 75 10             	pushl  0x10(%ebp)
  802204:	ff 75 0c             	pushl  0xc(%ebp)
  802207:	ff 75 08             	pushl  0x8(%ebp)
  80220a:	e8 87 ff ff ff       	call   802196 <memmove>
}
  80220f:	c9                   	leave  
  802210:	c3                   	ret    

00802211 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  802211:	55                   	push   %ebp
  802212:	89 e5                	mov    %esp,%ebp
  802214:	56                   	push   %esi
  802215:	53                   	push   %ebx
  802216:	8b 45 08             	mov    0x8(%ebp),%eax
  802219:	8b 55 0c             	mov    0xc(%ebp),%edx
  80221c:	89 c6                	mov    %eax,%esi
  80221e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  802221:	eb 1a                	jmp    80223d <memcmp+0x2c>
		if (*s1 != *s2)
  802223:	0f b6 08             	movzbl (%eax),%ecx
  802226:	0f b6 1a             	movzbl (%edx),%ebx
  802229:	38 d9                	cmp    %bl,%cl
  80222b:	74 0a                	je     802237 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80222d:	0f b6 c1             	movzbl %cl,%eax
  802230:	0f b6 db             	movzbl %bl,%ebx
  802233:	29 d8                	sub    %ebx,%eax
  802235:	eb 0f                	jmp    802246 <memcmp+0x35>
		s1++, s2++;
  802237:	83 c0 01             	add    $0x1,%eax
  80223a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80223d:	39 f0                	cmp    %esi,%eax
  80223f:	75 e2                	jne    802223 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  802241:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802246:	5b                   	pop    %ebx
  802247:	5e                   	pop    %esi
  802248:	5d                   	pop    %ebp
  802249:	c3                   	ret    

0080224a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80224a:	55                   	push   %ebp
  80224b:	89 e5                	mov    %esp,%ebp
  80224d:	8b 45 08             	mov    0x8(%ebp),%eax
  802250:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  802253:	89 c2                	mov    %eax,%edx
  802255:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  802258:	eb 07                	jmp    802261 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  80225a:	38 08                	cmp    %cl,(%eax)
  80225c:	74 07                	je     802265 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80225e:	83 c0 01             	add    $0x1,%eax
  802261:	39 d0                	cmp    %edx,%eax
  802263:	72 f5                	jb     80225a <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  802265:	5d                   	pop    %ebp
  802266:	c3                   	ret    

00802267 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  802267:	55                   	push   %ebp
  802268:	89 e5                	mov    %esp,%ebp
  80226a:	57                   	push   %edi
  80226b:	56                   	push   %esi
  80226c:	53                   	push   %ebx
  80226d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802270:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802273:	eb 03                	jmp    802278 <strtol+0x11>
		s++;
  802275:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  802278:	0f b6 01             	movzbl (%ecx),%eax
  80227b:	3c 09                	cmp    $0x9,%al
  80227d:	74 f6                	je     802275 <strtol+0xe>
  80227f:	3c 20                	cmp    $0x20,%al
  802281:	74 f2                	je     802275 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  802283:	3c 2b                	cmp    $0x2b,%al
  802285:	75 0a                	jne    802291 <strtol+0x2a>
		s++;
  802287:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80228a:	bf 00 00 00 00       	mov    $0x0,%edi
  80228f:	eb 10                	jmp    8022a1 <strtol+0x3a>
  802291:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  802296:	3c 2d                	cmp    $0x2d,%al
  802298:	75 07                	jne    8022a1 <strtol+0x3a>
		s++, neg = 1;
  80229a:	8d 49 01             	lea    0x1(%ecx),%ecx
  80229d:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8022a1:	85 db                	test   %ebx,%ebx
  8022a3:	0f 94 c0             	sete   %al
  8022a6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8022ac:	75 19                	jne    8022c7 <strtol+0x60>
  8022ae:	80 39 30             	cmpb   $0x30,(%ecx)
  8022b1:	75 14                	jne    8022c7 <strtol+0x60>
  8022b3:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8022b7:	0f 85 8a 00 00 00    	jne    802347 <strtol+0xe0>
		s += 2, base = 16;
  8022bd:	83 c1 02             	add    $0x2,%ecx
  8022c0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8022c5:	eb 16                	jmp    8022dd <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8022c7:	84 c0                	test   %al,%al
  8022c9:	74 12                	je     8022dd <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8022cb:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8022d0:	80 39 30             	cmpb   $0x30,(%ecx)
  8022d3:	75 08                	jne    8022dd <strtol+0x76>
		s++, base = 8;
  8022d5:	83 c1 01             	add    $0x1,%ecx
  8022d8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8022dd:	b8 00 00 00 00       	mov    $0x0,%eax
  8022e2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8022e5:	0f b6 11             	movzbl (%ecx),%edx
  8022e8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8022eb:	89 f3                	mov    %esi,%ebx
  8022ed:	80 fb 09             	cmp    $0x9,%bl
  8022f0:	77 08                	ja     8022fa <strtol+0x93>
			dig = *s - '0';
  8022f2:	0f be d2             	movsbl %dl,%edx
  8022f5:	83 ea 30             	sub    $0x30,%edx
  8022f8:	eb 22                	jmp    80231c <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  8022fa:	8d 72 9f             	lea    -0x61(%edx),%esi
  8022fd:	89 f3                	mov    %esi,%ebx
  8022ff:	80 fb 19             	cmp    $0x19,%bl
  802302:	77 08                	ja     80230c <strtol+0xa5>
			dig = *s - 'a' + 10;
  802304:	0f be d2             	movsbl %dl,%edx
  802307:	83 ea 57             	sub    $0x57,%edx
  80230a:	eb 10                	jmp    80231c <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  80230c:	8d 72 bf             	lea    -0x41(%edx),%esi
  80230f:	89 f3                	mov    %esi,%ebx
  802311:	80 fb 19             	cmp    $0x19,%bl
  802314:	77 16                	ja     80232c <strtol+0xc5>
			dig = *s - 'A' + 10;
  802316:	0f be d2             	movsbl %dl,%edx
  802319:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80231c:	3b 55 10             	cmp    0x10(%ebp),%edx
  80231f:	7d 0f                	jge    802330 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  802321:	83 c1 01             	add    $0x1,%ecx
  802324:	0f af 45 10          	imul   0x10(%ebp),%eax
  802328:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  80232a:	eb b9                	jmp    8022e5 <strtol+0x7e>
  80232c:	89 c2                	mov    %eax,%edx
  80232e:	eb 02                	jmp    802332 <strtol+0xcb>
  802330:	89 c2                	mov    %eax,%edx

	if (endptr)
  802332:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  802336:	74 05                	je     80233d <strtol+0xd6>
		*endptr = (char *) s;
  802338:	8b 75 0c             	mov    0xc(%ebp),%esi
  80233b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80233d:	85 ff                	test   %edi,%edi
  80233f:	74 0c                	je     80234d <strtol+0xe6>
  802341:	89 d0                	mov    %edx,%eax
  802343:	f7 d8                	neg    %eax
  802345:	eb 06                	jmp    80234d <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  802347:	84 c0                	test   %al,%al
  802349:	75 8a                	jne    8022d5 <strtol+0x6e>
  80234b:	eb 90                	jmp    8022dd <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  80234d:	5b                   	pop    %ebx
  80234e:	5e                   	pop    %esi
  80234f:	5f                   	pop    %edi
  802350:	5d                   	pop    %ebp
  802351:	c3                   	ret    

00802352 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  802352:	55                   	push   %ebp
  802353:	89 e5                	mov    %esp,%ebp
  802355:	57                   	push   %edi
  802356:	56                   	push   %esi
  802357:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802358:	b8 00 00 00 00       	mov    $0x0,%eax
  80235d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802360:	8b 55 08             	mov    0x8(%ebp),%edx
  802363:	89 c3                	mov    %eax,%ebx
  802365:	89 c7                	mov    %eax,%edi
  802367:	89 c6                	mov    %eax,%esi
  802369:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80236b:	5b                   	pop    %ebx
  80236c:	5e                   	pop    %esi
  80236d:	5f                   	pop    %edi
  80236e:	5d                   	pop    %ebp
  80236f:	c3                   	ret    

00802370 <sys_cgetc>:

int
sys_cgetc(void)
{
  802370:	55                   	push   %ebp
  802371:	89 e5                	mov    %esp,%ebp
  802373:	57                   	push   %edi
  802374:	56                   	push   %esi
  802375:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802376:	ba 00 00 00 00       	mov    $0x0,%edx
  80237b:	b8 01 00 00 00       	mov    $0x1,%eax
  802380:	89 d1                	mov    %edx,%ecx
  802382:	89 d3                	mov    %edx,%ebx
  802384:	89 d7                	mov    %edx,%edi
  802386:	89 d6                	mov    %edx,%esi
  802388:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  80238a:	5b                   	pop    %ebx
  80238b:	5e                   	pop    %esi
  80238c:	5f                   	pop    %edi
  80238d:	5d                   	pop    %ebp
  80238e:	c3                   	ret    

0080238f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80238f:	55                   	push   %ebp
  802390:	89 e5                	mov    %esp,%ebp
  802392:	57                   	push   %edi
  802393:	56                   	push   %esi
  802394:	53                   	push   %ebx
  802395:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802398:	b9 00 00 00 00       	mov    $0x0,%ecx
  80239d:	b8 03 00 00 00       	mov    $0x3,%eax
  8023a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8023a5:	89 cb                	mov    %ecx,%ebx
  8023a7:	89 cf                	mov    %ecx,%edi
  8023a9:	89 ce                	mov    %ecx,%esi
  8023ab:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8023ad:	85 c0                	test   %eax,%eax
  8023af:	7e 17                	jle    8023c8 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8023b1:	83 ec 0c             	sub    $0xc,%esp
  8023b4:	50                   	push   %eax
  8023b5:	6a 03                	push   $0x3
  8023b7:	68 5f 40 80 00       	push   $0x80405f
  8023bc:	6a 23                	push   $0x23
  8023be:	68 7c 40 80 00       	push   $0x80407c
  8023c3:	e8 df f5 ff ff       	call   8019a7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8023c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023cb:	5b                   	pop    %ebx
  8023cc:	5e                   	pop    %esi
  8023cd:	5f                   	pop    %edi
  8023ce:	5d                   	pop    %ebp
  8023cf:	c3                   	ret    

008023d0 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8023d0:	55                   	push   %ebp
  8023d1:	89 e5                	mov    %esp,%ebp
  8023d3:	57                   	push   %edi
  8023d4:	56                   	push   %esi
  8023d5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023d6:	ba 00 00 00 00       	mov    $0x0,%edx
  8023db:	b8 02 00 00 00       	mov    $0x2,%eax
  8023e0:	89 d1                	mov    %edx,%ecx
  8023e2:	89 d3                	mov    %edx,%ebx
  8023e4:	89 d7                	mov    %edx,%edi
  8023e6:	89 d6                	mov    %edx,%esi
  8023e8:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8023ea:	5b                   	pop    %ebx
  8023eb:	5e                   	pop    %esi
  8023ec:	5f                   	pop    %edi
  8023ed:	5d                   	pop    %ebp
  8023ee:	c3                   	ret    

008023ef <sys_yield>:

void
sys_yield(void)
{
  8023ef:	55                   	push   %ebp
  8023f0:	89 e5                	mov    %esp,%ebp
  8023f2:	57                   	push   %edi
  8023f3:	56                   	push   %esi
  8023f4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8023f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8023fa:	b8 0b 00 00 00       	mov    $0xb,%eax
  8023ff:	89 d1                	mov    %edx,%ecx
  802401:	89 d3                	mov    %edx,%ebx
  802403:	89 d7                	mov    %edx,%edi
  802405:	89 d6                	mov    %edx,%esi
  802407:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  802409:	5b                   	pop    %ebx
  80240a:	5e                   	pop    %esi
  80240b:	5f                   	pop    %edi
  80240c:	5d                   	pop    %ebp
  80240d:	c3                   	ret    

0080240e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80240e:	55                   	push   %ebp
  80240f:	89 e5                	mov    %esp,%ebp
  802411:	57                   	push   %edi
  802412:	56                   	push   %esi
  802413:	53                   	push   %ebx
  802414:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802417:	be 00 00 00 00       	mov    $0x0,%esi
  80241c:	b8 04 00 00 00       	mov    $0x4,%eax
  802421:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802424:	8b 55 08             	mov    0x8(%ebp),%edx
  802427:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80242a:	89 f7                	mov    %esi,%edi
  80242c:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80242e:	85 c0                	test   %eax,%eax
  802430:	7e 17                	jle    802449 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  802432:	83 ec 0c             	sub    $0xc,%esp
  802435:	50                   	push   %eax
  802436:	6a 04                	push   $0x4
  802438:	68 5f 40 80 00       	push   $0x80405f
  80243d:	6a 23                	push   $0x23
  80243f:	68 7c 40 80 00       	push   $0x80407c
  802444:	e8 5e f5 ff ff       	call   8019a7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  802449:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80244c:	5b                   	pop    %ebx
  80244d:	5e                   	pop    %esi
  80244e:	5f                   	pop    %edi
  80244f:	5d                   	pop    %ebp
  802450:	c3                   	ret    

00802451 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  802451:	55                   	push   %ebp
  802452:	89 e5                	mov    %esp,%ebp
  802454:	57                   	push   %edi
  802455:	56                   	push   %esi
  802456:	53                   	push   %ebx
  802457:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80245a:	b8 05 00 00 00       	mov    $0x5,%eax
  80245f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802462:	8b 55 08             	mov    0x8(%ebp),%edx
  802465:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802468:	8b 7d 14             	mov    0x14(%ebp),%edi
  80246b:	8b 75 18             	mov    0x18(%ebp),%esi
  80246e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802470:	85 c0                	test   %eax,%eax
  802472:	7e 17                	jle    80248b <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  802474:	83 ec 0c             	sub    $0xc,%esp
  802477:	50                   	push   %eax
  802478:	6a 05                	push   $0x5
  80247a:	68 5f 40 80 00       	push   $0x80405f
  80247f:	6a 23                	push   $0x23
  802481:	68 7c 40 80 00       	push   $0x80407c
  802486:	e8 1c f5 ff ff       	call   8019a7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80248b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80248e:	5b                   	pop    %ebx
  80248f:	5e                   	pop    %esi
  802490:	5f                   	pop    %edi
  802491:	5d                   	pop    %ebp
  802492:	c3                   	ret    

00802493 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  802493:	55                   	push   %ebp
  802494:	89 e5                	mov    %esp,%ebp
  802496:	57                   	push   %edi
  802497:	56                   	push   %esi
  802498:	53                   	push   %ebx
  802499:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80249c:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024a1:	b8 06 00 00 00       	mov    $0x6,%eax
  8024a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8024ac:	89 df                	mov    %ebx,%edi
  8024ae:	89 de                	mov    %ebx,%esi
  8024b0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024b2:	85 c0                	test   %eax,%eax
  8024b4:	7e 17                	jle    8024cd <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024b6:	83 ec 0c             	sub    $0xc,%esp
  8024b9:	50                   	push   %eax
  8024ba:	6a 06                	push   $0x6
  8024bc:	68 5f 40 80 00       	push   $0x80405f
  8024c1:	6a 23                	push   $0x23
  8024c3:	68 7c 40 80 00       	push   $0x80407c
  8024c8:	e8 da f4 ff ff       	call   8019a7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8024cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d0:	5b                   	pop    %ebx
  8024d1:	5e                   	pop    %esi
  8024d2:	5f                   	pop    %edi
  8024d3:	5d                   	pop    %ebp
  8024d4:	c3                   	ret    

008024d5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8024d5:	55                   	push   %ebp
  8024d6:	89 e5                	mov    %esp,%ebp
  8024d8:	57                   	push   %edi
  8024d9:	56                   	push   %esi
  8024da:	53                   	push   %ebx
  8024db:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8024de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8024e3:	b8 08 00 00 00       	mov    $0x8,%eax
  8024e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8024eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8024ee:	89 df                	mov    %ebx,%edi
  8024f0:	89 de                	mov    %ebx,%esi
  8024f2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8024f4:	85 c0                	test   %eax,%eax
  8024f6:	7e 17                	jle    80250f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8024f8:	83 ec 0c             	sub    $0xc,%esp
  8024fb:	50                   	push   %eax
  8024fc:	6a 08                	push   $0x8
  8024fe:	68 5f 40 80 00       	push   $0x80405f
  802503:	6a 23                	push   $0x23
  802505:	68 7c 40 80 00       	push   $0x80407c
  80250a:	e8 98 f4 ff ff       	call   8019a7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80250f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802512:	5b                   	pop    %ebx
  802513:	5e                   	pop    %esi
  802514:	5f                   	pop    %edi
  802515:	5d                   	pop    %ebp
  802516:	c3                   	ret    

00802517 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	57                   	push   %edi
  80251b:	56                   	push   %esi
  80251c:	53                   	push   %ebx
  80251d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802520:	bb 00 00 00 00       	mov    $0x0,%ebx
  802525:	b8 09 00 00 00       	mov    $0x9,%eax
  80252a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80252d:	8b 55 08             	mov    0x8(%ebp),%edx
  802530:	89 df                	mov    %ebx,%edi
  802532:	89 de                	mov    %ebx,%esi
  802534:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802536:	85 c0                	test   %eax,%eax
  802538:	7e 17                	jle    802551 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80253a:	83 ec 0c             	sub    $0xc,%esp
  80253d:	50                   	push   %eax
  80253e:	6a 09                	push   $0x9
  802540:	68 5f 40 80 00       	push   $0x80405f
  802545:	6a 23                	push   $0x23
  802547:	68 7c 40 80 00       	push   $0x80407c
  80254c:	e8 56 f4 ff ff       	call   8019a7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  802551:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802554:	5b                   	pop    %ebx
  802555:	5e                   	pop    %esi
  802556:	5f                   	pop    %edi
  802557:	5d                   	pop    %ebp
  802558:	c3                   	ret    

00802559 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  802559:	55                   	push   %ebp
  80255a:	89 e5                	mov    %esp,%ebp
  80255c:	57                   	push   %edi
  80255d:	56                   	push   %esi
  80255e:	53                   	push   %ebx
  80255f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802562:	bb 00 00 00 00       	mov    $0x0,%ebx
  802567:	b8 0a 00 00 00       	mov    $0xa,%eax
  80256c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80256f:	8b 55 08             	mov    0x8(%ebp),%edx
  802572:	89 df                	mov    %ebx,%edi
  802574:	89 de                	mov    %ebx,%esi
  802576:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  802578:	85 c0                	test   %eax,%eax
  80257a:	7e 17                	jle    802593 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80257c:	83 ec 0c             	sub    $0xc,%esp
  80257f:	50                   	push   %eax
  802580:	6a 0a                	push   $0xa
  802582:	68 5f 40 80 00       	push   $0x80405f
  802587:	6a 23                	push   $0x23
  802589:	68 7c 40 80 00       	push   $0x80407c
  80258e:	e8 14 f4 ff ff       	call   8019a7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  802593:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802596:	5b                   	pop    %ebx
  802597:	5e                   	pop    %esi
  802598:	5f                   	pop    %edi
  802599:	5d                   	pop    %ebp
  80259a:	c3                   	ret    

0080259b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80259b:	55                   	push   %ebp
  80259c:	89 e5                	mov    %esp,%ebp
  80259e:	57                   	push   %edi
  80259f:	56                   	push   %esi
  8025a0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025a1:	be 00 00 00 00       	mov    $0x0,%esi
  8025a6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8025ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8025b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8025b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8025b7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8025b9:	5b                   	pop    %ebx
  8025ba:	5e                   	pop    %esi
  8025bb:	5f                   	pop    %edi
  8025bc:	5d                   	pop    %ebp
  8025bd:	c3                   	ret    

008025be <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8025be:	55                   	push   %ebp
  8025bf:	89 e5                	mov    %esp,%ebp
  8025c1:	57                   	push   %edi
  8025c2:	56                   	push   %esi
  8025c3:	53                   	push   %ebx
  8025c4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8025c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8025cc:	b8 0d 00 00 00       	mov    $0xd,%eax
  8025d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8025d4:	89 cb                	mov    %ecx,%ebx
  8025d6:	89 cf                	mov    %ecx,%edi
  8025d8:	89 ce                	mov    %ecx,%esi
  8025da:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8025dc:	85 c0                	test   %eax,%eax
  8025de:	7e 17                	jle    8025f7 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8025e0:	83 ec 0c             	sub    $0xc,%esp
  8025e3:	50                   	push   %eax
  8025e4:	6a 0d                	push   $0xd
  8025e6:	68 5f 40 80 00       	push   $0x80405f
  8025eb:	6a 23                	push   $0x23
  8025ed:	68 7c 40 80 00       	push   $0x80407c
  8025f2:	e8 b0 f3 ff ff       	call   8019a7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8025f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025fa:	5b                   	pop    %ebx
  8025fb:	5e                   	pop    %esi
  8025fc:	5f                   	pop    %edi
  8025fd:	5d                   	pop    %ebp
  8025fe:	c3                   	ret    

008025ff <sys_gettime>:

int sys_gettime(void)
{
  8025ff:	55                   	push   %ebp
  802600:	89 e5                	mov    %esp,%ebp
  802602:	57                   	push   %edi
  802603:	56                   	push   %esi
  802604:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  802605:	ba 00 00 00 00       	mov    $0x0,%edx
  80260a:	b8 0e 00 00 00       	mov    $0xe,%eax
  80260f:	89 d1                	mov    %edx,%ecx
  802611:	89 d3                	mov    %edx,%ebx
  802613:	89 d7                	mov    %edx,%edi
  802615:	89 d6                	mov    %edx,%esi
  802617:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  802619:	5b                   	pop    %ebx
  80261a:	5e                   	pop    %esi
  80261b:	5f                   	pop    %edi
  80261c:	5d                   	pop    %ebp
  80261d:	c3                   	ret    

0080261e <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80261e:	55                   	push   %ebp
  80261f:	89 e5                	mov    %esp,%ebp
  802621:	83 ec 08             	sub    $0x8,%esp
	if (_pgfault_handler == 0) {
  802624:	83 3d 10 a0 80 00 00 	cmpl   $0x0,0x80a010
  80262b:	75 2c                	jne    802659 <set_pgfault_handler+0x3b>
		// First time through!
		// LAB 9: Your code here.
		if (sys_page_alloc(0, (void*)(UXSTACKTOP-PGSIZE), PTE_W|PTE_U|PTE_P) < 0) 
  80262d:	83 ec 04             	sub    $0x4,%esp
  802630:	6a 07                	push   $0x7
  802632:	68 00 f0 7f ee       	push   $0xee7ff000
  802637:	6a 00                	push   $0x0
  802639:	e8 d0 fd ff ff       	call   80240e <sys_page_alloc>
  80263e:	83 c4 10             	add    $0x10,%esp
  802641:	85 c0                	test   %eax,%eax
  802643:	79 14                	jns    802659 <set_pgfault_handler+0x3b>
			panic("set_pgfault_handler:sys_page_alloc failed");
  802645:	83 ec 04             	sub    $0x4,%esp
  802648:	68 8c 40 80 00       	push   $0x80408c
  80264d:	6a 1f                	push   $0x1f
  80264f:	68 ee 40 80 00       	push   $0x8040ee
  802654:	e8 4e f3 ff ff       	call   8019a7 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802659:	8b 45 08             	mov    0x8(%ebp),%eax
  80265c:	a3 10 a0 80 00       	mov    %eax,0x80a010
	if (sys_env_set_pgfault_upcall(0, _pgfault_upcall) < 0)
  802661:	83 ec 08             	sub    $0x8,%esp
  802664:	68 8d 26 80 00       	push   $0x80268d
  802669:	6a 00                	push   $0x0
  80266b:	e8 e9 fe ff ff       	call   802559 <sys_env_set_pgfault_upcall>
  802670:	83 c4 10             	add    $0x10,%esp
  802673:	85 c0                	test   %eax,%eax
  802675:	79 14                	jns    80268b <set_pgfault_handler+0x6d>
		panic("set_pgfault_handler:sys_env_set_pgfault_upcall failed");
  802677:	83 ec 04             	sub    $0x4,%esp
  80267a:	68 b8 40 80 00       	push   $0x8040b8
  80267f:	6a 25                	push   $0x25
  802681:	68 ee 40 80 00       	push   $0x8040ee
  802686:	e8 1c f3 ff ff       	call   8019a7 <_panic>
}
  80268b:	c9                   	leave  
  80268c:	c3                   	ret    

0080268d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80268d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80268e:	a1 10 a0 80 00       	mov    0x80a010,%eax
	call *%eax
  802693:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802695:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 9: Your code here.
	movl %esp, %eax 
  802698:	89 e0                	mov    %esp,%eax
	movl 40(%esp), %ebx 
  80269a:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl 48(%esp), %esp 
  80269e:	8b 64 24 30          	mov    0x30(%esp),%esp
	pushl %ebx 
  8026a2:	53                   	push   %ebx
	movl %esp, 48(%eax) 
  8026a3:	89 60 30             	mov    %esp,0x30(%eax)
	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 9: Your code here.
	movl %eax, %esp 
  8026a6:	89 c4                	mov    %eax,%esp
	addl $4, %esp 
  8026a8:	83 c4 04             	add    $0x4,%esp
	addl $4, %esp 
  8026ab:	83 c4 04             	add    $0x4,%esp
	popal 
  8026ae:	61                   	popa   
	addl $4, %esp 
  8026af:	83 c4 04             	add    $0x4,%esp
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 9: Your code here.
	popfl
  8026b2:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 9: Your code here.
	popl %esp
  8026b3:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 9: Your code here.
  8026b4:	c3                   	ret    

008026b5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8026b5:	55                   	push   %ebp
  8026b6:	89 e5                	mov    %esp,%ebp
  8026b8:	56                   	push   %esi
  8026b9:	53                   	push   %ebx
  8026ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8026bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8026c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  8026c3:	85 f6                	test   %esi,%esi
  8026c5:	74 06                	je     8026cd <ipc_recv+0x18>
  8026c7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  8026cd:	85 db                	test   %ebx,%ebx
  8026cf:	74 06                	je     8026d7 <ipc_recv+0x22>
  8026d1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  8026d7:	83 f8 01             	cmp    $0x1,%eax
  8026da:	19 d2                	sbb    %edx,%edx
  8026dc:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  8026de:	83 ec 0c             	sub    $0xc,%esp
  8026e1:	50                   	push   %eax
  8026e2:	e8 d7 fe ff ff       	call   8025be <sys_ipc_recv>
  8026e7:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  8026e9:	83 c4 10             	add    $0x10,%esp
  8026ec:	85 d2                	test   %edx,%edx
  8026ee:	75 24                	jne    802714 <ipc_recv+0x5f>
	if (from_env_store)
  8026f0:	85 f6                	test   %esi,%esi
  8026f2:	74 0a                	je     8026fe <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  8026f4:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  8026f9:	8b 40 70             	mov    0x70(%eax),%eax
  8026fc:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  8026fe:	85 db                	test   %ebx,%ebx
  802700:	74 0a                	je     80270c <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  802702:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802707:	8b 40 74             	mov    0x74(%eax),%eax
  80270a:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  80270c:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802711:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  802714:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802717:	5b                   	pop    %ebx
  802718:	5e                   	pop    %esi
  802719:	5d                   	pop    %ebp
  80271a:	c3                   	ret    

0080271b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80271b:	55                   	push   %ebp
  80271c:	89 e5                	mov    %esp,%ebp
  80271e:	57                   	push   %edi
  80271f:	56                   	push   %esi
  802720:	53                   	push   %ebx
  802721:	83 ec 0c             	sub    $0xc,%esp
  802724:	8b 7d 08             	mov    0x8(%ebp),%edi
  802727:	8b 75 0c             	mov    0xc(%ebp),%esi
  80272a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  80272d:	83 fb 01             	cmp    $0x1,%ebx
  802730:	19 c0                	sbb    %eax,%eax
  802732:	09 c3                	or     %eax,%ebx
  802734:	eb 1c                	jmp    802752 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  802736:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802739:	74 12                	je     80274d <ipc_send+0x32>
  80273b:	50                   	push   %eax
  80273c:	68 fc 40 80 00       	push   $0x8040fc
  802741:	6a 36                	push   $0x36
  802743:	68 13 41 80 00       	push   $0x804113
  802748:	e8 5a f2 ff ff       	call   8019a7 <_panic>
		sys_yield();
  80274d:	e8 9d fc ff ff       	call   8023ef <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  802752:	ff 75 14             	pushl  0x14(%ebp)
  802755:	53                   	push   %ebx
  802756:	56                   	push   %esi
  802757:	57                   	push   %edi
  802758:	e8 3e fe ff ff       	call   80259b <sys_ipc_try_send>
		if (ret == 0) break;
  80275d:	83 c4 10             	add    $0x10,%esp
  802760:	85 c0                	test   %eax,%eax
  802762:	75 d2                	jne    802736 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  802764:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802767:	5b                   	pop    %ebx
  802768:	5e                   	pop    %esi
  802769:	5f                   	pop    %edi
  80276a:	5d                   	pop    %ebp
  80276b:	c3                   	ret    

0080276c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80276c:	55                   	push   %ebp
  80276d:	89 e5                	mov    %esp,%ebp
  80276f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802772:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802777:	6b d0 78             	imul   $0x78,%eax,%edx
  80277a:	83 c2 50             	add    $0x50,%edx
  80277d:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  802783:	39 ca                	cmp    %ecx,%edx
  802785:	75 0d                	jne    802794 <ipc_find_env+0x28>
			return envs[i].env_id;
  802787:	6b c0 78             	imul   $0x78,%eax,%eax
  80278a:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  80278f:	8b 40 08             	mov    0x8(%eax),%eax
  802792:	eb 0e                	jmp    8027a2 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802794:	83 c0 01             	add    $0x1,%eax
  802797:	3d 00 04 00 00       	cmp    $0x400,%eax
  80279c:	75 d9                	jne    802777 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80279e:	66 b8 00 00          	mov    $0x0,%ax
}
  8027a2:	5d                   	pop    %ebp
  8027a3:	c3                   	ret    

008027a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8027a4:	55                   	push   %ebp
  8027a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8027a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8027aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8027af:	c1 e8 0c             	shr    $0xc,%eax
}
  8027b2:	5d                   	pop    %ebp
  8027b3:	c3                   	ret    

008027b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8027b4:	55                   	push   %ebp
  8027b5:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8027b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8027ba:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  8027bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8027c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    

008027cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8027cb:	55                   	push   %ebp
  8027cc:	89 e5                	mov    %esp,%ebp
  8027ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8027d6:	89 c2                	mov    %eax,%edx
  8027d8:	c1 ea 16             	shr    $0x16,%edx
  8027db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8027e2:	f6 c2 01             	test   $0x1,%dl
  8027e5:	74 11                	je     8027f8 <fd_alloc+0x2d>
  8027e7:	89 c2                	mov    %eax,%edx
  8027e9:	c1 ea 0c             	shr    $0xc,%edx
  8027ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8027f3:	f6 c2 01             	test   $0x1,%dl
  8027f6:	75 09                	jne    802801 <fd_alloc+0x36>
			*fd_store = fd;
  8027f8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8027fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8027ff:	eb 17                	jmp    802818 <fd_alloc+0x4d>
  802801:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  802806:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80280b:	75 c9                	jne    8027d6 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80280d:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  802813:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  802818:	5d                   	pop    %ebp
  802819:	c3                   	ret    

0080281a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80281a:	55                   	push   %ebp
  80281b:	89 e5                	mov    %esp,%ebp
  80281d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  802820:	83 f8 1f             	cmp    $0x1f,%eax
  802823:	77 36                	ja     80285b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  802825:	c1 e0 0c             	shl    $0xc,%eax
  802828:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80282d:	89 c2                	mov    %eax,%edx
  80282f:	c1 ea 16             	shr    $0x16,%edx
  802832:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802839:	f6 c2 01             	test   $0x1,%dl
  80283c:	74 24                	je     802862 <fd_lookup+0x48>
  80283e:	89 c2                	mov    %eax,%edx
  802840:	c1 ea 0c             	shr    $0xc,%edx
  802843:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80284a:	f6 c2 01             	test   $0x1,%dl
  80284d:	74 1a                	je     802869 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80284f:	8b 55 0c             	mov    0xc(%ebp),%edx
  802852:	89 02                	mov    %eax,(%edx)
	return 0;
  802854:	b8 00 00 00 00       	mov    $0x0,%eax
  802859:	eb 13                	jmp    80286e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80285b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802860:	eb 0c                	jmp    80286e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  802862:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  802867:	eb 05                	jmp    80286e <fd_lookup+0x54>
  802869:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80286e:	5d                   	pop    %ebp
  80286f:	c3                   	ret    

00802870 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  802870:	55                   	push   %ebp
  802871:	89 e5                	mov    %esp,%ebp
  802873:	83 ec 08             	sub    $0x8,%esp
  802876:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802879:	ba 9c 41 80 00       	mov    $0x80419c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80287e:	eb 13                	jmp    802893 <dev_lookup+0x23>
  802880:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  802883:	39 08                	cmp    %ecx,(%eax)
  802885:	75 0c                	jne    802893 <dev_lookup+0x23>
			*dev = devtab[i];
  802887:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80288a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80288c:	b8 00 00 00 00       	mov    $0x0,%eax
  802891:	eb 2e                	jmp    8028c1 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  802893:	8b 02                	mov    (%edx),%eax
  802895:	85 c0                	test   %eax,%eax
  802897:	75 e7                	jne    802880 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  802899:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  80289e:	8b 40 48             	mov    0x48(%eax),%eax
  8028a1:	83 ec 04             	sub    $0x4,%esp
  8028a4:	51                   	push   %ecx
  8028a5:	50                   	push   %eax
  8028a6:	68 20 41 80 00       	push   $0x804120
  8028ab:	e8 d0 f1 ff ff       	call   801a80 <cprintf>
	*dev = 0;
  8028b0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8028b3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8028b9:	83 c4 10             	add    $0x10,%esp
  8028bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8028c1:	c9                   	leave  
  8028c2:	c3                   	ret    

008028c3 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8028c3:	55                   	push   %ebp
  8028c4:	89 e5                	mov    %esp,%ebp
  8028c6:	56                   	push   %esi
  8028c7:	53                   	push   %ebx
  8028c8:	83 ec 10             	sub    $0x10,%esp
  8028cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8028ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8028d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8028d4:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8028d5:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8028db:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8028de:	50                   	push   %eax
  8028df:	e8 36 ff ff ff       	call   80281a <fd_lookup>
  8028e4:	83 c4 08             	add    $0x8,%esp
  8028e7:	85 c0                	test   %eax,%eax
  8028e9:	78 05                	js     8028f0 <fd_close+0x2d>
	    || fd != fd2)
  8028eb:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8028ee:	74 0b                	je     8028fb <fd_close+0x38>
		return (must_exist ? r : 0);
  8028f0:	80 fb 01             	cmp    $0x1,%bl
  8028f3:	19 d2                	sbb    %edx,%edx
  8028f5:	f7 d2                	not    %edx
  8028f7:	21 d0                	and    %edx,%eax
  8028f9:	eb 41                	jmp    80293c <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8028fb:	83 ec 08             	sub    $0x8,%esp
  8028fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802901:	50                   	push   %eax
  802902:	ff 36                	pushl  (%esi)
  802904:	e8 67 ff ff ff       	call   802870 <dev_lookup>
  802909:	89 c3                	mov    %eax,%ebx
  80290b:	83 c4 10             	add    $0x10,%esp
  80290e:	85 c0                	test   %eax,%eax
  802910:	78 1a                	js     80292c <fd_close+0x69>
		if (dev->dev_close)
  802912:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802915:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  802918:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80291d:	85 c0                	test   %eax,%eax
  80291f:	74 0b                	je     80292c <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  802921:	83 ec 0c             	sub    $0xc,%esp
  802924:	56                   	push   %esi
  802925:	ff d0                	call   *%eax
  802927:	89 c3                	mov    %eax,%ebx
  802929:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80292c:	83 ec 08             	sub    $0x8,%esp
  80292f:	56                   	push   %esi
  802930:	6a 00                	push   $0x0
  802932:	e8 5c fb ff ff       	call   802493 <sys_page_unmap>
	return r;
  802937:	83 c4 10             	add    $0x10,%esp
  80293a:	89 d8                	mov    %ebx,%eax
}
  80293c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80293f:	5b                   	pop    %ebx
  802940:	5e                   	pop    %esi
  802941:	5d                   	pop    %ebp
  802942:	c3                   	ret    

00802943 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  802943:	55                   	push   %ebp
  802944:	89 e5                	mov    %esp,%ebp
  802946:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802949:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80294c:	50                   	push   %eax
  80294d:	ff 75 08             	pushl  0x8(%ebp)
  802950:	e8 c5 fe ff ff       	call   80281a <fd_lookup>
  802955:	89 c2                	mov    %eax,%edx
  802957:	83 c4 08             	add    $0x8,%esp
  80295a:	85 d2                	test   %edx,%edx
  80295c:	78 10                	js     80296e <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  80295e:	83 ec 08             	sub    $0x8,%esp
  802961:	6a 01                	push   $0x1
  802963:	ff 75 f4             	pushl  -0xc(%ebp)
  802966:	e8 58 ff ff ff       	call   8028c3 <fd_close>
  80296b:	83 c4 10             	add    $0x10,%esp
}
  80296e:	c9                   	leave  
  80296f:	c3                   	ret    

00802970 <close_all>:

void
close_all(void)
{
  802970:	55                   	push   %ebp
  802971:	89 e5                	mov    %esp,%ebp
  802973:	53                   	push   %ebx
  802974:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  802977:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80297c:	83 ec 0c             	sub    $0xc,%esp
  80297f:	53                   	push   %ebx
  802980:	e8 be ff ff ff       	call   802943 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  802985:	83 c3 01             	add    $0x1,%ebx
  802988:	83 c4 10             	add    $0x10,%esp
  80298b:	83 fb 20             	cmp    $0x20,%ebx
  80298e:	75 ec                	jne    80297c <close_all+0xc>
		close(i);
}
  802990:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802993:	c9                   	leave  
  802994:	c3                   	ret    

00802995 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  802995:	55                   	push   %ebp
  802996:	89 e5                	mov    %esp,%ebp
  802998:	57                   	push   %edi
  802999:	56                   	push   %esi
  80299a:	53                   	push   %ebx
  80299b:	83 ec 2c             	sub    $0x2c,%esp
  80299e:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8029a1:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8029a4:	50                   	push   %eax
  8029a5:	ff 75 08             	pushl  0x8(%ebp)
  8029a8:	e8 6d fe ff ff       	call   80281a <fd_lookup>
  8029ad:	89 c2                	mov    %eax,%edx
  8029af:	83 c4 08             	add    $0x8,%esp
  8029b2:	85 d2                	test   %edx,%edx
  8029b4:	0f 88 c1 00 00 00    	js     802a7b <dup+0xe6>
		return r;
	close(newfdnum);
  8029ba:	83 ec 0c             	sub    $0xc,%esp
  8029bd:	56                   	push   %esi
  8029be:	e8 80 ff ff ff       	call   802943 <close>

	newfd = INDEX2FD(newfdnum);
  8029c3:	89 f3                	mov    %esi,%ebx
  8029c5:	c1 e3 0c             	shl    $0xc,%ebx
  8029c8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8029ce:	83 c4 04             	add    $0x4,%esp
  8029d1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8029d4:	e8 db fd ff ff       	call   8027b4 <fd2data>
  8029d9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8029db:	89 1c 24             	mov    %ebx,(%esp)
  8029de:	e8 d1 fd ff ff       	call   8027b4 <fd2data>
  8029e3:	83 c4 10             	add    $0x10,%esp
  8029e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8029e9:	89 f8                	mov    %edi,%eax
  8029eb:	c1 e8 16             	shr    $0x16,%eax
  8029ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8029f5:	a8 01                	test   $0x1,%al
  8029f7:	74 37                	je     802a30 <dup+0x9b>
  8029f9:	89 f8                	mov    %edi,%eax
  8029fb:	c1 e8 0c             	shr    $0xc,%eax
  8029fe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  802a05:	f6 c2 01             	test   $0x1,%dl
  802a08:	74 26                	je     802a30 <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  802a0a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a11:	83 ec 0c             	sub    $0xc,%esp
  802a14:	25 07 0e 00 00       	and    $0xe07,%eax
  802a19:	50                   	push   %eax
  802a1a:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a1d:	6a 00                	push   $0x0
  802a1f:	57                   	push   %edi
  802a20:	6a 00                	push   $0x0
  802a22:	e8 2a fa ff ff       	call   802451 <sys_page_map>
  802a27:	89 c7                	mov    %eax,%edi
  802a29:	83 c4 20             	add    $0x20,%esp
  802a2c:	85 c0                	test   %eax,%eax
  802a2e:	78 2e                	js     802a5e <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a30:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  802a33:	89 d0                	mov    %edx,%eax
  802a35:	c1 e8 0c             	shr    $0xc,%eax
  802a38:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802a3f:	83 ec 0c             	sub    $0xc,%esp
  802a42:	25 07 0e 00 00       	and    $0xe07,%eax
  802a47:	50                   	push   %eax
  802a48:	53                   	push   %ebx
  802a49:	6a 00                	push   $0x0
  802a4b:	52                   	push   %edx
  802a4c:	6a 00                	push   $0x0
  802a4e:	e8 fe f9 ff ff       	call   802451 <sys_page_map>
  802a53:	89 c7                	mov    %eax,%edi
  802a55:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  802a58:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  802a5a:	85 ff                	test   %edi,%edi
  802a5c:	79 1d                	jns    802a7b <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  802a5e:	83 ec 08             	sub    $0x8,%esp
  802a61:	53                   	push   %ebx
  802a62:	6a 00                	push   $0x0
  802a64:	e8 2a fa ff ff       	call   802493 <sys_page_unmap>
	sys_page_unmap(0, nva);
  802a69:	83 c4 08             	add    $0x8,%esp
  802a6c:	ff 75 d4             	pushl  -0x2c(%ebp)
  802a6f:	6a 00                	push   $0x0
  802a71:	e8 1d fa ff ff       	call   802493 <sys_page_unmap>
	return r;
  802a76:	83 c4 10             	add    $0x10,%esp
  802a79:	89 f8                	mov    %edi,%eax
}
  802a7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802a7e:	5b                   	pop    %ebx
  802a7f:	5e                   	pop    %esi
  802a80:	5f                   	pop    %edi
  802a81:	5d                   	pop    %ebp
  802a82:	c3                   	ret    

00802a83 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  802a83:	55                   	push   %ebp
  802a84:	89 e5                	mov    %esp,%ebp
  802a86:	53                   	push   %ebx
  802a87:	83 ec 14             	sub    $0x14,%esp
  802a8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802a8d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802a90:	50                   	push   %eax
  802a91:	53                   	push   %ebx
  802a92:	e8 83 fd ff ff       	call   80281a <fd_lookup>
  802a97:	83 c4 08             	add    $0x8,%esp
  802a9a:	89 c2                	mov    %eax,%edx
  802a9c:	85 c0                	test   %eax,%eax
  802a9e:	78 6d                	js     802b0d <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802aa0:	83 ec 08             	sub    $0x8,%esp
  802aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802aa6:	50                   	push   %eax
  802aa7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802aaa:	ff 30                	pushl  (%eax)
  802aac:	e8 bf fd ff ff       	call   802870 <dev_lookup>
  802ab1:	83 c4 10             	add    $0x10,%esp
  802ab4:	85 c0                	test   %eax,%eax
  802ab6:	78 4c                	js     802b04 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802ab8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802abb:	8b 42 08             	mov    0x8(%edx),%eax
  802abe:	83 e0 03             	and    $0x3,%eax
  802ac1:	83 f8 01             	cmp    $0x1,%eax
  802ac4:	75 21                	jne    802ae7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  802ac6:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802acb:	8b 40 48             	mov    0x48(%eax),%eax
  802ace:	83 ec 04             	sub    $0x4,%esp
  802ad1:	53                   	push   %ebx
  802ad2:	50                   	push   %eax
  802ad3:	68 61 41 80 00       	push   $0x804161
  802ad8:	e8 a3 ef ff ff       	call   801a80 <cprintf>
		return -E_INVAL;
  802add:	83 c4 10             	add    $0x10,%esp
  802ae0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802ae5:	eb 26                	jmp    802b0d <read+0x8a>
	}
	if (!dev->dev_read)
  802ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802aea:	8b 40 08             	mov    0x8(%eax),%eax
  802aed:	85 c0                	test   %eax,%eax
  802aef:	74 17                	je     802b08 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  802af1:	83 ec 04             	sub    $0x4,%esp
  802af4:	ff 75 10             	pushl  0x10(%ebp)
  802af7:	ff 75 0c             	pushl  0xc(%ebp)
  802afa:	52                   	push   %edx
  802afb:	ff d0                	call   *%eax
  802afd:	89 c2                	mov    %eax,%edx
  802aff:	83 c4 10             	add    $0x10,%esp
  802b02:	eb 09                	jmp    802b0d <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b04:	89 c2                	mov    %eax,%edx
  802b06:	eb 05                	jmp    802b0d <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  802b08:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  802b0d:	89 d0                	mov    %edx,%eax
  802b0f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802b12:	c9                   	leave  
  802b13:	c3                   	ret    

00802b14 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  802b14:	55                   	push   %ebp
  802b15:	89 e5                	mov    %esp,%ebp
  802b17:	57                   	push   %edi
  802b18:	56                   	push   %esi
  802b19:	53                   	push   %ebx
  802b1a:	83 ec 0c             	sub    $0xc,%esp
  802b1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  802b20:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b23:	bb 00 00 00 00       	mov    $0x0,%ebx
  802b28:	eb 21                	jmp    802b4b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802b2a:	83 ec 04             	sub    $0x4,%esp
  802b2d:	89 f0                	mov    %esi,%eax
  802b2f:	29 d8                	sub    %ebx,%eax
  802b31:	50                   	push   %eax
  802b32:	89 d8                	mov    %ebx,%eax
  802b34:	03 45 0c             	add    0xc(%ebp),%eax
  802b37:	50                   	push   %eax
  802b38:	57                   	push   %edi
  802b39:	e8 45 ff ff ff       	call   802a83 <read>
		if (m < 0)
  802b3e:	83 c4 10             	add    $0x10,%esp
  802b41:	85 c0                	test   %eax,%eax
  802b43:	78 0c                	js     802b51 <readn+0x3d>
			return m;
		if (m == 0)
  802b45:	85 c0                	test   %eax,%eax
  802b47:	74 06                	je     802b4f <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  802b49:	01 c3                	add    %eax,%ebx
  802b4b:	39 f3                	cmp    %esi,%ebx
  802b4d:	72 db                	jb     802b2a <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  802b4f:	89 d8                	mov    %ebx,%eax
}
  802b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802b54:	5b                   	pop    %ebx
  802b55:	5e                   	pop    %esi
  802b56:	5f                   	pop    %edi
  802b57:	5d                   	pop    %ebp
  802b58:	c3                   	ret    

00802b59 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802b59:	55                   	push   %ebp
  802b5a:	89 e5                	mov    %esp,%ebp
  802b5c:	53                   	push   %ebx
  802b5d:	83 ec 14             	sub    $0x14,%esp
  802b60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802b63:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802b66:	50                   	push   %eax
  802b67:	53                   	push   %ebx
  802b68:	e8 ad fc ff ff       	call   80281a <fd_lookup>
  802b6d:	83 c4 08             	add    $0x8,%esp
  802b70:	89 c2                	mov    %eax,%edx
  802b72:	85 c0                	test   %eax,%eax
  802b74:	78 68                	js     802bde <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802b76:	83 ec 08             	sub    $0x8,%esp
  802b79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802b7c:	50                   	push   %eax
  802b7d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b80:	ff 30                	pushl  (%eax)
  802b82:	e8 e9 fc ff ff       	call   802870 <dev_lookup>
  802b87:	83 c4 10             	add    $0x10,%esp
  802b8a:	85 c0                	test   %eax,%eax
  802b8c:	78 47                	js     802bd5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802b8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802b91:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802b95:	75 21                	jne    802bb8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  802b97:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  802b9c:	8b 40 48             	mov    0x48(%eax),%eax
  802b9f:	83 ec 04             	sub    $0x4,%esp
  802ba2:	53                   	push   %ebx
  802ba3:	50                   	push   %eax
  802ba4:	68 7d 41 80 00       	push   $0x80417d
  802ba9:	e8 d2 ee ff ff       	call   801a80 <cprintf>
		return -E_INVAL;
  802bae:	83 c4 10             	add    $0x10,%esp
  802bb1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802bb6:	eb 26                	jmp    802bde <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802bb8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802bbb:	8b 52 0c             	mov    0xc(%edx),%edx
  802bbe:	85 d2                	test   %edx,%edx
  802bc0:	74 17                	je     802bd9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  802bc2:	83 ec 04             	sub    $0x4,%esp
  802bc5:	ff 75 10             	pushl  0x10(%ebp)
  802bc8:	ff 75 0c             	pushl  0xc(%ebp)
  802bcb:	50                   	push   %eax
  802bcc:	ff d2                	call   *%edx
  802bce:	89 c2                	mov    %eax,%edx
  802bd0:	83 c4 10             	add    $0x10,%esp
  802bd3:	eb 09                	jmp    802bde <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802bd5:	89 c2                	mov    %eax,%edx
  802bd7:	eb 05                	jmp    802bde <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  802bd9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  802bde:	89 d0                	mov    %edx,%eax
  802be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802be3:	c9                   	leave  
  802be4:	c3                   	ret    

00802be5 <seek>:

int
seek(int fdnum, off_t offset)
{
  802be5:	55                   	push   %ebp
  802be6:	89 e5                	mov    %esp,%ebp
  802be8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802beb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  802bee:	50                   	push   %eax
  802bef:	ff 75 08             	pushl  0x8(%ebp)
  802bf2:	e8 23 fc ff ff       	call   80281a <fd_lookup>
  802bf7:	83 c4 08             	add    $0x8,%esp
  802bfa:	85 c0                	test   %eax,%eax
  802bfc:	78 0e                	js     802c0c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  802bfe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  802c01:	8b 55 0c             	mov    0xc(%ebp),%edx
  802c04:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  802c07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802c0c:	c9                   	leave  
  802c0d:	c3                   	ret    

00802c0e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  802c0e:	55                   	push   %ebp
  802c0f:	89 e5                	mov    %esp,%ebp
  802c11:	53                   	push   %ebx
  802c12:	83 ec 14             	sub    $0x14,%esp
  802c15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  802c18:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802c1b:	50                   	push   %eax
  802c1c:	53                   	push   %ebx
  802c1d:	e8 f8 fb ff ff       	call   80281a <fd_lookup>
  802c22:	83 c4 08             	add    $0x8,%esp
  802c25:	89 c2                	mov    %eax,%edx
  802c27:	85 c0                	test   %eax,%eax
  802c29:	78 65                	js     802c90 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c2b:	83 ec 08             	sub    $0x8,%esp
  802c2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802c31:	50                   	push   %eax
  802c32:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c35:	ff 30                	pushl  (%eax)
  802c37:	e8 34 fc ff ff       	call   802870 <dev_lookup>
  802c3c:	83 c4 10             	add    $0x10,%esp
  802c3f:	85 c0                	test   %eax,%eax
  802c41:	78 44                	js     802c87 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802c43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802c46:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802c4a:	75 21                	jne    802c6d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  802c4c:	a1 0c a0 80 00       	mov    0x80a00c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802c51:	8b 40 48             	mov    0x48(%eax),%eax
  802c54:	83 ec 04             	sub    $0x4,%esp
  802c57:	53                   	push   %ebx
  802c58:	50                   	push   %eax
  802c59:	68 40 41 80 00       	push   $0x804140
  802c5e:	e8 1d ee ff ff       	call   801a80 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  802c63:	83 c4 10             	add    $0x10,%esp
  802c66:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  802c6b:	eb 23                	jmp    802c90 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  802c6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802c70:	8b 52 18             	mov    0x18(%edx),%edx
  802c73:	85 d2                	test   %edx,%edx
  802c75:	74 14                	je     802c8b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  802c77:	83 ec 08             	sub    $0x8,%esp
  802c7a:	ff 75 0c             	pushl  0xc(%ebp)
  802c7d:	50                   	push   %eax
  802c7e:	ff d2                	call   *%edx
  802c80:	89 c2                	mov    %eax,%edx
  802c82:	83 c4 10             	add    $0x10,%esp
  802c85:	eb 09                	jmp    802c90 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802c87:	89 c2                	mov    %eax,%edx
  802c89:	eb 05                	jmp    802c90 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  802c8b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  802c90:	89 d0                	mov    %edx,%eax
  802c92:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802c95:	c9                   	leave  
  802c96:	c3                   	ret    

00802c97 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802c97:	55                   	push   %ebp
  802c98:	89 e5                	mov    %esp,%ebp
  802c9a:	53                   	push   %ebx
  802c9b:	83 ec 14             	sub    $0x14,%esp
  802c9e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802ca1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802ca4:	50                   	push   %eax
  802ca5:	ff 75 08             	pushl  0x8(%ebp)
  802ca8:	e8 6d fb ff ff       	call   80281a <fd_lookup>
  802cad:	83 c4 08             	add    $0x8,%esp
  802cb0:	89 c2                	mov    %eax,%edx
  802cb2:	85 c0                	test   %eax,%eax
  802cb4:	78 58                	js     802d0e <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802cb6:	83 ec 08             	sub    $0x8,%esp
  802cb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802cbc:	50                   	push   %eax
  802cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802cc0:	ff 30                	pushl  (%eax)
  802cc2:	e8 a9 fb ff ff       	call   802870 <dev_lookup>
  802cc7:	83 c4 10             	add    $0x10,%esp
  802cca:	85 c0                	test   %eax,%eax
  802ccc:	78 37                	js     802d05 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  802cce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802cd1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802cd5:	74 32                	je     802d09 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802cd7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  802cda:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802ce1:	00 00 00 
	stat->st_isdir = 0;
  802ce4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802ceb:	00 00 00 
	stat->st_dev = dev;
  802cee:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  802cf4:	83 ec 08             	sub    $0x8,%esp
  802cf7:	53                   	push   %ebx
  802cf8:	ff 75 f0             	pushl  -0x10(%ebp)
  802cfb:	ff 50 14             	call   *0x14(%eax)
  802cfe:	89 c2                	mov    %eax,%edx
  802d00:	83 c4 10             	add    $0x10,%esp
  802d03:	eb 09                	jmp    802d0e <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802d05:	89 c2                	mov    %eax,%edx
  802d07:	eb 05                	jmp    802d0e <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  802d09:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  802d0e:	89 d0                	mov    %edx,%eax
  802d10:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802d13:	c9                   	leave  
  802d14:	c3                   	ret    

00802d15 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  802d15:	55                   	push   %ebp
  802d16:	89 e5                	mov    %esp,%ebp
  802d18:	56                   	push   %esi
  802d19:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  802d1a:	83 ec 08             	sub    $0x8,%esp
  802d1d:	6a 00                	push   $0x0
  802d1f:	ff 75 08             	pushl  0x8(%ebp)
  802d22:	e8 e7 01 00 00       	call   802f0e <open>
  802d27:	89 c3                	mov    %eax,%ebx
  802d29:	83 c4 10             	add    $0x10,%esp
  802d2c:	85 db                	test   %ebx,%ebx
  802d2e:	78 1b                	js     802d4b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  802d30:	83 ec 08             	sub    $0x8,%esp
  802d33:	ff 75 0c             	pushl  0xc(%ebp)
  802d36:	53                   	push   %ebx
  802d37:	e8 5b ff ff ff       	call   802c97 <fstat>
  802d3c:	89 c6                	mov    %eax,%esi
	close(fd);
  802d3e:	89 1c 24             	mov    %ebx,(%esp)
  802d41:	e8 fd fb ff ff       	call   802943 <close>
	return r;
  802d46:	83 c4 10             	add    $0x10,%esp
  802d49:	89 f0                	mov    %esi,%eax
}
  802d4b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d4e:	5b                   	pop    %ebx
  802d4f:	5e                   	pop    %esi
  802d50:	5d                   	pop    %ebp
  802d51:	c3                   	ret    

00802d52 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802d52:	55                   	push   %ebp
  802d53:	89 e5                	mov    %esp,%ebp
  802d55:	56                   	push   %esi
  802d56:	53                   	push   %ebx
  802d57:	89 c6                	mov    %eax,%esi
  802d59:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  802d5b:	83 3d 00 a0 80 00 00 	cmpl   $0x0,0x80a000
  802d62:	75 12                	jne    802d76 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  802d64:	83 ec 0c             	sub    $0xc,%esp
  802d67:	6a 03                	push   $0x3
  802d69:	e8 fe f9 ff ff       	call   80276c <ipc_find_env>
  802d6e:	a3 00 a0 80 00       	mov    %eax,0x80a000
  802d73:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802d76:	6a 07                	push   $0x7
  802d78:	68 00 b0 80 00       	push   $0x80b000
  802d7d:	56                   	push   %esi
  802d7e:	ff 35 00 a0 80 00    	pushl  0x80a000
  802d84:	e8 92 f9 ff ff       	call   80271b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802d89:	83 c4 0c             	add    $0xc,%esp
  802d8c:	6a 00                	push   $0x0
  802d8e:	53                   	push   %ebx
  802d8f:	6a 00                	push   $0x0
  802d91:	e8 1f f9 ff ff       	call   8026b5 <ipc_recv>
}
  802d96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802d99:	5b                   	pop    %ebx
  802d9a:	5e                   	pop    %esi
  802d9b:	5d                   	pop    %ebp
  802d9c:	c3                   	ret    

00802d9d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  802d9d:	55                   	push   %ebp
  802d9e:	89 e5                	mov    %esp,%ebp
  802da0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802da3:	8b 45 08             	mov    0x8(%ebp),%eax
  802da6:	8b 40 0c             	mov    0xc(%eax),%eax
  802da9:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.set_size.req_size = newsize;
  802dae:	8b 45 0c             	mov    0xc(%ebp),%eax
  802db1:	a3 04 b0 80 00       	mov    %eax,0x80b004
	return fsipc(FSREQ_SET_SIZE, NULL);
  802db6:	ba 00 00 00 00       	mov    $0x0,%edx
  802dbb:	b8 02 00 00 00       	mov    $0x2,%eax
  802dc0:	e8 8d ff ff ff       	call   802d52 <fsipc>
}
  802dc5:	c9                   	leave  
  802dc6:	c3                   	ret    

00802dc7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  802dc7:	55                   	push   %ebp
  802dc8:	89 e5                	mov    %esp,%ebp
  802dca:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802dcd:	8b 45 08             	mov    0x8(%ebp),%eax
  802dd0:	8b 40 0c             	mov    0xc(%eax),%eax
  802dd3:	a3 00 b0 80 00       	mov    %eax,0x80b000
	return fsipc(FSREQ_FLUSH, NULL);
  802dd8:	ba 00 00 00 00       	mov    $0x0,%edx
  802ddd:	b8 06 00 00 00       	mov    $0x6,%eax
  802de2:	e8 6b ff ff ff       	call   802d52 <fsipc>
}
  802de7:	c9                   	leave  
  802de8:	c3                   	ret    

00802de9 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  802de9:	55                   	push   %ebp
  802dea:	89 e5                	mov    %esp,%ebp
  802dec:	53                   	push   %ebx
  802ded:	83 ec 04             	sub    $0x4,%esp
  802df0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  802df3:	8b 45 08             	mov    0x8(%ebp),%eax
  802df6:	8b 40 0c             	mov    0xc(%eax),%eax
  802df9:	a3 00 b0 80 00       	mov    %eax,0x80b000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  802dfe:	ba 00 00 00 00       	mov    $0x0,%edx
  802e03:	b8 05 00 00 00       	mov    $0x5,%eax
  802e08:	e8 45 ff ff ff       	call   802d52 <fsipc>
  802e0d:	89 c2                	mov    %eax,%edx
  802e0f:	85 d2                	test   %edx,%edx
  802e11:	78 2c                	js     802e3f <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  802e13:	83 ec 08             	sub    $0x8,%esp
  802e16:	68 00 b0 80 00       	push   $0x80b000
  802e1b:	53                   	push   %ebx
  802e1c:	e8 e3 f1 ff ff       	call   802004 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  802e21:	a1 80 b0 80 00       	mov    0x80b080,%eax
  802e26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  802e2c:	a1 84 b0 80 00       	mov    0x80b084,%eax
  802e31:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  802e37:	83 c4 10             	add    $0x10,%esp
  802e3a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802e3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e42:	c9                   	leave  
  802e43:	c3                   	ret    

00802e44 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  802e44:	55                   	push   %ebp
  802e45:	89 e5                	mov    %esp,%ebp
  802e47:	83 ec 08             	sub    $0x8,%esp
  802e4a:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  802e4d:	8b 55 08             	mov    0x8(%ebp),%edx
  802e50:	8b 52 0c             	mov    0xc(%edx),%edx
  802e53:	89 15 00 b0 80 00    	mov    %edx,0x80b000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  802e59:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  802e5e:	76 05                	jbe    802e65 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  802e60:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  802e65:	a3 04 b0 80 00       	mov    %eax,0x80b004
	memmove(req->req_buf, buf, movesize);
  802e6a:	83 ec 04             	sub    $0x4,%esp
  802e6d:	50                   	push   %eax
  802e6e:	ff 75 0c             	pushl  0xc(%ebp)
  802e71:	68 08 b0 80 00       	push   $0x80b008
  802e76:	e8 1b f3 ff ff       	call   802196 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  802e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  802e80:	b8 04 00 00 00       	mov    $0x4,%eax
  802e85:	e8 c8 fe ff ff       	call   802d52 <fsipc>
	return write;
}
  802e8a:	c9                   	leave  
  802e8b:	c3                   	ret    

00802e8c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  802e8c:	55                   	push   %ebp
  802e8d:	89 e5                	mov    %esp,%ebp
  802e8f:	56                   	push   %esi
  802e90:	53                   	push   %ebx
  802e91:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802e94:	8b 45 08             	mov    0x8(%ebp),%eax
  802e97:	8b 40 0c             	mov    0xc(%eax),%eax
  802e9a:	a3 00 b0 80 00       	mov    %eax,0x80b000
	fsipcbuf.read.req_n = n;
  802e9f:	89 35 04 b0 80 00    	mov    %esi,0x80b004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802ea5:	ba 00 00 00 00       	mov    $0x0,%edx
  802eaa:	b8 03 00 00 00       	mov    $0x3,%eax
  802eaf:	e8 9e fe ff ff       	call   802d52 <fsipc>
  802eb4:	89 c3                	mov    %eax,%ebx
  802eb6:	85 c0                	test   %eax,%eax
  802eb8:	78 4b                	js     802f05 <devfile_read+0x79>
		return r;
	assert(r <= n);
  802eba:	39 c6                	cmp    %eax,%esi
  802ebc:	73 16                	jae    802ed4 <devfile_read+0x48>
  802ebe:	68 ac 41 80 00       	push   $0x8041ac
  802ec3:	68 bd 37 80 00       	push   $0x8037bd
  802ec8:	6a 7c                	push   $0x7c
  802eca:	68 b3 41 80 00       	push   $0x8041b3
  802ecf:	e8 d3 ea ff ff       	call   8019a7 <_panic>
	assert(r <= PGSIZE);
  802ed4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802ed9:	7e 16                	jle    802ef1 <devfile_read+0x65>
  802edb:	68 be 41 80 00       	push   $0x8041be
  802ee0:	68 bd 37 80 00       	push   $0x8037bd
  802ee5:	6a 7d                	push   $0x7d
  802ee7:	68 b3 41 80 00       	push   $0x8041b3
  802eec:	e8 b6 ea ff ff       	call   8019a7 <_panic>
	memmove(buf, &fsipcbuf, r);
  802ef1:	83 ec 04             	sub    $0x4,%esp
  802ef4:	50                   	push   %eax
  802ef5:	68 00 b0 80 00       	push   $0x80b000
  802efa:	ff 75 0c             	pushl  0xc(%ebp)
  802efd:	e8 94 f2 ff ff       	call   802196 <memmove>
	return r;
  802f02:	83 c4 10             	add    $0x10,%esp
}
  802f05:	89 d8                	mov    %ebx,%eax
  802f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802f0a:	5b                   	pop    %ebx
  802f0b:	5e                   	pop    %esi
  802f0c:	5d                   	pop    %ebp
  802f0d:	c3                   	ret    

00802f0e <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  802f0e:	55                   	push   %ebp
  802f0f:	89 e5                	mov    %esp,%ebp
  802f11:	53                   	push   %ebx
  802f12:	83 ec 20             	sub    $0x20,%esp
  802f15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  802f18:	53                   	push   %ebx
  802f19:	e8 ad f0 ff ff       	call   801fcb <strlen>
  802f1e:	83 c4 10             	add    $0x10,%esp
  802f21:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  802f26:	7f 67                	jg     802f8f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f28:	83 ec 0c             	sub    $0xc,%esp
  802f2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f2e:	50                   	push   %eax
  802f2f:	e8 97 f8 ff ff       	call   8027cb <fd_alloc>
  802f34:	83 c4 10             	add    $0x10,%esp
		return r;
  802f37:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  802f39:	85 c0                	test   %eax,%eax
  802f3b:	78 57                	js     802f94 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  802f3d:	83 ec 08             	sub    $0x8,%esp
  802f40:	53                   	push   %ebx
  802f41:	68 00 b0 80 00       	push   $0x80b000
  802f46:	e8 b9 f0 ff ff       	call   802004 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802f4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  802f4e:	a3 00 b4 80 00       	mov    %eax,0x80b400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  802f53:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802f56:	b8 01 00 00 00       	mov    $0x1,%eax
  802f5b:	e8 f2 fd ff ff       	call   802d52 <fsipc>
  802f60:	89 c3                	mov    %eax,%ebx
  802f62:	83 c4 10             	add    $0x10,%esp
  802f65:	85 c0                	test   %eax,%eax
  802f67:	79 14                	jns    802f7d <open+0x6f>
		fd_close(fd, 0);
  802f69:	83 ec 08             	sub    $0x8,%esp
  802f6c:	6a 00                	push   $0x0
  802f6e:	ff 75 f4             	pushl  -0xc(%ebp)
  802f71:	e8 4d f9 ff ff       	call   8028c3 <fd_close>
		return r;
  802f76:	83 c4 10             	add    $0x10,%esp
  802f79:	89 da                	mov    %ebx,%edx
  802f7b:	eb 17                	jmp    802f94 <open+0x86>
	}

	return fd2num(fd);
  802f7d:	83 ec 0c             	sub    $0xc,%esp
  802f80:	ff 75 f4             	pushl  -0xc(%ebp)
  802f83:	e8 1c f8 ff ff       	call   8027a4 <fd2num>
  802f88:	89 c2                	mov    %eax,%edx
  802f8a:	83 c4 10             	add    $0x10,%esp
  802f8d:	eb 05                	jmp    802f94 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  802f8f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  802f94:	89 d0                	mov    %edx,%eax
  802f96:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802f99:	c9                   	leave  
  802f9a:	c3                   	ret    

00802f9b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802f9b:	55                   	push   %ebp
  802f9c:	89 e5                	mov    %esp,%ebp
  802f9e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  802fa1:	ba 00 00 00 00       	mov    $0x0,%edx
  802fa6:	b8 08 00 00 00       	mov    $0x8,%eax
  802fab:	e8 a2 fd ff ff       	call   802d52 <fsipc>
}
  802fb0:	c9                   	leave  
  802fb1:	c3                   	ret    

00802fb2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802fb2:	55                   	push   %ebp
  802fb3:	89 e5                	mov    %esp,%ebp
  802fb5:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fb8:	89 d0                	mov    %edx,%eax
  802fba:	c1 e8 16             	shr    $0x16,%eax
  802fbd:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802fc4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802fc9:	f6 c1 01             	test   $0x1,%cl
  802fcc:	74 1d                	je     802feb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802fce:	c1 ea 0c             	shr    $0xc,%edx
  802fd1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802fd8:	f6 c2 01             	test   $0x1,%dl
  802fdb:	74 0e                	je     802feb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802fdd:	c1 ea 0c             	shr    $0xc,%edx
  802fe0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802fe7:	ef 
  802fe8:	0f b7 c0             	movzwl %ax,%eax
}
  802feb:	5d                   	pop    %ebp
  802fec:	c3                   	ret    

00802fed <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802fed:	55                   	push   %ebp
  802fee:	89 e5                	mov    %esp,%ebp
  802ff0:	56                   	push   %esi
  802ff1:	53                   	push   %ebx
  802ff2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802ff5:	83 ec 0c             	sub    $0xc,%esp
  802ff8:	ff 75 08             	pushl  0x8(%ebp)
  802ffb:	e8 b4 f7 ff ff       	call   8027b4 <fd2data>
  803000:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  803002:	83 c4 08             	add    $0x8,%esp
  803005:	68 ca 41 80 00       	push   $0x8041ca
  80300a:	53                   	push   %ebx
  80300b:	e8 f4 ef ff ff       	call   802004 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  803010:	8b 56 04             	mov    0x4(%esi),%edx
  803013:	89 d0                	mov    %edx,%eax
  803015:	2b 06                	sub    (%esi),%eax
  803017:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80301d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  803024:	00 00 00 
	stat->st_dev = &devpipe;
  803027:	c7 83 88 00 00 00 a0 	movl   $0x8090a0,0x88(%ebx)
  80302e:	90 80 00 
	return 0;
}
  803031:	b8 00 00 00 00       	mov    $0x0,%eax
  803036:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803039:	5b                   	pop    %ebx
  80303a:	5e                   	pop    %esi
  80303b:	5d                   	pop    %ebp
  80303c:	c3                   	ret    

0080303d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80303d:	55                   	push   %ebp
  80303e:	89 e5                	mov    %esp,%ebp
  803040:	53                   	push   %ebx
  803041:	83 ec 0c             	sub    $0xc,%esp
  803044:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  803047:	53                   	push   %ebx
  803048:	6a 00                	push   $0x0
  80304a:	e8 44 f4 ff ff       	call   802493 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80304f:	89 1c 24             	mov    %ebx,(%esp)
  803052:	e8 5d f7 ff ff       	call   8027b4 <fd2data>
  803057:	83 c4 08             	add    $0x8,%esp
  80305a:	50                   	push   %eax
  80305b:	6a 00                	push   $0x0
  80305d:	e8 31 f4 ff ff       	call   802493 <sys_page_unmap>
}
  803062:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  803065:	c9                   	leave  
  803066:	c3                   	ret    

00803067 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  803067:	55                   	push   %ebp
  803068:	89 e5                	mov    %esp,%ebp
  80306a:	57                   	push   %edi
  80306b:	56                   	push   %esi
  80306c:	53                   	push   %ebx
  80306d:	83 ec 1c             	sub    $0x1c,%esp
  803070:	89 c7                	mov    %eax,%edi
  803072:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  803074:	a1 0c a0 80 00       	mov    0x80a00c,%eax
  803079:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80307c:	83 ec 0c             	sub    $0xc,%esp
  80307f:	57                   	push   %edi
  803080:	e8 2d ff ff ff       	call   802fb2 <pageref>
  803085:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  803088:	89 34 24             	mov    %esi,(%esp)
  80308b:	e8 22 ff ff ff       	call   802fb2 <pageref>
  803090:	83 c4 10             	add    $0x10,%esp
  803093:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  803096:	0f 94 c0             	sete   %al
  803099:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  80309c:	8b 15 0c a0 80 00    	mov    0x80a00c,%edx
  8030a2:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8030a5:	39 cb                	cmp    %ecx,%ebx
  8030a7:	74 15                	je     8030be <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8030a9:	8b 52 58             	mov    0x58(%edx),%edx
  8030ac:	50                   	push   %eax
  8030ad:	52                   	push   %edx
  8030ae:	53                   	push   %ebx
  8030af:	68 d8 41 80 00       	push   $0x8041d8
  8030b4:	e8 c7 e9 ff ff       	call   801a80 <cprintf>
  8030b9:	83 c4 10             	add    $0x10,%esp
  8030bc:	eb b6                	jmp    803074 <_pipeisclosed+0xd>
	}
}
  8030be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8030c1:	5b                   	pop    %ebx
  8030c2:	5e                   	pop    %esi
  8030c3:	5f                   	pop    %edi
  8030c4:	5d                   	pop    %ebp
  8030c5:	c3                   	ret    

008030c6 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8030c6:	55                   	push   %ebp
  8030c7:	89 e5                	mov    %esp,%ebp
  8030c9:	57                   	push   %edi
  8030ca:	56                   	push   %esi
  8030cb:	53                   	push   %ebx
  8030cc:	83 ec 28             	sub    $0x28,%esp
  8030cf:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8030d2:	56                   	push   %esi
  8030d3:	e8 dc f6 ff ff       	call   8027b4 <fd2data>
  8030d8:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8030da:	83 c4 10             	add    $0x10,%esp
  8030dd:	bf 00 00 00 00       	mov    $0x0,%edi
  8030e2:	eb 4b                	jmp    80312f <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8030e4:	89 da                	mov    %ebx,%edx
  8030e6:	89 f0                	mov    %esi,%eax
  8030e8:	e8 7a ff ff ff       	call   803067 <_pipeisclosed>
  8030ed:	85 c0                	test   %eax,%eax
  8030ef:	75 48                	jne    803139 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  8030f1:	e8 f9 f2 ff ff       	call   8023ef <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8030f6:	8b 43 04             	mov    0x4(%ebx),%eax
  8030f9:	8b 0b                	mov    (%ebx),%ecx
  8030fb:	8d 51 20             	lea    0x20(%ecx),%edx
  8030fe:	39 d0                	cmp    %edx,%eax
  803100:	73 e2                	jae    8030e4 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  803102:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803105:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  803109:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80310c:	89 c2                	mov    %eax,%edx
  80310e:	c1 fa 1f             	sar    $0x1f,%edx
  803111:	89 d1                	mov    %edx,%ecx
  803113:	c1 e9 1b             	shr    $0x1b,%ecx
  803116:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  803119:	83 e2 1f             	and    $0x1f,%edx
  80311c:	29 ca                	sub    %ecx,%edx
  80311e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  803122:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  803126:	83 c0 01             	add    $0x1,%eax
  803129:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80312c:	83 c7 01             	add    $0x1,%edi
  80312f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  803132:	75 c2                	jne    8030f6 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  803134:	8b 45 10             	mov    0x10(%ebp),%eax
  803137:	eb 05                	jmp    80313e <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  803139:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80313e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  803141:	5b                   	pop    %ebx
  803142:	5e                   	pop    %esi
  803143:	5f                   	pop    %edi
  803144:	5d                   	pop    %ebp
  803145:	c3                   	ret    

00803146 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  803146:	55                   	push   %ebp
  803147:	89 e5                	mov    %esp,%ebp
  803149:	57                   	push   %edi
  80314a:	56                   	push   %esi
  80314b:	53                   	push   %ebx
  80314c:	83 ec 18             	sub    $0x18,%esp
  80314f:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  803152:	57                   	push   %edi
  803153:	e8 5c f6 ff ff       	call   8027b4 <fd2data>
  803158:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80315a:	83 c4 10             	add    $0x10,%esp
  80315d:	bb 00 00 00 00       	mov    $0x0,%ebx
  803162:	eb 3d                	jmp    8031a1 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  803164:	85 db                	test   %ebx,%ebx
  803166:	74 04                	je     80316c <devpipe_read+0x26>
				return i;
  803168:	89 d8                	mov    %ebx,%eax
  80316a:	eb 44                	jmp    8031b0 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80316c:	89 f2                	mov    %esi,%edx
  80316e:	89 f8                	mov    %edi,%eax
  803170:	e8 f2 fe ff ff       	call   803067 <_pipeisclosed>
  803175:	85 c0                	test   %eax,%eax
  803177:	75 32                	jne    8031ab <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  803179:	e8 71 f2 ff ff       	call   8023ef <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80317e:	8b 06                	mov    (%esi),%eax
  803180:	3b 46 04             	cmp    0x4(%esi),%eax
  803183:	74 df                	je     803164 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  803185:	99                   	cltd   
  803186:	c1 ea 1b             	shr    $0x1b,%edx
  803189:	01 d0                	add    %edx,%eax
  80318b:	83 e0 1f             	and    $0x1f,%eax
  80318e:	29 d0                	sub    %edx,%eax
  803190:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  803195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  803198:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80319b:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80319e:	83 c3 01             	add    $0x1,%ebx
  8031a1:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8031a4:	75 d8                	jne    80317e <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8031a6:	8b 45 10             	mov    0x10(%ebp),%eax
  8031a9:	eb 05                	jmp    8031b0 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8031ab:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8031b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8031b3:	5b                   	pop    %ebx
  8031b4:	5e                   	pop    %esi
  8031b5:	5f                   	pop    %edi
  8031b6:	5d                   	pop    %ebp
  8031b7:	c3                   	ret    

008031b8 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8031b8:	55                   	push   %ebp
  8031b9:	89 e5                	mov    %esp,%ebp
  8031bb:	56                   	push   %esi
  8031bc:	53                   	push   %ebx
  8031bd:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8031c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8031c3:	50                   	push   %eax
  8031c4:	e8 02 f6 ff ff       	call   8027cb <fd_alloc>
  8031c9:	83 c4 10             	add    $0x10,%esp
  8031cc:	89 c2                	mov    %eax,%edx
  8031ce:	85 c0                	test   %eax,%eax
  8031d0:	0f 88 2c 01 00 00    	js     803302 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8031d6:	83 ec 04             	sub    $0x4,%esp
  8031d9:	68 07 04 00 00       	push   $0x407
  8031de:	ff 75 f4             	pushl  -0xc(%ebp)
  8031e1:	6a 00                	push   $0x0
  8031e3:	e8 26 f2 ff ff       	call   80240e <sys_page_alloc>
  8031e8:	83 c4 10             	add    $0x10,%esp
  8031eb:	89 c2                	mov    %eax,%edx
  8031ed:	85 c0                	test   %eax,%eax
  8031ef:	0f 88 0d 01 00 00    	js     803302 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  8031f5:	83 ec 0c             	sub    $0xc,%esp
  8031f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8031fb:	50                   	push   %eax
  8031fc:	e8 ca f5 ff ff       	call   8027cb <fd_alloc>
  803201:	89 c3                	mov    %eax,%ebx
  803203:	83 c4 10             	add    $0x10,%esp
  803206:	85 c0                	test   %eax,%eax
  803208:	0f 88 e2 00 00 00    	js     8032f0 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80320e:	83 ec 04             	sub    $0x4,%esp
  803211:	68 07 04 00 00       	push   $0x407
  803216:	ff 75 f0             	pushl  -0x10(%ebp)
  803219:	6a 00                	push   $0x0
  80321b:	e8 ee f1 ff ff       	call   80240e <sys_page_alloc>
  803220:	89 c3                	mov    %eax,%ebx
  803222:	83 c4 10             	add    $0x10,%esp
  803225:	85 c0                	test   %eax,%eax
  803227:	0f 88 c3 00 00 00    	js     8032f0 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80322d:	83 ec 0c             	sub    $0xc,%esp
  803230:	ff 75 f4             	pushl  -0xc(%ebp)
  803233:	e8 7c f5 ff ff       	call   8027b4 <fd2data>
  803238:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80323a:	83 c4 0c             	add    $0xc,%esp
  80323d:	68 07 04 00 00       	push   $0x407
  803242:	50                   	push   %eax
  803243:	6a 00                	push   $0x0
  803245:	e8 c4 f1 ff ff       	call   80240e <sys_page_alloc>
  80324a:	89 c3                	mov    %eax,%ebx
  80324c:	83 c4 10             	add    $0x10,%esp
  80324f:	85 c0                	test   %eax,%eax
  803251:	0f 88 89 00 00 00    	js     8032e0 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803257:	83 ec 0c             	sub    $0xc,%esp
  80325a:	ff 75 f0             	pushl  -0x10(%ebp)
  80325d:	e8 52 f5 ff ff       	call   8027b4 <fd2data>
  803262:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  803269:	50                   	push   %eax
  80326a:	6a 00                	push   $0x0
  80326c:	56                   	push   %esi
  80326d:	6a 00                	push   $0x0
  80326f:	e8 dd f1 ff ff       	call   802451 <sys_page_map>
  803274:	89 c3                	mov    %eax,%ebx
  803276:	83 c4 20             	add    $0x20,%esp
  803279:	85 c0                	test   %eax,%eax
  80327b:	78 55                	js     8032d2 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80327d:	8b 15 a0 90 80 00    	mov    0x8090a0,%edx
  803283:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803286:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  803288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80328b:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  803292:	8b 15 a0 90 80 00    	mov    0x8090a0,%edx
  803298:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80329b:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80329d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8032a0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8032a7:	83 ec 0c             	sub    $0xc,%esp
  8032aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8032ad:	e8 f2 f4 ff ff       	call   8027a4 <fd2num>
  8032b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032b5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8032b7:	83 c4 04             	add    $0x4,%esp
  8032ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8032bd:	e8 e2 f4 ff ff       	call   8027a4 <fd2num>
  8032c2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8032c5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8032c8:	83 c4 10             	add    $0x10,%esp
  8032cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8032d0:	eb 30                	jmp    803302 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8032d2:	83 ec 08             	sub    $0x8,%esp
  8032d5:	56                   	push   %esi
  8032d6:	6a 00                	push   $0x0
  8032d8:	e8 b6 f1 ff ff       	call   802493 <sys_page_unmap>
  8032dd:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8032e0:	83 ec 08             	sub    $0x8,%esp
  8032e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8032e6:	6a 00                	push   $0x0
  8032e8:	e8 a6 f1 ff ff       	call   802493 <sys_page_unmap>
  8032ed:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8032f0:	83 ec 08             	sub    $0x8,%esp
  8032f3:	ff 75 f4             	pushl  -0xc(%ebp)
  8032f6:	6a 00                	push   $0x0
  8032f8:	e8 96 f1 ff ff       	call   802493 <sys_page_unmap>
  8032fd:	83 c4 10             	add    $0x10,%esp
  803300:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  803302:	89 d0                	mov    %edx,%eax
  803304:	8d 65 f8             	lea    -0x8(%ebp),%esp
  803307:	5b                   	pop    %ebx
  803308:	5e                   	pop    %esi
  803309:	5d                   	pop    %ebp
  80330a:	c3                   	ret    

0080330b <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80330b:	55                   	push   %ebp
  80330c:	89 e5                	mov    %esp,%ebp
  80330e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803314:	50                   	push   %eax
  803315:	ff 75 08             	pushl  0x8(%ebp)
  803318:	e8 fd f4 ff ff       	call   80281a <fd_lookup>
  80331d:	89 c2                	mov    %eax,%edx
  80331f:	83 c4 10             	add    $0x10,%esp
  803322:	85 d2                	test   %edx,%edx
  803324:	78 18                	js     80333e <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  803326:	83 ec 0c             	sub    $0xc,%esp
  803329:	ff 75 f4             	pushl  -0xc(%ebp)
  80332c:	e8 83 f4 ff ff       	call   8027b4 <fd2data>
	return _pipeisclosed(fd, p);
  803331:	89 c2                	mov    %eax,%edx
  803333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803336:	e8 2c fd ff ff       	call   803067 <_pipeisclosed>
  80333b:	83 c4 10             	add    $0x10,%esp
}
  80333e:	c9                   	leave  
  80333f:	c3                   	ret    

00803340 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  803340:	55                   	push   %ebp
  803341:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  803343:	b8 00 00 00 00       	mov    $0x0,%eax
  803348:	5d                   	pop    %ebp
  803349:	c3                   	ret    

0080334a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80334a:	55                   	push   %ebp
  80334b:	89 e5                	mov    %esp,%ebp
  80334d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  803350:	68 0c 42 80 00       	push   $0x80420c
  803355:	ff 75 0c             	pushl  0xc(%ebp)
  803358:	e8 a7 ec ff ff       	call   802004 <strcpy>
	return 0;
}
  80335d:	b8 00 00 00 00       	mov    $0x0,%eax
  803362:	c9                   	leave  
  803363:	c3                   	ret    

00803364 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  803364:	55                   	push   %ebp
  803365:	89 e5                	mov    %esp,%ebp
  803367:	57                   	push   %edi
  803368:	56                   	push   %esi
  803369:	53                   	push   %ebx
  80336a:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  803370:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  803375:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80337b:	eb 2e                	jmp    8033ab <devcons_write+0x47>
		m = n - tot;
  80337d:	8b 55 10             	mov    0x10(%ebp),%edx
  803380:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  803382:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  803387:	83 fa 7f             	cmp    $0x7f,%edx
  80338a:	77 02                	ja     80338e <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80338c:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80338e:	83 ec 04             	sub    $0x4,%esp
  803391:	56                   	push   %esi
  803392:	03 45 0c             	add    0xc(%ebp),%eax
  803395:	50                   	push   %eax
  803396:	57                   	push   %edi
  803397:	e8 fa ed ff ff       	call   802196 <memmove>
		sys_cputs(buf, m);
  80339c:	83 c4 08             	add    $0x8,%esp
  80339f:	56                   	push   %esi
  8033a0:	57                   	push   %edi
  8033a1:	e8 ac ef ff ff       	call   802352 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8033a6:	01 f3                	add    %esi,%ebx
  8033a8:	83 c4 10             	add    $0x10,%esp
  8033ab:	89 d8                	mov    %ebx,%eax
  8033ad:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8033b0:	72 cb                	jb     80337d <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8033b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8033b5:	5b                   	pop    %ebx
  8033b6:	5e                   	pop    %esi
  8033b7:	5f                   	pop    %edi
  8033b8:	5d                   	pop    %ebp
  8033b9:	c3                   	ret    

008033ba <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8033ba:	55                   	push   %ebp
  8033bb:	89 e5                	mov    %esp,%ebp
  8033bd:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  8033c0:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  8033c5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8033c9:	75 07                	jne    8033d2 <devcons_read+0x18>
  8033cb:	eb 28                	jmp    8033f5 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8033cd:	e8 1d f0 ff ff       	call   8023ef <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8033d2:	e8 99 ef ff ff       	call   802370 <sys_cgetc>
  8033d7:	85 c0                	test   %eax,%eax
  8033d9:	74 f2                	je     8033cd <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8033db:	85 c0                	test   %eax,%eax
  8033dd:	78 16                	js     8033f5 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8033df:	83 f8 04             	cmp    $0x4,%eax
  8033e2:	74 0c                	je     8033f0 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8033e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8033e7:	88 02                	mov    %al,(%edx)
	return 1;
  8033e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8033ee:	eb 05                	jmp    8033f5 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8033f0:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8033f5:	c9                   	leave  
  8033f6:	c3                   	ret    

008033f7 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  8033f7:	55                   	push   %ebp
  8033f8:	89 e5                	mov    %esp,%ebp
  8033fa:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8033fd:	8b 45 08             	mov    0x8(%ebp),%eax
  803400:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  803403:	6a 01                	push   $0x1
  803405:	8d 45 f7             	lea    -0x9(%ebp),%eax
  803408:	50                   	push   %eax
  803409:	e8 44 ef ff ff       	call   802352 <sys_cputs>
  80340e:	83 c4 10             	add    $0x10,%esp
}
  803411:	c9                   	leave  
  803412:	c3                   	ret    

00803413 <getchar>:

int
getchar(void)
{
  803413:	55                   	push   %ebp
  803414:	89 e5                	mov    %esp,%ebp
  803416:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  803419:	6a 01                	push   $0x1
  80341b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80341e:	50                   	push   %eax
  80341f:	6a 00                	push   $0x0
  803421:	e8 5d f6 ff ff       	call   802a83 <read>
	if (r < 0)
  803426:	83 c4 10             	add    $0x10,%esp
  803429:	85 c0                	test   %eax,%eax
  80342b:	78 0f                	js     80343c <getchar+0x29>
		return r;
	if (r < 1)
  80342d:	85 c0                	test   %eax,%eax
  80342f:	7e 06                	jle    803437 <getchar+0x24>
		return -E_EOF;
	return c;
  803431:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  803435:	eb 05                	jmp    80343c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  803437:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80343c:	c9                   	leave  
  80343d:	c3                   	ret    

0080343e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80343e:	55                   	push   %ebp
  80343f:	89 e5                	mov    %esp,%ebp
  803441:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  803444:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803447:	50                   	push   %eax
  803448:	ff 75 08             	pushl  0x8(%ebp)
  80344b:	e8 ca f3 ff ff       	call   80281a <fd_lookup>
  803450:	83 c4 10             	add    $0x10,%esp
  803453:	85 c0                	test   %eax,%eax
  803455:	78 11                	js     803468 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  803457:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80345a:	8b 15 bc 90 80 00    	mov    0x8090bc,%edx
  803460:	39 10                	cmp    %edx,(%eax)
  803462:	0f 94 c0             	sete   %al
  803465:	0f b6 c0             	movzbl %al,%eax
}
  803468:	c9                   	leave  
  803469:	c3                   	ret    

0080346a <opencons>:

int
opencons(void)
{
  80346a:	55                   	push   %ebp
  80346b:	89 e5                	mov    %esp,%ebp
  80346d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  803470:	8d 45 f4             	lea    -0xc(%ebp),%eax
  803473:	50                   	push   %eax
  803474:	e8 52 f3 ff ff       	call   8027cb <fd_alloc>
  803479:	83 c4 10             	add    $0x10,%esp
		return r;
  80347c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80347e:	85 c0                	test   %eax,%eax
  803480:	78 3e                	js     8034c0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803482:	83 ec 04             	sub    $0x4,%esp
  803485:	68 07 04 00 00       	push   $0x407
  80348a:	ff 75 f4             	pushl  -0xc(%ebp)
  80348d:	6a 00                	push   $0x0
  80348f:	e8 7a ef ff ff       	call   80240e <sys_page_alloc>
  803494:	83 c4 10             	add    $0x10,%esp
		return r;
  803497:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  803499:	85 c0                	test   %eax,%eax
  80349b:	78 23                	js     8034c0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80349d:	8b 15 bc 90 80 00    	mov    0x8090bc,%edx
  8034a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8034a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8034ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8034b2:	83 ec 0c             	sub    $0xc,%esp
  8034b5:	50                   	push   %eax
  8034b6:	e8 e9 f2 ff ff       	call   8027a4 <fd2num>
  8034bb:	89 c2                	mov    %eax,%edx
  8034bd:	83 c4 10             	add    $0x10,%esp
}
  8034c0:	89 d0                	mov    %edx,%eax
  8034c2:	c9                   	leave  
  8034c3:	c3                   	ret    
  8034c4:	66 90                	xchg   %ax,%ax
  8034c6:	66 90                	xchg   %ax,%ax
  8034c8:	66 90                	xchg   %ax,%ax
  8034ca:	66 90                	xchg   %ax,%ax
  8034cc:	66 90                	xchg   %ax,%ax
  8034ce:	66 90                	xchg   %ax,%ax

008034d0 <__udivdi3>:
  8034d0:	55                   	push   %ebp
  8034d1:	57                   	push   %edi
  8034d2:	56                   	push   %esi
  8034d3:	83 ec 10             	sub    $0x10,%esp
  8034d6:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  8034da:	8b 7c 24 20          	mov    0x20(%esp),%edi
  8034de:	8b 74 24 24          	mov    0x24(%esp),%esi
  8034e2:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  8034e6:	85 d2                	test   %edx,%edx
  8034e8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8034ec:	89 34 24             	mov    %esi,(%esp)
  8034ef:	89 c8                	mov    %ecx,%eax
  8034f1:	75 35                	jne    803528 <__udivdi3+0x58>
  8034f3:	39 f1                	cmp    %esi,%ecx
  8034f5:	0f 87 bd 00 00 00    	ja     8035b8 <__udivdi3+0xe8>
  8034fb:	85 c9                	test   %ecx,%ecx
  8034fd:	89 cd                	mov    %ecx,%ebp
  8034ff:	75 0b                	jne    80350c <__udivdi3+0x3c>
  803501:	b8 01 00 00 00       	mov    $0x1,%eax
  803506:	31 d2                	xor    %edx,%edx
  803508:	f7 f1                	div    %ecx
  80350a:	89 c5                	mov    %eax,%ebp
  80350c:	89 f0                	mov    %esi,%eax
  80350e:	31 d2                	xor    %edx,%edx
  803510:	f7 f5                	div    %ebp
  803512:	89 c6                	mov    %eax,%esi
  803514:	89 f8                	mov    %edi,%eax
  803516:	f7 f5                	div    %ebp
  803518:	89 f2                	mov    %esi,%edx
  80351a:	83 c4 10             	add    $0x10,%esp
  80351d:	5e                   	pop    %esi
  80351e:	5f                   	pop    %edi
  80351f:	5d                   	pop    %ebp
  803520:	c3                   	ret    
  803521:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  803528:	3b 14 24             	cmp    (%esp),%edx
  80352b:	77 7b                	ja     8035a8 <__udivdi3+0xd8>
  80352d:	0f bd f2             	bsr    %edx,%esi
  803530:	83 f6 1f             	xor    $0x1f,%esi
  803533:	0f 84 97 00 00 00    	je     8035d0 <__udivdi3+0x100>
  803539:	bd 20 00 00 00       	mov    $0x20,%ebp
  80353e:	89 d7                	mov    %edx,%edi
  803540:	89 f1                	mov    %esi,%ecx
  803542:	29 f5                	sub    %esi,%ebp
  803544:	d3 e7                	shl    %cl,%edi
  803546:	89 c2                	mov    %eax,%edx
  803548:	89 e9                	mov    %ebp,%ecx
  80354a:	d3 ea                	shr    %cl,%edx
  80354c:	89 f1                	mov    %esi,%ecx
  80354e:	09 fa                	or     %edi,%edx
  803550:	8b 3c 24             	mov    (%esp),%edi
  803553:	d3 e0                	shl    %cl,%eax
  803555:	89 54 24 08          	mov    %edx,0x8(%esp)
  803559:	89 e9                	mov    %ebp,%ecx
  80355b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80355f:	8b 44 24 04          	mov    0x4(%esp),%eax
  803563:	89 fa                	mov    %edi,%edx
  803565:	d3 ea                	shr    %cl,%edx
  803567:	89 f1                	mov    %esi,%ecx
  803569:	d3 e7                	shl    %cl,%edi
  80356b:	89 e9                	mov    %ebp,%ecx
  80356d:	d3 e8                	shr    %cl,%eax
  80356f:	09 c7                	or     %eax,%edi
  803571:	89 f8                	mov    %edi,%eax
  803573:	f7 74 24 08          	divl   0x8(%esp)
  803577:	89 d5                	mov    %edx,%ebp
  803579:	89 c7                	mov    %eax,%edi
  80357b:	f7 64 24 0c          	mull   0xc(%esp)
  80357f:	39 d5                	cmp    %edx,%ebp
  803581:	89 14 24             	mov    %edx,(%esp)
  803584:	72 11                	jb     803597 <__udivdi3+0xc7>
  803586:	8b 54 24 04          	mov    0x4(%esp),%edx
  80358a:	89 f1                	mov    %esi,%ecx
  80358c:	d3 e2                	shl    %cl,%edx
  80358e:	39 c2                	cmp    %eax,%edx
  803590:	73 5e                	jae    8035f0 <__udivdi3+0x120>
  803592:	3b 2c 24             	cmp    (%esp),%ebp
  803595:	75 59                	jne    8035f0 <__udivdi3+0x120>
  803597:	8d 47 ff             	lea    -0x1(%edi),%eax
  80359a:	31 f6                	xor    %esi,%esi
  80359c:	89 f2                	mov    %esi,%edx
  80359e:	83 c4 10             	add    $0x10,%esp
  8035a1:	5e                   	pop    %esi
  8035a2:	5f                   	pop    %edi
  8035a3:	5d                   	pop    %ebp
  8035a4:	c3                   	ret    
  8035a5:	8d 76 00             	lea    0x0(%esi),%esi
  8035a8:	31 f6                	xor    %esi,%esi
  8035aa:	31 c0                	xor    %eax,%eax
  8035ac:	89 f2                	mov    %esi,%edx
  8035ae:	83 c4 10             	add    $0x10,%esp
  8035b1:	5e                   	pop    %esi
  8035b2:	5f                   	pop    %edi
  8035b3:	5d                   	pop    %ebp
  8035b4:	c3                   	ret    
  8035b5:	8d 76 00             	lea    0x0(%esi),%esi
  8035b8:	89 f2                	mov    %esi,%edx
  8035ba:	31 f6                	xor    %esi,%esi
  8035bc:	89 f8                	mov    %edi,%eax
  8035be:	f7 f1                	div    %ecx
  8035c0:	89 f2                	mov    %esi,%edx
  8035c2:	83 c4 10             	add    $0x10,%esp
  8035c5:	5e                   	pop    %esi
  8035c6:	5f                   	pop    %edi
  8035c7:	5d                   	pop    %ebp
  8035c8:	c3                   	ret    
  8035c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8035d0:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  8035d4:	76 0b                	jbe    8035e1 <__udivdi3+0x111>
  8035d6:	31 c0                	xor    %eax,%eax
  8035d8:	3b 14 24             	cmp    (%esp),%edx
  8035db:	0f 83 37 ff ff ff    	jae    803518 <__udivdi3+0x48>
  8035e1:	b8 01 00 00 00       	mov    $0x1,%eax
  8035e6:	e9 2d ff ff ff       	jmp    803518 <__udivdi3+0x48>
  8035eb:	90                   	nop
  8035ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8035f0:	89 f8                	mov    %edi,%eax
  8035f2:	31 f6                	xor    %esi,%esi
  8035f4:	e9 1f ff ff ff       	jmp    803518 <__udivdi3+0x48>
  8035f9:	66 90                	xchg   %ax,%ax
  8035fb:	66 90                	xchg   %ax,%ax
  8035fd:	66 90                	xchg   %ax,%ax
  8035ff:	90                   	nop

00803600 <__umoddi3>:
  803600:	55                   	push   %ebp
  803601:	57                   	push   %edi
  803602:	56                   	push   %esi
  803603:	83 ec 20             	sub    $0x20,%esp
  803606:	8b 44 24 34          	mov    0x34(%esp),%eax
  80360a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80360e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  803612:	89 c6                	mov    %eax,%esi
  803614:	89 44 24 10          	mov    %eax,0x10(%esp)
  803618:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80361c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  803620:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  803624:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  803628:	89 74 24 18          	mov    %esi,0x18(%esp)
  80362c:	85 c0                	test   %eax,%eax
  80362e:	89 c2                	mov    %eax,%edx
  803630:	75 1e                	jne    803650 <__umoddi3+0x50>
  803632:	39 f7                	cmp    %esi,%edi
  803634:	76 52                	jbe    803688 <__umoddi3+0x88>
  803636:	89 c8                	mov    %ecx,%eax
  803638:	89 f2                	mov    %esi,%edx
  80363a:	f7 f7                	div    %edi
  80363c:	89 d0                	mov    %edx,%eax
  80363e:	31 d2                	xor    %edx,%edx
  803640:	83 c4 20             	add    $0x20,%esp
  803643:	5e                   	pop    %esi
  803644:	5f                   	pop    %edi
  803645:	5d                   	pop    %ebp
  803646:	c3                   	ret    
  803647:	89 f6                	mov    %esi,%esi
  803649:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  803650:	39 f0                	cmp    %esi,%eax
  803652:	77 5c                	ja     8036b0 <__umoddi3+0xb0>
  803654:	0f bd e8             	bsr    %eax,%ebp
  803657:	83 f5 1f             	xor    $0x1f,%ebp
  80365a:	75 64                	jne    8036c0 <__umoddi3+0xc0>
  80365c:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  803660:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  803664:	0f 86 f6 00 00 00    	jbe    803760 <__umoddi3+0x160>
  80366a:	3b 44 24 18          	cmp    0x18(%esp),%eax
  80366e:	0f 82 ec 00 00 00    	jb     803760 <__umoddi3+0x160>
  803674:	8b 44 24 14          	mov    0x14(%esp),%eax
  803678:	8b 54 24 18          	mov    0x18(%esp),%edx
  80367c:	83 c4 20             	add    $0x20,%esp
  80367f:	5e                   	pop    %esi
  803680:	5f                   	pop    %edi
  803681:	5d                   	pop    %ebp
  803682:	c3                   	ret    
  803683:	90                   	nop
  803684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  803688:	85 ff                	test   %edi,%edi
  80368a:	89 fd                	mov    %edi,%ebp
  80368c:	75 0b                	jne    803699 <__umoddi3+0x99>
  80368e:	b8 01 00 00 00       	mov    $0x1,%eax
  803693:	31 d2                	xor    %edx,%edx
  803695:	f7 f7                	div    %edi
  803697:	89 c5                	mov    %eax,%ebp
  803699:	8b 44 24 10          	mov    0x10(%esp),%eax
  80369d:	31 d2                	xor    %edx,%edx
  80369f:	f7 f5                	div    %ebp
  8036a1:	89 c8                	mov    %ecx,%eax
  8036a3:	f7 f5                	div    %ebp
  8036a5:	eb 95                	jmp    80363c <__umoddi3+0x3c>
  8036a7:	89 f6                	mov    %esi,%esi
  8036a9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  8036b0:	89 c8                	mov    %ecx,%eax
  8036b2:	89 f2                	mov    %esi,%edx
  8036b4:	83 c4 20             	add    $0x20,%esp
  8036b7:	5e                   	pop    %esi
  8036b8:	5f                   	pop    %edi
  8036b9:	5d                   	pop    %ebp
  8036ba:	c3                   	ret    
  8036bb:	90                   	nop
  8036bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8036c0:	b8 20 00 00 00       	mov    $0x20,%eax
  8036c5:	89 e9                	mov    %ebp,%ecx
  8036c7:	29 e8                	sub    %ebp,%eax
  8036c9:	d3 e2                	shl    %cl,%edx
  8036cb:	89 c7                	mov    %eax,%edi
  8036cd:	89 44 24 18          	mov    %eax,0x18(%esp)
  8036d1:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8036d5:	89 f9                	mov    %edi,%ecx
  8036d7:	d3 e8                	shr    %cl,%eax
  8036d9:	89 c1                	mov    %eax,%ecx
  8036db:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8036df:	09 d1                	or     %edx,%ecx
  8036e1:	89 fa                	mov    %edi,%edx
  8036e3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8036e7:	89 e9                	mov    %ebp,%ecx
  8036e9:	d3 e0                	shl    %cl,%eax
  8036eb:	89 f9                	mov    %edi,%ecx
  8036ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8036f1:	89 f0                	mov    %esi,%eax
  8036f3:	d3 e8                	shr    %cl,%eax
  8036f5:	89 e9                	mov    %ebp,%ecx
  8036f7:	89 c7                	mov    %eax,%edi
  8036f9:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  8036fd:	d3 e6                	shl    %cl,%esi
  8036ff:	89 d1                	mov    %edx,%ecx
  803701:	89 fa                	mov    %edi,%edx
  803703:	d3 e8                	shr    %cl,%eax
  803705:	89 e9                	mov    %ebp,%ecx
  803707:	09 f0                	or     %esi,%eax
  803709:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80370d:	f7 74 24 10          	divl   0x10(%esp)
  803711:	d3 e6                	shl    %cl,%esi
  803713:	89 d1                	mov    %edx,%ecx
  803715:	f7 64 24 0c          	mull   0xc(%esp)
  803719:	39 d1                	cmp    %edx,%ecx
  80371b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80371f:	89 d7                	mov    %edx,%edi
  803721:	89 c6                	mov    %eax,%esi
  803723:	72 0a                	jb     80372f <__umoddi3+0x12f>
  803725:	39 44 24 14          	cmp    %eax,0x14(%esp)
  803729:	73 10                	jae    80373b <__umoddi3+0x13b>
  80372b:	39 d1                	cmp    %edx,%ecx
  80372d:	75 0c                	jne    80373b <__umoddi3+0x13b>
  80372f:	89 d7                	mov    %edx,%edi
  803731:	89 c6                	mov    %eax,%esi
  803733:	2b 74 24 0c          	sub    0xc(%esp),%esi
  803737:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80373b:	89 ca                	mov    %ecx,%edx
  80373d:	89 e9                	mov    %ebp,%ecx
  80373f:	8b 44 24 14          	mov    0x14(%esp),%eax
  803743:	29 f0                	sub    %esi,%eax
  803745:	19 fa                	sbb    %edi,%edx
  803747:	d3 e8                	shr    %cl,%eax
  803749:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  80374e:	89 d7                	mov    %edx,%edi
  803750:	d3 e7                	shl    %cl,%edi
  803752:	89 e9                	mov    %ebp,%ecx
  803754:	09 f8                	or     %edi,%eax
  803756:	d3 ea                	shr    %cl,%edx
  803758:	83 c4 20             	add    $0x20,%esp
  80375b:	5e                   	pop    %esi
  80375c:	5f                   	pop    %edi
  80375d:	5d                   	pop    %ebp
  80375e:	c3                   	ret    
  80375f:	90                   	nop
  803760:	8b 74 24 10          	mov    0x10(%esp),%esi
  803764:	29 f9                	sub    %edi,%ecx
  803766:	19 c6                	sbb    %eax,%esi
  803768:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  80376c:	89 74 24 18          	mov    %esi,0x18(%esp)
  803770:	e9 ff fe ff ff       	jmp    803674 <__umoddi3+0x74>
