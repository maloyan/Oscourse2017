
obj/kern/kernel:     file format elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	cli
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 fa                	in     $0xfa,%al

f010000c <entry>:
f010000c:	fa                   	cli    
	movw	$0x1234,0x472			# warm boot
f010000d:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100014:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100016:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001b:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001e:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100021:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100026:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100029:	b8 30 00 10 f0       	mov    $0xf0100030,%eax
	jmp	*%eax
f010002e:	ff e0                	jmp    *%eax

f0100030 <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f0100030:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100035:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f010003a:	e8 02 00 00 00       	call   f0100041 <i386_init>

f010003f <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003f:	eb fe                	jmp    f010003f <spin>

f0100041 <i386_init>:
#include <kern/picirq.h>
#include <kern/kclock.h>

void
i386_init(void)
{
f0100041:	55                   	push   %ebp
f0100042:	89 e5                	mov    %esp,%ebp
f0100044:	83 ec 0c             	sub    $0xc,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100047:	b8 2c e1 39 f0       	mov    $0xf039e12c,%eax
f010004c:	2d 3c d1 39 f0       	sub    $0xf039d13c,%eax
f0100051:	50                   	push   %eax
f0100052:	6a 00                	push   $0x0
f0100054:	68 3c d1 39 f0       	push   $0xf039d13c
f0100059:	e8 22 53 00 00       	call   f0105380 <memset>
	
	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f010005e:	e8 dd 04 00 00       	call   f0100540 <cons_init>

	tsc_calibrate();
f0100063:	e8 21 55 00 00       	call   f0105589 <tsc_calibrate>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100068:	83 c4 08             	add    $0x8,%esp
f010006b:	68 ac 1a 00 00       	push   $0x1aac
f0100070:	68 00 5b 10 f0       	push   $0xf0105b00
f0100075:	e8 cc 36 00 00       	call   f0103746 <cprintf>
	cprintf("END: %p\n", end);
f010007a:	83 c4 08             	add    $0x8,%esp
f010007d:	68 2c e1 39 f0       	push   $0xf039e12c
f0100082:	68 1b 5b 10 f0       	push   $0xf0105b1b
f0100087:	e8 ba 36 00 00       	call   f0103746 <cprintf>

#ifndef CONFIG_KSPACE
	// Lab 6 memory management initialization functions
	mem_init();
f010008c:	e8 f7 10 00 00       	call   f0101188 <mem_init>
#endif

	// user environment initialization functions
	env_init();
f0100091:	e8 02 2b 00 00       	call   f0102b98 <env_init>
	trap_init();
f0100096:	e8 1c 37 00 00       	call   f01037b7 <trap_init>

	clock_idt_init();
f010009b:	e8 7d 3a 00 00       	call   f0103b1d <clock_idt_init>

	pic_init();
f01000a0:	e8 b2 35 00 00       	call   f0103657 <pic_init>
	rtc_init();
f01000a5:	e8 c5 34 00 00       	call   f010356f <rtc_init>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<IRQ_CLOCK));
f01000aa:	0f b7 05 50 13 12 f0 	movzwl 0xf0121350,%eax
f01000b1:	25 ff fe 00 00       	and    $0xfeff,%eax
f01000b6:	89 04 24             	mov    %eax,(%esp)
f01000b9:	e8 24 35 00 00       	call   f01035e2 <irq_setmask_8259A>
	ENV_CREATE_KERNEL_TYPE(prog_test2);
	ENV_CREATE_KERNEL_TYPE(prog_test3);
	ENV_CREATE_KERNEL_TYPE(prog_test4);
	ENV_CREATE_KERNEL_TYPE(prog_test5);
#else
	ENV_CREATE(fs_fs, ENV_TYPE_FS);
f01000be:	83 c4 0c             	add    $0xc,%esp
f01000c1:	6a 03                	push   $0x3
f01000c3:	68 6c 85 01 00       	push   $0x1856c
f01000c8:	68 80 78 2e f0       	push   $0xf02e7880
f01000cd:	e8 9b 2c 00 00       	call   f0102d6d <env_create>
	// Don't touch -- used by grading script!
	ENV_CREATE(TEST, ENV_TYPE_USER);
#else
	// Touch all you want.
	//ENDNV_CREATE(user_spin, ENV_TYPE_USER);
	ENV_CREATE(user_icode, ENV_TYPE_USER);
f01000d2:	83 c4 0c             	add    $0xc,%esp
f01000d5:	6a 02                	push   $0x2
f01000d7:	68 98 df 00 00       	push   $0xdf98
f01000dc:	68 e8 98 2d f0       	push   $0xf02d98e8
f01000e1:	e8 87 2c 00 00       	call   f0102d6d <env_create>
#endif // TEST*
#endif

	// Should not be necessary - drains keyboard because interrupt has given up.
	kbd_intr();
f01000e6:	e8 f9 03 00 00       	call   f01004e4 <kbd_intr>

	// Schedule and run the first user environment!
	sched_yield();
f01000eb:	e8 25 40 00 00       	call   f0104115 <sched_yield>

f01000f0 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f01000f0:	55                   	push   %ebp
f01000f1:	89 e5                	mov    %esp,%ebp
f01000f3:	56                   	push   %esi
f01000f4:	53                   	push   %ebx
f01000f5:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f01000f8:	83 3d 90 e0 39 f0 00 	cmpl   $0x0,0xf039e090
f01000ff:	75 37                	jne    f0100138 <_panic+0x48>
		goto dead;
	panicstr = fmt;
f0100101:	89 35 90 e0 39 f0    	mov    %esi,0xf039e090

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f0100107:	fa                   	cli    
f0100108:	fc                   	cld    

	va_start(ap, fmt);
f0100109:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel panic at %s:%d: ", file, line);
f010010c:	83 ec 04             	sub    $0x4,%esp
f010010f:	ff 75 0c             	pushl  0xc(%ebp)
f0100112:	ff 75 08             	pushl  0x8(%ebp)
f0100115:	68 24 5b 10 f0       	push   $0xf0105b24
f010011a:	e8 27 36 00 00       	call   f0103746 <cprintf>
	vcprintf(fmt, ap);
f010011f:	83 c4 08             	add    $0x8,%esp
f0100122:	53                   	push   %ebx
f0100123:	56                   	push   %esi
f0100124:	e8 f7 35 00 00       	call   f0103720 <vcprintf>
	cprintf("\n");
f0100129:	c7 04 24 1f 64 10 f0 	movl   $0xf010641f,(%esp)
f0100130:	e8 11 36 00 00       	call   f0103746 <cprintf>
	va_end(ap);
f0100135:	83 c4 10             	add    $0x10,%esp

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f0100138:	83 ec 0c             	sub    $0xc,%esp
f010013b:	6a 00                	push   $0x0
f010013d:	e8 e7 07 00 00       	call   f0100929 <monitor>
f0100142:	83 c4 10             	add    $0x10,%esp
f0100145:	eb f1                	jmp    f0100138 <_panic+0x48>

f0100147 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100147:	55                   	push   %ebp
f0100148:	89 e5                	mov    %esp,%ebp
f010014a:	53                   	push   %ebx
f010014b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f010014e:	8d 5d 14             	lea    0x14(%ebp),%ebx
	cprintf("kernel warning at %s:%d: ", file, line);
f0100151:	ff 75 0c             	pushl  0xc(%ebp)
f0100154:	ff 75 08             	pushl  0x8(%ebp)
f0100157:	68 3c 5b 10 f0       	push   $0xf0105b3c
f010015c:	e8 e5 35 00 00       	call   f0103746 <cprintf>
	vcprintf(fmt, ap);
f0100161:	83 c4 08             	add    $0x8,%esp
f0100164:	53                   	push   %ebx
f0100165:	ff 75 10             	pushl  0x10(%ebp)
f0100168:	e8 b3 35 00 00       	call   f0103720 <vcprintf>
	cprintf("\n");
f010016d:	c7 04 24 1f 64 10 f0 	movl   $0xf010641f,(%esp)
f0100174:	e8 cd 35 00 00       	call   f0103746 <cprintf>
	va_end(ap);
f0100179:	83 c4 10             	add    $0x10,%esp
}
f010017c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010017f:	c9                   	leave  
f0100180:	c3                   	ret    

f0100181 <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f0100181:	55                   	push   %ebp
f0100182:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100184:	ba fd 03 00 00       	mov    $0x3fd,%edx
f0100189:	ec                   	in     (%dx),%al
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f010018a:	a8 01                	test   $0x1,%al
f010018c:	74 08                	je     f0100196 <serial_proc_data+0x15>
f010018e:	b2 f8                	mov    $0xf8,%dl
f0100190:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f0100191:	0f b6 c0             	movzbl %al,%eax
f0100194:	eb 05                	jmp    f010019b <serial_proc_data+0x1a>

static int
serial_proc_data(void)
{
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
		return -1;
f0100196:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	return inb(COM1+COM_RX);
}
f010019b:	5d                   	pop    %ebp
f010019c:	c3                   	ret    

f010019d <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f010019d:	55                   	push   %ebp
f010019e:	89 e5                	mov    %esp,%ebp
f01001a0:	53                   	push   %ebx
f01001a1:	83 ec 04             	sub    $0x4,%esp
f01001a4:	89 c3                	mov    %eax,%ebx
	int c;

	while ((c = (*proc)()) != -1) {
f01001a6:	eb 2a                	jmp    f01001d2 <cons_intr+0x35>
		if (c == 0)
f01001a8:	85 d2                	test   %edx,%edx
f01001aa:	74 26                	je     f01001d2 <cons_intr+0x35>
			continue;
		cons.buf[cons.wpos++] = c;
f01001ac:	a1 84 d3 39 f0       	mov    0xf039d384,%eax
f01001b1:	8d 48 01             	lea    0x1(%eax),%ecx
f01001b4:	89 0d 84 d3 39 f0    	mov    %ecx,0xf039d384
f01001ba:	88 90 80 d1 39 f0    	mov    %dl,-0xfc62e80(%eax)
		if (cons.wpos == CONSBUFSIZE)
f01001c0:	81 f9 00 02 00 00    	cmp    $0x200,%ecx
f01001c6:	75 0a                	jne    f01001d2 <cons_intr+0x35>
			cons.wpos = 0;
f01001c8:	c7 05 84 d3 39 f0 00 	movl   $0x0,0xf039d384
f01001cf:	00 00 00 
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001d2:	ff d3                	call   *%ebx
f01001d4:	89 c2                	mov    %eax,%edx
f01001d6:	83 f8 ff             	cmp    $0xffffffff,%eax
f01001d9:	75 cd                	jne    f01001a8 <cons_intr+0xb>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f01001db:	83 c4 04             	add    $0x4,%esp
f01001de:	5b                   	pop    %ebx
f01001df:	5d                   	pop    %ebp
f01001e0:	c3                   	ret    

f01001e1 <kbd_proc_data>:
f01001e1:	ba 64 00 00 00       	mov    $0x64,%edx
f01001e6:	ec                   	in     (%dx),%al
{
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01001e7:	a8 01                	test   $0x1,%al
f01001e9:	0f 84 e8 00 00 00    	je     f01002d7 <kbd_proc_data+0xf6>
f01001ef:	b2 60                	mov    $0x60,%dl
f01001f1:	ec                   	in     (%dx),%al
f01001f2:	89 c2                	mov    %eax,%edx
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01001f4:	3c e0                	cmp    $0xe0,%al
f01001f6:	75 0d                	jne    f0100205 <kbd_proc_data+0x24>
		// E0 escape character
		shift |= E0ESC;
f01001f8:	83 0d 40 d1 39 f0 40 	orl    $0x40,0xf039d140
		return 0;
f01001ff:	b8 00 00 00 00       	mov    $0x0,%eax
f0100204:	c3                   	ret    
	} else if (data & 0x80) {
f0100205:	84 c0                	test   %al,%al
f0100207:	79 2f                	jns    f0100238 <kbd_proc_data+0x57>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100209:	8b 0d 40 d1 39 f0    	mov    0xf039d140,%ecx
f010020f:	f6 c1 40             	test   $0x40,%cl
f0100212:	75 05                	jne    f0100219 <kbd_proc_data+0x38>
f0100214:	83 e0 7f             	and    $0x7f,%eax
f0100217:	89 c2                	mov    %eax,%edx
		shift &= ~(shiftcode[data] | E0ESC);
f0100219:	0f b6 c2             	movzbl %dl,%eax
f010021c:	0f b6 80 c0 5c 10 f0 	movzbl -0xfefa340(%eax),%eax
f0100223:	83 c8 40             	or     $0x40,%eax
f0100226:	0f b6 c0             	movzbl %al,%eax
f0100229:	f7 d0                	not    %eax
f010022b:	21 c8                	and    %ecx,%eax
f010022d:	a3 40 d1 39 f0       	mov    %eax,0xf039d140
		return 0;
f0100232:	b8 00 00 00 00       	mov    $0x0,%eax
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f0100237:	c3                   	ret    
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f0100238:	55                   	push   %ebp
f0100239:	89 e5                	mov    %esp,%ebp
f010023b:	53                   	push   %ebx
f010023c:	83 ec 04             	sub    $0x4,%esp
	} else if (data & 0x80) {
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
		shift &= ~(shiftcode[data] | E0ESC);
		return 0;
	} else if (shift & E0ESC) {
f010023f:	8b 0d 40 d1 39 f0    	mov    0xf039d140,%ecx
f0100245:	f6 c1 40             	test   $0x40,%cl
f0100248:	74 0e                	je     f0100258 <kbd_proc_data+0x77>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f010024a:	83 c8 80             	or     $0xffffff80,%eax
f010024d:	89 c2                	mov    %eax,%edx
		shift &= ~E0ESC;
f010024f:	83 e1 bf             	and    $0xffffffbf,%ecx
f0100252:	89 0d 40 d1 39 f0    	mov    %ecx,0xf039d140
	}

	shift |= shiftcode[data];
f0100258:	0f b6 c2             	movzbl %dl,%eax
f010025b:	0f b6 90 c0 5c 10 f0 	movzbl -0xfefa340(%eax),%edx
f0100262:	0b 15 40 d1 39 f0    	or     0xf039d140,%edx
	shift ^= togglecode[data];
f0100268:	0f b6 88 c0 5b 10 f0 	movzbl -0xfefa440(%eax),%ecx
f010026f:	31 ca                	xor    %ecx,%edx
f0100271:	89 15 40 d1 39 f0    	mov    %edx,0xf039d140

	c = charcode[shift & (CTL | SHIFT)][data];
f0100277:	89 d1                	mov    %edx,%ecx
f0100279:	83 e1 03             	and    $0x3,%ecx
f010027c:	8b 0c 8d 80 5b 10 f0 	mov    -0xfefa480(,%ecx,4),%ecx
f0100283:	0f b6 04 01          	movzbl (%ecx,%eax,1),%eax
f0100287:	0f b6 d8             	movzbl %al,%ebx
	if (shift & CAPSLOCK) {
f010028a:	f6 c2 08             	test   $0x8,%dl
f010028d:	74 1a                	je     f01002a9 <kbd_proc_data+0xc8>
		if ('a' <= c && c <= 'z')
f010028f:	89 d8                	mov    %ebx,%eax
f0100291:	8d 4b 9f             	lea    -0x61(%ebx),%ecx
f0100294:	83 f9 19             	cmp    $0x19,%ecx
f0100297:	77 05                	ja     f010029e <kbd_proc_data+0xbd>
			c += 'A' - 'a';
f0100299:	83 eb 20             	sub    $0x20,%ebx
f010029c:	eb 0b                	jmp    f01002a9 <kbd_proc_data+0xc8>
		else if ('A' <= c && c <= 'Z')
f010029e:	83 e8 41             	sub    $0x41,%eax
f01002a1:	83 f8 19             	cmp    $0x19,%eax
f01002a4:	77 03                	ja     f01002a9 <kbd_proc_data+0xc8>
			c += 'a' - 'A';
f01002a6:	83 c3 20             	add    $0x20,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01002a9:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01002af:	75 2c                	jne    f01002dd <kbd_proc_data+0xfc>
f01002b1:	f7 d2                	not    %edx
f01002b3:	f6 c2 06             	test   $0x6,%dl
f01002b6:	75 25                	jne    f01002dd <kbd_proc_data+0xfc>
		cprintf("Rebooting!\n");
f01002b8:	83 ec 0c             	sub    $0xc,%esp
f01002bb:	68 56 5b 10 f0       	push   $0xf0105b56
f01002c0:	e8 81 34 00 00       	call   f0103746 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01002c5:	ba 92 00 00 00       	mov    $0x92,%edx
f01002ca:	b8 03 00 00 00       	mov    $0x3,%eax
f01002cf:	ee                   	out    %al,(%dx)
f01002d0:	83 c4 10             	add    $0x10,%esp
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002d3:	89 d8                	mov    %ebx,%eax
f01002d5:	eb 08                	jmp    f01002df <kbd_proc_data+0xfe>
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
		return -1;
f01002d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002dc:	c3                   	ret    
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
		cprintf("Rebooting!\n");
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
f01002dd:	89 d8                	mov    %ebx,%eax
}
f01002df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01002e2:	c9                   	leave  
f01002e3:	c3                   	ret    

f01002e4 <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01002e4:	55                   	push   %ebp
f01002e5:	89 e5                	mov    %esp,%ebp
f01002e7:	57                   	push   %edi
f01002e8:	56                   	push   %esi
f01002e9:	53                   	push   %ebx
f01002ea:	83 ec 1c             	sub    $0x1c,%esp
f01002ed:	89 c7                	mov    %eax,%edi
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01002ef:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002f4:	be fd 03 00 00       	mov    $0x3fd,%esi
f01002f9:	b9 84 00 00 00       	mov    $0x84,%ecx
f01002fe:	eb 09                	jmp    f0100309 <cons_putc+0x25>
f0100300:	89 ca                	mov    %ecx,%edx
f0100302:	ec                   	in     (%dx),%al
f0100303:	ec                   	in     (%dx),%al
f0100304:	ec                   	in     (%dx),%al
f0100305:	ec                   	in     (%dx),%al
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f0100306:	83 c3 01             	add    $0x1,%ebx
f0100309:	89 f2                	mov    %esi,%edx
f010030b:	ec                   	in     (%dx),%al
serial_putc(int c)
{
	int i;

	for (i = 0;
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
f010030c:	a8 20                	test   $0x20,%al
f010030e:	75 08                	jne    f0100318 <cons_putc+0x34>
f0100310:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f0100316:	7e e8                	jle    f0100300 <cons_putc+0x1c>
f0100318:	89 f8                	mov    %edi,%eax
f010031a:	88 45 e7             	mov    %al,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010031d:	ba f8 03 00 00       	mov    $0x3f8,%edx
f0100322:	89 f8                	mov    %edi,%eax
f0100324:	ee                   	out    %al,(%dx)
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100325:	bb 00 00 00 00       	mov    $0x0,%ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010032a:	be 79 03 00 00       	mov    $0x379,%esi
f010032f:	b9 84 00 00 00       	mov    $0x84,%ecx
f0100334:	eb 09                	jmp    f010033f <cons_putc+0x5b>
f0100336:	89 ca                	mov    %ecx,%edx
f0100338:	ec                   	in     (%dx),%al
f0100339:	ec                   	in     (%dx),%al
f010033a:	ec                   	in     (%dx),%al
f010033b:	ec                   	in     (%dx),%al
f010033c:	83 c3 01             	add    $0x1,%ebx
f010033f:	89 f2                	mov    %esi,%edx
f0100341:	ec                   	in     (%dx),%al
f0100342:	84 c0                	test   %al,%al
f0100344:	78 08                	js     f010034e <cons_putc+0x6a>
f0100346:	81 fb ff 31 00 00    	cmp    $0x31ff,%ebx
f010034c:	7e e8                	jle    f0100336 <cons_putc+0x52>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010034e:	ba 78 03 00 00       	mov    $0x378,%edx
f0100353:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f0100357:	ee                   	out    %al,(%dx)
f0100358:	b2 7a                	mov    $0x7a,%dl
f010035a:	b8 0d 00 00 00       	mov    $0xd,%eax
f010035f:	ee                   	out    %al,(%dx)
f0100360:	b8 08 00 00 00       	mov    $0x8,%eax
f0100365:	ee                   	out    %al,(%dx)

static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
f0100366:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f010036c:	75 06                	jne    f0100374 <cons_putc+0x90>
		c |= 0x0700;
f010036e:	81 cf 00 07 00 00    	or     $0x700,%edi

	switch (c & 0xff) {
f0100374:	89 f8                	mov    %edi,%eax
f0100376:	0f b6 c0             	movzbl %al,%eax
f0100379:	83 f8 09             	cmp    $0x9,%eax
f010037c:	74 74                	je     f01003f2 <cons_putc+0x10e>
f010037e:	83 f8 09             	cmp    $0x9,%eax
f0100381:	7f 0a                	jg     f010038d <cons_putc+0xa9>
f0100383:	83 f8 08             	cmp    $0x8,%eax
f0100386:	74 14                	je     f010039c <cons_putc+0xb8>
f0100388:	e9 99 00 00 00       	jmp    f0100426 <cons_putc+0x142>
f010038d:	83 f8 0a             	cmp    $0xa,%eax
f0100390:	74 3a                	je     f01003cc <cons_putc+0xe8>
f0100392:	83 f8 0d             	cmp    $0xd,%eax
f0100395:	74 3d                	je     f01003d4 <cons_putc+0xf0>
f0100397:	e9 8a 00 00 00       	jmp    f0100426 <cons_putc+0x142>
	case '\b':
		if (crt_pos > 0) {
f010039c:	0f b7 05 88 d3 39 f0 	movzwl 0xf039d388,%eax
f01003a3:	66 85 c0             	test   %ax,%ax
f01003a6:	0f 84 e6 00 00 00    	je     f0100492 <cons_putc+0x1ae>
			crt_pos--;
f01003ac:	83 e8 01             	sub    $0x1,%eax
f01003af:	66 a3 88 d3 39 f0    	mov    %ax,0xf039d388
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01003b5:	0f b7 c0             	movzwl %ax,%eax
f01003b8:	66 81 e7 00 ff       	and    $0xff00,%di
f01003bd:	83 cf 20             	or     $0x20,%edi
f01003c0:	8b 15 8c d3 39 f0    	mov    0xf039d38c,%edx
f01003c6:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01003ca:	eb 78                	jmp    f0100444 <cons_putc+0x160>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01003cc:	66 83 05 88 d3 39 f0 	addw   $0x50,0xf039d388
f01003d3:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01003d4:	0f b7 05 88 d3 39 f0 	movzwl 0xf039d388,%eax
f01003db:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01003e1:	c1 e8 16             	shr    $0x16,%eax
f01003e4:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01003e7:	c1 e0 04             	shl    $0x4,%eax
f01003ea:	66 a3 88 d3 39 f0    	mov    %ax,0xf039d388
f01003f0:	eb 52                	jmp    f0100444 <cons_putc+0x160>
		break;
	case '\t':
		cons_putc(' ');
f01003f2:	b8 20 00 00 00       	mov    $0x20,%eax
f01003f7:	e8 e8 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f01003fc:	b8 20 00 00 00       	mov    $0x20,%eax
f0100401:	e8 de fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100406:	b8 20 00 00 00       	mov    $0x20,%eax
f010040b:	e8 d4 fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f0100410:	b8 20 00 00 00       	mov    $0x20,%eax
f0100415:	e8 ca fe ff ff       	call   f01002e4 <cons_putc>
		cons_putc(' ');
f010041a:	b8 20 00 00 00       	mov    $0x20,%eax
f010041f:	e8 c0 fe ff ff       	call   f01002e4 <cons_putc>
f0100424:	eb 1e                	jmp    f0100444 <cons_putc+0x160>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100426:	0f b7 05 88 d3 39 f0 	movzwl 0xf039d388,%eax
f010042d:	8d 50 01             	lea    0x1(%eax),%edx
f0100430:	66 89 15 88 d3 39 f0 	mov    %dx,0xf039d388
f0100437:	0f b7 c0             	movzwl %ax,%eax
f010043a:	8b 15 8c d3 39 f0    	mov    0xf039d38c,%edx
f0100440:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100444:	66 81 3d 88 d3 39 f0 	cmpw   $0x7cf,0xf039d388
f010044b:	cf 07 
f010044d:	76 43                	jbe    f0100492 <cons_putc+0x1ae>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f010044f:	a1 8c d3 39 f0       	mov    0xf039d38c,%eax
f0100454:	83 ec 04             	sub    $0x4,%esp
f0100457:	68 00 0f 00 00       	push   $0xf00
f010045c:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100462:	52                   	push   %edx
f0100463:	50                   	push   %eax
f0100464:	e8 64 4f 00 00       	call   f01053cd <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f0100469:	8b 15 8c d3 39 f0    	mov    0xf039d38c,%edx
f010046f:	8d 82 00 0f 00 00    	lea    0xf00(%edx),%eax
f0100475:	81 c2 a0 0f 00 00    	add    $0xfa0,%edx
f010047b:	83 c4 10             	add    $0x10,%esp
f010047e:	66 c7 00 20 07       	movw   $0x720,(%eax)
f0100483:	83 c0 02             	add    $0x2,%eax
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100486:	39 d0                	cmp    %edx,%eax
f0100488:	75 f4                	jne    f010047e <cons_putc+0x19a>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010048a:	66 83 2d 88 d3 39 f0 	subw   $0x50,0xf039d388
f0100491:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100492:	8b 0d 90 d3 39 f0    	mov    0xf039d390,%ecx
f0100498:	b8 0e 00 00 00       	mov    $0xe,%eax
f010049d:	89 ca                	mov    %ecx,%edx
f010049f:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01004a0:	0f b7 1d 88 d3 39 f0 	movzwl 0xf039d388,%ebx
f01004a7:	8d 71 01             	lea    0x1(%ecx),%esi
f01004aa:	89 d8                	mov    %ebx,%eax
f01004ac:	66 c1 e8 08          	shr    $0x8,%ax
f01004b0:	89 f2                	mov    %esi,%edx
f01004b2:	ee                   	out    %al,(%dx)
f01004b3:	b8 0f 00 00 00       	mov    $0xf,%eax
f01004b8:	89 ca                	mov    %ecx,%edx
f01004ba:	ee                   	out    %al,(%dx)
f01004bb:	89 d8                	mov    %ebx,%eax
f01004bd:	89 f2                	mov    %esi,%edx
f01004bf:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01004c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01004c3:	5b                   	pop    %ebx
f01004c4:	5e                   	pop    %esi
f01004c5:	5f                   	pop    %edi
f01004c6:	5d                   	pop    %ebp
f01004c7:	c3                   	ret    

f01004c8 <serial_intr>:
}

void
serial_intr(void)
{
	if (serial_exists)
f01004c8:	80 3d 94 d3 39 f0 00 	cmpb   $0x0,0xf039d394
f01004cf:	74 11                	je     f01004e2 <serial_intr+0x1a>
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f01004d1:	55                   	push   %ebp
f01004d2:	89 e5                	mov    %esp,%ebp
f01004d4:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
		cons_intr(serial_proc_data);
f01004d7:	b8 81 01 10 f0       	mov    $0xf0100181,%eax
f01004dc:	e8 bc fc ff ff       	call   f010019d <cons_intr>
}
f01004e1:	c9                   	leave  
f01004e2:	f3 c3                	repz ret 

f01004e4 <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f01004e4:	55                   	push   %ebp
f01004e5:	89 e5                	mov    %esp,%ebp
f01004e7:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f01004ea:	b8 e1 01 10 f0       	mov    $0xf01001e1,%eax
f01004ef:	e8 a9 fc ff ff       	call   f010019d <cons_intr>
}
f01004f4:	c9                   	leave  
f01004f5:	c3                   	ret    

f01004f6 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01004f6:	55                   	push   %ebp
f01004f7:	89 e5                	mov    %esp,%ebp
f01004f9:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f01004fc:	e8 c7 ff ff ff       	call   f01004c8 <serial_intr>
	kbd_intr();
f0100501:	e8 de ff ff ff       	call   f01004e4 <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f0100506:	a1 80 d3 39 f0       	mov    0xf039d380,%eax
f010050b:	3b 05 84 d3 39 f0    	cmp    0xf039d384,%eax
f0100511:	74 26                	je     f0100539 <cons_getc+0x43>
		c = cons.buf[cons.rpos++];
f0100513:	8d 50 01             	lea    0x1(%eax),%edx
f0100516:	89 15 80 d3 39 f0    	mov    %edx,0xf039d380
f010051c:	0f b6 88 80 d1 39 f0 	movzbl -0xfc62e80(%eax),%ecx
		if (cons.rpos == CONSBUFSIZE)
			cons.rpos = 0;
		return c;
f0100523:	89 c8                	mov    %ecx,%eax
	kbd_intr();

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
		c = cons.buf[cons.rpos++];
		if (cons.rpos == CONSBUFSIZE)
f0100525:	81 fa 00 02 00 00    	cmp    $0x200,%edx
f010052b:	75 11                	jne    f010053e <cons_getc+0x48>
			cons.rpos = 0;
f010052d:	c7 05 80 d3 39 f0 00 	movl   $0x0,0xf039d380
f0100534:	00 00 00 
f0100537:	eb 05                	jmp    f010053e <cons_getc+0x48>
		return c;
	}
	return 0;
f0100539:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010053e:	c9                   	leave  
f010053f:	c3                   	ret    

f0100540 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100540:	55                   	push   %ebp
f0100541:	89 e5                	mov    %esp,%ebp
f0100543:	57                   	push   %edi
f0100544:	56                   	push   %esi
f0100545:	53                   	push   %ebx
f0100546:	83 ec 0c             	sub    $0xc,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF); // Addressing lower bytes througth higher KERNBASE mapping.
	was = *cp;                            // CGA_BUF has fixed address.
f0100549:	0f b7 15 00 80 0b f0 	movzwl 0xf00b8000,%edx
	*cp = (uint16_t) 0xA55A;
f0100550:	66 c7 05 00 80 0b f0 	movw   $0xa55a,0xf00b8000
f0100557:	5a a5 
	if (*cp != 0xA55A) {
f0100559:	0f b7 05 00 80 0b f0 	movzwl 0xf00b8000,%eax
f0100560:	66 3d 5a a5          	cmp    $0xa55a,%ax
f0100564:	74 11                	je     f0100577 <cons_init+0x37>
		cp = (uint16_t*) (KERNBASE + MONO_BUF); // Addressing lower bytes higher KERTOP mapping.
		addr_6845 = MONO_BASE;                 // MONO_BASE has fixed address.
f0100566:	c7 05 90 d3 39 f0 b4 	movl   $0x3b4,0xf039d390
f010056d:	03 00 00 

	cp = (uint16_t*) (KERNBASE + CGA_BUF); // Addressing lower bytes througth higher KERNBASE mapping.
	was = *cp;                            // CGA_BUF has fixed address.
	*cp = (uint16_t) 0xA55A;
	if (*cp != 0xA55A) {
		cp = (uint16_t*) (KERNBASE + MONO_BUF); // Addressing lower bytes higher KERTOP mapping.
f0100570:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100575:	eb 16                	jmp    f010058d <cons_init+0x4d>
		addr_6845 = MONO_BASE;                 // MONO_BASE has fixed address.
	} else {
		*cp = was;
f0100577:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f010057e:	c7 05 90 d3 39 f0 d4 	movl   $0x3d4,0xf039d390
f0100585:	03 00 00 
{
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF); // Addressing lower bytes througth higher KERNBASE mapping.
f0100588:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
		*cp = was;
		addr_6845 = CGA_BASE;
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010058d:	8b 3d 90 d3 39 f0    	mov    0xf039d390,%edi
f0100593:	b8 0e 00 00 00       	mov    $0xe,%eax
f0100598:	89 fa                	mov    %edi,%edx
f010059a:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010059b:	8d 4f 01             	lea    0x1(%edi),%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010059e:	89 ca                	mov    %ecx,%edx
f01005a0:	ec                   	in     (%dx),%al
f01005a1:	0f b6 c0             	movzbl %al,%eax
f01005a4:	c1 e0 08             	shl    $0x8,%eax
f01005a7:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005a9:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005ae:	89 fa                	mov    %edi,%edx
f01005b0:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005b1:	89 ca                	mov    %ecx,%edx
f01005b3:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f01005b4:	89 35 8c d3 39 f0    	mov    %esi,0xf039d38c

	/* Extract cursor location */
	outb(addr_6845, 14);
	pos = inb(addr_6845 + 1) << 8;
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);
f01005ba:	0f b6 c8             	movzbl %al,%ecx
f01005bd:	89 d8                	mov    %ebx,%eax
f01005bf:	09 c8                	or     %ecx,%eax

	crt_buf = (uint16_t*) cp;
	crt_pos = pos;
f01005c1:	66 a3 88 d3 39 f0    	mov    %ax,0xf039d388

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f01005c7:	e8 18 ff ff ff       	call   f01004e4 <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f01005cc:	83 ec 0c             	sub    $0xc,%esp
f01005cf:	0f b7 05 50 13 12 f0 	movzwl 0xf0121350,%eax
f01005d6:	25 fd ff 00 00       	and    $0xfffd,%eax
f01005db:	50                   	push   %eax
f01005dc:	e8 01 30 00 00       	call   f01035e2 <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01005e1:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f01005e6:	b8 00 00 00 00       	mov    $0x0,%eax
f01005eb:	89 da                	mov    %ebx,%edx
f01005ed:	ee                   	out    %al,(%dx)
f01005ee:	b2 fb                	mov    $0xfb,%dl
f01005f0:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f01005f5:	ee                   	out    %al,(%dx)
f01005f6:	be f8 03 00 00       	mov    $0x3f8,%esi
f01005fb:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100600:	89 f2                	mov    %esi,%edx
f0100602:	ee                   	out    %al,(%dx)
f0100603:	b2 f9                	mov    $0xf9,%dl
f0100605:	b8 00 00 00 00       	mov    $0x0,%eax
f010060a:	ee                   	out    %al,(%dx)
f010060b:	b2 fb                	mov    $0xfb,%dl
f010060d:	b8 03 00 00 00       	mov    $0x3,%eax
f0100612:	ee                   	out    %al,(%dx)
f0100613:	b2 fc                	mov    $0xfc,%dl
f0100615:	b8 00 00 00 00       	mov    $0x0,%eax
f010061a:	ee                   	out    %al,(%dx)
f010061b:	b2 f9                	mov    $0xf9,%dl
f010061d:	b8 01 00 00 00       	mov    $0x1,%eax
f0100622:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100623:	b2 fd                	mov    $0xfd,%dl
f0100625:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f0100626:	83 c4 10             	add    $0x10,%esp
f0100629:	3c ff                	cmp    $0xff,%al
f010062b:	0f 95 c1             	setne  %cl
f010062e:	88 0d 94 d3 39 f0    	mov    %cl,0xf039d394
f0100634:	89 da                	mov    %ebx,%edx
f0100636:	ec                   	in     (%dx),%al
f0100637:	89 f2                	mov    %esi,%edx
f0100639:	ec                   	in     (%dx),%al
	(void) inb(COM1+COM_IIR);
	(void) inb(COM1+COM_RX);

	// Enable serial interrupts
	if (serial_exists)
f010063a:	84 c9                	test   %cl,%cl
f010063c:	74 21                	je     f010065f <cons_init+0x11f>
		irq_setmask_8259A(irq_mask_8259A & ~(1<<4));
f010063e:	83 ec 0c             	sub    $0xc,%esp
f0100641:	0f b7 05 50 13 12 f0 	movzwl 0xf0121350,%eax
f0100648:	25 ef ff 00 00       	and    $0xffef,%eax
f010064d:	50                   	push   %eax
f010064e:	e8 8f 2f 00 00       	call   f01035e2 <irq_setmask_8259A>
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f0100653:	83 c4 10             	add    $0x10,%esp
f0100656:	80 3d 94 d3 39 f0 00 	cmpb   $0x0,0xf039d394
f010065d:	75 10                	jne    f010066f <cons_init+0x12f>
		cprintf("Serial port does not exist!\n");
f010065f:	83 ec 0c             	sub    $0xc,%esp
f0100662:	68 62 5b 10 f0       	push   $0xf0105b62
f0100667:	e8 da 30 00 00       	call   f0103746 <cprintf>
f010066c:	83 c4 10             	add    $0x10,%esp
}
f010066f:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100672:	5b                   	pop    %ebx
f0100673:	5e                   	pop    %esi
f0100674:	5f                   	pop    %edi
f0100675:	5d                   	pop    %ebp
f0100676:	c3                   	ret    

f0100677 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f0100677:	55                   	push   %ebp
f0100678:	89 e5                	mov    %esp,%ebp
f010067a:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f010067d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100680:	e8 5f fc ff ff       	call   f01002e4 <cons_putc>
}
f0100685:	c9                   	leave  
f0100686:	c3                   	ret    

f0100687 <getchar>:

int
getchar(void)
{
f0100687:	55                   	push   %ebp
f0100688:	89 e5                	mov    %esp,%ebp
f010068a:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f010068d:	e8 64 fe ff ff       	call   f01004f6 <cons_getc>
f0100692:	85 c0                	test   %eax,%eax
f0100694:	74 f7                	je     f010068d <getchar+0x6>
		/* do nothing */;
	return c;
}
f0100696:	c9                   	leave  
f0100697:	c3                   	ret    

f0100698 <iscons>:

int
iscons(int fdnum)
{
f0100698:	55                   	push   %ebp
f0100699:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f010069b:	b8 01 00 00 00       	mov    $0x1,%eax
f01006a0:	5d                   	pop    %ebp
f01006a1:	c3                   	ret    

f01006a2 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01006a2:	55                   	push   %ebp
f01006a3:	89 e5                	mov    %esp,%ebp
f01006a5:	56                   	push   %esi
f01006a6:	53                   	push   %ebx
f01006a7:	bb 04 61 10 f0       	mov    $0xf0106104,%ebx
f01006ac:	be 58 61 10 f0       	mov    $0xf0106158,%esi
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01006b1:	83 ec 04             	sub    $0x4,%esp
f01006b4:	ff 33                	pushl  (%ebx)
f01006b6:	ff 73 fc             	pushl  -0x4(%ebx)
f01006b9:	68 c0 5d 10 f0       	push   $0xf0105dc0
f01006be:	e8 83 30 00 00       	call   f0103746 <cprintf>
f01006c3:	83 c3 0c             	add    $0xc,%ebx
int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
f01006c6:	83 c4 10             	add    $0x10,%esp
f01006c9:	39 f3                	cmp    %esi,%ebx
f01006cb:	75 e4                	jne    f01006b1 <mon_help+0xf>
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}
f01006cd:	b8 00 00 00 00       	mov    $0x0,%eax
f01006d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01006d5:	5b                   	pop    %ebx
f01006d6:	5e                   	pop    %esi
f01006d7:	5d                   	pop    %ebp
f01006d8:	c3                   	ret    

f01006d9 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01006d9:	55                   	push   %ebp
f01006da:	89 e5                	mov    %esp,%ebp
f01006dc:	83 ec 14             	sub    $0x14,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01006df:	68 c9 5d 10 f0       	push   $0xf0105dc9
f01006e4:	e8 5d 30 00 00       	call   f0103746 <cprintf>
	cprintf("  _start                  %08x (phys)\n", (uint32_t)_start);
f01006e9:	83 c4 08             	add    $0x8,%esp
f01006ec:	68 0c 00 10 00       	push   $0x10000c
f01006f1:	68 44 5f 10 f0       	push   $0xf0105f44
f01006f6:	e8 4b 30 00 00       	call   f0103746 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n",
f01006fb:	83 c4 0c             	add    $0xc,%esp
f01006fe:	68 0c 00 10 00       	push   $0x10000c
f0100703:	68 0c 00 10 f0       	push   $0xf010000c
f0100708:	68 6c 5f 10 f0       	push   $0xf0105f6c
f010070d:	e8 34 30 00 00       	call   f0103746 <cprintf>
            (uint32_t)entry, (uint32_t)entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n",
f0100712:	83 c4 0c             	add    $0xc,%esp
f0100715:	68 f5 5a 10 00       	push   $0x105af5
f010071a:	68 f5 5a 10 f0       	push   $0xf0105af5
f010071f:	68 90 5f 10 f0       	push   $0xf0105f90
f0100724:	e8 1d 30 00 00       	call   f0103746 <cprintf>
            (uint32_t)etext, (uint32_t)etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n",
f0100729:	83 c4 0c             	add    $0xc,%esp
f010072c:	68 3c d1 39 00       	push   $0x39d13c
f0100731:	68 3c d1 39 f0       	push   $0xf039d13c
f0100736:	68 b4 5f 10 f0       	push   $0xf0105fb4
f010073b:	e8 06 30 00 00       	call   f0103746 <cprintf>
            (uint32_t)edata, (uint32_t)edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n",
f0100740:	83 c4 0c             	add    $0xc,%esp
f0100743:	68 2c e1 39 00       	push   $0x39e12c
f0100748:	68 2c e1 39 f0       	push   $0xf039e12c
f010074d:	68 d8 5f 10 f0       	push   $0xf0105fd8
f0100752:	e8 ef 2f 00 00       	call   f0103746 <cprintf>
f0100757:	b8 2b e5 39 f0       	mov    $0xf039e52b,%eax
            (uint32_t)end, (uint32_t)end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
	    ROUNDUP(end - entry, 1024) / 1024);
f010075c:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
            (uint32_t)etext, (uint32_t)etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n",
            (uint32_t)edata, (uint32_t)edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n",
            (uint32_t)end, (uint32_t)end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100761:	83 c4 08             	add    $0x8,%esp
f0100764:	c1 f8 0a             	sar    $0xa,%eax
f0100767:	50                   	push   %eax
f0100768:	68 fc 5f 10 f0       	push   $0xf0105ffc
f010076d:	e8 d4 2f 00 00       	call   f0103746 <cprintf>
	    ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f0100772:	b8 00 00 00 00       	mov    $0x0,%eax
f0100777:	c9                   	leave  
f0100778:	c3                   	ret    

f0100779 <mon_test>:
	return 0;
}

int
mon_test(int argc, char **argv, struct Trapframe *tf)
{
f0100779:	55                   	push   %ebp
f010077a:	89 e5                	mov    %esp,%ebp
f010077c:	83 ec 14             	sub    $0x14,%esp
	cprintf("It works!\n");
f010077f:	68 e2 5d 10 f0       	push   $0xf0105de2
f0100784:	e8 bd 2f 00 00       	call   f0103746 <cprintf>
	return 0;
}
f0100789:	b8 00 00 00 00       	mov    $0x0,%eax
f010078e:	c9                   	leave  
f010078f:	c3                   	ret    

f0100790 <mon_memory>:
	timer_stop();
	return 0;
}

int
mon_memory(int argc, char **argv, struct Trapframe *tf) {
f0100790:	55                   	push   %ebp
f0100791:	89 e5                	mov    %esp,%ebp
f0100793:	57                   	push   %edi
f0100794:	56                   	push   %esi
f0100795:	53                   	push   %ebx
f0100796:	83 ec 1c             	sub    $0x1c,%esp
	int i, start = 1, state_flag = 1, ref_flag = 0;
f0100799:	bf 01 00 00 00       	mov    $0x1,%edi
f010079e:	b8 01 00 00 00       	mov    $0x1,%eax
	for (i = 0; i < npages; i++) {
f01007a3:	bb 00 00 00 00       	mov    $0x0,%ebx
f01007a8:	eb 72                	jmp    f010081c <mon_memory+0x8c>

		if (pages[i].pp_ref) {
f01007aa:	8b 15 a0 e0 39 f0    	mov    0xf039e0a0,%edx
f01007b0:	66 83 7c da 04 00    	cmpw   $0x0,0x4(%edx,%ebx,8)
f01007b6:	0f 95 c1             	setne  %cl
f01007b9:	0f b6 c9             	movzbl %cl,%ecx
f01007bc:	89 ce                	mov    %ecx,%esi
			ref_flag = 1;
		} else {
			ref_flag = 0;
		}

		if (state_flag != ref_flag) {
f01007be:	39 cf                	cmp    %ecx,%edi
f01007c0:	74 55                	je     f0100817 <mon_memory+0x87>
			if (start != i)
f01007c2:	39 d8                	cmp    %ebx,%eax
f01007c4:	74 14                	je     f01007da <mon_memory+0x4a>
				cprintf("%d..%d", start, i);
f01007c6:	83 ec 04             	sub    $0x4,%esp
f01007c9:	53                   	push   %ebx
f01007ca:	50                   	push   %eax
f01007cb:	68 ed 5d 10 f0       	push   $0xf0105ded
f01007d0:	e8 71 2f 00 00       	call   f0103746 <cprintf>
f01007d5:	83 c4 10             	add    $0x10,%esp
f01007d8:	eb 11                	jmp    f01007eb <mon_memory+0x5b>
			else
				cprintf("%d", start);
f01007da:	83 ec 08             	sub    $0x8,%esp
f01007dd:	50                   	push   %eax
f01007de:	68 fc 71 10 f0       	push   $0xf01071fc
f01007e3:	e8 5e 2f 00 00       	call   f0103746 <cprintf>
f01007e8:	83 c4 10             	add    $0x10,%esp

			if (state_flag) 
f01007eb:	85 ff                	test   %edi,%edi
f01007ed:	74 12                	je     f0100801 <mon_memory+0x71>
				cprintf(" ALLOCATED\n");
f01007ef:	83 ec 0c             	sub    $0xc,%esp
f01007f2:	68 07 5e 10 f0       	push   $0xf0105e07
f01007f7:	e8 4a 2f 00 00       	call   f0103746 <cprintf>
f01007fc:	83 c4 10             	add    $0x10,%esp
f01007ff:	eb 10                	jmp    f0100811 <mon_memory+0x81>
			else
				cprintf(" FREE\n");
f0100801:	83 ec 0c             	sub    $0xc,%esp
f0100804:	68 fa 5d 10 f0       	push   $0xf0105dfa
f0100809:	e8 38 2f 00 00       	call   f0103746 <cprintf>
f010080e:	83 c4 10             	add    $0x10,%esp
f0100811:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100814:	83 c0 01             	add    $0x1,%eax
}

int
mon_memory(int argc, char **argv, struct Trapframe *tf) {
	int i, start = 1, state_flag = 1, ref_flag = 0;
	for (i = 0; i < npages; i++) {
f0100817:	83 c3 01             	add    $0x1,%ebx
f010081a:	89 f7                	mov    %esi,%edi
f010081c:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
f010081f:	8b 15 98 e0 39 f0    	mov    0xf039e098,%edx
f0100825:	39 d3                	cmp    %edx,%ebx
f0100827:	72 81                	jb     f01007aa <mon_memory+0x1a>

			start = i + 1;
			state_flag = ref_flag;
		}
	}
	if (start != npages) {
f0100829:	39 d0                	cmp    %edx,%eax
f010082b:	74 2a                	je     f0100857 <mon_memory+0xc7>
		if (state_flag == 0)
f010082d:	85 ff                	test   %edi,%edi
f010082f:	75 14                	jne    f0100845 <mon_memory+0xb5>
			cprintf("%d..%d FREE\n", start, npages);
f0100831:	83 ec 04             	sub    $0x4,%esp
f0100834:	52                   	push   %edx
f0100835:	50                   	push   %eax
f0100836:	68 f4 5d 10 f0       	push   $0xf0105df4
f010083b:	e8 06 2f 00 00       	call   f0103746 <cprintf>
f0100840:	83 c4 10             	add    $0x10,%esp
f0100843:	eb 12                	jmp    f0100857 <mon_memory+0xc7>
		else
			cprintf("%d..%d ALLOCATED\n", start, npages);
f0100845:	83 ec 04             	sub    $0x4,%esp
f0100848:	52                   	push   %edx
f0100849:	50                   	push   %eax
f010084a:	68 01 5e 10 f0       	push   $0xf0105e01
f010084f:	e8 f2 2e 00 00       	call   f0103746 <cprintf>
f0100854:	83 c4 10             	add    $0x10,%esp
	}
	return 0;
}
f0100857:	b8 00 00 00 00       	mov    $0x0,%eax
f010085c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010085f:	5b                   	pop    %ebx
f0100860:	5e                   	pop    %esi
f0100861:	5f                   	pop    %edi
f0100862:	5d                   	pop    %ebp
f0100863:	c3                   	ret    

f0100864 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100864:	55                   	push   %ebp
f0100865:	89 e5                	mov    %esp,%ebp
f0100867:	57                   	push   %edi
f0100868:	56                   	push   %esi
f0100869:	53                   	push   %ebx
f010086a:	83 ec 48             	sub    $0x48,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f010086d:	89 ee                	mov    %ebp,%esi
	uint32_t ebp = read_ebp(), *ebp_pointer, eip;
	struct Eipdebuginfo dbg;	
	cprintf("Stack backtrace:\n");
f010086f:	68 13 5e 10 f0       	push   $0xf0105e13
f0100874:	e8 cd 2e 00 00       	call   f0103746 <cprintf>
	while (ebp) {
f0100879:	83 c4 10             	add    $0x10,%esp
f010087c:	eb 76                	jmp    f01008f4 <mon_backtrace+0x90>
		ebp_pointer = (uint32_t *)ebp;
f010087e:	89 75 c4             	mov    %esi,-0x3c(%ebp)
		eip = ebp_pointer[1];
f0100881:	8b 7e 04             	mov    0x4(%esi),%edi
		cprintf("  ebp  %08x  eip %08x  args ", ebp, eip);
f0100884:	83 ec 04             	sub    $0x4,%esp
f0100887:	57                   	push   %edi
f0100888:	56                   	push   %esi
f0100889:	68 25 5e 10 f0       	push   $0xf0105e25
f010088e:	e8 b3 2e 00 00       	call   f0103746 <cprintf>
f0100893:	8d 5e 08             	lea    0x8(%esi),%ebx
f0100896:	83 c6 18             	add    $0x18,%esi
f0100899:	83 c4 10             	add    $0x10,%esp
		int i;
		for (i = 2; i < 6; i++)
			cprintf(" %08x", ebp_pointer[i]);
f010089c:	83 ec 08             	sub    $0x8,%esp
f010089f:	ff 33                	pushl  (%ebx)
f01008a1:	68 42 5e 10 f0       	push   $0xf0105e42
f01008a6:	e8 9b 2e 00 00       	call   f0103746 <cprintf>
f01008ab:	83 c3 04             	add    $0x4,%ebx
	while (ebp) {
		ebp_pointer = (uint32_t *)ebp;
		eip = ebp_pointer[1];
		cprintf("  ebp  %08x  eip %08x  args ", ebp, eip);
		int i;
		for (i = 2; i < 6; i++)
f01008ae:	83 c4 10             	add    $0x10,%esp
f01008b1:	39 f3                	cmp    %esi,%ebx
f01008b3:	75 e7                	jne    f010089c <mon_backtrace+0x38>
			cprintf(" %08x", ebp_pointer[i]);
		cprintf("\n");
f01008b5:	83 ec 0c             	sub    $0xc,%esp
f01008b8:	68 1f 64 10 f0       	push   $0xf010641f
f01008bd:	e8 84 2e 00 00       	call   f0103746 <cprintf>
		debuginfo_eip(eip, &dbg);
f01008c2:	83 c4 08             	add    $0x8,%esp
f01008c5:	8d 45 d0             	lea    -0x30(%ebp),%eax
f01008c8:	50                   	push   %eax
f01008c9:	57                   	push   %edi
f01008ca:	e8 d9 3f 00 00       	call   f01048a8 <debuginfo_eip>
		cprintf("          %s:%d: %.*s+%d\n",
f01008cf:	83 c4 08             	add    $0x8,%esp
f01008d2:	2b 7d e0             	sub    -0x20(%ebp),%edi
f01008d5:	57                   	push   %edi
f01008d6:	ff 75 d8             	pushl  -0x28(%ebp)
f01008d9:	ff 75 dc             	pushl  -0x24(%ebp)
f01008dc:	ff 75 d4             	pushl  -0x2c(%ebp)
f01008df:	ff 75 d0             	pushl  -0x30(%ebp)
f01008e2:	68 48 5e 10 f0       	push   $0xf0105e48
f01008e7:	e8 5a 2e 00 00       	call   f0103746 <cprintf>
		    dbg.eip_file, dbg.eip_line, dbg.eip_fn_namelen, dbg.eip_fn_name, eip - dbg.eip_fn_addr);
		ebp = *ebp_pointer;
f01008ec:	8b 45 c4             	mov    -0x3c(%ebp),%eax
f01008ef:	8b 30                	mov    (%eax),%esi
f01008f1:	83 c4 20             	add    $0x20,%esp
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t ebp = read_ebp(), *ebp_pointer, eip;
	struct Eipdebuginfo dbg;	
	cprintf("Stack backtrace:\n");
	while (ebp) {
f01008f4:	85 f6                	test   %esi,%esi
f01008f6:	75 86                	jne    f010087e <mon_backtrace+0x1a>
		cprintf("          %s:%d: %.*s+%d\n",
		    dbg.eip_file, dbg.eip_line, dbg.eip_fn_namelen, dbg.eip_fn_name, eip - dbg.eip_fn_addr);
		ebp = *ebp_pointer;
	}
	return 0;
}
f01008f8:	b8 00 00 00 00       	mov    $0x0,%eax
f01008fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100900:	5b                   	pop    %ebx
f0100901:	5e                   	pop    %esi
f0100902:	5f                   	pop    %edi
f0100903:	5d                   	pop    %ebp
f0100904:	c3                   	ret    

f0100905 <mon_start>:
	return 0;
}

int
mon_start(int argc, char **argv, struct  Trapframe *tf)
{
f0100905:	55                   	push   %ebp
f0100906:	89 e5                	mov    %esp,%ebp
f0100908:	83 ec 08             	sub    $0x8,%esp
	timer_start();
f010090b:	e8 7c 4e 00 00       	call   f010578c <timer_start>
	return 0;
}
f0100910:	b8 00 00 00 00       	mov    $0x0,%eax
f0100915:	c9                   	leave  
f0100916:	c3                   	ret    

f0100917 <mon_stop>:

int
mon_stop(int argc, char **argv, struct  Trapframe *tf)
{
f0100917:	55                   	push   %ebp
f0100918:	89 e5                	mov    %esp,%ebp
f010091a:	83 ec 08             	sub    $0x8,%esp
	timer_stop();
f010091d:	e8 83 4e 00 00       	call   f01057a5 <timer_stop>
	return 0;
}
f0100922:	b8 00 00 00 00       	mov    $0x0,%eax
f0100927:	c9                   	leave  
f0100928:	c3                   	ret    

f0100929 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100929:	55                   	push   %ebp
f010092a:	89 e5                	mov    %esp,%ebp
f010092c:	57                   	push   %edi
f010092d:	56                   	push   %esi
f010092e:	53                   	push   %ebx
f010092f:	83 ec 58             	sub    $0x58,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100932:	68 28 60 10 f0       	push   $0xf0106028
f0100937:	e8 0a 2e 00 00       	call   f0103746 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f010093c:	c7 04 24 4c 60 10 f0 	movl   $0xf010604c,(%esp)
f0100943:	e8 fe 2d 00 00       	call   f0103746 <cprintf>

	if (tf != NULL)
f0100948:	83 c4 10             	add    $0x10,%esp
f010094b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f010094f:	74 0e                	je     f010095f <monitor+0x36>
		print_trapframe(tf);
f0100951:	83 ec 0c             	sub    $0xc,%esp
f0100954:	ff 75 08             	pushl  0x8(%ebp)
f0100957:	e8 87 32 00 00       	call   f0103be3 <print_trapframe>
f010095c:	83 c4 10             	add    $0x10,%esp

	while (1) {
		buf = readline("K> ");
f010095f:	83 ec 0c             	sub    $0xc,%esp
f0100962:	68 62 5e 10 f0       	push   $0xf0105e62
f0100967:	e8 a5 47 00 00       	call   f0105111 <readline>
f010096c:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f010096e:	83 c4 10             	add    $0x10,%esp
f0100971:	85 c0                	test   %eax,%eax
f0100973:	74 ea                	je     f010095f <monitor+0x36>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100975:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
f010097c:	be 00 00 00 00       	mov    $0x0,%esi
f0100981:	eb 0a                	jmp    f010098d <monitor+0x64>
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100983:	c6 03 00             	movb   $0x0,(%ebx)
f0100986:	89 f7                	mov    %esi,%edi
f0100988:	8d 5b 01             	lea    0x1(%ebx),%ebx
f010098b:	89 fe                	mov    %edi,%esi
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010098d:	0f b6 03             	movzbl (%ebx),%eax
f0100990:	84 c0                	test   %al,%al
f0100992:	74 63                	je     f01009f7 <monitor+0xce>
f0100994:	83 ec 08             	sub    $0x8,%esp
f0100997:	0f be c0             	movsbl %al,%eax
f010099a:	50                   	push   %eax
f010099b:	68 66 5e 10 f0       	push   $0xf0105e66
f01009a0:	e8 9e 49 00 00       	call   f0105343 <strchr>
f01009a5:	83 c4 10             	add    $0x10,%esp
f01009a8:	85 c0                	test   %eax,%eax
f01009aa:	75 d7                	jne    f0100983 <monitor+0x5a>
			*buf++ = 0;
		if (*buf == 0)
f01009ac:	80 3b 00             	cmpb   $0x0,(%ebx)
f01009af:	74 46                	je     f01009f7 <monitor+0xce>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f01009b1:	83 fe 0f             	cmp    $0xf,%esi
f01009b4:	75 14                	jne    f01009ca <monitor+0xa1>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009b6:	83 ec 08             	sub    $0x8,%esp
f01009b9:	6a 10                	push   $0x10
f01009bb:	68 6b 5e 10 f0       	push   $0xf0105e6b
f01009c0:	e8 81 2d 00 00       	call   f0103746 <cprintf>
f01009c5:	83 c4 10             	add    $0x10,%esp
f01009c8:	eb 95                	jmp    f010095f <monitor+0x36>
			return 0;
		}
		argv[argc++] = buf;
f01009ca:	8d 7e 01             	lea    0x1(%esi),%edi
f01009cd:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009d1:	eb 03                	jmp    f01009d6 <monitor+0xad>
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
f01009d3:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009d6:	0f b6 03             	movzbl (%ebx),%eax
f01009d9:	84 c0                	test   %al,%al
f01009db:	74 ae                	je     f010098b <monitor+0x62>
f01009dd:	83 ec 08             	sub    $0x8,%esp
f01009e0:	0f be c0             	movsbl %al,%eax
f01009e3:	50                   	push   %eax
f01009e4:	68 66 5e 10 f0       	push   $0xf0105e66
f01009e9:	e8 55 49 00 00       	call   f0105343 <strchr>
f01009ee:	83 c4 10             	add    $0x10,%esp
f01009f1:	85 c0                	test   %eax,%eax
f01009f3:	74 de                	je     f01009d3 <monitor+0xaa>
f01009f5:	eb 94                	jmp    f010098b <monitor+0x62>
			buf++;
	}
	argv[argc] = 0;
f01009f7:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009fe:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009ff:	85 f6                	test   %esi,%esi
f0100a01:	0f 84 58 ff ff ff    	je     f010095f <monitor+0x36>
f0100a07:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a0c:	83 ec 08             	sub    $0x8,%esp
f0100a0f:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a12:	ff 34 85 00 61 10 f0 	pushl  -0xfef9f00(,%eax,4)
f0100a19:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a1c:	e8 c4 48 00 00       	call   f01052e5 <strcmp>
f0100a21:	83 c4 10             	add    $0x10,%esp
f0100a24:	85 c0                	test   %eax,%eax
f0100a26:	75 22                	jne    f0100a4a <monitor+0x121>
			return commands[i].func(argc, argv, tf);
f0100a28:	83 ec 04             	sub    $0x4,%esp
f0100a2b:	8d 04 5b             	lea    (%ebx,%ebx,2),%eax
f0100a2e:	ff 75 08             	pushl  0x8(%ebp)
f0100a31:	8d 55 a8             	lea    -0x58(%ebp),%edx
f0100a34:	52                   	push   %edx
f0100a35:	56                   	push   %esi
f0100a36:	ff 14 85 08 61 10 f0 	call   *-0xfef9ef8(,%eax,4)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a3d:	83 c4 10             	add    $0x10,%esp
f0100a40:	85 c0                	test   %eax,%eax
f0100a42:	0f 89 17 ff ff ff    	jns    f010095f <monitor+0x36>
f0100a48:	eb 20                	jmp    f0100a6a <monitor+0x141>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a4a:	83 c3 01             	add    $0x1,%ebx
f0100a4d:	83 fb 07             	cmp    $0x7,%ebx
f0100a50:	75 ba                	jne    f0100a0c <monitor+0xe3>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a52:	83 ec 08             	sub    $0x8,%esp
f0100a55:	ff 75 a8             	pushl  -0x58(%ebp)
f0100a58:	68 88 5e 10 f0       	push   $0xf0105e88
f0100a5d:	e8 e4 2c 00 00       	call   f0103746 <cprintf>
f0100a62:	83 c4 10             	add    $0x10,%esp
f0100a65:	e9 f5 fe ff ff       	jmp    f010095f <monitor+0x36>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100a6d:	5b                   	pop    %ebx
f0100a6e:	5e                   	pop    %esi
f0100a6f:	5f                   	pop    %edi
f0100a70:	5d                   	pop    %ebp
f0100a71:	c3                   	ret    

f0100a72 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100a72:	89 c2                	mov    %eax,%edx
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100a74:	83 3d 98 d3 39 f0 00 	cmpl   $0x0,0xf039d398
f0100a7b:	75 0f                	jne    f0100a8c <boot_alloc+0x1a>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100a7d:	b8 2b f1 39 f0       	mov    $0xf039f12b,%eax
f0100a82:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100a87:	a3 98 d3 39 f0       	mov    %eax,0xf039d398
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 6: Your code here.
	result = nextfree;
f0100a8c:	a1 98 d3 39 f0       	mov    0xf039d398,%eax
	if (n > 0) {
f0100a91:	85 d2                	test   %edx,%edx
f0100a93:	74 3e                	je     f0100ad3 <boot_alloc+0x61>
		uint32_t alloc_size = ROUNDUP(n, PGSIZE);
f0100a95:	81 c2 ff 0f 00 00    	add    $0xfff,%edx
f0100a9b:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
		nextfree += alloc_size;
f0100aa1:	01 c2                	add    %eax,%edx
f0100aa3:	89 15 98 d3 39 f0    	mov    %edx,0xf039d398
		// Из-за того, что вначале выделяется
		// 4MB физической памяти.
		// Аллокатор памяти не может выделять за пределами памяти,
		// т.к свободной памяти нет
		if ((uintptr_t)nextfree >= KERNBASE + npages * PGSIZE) {
f0100aa9:	8b 0d 98 e0 39 f0    	mov    0xf039e098,%ecx
f0100aaf:	81 c1 00 00 0f 00    	add    $0xf0000,%ecx
f0100ab5:	c1 e1 0c             	shl    $0xc,%ecx
f0100ab8:	39 ca                	cmp    %ecx,%edx
f0100aba:	72 17                	jb     f0100ad3 <boot_alloc+0x61>
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100abc:	55                   	push   %ebp
f0100abd:	89 e5                	mov    %esp,%ebp
f0100abf:	83 ec 0c             	sub    $0xc,%esp
		// Из-за того, что вначале выделяется
		// 4MB физической памяти.
		// Аллокатор памяти не может выделять за пределами памяти,
		// т.к свободной памяти нет
		if ((uintptr_t)nextfree >= KERNBASE + npages * PGSIZE) {
		   panic("boot_alloc: out of memory");
f0100ac2:	68 54 61 10 f0       	push   $0xf0106154
f0100ac7:	6a 72                	push   $0x72
f0100ac9:	68 6e 61 10 f0       	push   $0xf010616e
f0100ace:	e8 1d f6 ff ff       	call   f01000f0 <_panic>
		}
	}

	return result;
}
f0100ad3:	f3 c3                	repz ret 

f0100ad5 <check_va2pa>:
static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
f0100ad5:	89 d1                	mov    %edx,%ecx
f0100ad7:	c1 e9 16             	shr    $0x16,%ecx
	if (!(*pgdir & PTE_P))
f0100ada:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100add:	a8 01                	test   $0x1,%al
f0100adf:	74 4f                	je     f0100b30 <check_va2pa+0x5b>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100ae1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ae6:	89 c1                	mov    %eax,%ecx
f0100ae8:	c1 e9 0c             	shr    $0xc,%ecx
f0100aeb:	3b 0d 98 e0 39 f0    	cmp    0xf039e098,%ecx
f0100af1:	72 1b                	jb     f0100b0e <check_va2pa+0x39>
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100af3:	55                   	push   %ebp
f0100af4:	89 e5                	mov    %esp,%ebp
f0100af6:	83 ec 08             	sub    $0x8,%esp
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0100af9:	50                   	push   %eax
f0100afa:	68 54 64 10 f0       	push   $0xf0106454
f0100aff:	68 6e 03 00 00       	push   $0x36e
f0100b04:	68 6e 61 10 f0       	push   $0xf010616e
f0100b09:	e8 e2 f5 ff ff       	call   f01000f0 <_panic>

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100b0e:	c1 ea 0c             	shr    $0xc,%edx
f0100b11:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100b17:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100b1e:	89 c2                	mov    %eax,%edx
f0100b20:	83 e2 01             	and    $0x1,%edx
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100b23:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b28:	83 fa 01             	cmp    $0x1,%edx
f0100b2b:	19 d2                	sbb    %edx,%edx
f0100b2d:	09 d0                	or     %edx,%eax
f0100b2f:	c3                   	ret    
{
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
		return ~0;
f0100b30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
}
f0100b35:	c3                   	ret    

f0100b36 <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100b36:	55                   	push   %ebp
f0100b37:	89 e5                	mov    %esp,%ebp
f0100b39:	57                   	push   %edi
f0100b3a:	56                   	push   %esi
f0100b3b:	53                   	push   %ebx
f0100b3c:	83 ec 2c             	sub    $0x2c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100b3f:	84 c0                	test   %al,%al
f0100b41:	0f 85 72 02 00 00    	jne    f0100db9 <check_page_free_list+0x283>
f0100b47:	e9 7f 02 00 00       	jmp    f0100dcb <check_page_free_list+0x295>
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
		panic("'page_free_list' is a null pointer!");
f0100b4c:	83 ec 04             	sub    $0x4,%esp
f0100b4f:	68 74 64 10 f0       	push   $0xf0106474
f0100b54:	68 ab 02 00 00       	push   $0x2ab
f0100b59:	68 6e 61 10 f0       	push   $0xf010616e
f0100b5e:	e8 8d f5 ff ff       	call   f01000f0 <_panic>

	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100b63:	8d 55 d8             	lea    -0x28(%ebp),%edx
f0100b66:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0100b69:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0100b6c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b6f:	89 c2                	mov    %eax,%edx
f0100b71:	2b 15 a0 e0 39 f0    	sub    0xf039e0a0,%edx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100b77:	f7 c2 00 e0 7f 00    	test   $0x7fe000,%edx
f0100b7d:	0f 95 c2             	setne  %dl
f0100b80:	0f b6 d2             	movzbl %dl,%edx
			*tp[pagetype] = pp;
f0100b83:	8b 4c 95 e0          	mov    -0x20(%ebp,%edx,4),%ecx
f0100b87:	89 01                	mov    %eax,(%ecx)
			tp[pagetype] = &pp->pp_link;
f0100b89:	89 44 95 e0          	mov    %eax,-0x20(%ebp,%edx,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100b8d:	8b 00                	mov    (%eax),%eax
f0100b8f:	85 c0                	test   %eax,%eax
f0100b91:	75 dc                	jne    f0100b6f <check_page_free_list+0x39>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100b93:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0100b96:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100b9c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0100b9f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0100ba2:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100ba4:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100ba7:	a3 a0 d3 39 f0       	mov    %eax,0xf039d3a0
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100bac:	be 01 00 00 00       	mov    $0x1,%esi
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100bb1:	8b 1d a0 d3 39 f0    	mov    0xf039d3a0,%ebx
f0100bb7:	eb 53                	jmp    f0100c0c <check_page_free_list+0xd6>
f0100bb9:	89 d8                	mov    %ebx,%eax
f0100bbb:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0100bc1:	c1 f8 03             	sar    $0x3,%eax
f0100bc4:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100bc7:	89 c2                	mov    %eax,%edx
f0100bc9:	c1 ea 16             	shr    $0x16,%edx
f0100bcc:	39 f2                	cmp    %esi,%edx
f0100bce:	73 3a                	jae    f0100c0a <check_page_free_list+0xd4>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bd0:	89 c2                	mov    %eax,%edx
f0100bd2:	c1 ea 0c             	shr    $0xc,%edx
f0100bd5:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f0100bdb:	72 12                	jb     f0100bef <check_page_free_list+0xb9>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0100bdd:	50                   	push   %eax
f0100bde:	68 54 64 10 f0       	push   $0xf0106454
f0100be3:	6a 58                	push   $0x58
f0100be5:	68 7a 61 10 f0       	push   $0xf010617a
f0100bea:	e8 01 f5 ff ff       	call   f01000f0 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100bef:	83 ec 04             	sub    $0x4,%esp
f0100bf2:	68 80 00 00 00       	push   $0x80
f0100bf7:	68 97 00 00 00       	push   $0x97
	return (void *)(pa + KERNBASE);
f0100bfc:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100c01:	50                   	push   %eax
f0100c02:	e8 79 47 00 00       	call   f0105380 <memset>
f0100c07:	83 c4 10             	add    $0x10,%esp
		page_free_list = pp1;
	}

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100c0a:	8b 1b                	mov    (%ebx),%ebx
f0100c0c:	85 db                	test   %ebx,%ebx
f0100c0e:	75 a9                	jne    f0100bb9 <check_page_free_list+0x83>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100c10:	b8 00 00 00 00       	mov    $0x0,%eax
f0100c15:	e8 58 fe ff ff       	call   f0100a72 <boot_alloc>
f0100c1a:	89 45 cc             	mov    %eax,-0x34(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c1d:	8b 15 a0 d3 39 f0    	mov    0xf039d3a0,%edx
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c23:	8b 0d a0 e0 39 f0    	mov    0xf039e0a0,%ecx
		assert(pp < pages + npages);
f0100c29:	a1 98 e0 39 f0       	mov    0xf039e098,%eax
f0100c2e:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100c31:	8d 3c c1             	lea    (%ecx,%eax,8),%edi
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c34:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
f0100c37:	be 00 00 00 00       	mov    $0x0,%esi
f0100c3c:	89 5d d0             	mov    %ebx,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100c3f:	e9 30 01 00 00       	jmp    f0100d74 <check_page_free_list+0x23e>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100c44:	39 ca                	cmp    %ecx,%edx
f0100c46:	73 19                	jae    f0100c61 <check_page_free_list+0x12b>
f0100c48:	68 88 61 10 f0       	push   $0xf0106188
f0100c4d:	68 94 61 10 f0       	push   $0xf0106194
f0100c52:	68 c5 02 00 00       	push   $0x2c5
f0100c57:	68 6e 61 10 f0       	push   $0xf010616e
f0100c5c:	e8 8f f4 ff ff       	call   f01000f0 <_panic>
		assert(pp < pages + npages);
f0100c61:	39 fa                	cmp    %edi,%edx
f0100c63:	72 19                	jb     f0100c7e <check_page_free_list+0x148>
f0100c65:	68 a9 61 10 f0       	push   $0xf01061a9
f0100c6a:	68 94 61 10 f0       	push   $0xf0106194
f0100c6f:	68 c6 02 00 00       	push   $0x2c6
f0100c74:	68 6e 61 10 f0       	push   $0xf010616e
f0100c79:	e8 72 f4 ff ff       	call   f01000f0 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100c7e:	89 d0                	mov    %edx,%eax
f0100c80:	2b 45 d4             	sub    -0x2c(%ebp),%eax
f0100c83:	a8 07                	test   $0x7,%al
f0100c85:	74 19                	je     f0100ca0 <check_page_free_list+0x16a>
f0100c87:	68 98 64 10 f0       	push   $0xf0106498
f0100c8c:	68 94 61 10 f0       	push   $0xf0106194
f0100c91:	68 c7 02 00 00       	push   $0x2c7
f0100c96:	68 6e 61 10 f0       	push   $0xf010616e
f0100c9b:	e8 50 f4 ff ff       	call   f01000f0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ca0:	c1 f8 03             	sar    $0x3,%eax
f0100ca3:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100ca6:	85 c0                	test   %eax,%eax
f0100ca8:	75 19                	jne    f0100cc3 <check_page_free_list+0x18d>
f0100caa:	68 bd 61 10 f0       	push   $0xf01061bd
f0100caf:	68 94 61 10 f0       	push   $0xf0106194
f0100cb4:	68 ca 02 00 00       	push   $0x2ca
f0100cb9:	68 6e 61 10 f0       	push   $0xf010616e
f0100cbe:	e8 2d f4 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100cc3:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100cc8:	75 19                	jne    f0100ce3 <check_page_free_list+0x1ad>
f0100cca:	68 ce 61 10 f0       	push   $0xf01061ce
f0100ccf:	68 94 61 10 f0       	push   $0xf0106194
f0100cd4:	68 cb 02 00 00       	push   $0x2cb
f0100cd9:	68 6e 61 10 f0       	push   $0xf010616e
f0100cde:	e8 0d f4 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100ce3:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100ce8:	75 19                	jne    f0100d03 <check_page_free_list+0x1cd>
f0100cea:	68 cc 64 10 f0       	push   $0xf01064cc
f0100cef:	68 94 61 10 f0       	push   $0xf0106194
f0100cf4:	68 cc 02 00 00       	push   $0x2cc
f0100cf9:	68 6e 61 10 f0       	push   $0xf010616e
f0100cfe:	e8 ed f3 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM);
f0100d03:	3d 00 00 10 00       	cmp    $0x100000,%eax
f0100d08:	75 19                	jne    f0100d23 <check_page_free_list+0x1ed>
f0100d0a:	68 e7 61 10 f0       	push   $0xf01061e7
f0100d0f:	68 94 61 10 f0       	push   $0xf0106194
f0100d14:	68 cd 02 00 00       	push   $0x2cd
f0100d19:	68 6e 61 10 f0       	push   $0xf010616e
f0100d1e:	e8 cd f3 ff ff       	call   f01000f0 <_panic>
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0100d23:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0100d28:	76 3f                	jbe    f0100d69 <check_page_free_list+0x233>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d2a:	89 c3                	mov    %eax,%ebx
f0100d2c:	c1 eb 0c             	shr    $0xc,%ebx
f0100d2f:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0100d32:	77 12                	ja     f0100d46 <check_page_free_list+0x210>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0100d34:	50                   	push   %eax
f0100d35:	68 54 64 10 f0       	push   $0xf0106454
f0100d3a:	6a 58                	push   $0x58
f0100d3c:	68 7a 61 10 f0       	push   $0xf010617a
f0100d41:	e8 aa f3 ff ff       	call   f01000f0 <_panic>
	return (void *)(pa + KERNBASE);
f0100d46:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100d4b:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0100d4e:	76 1e                	jbe    f0100d6e <check_page_free_list+0x238>
f0100d50:	68 f0 64 10 f0       	push   $0xf01064f0
f0100d55:	68 94 61 10 f0       	push   $0xf0106194
f0100d5a:	68 ce 02 00 00       	push   $0x2ce
f0100d5f:	68 6e 61 10 f0       	push   $0xf010616e
f0100d64:	e8 87 f3 ff ff       	call   f01000f0 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
			++nfree_basemem;
f0100d69:	83 c6 01             	add    $0x1,%esi
f0100d6c:	eb 04                	jmp    f0100d72 <check_page_free_list+0x23c>
		else
			++nfree_extmem;
f0100d6e:	83 45 d0 01          	addl   $0x1,-0x30(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100d72:	8b 12                	mov    (%edx),%edx
f0100d74:	85 d2                	test   %edx,%edx
f0100d76:	0f 85 c8 fe ff ff    	jne    f0100c44 <check_page_free_list+0x10e>
f0100d7c:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0100d7f:	85 f6                	test   %esi,%esi
f0100d81:	7f 19                	jg     f0100d9c <check_page_free_list+0x266>
f0100d83:	68 01 62 10 f0       	push   $0xf0106201
f0100d88:	68 94 61 10 f0       	push   $0xf0106194
f0100d8d:	68 d6 02 00 00       	push   $0x2d6
f0100d92:	68 6e 61 10 f0       	push   $0xf010616e
f0100d97:	e8 54 f3 ff ff       	call   f01000f0 <_panic>
	assert(nfree_extmem > 0);
f0100d9c:	85 db                	test   %ebx,%ebx
f0100d9e:	7f 42                	jg     f0100de2 <check_page_free_list+0x2ac>
f0100da0:	68 13 62 10 f0       	push   $0xf0106213
f0100da5:	68 94 61 10 f0       	push   $0xf0106194
f0100daa:	68 d7 02 00 00       	push   $0x2d7
f0100daf:	68 6e 61 10 f0       	push   $0xf010616e
f0100db4:	e8 37 f3 ff ff       	call   f01000f0 <_panic>
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100db9:	a1 a0 d3 39 f0       	mov    0xf039d3a0,%eax
f0100dbe:	85 c0                	test   %eax,%eax
f0100dc0:	0f 85 9d fd ff ff    	jne    f0100b63 <check_page_free_list+0x2d>
f0100dc6:	e9 81 fd ff ff       	jmp    f0100b4c <check_page_free_list+0x16>
f0100dcb:	83 3d a0 d3 39 f0 00 	cmpl   $0x0,0xf039d3a0
f0100dd2:	0f 84 74 fd ff ff    	je     f0100b4c <check_page_free_list+0x16>
//
static void
check_page_free_list(bool only_low_memory)
{
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100dd8:	be 00 04 00 00       	mov    $0x400,%esi
f0100ddd:	e9 cf fd ff ff       	jmp    f0100bb1 <check_page_free_list+0x7b>
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
	assert(nfree_extmem > 0);
}
f0100de2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100de5:	5b                   	pop    %ebx
f0100de6:	5e                   	pop    %esi
f0100de7:	5f                   	pop    %edi
f0100de8:	5d                   	pop    %ebp
f0100de9:	c3                   	ret    

f0100dea <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100dea:	55                   	push   %ebp
f0100deb:	89 e5                	mov    %esp,%ebp
f0100ded:	57                   	push   %edi
f0100dee:	56                   	push   %esi
f0100def:	53                   	push   %ebx
f0100df0:	83 ec 0c             	sub    $0xc,%esp
	size_t i;
	// Page 0 in use, so we start from 1
	// Adding reset of base memory to the page_free_list
	// IO hole should't be allocated
	// pages after boot_alloc() are ready in use
	size_t ext_mem = PGNUM(PADDR(boot_alloc(0)));
f0100df3:	b8 00 00 00 00       	mov    $0x0,%eax
f0100df8:	e8 75 fc ff ff       	call   f0100a72 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100dfd:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100e02:	77 15                	ja     f0100e19 <page_init+0x2f>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0100e04:	50                   	push   %eax
f0100e05:	68 38 65 10 f0       	push   $0xf0106538
f0100e0a:	68 2f 01 00 00       	push   $0x12f
f0100e0f:	68 6e 61 10 f0       	push   $0xf010616e
f0100e14:	e8 d7 f2 ff ff       	call   f01000f0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100e19:	05 00 00 00 10       	add    $0x10000000,%eax
f0100e1e:	c1 e8 0c             	shr    $0xc,%eax
	for (i = 1; i < npages; i++) {
		if (i < npages_basemem || i >= ext_mem) {
f0100e21:	8b 3d a4 d3 39 f0    	mov    0xf039d3a4,%edi
f0100e27:	8b 35 a0 d3 39 f0    	mov    0xf039d3a0,%esi
	// Page 0 in use, so we start from 1
	// Adding reset of base memory to the page_free_list
	// IO hole should't be allocated
	// pages after boot_alloc() are ready in use
	size_t ext_mem = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100e2d:	ba 01 00 00 00       	mov    $0x1,%edx
f0100e32:	eb 2a                	jmp    f0100e5e <page_init+0x74>
		if (i < npages_basemem || i >= ext_mem) {
f0100e34:	39 fa                	cmp    %edi,%edx
f0100e36:	72 04                	jb     f0100e3c <page_init+0x52>
f0100e38:	39 c2                	cmp    %eax,%edx
f0100e3a:	72 1f                	jb     f0100e5b <page_init+0x71>
f0100e3c:	8d 0c d5 00 00 00 00 	lea    0x0(,%edx,8),%ecx
			pages[i].pp_ref = 0;
f0100e43:	89 cb                	mov    %ecx,%ebx
f0100e45:	03 1d a0 e0 39 f0    	add    0xf039e0a0,%ebx
f0100e4b:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)
			pages[i].pp_link = page_free_list;
f0100e51:	89 33                	mov    %esi,(%ebx)
			page_free_list = &pages[i];
f0100e53:	89 ce                	mov    %ecx,%esi
f0100e55:	03 35 a0 e0 39 f0    	add    0xf039e0a0,%esi
	// Page 0 in use, so we start from 1
	// Adding reset of base memory to the page_free_list
	// IO hole should't be allocated
	// pages after boot_alloc() are ready in use
	size_t ext_mem = PGNUM(PADDR(boot_alloc(0)));
	for (i = 1; i < npages; i++) {
f0100e5b:	83 c2 01             	add    $0x1,%edx
f0100e5e:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f0100e64:	72 ce                	jb     f0100e34 <page_init+0x4a>
f0100e66:	89 35 a0 d3 39 f0    	mov    %esi,0xf039d3a0
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
	pages[0].pp_ref = 1;
f0100e6c:	8b 0d a0 e0 39 f0    	mov    0xf039e0a0,%ecx
f0100e72:	66 c7 41 04 01 00    	movw   $0x1,0x4(%ecx)
	for (i = npages_basemem; i < ext_mem; i++) {
f0100e78:	8b 15 a4 d3 39 f0    	mov    0xf039d3a4,%edx
f0100e7e:	eb 0a                	jmp    f0100e8a <page_init+0xa0>
		pages[i].pp_ref = 1;
f0100e80:	66 c7 44 d1 04 01 00 	movw   $0x1,0x4(%ecx,%edx,8)
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
		}
	}
	pages[0].pp_ref = 1;
	for (i = npages_basemem; i < ext_mem; i++) {
f0100e87:	83 c2 01             	add    $0x1,%edx
f0100e8a:	39 c2                	cmp    %eax,%edx
f0100e8c:	72 f2                	jb     f0100e80 <page_init+0x96>
		pages[i].pp_ref = 1;
	}

}
f0100e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0100e91:	5b                   	pop    %ebx
f0100e92:	5e                   	pop    %esi
f0100e93:	5f                   	pop    %edi
f0100e94:	5d                   	pop    %ebp
f0100e95:	c3                   	ret    

f0100e96 <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memsetff
struct PageInfo *
page_alloc(int alloc_flags)
{
f0100e96:	55                   	push   %ebp
f0100e97:	89 e5                	mov    %esp,%ebp
f0100e99:	53                   	push   %ebx
f0100e9a:	83 ec 04             	sub    $0x4,%esp
	// Fill this function in
	struct PageInfo *result = page_free_list;
f0100e9d:	8b 1d a0 d3 39 f0    	mov    0xf039d3a0,%ebx
	// If we out of memory return NULL
	if (!result) {
f0100ea3:	85 db                	test   %ebx,%ebx
f0100ea5:	74 5c                	je     f0100f03 <page_alloc+0x6d>
		return NULL;
	}
	page_free_list = result->pp_link;
f0100ea7:	8b 03                	mov    (%ebx),%eax
f0100ea9:	a3 a0 d3 39 f0       	mov    %eax,0xf039d3a0
	result->pp_link = NULL;
f0100eae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(result), 0, PGSIZE);
	return result;
f0100eb4:	89 d8                	mov    %ebx,%eax
	if (!result) {
		return NULL;
	}
	page_free_list = result->pp_link;
	result->pp_link = NULL;
	if (alloc_flags & ALLOC_ZERO) 
f0100eb6:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f0100eba:	74 4c                	je     f0100f08 <page_alloc+0x72>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100ebc:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0100ec2:	c1 f8 03             	sar    $0x3,%eax
f0100ec5:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ec8:	89 c2                	mov    %eax,%edx
f0100eca:	c1 ea 0c             	shr    $0xc,%edx
f0100ecd:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f0100ed3:	72 12                	jb     f0100ee7 <page_alloc+0x51>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0100ed5:	50                   	push   %eax
f0100ed6:	68 54 64 10 f0       	push   $0xf0106454
f0100edb:	6a 58                	push   $0x58
f0100edd:	68 7a 61 10 f0       	push   $0xf010617a
f0100ee2:	e8 09 f2 ff ff       	call   f01000f0 <_panic>
		memset(page2kva(result), 0, PGSIZE);
f0100ee7:	83 ec 04             	sub    $0x4,%esp
f0100eea:	68 00 10 00 00       	push   $0x1000
f0100eef:	6a 00                	push   $0x0
	return (void *)(pa + KERNBASE);
f0100ef1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ef6:	50                   	push   %eax
f0100ef7:	e8 84 44 00 00       	call   f0105380 <memset>
f0100efc:	83 c4 10             	add    $0x10,%esp
	return result;
f0100eff:	89 d8                	mov    %ebx,%eax
f0100f01:	eb 05                	jmp    f0100f08 <page_alloc+0x72>
{
	// Fill this function in
	struct PageInfo *result = page_free_list;
	// If we out of memory return NULL
	if (!result) {
		return NULL;
f0100f03:	b8 00 00 00 00       	mov    $0x0,%eax
	page_free_list = result->pp_link;
	result->pp_link = NULL;
	if (alloc_flags & ALLOC_ZERO) 
		memset(page2kva(result), 0, PGSIZE);
	return result;
}
f0100f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0100f0b:	c9                   	leave  
f0100f0c:	c3                   	ret    

f0100f0d <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100f0d:	55                   	push   %ebp
f0100f0e:	89 e5                	mov    %esp,%ebp
f0100f10:	83 ec 08             	sub    $0x8,%esp
f0100f13:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	// Hint: You may want to panic if pp->pp_ref is nonzero or
	// pp->pp_link is not NULL.
	if (pp->pp_ref != 0 || pp->pp_link != NULL) {
f0100f16:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100f1b:	75 05                	jne    f0100f22 <page_free+0x15>
f0100f1d:	83 38 00             	cmpl   $0x0,(%eax)
f0100f20:	74 17                	je     f0100f39 <page_free+0x2c>
		panic("pp->pp_ref is nonzero or pp->pp_ref is not NULL");
f0100f22:	83 ec 04             	sub    $0x4,%esp
f0100f25:	68 5c 65 10 f0       	push   $0xf010655c
f0100f2a:	68 65 01 00 00       	push   $0x165
f0100f2f:	68 6e 61 10 f0       	push   $0xf010616e
f0100f34:	e8 b7 f1 ff ff       	call   f01000f0 <_panic>
	}
	pp->pp_link = page_free_list;
f0100f39:	8b 15 a0 d3 39 f0    	mov    0xf039d3a0,%edx
f0100f3f:	89 10                	mov    %edx,(%eax)
	page_free_list = pp;
f0100f41:	a3 a0 d3 39 f0       	mov    %eax,0xf039d3a0
}
f0100f46:	c9                   	leave  
f0100f47:	c3                   	ret    

f0100f48 <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{
f0100f48:	55                   	push   %ebp
f0100f49:	89 e5                	mov    %esp,%ebp
f0100f4b:	83 ec 08             	sub    $0x8,%esp
f0100f4e:	8b 55 08             	mov    0x8(%ebp),%edx
	if (--pp->pp_ref == 0)
f0100f51:	0f b7 42 04          	movzwl 0x4(%edx),%eax
f0100f55:	83 e8 01             	sub    $0x1,%eax
f0100f58:	66 89 42 04          	mov    %ax,0x4(%edx)
f0100f5c:	66 85 c0             	test   %ax,%ax
f0100f5f:	75 0c                	jne    f0100f6d <page_decref+0x25>
		page_free(pp);
f0100f61:	83 ec 0c             	sub    $0xc,%esp
f0100f64:	52                   	push   %edx
f0100f65:	e8 a3 ff ff ff       	call   f0100f0d <page_free>
f0100f6a:	83 c4 10             	add    $0x10,%esp
}
f0100f6d:	c9                   	leave  
f0100f6e:	c3                   	ret    

f0100f6f <pgdir_walk>:

// По указателю на каталог страниц (pgdir) возвращает запись в таблице 
// страниц для адреса va.
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100f6f:	55                   	push   %ebp
f0100f70:	89 e5                	mov    %esp,%ebp
f0100f72:	56                   	push   %esi
f0100f73:	53                   	push   %ebx
f0100f74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// Fill this function in
	// С помощью PDX мы получаем индекс страницы для таблицы страниц
	int pde_t = PDX(va);
	// С помощью PTX мы получаем индекс таблицы страниц
	int pte_t_num = PTX(va);
f0100f77:	89 de                	mov    %ebx,%esi
f0100f79:	c1 ee 0c             	shr    $0xc,%esi
f0100f7c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
	// Fill this function in
	// С помощью PDX мы получаем индекс страницы для таблицы страниц
	int pde_t = PDX(va);
f0100f82:	c1 eb 16             	shr    $0x16,%ebx
	// С помощью PTX мы получаем индекс таблицы страниц
	int pte_t_num = PTX(va);
	// PTE_P это Page Table Entry флаг, который отвечает за присутствие
	// Если PDE не существует
	if (!(pgdir[pde_t] & PTE_P)) {
f0100f85:	c1 e3 02             	shl    $0x2,%ebx
f0100f88:	03 5d 08             	add    0x8(%ebp),%ebx
f0100f8b:	f6 03 01             	testb  $0x1,(%ebx)
f0100f8e:	75 2d                	jne    f0100fbd <pgdir_walk+0x4e>
		if (create) {
f0100f90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f0100f94:	74 59                	je     f0100fef <pgdir_walk+0x80>
			// Пробуем разместить пустую(заполненную нулями) страницу
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);
f0100f96:	83 ec 0c             	sub    $0xc,%esp
f0100f99:	6a 01                	push   $0x1
f0100f9b:	e8 f6 fe ff ff       	call   f0100e96 <page_alloc>
			// Размещение не удалось (мало памяти)
			if (!pg) { 
f0100fa0:	83 c4 10             	add    $0x10,%esp
f0100fa3:	85 c0                	test   %eax,%eax
f0100fa5:	74 4f                	je     f0100ff6 <pgdir_walk+0x87>
				return NULL;
			} else {
				// Увеличиваем счетчик ссылок на страницу
				pg->pp_ref++;
f0100fa7:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100fac:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0100fb2:	c1 f8 03             	sar    $0x3,%eax
f0100fb5:	c1 e0 0c             	shl    $0xc,%eax
				// С помощью page2pa() получаемя физический адрес нашей 
				// выделенной страницы и выставляем там нужные флаги
				pgdir[pde_t] = page2pa(pg) | PTE_P | PTE_W | PTE_U;
f0100fb8:	83 c8 07             	or     $0x7,%eax
f0100fbb:	89 03                	mov    %eax,(%ebx)
			}
		} else {
			return NULL;
		}
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[pde_t]));
f0100fbd:	8b 03                	mov    (%ebx),%eax
f0100fbf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100fc4:	89 c2                	mov    %eax,%edx
f0100fc6:	c1 ea 0c             	shr    $0xc,%edx
f0100fc9:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f0100fcf:	72 15                	jb     f0100fe6 <pgdir_walk+0x77>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0100fd1:	50                   	push   %eax
f0100fd2:	68 54 64 10 f0       	push   $0xf0106454
f0100fd7:	68 aa 01 00 00       	push   $0x1aa
f0100fdc:	68 6e 61 10 f0       	push   $0xf010616e
f0100fe1:	e8 0a f1 ff ff       	call   f01000f0 <_panic>

	return p + pte_t_num;
f0100fe6:	8d 84 b0 00 00 00 f0 	lea    -0x10000000(%eax,%esi,4),%eax
f0100fed:	eb 0c                	jmp    f0100ffb <pgdir_walk+0x8c>
				// С помощью page2pa() получаемя физический адрес нашей 
				// выделенной страницы и выставляем там нужные флаги
				pgdir[pde_t] = page2pa(pg) | PTE_P | PTE_W | PTE_U;
			}
		} else {
			return NULL;
f0100fef:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ff4:	eb 05                	jmp    f0100ffb <pgdir_walk+0x8c>
		if (create) {
			// Пробуем разместить пустую(заполненную нулями) страницу
			struct PageInfo *pg = page_alloc(ALLOC_ZERO);
			// Размещение не удалось (мало памяти)
			if (!pg) { 
				return NULL;
f0100ff6:	b8 00 00 00 00       	mov    $0x0,%eax
		}
	}
	pte_t *p = KADDR(PTE_ADDR(pgdir[pde_t]));

	return p + pte_t_num;
}
f0100ffb:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0100ffe:	5b                   	pop    %ebx
f0100fff:	5e                   	pop    %esi
f0101000:	5d                   	pop    %ebp
f0101001:	c3                   	ret    

f0101002 <boot_map_region>:

// Отображает виртуальные адреса [va,va+size) по физическим [pa,pa+size)
// в каталоге страниц pgdir.
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f0101002:	55                   	push   %ebp
f0101003:	89 e5                	mov    %esp,%ebp
f0101005:	57                   	push   %edi
f0101006:	56                   	push   %esi
f0101007:	53                   	push   %ebx
f0101008:	83 ec 1c             	sub    $0x1c,%esp
f010100b:	89 c7                	mov    %eax,%edi
f010100d:	89 d6                	mov    %edx,%esi
f010100f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	// Fill this function in
	uint32_t i = 0;
f0101012:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101017:	8b 45 0c             	mov    0xc(%ebp),%eax
f010101a:	83 c8 01             	or     $0x1,%eax
f010101d:	89 45 e0             	mov    %eax,-0x20(%ebp)
	for (; i < size; i += PGSIZE) {
f0101020:	eb 22                	jmp    f0101044 <boot_map_region+0x42>
		//C помощью pgdir_walk() получаем запись pte_t из каталога страниц по адресу (va + i)
		pte_t *pte = pgdir_walk(pgdir, (void *)va + i, 1);
f0101022:	83 ec 04             	sub    $0x4,%esp
f0101025:	6a 01                	push   $0x1
f0101027:	8d 04 33             	lea    (%ebx,%esi,1),%eax
f010102a:	50                   	push   %eax
f010102b:	57                   	push   %edi
f010102c:	e8 3e ff ff ff       	call   f0100f6f <pgdir_walk>
f0101031:	89 da                	mov    %ebx,%edx
f0101033:	03 55 08             	add    0x8(%ebp),%edx
		*pte = (pa + i) | perm | PTE_P;
f0101036:	0b 55 e0             	or     -0x20(%ebp),%edx
f0101039:	89 10                	mov    %edx,(%eax)
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
	// Fill this function in
	uint32_t i = 0;
	for (; i < size; i += PGSIZE) {
f010103b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101041:	83 c4 10             	add    $0x10,%esp
f0101044:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0101047:	72 d9                	jb     f0101022 <boot_map_region+0x20>
		//C помощью pgdir_walk() получаем запись pte_t из каталога страниц по адресу (va + i)
		pte_t *pte = pgdir_walk(pgdir, (void *)va + i, 1);
		*pte = (pa + i) | perm | PTE_P;
	}
}
f0101049:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010104c:	5b                   	pop    %ebx
f010104d:	5e                   	pop    %esi
f010104e:	5f                   	pop    %edi
f010104f:	5d                   	pop    %ebp
f0101050:	c3                   	ret    

f0101051 <page_lookup>:
//

// Возвращает страницу, отображенную по адресу va.
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101051:	55                   	push   %ebp
f0101052:	89 e5                	mov    %esp,%ebp
f0101054:	53                   	push   %ebx
f0101055:	83 ec 08             	sub    $0x8,%esp
f0101058:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
f010105b:	6a 00                	push   $0x0
f010105d:	ff 75 0c             	pushl  0xc(%ebp)
f0101060:	ff 75 08             	pushl  0x8(%ebp)
f0101063:	e8 07 ff ff ff       	call   f0100f6f <pgdir_walk>
	if (pte_store)
f0101068:	83 c4 10             	add    $0x10,%esp
f010106b:	85 db                	test   %ebx,%ebx
f010106d:	74 02                	je     f0101071 <page_lookup+0x20>
		*pte_store = pte;
f010106f:	89 03                	mov    %eax,(%ebx)
	if (!pte || !(*pte & PTE_P)) return NULL;
f0101071:	85 c0                	test   %eax,%eax
f0101073:	74 30                	je     f01010a5 <page_lookup+0x54>
f0101075:	8b 00                	mov    (%eax),%eax
f0101077:	a8 01                	test   $0x1,%al
f0101079:	74 31                	je     f01010ac <page_lookup+0x5b>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010107b:	c1 e8 0c             	shr    $0xc,%eax
f010107e:	3b 05 98 e0 39 f0    	cmp    0xf039e098,%eax
f0101084:	72 14                	jb     f010109a <page_lookup+0x49>
		panic("pa2page called with invalid pa");
f0101086:	83 ec 04             	sub    $0x4,%esp
f0101089:	68 8c 65 10 f0       	push   $0xf010658c
f010108e:	6a 51                	push   $0x51
f0101090:	68 7a 61 10 f0       	push   $0xf010617a
f0101095:	e8 56 f0 ff ff       	call   f01000f0 <_panic>
	return &pages[PGNUM(pa)];
f010109a:	8b 15 a0 e0 39 f0    	mov    0xf039e0a0,%edx
f01010a0:	8d 04 c2             	lea    (%edx,%eax,8),%eax
	
	return pa2page(PTE_ADDR(*pte));	
f01010a3:	eb 0c                	jmp    f01010b1 <page_lookup+0x60>
{
	// Fill this function in
	pte_t *pte = pgdir_walk(pgdir, va, 0);
	if (pte_store)
		*pte_store = pte;
	if (!pte || !(*pte & PTE_P)) return NULL;
f01010a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01010aa:	eb 05                	jmp    f01010b1 <page_lookup+0x60>
f01010ac:	b8 00 00 00 00       	mov    $0x0,%eax
	
	return pa2page(PTE_ADDR(*pte));	
}
f01010b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f01010b4:	c9                   	leave  
f01010b5:	c3                   	ret    

f01010b6 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f01010b6:	55                   	push   %ebp
f01010b7:	89 e5                	mov    %esp,%ebp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f01010b9:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f01010be:	85 c0                	test   %eax,%eax
f01010c0:	74 08                	je     f01010ca <tlb_invalidate+0x14>
f01010c2:	8b 55 08             	mov    0x8(%ebp),%edx
f01010c5:	39 50 5c             	cmp    %edx,0x5c(%eax)
f01010c8:	75 06                	jne    f01010d0 <tlb_invalidate+0x1a>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f01010ca:	8b 45 0c             	mov    0xc(%ebp),%eax
f01010cd:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f01010d0:	5d                   	pop    %ebp
f01010d1:	c3                   	ret    

f01010d2 <page_remove>:
//

// Удаляет отображение физической страницы по адресу va.
void
page_remove(pde_t *pgdir, void *va)
{
f01010d2:	55                   	push   %ebp
f01010d3:	89 e5                	mov    %esp,%ebp
f01010d5:	56                   	push   %esi
f01010d6:	53                   	push   %ebx
f01010d7:	83 ec 14             	sub    $0x14,%esp
f01010da:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01010dd:	8b 75 0c             	mov    0xc(%ebp),%esi
	// Fill this function in
	pte_t *pte;
	struct PageInfo *pg = page_lookup(pgdir, va, &pte);
f01010e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
f01010e3:	50                   	push   %eax
f01010e4:	56                   	push   %esi
f01010e5:	53                   	push   %ebx
f01010e6:	e8 66 ff ff ff       	call   f0101051 <page_lookup>
	if (!pg || !(*pte & PTE_P)) return;	//Страница не существует
f01010eb:	83 c4 10             	add    $0x10,%esp
f01010ee:	85 c0                	test   %eax,%eax
f01010f0:	74 27                	je     f0101119 <page_remove+0x47>
f01010f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
f01010f5:	f6 02 01             	testb  $0x1,(%edx)
f01010f8:	74 1f                	je     f0101119 <page_remove+0x47>
	//   - The ref count on the physical page should decrement.
	//   - The physical page should be freed if the refcount reaches 0.
	page_decref(pg);
f01010fa:	83 ec 0c             	sub    $0xc,%esp
f01010fd:	50                   	push   %eax
f01010fe:	e8 45 fe ff ff       	call   f0100f48 <page_decref>
	//   - The pg table entry corresponding to 'va' should be set to 0.
	*pte = 0;
f0101103:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0101106:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	//   - The TLB must be invalidated if you remove an entry from
	//     the page table.
	tlb_invalidate(pgdir, va);
f010110c:	83 c4 08             	add    $0x8,%esp
f010110f:	56                   	push   %esi
f0101110:	53                   	push   %ebx
f0101111:	e8 a0 ff ff ff       	call   f01010b6 <tlb_invalidate>
f0101116:	83 c4 10             	add    $0x10,%esp
}
f0101119:	8d 65 f8             	lea    -0x8(%ebp),%esp
f010111c:	5b                   	pop    %ebx
f010111d:	5e                   	pop    %esi
f010111e:	5d                   	pop    %ebp
f010111f:	c3                   	ret    

f0101120 <page_insert>:
// and page2pa.
//
// Отображает физическую страницу pp по адресу va.
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0101120:	55                   	push   %ebp
f0101121:	89 e5                	mov    %esp,%ebp
f0101123:	57                   	push   %edi
f0101124:	56                   	push   %esi
f0101125:	53                   	push   %ebx
f0101126:	83 ec 10             	sub    $0x10,%esp
f0101129:	8b 75 0c             	mov    0xc(%ebp),%esi
f010112c:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function in
	// Если необходимо, таблица страниц должна быть выделена и добавлена в pgdir
	pte_t *pte = pgdir_walk(pgdir, va, 1);
f010112f:	6a 01                	push   $0x1
f0101131:	57                   	push   %edi
f0101132:	ff 75 08             	pushl  0x8(%ebp)
f0101135:	e8 35 fe ff ff       	call   f0100f6f <pgdir_walk>
f010113a:	89 c3                	mov    %eax,%ebx
	// Page table not allocated
	if (!pte) 
f010113c:	83 c4 10             	add    $0x10,%esp
f010113f:	85 c0                	test   %eax,%eax
f0101141:	74 38                	je     f010117b <page_insert+0x5b>
		return -E_NO_MEM;	
	// Счетчик ссылок должен быть увеличен.
	pp->pp_ref++;
f0101143:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	// Если страница по этому адресу уже отображена, 
	// она должна быть удалена с помощью page_remove().	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
f0101148:	f6 00 01             	testb  $0x1,(%eax)
f010114b:	74 0f                	je     f010115c <page_insert+0x3c>
		page_remove(pgdir, va);
f010114d:	83 ec 08             	sub    $0x8,%esp
f0101150:	57                   	push   %edi
f0101151:	ff 75 08             	pushl  0x8(%ebp)
f0101154:	e8 79 ff ff ff       	call   f01010d2 <page_remove>
f0101159:	83 c4 10             	add    $0x10,%esp
f010115c:	8b 55 14             	mov    0x14(%ebp),%edx
f010115f:	83 ca 01             	or     $0x1,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101162:	89 f0                	mov    %esi,%eax
f0101164:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f010116a:	c1 f8 03             	sar    $0x3,%eax
f010116d:	c1 e0 0c             	shl    $0xc,%eax
	*pte = page2pa(pp) | perm | PTE_P;
f0101170:	09 d0                	or     %edx,%eax
f0101172:	89 03                	mov    %eax,(%ebx)
	return 0;
f0101174:	b8 00 00 00 00       	mov    $0x0,%eax
f0101179:	eb 05                	jmp    f0101180 <page_insert+0x60>
	// Fill this function in
	// Если необходимо, таблица страниц должна быть выделена и добавлена в pgdir
	pte_t *pte = pgdir_walk(pgdir, va, 1);
	// Page table not allocated
	if (!pte) 
		return -E_NO_MEM;	
f010117b:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	// она должна быть удалена с помощью page_remove().	
	if (*pte & PTE_P) 	//page colides, tle is invalidated in page_remove
		page_remove(pgdir, va);
	*pte = page2pa(pp) | perm | PTE_P;
	return 0;
}
f0101180:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0101183:	5b                   	pop    %ebx
f0101184:	5e                   	pop    %esi
f0101185:	5f                   	pop    %edi
f0101186:	5d                   	pop    %ebp
f0101187:	c3                   	ret    

f0101188 <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f0101188:	55                   	push   %ebp
f0101189:	89 e5                	mov    %esp,%ebp
f010118b:	57                   	push   %edi
f010118c:	56                   	push   %esi
f010118d:	53                   	push   %ebx
f010118e:	83 ec 38             	sub    $0x38,%esp
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0101191:	6a 15                	push   $0x15
f0101193:	e8 22 24 00 00       	call   f01035ba <mc146818_read>
f0101198:	89 c3                	mov    %eax,%ebx
f010119a:	c7 04 24 16 00 00 00 	movl   $0x16,(%esp)
f01011a1:	e8 14 24 00 00       	call   f01035ba <mc146818_read>
f01011a6:	c1 e0 08             	shl    $0x8,%eax
f01011a9:	09 d8                	or     %ebx,%eax
{
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f01011ab:	c1 e0 0a             	shl    $0xa,%eax
f01011ae:	99                   	cltd   
f01011af:	c1 ea 14             	shr    $0x14,%edx
f01011b2:	01 d0                	add    %edx,%eax
f01011b4:	c1 f8 0c             	sar    $0xc,%eax
f01011b7:	a3 a4 d3 39 f0       	mov    %eax,0xf039d3a4
// --------------------------------------------------------------

static int
nvram_read(int r)
{
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f01011bc:	c7 04 24 17 00 00 00 	movl   $0x17,(%esp)
f01011c3:	e8 f2 23 00 00       	call   f01035ba <mc146818_read>
f01011c8:	89 c3                	mov    %eax,%ebx
f01011ca:	c7 04 24 18 00 00 00 	movl   $0x18,(%esp)
f01011d1:	e8 e4 23 00 00       	call   f01035ba <mc146818_read>
f01011d6:	c1 e0 08             	shl    $0x8,%eax
f01011d9:	09 d8                	or     %ebx,%eax
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f01011db:	c1 e0 0a             	shl    $0xa,%eax
f01011de:	99                   	cltd   
f01011df:	c1 ea 14             	shr    $0x14,%edx
f01011e2:	01 d0                	add    %edx,%eax
f01011e4:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f01011e7:	83 c4 10             	add    $0x10,%esp
f01011ea:	85 c0                	test   %eax,%eax
f01011ec:	74 0e                	je     f01011fc <mem_init+0x74>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f01011ee:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f01011f4:	89 15 98 e0 39 f0    	mov    %edx,0xf039e098
f01011fa:	eb 0c                	jmp    f0101208 <mem_init+0x80>
	else
		npages = npages_basemem;
f01011fc:	8b 15 a4 d3 39 f0    	mov    0xf039d3a4,%edx
f0101202:	89 15 98 e0 39 f0    	mov    %edx,0xf039e098

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
f0101208:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f010120b:	c1 e8 0a             	shr    $0xa,%eax
f010120e:	50                   	push   %eax
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
f010120f:	a1 a4 d3 39 f0       	mov    0xf039d3a4,%eax
f0101214:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101217:	c1 e8 0a             	shr    $0xa,%eax
f010121a:	50                   	push   %eax
		npages * PGSIZE / 1024,
f010121b:	a1 98 e0 39 f0       	mov    0xf039e098,%eax
f0101220:	c1 e0 0c             	shl    $0xc,%eax
	if (npages_extmem)
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
	else
		npages = npages_basemem;

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0101223:	c1 e8 0a             	shr    $0xa,%eax
f0101226:	50                   	push   %eax
f0101227:	68 ac 65 10 f0       	push   $0xf01065ac
f010122c:	e8 15 25 00 00       	call   f0103746 <cprintf>
	// Remove this line when you're ready to test this function.
	// panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f0101231:	b8 00 10 00 00       	mov    $0x1000,%eax
f0101236:	e8 37 f8 ff ff       	call   f0100a72 <boot_alloc>
f010123b:	a3 9c e0 39 f0       	mov    %eax,0xf039e09c
	memset(kern_pgdir, 0, PGSIZE);
f0101240:	83 c4 0c             	add    $0xc,%esp
f0101243:	68 00 10 00 00       	push   $0x1000
f0101248:	6a 00                	push   $0x0
f010124a:	50                   	push   %eax
f010124b:	e8 30 41 00 00       	call   f0105380 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f0101250:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101255:	83 c4 10             	add    $0x10,%esp
f0101258:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010125d:	77 15                	ja     f0101274 <mem_init+0xec>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f010125f:	50                   	push   %eax
f0101260:	68 38 65 10 f0       	push   $0xf0106538
f0101265:	68 97 00 00 00       	push   $0x97
f010126a:	68 6e 61 10 f0       	push   $0xf010616e
f010126f:	e8 7c ee ff ff       	call   f01000f0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0101274:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f010127a:	83 ca 05             	or     $0x5,%edx
f010127d:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.  Use memset
	// to initialize all fields of each struct PageInfo to 0.
	// Your code goes here:
	pages = (struct PageInfo *) boot_alloc(npages * sizeof(struct PageInfo));
f0101283:	a1 98 e0 39 f0       	mov    0xf039e098,%eax
f0101288:	c1 e0 03             	shl    $0x3,%eax
f010128b:	e8 e2 f7 ff ff       	call   f0100a72 <boot_alloc>
f0101290:	a3 a0 e0 39 f0       	mov    %eax,0xf039e0a0
 	memset(pages, 0, npages * sizeof(struct PageInfo));
f0101295:	83 ec 04             	sub    $0x4,%esp
f0101298:	8b 3d 98 e0 39 f0    	mov    0xf039e098,%edi
f010129e:	8d 14 fd 00 00 00 00 	lea    0x0(,%edi,8),%edx
f01012a5:	52                   	push   %edx
f01012a6:	6a 00                	push   $0x0
f01012a8:	50                   	push   %eax
f01012a9:	e8 d2 40 00 00       	call   f0105380 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 8: Your code here.
 	envs = (struct Env *) boot_alloc(sizeof(struct Env) * NENV);
f01012ae:	b8 00 e0 01 00       	mov    $0x1e000,%eax
f01012b3:	e8 ba f7 ff ff       	call   f0100a72 <boot_alloc>
f01012b8:	a3 ac d3 39 f0       	mov    %eax,0xf039d3ac
 	memset(pages, 0,  NENV * sizeof(struct Env));
f01012bd:	83 c4 0c             	add    $0xc,%esp
f01012c0:	68 00 e0 01 00       	push   $0x1e000
f01012c5:	6a 00                	push   $0x0
f01012c7:	ff 35 a0 e0 39 f0    	pushl  0xf039e0a0
f01012cd:	e8 ae 40 00 00       	call   f0105380 <memset>

	//////////////////////////////////////////////////////////////////////
	// Make 'vsys' point to an array of size 'NVSYSCALLS' of int.
	// LAB 12: Your code here.

 	vsys = boot_alloc(NVSYSCALLS * sizeof(int));
f01012d2:	b8 04 00 00 00       	mov    $0x4,%eax
f01012d7:	e8 96 f7 ff ff       	call   f0100a72 <boot_alloc>
f01012dc:	a3 94 e0 39 f0       	mov    %eax,0xf039e094
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f01012e1:	e8 04 fb ff ff       	call   f0100dea <page_init>

	check_page_free_list(1);
f01012e6:	b8 01 00 00 00       	mov    $0x1,%eax
f01012eb:	e8 46 f8 ff ff       	call   f0100b36 <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f01012f0:	83 c4 10             	add    $0x10,%esp
f01012f3:	83 3d a0 e0 39 f0 00 	cmpl   $0x0,0xf039e0a0
f01012fa:	75 17                	jne    f0101313 <mem_init+0x18b>
		panic("'pages' is a null pointer!");
f01012fc:	83 ec 04             	sub    $0x4,%esp
f01012ff:	68 24 62 10 f0       	push   $0xf0106224
f0101304:	68 e8 02 00 00       	push   $0x2e8
f0101309:	68 6e 61 10 f0       	push   $0xf010616e
f010130e:	e8 dd ed ff ff       	call   f01000f0 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101313:	a1 a0 d3 39 f0       	mov    0xf039d3a0,%eax
f0101318:	bb 00 00 00 00       	mov    $0x0,%ebx
f010131d:	eb 05                	jmp    f0101324 <mem_init+0x19c>
		++nfree;
f010131f:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101322:	8b 00                	mov    (%eax),%eax
f0101324:	85 c0                	test   %eax,%eax
f0101326:	75 f7                	jne    f010131f <mem_init+0x197>
		++nfree;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101328:	83 ec 0c             	sub    $0xc,%esp
f010132b:	6a 00                	push   $0x0
f010132d:	e8 64 fb ff ff       	call   f0100e96 <page_alloc>
f0101332:	89 c7                	mov    %eax,%edi
f0101334:	83 c4 10             	add    $0x10,%esp
f0101337:	85 c0                	test   %eax,%eax
f0101339:	75 19                	jne    f0101354 <mem_init+0x1cc>
f010133b:	68 3f 62 10 f0       	push   $0xf010623f
f0101340:	68 94 61 10 f0       	push   $0xf0106194
f0101345:	68 f0 02 00 00       	push   $0x2f0
f010134a:	68 6e 61 10 f0       	push   $0xf010616e
f010134f:	e8 9c ed ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f0101354:	83 ec 0c             	sub    $0xc,%esp
f0101357:	6a 00                	push   $0x0
f0101359:	e8 38 fb ff ff       	call   f0100e96 <page_alloc>
f010135e:	89 c6                	mov    %eax,%esi
f0101360:	83 c4 10             	add    $0x10,%esp
f0101363:	85 c0                	test   %eax,%eax
f0101365:	75 19                	jne    f0101380 <mem_init+0x1f8>
f0101367:	68 55 62 10 f0       	push   $0xf0106255
f010136c:	68 94 61 10 f0       	push   $0xf0106194
f0101371:	68 f1 02 00 00       	push   $0x2f1
f0101376:	68 6e 61 10 f0       	push   $0xf010616e
f010137b:	e8 70 ed ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101380:	83 ec 0c             	sub    $0xc,%esp
f0101383:	6a 00                	push   $0x0
f0101385:	e8 0c fb ff ff       	call   f0100e96 <page_alloc>
f010138a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010138d:	83 c4 10             	add    $0x10,%esp
f0101390:	85 c0                	test   %eax,%eax
f0101392:	75 19                	jne    f01013ad <mem_init+0x225>
f0101394:	68 6b 62 10 f0       	push   $0xf010626b
f0101399:	68 94 61 10 f0       	push   $0xf0106194
f010139e:	68 f2 02 00 00       	push   $0x2f2
f01013a3:	68 6e 61 10 f0       	push   $0xf010616e
f01013a8:	e8 43 ed ff ff       	call   f01000f0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f01013ad:	39 f7                	cmp    %esi,%edi
f01013af:	75 19                	jne    f01013ca <mem_init+0x242>
f01013b1:	68 81 62 10 f0       	push   $0xf0106281
f01013b6:	68 94 61 10 f0       	push   $0xf0106194
f01013bb:	68 f5 02 00 00       	push   $0x2f5
f01013c0:	68 6e 61 10 f0       	push   $0xf010616e
f01013c5:	e8 26 ed ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01013ca:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01013cd:	39 c7                	cmp    %eax,%edi
f01013cf:	74 04                	je     f01013d5 <mem_init+0x24d>
f01013d1:	39 c6                	cmp    %eax,%esi
f01013d3:	75 19                	jne    f01013ee <mem_init+0x266>
f01013d5:	68 e8 65 10 f0       	push   $0xf01065e8
f01013da:	68 94 61 10 f0       	push   $0xf0106194
f01013df:	68 f6 02 00 00       	push   $0x2f6
f01013e4:	68 6e 61 10 f0       	push   $0xf010616e
f01013e9:	e8 02 ed ff ff       	call   f01000f0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01013ee:	8b 0d a0 e0 39 f0    	mov    0xf039e0a0,%ecx
	assert(page2pa(pp0) < npages*PGSIZE);
f01013f4:	8b 15 98 e0 39 f0    	mov    0xf039e098,%edx
f01013fa:	c1 e2 0c             	shl    $0xc,%edx
f01013fd:	89 f8                	mov    %edi,%eax
f01013ff:	29 c8                	sub    %ecx,%eax
f0101401:	c1 f8 03             	sar    $0x3,%eax
f0101404:	c1 e0 0c             	shl    $0xc,%eax
f0101407:	39 d0                	cmp    %edx,%eax
f0101409:	72 19                	jb     f0101424 <mem_init+0x29c>
f010140b:	68 93 62 10 f0       	push   $0xf0106293
f0101410:	68 94 61 10 f0       	push   $0xf0106194
f0101415:	68 f7 02 00 00       	push   $0x2f7
f010141a:	68 6e 61 10 f0       	push   $0xf010616e
f010141f:	e8 cc ec ff ff       	call   f01000f0 <_panic>
f0101424:	89 f0                	mov    %esi,%eax
f0101426:	29 c8                	sub    %ecx,%eax
f0101428:	c1 f8 03             	sar    $0x3,%eax
f010142b:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp1) < npages*PGSIZE);
f010142e:	39 c2                	cmp    %eax,%edx
f0101430:	77 19                	ja     f010144b <mem_init+0x2c3>
f0101432:	68 b0 62 10 f0       	push   $0xf01062b0
f0101437:	68 94 61 10 f0       	push   $0xf0106194
f010143c:	68 f8 02 00 00       	push   $0x2f8
f0101441:	68 6e 61 10 f0       	push   $0xf010616e
f0101446:	e8 a5 ec ff ff       	call   f01000f0 <_panic>
f010144b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010144e:	29 c8                	sub    %ecx,%eax
f0101450:	c1 f8 03             	sar    $0x3,%eax
f0101453:	c1 e0 0c             	shl    $0xc,%eax
	assert(page2pa(pp2) < npages*PGSIZE);
f0101456:	39 c2                	cmp    %eax,%edx
f0101458:	77 19                	ja     f0101473 <mem_init+0x2eb>
f010145a:	68 cd 62 10 f0       	push   $0xf01062cd
f010145f:	68 94 61 10 f0       	push   $0xf0106194
f0101464:	68 f9 02 00 00       	push   $0x2f9
f0101469:	68 6e 61 10 f0       	push   $0xf010616e
f010146e:	e8 7d ec ff ff       	call   f01000f0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101473:	a1 a0 d3 39 f0       	mov    0xf039d3a0,%eax
f0101478:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f010147b:	c7 05 a0 d3 39 f0 00 	movl   $0x0,0xf039d3a0
f0101482:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101485:	83 ec 0c             	sub    $0xc,%esp
f0101488:	6a 00                	push   $0x0
f010148a:	e8 07 fa ff ff       	call   f0100e96 <page_alloc>
f010148f:	83 c4 10             	add    $0x10,%esp
f0101492:	85 c0                	test   %eax,%eax
f0101494:	74 19                	je     f01014af <mem_init+0x327>
f0101496:	68 ea 62 10 f0       	push   $0xf01062ea
f010149b:	68 94 61 10 f0       	push   $0xf0106194
f01014a0:	68 00 03 00 00       	push   $0x300
f01014a5:	68 6e 61 10 f0       	push   $0xf010616e
f01014aa:	e8 41 ec ff ff       	call   f01000f0 <_panic>

	// free and re-allocate?
	page_free(pp0);
f01014af:	83 ec 0c             	sub    $0xc,%esp
f01014b2:	57                   	push   %edi
f01014b3:	e8 55 fa ff ff       	call   f0100f0d <page_free>
	page_free(pp1);
f01014b8:	89 34 24             	mov    %esi,(%esp)
f01014bb:	e8 4d fa ff ff       	call   f0100f0d <page_free>
	page_free(pp2);
f01014c0:	83 c4 04             	add    $0x4,%esp
f01014c3:	ff 75 d4             	pushl  -0x2c(%ebp)
f01014c6:	e8 42 fa ff ff       	call   f0100f0d <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01014cb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01014d2:	e8 bf f9 ff ff       	call   f0100e96 <page_alloc>
f01014d7:	89 c6                	mov    %eax,%esi
f01014d9:	83 c4 10             	add    $0x10,%esp
f01014dc:	85 c0                	test   %eax,%eax
f01014de:	75 19                	jne    f01014f9 <mem_init+0x371>
f01014e0:	68 3f 62 10 f0       	push   $0xf010623f
f01014e5:	68 94 61 10 f0       	push   $0xf0106194
f01014ea:	68 07 03 00 00       	push   $0x307
f01014ef:	68 6e 61 10 f0       	push   $0xf010616e
f01014f4:	e8 f7 eb ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f01014f9:	83 ec 0c             	sub    $0xc,%esp
f01014fc:	6a 00                	push   $0x0
f01014fe:	e8 93 f9 ff ff       	call   f0100e96 <page_alloc>
f0101503:	89 c7                	mov    %eax,%edi
f0101505:	83 c4 10             	add    $0x10,%esp
f0101508:	85 c0                	test   %eax,%eax
f010150a:	75 19                	jne    f0101525 <mem_init+0x39d>
f010150c:	68 55 62 10 f0       	push   $0xf0106255
f0101511:	68 94 61 10 f0       	push   $0xf0106194
f0101516:	68 08 03 00 00       	push   $0x308
f010151b:	68 6e 61 10 f0       	push   $0xf010616e
f0101520:	e8 cb eb ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f0101525:	83 ec 0c             	sub    $0xc,%esp
f0101528:	6a 00                	push   $0x0
f010152a:	e8 67 f9 ff ff       	call   f0100e96 <page_alloc>
f010152f:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101532:	83 c4 10             	add    $0x10,%esp
f0101535:	85 c0                	test   %eax,%eax
f0101537:	75 19                	jne    f0101552 <mem_init+0x3ca>
f0101539:	68 6b 62 10 f0       	push   $0xf010626b
f010153e:	68 94 61 10 f0       	push   $0xf0106194
f0101543:	68 09 03 00 00       	push   $0x309
f0101548:	68 6e 61 10 f0       	push   $0xf010616e
f010154d:	e8 9e eb ff ff       	call   f01000f0 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101552:	39 fe                	cmp    %edi,%esi
f0101554:	75 19                	jne    f010156f <mem_init+0x3e7>
f0101556:	68 81 62 10 f0       	push   $0xf0106281
f010155b:	68 94 61 10 f0       	push   $0xf0106194
f0101560:	68 0b 03 00 00       	push   $0x30b
f0101565:	68 6e 61 10 f0       	push   $0xf010616e
f010156a:	e8 81 eb ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010156f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101572:	39 c6                	cmp    %eax,%esi
f0101574:	74 04                	je     f010157a <mem_init+0x3f2>
f0101576:	39 c7                	cmp    %eax,%edi
f0101578:	75 19                	jne    f0101593 <mem_init+0x40b>
f010157a:	68 e8 65 10 f0       	push   $0xf01065e8
f010157f:	68 94 61 10 f0       	push   $0xf0106194
f0101584:	68 0c 03 00 00       	push   $0x30c
f0101589:	68 6e 61 10 f0       	push   $0xf010616e
f010158e:	e8 5d eb ff ff       	call   f01000f0 <_panic>
	assert(!page_alloc(0));
f0101593:	83 ec 0c             	sub    $0xc,%esp
f0101596:	6a 00                	push   $0x0
f0101598:	e8 f9 f8 ff ff       	call   f0100e96 <page_alloc>
f010159d:	83 c4 10             	add    $0x10,%esp
f01015a0:	85 c0                	test   %eax,%eax
f01015a2:	74 19                	je     f01015bd <mem_init+0x435>
f01015a4:	68 ea 62 10 f0       	push   $0xf01062ea
f01015a9:	68 94 61 10 f0       	push   $0xf0106194
f01015ae:	68 0d 03 00 00       	push   $0x30d
f01015b3:	68 6e 61 10 f0       	push   $0xf010616e
f01015b8:	e8 33 eb ff ff       	call   f01000f0 <_panic>
f01015bd:	89 f0                	mov    %esi,%eax
f01015bf:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f01015c5:	c1 f8 03             	sar    $0x3,%eax
f01015c8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01015cb:	89 c2                	mov    %eax,%edx
f01015cd:	c1 ea 0c             	shr    $0xc,%edx
f01015d0:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f01015d6:	72 12                	jb     f01015ea <mem_init+0x462>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f01015d8:	50                   	push   %eax
f01015d9:	68 54 64 10 f0       	push   $0xf0106454
f01015de:	6a 58                	push   $0x58
f01015e0:	68 7a 61 10 f0       	push   $0xf010617a
f01015e5:	e8 06 eb ff ff       	call   f01000f0 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f01015ea:	83 ec 04             	sub    $0x4,%esp
f01015ed:	68 00 10 00 00       	push   $0x1000
f01015f2:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f01015f4:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01015f9:	50                   	push   %eax
f01015fa:	e8 81 3d 00 00       	call   f0105380 <memset>
	page_free(pp0);
f01015ff:	89 34 24             	mov    %esi,(%esp)
f0101602:	e8 06 f9 ff ff       	call   f0100f0d <page_free>
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101607:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f010160e:	e8 83 f8 ff ff       	call   f0100e96 <page_alloc>
f0101613:	83 c4 10             	add    $0x10,%esp
f0101616:	85 c0                	test   %eax,%eax
f0101618:	75 19                	jne    f0101633 <mem_init+0x4ab>
f010161a:	68 f9 62 10 f0       	push   $0xf01062f9
f010161f:	68 94 61 10 f0       	push   $0xf0106194
f0101624:	68 12 03 00 00       	push   $0x312
f0101629:	68 6e 61 10 f0       	push   $0xf010616e
f010162e:	e8 bd ea ff ff       	call   f01000f0 <_panic>
	assert(pp && pp0 == pp);
f0101633:	39 c6                	cmp    %eax,%esi
f0101635:	74 19                	je     f0101650 <mem_init+0x4c8>
f0101637:	68 17 63 10 f0       	push   $0xf0106317
f010163c:	68 94 61 10 f0       	push   $0xf0106194
f0101641:	68 13 03 00 00       	push   $0x313
f0101646:	68 6e 61 10 f0       	push   $0xf010616e
f010164b:	e8 a0 ea ff ff       	call   f01000f0 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101650:	89 f0                	mov    %esi,%eax
f0101652:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0101658:	c1 f8 03             	sar    $0x3,%eax
f010165b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010165e:	89 c2                	mov    %eax,%edx
f0101660:	c1 ea 0c             	shr    $0xc,%edx
f0101663:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f0101669:	72 12                	jb     f010167d <mem_init+0x4f5>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f010166b:	50                   	push   %eax
f010166c:	68 54 64 10 f0       	push   $0xf0106454
f0101671:	6a 58                	push   $0x58
f0101673:	68 7a 61 10 f0       	push   $0xf010617a
f0101678:	e8 73 ea ff ff       	call   f01000f0 <_panic>
f010167d:	8d 90 00 10 00 f0    	lea    -0xffff000(%eax),%edx
	return (void *)(pa + KERNBASE);
f0101683:	8d 80 00 00 00 f0    	lea    -0x10000000(%eax),%eax
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101689:	80 38 00             	cmpb   $0x0,(%eax)
f010168c:	74 19                	je     f01016a7 <mem_init+0x51f>
f010168e:	68 27 63 10 f0       	push   $0xf0106327
f0101693:	68 94 61 10 f0       	push   $0xf0106194
f0101698:	68 16 03 00 00       	push   $0x316
f010169d:	68 6e 61 10 f0       	push   $0xf010616e
f01016a2:	e8 49 ea ff ff       	call   f01000f0 <_panic>
f01016a7:	83 c0 01             	add    $0x1,%eax
	memset(page2kva(pp0), 1, PGSIZE);
	page_free(pp0);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f01016aa:	39 d0                	cmp    %edx,%eax
f01016ac:	75 db                	jne    f0101689 <mem_init+0x501>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f01016ae:	8b 45 d0             	mov    -0x30(%ebp),%eax
f01016b1:	a3 a0 d3 39 f0       	mov    %eax,0xf039d3a0

	// free the pages we took
	page_free(pp0);
f01016b6:	83 ec 0c             	sub    $0xc,%esp
f01016b9:	56                   	push   %esi
f01016ba:	e8 4e f8 ff ff       	call   f0100f0d <page_free>
	page_free(pp1);
f01016bf:	89 3c 24             	mov    %edi,(%esp)
f01016c2:	e8 46 f8 ff ff       	call   f0100f0d <page_free>
	page_free(pp2);
f01016c7:	83 c4 04             	add    $0x4,%esp
f01016ca:	ff 75 d4             	pushl  -0x2c(%ebp)
f01016cd:	e8 3b f8 ff ff       	call   f0100f0d <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016d2:	a1 a0 d3 39 f0       	mov    0xf039d3a0,%eax
f01016d7:	83 c4 10             	add    $0x10,%esp
f01016da:	eb 05                	jmp    f01016e1 <mem_init+0x559>
		--nfree;
f01016dc:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f01016df:	8b 00                	mov    (%eax),%eax
f01016e1:	85 c0                	test   %eax,%eax
f01016e3:	75 f7                	jne    f01016dc <mem_init+0x554>
		--nfree;
	assert(nfree == 0);
f01016e5:	85 db                	test   %ebx,%ebx
f01016e7:	74 19                	je     f0101702 <mem_init+0x57a>
f01016e9:	68 31 63 10 f0       	push   $0xf0106331
f01016ee:	68 94 61 10 f0       	push   $0xf0106194
f01016f3:	68 23 03 00 00       	push   $0x323
f01016f8:	68 6e 61 10 f0       	push   $0xf010616e
f01016fd:	e8 ee e9 ff ff       	call   f01000f0 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101702:	83 ec 0c             	sub    $0xc,%esp
f0101705:	68 08 66 10 f0       	push   $0xf0106608
f010170a:	e8 37 20 00 00       	call   f0103746 <cprintf>
	void *va;
	int i;

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f010170f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101716:	e8 7b f7 ff ff       	call   f0100e96 <page_alloc>
f010171b:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f010171e:	83 c4 10             	add    $0x10,%esp
f0101721:	85 c0                	test   %eax,%eax
f0101723:	75 19                	jne    f010173e <mem_init+0x5b6>
f0101725:	68 3f 62 10 f0       	push   $0xf010623f
f010172a:	68 94 61 10 f0       	push   $0xf0106194
f010172f:	68 81 03 00 00       	push   $0x381
f0101734:	68 6e 61 10 f0       	push   $0xf010616e
f0101739:	e8 b2 e9 ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f010173e:	83 ec 0c             	sub    $0xc,%esp
f0101741:	6a 00                	push   $0x0
f0101743:	e8 4e f7 ff ff       	call   f0100e96 <page_alloc>
f0101748:	89 c3                	mov    %eax,%ebx
f010174a:	83 c4 10             	add    $0x10,%esp
f010174d:	85 c0                	test   %eax,%eax
f010174f:	75 19                	jne    f010176a <mem_init+0x5e2>
f0101751:	68 55 62 10 f0       	push   $0xf0106255
f0101756:	68 94 61 10 f0       	push   $0xf0106194
f010175b:	68 82 03 00 00       	push   $0x382
f0101760:	68 6e 61 10 f0       	push   $0xf010616e
f0101765:	e8 86 e9 ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f010176a:	83 ec 0c             	sub    $0xc,%esp
f010176d:	6a 00                	push   $0x0
f010176f:	e8 22 f7 ff ff       	call   f0100e96 <page_alloc>
f0101774:	89 c6                	mov    %eax,%esi
f0101776:	83 c4 10             	add    $0x10,%esp
f0101779:	85 c0                	test   %eax,%eax
f010177b:	75 19                	jne    f0101796 <mem_init+0x60e>
f010177d:	68 6b 62 10 f0       	push   $0xf010626b
f0101782:	68 94 61 10 f0       	push   $0xf0106194
f0101787:	68 83 03 00 00       	push   $0x383
f010178c:	68 6e 61 10 f0       	push   $0xf010616e
f0101791:	e8 5a e9 ff ff       	call   f01000f0 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101796:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0101799:	75 19                	jne    f01017b4 <mem_init+0x62c>
f010179b:	68 81 62 10 f0       	push   $0xf0106281
f01017a0:	68 94 61 10 f0       	push   $0xf0106194
f01017a5:	68 86 03 00 00       	push   $0x386
f01017aa:	68 6e 61 10 f0       	push   $0xf010616e
f01017af:	e8 3c e9 ff ff       	call   f01000f0 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f01017b4:	39 45 d4             	cmp    %eax,-0x2c(%ebp)
f01017b7:	74 04                	je     f01017bd <mem_init+0x635>
f01017b9:	39 c3                	cmp    %eax,%ebx
f01017bb:	75 19                	jne    f01017d6 <mem_init+0x64e>
f01017bd:	68 e8 65 10 f0       	push   $0xf01065e8
f01017c2:	68 94 61 10 f0       	push   $0xf0106194
f01017c7:	68 87 03 00 00       	push   $0x387
f01017cc:	68 6e 61 10 f0       	push   $0xf010616e
f01017d1:	e8 1a e9 ff ff       	call   f01000f0 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f01017d6:	a1 a0 d3 39 f0       	mov    0xf039d3a0,%eax
f01017db:	89 45 d0             	mov    %eax,-0x30(%ebp)
	page_free_list = 0;
f01017de:	c7 05 a0 d3 39 f0 00 	movl   $0x0,0xf039d3a0
f01017e5:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f01017e8:	83 ec 0c             	sub    $0xc,%esp
f01017eb:	6a 00                	push   $0x0
f01017ed:	e8 a4 f6 ff ff       	call   f0100e96 <page_alloc>
f01017f2:	83 c4 10             	add    $0x10,%esp
f01017f5:	85 c0                	test   %eax,%eax
f01017f7:	74 19                	je     f0101812 <mem_init+0x68a>
f01017f9:	68 ea 62 10 f0       	push   $0xf01062ea
f01017fe:	68 94 61 10 f0       	push   $0xf0106194
f0101803:	68 8e 03 00 00       	push   $0x38e
f0101808:	68 6e 61 10 f0       	push   $0xf010616e
f010180d:	e8 de e8 ff ff       	call   f01000f0 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101812:	83 ec 04             	sub    $0x4,%esp
f0101815:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0101818:	50                   	push   %eax
f0101819:	6a 00                	push   $0x0
f010181b:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101821:	e8 2b f8 ff ff       	call   f0101051 <page_lookup>
f0101826:	83 c4 10             	add    $0x10,%esp
f0101829:	85 c0                	test   %eax,%eax
f010182b:	74 19                	je     f0101846 <mem_init+0x6be>
f010182d:	68 28 66 10 f0       	push   $0xf0106628
f0101832:	68 94 61 10 f0       	push   $0xf0106194
f0101837:	68 91 03 00 00       	push   $0x391
f010183c:	68 6e 61 10 f0       	push   $0xf010616e
f0101841:	e8 aa e8 ff ff       	call   f01000f0 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0101846:	6a 02                	push   $0x2
f0101848:	6a 00                	push   $0x0
f010184a:	53                   	push   %ebx
f010184b:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101851:	e8 ca f8 ff ff       	call   f0101120 <page_insert>
f0101856:	83 c4 10             	add    $0x10,%esp
f0101859:	85 c0                	test   %eax,%eax
f010185b:	78 19                	js     f0101876 <mem_init+0x6ee>
f010185d:	68 60 66 10 f0       	push   $0xf0106660
f0101862:	68 94 61 10 f0       	push   $0xf0106194
f0101867:	68 94 03 00 00       	push   $0x394
f010186c:	68 6e 61 10 f0       	push   $0xf010616e
f0101871:	e8 7a e8 ff ff       	call   f01000f0 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f0101876:	83 ec 0c             	sub    $0xc,%esp
f0101879:	ff 75 d4             	pushl  -0x2c(%ebp)
f010187c:	e8 8c f6 ff ff       	call   f0100f0d <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0101881:	6a 02                	push   $0x2
f0101883:	6a 00                	push   $0x0
f0101885:	53                   	push   %ebx
f0101886:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f010188c:	e8 8f f8 ff ff       	call   f0101120 <page_insert>
f0101891:	83 c4 20             	add    $0x20,%esp
f0101894:	85 c0                	test   %eax,%eax
f0101896:	74 19                	je     f01018b1 <mem_init+0x729>
f0101898:	68 90 66 10 f0       	push   $0xf0106690
f010189d:	68 94 61 10 f0       	push   $0xf0106194
f01018a2:	68 98 03 00 00       	push   $0x398
f01018a7:	68 6e 61 10 f0       	push   $0xf010616e
f01018ac:	e8 3f e8 ff ff       	call   f01000f0 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f01018b1:	8b 3d 9c e0 39 f0    	mov    0xf039e09c,%edi
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01018b7:	a1 a0 e0 39 f0       	mov    0xf039e0a0,%eax
f01018bc:	89 c1                	mov    %eax,%ecx
f01018be:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01018c1:	8b 17                	mov    (%edi),%edx
f01018c3:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f01018c9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01018cc:	29 c8                	sub    %ecx,%eax
f01018ce:	c1 f8 03             	sar    $0x3,%eax
f01018d1:	c1 e0 0c             	shl    $0xc,%eax
f01018d4:	39 c2                	cmp    %eax,%edx
f01018d6:	74 19                	je     f01018f1 <mem_init+0x769>
f01018d8:	68 c0 66 10 f0       	push   $0xf01066c0
f01018dd:	68 94 61 10 f0       	push   $0xf0106194
f01018e2:	68 99 03 00 00       	push   $0x399
f01018e7:	68 6e 61 10 f0       	push   $0xf010616e
f01018ec:	e8 ff e7 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01018f1:	ba 00 00 00 00       	mov    $0x0,%edx
f01018f6:	89 f8                	mov    %edi,%eax
f01018f8:	e8 d8 f1 ff ff       	call   f0100ad5 <check_va2pa>
f01018fd:	89 da                	mov    %ebx,%edx
f01018ff:	2b 55 cc             	sub    -0x34(%ebp),%edx
f0101902:	c1 fa 03             	sar    $0x3,%edx
f0101905:	c1 e2 0c             	shl    $0xc,%edx
f0101908:	39 d0                	cmp    %edx,%eax
f010190a:	74 19                	je     f0101925 <mem_init+0x79d>
f010190c:	68 e8 66 10 f0       	push   $0xf01066e8
f0101911:	68 94 61 10 f0       	push   $0xf0106194
f0101916:	68 9a 03 00 00       	push   $0x39a
f010191b:	68 6e 61 10 f0       	push   $0xf010616e
f0101920:	e8 cb e7 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 1);
f0101925:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f010192a:	74 19                	je     f0101945 <mem_init+0x7bd>
f010192c:	68 3c 63 10 f0       	push   $0xf010633c
f0101931:	68 94 61 10 f0       	push   $0xf0106194
f0101936:	68 9b 03 00 00       	push   $0x39b
f010193b:	68 6e 61 10 f0       	push   $0xf010616e
f0101940:	e8 ab e7 ff ff       	call   f01000f0 <_panic>
	assert(pp0->pp_ref == 1);
f0101945:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101948:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f010194d:	74 19                	je     f0101968 <mem_init+0x7e0>
f010194f:	68 4d 63 10 f0       	push   $0xf010634d
f0101954:	68 94 61 10 f0       	push   $0xf0106194
f0101959:	68 9c 03 00 00       	push   $0x39c
f010195e:	68 6e 61 10 f0       	push   $0xf010616e
f0101963:	e8 88 e7 ff ff       	call   f01000f0 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101968:	6a 02                	push   $0x2
f010196a:	68 00 10 00 00       	push   $0x1000
f010196f:	56                   	push   %esi
f0101970:	57                   	push   %edi
f0101971:	e8 aa f7 ff ff       	call   f0101120 <page_insert>
f0101976:	83 c4 10             	add    $0x10,%esp
f0101979:	85 c0                	test   %eax,%eax
f010197b:	74 19                	je     f0101996 <mem_init+0x80e>
f010197d:	68 18 67 10 f0       	push   $0xf0106718
f0101982:	68 94 61 10 f0       	push   $0xf0106194
f0101987:	68 9f 03 00 00       	push   $0x39f
f010198c:	68 6e 61 10 f0       	push   $0xf010616e
f0101991:	e8 5a e7 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101996:	ba 00 10 00 00       	mov    $0x1000,%edx
f010199b:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f01019a0:	e8 30 f1 ff ff       	call   f0100ad5 <check_va2pa>
f01019a5:	89 f2                	mov    %esi,%edx
f01019a7:	2b 15 a0 e0 39 f0    	sub    0xf039e0a0,%edx
f01019ad:	c1 fa 03             	sar    $0x3,%edx
f01019b0:	c1 e2 0c             	shl    $0xc,%edx
f01019b3:	39 d0                	cmp    %edx,%eax
f01019b5:	74 19                	je     f01019d0 <mem_init+0x848>
f01019b7:	68 54 67 10 f0       	push   $0xf0106754
f01019bc:	68 94 61 10 f0       	push   $0xf0106194
f01019c1:	68 a0 03 00 00       	push   $0x3a0
f01019c6:	68 6e 61 10 f0       	push   $0xf010616e
f01019cb:	e8 20 e7 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f01019d0:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f01019d5:	74 19                	je     f01019f0 <mem_init+0x868>
f01019d7:	68 5e 63 10 f0       	push   $0xf010635e
f01019dc:	68 94 61 10 f0       	push   $0xf0106194
f01019e1:	68 a1 03 00 00       	push   $0x3a1
f01019e6:	68 6e 61 10 f0       	push   $0xf010616e
f01019eb:	e8 00 e7 ff ff       	call   f01000f0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f01019f0:	83 ec 0c             	sub    $0xc,%esp
f01019f3:	6a 00                	push   $0x0
f01019f5:	e8 9c f4 ff ff       	call   f0100e96 <page_alloc>
f01019fa:	83 c4 10             	add    $0x10,%esp
f01019fd:	85 c0                	test   %eax,%eax
f01019ff:	74 19                	je     f0101a1a <mem_init+0x892>
f0101a01:	68 ea 62 10 f0       	push   $0xf01062ea
f0101a06:	68 94 61 10 f0       	push   $0xf0106194
f0101a0b:	68 a4 03 00 00       	push   $0x3a4
f0101a10:	68 6e 61 10 f0       	push   $0xf010616e
f0101a15:	e8 d6 e6 ff ff       	call   f01000f0 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101a1a:	6a 02                	push   $0x2
f0101a1c:	68 00 10 00 00       	push   $0x1000
f0101a21:	56                   	push   %esi
f0101a22:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101a28:	e8 f3 f6 ff ff       	call   f0101120 <page_insert>
f0101a2d:	83 c4 10             	add    $0x10,%esp
f0101a30:	85 c0                	test   %eax,%eax
f0101a32:	74 19                	je     f0101a4d <mem_init+0x8c5>
f0101a34:	68 18 67 10 f0       	push   $0xf0106718
f0101a39:	68 94 61 10 f0       	push   $0xf0106194
f0101a3e:	68 a7 03 00 00       	push   $0x3a7
f0101a43:	68 6e 61 10 f0       	push   $0xf010616e
f0101a48:	e8 a3 e6 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101a4d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101a52:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f0101a57:	e8 79 f0 ff ff       	call   f0100ad5 <check_va2pa>
f0101a5c:	89 f2                	mov    %esi,%edx
f0101a5e:	2b 15 a0 e0 39 f0    	sub    0xf039e0a0,%edx
f0101a64:	c1 fa 03             	sar    $0x3,%edx
f0101a67:	c1 e2 0c             	shl    $0xc,%edx
f0101a6a:	39 d0                	cmp    %edx,%eax
f0101a6c:	74 19                	je     f0101a87 <mem_init+0x8ff>
f0101a6e:	68 54 67 10 f0       	push   $0xf0106754
f0101a73:	68 94 61 10 f0       	push   $0xf0106194
f0101a78:	68 a8 03 00 00       	push   $0x3a8
f0101a7d:	68 6e 61 10 f0       	push   $0xf010616e
f0101a82:	e8 69 e6 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f0101a87:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101a8c:	74 19                	je     f0101aa7 <mem_init+0x91f>
f0101a8e:	68 5e 63 10 f0       	push   $0xf010635e
f0101a93:	68 94 61 10 f0       	push   $0xf0106194
f0101a98:	68 a9 03 00 00       	push   $0x3a9
f0101a9d:	68 6e 61 10 f0       	push   $0xf010616e
f0101aa2:	e8 49 e6 ff ff       	call   f01000f0 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0101aa7:	83 ec 0c             	sub    $0xc,%esp
f0101aaa:	6a 00                	push   $0x0
f0101aac:	e8 e5 f3 ff ff       	call   f0100e96 <page_alloc>
f0101ab1:	83 c4 10             	add    $0x10,%esp
f0101ab4:	85 c0                	test   %eax,%eax
f0101ab6:	74 19                	je     f0101ad1 <mem_init+0x949>
f0101ab8:	68 ea 62 10 f0       	push   $0xf01062ea
f0101abd:	68 94 61 10 f0       	push   $0xf0106194
f0101ac2:	68 ad 03 00 00       	push   $0x3ad
f0101ac7:	68 6e 61 10 f0       	push   $0xf010616e
f0101acc:	e8 1f e6 ff ff       	call   f01000f0 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101ad1:	8b 15 9c e0 39 f0    	mov    0xf039e09c,%edx
f0101ad7:	8b 02                	mov    (%edx),%eax
f0101ad9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ade:	89 c1                	mov    %eax,%ecx
f0101ae0:	c1 e9 0c             	shr    $0xc,%ecx
f0101ae3:	3b 0d 98 e0 39 f0    	cmp    0xf039e098,%ecx
f0101ae9:	72 15                	jb     f0101b00 <mem_init+0x978>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0101aeb:	50                   	push   %eax
f0101aec:	68 54 64 10 f0       	push   $0xf0106454
f0101af1:	68 b0 03 00 00       	push   $0x3b0
f0101af6:	68 6e 61 10 f0       	push   $0xf010616e
f0101afb:	e8 f0 e5 ff ff       	call   f01000f0 <_panic>
	return (void *)(pa + KERNBASE);
f0101b00:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101b05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101b08:	83 ec 04             	sub    $0x4,%esp
f0101b0b:	6a 00                	push   $0x0
f0101b0d:	68 00 10 00 00       	push   $0x1000
f0101b12:	52                   	push   %edx
f0101b13:	e8 57 f4 ff ff       	call   f0100f6f <pgdir_walk>
f0101b18:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0101b1b:	8d 57 04             	lea    0x4(%edi),%edx
f0101b1e:	83 c4 10             	add    $0x10,%esp
f0101b21:	39 d0                	cmp    %edx,%eax
f0101b23:	74 19                	je     f0101b3e <mem_init+0x9b6>
f0101b25:	68 84 67 10 f0       	push   $0xf0106784
f0101b2a:	68 94 61 10 f0       	push   $0xf0106194
f0101b2f:	68 b1 03 00 00       	push   $0x3b1
f0101b34:	68 6e 61 10 f0       	push   $0xf010616e
f0101b39:	e8 b2 e5 ff ff       	call   f01000f0 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f0101b3e:	6a 06                	push   $0x6
f0101b40:	68 00 10 00 00       	push   $0x1000
f0101b45:	56                   	push   %esi
f0101b46:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101b4c:	e8 cf f5 ff ff       	call   f0101120 <page_insert>
f0101b51:	83 c4 10             	add    $0x10,%esp
f0101b54:	85 c0                	test   %eax,%eax
f0101b56:	74 19                	je     f0101b71 <mem_init+0x9e9>
f0101b58:	68 c4 67 10 f0       	push   $0xf01067c4
f0101b5d:	68 94 61 10 f0       	push   $0xf0106194
f0101b62:	68 b4 03 00 00       	push   $0x3b4
f0101b67:	68 6e 61 10 f0       	push   $0xf010616e
f0101b6c:	e8 7f e5 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b71:	8b 3d 9c e0 39 f0    	mov    0xf039e09c,%edi
f0101b77:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101b7c:	89 f8                	mov    %edi,%eax
f0101b7e:	e8 52 ef ff ff       	call   f0100ad5 <check_va2pa>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101b83:	89 f2                	mov    %esi,%edx
f0101b85:	2b 15 a0 e0 39 f0    	sub    0xf039e0a0,%edx
f0101b8b:	c1 fa 03             	sar    $0x3,%edx
f0101b8e:	c1 e2 0c             	shl    $0xc,%edx
f0101b91:	39 d0                	cmp    %edx,%eax
f0101b93:	74 19                	je     f0101bae <mem_init+0xa26>
f0101b95:	68 54 67 10 f0       	push   $0xf0106754
f0101b9a:	68 94 61 10 f0       	push   $0xf0106194
f0101b9f:	68 b5 03 00 00       	push   $0x3b5
f0101ba4:	68 6e 61 10 f0       	push   $0xf010616e
f0101ba9:	e8 42 e5 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f0101bae:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0101bb3:	74 19                	je     f0101bce <mem_init+0xa46>
f0101bb5:	68 5e 63 10 f0       	push   $0xf010635e
f0101bba:	68 94 61 10 f0       	push   $0xf0106194
f0101bbf:	68 b6 03 00 00       	push   $0x3b6
f0101bc4:	68 6e 61 10 f0       	push   $0xf010616e
f0101bc9:	e8 22 e5 ff ff       	call   f01000f0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f0101bce:	83 ec 04             	sub    $0x4,%esp
f0101bd1:	6a 00                	push   $0x0
f0101bd3:	68 00 10 00 00       	push   $0x1000
f0101bd8:	57                   	push   %edi
f0101bd9:	e8 91 f3 ff ff       	call   f0100f6f <pgdir_walk>
f0101bde:	83 c4 10             	add    $0x10,%esp
f0101be1:	f6 00 04             	testb  $0x4,(%eax)
f0101be4:	75 19                	jne    f0101bff <mem_init+0xa77>
f0101be6:	68 04 68 10 f0       	push   $0xf0106804
f0101beb:	68 94 61 10 f0       	push   $0xf0106194
f0101bf0:	68 b7 03 00 00       	push   $0x3b7
f0101bf5:	68 6e 61 10 f0       	push   $0xf010616e
f0101bfa:	e8 f1 e4 ff ff       	call   f01000f0 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f0101bff:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f0101c04:	f6 00 04             	testb  $0x4,(%eax)
f0101c07:	75 19                	jne    f0101c22 <mem_init+0xa9a>
f0101c09:	68 6f 63 10 f0       	push   $0xf010636f
f0101c0e:	68 94 61 10 f0       	push   $0xf0106194
f0101c13:	68 b8 03 00 00       	push   $0x3b8
f0101c18:	68 6e 61 10 f0       	push   $0xf010616e
f0101c1d:	e8 ce e4 ff ff       	call   f01000f0 <_panic>

	// should be able to remap with fewer permissions
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0101c22:	6a 02                	push   $0x2
f0101c24:	68 00 10 00 00       	push   $0x1000
f0101c29:	56                   	push   %esi
f0101c2a:	50                   	push   %eax
f0101c2b:	e8 f0 f4 ff ff       	call   f0101120 <page_insert>
f0101c30:	83 c4 10             	add    $0x10,%esp
f0101c33:	85 c0                	test   %eax,%eax
f0101c35:	74 19                	je     f0101c50 <mem_init+0xac8>
f0101c37:	68 18 67 10 f0       	push   $0xf0106718
f0101c3c:	68 94 61 10 f0       	push   $0xf0106194
f0101c41:	68 bb 03 00 00       	push   $0x3bb
f0101c46:	68 6e 61 10 f0       	push   $0xf010616e
f0101c4b:	e8 a0 e4 ff ff       	call   f01000f0 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0101c50:	83 ec 04             	sub    $0x4,%esp
f0101c53:	6a 00                	push   $0x0
f0101c55:	68 00 10 00 00       	push   $0x1000
f0101c5a:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101c60:	e8 0a f3 ff ff       	call   f0100f6f <pgdir_walk>
f0101c65:	83 c4 10             	add    $0x10,%esp
f0101c68:	f6 00 02             	testb  $0x2,(%eax)
f0101c6b:	75 19                	jne    f0101c86 <mem_init+0xafe>
f0101c6d:	68 38 68 10 f0       	push   $0xf0106838
f0101c72:	68 94 61 10 f0       	push   $0xf0106194
f0101c77:	68 bc 03 00 00       	push   $0x3bc
f0101c7c:	68 6e 61 10 f0       	push   $0xf010616e
f0101c81:	e8 6a e4 ff ff       	call   f01000f0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101c86:	83 ec 04             	sub    $0x4,%esp
f0101c89:	6a 00                	push   $0x0
f0101c8b:	68 00 10 00 00       	push   $0x1000
f0101c90:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101c96:	e8 d4 f2 ff ff       	call   f0100f6f <pgdir_walk>
f0101c9b:	83 c4 10             	add    $0x10,%esp
f0101c9e:	f6 00 04             	testb  $0x4,(%eax)
f0101ca1:	74 19                	je     f0101cbc <mem_init+0xb34>
f0101ca3:	68 6c 68 10 f0       	push   $0xf010686c
f0101ca8:	68 94 61 10 f0       	push   $0xf0106194
f0101cad:	68 bd 03 00 00       	push   $0x3bd
f0101cb2:	68 6e 61 10 f0       	push   $0xf010616e
f0101cb7:	e8 34 e4 ff ff       	call   f01000f0 <_panic>

	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f0101cbc:	6a 02                	push   $0x2
f0101cbe:	68 00 00 40 00       	push   $0x400000
f0101cc3:	ff 75 d4             	pushl  -0x2c(%ebp)
f0101cc6:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101ccc:	e8 4f f4 ff ff       	call   f0101120 <page_insert>
f0101cd1:	83 c4 10             	add    $0x10,%esp
f0101cd4:	85 c0                	test   %eax,%eax
f0101cd6:	78 19                	js     f0101cf1 <mem_init+0xb69>
f0101cd8:	68 a4 68 10 f0       	push   $0xf01068a4
f0101cdd:	68 94 61 10 f0       	push   $0xf0106194
f0101ce2:	68 c0 03 00 00       	push   $0x3c0
f0101ce7:	68 6e 61 10 f0       	push   $0xf010616e
f0101cec:	e8 ff e3 ff ff       	call   f01000f0 <_panic>

	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f0101cf1:	6a 02                	push   $0x2
f0101cf3:	68 00 10 00 00       	push   $0x1000
f0101cf8:	53                   	push   %ebx
f0101cf9:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101cff:	e8 1c f4 ff ff       	call   f0101120 <page_insert>
f0101d04:	83 c4 10             	add    $0x10,%esp
f0101d07:	85 c0                	test   %eax,%eax
f0101d09:	74 19                	je     f0101d24 <mem_init+0xb9c>
f0101d0b:	68 dc 68 10 f0       	push   $0xf01068dc
f0101d10:	68 94 61 10 f0       	push   $0xf0106194
f0101d15:	68 c3 03 00 00       	push   $0x3c3
f0101d1a:	68 6e 61 10 f0       	push   $0xf010616e
f0101d1f:	e8 cc e3 ff ff       	call   f01000f0 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0101d24:	83 ec 04             	sub    $0x4,%esp
f0101d27:	6a 00                	push   $0x0
f0101d29:	68 00 10 00 00       	push   $0x1000
f0101d2e:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101d34:	e8 36 f2 ff ff       	call   f0100f6f <pgdir_walk>
f0101d39:	83 c4 10             	add    $0x10,%esp
f0101d3c:	f6 00 04             	testb  $0x4,(%eax)
f0101d3f:	74 19                	je     f0101d5a <mem_init+0xbd2>
f0101d41:	68 6c 68 10 f0       	push   $0xf010686c
f0101d46:	68 94 61 10 f0       	push   $0xf0106194
f0101d4b:	68 c4 03 00 00       	push   $0x3c4
f0101d50:	68 6e 61 10 f0       	push   $0xf010616e
f0101d55:	e8 96 e3 ff ff       	call   f01000f0 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d5a:	8b 3d 9c e0 39 f0    	mov    0xf039e09c,%edi
f0101d60:	ba 00 00 00 00       	mov    $0x0,%edx
f0101d65:	89 f8                	mov    %edi,%eax
f0101d67:	e8 69 ed ff ff       	call   f0100ad5 <check_va2pa>
f0101d6c:	89 c1                	mov    %eax,%ecx
f0101d6e:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0101d71:	89 d8                	mov    %ebx,%eax
f0101d73:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0101d79:	c1 f8 03             	sar    $0x3,%eax
f0101d7c:	c1 e0 0c             	shl    $0xc,%eax
f0101d7f:	39 c1                	cmp    %eax,%ecx
f0101d81:	74 19                	je     f0101d9c <mem_init+0xc14>
f0101d83:	68 18 69 10 f0       	push   $0xf0106918
f0101d88:	68 94 61 10 f0       	push   $0xf0106194
f0101d8d:	68 c7 03 00 00       	push   $0x3c7
f0101d92:	68 6e 61 10 f0       	push   $0xf010616e
f0101d97:	e8 54 e3 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101d9c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101da1:	89 f8                	mov    %edi,%eax
f0101da3:	e8 2d ed ff ff       	call   f0100ad5 <check_va2pa>
f0101da8:	39 45 cc             	cmp    %eax,-0x34(%ebp)
f0101dab:	74 19                	je     f0101dc6 <mem_init+0xc3e>
f0101dad:	68 44 69 10 f0       	push   $0xf0106944
f0101db2:	68 94 61 10 f0       	push   $0xf0106194
f0101db7:	68 c8 03 00 00       	push   $0x3c8
f0101dbc:	68 6e 61 10 f0       	push   $0xf010616e
f0101dc1:	e8 2a e3 ff ff       	call   f01000f0 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0101dc6:	66 83 7b 04 02       	cmpw   $0x2,0x4(%ebx)
f0101dcb:	74 19                	je     f0101de6 <mem_init+0xc5e>
f0101dcd:	68 85 63 10 f0       	push   $0xf0106385
f0101dd2:	68 94 61 10 f0       	push   $0xf0106194
f0101dd7:	68 ca 03 00 00       	push   $0x3ca
f0101ddc:	68 6e 61 10 f0       	push   $0xf010616e
f0101de1:	e8 0a e3 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f0101de6:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101deb:	74 19                	je     f0101e06 <mem_init+0xc7e>
f0101ded:	68 96 63 10 f0       	push   $0xf0106396
f0101df2:	68 94 61 10 f0       	push   $0xf0106194
f0101df7:	68 cb 03 00 00       	push   $0x3cb
f0101dfc:	68 6e 61 10 f0       	push   $0xf010616e
f0101e01:	e8 ea e2 ff ff       	call   f01000f0 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f0101e06:	83 ec 0c             	sub    $0xc,%esp
f0101e09:	6a 00                	push   $0x0
f0101e0b:	e8 86 f0 ff ff       	call   f0100e96 <page_alloc>
f0101e10:	83 c4 10             	add    $0x10,%esp
f0101e13:	85 c0                	test   %eax,%eax
f0101e15:	74 04                	je     f0101e1b <mem_init+0xc93>
f0101e17:	39 c6                	cmp    %eax,%esi
f0101e19:	74 19                	je     f0101e34 <mem_init+0xcac>
f0101e1b:	68 74 69 10 f0       	push   $0xf0106974
f0101e20:	68 94 61 10 f0       	push   $0xf0106194
f0101e25:	68 ce 03 00 00       	push   $0x3ce
f0101e2a:	68 6e 61 10 f0       	push   $0xf010616e
f0101e2f:	e8 bc e2 ff ff       	call   f01000f0 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f0101e34:	83 ec 08             	sub    $0x8,%esp
f0101e37:	6a 00                	push   $0x0
f0101e39:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101e3f:	e8 8e f2 ff ff       	call   f01010d2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101e44:	8b 3d 9c e0 39 f0    	mov    0xf039e09c,%edi
f0101e4a:	ba 00 00 00 00       	mov    $0x0,%edx
f0101e4f:	89 f8                	mov    %edi,%eax
f0101e51:	e8 7f ec ff ff       	call   f0100ad5 <check_va2pa>
f0101e56:	83 c4 10             	add    $0x10,%esp
f0101e59:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101e5c:	74 19                	je     f0101e77 <mem_init+0xcef>
f0101e5e:	68 98 69 10 f0       	push   $0xf0106998
f0101e63:	68 94 61 10 f0       	push   $0xf0106194
f0101e68:	68 d2 03 00 00       	push   $0x3d2
f0101e6d:	68 6e 61 10 f0       	push   $0xf010616e
f0101e72:	e8 79 e2 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101e77:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101e7c:	89 f8                	mov    %edi,%eax
f0101e7e:	e8 52 ec ff ff       	call   f0100ad5 <check_va2pa>
f0101e83:	89 da                	mov    %ebx,%edx
f0101e85:	2b 15 a0 e0 39 f0    	sub    0xf039e0a0,%edx
f0101e8b:	c1 fa 03             	sar    $0x3,%edx
f0101e8e:	c1 e2 0c             	shl    $0xc,%edx
f0101e91:	39 d0                	cmp    %edx,%eax
f0101e93:	74 19                	je     f0101eae <mem_init+0xd26>
f0101e95:	68 44 69 10 f0       	push   $0xf0106944
f0101e9a:	68 94 61 10 f0       	push   $0xf0106194
f0101e9f:	68 d3 03 00 00       	push   $0x3d3
f0101ea4:	68 6e 61 10 f0       	push   $0xf010616e
f0101ea9:	e8 42 e2 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 1);
f0101eae:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101eb3:	74 19                	je     f0101ece <mem_init+0xd46>
f0101eb5:	68 3c 63 10 f0       	push   $0xf010633c
f0101eba:	68 94 61 10 f0       	push   $0xf0106194
f0101ebf:	68 d4 03 00 00       	push   $0x3d4
f0101ec4:	68 6e 61 10 f0       	push   $0xf010616e
f0101ec9:	e8 22 e2 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f0101ece:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101ed3:	74 19                	je     f0101eee <mem_init+0xd66>
f0101ed5:	68 96 63 10 f0       	push   $0xf0106396
f0101eda:	68 94 61 10 f0       	push   $0xf0106194
f0101edf:	68 d5 03 00 00       	push   $0x3d5
f0101ee4:	68 6e 61 10 f0       	push   $0xf010616e
f0101ee9:	e8 02 e2 ff ff       	call   f01000f0 <_panic>

	// test re-inserting pp1 at PGSIZE
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0101eee:	6a 00                	push   $0x0
f0101ef0:	68 00 10 00 00       	push   $0x1000
f0101ef5:	53                   	push   %ebx
f0101ef6:	57                   	push   %edi
f0101ef7:	e8 24 f2 ff ff       	call   f0101120 <page_insert>
f0101efc:	83 c4 10             	add    $0x10,%esp
f0101eff:	85 c0                	test   %eax,%eax
f0101f01:	74 19                	je     f0101f1c <mem_init+0xd94>
f0101f03:	68 bc 69 10 f0       	push   $0xf01069bc
f0101f08:	68 94 61 10 f0       	push   $0xf0106194
f0101f0d:	68 d8 03 00 00       	push   $0x3d8
f0101f12:	68 6e 61 10 f0       	push   $0xf010616e
f0101f17:	e8 d4 e1 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref);
f0101f1c:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101f21:	75 19                	jne    f0101f3c <mem_init+0xdb4>
f0101f23:	68 a7 63 10 f0       	push   $0xf01063a7
f0101f28:	68 94 61 10 f0       	push   $0xf0106194
f0101f2d:	68 d9 03 00 00       	push   $0x3d9
f0101f32:	68 6e 61 10 f0       	push   $0xf010616e
f0101f37:	e8 b4 e1 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_link == NULL);
f0101f3c:	83 3b 00             	cmpl   $0x0,(%ebx)
f0101f3f:	74 19                	je     f0101f5a <mem_init+0xdd2>
f0101f41:	68 b3 63 10 f0       	push   $0xf01063b3
f0101f46:	68 94 61 10 f0       	push   $0xf0106194
f0101f4b:	68 da 03 00 00       	push   $0x3da
f0101f50:	68 6e 61 10 f0       	push   $0xf010616e
f0101f55:	e8 96 e1 ff ff       	call   f01000f0 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f0101f5a:	83 ec 08             	sub    $0x8,%esp
f0101f5d:	68 00 10 00 00       	push   $0x1000
f0101f62:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0101f68:	e8 65 f1 ff ff       	call   f01010d2 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f0101f6d:	8b 3d 9c e0 39 f0    	mov    0xf039e09c,%edi
f0101f73:	ba 00 00 00 00       	mov    $0x0,%edx
f0101f78:	89 f8                	mov    %edi,%eax
f0101f7a:	e8 56 eb ff ff       	call   f0100ad5 <check_va2pa>
f0101f7f:	83 c4 10             	add    $0x10,%esp
f0101f82:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101f85:	74 19                	je     f0101fa0 <mem_init+0xe18>
f0101f87:	68 98 69 10 f0       	push   $0xf0106998
f0101f8c:	68 94 61 10 f0       	push   $0xf0106194
f0101f91:	68 de 03 00 00       	push   $0x3de
f0101f96:	68 6e 61 10 f0       	push   $0xf010616e
f0101f9b:	e8 50 e1 ff ff       	call   f01000f0 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0101fa0:	ba 00 10 00 00       	mov    $0x1000,%edx
f0101fa5:	89 f8                	mov    %edi,%eax
f0101fa7:	e8 29 eb ff ff       	call   f0100ad5 <check_va2pa>
f0101fac:	83 f8 ff             	cmp    $0xffffffff,%eax
f0101faf:	74 19                	je     f0101fca <mem_init+0xe42>
f0101fb1:	68 f4 69 10 f0       	push   $0xf01069f4
f0101fb6:	68 94 61 10 f0       	push   $0xf0106194
f0101fbb:	68 df 03 00 00       	push   $0x3df
f0101fc0:	68 6e 61 10 f0       	push   $0xf010616e
f0101fc5:	e8 26 e1 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 0);
f0101fca:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0101fcf:	74 19                	je     f0101fea <mem_init+0xe62>
f0101fd1:	68 c8 63 10 f0       	push   $0xf01063c8
f0101fd6:	68 94 61 10 f0       	push   $0xf0106194
f0101fdb:	68 e0 03 00 00       	push   $0x3e0
f0101fe0:	68 6e 61 10 f0       	push   $0xf010616e
f0101fe5:	e8 06 e1 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 0);
f0101fea:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f0101fef:	74 19                	je     f010200a <mem_init+0xe82>
f0101ff1:	68 96 63 10 f0       	push   $0xf0106396
f0101ff6:	68 94 61 10 f0       	push   $0xf0106194
f0101ffb:	68 e1 03 00 00       	push   $0x3e1
f0102000:	68 6e 61 10 f0       	push   $0xf010616e
f0102005:	e8 e6 e0 ff ff       	call   f01000f0 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f010200a:	83 ec 0c             	sub    $0xc,%esp
f010200d:	6a 00                	push   $0x0
f010200f:	e8 82 ee ff ff       	call   f0100e96 <page_alloc>
f0102014:	83 c4 10             	add    $0x10,%esp
f0102017:	85 c0                	test   %eax,%eax
f0102019:	74 04                	je     f010201f <mem_init+0xe97>
f010201b:	39 c3                	cmp    %eax,%ebx
f010201d:	74 19                	je     f0102038 <mem_init+0xeb0>
f010201f:	68 1c 6a 10 f0       	push   $0xf0106a1c
f0102024:	68 94 61 10 f0       	push   $0xf0106194
f0102029:	68 e4 03 00 00       	push   $0x3e4
f010202e:	68 6e 61 10 f0       	push   $0xf010616e
f0102033:	e8 b8 e0 ff ff       	call   f01000f0 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102038:	83 ec 0c             	sub    $0xc,%esp
f010203b:	6a 00                	push   $0x0
f010203d:	e8 54 ee ff ff       	call   f0100e96 <page_alloc>
f0102042:	83 c4 10             	add    $0x10,%esp
f0102045:	85 c0                	test   %eax,%eax
f0102047:	74 19                	je     f0102062 <mem_init+0xeda>
f0102049:	68 ea 62 10 f0       	push   $0xf01062ea
f010204e:	68 94 61 10 f0       	push   $0xf0106194
f0102053:	68 e7 03 00 00       	push   $0x3e7
f0102058:	68 6e 61 10 f0       	push   $0xf010616e
f010205d:	e8 8e e0 ff ff       	call   f01000f0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102062:	8b 0d 9c e0 39 f0    	mov    0xf039e09c,%ecx
f0102068:	8b 11                	mov    (%ecx),%edx
f010206a:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102070:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102073:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0102079:	c1 f8 03             	sar    $0x3,%eax
f010207c:	c1 e0 0c             	shl    $0xc,%eax
f010207f:	39 c2                	cmp    %eax,%edx
f0102081:	74 19                	je     f010209c <mem_init+0xf14>
f0102083:	68 c0 66 10 f0       	push   $0xf01066c0
f0102088:	68 94 61 10 f0       	push   $0xf0106194
f010208d:	68 ea 03 00 00       	push   $0x3ea
f0102092:	68 6e 61 10 f0       	push   $0xf010616e
f0102097:	e8 54 e0 ff ff       	call   f01000f0 <_panic>
	kern_pgdir[0] = 0;
f010209c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f01020a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020a5:	66 83 78 04 01       	cmpw   $0x1,0x4(%eax)
f01020aa:	74 19                	je     f01020c5 <mem_init+0xf3d>
f01020ac:	68 4d 63 10 f0       	push   $0xf010634d
f01020b1:	68 94 61 10 f0       	push   $0xf0106194
f01020b6:	68 ec 03 00 00       	push   $0x3ec
f01020bb:	68 6e 61 10 f0       	push   $0xf010616e
f01020c0:	e8 2b e0 ff ff       	call   f01000f0 <_panic>
	pp0->pp_ref = 0;
f01020c5:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f01020c8:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f01020ce:	83 ec 0c             	sub    $0xc,%esp
f01020d1:	50                   	push   %eax
f01020d2:	e8 36 ee ff ff       	call   f0100f0d <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f01020d7:	83 c4 0c             	add    $0xc,%esp
f01020da:	6a 01                	push   $0x1
f01020dc:	68 00 10 40 00       	push   $0x401000
f01020e1:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f01020e7:	e8 83 ee ff ff       	call   f0100f6f <pgdir_walk>
f01020ec:	89 c7                	mov    %eax,%edi
f01020ee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f01020f1:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f01020f6:	89 45 cc             	mov    %eax,-0x34(%ebp)
f01020f9:	8b 40 04             	mov    0x4(%eax),%eax
f01020fc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102101:	8b 0d 98 e0 39 f0    	mov    0xf039e098,%ecx
f0102107:	89 c2                	mov    %eax,%edx
f0102109:	c1 ea 0c             	shr    $0xc,%edx
f010210c:	83 c4 10             	add    $0x10,%esp
f010210f:	39 ca                	cmp    %ecx,%edx
f0102111:	72 15                	jb     f0102128 <mem_init+0xfa0>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0102113:	50                   	push   %eax
f0102114:	68 54 64 10 f0       	push   $0xf0106454
f0102119:	68 f3 03 00 00       	push   $0x3f3
f010211e:	68 6e 61 10 f0       	push   $0xf010616e
f0102123:	e8 c8 df ff ff       	call   f01000f0 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102128:	2d fc ff ff 0f       	sub    $0xffffffc,%eax
f010212d:	39 c7                	cmp    %eax,%edi
f010212f:	74 19                	je     f010214a <mem_init+0xfc2>
f0102131:	68 d9 63 10 f0       	push   $0xf01063d9
f0102136:	68 94 61 10 f0       	push   $0xf0106194
f010213b:	68 f4 03 00 00       	push   $0x3f4
f0102140:	68 6e 61 10 f0       	push   $0xf010616e
f0102145:	e8 a6 df ff ff       	call   f01000f0 <_panic>
	kern_pgdir[PDX(va)] = 0;
f010214a:	8b 45 cc             	mov    -0x34(%ebp),%eax
f010214d:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
	pp0->pp_ref = 0;
f0102154:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102157:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010215d:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0102163:	c1 f8 03             	sar    $0x3,%eax
f0102166:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102169:	89 c2                	mov    %eax,%edx
f010216b:	c1 ea 0c             	shr    $0xc,%edx
f010216e:	39 d1                	cmp    %edx,%ecx
f0102170:	77 12                	ja     f0102184 <mem_init+0xffc>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0102172:	50                   	push   %eax
f0102173:	68 54 64 10 f0       	push   $0xf0106454
f0102178:	6a 58                	push   $0x58
f010217a:	68 7a 61 10 f0       	push   $0xf010617a
f010217f:	e8 6c df ff ff       	call   f01000f0 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102184:	83 ec 04             	sub    $0x4,%esp
f0102187:	68 00 10 00 00       	push   $0x1000
f010218c:	68 ff 00 00 00       	push   $0xff
	return (void *)(pa + KERNBASE);
f0102191:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102196:	50                   	push   %eax
f0102197:	e8 e4 31 00 00       	call   f0105380 <memset>
	page_free(pp0);
f010219c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f010219f:	89 3c 24             	mov    %edi,(%esp)
f01021a2:	e8 66 ed ff ff       	call   f0100f0d <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f01021a7:	83 c4 0c             	add    $0xc,%esp
f01021aa:	6a 01                	push   $0x1
f01021ac:	6a 00                	push   $0x0
f01021ae:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f01021b4:	e8 b6 ed ff ff       	call   f0100f6f <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021b9:	89 fa                	mov    %edi,%edx
f01021bb:	2b 15 a0 e0 39 f0    	sub    0xf039e0a0,%edx
f01021c1:	c1 fa 03             	sar    $0x3,%edx
f01021c4:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01021c7:	89 d0                	mov    %edx,%eax
f01021c9:	c1 e8 0c             	shr    $0xc,%eax
f01021cc:	83 c4 10             	add    $0x10,%esp
f01021cf:	3b 05 98 e0 39 f0    	cmp    0xf039e098,%eax
f01021d5:	72 12                	jb     f01021e9 <mem_init+0x1061>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f01021d7:	52                   	push   %edx
f01021d8:	68 54 64 10 f0       	push   $0xf0106454
f01021dd:	6a 58                	push   $0x58
f01021df:	68 7a 61 10 f0       	push   $0xf010617a
f01021e4:	e8 07 df ff ff       	call   f01000f0 <_panic>
	return (void *)(pa + KERNBASE);
f01021e9:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
	ptep = (pte_t *) page2kva(pp0);
f01021ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f01021f2:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f01021f8:	f6 00 01             	testb  $0x1,(%eax)
f01021fb:	74 19                	je     f0102216 <mem_init+0x108e>
f01021fd:	68 f1 63 10 f0       	push   $0xf01063f1
f0102202:	68 94 61 10 f0       	push   $0xf0106194
f0102207:	68 fe 03 00 00       	push   $0x3fe
f010220c:	68 6e 61 10 f0       	push   $0xf010616e
f0102211:	e8 da de ff ff       	call   f01000f0 <_panic>
f0102216:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102219:	39 d0                	cmp    %edx,%eax
f010221b:	75 db                	jne    f01021f8 <mem_init+0x1070>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f010221d:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f0102222:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102228:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f010222b:	66 c7 40 04 00 00    	movw   $0x0,0x4(%eax)

	// give free list back
	page_free_list = fl;
f0102231:	8b 7d d0             	mov    -0x30(%ebp),%edi
f0102234:	89 3d a0 d3 39 f0    	mov    %edi,0xf039d3a0

	// free the pages we took
	page_free(pp0);
f010223a:	83 ec 0c             	sub    $0xc,%esp
f010223d:	50                   	push   %eax
f010223e:	e8 ca ec ff ff       	call   f0100f0d <page_free>
	page_free(pp1);
f0102243:	89 1c 24             	mov    %ebx,(%esp)
f0102246:	e8 c2 ec ff ff       	call   f0100f0d <page_free>
	page_free(pp2);
f010224b:	89 34 24             	mov    %esi,(%esp)
f010224e:	e8 ba ec ff ff       	call   f0100f0d <page_free>

	cprintf("check_page() succeeded!\n");
f0102253:	c7 04 24 08 64 10 f0 	movl   $0xf0106408,(%esp)
f010225a:	e8 e7 14 00 00       	call   f0103746 <cprintf>
	// Permissions:
	//    - the new image at UPAGES -- kernel R, user R
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, UPAGES, npages * sizeof(struct PageInfo), PADDR(pages), PTE_U);
f010225f:	a1 a0 e0 39 f0       	mov    0xf039e0a0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102264:	83 c4 10             	add    $0x10,%esp
f0102267:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010226c:	77 15                	ja     f0102283 <mem_init+0x10fb>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f010226e:	50                   	push   %eax
f010226f:	68 38 65 10 f0       	push   $0xf0106538
f0102274:	68 c4 00 00 00       	push   $0xc4
f0102279:	68 6e 61 10 f0       	push   $0xf010616e
f010227e:	e8 6d de ff ff       	call   f01000f0 <_panic>
f0102283:	83 ec 08             	sub    $0x8,%esp
f0102286:	8b 3d 98 e0 39 f0    	mov    0xf039e098,%edi
f010228c:	8d 0c fd 00 00 00 00 	lea    0x0(,%edi,8),%ecx
f0102293:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f0102295:	05 00 00 00 10       	add    $0x10000000,%eax
f010229a:	50                   	push   %eax
f010229b:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f01022a0:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f01022a5:	e8 58 ed ff ff       	call   f0101002 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t)pages, npages * sizeof(struct PageInfo), PADDR(pages), PTE_W);
f01022aa:	8b 15 a0 e0 39 f0    	mov    0xf039e0a0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022b0:	83 c4 10             	add    $0x10,%esp
f01022b3:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01022b9:	77 15                	ja     f01022d0 <mem_init+0x1148>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f01022bb:	52                   	push   %edx
f01022bc:	68 38 65 10 f0       	push   $0xf0106538
f01022c1:	68 c5 00 00 00       	push   $0xc5
f01022c6:	68 6e 61 10 f0       	push   $0xf010616e
f01022cb:	e8 20 de ff ff       	call   f01000f0 <_panic>
f01022d0:	83 ec 08             	sub    $0x8,%esp
f01022d3:	a1 98 e0 39 f0       	mov    0xf039e098,%eax
f01022d8:	8d 0c c5 00 00 00 00 	lea    0x0(,%eax,8),%ecx
f01022df:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f01022e1:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f01022e7:	50                   	push   %eax
f01022e8:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f01022ed:	e8 10 ed ff ff       	call   f0101002 <boot_map_region>
	// (ie. perm = PTE_U | PTE_P).
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 8: Your code here.
	boot_map_region(kern_pgdir, UENVS, NENV * sizeof(struct Env), PADDR(envs), PTE_U);
f01022f2:	a1 ac d3 39 f0       	mov    0xf039d3ac,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01022f7:	83 c4 10             	add    $0x10,%esp
f01022fa:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01022ff:	77 15                	ja     f0102316 <mem_init+0x118e>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0102301:	50                   	push   %eax
f0102302:	68 38 65 10 f0       	push   $0xf0106538
f0102307:	68 cd 00 00 00       	push   $0xcd
f010230c:	68 6e 61 10 f0       	push   $0xf010616e
f0102311:	e8 da dd ff ff       	call   f01000f0 <_panic>
f0102316:	83 ec 08             	sub    $0x8,%esp
f0102319:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f010231b:	05 00 00 00 10       	add    $0x10000000,%eax
f0102320:	50                   	push   %eax
f0102321:	b9 00 e0 01 00       	mov    $0x1e000,%ecx
f0102326:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010232b:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f0102330:	e8 cd ec ff ff       	call   f0101002 <boot_map_region>
	boot_map_region(kern_pgdir, (uintptr_t)envs, NENV * sizeof(struct Env), PADDR(envs), PTE_W);
f0102335:	8b 15 ac d3 39 f0    	mov    0xf039d3ac,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010233b:	83 c4 10             	add    $0x10,%esp
f010233e:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0102344:	77 15                	ja     f010235b <mem_init+0x11d3>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0102346:	52                   	push   %edx
f0102347:	68 38 65 10 f0       	push   $0xf0106538
f010234c:	68 ce 00 00 00       	push   $0xce
f0102351:	68 6e 61 10 f0       	push   $0xf010616e
f0102356:	e8 95 dd ff ff       	call   f01000f0 <_panic>
f010235b:	83 ec 08             	sub    $0x8,%esp
f010235e:	6a 02                	push   $0x2
	return (physaddr_t)kva - KERNBASE;
f0102360:	8d 82 00 00 00 10    	lea    0x10000000(%edx),%eax
f0102366:	50                   	push   %eax
f0102367:	b9 00 e0 01 00       	mov    $0x1e000,%ecx
f010236c:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f0102371:	e8 8c ec ff ff       	call   f0101002 <boot_map_region>
	// Permissions:
	//    - the new image at UVSYS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 12: Your code here.

	boot_map_region(kern_pgdir, UVSYS, ROUNDUP(NVSYSCALLS * sizeof(int), PGSIZE), PADDR(vsys), PTE_U);
f0102376:	a1 94 e0 39 f0       	mov    0xf039e094,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010237b:	83 c4 10             	add    $0x10,%esp
f010237e:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102383:	77 15                	ja     f010239a <mem_init+0x1212>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0102385:	50                   	push   %eax
f0102386:	68 38 65 10 f0       	push   $0xf0106538
f010238b:	68 d8 00 00 00       	push   $0xd8
f0102390:	68 6e 61 10 f0       	push   $0xf010616e
f0102395:	e8 56 dd ff ff       	call   f01000f0 <_panic>
f010239a:	83 ec 08             	sub    $0x8,%esp
f010239d:	6a 04                	push   $0x4
	return (physaddr_t)kva - KERNBASE;
f010239f:	05 00 00 00 10       	add    $0x10000000,%eax
f01023a4:	50                   	push   %eax
f01023a5:	b9 00 10 00 00       	mov    $0x1000,%ecx
f01023aa:	ba 00 00 80 ee       	mov    $0xee800000,%edx
f01023af:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f01023b4:	e8 49 ec ff ff       	call   f0101002 <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01023b9:	83 c4 10             	add    $0x10,%esp
f01023bc:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f01023c1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01023c6:	77 15                	ja     f01023dd <mem_init+0x1255>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f01023c8:	50                   	push   %eax
f01023c9:	68 38 65 10 f0       	push   $0xf0106538
f01023ce:	68 e5 00 00 00       	push   $0xe5
f01023d3:	68 6e 61 10 f0       	push   $0xf010616e
f01023d8:	e8 13 dd ff ff       	call   f01000f0 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:

	boot_map_region(kern_pgdir, KSTACKTOP - KSTKSIZE, KSTKSIZE, PADDR(bootstack), PTE_W);
f01023dd:	83 ec 08             	sub    $0x8,%esp
f01023e0:	6a 02                	push   $0x2
f01023e2:	68 00 60 11 00       	push   $0x116000
f01023e7:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01023ec:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01023f1:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f01023f6:	e8 07 ec ff ff       	call   f0101002 <boot_map_region>
	//      the PA range [0, 2^32 - KERNBASE)
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	boot_map_region(kern_pgdir, KERNBASE, ~KERNBASE + 1, 0, PTE_W);
f01023fb:	83 c4 08             	add    $0x8,%esp
f01023fe:	6a 02                	push   $0x2
f0102400:	6a 00                	push   $0x0
f0102402:	b9 00 00 00 10       	mov    $0x10000000,%ecx
f0102407:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010240c:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
f0102411:	e8 ec eb ff ff       	call   f0101002 <boot_map_region>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0102416:	8b 35 9c e0 39 f0    	mov    0xf039e09c,%esi

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f010241c:	a1 98 e0 39 f0       	mov    0xf039e098,%eax
f0102421:	89 45 cc             	mov    %eax,-0x34(%ebp)
f0102424:	8d 04 c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%eax
f010242b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0102430:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f0102433:	8b 3d a0 e0 39 f0    	mov    0xf039e0a0,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102439:	89 7d d0             	mov    %edi,-0x30(%ebp)
f010243c:	83 c4 10             	add    $0x10,%esp

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010243f:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102444:	eb 55                	jmp    f010249b <mem_init+0x1313>
f0102446:	8d 93 00 00 00 ef    	lea    -0x11000000(%ebx),%edx
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f010244c:	89 f0                	mov    %esi,%eax
f010244e:	e8 82 e6 ff ff       	call   f0100ad5 <check_va2pa>
f0102453:	81 7d d0 ff ff ff ef 	cmpl   $0xefffffff,-0x30(%ebp)
f010245a:	77 15                	ja     f0102471 <mem_init+0x12e9>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f010245c:	57                   	push   %edi
f010245d:	68 38 65 10 f0       	push   $0xf0106538
f0102462:	68 3b 03 00 00       	push   $0x33b
f0102467:	68 6e 61 10 f0       	push   $0xf010616e
f010246c:	e8 7f dc ff ff       	call   f01000f0 <_panic>
f0102471:	8d 94 1f 00 00 00 10 	lea    0x10000000(%edi,%ebx,1),%edx
f0102478:	39 d0                	cmp    %edx,%eax
f010247a:	74 19                	je     f0102495 <mem_init+0x130d>
f010247c:	68 40 6a 10 f0       	push   $0xf0106a40
f0102481:	68 94 61 10 f0       	push   $0xf0106194
f0102486:	68 3b 03 00 00       	push   $0x33b
f010248b:	68 6e 61 10 f0       	push   $0xf010616e
f0102490:	e8 5b dc ff ff       	call   f01000f0 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0102495:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f010249b:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f010249e:	77 a6                	ja     f0102446 <mem_init+0x12be>
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 8)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f01024a0:	8b 3d ac d3 39 f0    	mov    0xf039d3ac,%edi
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01024a6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f01024a9:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
f01024ae:	89 da                	mov    %ebx,%edx
f01024b0:	89 f0                	mov    %esi,%eax
f01024b2:	e8 1e e6 ff ff       	call   f0100ad5 <check_va2pa>
f01024b7:	81 7d d4 ff ff ff ef 	cmpl   $0xefffffff,-0x2c(%ebp)
f01024be:	77 15                	ja     f01024d5 <mem_init+0x134d>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f01024c0:	57                   	push   %edi
f01024c1:	68 38 65 10 f0       	push   $0xf0106538
f01024c6:	68 40 03 00 00       	push   $0x340
f01024cb:	68 6e 61 10 f0       	push   $0xf010616e
f01024d0:	e8 1b dc ff ff       	call   f01000f0 <_panic>
f01024d5:	8d 94 1f 00 00 40 21 	lea    0x21400000(%edi,%ebx,1),%edx
f01024dc:	39 d0                	cmp    %edx,%eax
f01024de:	74 19                	je     f01024f9 <mem_init+0x1371>
f01024e0:	68 74 6a 10 f0       	push   $0xf0106a74
f01024e5:	68 94 61 10 f0       	push   $0xf0106194
f01024ea:	68 40 03 00 00       	push   $0x340
f01024ef:	68 6e 61 10 f0       	push   $0xf010616e
f01024f4:	e8 f7 db ff ff       	call   f01000f0 <_panic>
f01024f9:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 8)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f01024ff:	81 fb 00 e0 c1 ee    	cmp    $0xeec1e000,%ebx
f0102505:	75 a7                	jne    f01024ae <mem_init+0x1326>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102507:	8b 7d cc             	mov    -0x34(%ebp),%edi
f010250a:	c1 e7 0c             	shl    $0xc,%edi
f010250d:	bb 00 00 00 00       	mov    $0x0,%ebx
f0102512:	eb 30                	jmp    f0102544 <mem_init+0x13bc>
f0102514:	8d 93 00 00 00 f0    	lea    -0x10000000(%ebx),%edx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f010251a:	89 f0                	mov    %esi,%eax
f010251c:	e8 b4 e5 ff ff       	call   f0100ad5 <check_va2pa>
f0102521:	39 c3                	cmp    %eax,%ebx
f0102523:	74 19                	je     f010253e <mem_init+0x13b6>
f0102525:	68 a8 6a 10 f0       	push   $0xf0106aa8
f010252a:	68 94 61 10 f0       	push   $0xf0106194
f010252f:	68 44 03 00 00       	push   $0x344
f0102534:	68 6e 61 10 f0       	push   $0xf010616e
f0102539:	e8 b2 db ff ff       	call   f01000f0 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f010253e:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102544:	39 fb                	cmp    %edi,%ebx
f0102546:	72 cc                	jb     f0102514 <mem_init+0x138c>
f0102548:	bb 00 80 ff ef       	mov    $0xefff8000,%ebx
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
f010254d:	89 da                	mov    %ebx,%edx
f010254f:	89 f0                	mov    %esi,%eax
f0102551:	e8 7f e5 ff ff       	call   f0100ad5 <check_va2pa>
f0102556:	8d 93 00 e0 11 10    	lea    0x1011e000(%ebx),%edx
f010255c:	39 c2                	cmp    %eax,%edx
f010255e:	74 19                	je     f0102579 <mem_init+0x13f1>
f0102560:	68 d0 6a 10 f0       	push   $0xf0106ad0
f0102565:	68 94 61 10 f0       	push   $0xf0106194
f010256a:	68 48 03 00 00       	push   $0x348
f010256f:	68 6e 61 10 f0       	push   $0xf010616e
f0102574:	e8 77 db ff ff       	call   f01000f0 <_panic>
f0102579:	81 c3 00 10 00 00    	add    $0x1000,%ebx
	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010257f:	81 fb 00 00 00 f0    	cmp    $0xf0000000,%ebx
f0102585:	75 c6                	jne    f010254d <mem_init+0x13c5>
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f0102587:	ba 00 00 c0 ef       	mov    $0xefc00000,%edx
f010258c:	89 f0                	mov    %esi,%eax
f010258e:	e8 42 e5 ff ff       	call   f0100ad5 <check_va2pa>
f0102593:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102596:	74 30                	je     f01025c8 <mem_init+0x1440>
f0102598:	68 18 6b 10 f0       	push   $0xf0106b18
f010259d:	68 94 61 10 f0       	push   $0xf0106194
f01025a2:	68 49 03 00 00       	push   $0x349
f01025a7:	68 6e 61 10 f0       	push   $0xf010616e
f01025ac:	e8 3f db ff ff       	call   f01000f0 <_panic>

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f01025b1:	3d ba 03 00 00       	cmp    $0x3ba,%eax
f01025b6:	72 15                	jb     f01025cd <mem_init+0x1445>
f01025b8:	3d bd 03 00 00       	cmp    $0x3bd,%eax
f01025bd:	76 73                	jbe    f0102632 <mem_init+0x14aa>
f01025bf:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01025c4:	74 6c                	je     f0102632 <mem_init+0x14aa>
f01025c6:	eb 05                	jmp    f01025cd <mem_init+0x1445>
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
f01025c8:	b8 00 00 00 00       	mov    $0x0,%eax
		case PDX(UENVS):
		case PDX(UVSYS):
			//assert(pgdir[i] & PTE_P);
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f01025cd:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f01025d2:	76 3f                	jbe    f0102613 <mem_init+0x148b>
				assert(pgdir[i] & PTE_P);
f01025d4:	8b 14 86             	mov    (%esi,%eax,4),%edx
f01025d7:	f6 c2 01             	test   $0x1,%dl
f01025da:	75 19                	jne    f01025f5 <mem_init+0x146d>
f01025dc:	68 21 64 10 f0       	push   $0xf0106421
f01025e1:	68 94 61 10 f0       	push   $0xf0106194
f01025e6:	68 57 03 00 00       	push   $0x357
f01025eb:	68 6e 61 10 f0       	push   $0xf010616e
f01025f0:	e8 fb da ff ff       	call   f01000f0 <_panic>
				assert(pgdir[i] & PTE_W);
f01025f5:	f6 c2 02             	test   $0x2,%dl
f01025f8:	75 38                	jne    f0102632 <mem_init+0x14aa>
f01025fa:	68 32 64 10 f0       	push   $0xf0106432
f01025ff:	68 94 61 10 f0       	push   $0xf0106194
f0102604:	68 58 03 00 00       	push   $0x358
f0102609:	68 6e 61 10 f0       	push   $0xf010616e
f010260e:	e8 dd da ff ff       	call   f01000f0 <_panic>
			} else
				assert(pgdir[i] == 0);
f0102613:	83 3c 86 00          	cmpl   $0x0,(%esi,%eax,4)
f0102617:	74 19                	je     f0102632 <mem_init+0x14aa>
f0102619:	68 43 64 10 f0       	push   $0xf0106443
f010261e:	68 94 61 10 f0       	push   $0xf0106194
f0102623:	68 5a 03 00 00       	push   $0x35a
f0102628:	68 6e 61 10 f0       	push   $0xf010616e
f010262d:	e8 be da ff ff       	call   f01000f0 <_panic>
	for (i = 0; i < KSTKSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
	assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f0102632:	83 c0 01             	add    $0x1,%eax
f0102635:	3d ff 03 00 00       	cmp    $0x3ff,%eax
f010263a:	0f 86 71 ff ff ff    	jbe    f01025b1 <mem_init+0x1429>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f0102640:	83 ec 0c             	sub    $0xc,%esp
f0102643:	68 48 6b 10 f0       	push   $0xf0106b48
f0102648:	e8 f9 10 00 00       	call   f0103746 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f010264d:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102652:	83 c4 10             	add    $0x10,%esp
f0102655:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010265a:	77 15                	ja     f0102671 <mem_init+0x14e9>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f010265c:	50                   	push   %eax
f010265d:	68 38 65 10 f0       	push   $0xf0106538
f0102662:	68 f9 00 00 00       	push   $0xf9
f0102667:	68 6e 61 10 f0       	push   $0xf010616e
f010266c:	e8 7f da ff ff       	call   f01000f0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102671:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102676:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0102679:	b8 00 00 00 00       	mov    $0x0,%eax
f010267e:	e8 b3 e4 ff ff       	call   f0100b36 <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f0102683:	0f 20 c0             	mov    %cr0,%eax
	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	{
		uint32_t cr0 = rcr0();
		cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
		cr0 &= ~(CR0_TS|CR0_EM);
f0102686:	83 e0 f3             	and    $0xfffffff3,%eax
f0102689:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f010268e:	0f 22 c0             	mov    %eax,%cr0
{
	struct PageInfo *pp0, *pp1, *pp2;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0102691:	83 ec 0c             	sub    $0xc,%esp
f0102694:	6a 00                	push   $0x0
f0102696:	e8 fb e7 ff ff       	call   f0100e96 <page_alloc>
f010269b:	89 c3                	mov    %eax,%ebx
f010269d:	83 c4 10             	add    $0x10,%esp
f01026a0:	85 c0                	test   %eax,%eax
f01026a2:	75 19                	jne    f01026bd <mem_init+0x1535>
f01026a4:	68 3f 62 10 f0       	push   $0xf010623f
f01026a9:	68 94 61 10 f0       	push   $0xf0106194
f01026ae:	68 15 04 00 00       	push   $0x415
f01026b3:	68 6e 61 10 f0       	push   $0xf010616e
f01026b8:	e8 33 da ff ff       	call   f01000f0 <_panic>
	assert((pp1 = page_alloc(0)));
f01026bd:	83 ec 0c             	sub    $0xc,%esp
f01026c0:	6a 00                	push   $0x0
f01026c2:	e8 cf e7 ff ff       	call   f0100e96 <page_alloc>
f01026c7:	89 c7                	mov    %eax,%edi
f01026c9:	83 c4 10             	add    $0x10,%esp
f01026cc:	85 c0                	test   %eax,%eax
f01026ce:	75 19                	jne    f01026e9 <mem_init+0x1561>
f01026d0:	68 55 62 10 f0       	push   $0xf0106255
f01026d5:	68 94 61 10 f0       	push   $0xf0106194
f01026da:	68 16 04 00 00       	push   $0x416
f01026df:	68 6e 61 10 f0       	push   $0xf010616e
f01026e4:	e8 07 da ff ff       	call   f01000f0 <_panic>
	assert((pp2 = page_alloc(0)));
f01026e9:	83 ec 0c             	sub    $0xc,%esp
f01026ec:	6a 00                	push   $0x0
f01026ee:	e8 a3 e7 ff ff       	call   f0100e96 <page_alloc>
f01026f3:	89 c6                	mov    %eax,%esi
f01026f5:	83 c4 10             	add    $0x10,%esp
f01026f8:	85 c0                	test   %eax,%eax
f01026fa:	75 19                	jne    f0102715 <mem_init+0x158d>
f01026fc:	68 6b 62 10 f0       	push   $0xf010626b
f0102701:	68 94 61 10 f0       	push   $0xf0106194
f0102706:	68 17 04 00 00       	push   $0x417
f010270b:	68 6e 61 10 f0       	push   $0xf010616e
f0102710:	e8 db d9 ff ff       	call   f01000f0 <_panic>
	page_free(pp0);
f0102715:	83 ec 0c             	sub    $0xc,%esp
f0102718:	53                   	push   %ebx
f0102719:	e8 ef e7 ff ff       	call   f0100f0d <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010271e:	89 f8                	mov    %edi,%eax
f0102720:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0102726:	c1 f8 03             	sar    $0x3,%eax
f0102729:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010272c:	89 c2                	mov    %eax,%edx
f010272e:	c1 ea 0c             	shr    $0xc,%edx
f0102731:	83 c4 10             	add    $0x10,%esp
f0102734:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f010273a:	72 12                	jb     f010274e <mem_init+0x15c6>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f010273c:	50                   	push   %eax
f010273d:	68 54 64 10 f0       	push   $0xf0106454
f0102742:	6a 58                	push   $0x58
f0102744:	68 7a 61 10 f0       	push   $0xf010617a
f0102749:	e8 a2 d9 ff ff       	call   f01000f0 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f010274e:	83 ec 04             	sub    $0x4,%esp
f0102751:	68 00 10 00 00       	push   $0x1000
f0102756:	6a 01                	push   $0x1
	return (void *)(pa + KERNBASE);
f0102758:	2d 00 00 00 10       	sub    $0x10000000,%eax
f010275d:	50                   	push   %eax
f010275e:	e8 1d 2c 00 00       	call   f0105380 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102763:	89 f0                	mov    %esi,%eax
f0102765:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f010276b:	c1 f8 03             	sar    $0x3,%eax
f010276e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102771:	89 c2                	mov    %eax,%edx
f0102773:	c1 ea 0c             	shr    $0xc,%edx
f0102776:	83 c4 10             	add    $0x10,%esp
f0102779:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f010277f:	72 12                	jb     f0102793 <mem_init+0x160b>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0102781:	50                   	push   %eax
f0102782:	68 54 64 10 f0       	push   $0xf0106454
f0102787:	6a 58                	push   $0x58
f0102789:	68 7a 61 10 f0       	push   $0xf010617a
f010278e:	e8 5d d9 ff ff       	call   f01000f0 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f0102793:	83 ec 04             	sub    $0x4,%esp
f0102796:	68 00 10 00 00       	push   $0x1000
f010279b:	6a 02                	push   $0x2
	return (void *)(pa + KERNBASE);
f010279d:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01027a2:	50                   	push   %eax
f01027a3:	e8 d8 2b 00 00       	call   f0105380 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f01027a8:	6a 02                	push   $0x2
f01027aa:	68 00 10 00 00       	push   $0x1000
f01027af:	57                   	push   %edi
f01027b0:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f01027b6:	e8 65 e9 ff ff       	call   f0101120 <page_insert>
	assert(pp1->pp_ref == 1);
f01027bb:	83 c4 20             	add    $0x20,%esp
f01027be:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f01027c3:	74 19                	je     f01027de <mem_init+0x1656>
f01027c5:	68 3c 63 10 f0       	push   $0xf010633c
f01027ca:	68 94 61 10 f0       	push   $0xf0106194
f01027cf:	68 1c 04 00 00       	push   $0x41c
f01027d4:	68 6e 61 10 f0       	push   $0xf010616e
f01027d9:	e8 12 d9 ff ff       	call   f01000f0 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01027de:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01027e5:	01 01 01 
f01027e8:	74 19                	je     f0102803 <mem_init+0x167b>
f01027ea:	68 68 6b 10 f0       	push   $0xf0106b68
f01027ef:	68 94 61 10 f0       	push   $0xf0106194
f01027f4:	68 1d 04 00 00       	push   $0x41d
f01027f9:	68 6e 61 10 f0       	push   $0xf010616e
f01027fe:	e8 ed d8 ff ff       	call   f01000f0 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f0102803:	6a 02                	push   $0x2
f0102805:	68 00 10 00 00       	push   $0x1000
f010280a:	56                   	push   %esi
f010280b:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0102811:	e8 0a e9 ff ff       	call   f0101120 <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102816:	83 c4 10             	add    $0x10,%esp
f0102819:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f0102820:	02 02 02 
f0102823:	74 19                	je     f010283e <mem_init+0x16b6>
f0102825:	68 8c 6b 10 f0       	push   $0xf0106b8c
f010282a:	68 94 61 10 f0       	push   $0xf0106194
f010282f:	68 1f 04 00 00       	push   $0x41f
f0102834:	68 6e 61 10 f0       	push   $0xf010616e
f0102839:	e8 b2 d8 ff ff       	call   f01000f0 <_panic>
	assert(pp2->pp_ref == 1);
f010283e:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102843:	74 19                	je     f010285e <mem_init+0x16d6>
f0102845:	68 5e 63 10 f0       	push   $0xf010635e
f010284a:	68 94 61 10 f0       	push   $0xf0106194
f010284f:	68 20 04 00 00       	push   $0x420
f0102854:	68 6e 61 10 f0       	push   $0xf010616e
f0102859:	e8 92 d8 ff ff       	call   f01000f0 <_panic>
	assert(pp1->pp_ref == 0);
f010285e:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102863:	74 19                	je     f010287e <mem_init+0x16f6>
f0102865:	68 c8 63 10 f0       	push   $0xf01063c8
f010286a:	68 94 61 10 f0       	push   $0xf0106194
f010286f:	68 21 04 00 00       	push   $0x421
f0102874:	68 6e 61 10 f0       	push   $0xf010616e
f0102879:	e8 72 d8 ff ff       	call   f01000f0 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010287e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0102885:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102888:	89 f0                	mov    %esi,%eax
f010288a:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0102890:	c1 f8 03             	sar    $0x3,%eax
f0102893:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102896:	89 c2                	mov    %eax,%edx
f0102898:	c1 ea 0c             	shr    $0xc,%edx
f010289b:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f01028a1:	72 12                	jb     f01028b5 <mem_init+0x172d>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f01028a3:	50                   	push   %eax
f01028a4:	68 54 64 10 f0       	push   $0xf0106454
f01028a9:	6a 58                	push   $0x58
f01028ab:	68 7a 61 10 f0       	push   $0xf010617a
f01028b0:	e8 3b d8 ff ff       	call   f01000f0 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01028b5:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01028bc:	03 03 03 
f01028bf:	74 19                	je     f01028da <mem_init+0x1752>
f01028c1:	68 b0 6b 10 f0       	push   $0xf0106bb0
f01028c6:	68 94 61 10 f0       	push   $0xf0106194
f01028cb:	68 23 04 00 00       	push   $0x423
f01028d0:	68 6e 61 10 f0       	push   $0xf010616e
f01028d5:	e8 16 d8 ff ff       	call   f01000f0 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01028da:	83 ec 08             	sub    $0x8,%esp
f01028dd:	68 00 10 00 00       	push   $0x1000
f01028e2:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f01028e8:	e8 e5 e7 ff ff       	call   f01010d2 <page_remove>
	assert(pp2->pp_ref == 0);
f01028ed:	83 c4 10             	add    $0x10,%esp
f01028f0:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f01028f5:	74 19                	je     f0102910 <mem_init+0x1788>
f01028f7:	68 96 63 10 f0       	push   $0xf0106396
f01028fc:	68 94 61 10 f0       	push   $0xf0106194
f0102901:	68 25 04 00 00       	push   $0x425
f0102906:	68 6e 61 10 f0       	push   $0xf010616e
f010290b:	e8 e0 d7 ff ff       	call   f01000f0 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102910:	8b 0d 9c e0 39 f0    	mov    0xf039e09c,%ecx
f0102916:	8b 11                	mov    (%ecx),%edx
f0102918:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010291e:	89 d8                	mov    %ebx,%eax
f0102920:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0102926:	c1 f8 03             	sar    $0x3,%eax
f0102929:	c1 e0 0c             	shl    $0xc,%eax
f010292c:	39 c2                	cmp    %eax,%edx
f010292e:	74 19                	je     f0102949 <mem_init+0x17c1>
f0102930:	68 c0 66 10 f0       	push   $0xf01066c0
f0102935:	68 94 61 10 f0       	push   $0xf0106194
f010293a:	68 28 04 00 00       	push   $0x428
f010293f:	68 6e 61 10 f0       	push   $0xf010616e
f0102944:	e8 a7 d7 ff ff       	call   f01000f0 <_panic>
	kern_pgdir[0] = 0;
f0102949:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	assert(pp0->pp_ref == 1);
f010294f:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102954:	74 19                	je     f010296f <mem_init+0x17e7>
f0102956:	68 4d 63 10 f0       	push   $0xf010634d
f010295b:	68 94 61 10 f0       	push   $0xf0106194
f0102960:	68 2a 04 00 00       	push   $0x42a
f0102965:	68 6e 61 10 f0       	push   $0xf010616e
f010296a:	e8 81 d7 ff ff       	call   f01000f0 <_panic>
	pp0->pp_ref = 0;
f010296f:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f0102975:	83 ec 0c             	sub    $0xc,%esp
f0102978:	53                   	push   %ebx
f0102979:	e8 8f e5 ff ff       	call   f0100f0d <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f010297e:	c7 04 24 dc 6b 10 f0 	movl   $0xf0106bdc,(%esp)
f0102985:	e8 bc 0d 00 00       	call   f0103746 <cprintf>
f010298a:	83 c4 10             	add    $0x10,%esp
		lcr0(cr0);
	}

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
}
f010298d:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102990:	5b                   	pop    %ebx
f0102991:	5e                   	pop    %esi
f0102992:	5f                   	pop    %edi
f0102993:	5d                   	pop    %ebp
f0102994:	c3                   	ret    

f0102995 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0102995:	55                   	push   %ebp
f0102996:	89 e5                	mov    %esp,%ebp
f0102998:	83 ec 0c             	sub    $0xc,%esp
	// okay to simply panic if this happens).
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	panic("mmio_map_region not implemented");
f010299b:	68 08 6c 10 f0       	push   $0xf0106c08
f01029a0:	68 5d 02 00 00       	push   $0x25d
f01029a5:	68 6e 61 10 f0       	push   $0xf010616e
f01029aa:	e8 41 d7 ff ff       	call   f01000f0 <_panic>

f01029af <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01029af:	55                   	push   %ebp
f01029b0:	89 e5                	mov    %esp,%ebp
f01029b2:	57                   	push   %edi
f01029b3:	56                   	push   %esi
f01029b4:	53                   	push   %ebx
f01029b5:	83 ec 1c             	sub    $0x1c,%esp
f01029b8:	8b 7d 08             	mov    0x8(%ebp),%edi
f01029bb:	8b 75 14             	mov    0x14(%ebp),%esi
	// LAB 8: Your code here.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
f01029be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01029c1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	uint32_t end   = (uint32_t) ROUNDUP(va+len, PGSIZE);
f01029c7:	8b 45 0c             	mov    0xc(%ebp),%eax
f01029ca:	03 45 10             	add    0x10(%ebp),%eax
f01029cd:	05 ff 0f 00 00       	add    $0xfff,%eax
f01029d2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f01029d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	uint32_t i;
	for (i = begin; i < end; i+=PGSIZE) {
f01029da:	eb 50                	jmp    f0102a2c <user_mem_check+0x7d>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
f01029dc:	83 ec 04             	sub    $0x4,%esp
f01029df:	6a 00                	push   $0x0
f01029e1:	53                   	push   %ebx
f01029e2:	ff 77 5c             	pushl  0x5c(%edi)
f01029e5:	e8 85 e5 ff ff       	call   f0100f6f <pgdir_walk>
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
f01029ea:	83 c4 10             	add    $0x10,%esp
f01029ed:	85 c0                	test   %eax,%eax
f01029ef:	74 14                	je     f0102a05 <user_mem_check+0x56>
f01029f1:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01029f7:	77 0c                	ja     f0102a05 <user_mem_check+0x56>
f01029f9:	8b 00                	mov    (%eax),%eax
f01029fb:	a8 01                	test   $0x1,%al
f01029fd:	74 06                	je     f0102a05 <user_mem_check+0x56>
f01029ff:	21 f0                	and    %esi,%eax
f0102a01:	39 c6                	cmp    %eax,%esi
f0102a03:	74 21                	je     f0102a26 <user_mem_check+0x77>
			if (i < (uint32_t)va) {
f0102a05:	39 5d 0c             	cmp    %ebx,0xc(%ebp)
f0102a08:	76 0f                	jbe    f0102a19 <user_mem_check+0x6a>
				user_mem_check_addr = (uint32_t)va;
f0102a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102a0d:	a3 9c d3 39 f0       	mov    %eax,0xf039d39c
			} else {
				user_mem_check_addr = i;
			}
			return -E_FAULT;
f0102a12:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102a17:	eb 1d                	jmp    f0102a36 <user_mem_check+0x87>
		pte_t *pte = pgdir_walk(env->env_pgdir, (void*)i, 0);
		if ((i>=ULIM) || !pte || !(*pte & PTE_P) || ((*pte & perm) != perm)) {
			if (i < (uint32_t)va) {
				user_mem_check_addr = (uint32_t)va;
			} else {
				user_mem_check_addr = i;
f0102a19:	89 1d 9c d3 39 f0    	mov    %ebx,0xf039d39c
			}
			return -E_FAULT;
f0102a1f:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
f0102a24:	eb 10                	jmp    f0102a36 <user_mem_check+0x87>
{
	// LAB 8: Your code here.
	uint32_t begin = (uint32_t) ROUNDDOWN(va, PGSIZE); 
	uint32_t end   = (uint32_t) ROUNDUP(va+len, PGSIZE);
	uint32_t i;
	for (i = begin; i < end; i+=PGSIZE) {
f0102a26:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102a2c:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
f0102a2f:	72 ab                	jb     f01029dc <user_mem_check+0x2d>
				user_mem_check_addr = i;
			}
			return -E_FAULT;
		}
	}
	return 0;
f0102a31:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102a36:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102a39:	5b                   	pop    %ebx
f0102a3a:	5e                   	pop    %esi
f0102a3b:	5f                   	pop    %edi
f0102a3c:	5d                   	pop    %ebp
f0102a3d:	c3                   	ret    

f0102a3e <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0102a3e:	55                   	push   %ebp
f0102a3f:	89 e5                	mov    %esp,%ebp
f0102a41:	53                   	push   %ebx
f0102a42:	83 ec 04             	sub    $0x4,%esp
f0102a45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f0102a48:	8b 45 14             	mov    0x14(%ebp),%eax
f0102a4b:	83 c8 04             	or     $0x4,%eax
f0102a4e:	50                   	push   %eax
f0102a4f:	ff 75 10             	pushl  0x10(%ebp)
f0102a52:	ff 75 0c             	pushl  0xc(%ebp)
f0102a55:	53                   	push   %ebx
f0102a56:	e8 54 ff ff ff       	call   f01029af <user_mem_check>
f0102a5b:	83 c4 10             	add    $0x10,%esp
f0102a5e:	85 c0                	test   %eax,%eax
f0102a60:	79 21                	jns    f0102a83 <user_mem_assert+0x45>
		cprintf("[%08x] user_mem_check assertion failure for "
f0102a62:	83 ec 04             	sub    $0x4,%esp
f0102a65:	ff 35 9c d3 39 f0    	pushl  0xf039d39c
f0102a6b:	ff 73 48             	pushl  0x48(%ebx)
f0102a6e:	68 28 6c 10 f0       	push   $0xf0106c28
f0102a73:	e8 ce 0c 00 00       	call   f0103746 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f0102a78:	89 1c 24             	mov    %ebx,(%esp)
f0102a7b:	e8 ea 05 00 00       	call   f010306a <env_destroy>
f0102a80:	83 c4 10             	add    $0x10,%esp
	}
}
f0102a83:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102a86:	c9                   	leave  
f0102a87:	c3                   	ret    

f0102a88 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0102a88:	55                   	push   %ebp
f0102a89:	89 e5                	mov    %esp,%ebp
f0102a8b:	57                   	push   %edi
f0102a8c:	56                   	push   %esi
f0102a8d:	53                   	push   %ebx
f0102a8e:	83 ec 0c             	sub    $0xc,%esp
f0102a91:	89 c7                	mov    %eax,%edi
	//
	// Hint: It is easier to use region_alloc if the caller can pass
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *begin = ROUNDDOWN(va, PGSIZE);
f0102a93:	89 d3                	mov    %edx,%ebx
f0102a95:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	void *end = ROUNDUP(va+len, PGSIZE);
f0102a9b:	8d b4 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%esi
f0102aa2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
	for (; begin < end; begin += PGSIZE) {
f0102aa8:	eb 3d                	jmp    f0102ae7 <region_alloc+0x5f>
		struct PageInfo *pg = page_alloc(0);	//not initialized
f0102aaa:	83 ec 0c             	sub    $0xc,%esp
f0102aad:	6a 00                	push   $0x0
f0102aaf:	e8 e2 e3 ff ff       	call   f0100e96 <page_alloc>
		if (!pg) panic("region_alloc failed!");
f0102ab4:	83 c4 10             	add    $0x10,%esp
f0102ab7:	85 c0                	test   %eax,%eax
f0102ab9:	75 17                	jne    f0102ad2 <region_alloc+0x4a>
f0102abb:	83 ec 04             	sub    $0x4,%esp
f0102abe:	68 5d 6c 10 f0       	push   $0xf0106c5d
f0102ac3:	68 3b 01 00 00       	push   $0x13b
f0102ac8:	68 72 6c 10 f0       	push   $0xf0106c72
f0102acd:	e8 1e d6 ff ff       	call   f01000f0 <_panic>
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
f0102ad2:	6a 06                	push   $0x6
f0102ad4:	53                   	push   %ebx
f0102ad5:	50                   	push   %eax
f0102ad6:	ff 77 5c             	pushl  0x5c(%edi)
f0102ad9:	e8 42 e6 ff ff       	call   f0101120 <page_insert>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	void *begin = ROUNDDOWN(va, PGSIZE);
	void *end = ROUNDUP(va+len, PGSIZE);
	for (; begin < end; begin += PGSIZE) {
f0102ade:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0102ae4:	83 c4 10             	add    $0x10,%esp
f0102ae7:	39 f3                	cmp    %esi,%ebx
f0102ae9:	72 bf                	jb     f0102aaa <region_alloc+0x22>
		struct PageInfo *pg = page_alloc(0);	//not initialized
		if (!pg) panic("region_alloc failed!");
		page_insert(e->env_pgdir, pg, begin, PTE_W | PTE_U);
	}
}
f0102aeb:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102aee:	5b                   	pop    %ebx
f0102aef:	5e                   	pop    %esi
f0102af0:	5f                   	pop    %edi
f0102af1:	5d                   	pop    %ebp
f0102af2:	c3                   	ret    

f0102af3 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0102af3:	55                   	push   %ebp
f0102af4:	89 e5                	mov    %esp,%ebp
f0102af6:	8b 55 08             	mov    0x8(%ebp),%edx
f0102af9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0102afc:	85 d2                	test   %edx,%edx
f0102afe:	75 11                	jne    f0102b11 <envid2env+0x1e>
		*env_store = curenv;
f0102b00:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f0102b05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102b08:	89 01                	mov    %eax,(%ecx)
		return 0;
f0102b0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0102b0f:	eb 5b                	jmp    f0102b6c <envid2env+0x79>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f0102b11:	89 d0                	mov    %edx,%eax
f0102b13:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102b18:	6b c0 78             	imul   $0x78,%eax,%eax
f0102b1b:	03 05 ac d3 39 f0    	add    0xf039d3ac,%eax
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f0102b21:	83 78 54 00          	cmpl   $0x0,0x54(%eax)
f0102b25:	74 05                	je     f0102b2c <envid2env+0x39>
f0102b27:	39 50 48             	cmp    %edx,0x48(%eax)
f0102b2a:	74 10                	je     f0102b3c <envid2env+0x49>
		*env_store = 0;
f0102b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102b35:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102b3a:	eb 30                	jmp    f0102b6c <envid2env+0x79>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0102b3c:	84 c9                	test   %cl,%cl
f0102b3e:	74 22                	je     f0102b62 <envid2env+0x6f>
f0102b40:	8b 15 a8 d3 39 f0    	mov    0xf039d3a8,%edx
f0102b46:	39 d0                	cmp    %edx,%eax
f0102b48:	74 18                	je     f0102b62 <envid2env+0x6f>
f0102b4a:	8b 4a 48             	mov    0x48(%edx),%ecx
f0102b4d:	39 48 4c             	cmp    %ecx,0x4c(%eax)
f0102b50:	74 10                	je     f0102b62 <envid2env+0x6f>
		*env_store = 0;
f0102b52:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102b55:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		return -E_BAD_ENV;
f0102b5b:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
f0102b60:	eb 0a                	jmp    f0102b6c <envid2env+0x79>
	}

	*env_store = e;
f0102b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0102b65:	89 01                	mov    %eax,(%ecx)
	return 0;
f0102b67:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0102b6c:	5d                   	pop    %ebp
f0102b6d:	c3                   	ret    

f0102b6e <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0102b6e:	55                   	push   %ebp
f0102b6f:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0102b71:	b8 00 13 12 f0       	mov    $0xf0121300,%eax
f0102b76:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f0102b79:	b8 23 00 00 00       	mov    $0x23,%eax
f0102b7e:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0102b80:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0102b82:	b0 10                	mov    $0x10,%al
f0102b84:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0102b86:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f0102b88:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f0102b8a:	ea 91 2b 10 f0 08 00 	ljmp   $0x8,$0xf0102b91
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f0102b91:	b0 00                	mov    $0x0,%al
f0102b93:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f0102b96:	5d                   	pop    %ebp
f0102b97:	c3                   	ret    

f0102b98 <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f0102b98:	55                   	push   %ebp
f0102b99:	89 e5                	mov    %esp,%ebp
f0102b9b:	56                   	push   %esi
f0102b9c:	53                   	push   %ebx
	// Set up envs array
	//LAB 3: Your code here.
	int i = 0;	
	for (i = 0; i < NENV; i++) {
		envs[i].env_link = &envs[(i + 1) % NENV];
f0102b9d:	8b 1d ac d3 39 f0    	mov    0xf039d3ac,%ebx
f0102ba3:	8d 4b 44             	lea    0x44(%ebx),%ecx
env_init(void)
{
	// Set up envs array
	//LAB 3: Your code here.
	int i = 0;	
	for (i = 0; i < NENV; i++) {
f0102ba6:	ba 00 00 00 00       	mov    $0x0,%edx
		envs[i].env_link = &envs[(i + 1) % NENV];
f0102bab:	83 c2 01             	add    $0x1,%edx
f0102bae:	89 d6                	mov    %edx,%esi
f0102bb0:	c1 fe 1f             	sar    $0x1f,%esi
f0102bb3:	c1 ee 16             	shr    $0x16,%esi
f0102bb6:	8d 04 32             	lea    (%edx,%esi,1),%eax
f0102bb9:	25 ff 03 00 00       	and    $0x3ff,%eax
f0102bbe:	29 f0                	sub    %esi,%eax
f0102bc0:	6b c0 78             	imul   $0x78,%eax,%eax
f0102bc3:	01 d8                	add    %ebx,%eax
f0102bc5:	89 01                	mov    %eax,(%ecx)
		envs[i].env_id = 0;
f0102bc7:	c7 41 04 00 00 00 00 	movl   $0x0,0x4(%ecx)
		envs[i].env_status = ENV_FREE;
f0102bce:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
f0102bd5:	83 c1 78             	add    $0x78,%ecx
env_init(void)
{
	// Set up envs array
	//LAB 3: Your code here.
	int i = 0;	
	for (i = 0; i < NENV; i++) {
f0102bd8:	81 fa 00 04 00 00    	cmp    $0x400,%edx
f0102bde:	75 cb                	jne    f0102bab <env_init+0x13>
		envs[i].env_link = &envs[(i + 1) % NENV];
		envs[i].env_id = 0;
		envs[i].env_status = ENV_FREE;
	}
	env_free_list = envs;
f0102be0:	a1 ac d3 39 f0       	mov    0xf039d3ac,%eax
f0102be5:	a3 b0 d3 39 f0       	mov    %eax,0xf039d3b0
	// Per-CPU part of the initialization
	env_init_percpu();
f0102bea:	e8 7f ff ff ff       	call   f0102b6e <env_init_percpu>
}
f0102bef:	5b                   	pop    %ebx
f0102bf0:	5e                   	pop    %esi
f0102bf1:	5d                   	pop    %ebp
f0102bf2:	c3                   	ret    

f0102bf3 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0102bf3:	55                   	push   %ebp
f0102bf4:	89 e5                	mov    %esp,%ebp
f0102bf6:	53                   	push   %ebx
f0102bf7:	83 ec 04             	sub    $0x4,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) {
f0102bfa:	8b 1d b0 d3 39 f0    	mov    0xf039d3b0,%ebx
f0102c00:	85 db                	test   %ebx,%ebx
f0102c02:	0f 84 54 01 00 00    	je     f0102d5c <env_alloc+0x169>
env_setup_vm(struct Env *e)
{
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0102c08:	83 ec 0c             	sub    $0xc,%esp
f0102c0b:	6a 01                	push   $0x1
f0102c0d:	e8 84 e2 ff ff       	call   f0100e96 <page_alloc>
f0102c12:	83 c4 10             	add    $0x10,%esp
f0102c15:	85 c0                	test   %eax,%eax
f0102c17:	0f 84 46 01 00 00    	je     f0102d63 <env_alloc+0x170>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 8: Your code here.
	p->pp_ref++;
f0102c1d:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
f0102c22:	2b 05 a0 e0 39 f0    	sub    0xf039e0a0,%eax
f0102c28:	c1 f8 03             	sar    $0x3,%eax
f0102c2b:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c2e:	89 c2                	mov    %eax,%edx
f0102c30:	c1 ea 0c             	shr    $0xc,%edx
f0102c33:	3b 15 98 e0 39 f0    	cmp    0xf039e098,%edx
f0102c39:	72 12                	jb     f0102c4d <env_alloc+0x5a>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0102c3b:	50                   	push   %eax
f0102c3c:	68 54 64 10 f0       	push   $0xf0106454
f0102c41:	6a 58                	push   $0x58
f0102c43:	68 7a 61 10 f0       	push   $0xf010617a
f0102c48:	e8 a3 d4 ff ff       	call   f01000f0 <_panic>
	return (void *)(pa + KERNBASE);
f0102c4d:	2d 00 00 00 10       	sub    $0x10000000,%eax
	e->env_pgdir = (pde_t *) page2kva(p);
f0102c52:	89 43 5c             	mov    %eax,0x5c(%ebx)
	memcpy(e->env_pgdir, kern_pgdir, PGSIZE);
f0102c55:	83 ec 04             	sub    $0x4,%esp
f0102c58:	68 00 10 00 00       	push   $0x1000
f0102c5d:	ff 35 9c e0 39 f0    	pushl  0xf039e09c
f0102c63:	50                   	push   %eax
f0102c64:	e8 cc 27 00 00       	call   f0105435 <memcpy>
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U;
f0102c69:	8b 43 5c             	mov    0x5c(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102c6c:	83 c4 10             	add    $0x10,%esp
f0102c6f:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102c74:	77 15                	ja     f0102c8b <env_alloc+0x98>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0102c76:	50                   	push   %eax
f0102c77:	68 38 65 10 f0       	push   $0xf0106538
f0102c7c:	68 cb 00 00 00       	push   $0xcb
f0102c81:	68 72 6c 10 f0       	push   $0xf0106c72
f0102c86:	e8 65 d4 ff ff       	call   f01000f0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102c8b:	8d 90 00 00 00 10    	lea    0x10000000(%eax),%edx
f0102c91:	83 ca 05             	or     $0x5,%edx
f0102c94:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0102c9a:	8b 43 48             	mov    0x48(%ebx),%eax
f0102c9d:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0102ca2:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0102ca7:	7f 05                	jg     f0102cae <env_alloc+0xbb>
		generation = 1 << ENVGENSHIFT;
f0102ca9:	b8 00 10 00 00       	mov    $0x1000,%eax
	e->env_id = generation | (e - envs);
f0102cae:	89 da                	mov    %ebx,%edx
f0102cb0:	2b 15 ac d3 39 f0    	sub    0xf039d3ac,%edx
f0102cb6:	c1 fa 03             	sar    $0x3,%edx
f0102cb9:	69 d2 ef ee ee ee    	imul   $0xeeeeeeef,%edx,%edx
f0102cbf:	09 d0                	or     %edx,%eax
f0102cc1:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0102cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
f0102cc7:	89 43 4c             	mov    %eax,0x4c(%ebx)
#ifdef CONFIG_KSPACE
	e->env_type = ENV_TYPE_KERNEL;
#else
	e->env_type = ENV_TYPE_USER;
f0102cca:	c7 43 50 02 00 00 00 	movl   $0x2,0x50(%ebx)
#endif
	e->env_status = ENV_RUNNABLE;
f0102cd1:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0102cd8:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0102cdf:	83 ec 04             	sub    $0x4,%esp
f0102ce2:	6a 44                	push   $0x44
f0102ce4:	6a 00                	push   $0x0
f0102ce6:	53                   	push   %ebx
f0102ce7:	e8 94 26 00 00       	call   f0105380 <memset>
	e->env_tf.tf_ss = GD_KD | 0;
	e->env_tf.tf_cs = GD_KT | 0;
	//LAB 3: Your code here.
	e->env_tf.tf_esp = 0x210000 + PGSIZE * 2 * (e - envs);
#else
	e->env_tf.tf_ds = GD_UD | 3;
f0102cec:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0102cf2:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0102cf8:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0102cfe:	c7 43 3c 00 e0 7f ee 	movl   $0xee7fe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0102d05:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)
#endif

	e->env_tf.tf_eflags |= FL_IF;
f0102d0b:	81 4b 38 00 02 00 00 	orl    $0x200,0x38(%ebx)

	// You will set e->env_tf.tf_eip later.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0102d12:	c7 43 60 00 00 00 00 	movl   $0x0,0x60(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0102d19:	c6 43 64 00          	movb   $0x0,0x64(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0102d1d:	8b 43 44             	mov    0x44(%ebx),%eax
f0102d20:	a3 b0 d3 39 f0       	mov    %eax,0xf039d3b0
	*newenv_store = e;
f0102d25:	8b 45 08             	mov    0x8(%ebp),%eax
f0102d28:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102d2a:	8b 53 48             	mov    0x48(%ebx),%edx
f0102d2d:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f0102d32:	83 c4 10             	add    $0x10,%esp
f0102d35:	85 c0                	test   %eax,%eax
f0102d37:	74 05                	je     f0102d3e <env_alloc+0x14b>
f0102d39:	8b 40 48             	mov    0x48(%eax),%eax
f0102d3c:	eb 05                	jmp    f0102d43 <env_alloc+0x150>
f0102d3e:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d43:	83 ec 04             	sub    $0x4,%esp
f0102d46:	52                   	push   %edx
f0102d47:	50                   	push   %eax
f0102d48:	68 7d 6c 10 f0       	push   $0xf0106c7d
f0102d4d:	e8 f4 09 00 00       	call   f0103746 <cprintf>
	return 0;
f0102d52:	83 c4 10             	add    $0x10,%esp
f0102d55:	b8 00 00 00 00       	mov    $0x0,%eax
f0102d5a:	eb 0c                	jmp    f0102d68 <env_alloc+0x175>
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list)) {
		return -E_NO_FREE_ENV;
f0102d5c:	b8 fb ff ff ff       	mov    $0xfffffffb,%eax
f0102d61:	eb 05                	jmp    f0102d68 <env_alloc+0x175>
{
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
		return -E_NO_MEM;
f0102d63:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
	env_free_list = e->env_link;
	*newenv_store = e;

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
	return 0;
}
f0102d68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0102d6b:	c9                   	leave  
f0102d6c:	c3                   	ret    

f0102d6d <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0102d6d:	55                   	push   %ebp
f0102d6e:	89 e5                	mov    %esp,%ebp
f0102d70:	57                   	push   %edi
f0102d71:	56                   	push   %esi
f0102d72:	53                   	push   %ebx
f0102d73:	83 ec 34             	sub    $0x34,%esp
f0102d76:	8b 7d 08             	mov    0x8(%ebp),%edi
	//LAB 3: Your code here.
	struct Env *penv;
	int r = env_alloc(&penv, 0);
f0102d79:	6a 00                	push   $0x0
f0102d7b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0102d7e:	50                   	push   %eax
f0102d7f:	e8 6f fe ff ff       	call   f0102bf3 <env_alloc>
	if (r) panic("env_alloc: %i", r);
f0102d84:	83 c4 10             	add    $0x10,%esp
f0102d87:	85 c0                	test   %eax,%eax
f0102d89:	74 15                	je     f0102da0 <env_create+0x33>
f0102d8b:	50                   	push   %eax
f0102d8c:	68 92 6c 10 f0       	push   $0xf0106c92
f0102d91:	68 d7 01 00 00       	push   $0x1d7
f0102d96:	68 72 6c 10 f0       	push   $0xf0106c72
f0102d9b:	e8 50 d3 ff ff       	call   f01000f0 <_panic>
	penv->env_type = type;
f0102da0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102da3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0102da6:	8b 55 10             	mov    0x10(%ebp),%edx
f0102da9:	89 50 50             	mov    %edx,0x50(%eax)

	//LAB 3: Your code here.
	struct Elf *ELFHDR = (struct Elf *) binary;
	struct Proghdr *ph, *eph;

	if (ELFHDR->e_magic != ELF_MAGIC)
f0102dac:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0102db2:	74 17                	je     f0102dcb <env_create+0x5e>
		panic("Not executable!");
f0102db4:	83 ec 04             	sub    $0x4,%esp
f0102db7:	68 a0 6c 10 f0       	push   $0xf0106ca0
f0102dbc:	68 b0 01 00 00       	push   $0x1b0
f0102dc1:	68 72 6c 10 f0       	push   $0xf0106c72
f0102dc6:	e8 25 d3 ff ff       	call   f01000f0 <_panic>
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0102dcb:	89 fb                	mov    %edi,%ebx
f0102dcd:	03 5f 1c             	add    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0102dd0:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
f0102dd4:	c1 e6 05             	shl    $0x5,%esi
f0102dd7:	01 de                	add    %ebx,%esi
	// Адрес текущего каталога страниц
	lcr3(PADDR(e->env_pgdir));
f0102dd9:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102ddc:	8b 40 5c             	mov    0x5c(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ddf:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102de4:	77 15                	ja     f0102dfb <env_create+0x8e>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0102de6:	50                   	push   %eax
f0102de7:	68 38 65 10 f0       	push   $0xf0106538
f0102dec:	68 b5 01 00 00       	push   $0x1b5
f0102df1:	68 72 6c 10 f0       	push   $0xf0106c72
f0102df6:	e8 f5 d2 ff ff       	call   f01000f0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102dfb:	05 00 00 00 10       	add    $0x10000000,%eax
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0102e00:	0f 22 d8             	mov    %eax,%cr3
f0102e03:	eb 49                	jmp    f0102e4e <env_create+0xe1>
	for (; ph < eph; ph++)
		if (ph->p_type == ELF_PROG_LOAD && ph->p_filesz <= ph->p_memsz) {
f0102e05:	83 3b 01             	cmpl   $0x1,(%ebx)
f0102e08:	75 41                	jne    f0102e4b <env_create+0xde>
f0102e0a:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0102e0d:	39 4b 10             	cmp    %ecx,0x10(%ebx)
f0102e10:	77 39                	ja     f0102e4b <env_create+0xde>
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
f0102e12:	8b 53 08             	mov    0x8(%ebx),%edx
f0102e15:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e18:	e8 6b fc ff ff       	call   f0102a88 <region_alloc>
			memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
f0102e1d:	83 ec 04             	sub    $0x4,%esp
f0102e20:	ff 73 10             	pushl  0x10(%ebx)
f0102e23:	89 f8                	mov    %edi,%eax
f0102e25:	03 43 04             	add    0x4(%ebx),%eax
f0102e28:	50                   	push   %eax
f0102e29:	ff 73 08             	pushl  0x8(%ebx)
f0102e2c:	e8 9c 25 00 00       	call   f01053cd <memmove>
			memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
f0102e31:	8b 43 10             	mov    0x10(%ebx),%eax
f0102e34:	83 c4 0c             	add    $0xc,%esp
f0102e37:	8b 53 14             	mov    0x14(%ebx),%edx
f0102e3a:	29 c2                	sub    %eax,%edx
f0102e3c:	52                   	push   %edx
f0102e3d:	6a 00                	push   $0x0
f0102e3f:	03 43 08             	add    0x8(%ebx),%eax
f0102e42:	50                   	push   %eax
f0102e43:	e8 38 25 00 00       	call   f0105380 <memset>
f0102e48:	83 c4 10             	add    $0x10,%esp
	
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	// Адрес текущего каталога страниц
	lcr3(PADDR(e->env_pgdir));
	for (; ph < eph; ph++)
f0102e4b:	83 c3 20             	add    $0x20,%ebx
f0102e4e:	39 de                	cmp    %ebx,%esi
f0102e50:	77 b3                	ja     f0102e05 <env_create+0x98>
		if (ph->p_type == ELF_PROG_LOAD && ph->p_filesz <= ph->p_memsz) {
			region_alloc(e, (void *)ph->p_va, ph->p_memsz);
			memmove((void *)ph->p_va, binary+ph->p_offset, ph->p_filesz);
			memset((void *)ph->p_va + ph->p_filesz, 0, ph->p_memsz - ph->p_filesz);
		}
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0102e52:	8b 47 18             	mov    0x18(%edi),%eax
f0102e55:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0102e58:	89 41 30             	mov    %eax,0x30(%ecx)
	lcr3(PADDR(kern_pgdir));
f0102e5b:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102e60:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102e65:	77 15                	ja     f0102e7c <env_create+0x10f>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0102e67:	50                   	push   %eax
f0102e68:	68 38 65 10 f0       	push   $0xf0106538
f0102e6d:	68 bd 01 00 00       	push   $0x1bd
f0102e72:	68 72 6c 10 f0       	push   $0xf0106c72
f0102e77:	e8 74 d2 ff ff       	call   f01000f0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102e7c:	05 00 00 00 10       	add    $0x10000000,%eax
f0102e81:	0f 22 d8             	mov    %eax,%cr3
	bind_functions(e, ELFHDR);
#endif
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 8: Your code here.
	region_alloc(e, (void *) (USTACKTOP - PGSIZE), PGSIZE);
f0102e84:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0102e89:	ba 00 d0 7f ee       	mov    $0xee7fd000,%edx
f0102e8e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102e91:	e8 f2 fb ff ff       	call   f0102a88 <region_alloc>
	struct Env *penv;
	int r = env_alloc(&penv, 0);
	if (r) panic("env_alloc: %i", r);
	penv->env_type = type;
	load_icode(penv, binary, size);
	if (type == ENV_TYPE_FS)
f0102e96:	83 7d 10 03          	cmpl   $0x3,0x10(%ebp)
f0102e9a:	75 0a                	jne    f0102ea6 <env_create+0x139>
		penv->env_tf.tf_eflags |= FL_IOPL_3;
f0102e9c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0102e9f:	81 48 38 00 30 00 00 	orl    $0x3000,0x38(%eax)
	else
		penv->env_tf.tf_eflags |= FL_IOPL_0;
}
f0102ea6:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0102ea9:	5b                   	pop    %ebx
f0102eaa:	5e                   	pop    %esi
f0102eab:	5f                   	pop    %edi
f0102eac:	5d                   	pop    %ebp
f0102ead:	c3                   	ret    

f0102eae <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f0102eae:	55                   	push   %ebp
f0102eaf:	89 e5                	mov    %esp,%ebp
f0102eb1:	57                   	push   %edi
f0102eb2:	56                   	push   %esi
f0102eb3:	53                   	push   %ebx
f0102eb4:	83 ec 1c             	sub    $0x1c,%esp
f0102eb7:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f0102eba:	8b 15 a8 d3 39 f0    	mov    0xf039d3a8,%edx
f0102ec0:	39 d7                	cmp    %edx,%edi
f0102ec2:	75 29                	jne    f0102eed <env_free+0x3f>
		lcr3(PADDR(kern_pgdir));
f0102ec4:	a1 9c e0 39 f0       	mov    0xf039e09c,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ec9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ece:	77 15                	ja     f0102ee5 <env_free+0x37>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0102ed0:	50                   	push   %eax
f0102ed1:	68 38 65 10 f0       	push   $0xf0106538
f0102ed6:	68 ef 01 00 00       	push   $0x1ef
f0102edb:	68 72 6c 10 f0       	push   $0xf0106c72
f0102ee0:	e8 0b d2 ff ff       	call   f01000f0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0102ee5:	05 00 00 00 10       	add    $0x10000000,%eax
f0102eea:	0f 22 d8             	mov    %eax,%cr3
#endif

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0102eed:	8b 4f 48             	mov    0x48(%edi),%ecx
f0102ef0:	85 d2                	test   %edx,%edx
f0102ef2:	74 05                	je     f0102ef9 <env_free+0x4b>
f0102ef4:	8b 42 48             	mov    0x48(%edx),%eax
f0102ef7:	eb 05                	jmp    f0102efe <env_free+0x50>
f0102ef9:	b8 00 00 00 00       	mov    $0x0,%eax
f0102efe:	83 ec 04             	sub    $0x4,%esp
f0102f01:	51                   	push   %ecx
f0102f02:	50                   	push   %eax
f0102f03:	68 b0 6c 10 f0       	push   $0xf0106cb0
f0102f08:	e8 39 08 00 00       	call   f0103746 <cprintf>
f0102f0d:	83 c4 10             	add    $0x10,%esp

#ifndef CONFIG_KSPACE
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102f10:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0102f17:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0102f1a:	89 d0                	mov    %edx,%eax
f0102f1c:	c1 e0 02             	shl    $0x2,%eax
f0102f1f:	89 45 d8             	mov    %eax,-0x28(%ebp)

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0102f22:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102f25:	8b 34 90             	mov    (%eax,%edx,4),%esi
f0102f28:	f7 c6 01 00 00 00    	test   $0x1,%esi
f0102f2e:	0f 84 a8 00 00 00    	je     f0102fdc <env_free+0x12e>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0102f34:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102f3a:	89 f0                	mov    %esi,%eax
f0102f3c:	c1 e8 0c             	shr    $0xc,%eax
f0102f3f:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0102f42:	3b 05 98 e0 39 f0    	cmp    0xf039e098,%eax
f0102f48:	72 15                	jb     f0102f5f <env_free+0xb1>
		_panic(file, line, "KADDR called with invalid pa %p", (void *) pa);
f0102f4a:	56                   	push   %esi
f0102f4b:	68 54 64 10 f0       	push   $0xf0106454
f0102f50:	68 00 02 00 00       	push   $0x200
f0102f55:	68 72 6c 10 f0       	push   $0xf0106c72
f0102f5a:	e8 91 d1 ff ff       	call   f01000f0 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102f5f:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102f62:	c1 e0 16             	shl    $0x16,%eax
f0102f65:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102f68:	bb 00 00 00 00       	mov    $0x0,%ebx
			if (pt[pteno] & PTE_P)
f0102f6d:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f0102f74:	01 
f0102f75:	74 17                	je     f0102f8e <env_free+0xe0>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f0102f77:	83 ec 08             	sub    $0x8,%esp
f0102f7a:	89 d8                	mov    %ebx,%eax
f0102f7c:	c1 e0 0c             	shl    $0xc,%eax
f0102f7f:	0b 45 e4             	or     -0x1c(%ebp),%eax
f0102f82:	50                   	push   %eax
f0102f83:	ff 77 5c             	pushl  0x5c(%edi)
f0102f86:	e8 47 e1 ff ff       	call   f01010d2 <page_remove>
f0102f8b:	83 c4 10             	add    $0x10,%esp
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f0102f8e:	83 c3 01             	add    $0x1,%ebx
f0102f91:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f0102f97:	75 d4                	jne    f0102f6d <env_free+0xbf>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f0102f99:	8b 47 5c             	mov    0x5c(%edi),%eax
f0102f9c:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0102f9f:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102fa6:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0102fa9:	3b 05 98 e0 39 f0    	cmp    0xf039e098,%eax
f0102faf:	72 14                	jb     f0102fc5 <env_free+0x117>
		panic("pa2page called with invalid pa");
f0102fb1:	83 ec 04             	sub    $0x4,%esp
f0102fb4:	68 8c 65 10 f0       	push   $0xf010658c
f0102fb9:	6a 51                	push   $0x51
f0102fbb:	68 7a 61 10 f0       	push   $0xf010617a
f0102fc0:	e8 2b d1 ff ff       	call   f01000f0 <_panic>
		page_decref(pa2page(pa));
f0102fc5:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f0102fc8:	a1 a0 e0 39 f0       	mov    0xf039e0a0,%eax
f0102fcd:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0102fd0:	8d 04 d0             	lea    (%eax,%edx,8),%eax
f0102fd3:	50                   	push   %eax
f0102fd4:	e8 6f df ff ff       	call   f0100f48 <page_decref>
f0102fd9:	83 c4 10             	add    $0x10,%esp
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

#ifndef CONFIG_KSPACE
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f0102fdc:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0102fe0:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0102fe3:	3d ba 03 00 00       	cmp    $0x3ba,%eax
f0102fe8:	0f 85 29 ff ff ff    	jne    f0102f17 <env_free+0x69>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f0102fee:	8b 47 5c             	mov    0x5c(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0102ff1:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0102ff6:	77 15                	ja     f010300d <env_free+0x15f>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f0102ff8:	50                   	push   %eax
f0102ff9:	68 38 65 10 f0       	push   $0xf0106538
f0102ffe:	68 0e 02 00 00       	push   $0x20e
f0103003:	68 72 6c 10 f0       	push   $0xf0106c72
f0103008:	e8 e3 d0 ff ff       	call   f01000f0 <_panic>
	e->env_pgdir = 0;
f010300d:	c7 47 5c 00 00 00 00 	movl   $0x0,0x5c(%edi)
	return (physaddr_t)kva - KERNBASE;
f0103014:	05 00 00 00 10       	add    $0x10000000,%eax
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103019:	c1 e8 0c             	shr    $0xc,%eax
f010301c:	3b 05 98 e0 39 f0    	cmp    0xf039e098,%eax
f0103022:	72 14                	jb     f0103038 <env_free+0x18a>
		panic("pa2page called with invalid pa");
f0103024:	83 ec 04             	sub    $0x4,%esp
f0103027:	68 8c 65 10 f0       	push   $0xf010658c
f010302c:	6a 51                	push   $0x51
f010302e:	68 7a 61 10 f0       	push   $0xf010617a
f0103033:	e8 b8 d0 ff ff       	call   f01000f0 <_panic>
	page_decref(pa2page(pa));
f0103038:	83 ec 0c             	sub    $0xc,%esp
	return &pages[PGNUM(pa)];
f010303b:	8b 15 a0 e0 39 f0    	mov    0xf039e0a0,%edx
f0103041:	8d 04 c2             	lea    (%edx,%eax,8),%eax
f0103044:	50                   	push   %eax
f0103045:	e8 fe de ff ff       	call   f0100f48 <page_decref>
#endif
	// return the environment to the free list
	e->env_status = ENV_FREE;
f010304a:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f0103051:	a1 b0 d3 39 f0       	mov    0xf039d3b0,%eax
f0103056:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f0103059:	89 3d b0 d3 39 f0    	mov    %edi,0xf039d3b0
f010305f:	83 c4 10             	add    $0x10,%esp
}
f0103062:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103065:	5b                   	pop    %ebx
f0103066:	5e                   	pop    %esi
f0103067:	5f                   	pop    %edi
f0103068:	5d                   	pop    %ebp
f0103069:	c3                   	ret    

f010306a <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f010306a:	55                   	push   %ebp
f010306b:	89 e5                	mov    %esp,%ebp
f010306d:	53                   	push   %ebx
f010306e:	83 ec 10             	sub    $0x10,%esp
f0103071:	8b 5d 08             	mov    0x8(%ebp),%ebx
	while (1)
		monitor(NULL);
		*/
	

	env_free(e);
f0103074:	53                   	push   %ebx
f0103075:	e8 34 fe ff ff       	call   f0102eae <env_free>

	if (curenv == e) {
f010307a:	83 c4 10             	add    $0x10,%esp
f010307d:	39 1d a8 d3 39 f0    	cmp    %ebx,0xf039d3a8
f0103083:	75 0f                	jne    f0103094 <env_destroy+0x2a>
		curenv = NULL;
f0103085:	c7 05 a8 d3 39 f0 00 	movl   $0x0,0xf039d3a8
f010308c:	00 00 00 
		sched_yield();
f010308f:	e8 81 10 00 00       	call   f0104115 <sched_yield>
	}	
}
f0103094:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103097:	c9                   	leave  
f0103098:	c3                   	ret    

f0103099 <env_pop_tf>:
//
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)
{
f0103099:	55                   	push   %ebp
f010309a:	89 e5                	mov    %esp,%ebp
f010309c:	83 ec 0c             	sub    $0xc,%esp
		  [eflags]"i"(offsetof(struct Trapframe, tf_eflags)),
//		  [esp]"i"(offsetof(struct Trapframe, tf_regs.reg_oesp))
		  [esp]"i"(offsetof(struct Trapframe, tf_esp))
		: "cc", "memory", "ebx", "ecx", "edx", "esi", "edi" );
#else
	__asm __volatile("movl %0,%%esp\n"
f010309f:	8b 65 08             	mov    0x8(%ebp),%esp
f01030a2:	61                   	popa   
f01030a3:	07                   	pop    %es
f01030a4:	1f                   	pop    %ds
f01030a5:	83 c4 08             	add    $0x8,%esp
f01030a8:	cf                   	iret   
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
#endif
	panic("BUG");  /* mostly to placate the compiler */
f01030a9:	68 c6 6c 10 f0       	push   $0xf0106cc6
f01030ae:	68 74 02 00 00       	push   $0x274
f01030b3:	68 72 6c 10 f0       	push   $0xf0106c72
f01030b8:	e8 33 d0 ff ff       	call   f01000f0 <_panic>

f01030bd <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01030bd:	55                   	push   %ebp
f01030be:	89 e5                	mov    %esp,%ebp
f01030c0:	83 ec 08             	sub    $0x8,%esp
f01030c3:	8b 45 08             	mov    0x8(%ebp),%eax
	//	e->env_tf.  Go back through the code you wrote above
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.
	//
	//LAB 3: Your code here.
	if (curenv != e && (curenv->env_status == ENV_RUNNING)) 
f01030c6:	8b 15 a8 d3 39 f0    	mov    0xf039d3a8,%edx
f01030cc:	39 c2                	cmp    %eax,%edx
f01030ce:	74 0d                	je     f01030dd <env_run+0x20>
f01030d0:	83 7a 54 03          	cmpl   $0x3,0x54(%edx)
f01030d4:	75 07                	jne    f01030dd <env_run+0x20>
			curenv->env_status = ENV_RUNNABLE;		
f01030d6:	c7 42 54 02 00 00 00 	movl   $0x2,0x54(%edx)
	curenv = e;
f01030dd:	a3 a8 d3 39 f0       	mov    %eax,0xf039d3a8
	e->env_status = ENV_RUNNING;
f01030e2:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	e->env_runs++;
f01030e9:	83 40 58 01          	addl   $0x1,0x58(%eax)
	lcr3(PADDR(e->env_pgdir));
f01030ed:	8b 50 5c             	mov    0x5c(%eax),%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030f0:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01030f6:	77 15                	ja     f010310d <env_run+0x50>
		_panic(file, line, "PADDR called with invalid kva %p", kva);
f01030f8:	52                   	push   %edx
f01030f9:	68 38 65 10 f0       	push   $0xf0106538
f01030fe:	68 9d 02 00 00       	push   $0x29d
f0103103:	68 72 6c 10 f0       	push   $0xf0106c72
f0103108:	e8 e3 cf ff ff       	call   f01000f0 <_panic>
	return (physaddr_t)kva - KERNBASE;
f010310d:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103113:	0f 22 da             	mov    %edx,%cr3
	env_pop_tf(&e->env_tf);
f0103116:	83 ec 0c             	sub    $0xc,%esp
f0103119:	50                   	push   %eax
f010311a:	e8 7a ff ff ff       	call   f0103099 <env_pop_tf>

f010311f <is_leap_year>:
    int tm_mon;                   /* Month.       [0-11] */
    int tm_year;                  /* Year - 1900.  */
};

bool is_leap_year(int year)
{
f010311f:	55                   	push   %ebp
f0103120:	89 e5                	mov    %esp,%ebp
f0103122:	8b 4d 08             	mov    0x8(%ebp),%ecx
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
f0103125:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
f010312a:	89 c8                	mov    %ecx,%eax
f010312c:	f7 ea                	imul   %edx
f010312e:	c1 fa 07             	sar    $0x7,%edx
f0103131:	89 c8                	mov    %ecx,%eax
f0103133:	c1 f8 1f             	sar    $0x1f,%eax
f0103136:	29 c2                	sub    %eax,%edx
f0103138:	69 d2 90 01 00 00    	imul   $0x190,%edx,%edx
f010313e:	b8 01 00 00 00       	mov    $0x1,%eax
f0103143:	39 d1                	cmp    %edx,%ecx
f0103145:	74 25                	je     f010316c <is_leap_year+0x4d>
f0103147:	b0 00                	mov    $0x0,%al
f0103149:	f6 c1 03             	test   $0x3,%cl
f010314c:	75 1e                	jne    f010316c <is_leap_year+0x4d>
f010314e:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
f0103153:	89 c8                	mov    %ecx,%eax
f0103155:	f7 ea                	imul   %edx
f0103157:	c1 fa 05             	sar    $0x5,%edx
f010315a:	89 c8                	mov    %ecx,%eax
f010315c:	c1 f8 1f             	sar    $0x1f,%eax
f010315f:	29 c2                	sub    %eax,%edx
f0103161:	6b d2 64             	imul   $0x64,%edx,%edx
f0103164:	39 d1                	cmp    %edx,%ecx
f0103166:	0f 95 c0             	setne  %al
f0103169:	0f b6 c0             	movzbl %al,%eax
f010316c:	83 e0 01             	and    $0x1,%eax
}
f010316f:	5d                   	pop    %ebp
f0103170:	c3                   	ret    

f0103171 <d_to_s>:

int d_to_s(int d)
{
f0103171:	55                   	push   %ebp
f0103172:	89 e5                	mov    %esp,%ebp
    return d * 24 * 60 * 60;
f0103174:	69 45 08 80 51 01 00 	imul   $0x15180,0x8(%ebp),%eax
}
f010317b:	5d                   	pop    %ebp
f010317c:	c3                   	ret    

f010317d <timestamp>:

int timestamp(struct tm *time)
{
f010317d:	55                   	push   %ebp
f010317e:	89 e5                	mov    %esp,%ebp
f0103180:	57                   	push   %edi
f0103181:	56                   	push   %esi
f0103182:	53                   	push   %ebx
f0103183:	83 ec 34             	sub    $0x34,%esp
    int result = 0, year, month;
    for (year = 1970; year < time->tm_year + 2000; year++)
f0103186:	8b 45 08             	mov    0x8(%ebp),%eax
f0103189:	8b 40 14             	mov    0x14(%eax),%eax
f010318c:	89 45 c0             	mov    %eax,-0x40(%ebp)
f010318f:	8d b8 d0 07 00 00    	lea    0x7d0(%eax),%edi
f0103195:	be b2 07 00 00       	mov    $0x7b2,%esi
    return d * 24 * 60 * 60;
}

int timestamp(struct tm *time)
{
    int result = 0, year, month;
f010319a:	bb 00 00 00 00       	mov    $0x0,%ebx
    for (year = 1970; year < time->tm_year + 2000; year++)
f010319f:	eb 1c                	jmp    f01031bd <timestamp+0x40>
    {
        result += d_to_s(365 + is_leap_year(year));
f01031a1:	56                   	push   %esi
f01031a2:	e8 78 ff ff ff       	call   f010311f <is_leap_year>
f01031a7:	83 c4 04             	add    $0x4,%esp
f01031aa:	0f b6 c0             	movzbl %al,%eax
f01031ad:	05 6d 01 00 00       	add    $0x16d,%eax
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
f01031b2:	69 c0 80 51 01 00    	imul   $0x15180,%eax,%eax
int timestamp(struct tm *time)
{
    int result = 0, year, month;
    for (year = 1970; year < time->tm_year + 2000; year++)
    {
        result += d_to_s(365 + is_leap_year(year));
f01031b8:	01 c3                	add    %eax,%ebx
}

int timestamp(struct tm *time)
{
    int result = 0, year, month;
    for (year = 1970; year < time->tm_year + 2000; year++)
f01031ba:	83 c6 01             	add    $0x1,%esi
f01031bd:	39 fe                	cmp    %edi,%esi
f01031bf:	7c e0                	jl     f01031a1 <timestamp+0x24>
    {
        result += d_to_s(365 + is_leap_year(year));
    }
    int months[] = {31, 28 + is_leap_year(year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
f01031c1:	c7 45 c4 1f 00 00 00 	movl   $0x1f,-0x3c(%ebp)
f01031c8:	56                   	push   %esi
f01031c9:	e8 51 ff ff ff       	call   f010311f <is_leap_year>
f01031ce:	83 c4 04             	add    $0x4,%esp
f01031d1:	0f b6 c0             	movzbl %al,%eax
f01031d4:	83 c0 1c             	add    $0x1c,%eax
f01031d7:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01031da:	c7 45 cc 1f 00 00 00 	movl   $0x1f,-0x34(%ebp)
f01031e1:	c7 45 d0 1e 00 00 00 	movl   $0x1e,-0x30(%ebp)
f01031e8:	c7 45 d4 1f 00 00 00 	movl   $0x1f,-0x2c(%ebp)
f01031ef:	c7 45 d8 1e 00 00 00 	movl   $0x1e,-0x28(%ebp)
f01031f6:	c7 45 dc 1f 00 00 00 	movl   $0x1f,-0x24(%ebp)
f01031fd:	c7 45 e0 1f 00 00 00 	movl   $0x1f,-0x20(%ebp)
f0103204:	c7 45 e4 1e 00 00 00 	movl   $0x1e,-0x1c(%ebp)
f010320b:	c7 45 e8 1f 00 00 00 	movl   $0x1f,-0x18(%ebp)
f0103212:	c7 45 ec 1e 00 00 00 	movl   $0x1e,-0x14(%ebp)
f0103219:	c7 45 f0 1f 00 00 00 	movl   $0x1f,-0x10(%ebp)
    for (month = 0; month < time->tm_mon; month++)
f0103220:	8b 45 08             	mov    0x8(%ebp),%eax
f0103223:	8b 48 10             	mov    0x10(%eax),%ecx
f0103226:	b8 00 00 00 00       	mov    $0x0,%eax
f010322b:	eb 0d                	jmp    f010323a <timestamp+0xbd>
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
f010322d:	69 54 85 c4 80 51 01 	imul   $0x15180,-0x3c(%ebp,%eax,4),%edx
f0103234:	00 
        result += d_to_s(365 + is_leap_year(year));
    }
    int months[] = {31, 28 + is_leap_year(year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    for (month = 0; month < time->tm_mon; month++)
    {
        result += d_to_s(months[month]);
f0103235:	01 d3                	add    %edx,%ebx
    for (year = 1970; year < time->tm_year + 2000; year++)
    {
        result += d_to_s(365 + is_leap_year(year));
    }
    int months[] = {31, 28 + is_leap_year(year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    for (month = 0; month < time->tm_mon; month++)
f0103237:	83 c0 01             	add    $0x1,%eax
f010323a:	39 c8                	cmp    %ecx,%eax
f010323c:	7c ef                	jl     f010322d <timestamp+0xb0>
    {
        result += d_to_s(months[month]);
    }
    result += d_to_s(time->tm_mday) + time->tm_hour*60*60 + time->tm_min*60 + time->tm_sec;
f010323e:	8b 45 08             	mov    0x8(%ebp),%eax
f0103241:	69 50 08 10 0e 00 00 	imul   $0xe10,0x8(%eax),%edx
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
f0103248:	69 40 0c 80 51 01 00 	imul   $0x15180,0xc(%eax),%eax
    int months[] = {31, 28 + is_leap_year(year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    for (month = 0; month < time->tm_mon; month++)
    {
        result += d_to_s(months[month]);
    }
    result += d_to_s(time->tm_mday) + time->tm_hour*60*60 + time->tm_min*60 + time->tm_sec;
f010324f:	01 c2                	add    %eax,%edx
f0103251:	8b 45 08             	mov    0x8(%ebp),%eax
f0103254:	6b 40 04 3c          	imul   $0x3c,0x4(%eax),%eax
f0103258:	01 d0                	add    %edx,%eax
f010325a:	8b 7d 08             	mov    0x8(%ebp),%edi
f010325d:	03 07                	add    (%edi),%eax
f010325f:	01 d8                	add    %ebx,%eax
    return result;
}
f0103261:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103264:	5b                   	pop    %ebx
f0103265:	5e                   	pop    %esi
f0103266:	5f                   	pop    %edi
f0103267:	5d                   	pop    %ebp
f0103268:	c3                   	ret    

f0103269 <mktime>:

void mktime(int time, struct tm *tm)
{
f0103269:	55                   	push   %ebp
f010326a:	89 e5                	mov    %esp,%ebp
f010326c:	57                   	push   %edi
f010326d:	56                   	push   %esi
f010326e:	53                   	push   %ebx
f010326f:	83 ec 30             	sub    $0x30,%esp
f0103272:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103275:	8b 7d 0c             	mov    0xc(%ebp),%edi
    int year = 70;
f0103278:	be 46 00 00 00       	mov    $0x46,%esi
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;

    while (time > d_to_s(365 + is_leap_year(1900+year))) {
f010327d:	eb 05                	jmp    f0103284 <mktime+0x1b>
        time -= d_to_s(365 + is_leap_year(1900+year));
f010327f:	29 d3                	sub    %edx,%ebx
        year++;
f0103281:	83 c6 01             	add    $0x1,%esi
f0103284:	8d 86 6c 07 00 00    	lea    0x76c(%esi),%eax
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;

    while (time > d_to_s(365 + is_leap_year(1900+year))) {
f010328a:	50                   	push   %eax
f010328b:	e8 8f fe ff ff       	call   f010311f <is_leap_year>
f0103290:	83 c4 04             	add    $0x4,%esp
f0103293:	0f b6 c0             	movzbl %al,%eax
f0103296:	8d 90 6d 01 00 00    	lea    0x16d(%eax),%edx
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
f010329c:	69 d2 80 51 01 00    	imul   $0x15180,%edx,%edx
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;

    while (time > d_to_s(365 + is_leap_year(1900+year))) {
f01032a2:	39 d3                	cmp    %edx,%ebx
f01032a4:	7f d9                	jg     f010327f <mktime+0x16>
        time -= d_to_s(365 + is_leap_year(1900+year));
        year++;
    }
    tm->tm_year = year;
f01032a6:	89 77 14             	mov    %esi,0x14(%edi)

    int months[] = {31, 28 + is_leap_year(1900+year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
f01032a9:	c7 45 c4 1f 00 00 00 	movl   $0x1f,-0x3c(%ebp)
f01032b0:	83 c0 1c             	add    $0x1c,%eax
f01032b3:	89 45 c8             	mov    %eax,-0x38(%ebp)
f01032b6:	c7 45 cc 1f 00 00 00 	movl   $0x1f,-0x34(%ebp)
f01032bd:	c7 45 d0 1e 00 00 00 	movl   $0x1e,-0x30(%ebp)
f01032c4:	c7 45 d4 1f 00 00 00 	movl   $0x1f,-0x2c(%ebp)
f01032cb:	c7 45 d8 1e 00 00 00 	movl   $0x1e,-0x28(%ebp)
f01032d2:	c7 45 dc 1f 00 00 00 	movl   $0x1f,-0x24(%ebp)
f01032d9:	c7 45 e0 1f 00 00 00 	movl   $0x1f,-0x20(%ebp)
f01032e0:	c7 45 e4 1e 00 00 00 	movl   $0x1e,-0x1c(%ebp)
f01032e7:	c7 45 e8 1f 00 00 00 	movl   $0x1f,-0x18(%ebp)
f01032ee:	c7 45 ec 1e 00 00 00 	movl   $0x1e,-0x14(%ebp)
f01032f5:	c7 45 f0 1f 00 00 00 	movl   $0x1f,-0x10(%ebp)
}

void mktime(int time, struct tm *tm)
{
    int year = 70;
    int month = 0;
f01032fc:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    tm->tm_year = year;

    int months[] = {31, 28 + is_leap_year(1900+year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    while (time > d_to_s(months[month])){
f0103301:	eb 05                	jmp    f0103308 <mktime+0x9f>
        time -= d_to_s(months[month]);
f0103303:	29 d3                	sub    %edx,%ebx
        month++;
f0103305:	83 c0 01             	add    $0x1,%eax
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
f0103308:	69 54 85 c4 80 51 01 	imul   $0x15180,-0x3c(%ebp,%eax,4),%edx
f010330f:	00 
    }
    tm->tm_year = year;

    int months[] = {31, 28 + is_leap_year(1900+year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    while (time > d_to_s(months[month])){
f0103310:	39 d3                	cmp    %edx,%ebx
f0103312:	7f ef                	jg     f0103303 <mktime+0x9a>
        time -= d_to_s(months[month]);
        month++;
    }
    tm->tm_mon = month;
f0103314:	89 47 10             	mov    %eax,0x10(%edi)

void mktime(int time, struct tm *tm)
{
    int year = 70;
    int month = 0;
    int day = 0;
f0103317:	b8 00 00 00 00       	mov    $0x0,%eax
        time -= d_to_s(months[month]);
        month++;
    }
    tm->tm_mon = month;

    while (time > d_to_s(1)) {
f010331c:	eb 09                	jmp    f0103327 <mktime+0xbe>
        time -= d_to_s(1);
f010331e:	81 eb 80 51 01 00    	sub    $0x15180,%ebx
        day++;
f0103324:	83 c0 01             	add    $0x1,%eax
        time -= d_to_s(months[month]);
        month++;
    }
    tm->tm_mon = month;

    while (time > d_to_s(1)) {
f0103327:	81 fb 80 51 01 00    	cmp    $0x15180,%ebx
f010332d:	7f ef                	jg     f010331e <mktime+0xb5>
        time -= d_to_s(1);
        day++;
    }
    tm->tm_mday = day;
f010332f:	89 47 0c             	mov    %eax,0xc(%edi)
void mktime(int time, struct tm *tm)
{
    int year = 70;
    int month = 0;
    int day = 0;
    int hour = 0;
f0103332:	b8 00 00 00 00       	mov    $0x0,%eax
        time -= d_to_s(1);
        day++;
    }
    tm->tm_mday = day;

    while (time >= 60*60) {
f0103337:	eb 09                	jmp    f0103342 <mktime+0xd9>
        time -= 60*60;
f0103339:	81 eb 10 0e 00 00    	sub    $0xe10,%ebx
        hour++;
f010333f:	83 c0 01             	add    $0x1,%eax
        time -= d_to_s(1);
        day++;
    }
    tm->tm_mday = day;

    while (time >= 60*60) {
f0103342:	81 fb 0f 0e 00 00    	cmp    $0xe0f,%ebx
f0103348:	7f ef                	jg     f0103339 <mktime+0xd0>
        time -= 60*60;
        hour++;
    }

    tm->tm_hour = hour;
f010334a:	89 47 08             	mov    %eax,0x8(%edi)
{
    int year = 70;
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;
f010334d:	b8 00 00 00 00       	mov    $0x0,%eax
        hour++;
    }

    tm->tm_hour = hour;

    while (time >= 60) {
f0103352:	eb 06                	jmp    f010335a <mktime+0xf1>
        time -= 60;
f0103354:	83 eb 3c             	sub    $0x3c,%ebx
        minute++;
f0103357:	83 c0 01             	add    $0x1,%eax
        hour++;
    }

    tm->tm_hour = hour;

    while (time >= 60) {
f010335a:	83 fb 3b             	cmp    $0x3b,%ebx
f010335d:	7f f5                	jg     f0103354 <mktime+0xeb>
        time -= 60;
        minute++;
    }

    tm->tm_min = minute;
f010335f:	89 47 04             	mov    %eax,0x4(%edi)
    tm->tm_sec = time;
f0103362:	89 1f                	mov    %ebx,(%edi)
}
f0103364:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103367:	5b                   	pop    %ebx
f0103368:	5e                   	pop    %esi
f0103369:	5f                   	pop    %edi
f010336a:	5d                   	pop    %ebp
f010336b:	c3                   	ret    

f010336c <print_datetime>:

void print_datetime(struct tm *tm)
{
f010336c:	55                   	push   %ebp
f010336d:	89 e5                	mov    %esp,%ebp
f010336f:	83 ec 0c             	sub    $0xc,%esp
f0103372:	8b 45 08             	mov    0x8(%ebp),%eax
    cprintf("%04d-%02d-%02d %02d:%02d:%02d\n",
f0103375:	ff 30                	pushl  (%eax)
f0103377:	ff 70 04             	pushl  0x4(%eax)
f010337a:	ff 70 08             	pushl  0x8(%eax)
f010337d:	ff 70 0c             	pushl  0xc(%eax)
f0103380:	8b 48 10             	mov    0x10(%eax),%ecx
f0103383:	8d 51 01             	lea    0x1(%ecx),%edx
f0103386:	52                   	push   %edx
f0103387:	8b 40 14             	mov    0x14(%eax),%eax
f010338a:	05 6c 07 00 00       	add    $0x76c,%eax
f010338f:	50                   	push   %eax
f0103390:	68 cc 6c 10 f0       	push   $0xf0106ccc
f0103395:	e8 ac 03 00 00       	call   f0103746 <cprintf>
f010339a:	83 c4 20             	add    $0x20,%esp
        tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
        tm->tm_hour, tm->tm_min, tm->tm_sec);
}
f010339d:	c9                   	leave  
f010339e:	c3                   	ret    

f010339f <snprint_datetime>:

void snprint_datetime(char *buf, int size, struct tm *tm)
{
f010339f:	55                   	push   %ebp
f01033a0:	89 e5                	mov    %esp,%ebp
f01033a2:	83 ec 08             	sub    $0x8,%esp
f01033a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01033a8:	8b 45 10             	mov    0x10(%ebp),%eax
    assert(size >= 10 + 1 + 8 + 1);
f01033ab:	83 f9 13             	cmp    $0x13,%ecx
f01033ae:	7f 16                	jg     f01033c6 <snprint_datetime+0x27>
f01033b0:	68 eb 6c 10 f0       	push   $0xf0106ceb
f01033b5:	68 94 61 10 f0       	push   $0xf0106194
f01033ba:	6a 60                	push   $0x60
f01033bc:	68 02 6d 10 f0       	push   $0xf0106d02
f01033c1:	e8 2a cd ff ff       	call   f01000f0 <_panic>
    snprintf(buf, size,
f01033c6:	83 ec 0c             	sub    $0xc,%esp
f01033c9:	ff 30                	pushl  (%eax)
f01033cb:	ff 70 04             	pushl  0x4(%eax)
f01033ce:	ff 70 08             	pushl  0x8(%eax)
f01033d1:	ff 70 0c             	pushl  0xc(%eax)
f01033d4:	8b 50 10             	mov    0x10(%eax),%edx
f01033d7:	83 c2 01             	add    $0x1,%edx
f01033da:	52                   	push   %edx
f01033db:	8b 40 14             	mov    0x14(%eax),%eax
f01033de:	05 6c 07 00 00       	add    $0x76c,%eax
f01033e3:	50                   	push   %eax
f01033e4:	68 0f 6d 10 f0       	push   $0xf0106d0f
f01033e9:	51                   	push   %ecx
f01033ea:	ff 75 08             	pushl  0x8(%ebp)
f01033ed:	e8 05 1d 00 00       	call   f01050f7 <snprintf>
f01033f2:	83 c4 30             	add    $0x30,%esp
          "%04d-%02d-%02d %02d:%02d:%02d",
          tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
          tm->tm_hour, tm->tm_min, tm->tm_sec);
}
f01033f5:	c9                   	leave  
f01033f6:	c3                   	ret    

f01033f7 <get_time>:
#include <inc/x86.h>
#include <kern/kclock.h>
#include <inc/time.h>

int get_time()
{
f01033f7:	55                   	push   %ebp
f01033f8:	89 e5                	mov    %esp,%ebp
f01033fa:	53                   	push   %ebx
f01033fb:	83 ec 20             	sub    $0x20,%esp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01033fe:	ba 70 00 00 00       	mov    $0x70,%edx
f0103403:	b8 00 00 00 00       	mov    $0x0,%eax
f0103408:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103409:	b9 71 00 00 00       	mov    $0x71,%ecx
f010340e:	89 ca                	mov    %ecx,%edx
f0103410:	ec                   	in     (%dx),%al
f0103411:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103413:	b2 70                	mov    $0x70,%dl
f0103415:	b8 00 00 00 00       	mov    $0x0,%eax
f010341a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010341b:	89 ca                	mov    %ecx,%edx
f010341d:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
f010341e:	0f b6 d0             	movzbl %al,%edx
#include <inc/time.h>

int get_time()
{
	struct tm time;
	time.tm_sec = BCD2BIN(mc146818_read(RTC_SEC));
f0103421:	c1 ea 04             	shr    $0x4,%edx
f0103424:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0103427:	83 e3 0f             	and    $0xf,%ebx
f010342a:	8d 04 43             	lea    (%ebx,%eax,2),%eax
f010342d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103430:	ba 70 00 00 00       	mov    $0x70,%edx
f0103435:	b8 02 00 00 00       	mov    $0x2,%eax
f010343a:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010343b:	89 ca                	mov    %ecx,%edx
f010343d:	ec                   	in     (%dx),%al
f010343e:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103440:	b2 70                	mov    $0x70,%dl
f0103442:	b8 02 00 00 00       	mov    $0x2,%eax
f0103447:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103448:	89 ca                	mov    %ecx,%edx
f010344a:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
f010344b:	0f b6 d0             	movzbl %al,%edx

int get_time()
{
	struct tm time;
	time.tm_sec = BCD2BIN(mc146818_read(RTC_SEC));
	time.tm_min = BCD2BIN(mc146818_read(RTC_MIN));
f010344e:	c1 ea 04             	shr    $0x4,%edx
f0103451:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0103454:	83 e3 0f             	and    $0xf,%ebx
f0103457:	8d 04 43             	lea    (%ebx,%eax,2),%eax
f010345a:	89 45 e8             	mov    %eax,-0x18(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010345d:	ba 70 00 00 00       	mov    $0x70,%edx
f0103462:	b8 04 00 00 00       	mov    $0x4,%eax
f0103467:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103468:	89 ca                	mov    %ecx,%edx
f010346a:	ec                   	in     (%dx),%al
f010346b:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010346d:	b2 70                	mov    $0x70,%dl
f010346f:	b8 04 00 00 00       	mov    $0x4,%eax
f0103474:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103475:	89 ca                	mov    %ecx,%edx
f0103477:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
f0103478:	0f b6 d0             	movzbl %al,%edx
int get_time()
{
	struct tm time;
	time.tm_sec = BCD2BIN(mc146818_read(RTC_SEC));
	time.tm_min = BCD2BIN(mc146818_read(RTC_MIN));
	time.tm_hour = BCD2BIN(mc146818_read(RTC_HOUR));
f010347b:	c1 ea 04             	shr    $0x4,%edx
f010347e:	8d 04 92             	lea    (%edx,%edx,4),%eax
f0103481:	83 e3 0f             	and    $0xf,%ebx
f0103484:	8d 04 43             	lea    (%ebx,%eax,2),%eax
f0103487:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010348a:	ba 70 00 00 00       	mov    $0x70,%edx
f010348f:	b8 07 00 00 00       	mov    $0x7,%eax
f0103494:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103495:	89 ca                	mov    %ecx,%edx
f0103497:	ec                   	in     (%dx),%al
f0103498:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010349a:	b2 70                	mov    $0x70,%dl
f010349c:	b8 07 00 00 00       	mov    $0x7,%eax
f01034a1:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034a2:	89 ca                	mov    %ecx,%edx
f01034a4:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
f01034a5:	0f b6 d0             	movzbl %al,%edx
{
	struct tm time;
	time.tm_sec = BCD2BIN(mc146818_read(RTC_SEC));
	time.tm_min = BCD2BIN(mc146818_read(RTC_MIN));
	time.tm_hour = BCD2BIN(mc146818_read(RTC_HOUR));
	time.tm_mday = BCD2BIN(mc146818_read(RTC_DAY));
f01034a8:	c1 ea 04             	shr    $0x4,%edx
f01034ab:	8d 04 92             	lea    (%edx,%edx,4),%eax
f01034ae:	83 e3 0f             	and    $0xf,%ebx
f01034b1:	8d 04 43             	lea    (%ebx,%eax,2),%eax
f01034b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034b7:	ba 70 00 00 00       	mov    $0x70,%edx
f01034bc:	b8 08 00 00 00       	mov    $0x8,%eax
f01034c1:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034c2:	89 ca                	mov    %ecx,%edx
f01034c4:	ec                   	in     (%dx),%al
f01034c5:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034c7:	b2 70                	mov    $0x70,%dl
f01034c9:	b8 08 00 00 00       	mov    $0x8,%eax
f01034ce:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034cf:	89 ca                	mov    %ecx,%edx
f01034d1:	ec                   	in     (%dx),%al
	time.tm_mon = BCD2BIN(mc146818_read(RTC_MON)) - 1;
f01034d2:	83 e3 0f             	and    $0xf,%ebx

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
f01034d5:	0f b6 d0             	movzbl %al,%edx
	struct tm time;
	time.tm_sec = BCD2BIN(mc146818_read(RTC_SEC));
	time.tm_min = BCD2BIN(mc146818_read(RTC_MIN));
	time.tm_hour = BCD2BIN(mc146818_read(RTC_HOUR));
	time.tm_mday = BCD2BIN(mc146818_read(RTC_DAY));
	time.tm_mon = BCD2BIN(mc146818_read(RTC_MON)) - 1;
f01034d8:	c1 ea 04             	shr    $0x4,%edx
f01034db:	8d 04 92             	lea    (%edx,%edx,4),%eax
f01034de:	8d 44 43 ff          	lea    -0x1(%ebx,%eax,2),%eax
f01034e2:	89 45 f4             	mov    %eax,-0xc(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034e5:	ba 70 00 00 00       	mov    $0x70,%edx
f01034ea:	b8 09 00 00 00       	mov    $0x9,%eax
f01034ef:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034f0:	89 ca                	mov    %ecx,%edx
f01034f2:	ec                   	in     (%dx),%al
f01034f3:	89 c3                	mov    %eax,%ebx
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01034f5:	b2 70                	mov    $0x70,%dl
f01034f7:	b8 09 00 00 00       	mov    $0x9,%eax
f01034fc:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01034fd:	89 ca                	mov    %ecx,%edx
f01034ff:	ec                   	in     (%dx),%al

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
f0103500:	0f b6 c8             	movzbl %al,%ecx
	time.tm_sec = BCD2BIN(mc146818_read(RTC_SEC));
	time.tm_min = BCD2BIN(mc146818_read(RTC_MIN));
	time.tm_hour = BCD2BIN(mc146818_read(RTC_HOUR));
	time.tm_mday = BCD2BIN(mc146818_read(RTC_DAY));
	time.tm_mon = BCD2BIN(mc146818_read(RTC_MON)) - 1;
	time.tm_year = BCD2BIN(mc146818_read(RTC_YEAR));
f0103503:	c1 e9 04             	shr    $0x4,%ecx
f0103506:	8d 04 89             	lea    (%ecx,%ecx,4),%eax
f0103509:	83 e3 0f             	and    $0xf,%ebx
f010350c:	8d 04 43             	lea    (%ebx,%eax,2),%eax
f010350f:	89 45 f8             	mov    %eax,-0x8(%ebp)
	return timestamp(&time);
f0103512:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103515:	50                   	push   %eax
f0103516:	e8 62 fc ff ff       	call   f010317d <timestamp>
f010351b:	83 c4 04             	add    $0x4,%esp
}
f010351e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103521:	c9                   	leave  
f0103522:	c3                   	ret    

f0103523 <gettime>:

int gettime(void)
{
f0103523:	55                   	push   %ebp
f0103524:	89 e5                	mov    %esp,%ebp
f0103526:	57                   	push   %edi
f0103527:	56                   	push   %esi
f0103528:	53                   	push   %ebx
f0103529:	ba 70 00 00 00       	mov    $0x70,%edx
f010352e:	ec                   	in     (%dx),%al
}

static inline void
nmi_disable(void)
{
	outb(0x70, inb(0x70) | NMI_LOCK );
f010352f:	83 c8 80             	or     $0xffffff80,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103532:	ee                   	out    %al,(%dx)
f0103533:	bf 0a 00 00 00       	mov    $0xa,%edi
f0103538:	be 70 00 00 00       	mov    $0x70,%esi
	nmi_disable();
	// LAB 12: your code here
	int t1, t2;
	do {
	  t1 = get_time();
f010353d:	e8 b5 fe ff ff       	call   f01033f7 <get_time>
f0103542:	89 c3                	mov    %eax,%ebx
	  t2 = get_time();
f0103544:	e8 ae fe ff ff       	call   f01033f7 <get_time>
f0103549:	89 c1                	mov    %eax,%ecx
f010354b:	89 f8                	mov    %edi,%eax
f010354d:	89 f2                	mov    %esi,%edx
f010354f:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103550:	ba 71 00 00 00       	mov    $0x71,%edx
f0103555:	ec                   	in     (%dx),%al
	} while (!(mc146818_read(RTC_AREG)& RTC_UPDATE_IN_PROGRESS) && t1 != t2);
f0103556:	84 c0                	test   %al,%al
f0103558:	78 04                	js     f010355e <gettime+0x3b>
f010355a:	39 cb                	cmp    %ecx,%ebx
f010355c:	75 df                	jne    f010353d <gettime+0x1a>
f010355e:	ba 70 00 00 00       	mov    $0x70,%edx
f0103563:	ec                   	in     (%dx),%al
#define NMI_LOCK	0x80

static inline void
nmi_enable(void)
{
	outb(0x70, inb(0x70) & ~NMI_LOCK );
f0103564:	83 e0 7f             	and    $0x7f,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103567:	ee                   	out    %al,(%dx)

	nmi_enable();
	return t1;
}
f0103568:	89 d8                	mov    %ebx,%eax
f010356a:	5b                   	pop    %ebx
f010356b:	5e                   	pop    %esi
f010356c:	5f                   	pop    %edi
f010356d:	5d                   	pop    %ebp
f010356e:	c3                   	ret    

f010356f <rtc_init>:

void
rtc_init(void)
{
f010356f:	55                   	push   %ebp
f0103570:	89 e5                	mov    %esp,%ebp
f0103572:	53                   	push   %ebx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103573:	b9 70 00 00 00       	mov    $0x70,%ecx
f0103578:	89 ca                	mov    %ecx,%edx
f010357a:	ec                   	in     (%dx),%al
}

static inline void
nmi_disable(void)
{
	outb(0x70, inb(0x70) | NMI_LOCK );
f010357b:	83 c8 80             	or     $0xffffff80,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010357e:	ee                   	out    %al,(%dx)
f010357f:	b8 0b 00 00 00       	mov    $0xb,%eax
f0103584:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103585:	bb 71 00 00 00       	mov    $0x71,%ebx
f010358a:	89 da                	mov    %ebx,%edx
f010358c:	ec                   	in     (%dx),%al
	// 3. Установка бита RTC_PIE.
	// 4. Запись обновленного значения регистра в порт ввода-вывода.
	
	outb(IO_RTC_CMND, RTC_BREG);
	uint8_t regB = inb(IO_RTC_DATA);
	regB = regB | RTC_PIE;
f010358d:	83 c8 40             	or     $0x40,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103590:	ee                   	out    %al,(%dx)
f0103591:	b2 70                	mov    $0x70,%dl
f0103593:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103598:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103599:	89 da                	mov    %ebx,%edx
f010359b:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010359c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010359d:	89 ca                	mov    %ecx,%edx
f010359f:	ec                   	in     (%dx),%al
#define NMI_LOCK	0x80

static inline void
nmi_enable(void)
{
	outb(0x70, inb(0x70) & ~NMI_LOCK );
f01035a0:	83 e0 7f             	and    $0x7f,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035a3:	ee                   	out    %al,(%dx)
	regA = regA ;
	//outb(IO_RTC_CMND, RTC_AREG);
	outb(IO_RTC_DATA, regA);

	nmi_enable();
}
f01035a4:	5b                   	pop    %ebx
f01035a5:	5d                   	pop    %ebp
f01035a6:	c3                   	ret    

f01035a7 <rtc_check_status>:

uint8_t
rtc_check_status(void)
{
f01035a7:	55                   	push   %ebp
f01035a8:	89 e5                	mov    %esp,%ebp
f01035aa:	ba 70 00 00 00       	mov    $0x70,%edx
f01035af:	b8 0c 00 00 00       	mov    $0xc,%eax
f01035b4:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035b5:	b2 71                	mov    $0x71,%dl
f01035b7:	ec                   	in     (%dx),%al
	// LAB 4: your code here
	// Для проверки статуса часов в функции rtc_check_status необходимо прочитать значение регистра часов C.
	outb(IO_RTC_CMND, RTC_CREG);
	status = inb(IO_RTC_DATA);
	return status;
}
f01035b8:	5d                   	pop    %ebp
f01035b9:	c3                   	ret    

f01035ba <mc146818_read>:

unsigned
mc146818_read(unsigned reg)
{
f01035ba:	55                   	push   %ebp
f01035bb:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035bd:	ba 70 00 00 00       	mov    $0x70,%edx
f01035c2:	8b 45 08             	mov    0x8(%ebp),%eax
f01035c5:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01035c6:	b2 71                	mov    $0x71,%dl
f01035c8:	ec                   	in     (%dx),%al
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
f01035c9:	0f b6 c0             	movzbl %al,%eax
}
f01035cc:	5d                   	pop    %ebp
f01035cd:	c3                   	ret    

f01035ce <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f01035ce:	55                   	push   %ebp
f01035cf:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01035d1:	ba 70 00 00 00       	mov    $0x70,%edx
f01035d6:	8b 45 08             	mov    0x8(%ebp),%eax
f01035d9:	ee                   	out    %al,(%dx)
f01035da:	b2 71                	mov    $0x71,%dl
f01035dc:	8b 45 0c             	mov    0xc(%ebp),%eax
f01035df:	ee                   	out    %al,(%dx)
	outb(IO_RTC_CMND, reg);
	outb(IO_RTC_DATA, datum);
}
f01035e0:	5d                   	pop    %ebp
f01035e1:	c3                   	ret    

f01035e2 <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f01035e2:	55                   	push   %ebp
f01035e3:	89 e5                	mov    %esp,%ebp
f01035e5:	56                   	push   %esi
f01035e6:	53                   	push   %ebx
f01035e7:	8b 45 08             	mov    0x8(%ebp),%eax
	int i;
	irq_mask_8259A = mask;
f01035ea:	66 a3 50 13 12 f0    	mov    %ax,0xf0121350
	if (!didinit)
f01035f0:	80 3d b4 d3 39 f0 00 	cmpb   $0x0,0xf039d3b4
f01035f7:	74 57                	je     f0103650 <irq_setmask_8259A+0x6e>
f01035f9:	89 c6                	mov    %eax,%esi
f01035fb:	ba 21 00 00 00       	mov    $0x21,%edx
f0103600:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1_DATA, (char)mask);
	outb(IO_PIC2_DATA, (char)(mask >> 8));
f0103601:	66 c1 e8 08          	shr    $0x8,%ax
f0103605:	b2 a1                	mov    $0xa1,%dl
f0103607:	ee                   	out    %al,(%dx)
	cprintf("enabled interrupts:");
f0103608:	83 ec 0c             	sub    $0xc,%esp
f010360b:	68 2d 6d 10 f0       	push   $0xf0106d2d
f0103610:	e8 31 01 00 00       	call   f0103746 <cprintf>
f0103615:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 16; i++)
f0103618:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (~mask & (1<<i))
f010361d:	0f b7 f6             	movzwl %si,%esi
f0103620:	f7 d6                	not    %esi
f0103622:	0f a3 de             	bt     %ebx,%esi
f0103625:	73 11                	jae    f0103638 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0103627:	83 ec 08             	sub    $0x8,%esp
f010362a:	53                   	push   %ebx
f010362b:	68 fb 71 10 f0       	push   $0xf01071fb
f0103630:	e8 11 01 00 00       	call   f0103746 <cprintf>
f0103635:	83 c4 10             	add    $0x10,%esp
	if (!didinit)
		return;
	outb(IO_PIC1_DATA, (char)mask);
	outb(IO_PIC2_DATA, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103638:	83 c3 01             	add    $0x1,%ebx
f010363b:	83 fb 10             	cmp    $0x10,%ebx
f010363e:	75 e2                	jne    f0103622 <irq_setmask_8259A+0x40>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103640:	83 ec 0c             	sub    $0xc,%esp
f0103643:	68 1f 64 10 f0       	push   $0xf010641f
f0103648:	e8 f9 00 00 00       	call   f0103746 <cprintf>
f010364d:	83 c4 10             	add    $0x10,%esp
}
f0103650:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103653:	5b                   	pop    %ebx
f0103654:	5e                   	pop    %esi
f0103655:	5d                   	pop    %ebp
f0103656:	c3                   	ret    

f0103657 <pic_init>:

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
	didinit = 1;
f0103657:	c6 05 b4 d3 39 f0 01 	movb   $0x1,0xf039d3b4
f010365e:	ba 21 00 00 00       	mov    $0x21,%edx
f0103663:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103668:	ee                   	out    %al,(%dx)
f0103669:	b2 a1                	mov    $0xa1,%dl
f010366b:	ee                   	out    %al,(%dx)
f010366c:	b2 20                	mov    $0x20,%dl
f010366e:	b8 11 00 00 00       	mov    $0x11,%eax
f0103673:	ee                   	out    %al,(%dx)
f0103674:	b2 21                	mov    $0x21,%dl
f0103676:	b8 20 00 00 00       	mov    $0x20,%eax
f010367b:	ee                   	out    %al,(%dx)
f010367c:	b8 04 00 00 00       	mov    $0x4,%eax
f0103681:	ee                   	out    %al,(%dx)
f0103682:	b8 01 00 00 00       	mov    $0x1,%eax
f0103687:	ee                   	out    %al,(%dx)
f0103688:	b2 a0                	mov    $0xa0,%dl
f010368a:	b8 11 00 00 00       	mov    $0x11,%eax
f010368f:	ee                   	out    %al,(%dx)
f0103690:	b2 a1                	mov    $0xa1,%dl
f0103692:	b8 28 00 00 00       	mov    $0x28,%eax
f0103697:	ee                   	out    %al,(%dx)
f0103698:	b8 02 00 00 00       	mov    $0x2,%eax
f010369d:	ee                   	out    %al,(%dx)
f010369e:	b8 01 00 00 00       	mov    $0x1,%eax
f01036a3:	ee                   	out    %al,(%dx)
f01036a4:	b2 20                	mov    $0x20,%dl
f01036a6:	b8 68 00 00 00       	mov    $0x68,%eax
f01036ab:	ee                   	out    %al,(%dx)
f01036ac:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036b1:	ee                   	out    %al,(%dx)
f01036b2:	b2 a0                	mov    $0xa0,%dl
f01036b4:	b8 68 00 00 00       	mov    $0x68,%eax
f01036b9:	ee                   	out    %al,(%dx)
f01036ba:	b8 0a 00 00 00       	mov    $0xa,%eax
f01036bf:	ee                   	out    %al,(%dx)
	outb(IO_PIC1_CMND, 0x0a);             /* read IRR by default */

	outb(IO_PIC2_CMND, 0x68);               /* OCW3 */
	outb(IO_PIC2_CMND, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f01036c0:	0f b7 05 50 13 12 f0 	movzwl 0xf0121350,%eax
f01036c7:	66 83 f8 ff          	cmp    $0xffff,%ax
f01036cb:	74 13                	je     f01036e0 <pic_init+0x89>
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f01036cd:	55                   	push   %ebp
f01036ce:	89 e5                	mov    %esp,%ebp
f01036d0:	83 ec 14             	sub    $0x14,%esp

	outb(IO_PIC2_CMND, 0x68);               /* OCW3 */
	outb(IO_PIC2_CMND, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
		irq_setmask_8259A(irq_mask_8259A);
f01036d3:	0f b7 c0             	movzwl %ax,%eax
f01036d6:	50                   	push   %eax
f01036d7:	e8 06 ff ff ff       	call   f01035e2 <irq_setmask_8259A>
f01036dc:	83 c4 10             	add    $0x10,%esp
}
f01036df:	c9                   	leave  
f01036e0:	f3 c3                	repz ret 

f01036e2 <pic_send_eoi>:
	cprintf("\n");
}

void
pic_send_eoi(uint8_t irq)
{
f01036e2:	55                   	push   %ebp
f01036e3:	89 e5                	mov    %esp,%ebp
	if(irq >= 8)
f01036e5:	80 7d 08 07          	cmpb   $0x7,0x8(%ebp)
f01036e9:	76 0b                	jbe    f01036f6 <pic_send_eoi+0x14>
f01036eb:	ba a0 00 00 00       	mov    $0xa0,%edx
f01036f0:	b8 20 00 00 00       	mov    $0x20,%eax
f01036f5:	ee                   	out    %al,(%dx)
f01036f6:	ba 20 00 00 00       	mov    $0x20,%edx
f01036fb:	b8 20 00 00 00       	mov    $0x20,%eax
f0103700:	ee                   	out    %al,(%dx)
		outb(IO_PIC2_CMND, PIC_EOI);
	outb(IO_PIC1_CMND, PIC_EOI);
}
f0103701:	5d                   	pop    %ebp
f0103702:	c3                   	ret    

f0103703 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103703:	55                   	push   %ebp
f0103704:	89 e5                	mov    %esp,%ebp
f0103706:	53                   	push   %ebx
f0103707:	83 ec 10             	sub    $0x10,%esp
f010370a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	cputchar(ch);
f010370d:	ff 75 08             	pushl  0x8(%ebp)
f0103710:	e8 62 cf ff ff       	call   f0100677 <cputchar>
	(*cnt)++;
f0103715:	83 03 01             	addl   $0x1,(%ebx)
f0103718:	83 c4 10             	add    $0x10,%esp
}
f010371b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010371e:	c9                   	leave  
f010371f:	c3                   	ret    

f0103720 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
f0103720:	55                   	push   %ebp
f0103721:	89 e5                	mov    %esp,%ebp
f0103723:	83 ec 18             	sub    $0x18,%esp
	int cnt = 0;
f0103726:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f010372d:	ff 75 0c             	pushl  0xc(%ebp)
f0103730:	ff 75 08             	pushl  0x8(%ebp)
f0103733:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103736:	50                   	push   %eax
f0103737:	68 03 37 10 f0       	push   $0xf0103703
f010373c:	e8 b7 15 00 00       	call   f0104cf8 <vprintfmt>
	return cnt;
}
f0103741:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103744:	c9                   	leave  
f0103745:	c3                   	ret    

f0103746 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103746:	55                   	push   %ebp
f0103747:	89 e5                	mov    %esp,%ebp
f0103749:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f010374c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
f010374f:	50                   	push   %eax
f0103750:	ff 75 08             	pushl  0x8(%ebp)
f0103753:	e8 c8 ff ff ff       	call   f0103720 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103758:	c9                   	leave  
f0103759:	c3                   	ret    

f010375a <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f010375a:	55                   	push   %ebp
f010375b:	89 e5                	mov    %esp,%ebp
	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f010375d:	b8 00 dc 39 f0       	mov    $0xf039dc00,%eax
f0103762:	c7 05 04 dc 39 f0 00 	movl   $0xf0000000,0xf039dc04
f0103769:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f010376c:	66 c7 05 08 dc 39 f0 	movw   $0x10,0xf039dc08
f0103773:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103775:	66 c7 05 48 13 12 f0 	movw   $0x68,0xf0121348
f010377c:	68 00 
f010377e:	66 a3 4a 13 12 f0    	mov    %ax,0xf012134a
f0103784:	89 c2                	mov    %eax,%edx
f0103786:	c1 ea 10             	shr    $0x10,%edx
f0103789:	88 15 4c 13 12 f0    	mov    %dl,0xf012134c
f010378f:	c6 05 4e 13 12 f0 40 	movb   $0x40,0xf012134e
f0103796:	c1 e8 18             	shr    $0x18,%eax
f0103799:	a2 4f 13 12 f0       	mov    %al,0xf012134f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f010379e:	c6 05 4d 13 12 f0 89 	movb   $0x89,0xf012134d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f01037a5:	b8 28 00 00 00       	mov    $0x28,%eax
f01037aa:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f01037ad:	b8 52 13 12 f0       	mov    $0xf0121352,%eax
f01037b2:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f01037b5:	5d                   	pop    %ebp
f01037b6:	c3                   	ret    

f01037b7 <trap_init>:
	return "(unknown trap)";
}

void
trap_init(void)
{
f01037b7:	55                   	push   %ebp
f01037b8:	89 e5                	mov    %esp,%ebp
	extern void th18();
	extern void th48();
	extern void th100();
	extern void th101();

	SETGATE(idt[0], 0, GD_KT, th0, 0);
f01037ba:	b8 ea 3f 10 f0       	mov    $0xf0103fea,%eax
f01037bf:	66 a3 c0 d3 39 f0    	mov    %ax,0xf039d3c0
f01037c5:	66 c7 05 c2 d3 39 f0 	movw   $0x8,0xf039d3c2
f01037cc:	08 00 
f01037ce:	c6 05 c4 d3 39 f0 00 	movb   $0x0,0xf039d3c4
f01037d5:	c6 05 c5 d3 39 f0 8e 	movb   $0x8e,0xf039d3c5
f01037dc:	c1 e8 10             	shr    $0x10,%eax
f01037df:	66 a3 c6 d3 39 f0    	mov    %ax,0xf039d3c6
	SETGATE(idt[1], 0, GD_KT, th1, 0);
f01037e5:	b8 f4 3f 10 f0       	mov    $0xf0103ff4,%eax
f01037ea:	66 a3 c8 d3 39 f0    	mov    %ax,0xf039d3c8
f01037f0:	66 c7 05 ca d3 39 f0 	movw   $0x8,0xf039d3ca
f01037f7:	08 00 
f01037f9:	c6 05 cc d3 39 f0 00 	movb   $0x0,0xf039d3cc
f0103800:	c6 05 cd d3 39 f0 8e 	movb   $0x8e,0xf039d3cd
f0103807:	c1 e8 10             	shr    $0x10,%eax
f010380a:	66 a3 ce d3 39 f0    	mov    %ax,0xf039d3ce
	SETGATE(idt[2], 0, GD_KT, th2, 0);
f0103810:	b8 fe 3f 10 f0       	mov    $0xf0103ffe,%eax
f0103815:	66 a3 d0 d3 39 f0    	mov    %ax,0xf039d3d0
f010381b:	66 c7 05 d2 d3 39 f0 	movw   $0x8,0xf039d3d2
f0103822:	08 00 
f0103824:	c6 05 d4 d3 39 f0 00 	movb   $0x0,0xf039d3d4
f010382b:	c6 05 d5 d3 39 f0 8e 	movb   $0x8e,0xf039d3d5
f0103832:	c1 e8 10             	shr    $0x10,%eax
f0103835:	66 a3 d6 d3 39 f0    	mov    %ax,0xf039d3d6
	SETGATE(idt[3], 0, GD_KT, th3, 3);
f010383b:	b8 08 40 10 f0       	mov    $0xf0104008,%eax
f0103840:	66 a3 d8 d3 39 f0    	mov    %ax,0xf039d3d8
f0103846:	66 c7 05 da d3 39 f0 	movw   $0x8,0xf039d3da
f010384d:	08 00 
f010384f:	c6 05 dc d3 39 f0 00 	movb   $0x0,0xf039d3dc
f0103856:	c6 05 dd d3 39 f0 ee 	movb   $0xee,0xf039d3dd
f010385d:	c1 e8 10             	shr    $0x10,%eax
f0103860:	66 a3 de d3 39 f0    	mov    %ax,0xf039d3de
	SETGATE(idt[4], 0, GD_KT, th4, 0);
f0103866:	b8 12 40 10 f0       	mov    $0xf0104012,%eax
f010386b:	66 a3 e0 d3 39 f0    	mov    %ax,0xf039d3e0
f0103871:	66 c7 05 e2 d3 39 f0 	movw   $0x8,0xf039d3e2
f0103878:	08 00 
f010387a:	c6 05 e4 d3 39 f0 00 	movb   $0x0,0xf039d3e4
f0103881:	c6 05 e5 d3 39 f0 8e 	movb   $0x8e,0xf039d3e5
f0103888:	c1 e8 10             	shr    $0x10,%eax
f010388b:	66 a3 e6 d3 39 f0    	mov    %ax,0xf039d3e6
	SETGATE(idt[5], 0, GD_KT, th5, 0);
f0103891:	b8 1c 40 10 f0       	mov    $0xf010401c,%eax
f0103896:	66 a3 e8 d3 39 f0    	mov    %ax,0xf039d3e8
f010389c:	66 c7 05 ea d3 39 f0 	movw   $0x8,0xf039d3ea
f01038a3:	08 00 
f01038a5:	c6 05 ec d3 39 f0 00 	movb   $0x0,0xf039d3ec
f01038ac:	c6 05 ed d3 39 f0 8e 	movb   $0x8e,0xf039d3ed
f01038b3:	c1 e8 10             	shr    $0x10,%eax
f01038b6:	66 a3 ee d3 39 f0    	mov    %ax,0xf039d3ee
	SETGATE(idt[6], 0, GD_KT, th6, 0);
f01038bc:	b8 26 40 10 f0       	mov    $0xf0104026,%eax
f01038c1:	66 a3 f0 d3 39 f0    	mov    %ax,0xf039d3f0
f01038c7:	66 c7 05 f2 d3 39 f0 	movw   $0x8,0xf039d3f2
f01038ce:	08 00 
f01038d0:	c6 05 f4 d3 39 f0 00 	movb   $0x0,0xf039d3f4
f01038d7:	c6 05 f5 d3 39 f0 8e 	movb   $0x8e,0xf039d3f5
f01038de:	c1 e8 10             	shr    $0x10,%eax
f01038e1:	66 a3 f6 d3 39 f0    	mov    %ax,0xf039d3f6
	SETGATE(idt[7], 0, GD_KT, th7, 0);
f01038e7:	b8 30 40 10 f0       	mov    $0xf0104030,%eax
f01038ec:	66 a3 f8 d3 39 f0    	mov    %ax,0xf039d3f8
f01038f2:	66 c7 05 fa d3 39 f0 	movw   $0x8,0xf039d3fa
f01038f9:	08 00 
f01038fb:	c6 05 fc d3 39 f0 00 	movb   $0x0,0xf039d3fc
f0103902:	c6 05 fd d3 39 f0 8e 	movb   $0x8e,0xf039d3fd
f0103909:	c1 e8 10             	shr    $0x10,%eax
f010390c:	66 a3 fe d3 39 f0    	mov    %ax,0xf039d3fe
	SETGATE(idt[8], 0, GD_KT, th8, 0);
f0103912:	b8 3a 40 10 f0       	mov    $0xf010403a,%eax
f0103917:	66 a3 00 d4 39 f0    	mov    %ax,0xf039d400
f010391d:	66 c7 05 02 d4 39 f0 	movw   $0x8,0xf039d402
f0103924:	08 00 
f0103926:	c6 05 04 d4 39 f0 00 	movb   $0x0,0xf039d404
f010392d:	c6 05 05 d4 39 f0 8e 	movb   $0x8e,0xf039d405
f0103934:	c1 e8 10             	shr    $0x10,%eax
f0103937:	66 a3 06 d4 39 f0    	mov    %ax,0xf039d406
	SETGATE(idt[10], 0, GD_KT, th10, 0);
f010393d:	b8 42 40 10 f0       	mov    $0xf0104042,%eax
f0103942:	66 a3 10 d4 39 f0    	mov    %ax,0xf039d410
f0103948:	66 c7 05 12 d4 39 f0 	movw   $0x8,0xf039d412
f010394f:	08 00 
f0103951:	c6 05 14 d4 39 f0 00 	movb   $0x0,0xf039d414
f0103958:	c6 05 15 d4 39 f0 8e 	movb   $0x8e,0xf039d415
f010395f:	c1 e8 10             	shr    $0x10,%eax
f0103962:	66 a3 16 d4 39 f0    	mov    %ax,0xf039d416
	SETGATE(idt[11], 0, GD_KT, th11, 0);
f0103968:	b8 4a 40 10 f0       	mov    $0xf010404a,%eax
f010396d:	66 a3 18 d4 39 f0    	mov    %ax,0xf039d418
f0103973:	66 c7 05 1a d4 39 f0 	movw   $0x8,0xf039d41a
f010397a:	08 00 
f010397c:	c6 05 1c d4 39 f0 00 	movb   $0x0,0xf039d41c
f0103983:	c6 05 1d d4 39 f0 8e 	movb   $0x8e,0xf039d41d
f010398a:	c1 e8 10             	shr    $0x10,%eax
f010398d:	66 a3 1e d4 39 f0    	mov    %ax,0xf039d41e
	SETGATE(idt[12], 0, GD_KT, th12, 0);
f0103993:	b8 52 40 10 f0       	mov    $0xf0104052,%eax
f0103998:	66 a3 20 d4 39 f0    	mov    %ax,0xf039d420
f010399e:	66 c7 05 22 d4 39 f0 	movw   $0x8,0xf039d422
f01039a5:	08 00 
f01039a7:	c6 05 24 d4 39 f0 00 	movb   $0x0,0xf039d424
f01039ae:	c6 05 25 d4 39 f0 8e 	movb   $0x8e,0xf039d425
f01039b5:	c1 e8 10             	shr    $0x10,%eax
f01039b8:	66 a3 26 d4 39 f0    	mov    %ax,0xf039d426
	SETGATE(idt[13], 0, GD_KT, th13, 0);
f01039be:	b8 5a 40 10 f0       	mov    $0xf010405a,%eax
f01039c3:	66 a3 28 d4 39 f0    	mov    %ax,0xf039d428
f01039c9:	66 c7 05 2a d4 39 f0 	movw   $0x8,0xf039d42a
f01039d0:	08 00 
f01039d2:	c6 05 2c d4 39 f0 00 	movb   $0x0,0xf039d42c
f01039d9:	c6 05 2d d4 39 f0 8e 	movb   $0x8e,0xf039d42d
f01039e0:	c1 e8 10             	shr    $0x10,%eax
f01039e3:	66 a3 2e d4 39 f0    	mov    %ax,0xf039d42e
	SETGATE(idt[14], 0, GD_KT, th14, 0);
f01039e9:	b8 62 40 10 f0       	mov    $0xf0104062,%eax
f01039ee:	66 a3 30 d4 39 f0    	mov    %ax,0xf039d430
f01039f4:	66 c7 05 32 d4 39 f0 	movw   $0x8,0xf039d432
f01039fb:	08 00 
f01039fd:	c6 05 34 d4 39 f0 00 	movb   $0x0,0xf039d434
f0103a04:	c6 05 35 d4 39 f0 8e 	movb   $0x8e,0xf039d435
f0103a0b:	c1 e8 10             	shr    $0x10,%eax
f0103a0e:	66 a3 36 d4 39 f0    	mov    %ax,0xf039d436
	SETGATE(idt[16], 0, GD_KT, th16, 0);
f0103a14:	b8 6a 40 10 f0       	mov    $0xf010406a,%eax
f0103a19:	66 a3 40 d4 39 f0    	mov    %ax,0xf039d440
f0103a1f:	66 c7 05 42 d4 39 f0 	movw   $0x8,0xf039d442
f0103a26:	08 00 
f0103a28:	c6 05 44 d4 39 f0 00 	movb   $0x0,0xf039d444
f0103a2f:	c6 05 45 d4 39 f0 8e 	movb   $0x8e,0xf039d445
f0103a36:	c1 e8 10             	shr    $0x10,%eax
f0103a39:	66 a3 46 d4 39 f0    	mov    %ax,0xf039d446
	SETGATE(idt[17], 0, GD_KT, th17, 0);
f0103a3f:	b8 74 40 10 f0       	mov    $0xf0104074,%eax
f0103a44:	66 a3 48 d4 39 f0    	mov    %ax,0xf039d448
f0103a4a:	66 c7 05 4a d4 39 f0 	movw   $0x8,0xf039d44a
f0103a51:	08 00 
f0103a53:	c6 05 4c d4 39 f0 00 	movb   $0x0,0xf039d44c
f0103a5a:	c6 05 4d d4 39 f0 8e 	movb   $0x8e,0xf039d44d
f0103a61:	c1 e8 10             	shr    $0x10,%eax
f0103a64:	66 a3 4e d4 39 f0    	mov    %ax,0xf039d44e
	SETGATE(idt[18], 0, GD_KT, th18, 0);
f0103a6a:	b8 7c 40 10 f0       	mov    $0xf010407c,%eax
f0103a6f:	66 a3 50 d4 39 f0    	mov    %ax,0xf039d450
f0103a75:	66 c7 05 52 d4 39 f0 	movw   $0x8,0xf039d452
f0103a7c:	08 00 
f0103a7e:	c6 05 54 d4 39 f0 00 	movb   $0x0,0xf039d454
f0103a85:	c6 05 55 d4 39 f0 8e 	movb   $0x8e,0xf039d455
f0103a8c:	c1 e8 10             	shr    $0x10,%eax
f0103a8f:	66 a3 56 d4 39 f0    	mov    %ax,0xf039d456
	SETGATE(idt[48], 0, GD_KT, th48, 3);
f0103a95:	b8 86 40 10 f0       	mov    $0xf0104086,%eax
f0103a9a:	66 a3 40 d5 39 f0    	mov    %ax,0xf039d540
f0103aa0:	66 c7 05 42 d5 39 f0 	movw   $0x8,0xf039d542
f0103aa7:	08 00 
f0103aa9:	c6 05 44 d5 39 f0 00 	movb   $0x0,0xf039d544
f0103ab0:	c6 05 45 d5 39 f0 ee 	movb   $0xee,0xf039d545
f0103ab7:	c1 e8 10             	shr    $0x10,%eax
f0103aba:	66 a3 46 d5 39 f0    	mov    %ax,0xf039d546
	SETGATE(idt[IRQ_OFFSET + IRQ_KBD], 0, GD_KT, th100, 3);
f0103ac0:	b8 90 40 10 f0       	mov    $0xf0104090,%eax
f0103ac5:	66 a3 c8 d4 39 f0    	mov    %ax,0xf039d4c8
f0103acb:	66 c7 05 ca d4 39 f0 	movw   $0x8,0xf039d4ca
f0103ad2:	08 00 
f0103ad4:	c6 05 cc d4 39 f0 00 	movb   $0x0,0xf039d4cc
f0103adb:	c6 05 cd d4 39 f0 ee 	movb   $0xee,0xf039d4cd
f0103ae2:	c1 e8 10             	shr    $0x10,%eax
f0103ae5:	66 a3 ce d4 39 f0    	mov    %ax,0xf039d4ce
	SETGATE(idt[IRQ_OFFSET + IRQ_SERIAL], 0, GD_KT, th101, 3);
f0103aeb:	b8 9a 40 10 f0       	mov    $0xf010409a,%eax
f0103af0:	66 a3 e0 d4 39 f0    	mov    %ax,0xf039d4e0
f0103af6:	66 c7 05 e2 d4 39 f0 	movw   $0x8,0xf039d4e2
f0103afd:	08 00 
f0103aff:	c6 05 e4 d4 39 f0 00 	movb   $0x0,0xf039d4e4
f0103b06:	c6 05 e5 d4 39 f0 ee 	movb   $0xee,0xf039d4e5
f0103b0d:	c1 e8 10             	shr    $0x10,%eax
f0103b10:	66 a3 e6 d4 39 f0    	mov    %ax,0xf039d4e6
	
	//ts.ts_esp0 = KSTACKTOP;
	//ts.ts_ss0 = GD_KD;
	// Per-CPU setup 
	trap_init_percpu();
f0103b16:	e8 3f fc ff ff       	call   f010375a <trap_init_percpu>
}
f0103b1b:	5d                   	pop    %ebp
f0103b1c:	c3                   	ret    

f0103b1d <clock_idt_init>:
}


void
clock_idt_init(void)
{
f0103b1d:	55                   	push   %ebp
f0103b1e:	89 e5                	mov    %esp,%ebp
	extern void (*clock_thdlr)(void);
	// init idt structure
	SETGATE(idt[IRQ_OFFSET + IRQ_CLOCK], 0, GD_KT, (int)(&clock_thdlr), 0);
f0103b20:	b8 e0 3f 10 f0       	mov    $0xf0103fe0,%eax
f0103b25:	66 a3 00 d5 39 f0    	mov    %ax,0xf039d500
f0103b2b:	66 c7 05 02 d5 39 f0 	movw   $0x8,0xf039d502
f0103b32:	08 00 
f0103b34:	c6 05 04 d5 39 f0 00 	movb   $0x0,0xf039d504
f0103b3b:	c6 05 05 d5 39 f0 8e 	movb   $0x8e,0xf039d505
f0103b42:	c1 e8 10             	shr    $0x10,%eax
f0103b45:	66 a3 06 d5 39 f0    	mov    %ax,0xf039d506
f0103b4b:	b8 52 13 12 f0       	mov    $0xf0121352,%eax
f0103b50:	0f 01 18             	lidtl  (%eax)
	lidt(&idt_pd);
}
f0103b53:	5d                   	pop    %ebp
f0103b54:	c3                   	ret    

f0103b55 <print_regs>:
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
}

void
print_regs(struct PushRegs *regs)
{
f0103b55:	55                   	push   %ebp
f0103b56:	89 e5                	mov    %esp,%ebp
f0103b58:	53                   	push   %ebx
f0103b59:	83 ec 0c             	sub    $0xc,%esp
f0103b5c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0103b5f:	ff 33                	pushl  (%ebx)
f0103b61:	68 41 6d 10 f0       	push   $0xf0106d41
f0103b66:	e8 db fb ff ff       	call   f0103746 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0103b6b:	83 c4 08             	add    $0x8,%esp
f0103b6e:	ff 73 04             	pushl  0x4(%ebx)
f0103b71:	68 50 6d 10 f0       	push   $0xf0106d50
f0103b76:	e8 cb fb ff ff       	call   f0103746 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0103b7b:	83 c4 08             	add    $0x8,%esp
f0103b7e:	ff 73 08             	pushl  0x8(%ebx)
f0103b81:	68 5f 6d 10 f0       	push   $0xf0106d5f
f0103b86:	e8 bb fb ff ff       	call   f0103746 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f0103b8b:	83 c4 08             	add    $0x8,%esp
f0103b8e:	ff 73 0c             	pushl  0xc(%ebx)
f0103b91:	68 6e 6d 10 f0       	push   $0xf0106d6e
f0103b96:	e8 ab fb ff ff       	call   f0103746 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f0103b9b:	83 c4 08             	add    $0x8,%esp
f0103b9e:	ff 73 10             	pushl  0x10(%ebx)
f0103ba1:	68 7d 6d 10 f0       	push   $0xf0106d7d
f0103ba6:	e8 9b fb ff ff       	call   f0103746 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0103bab:	83 c4 08             	add    $0x8,%esp
f0103bae:	ff 73 14             	pushl  0x14(%ebx)
f0103bb1:	68 8c 6d 10 f0       	push   $0xf0106d8c
f0103bb6:	e8 8b fb ff ff       	call   f0103746 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0103bbb:	83 c4 08             	add    $0x8,%esp
f0103bbe:	ff 73 18             	pushl  0x18(%ebx)
f0103bc1:	68 9b 6d 10 f0       	push   $0xf0106d9b
f0103bc6:	e8 7b fb ff ff       	call   f0103746 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0103bcb:	83 c4 08             	add    $0x8,%esp
f0103bce:	ff 73 1c             	pushl  0x1c(%ebx)
f0103bd1:	68 aa 6d 10 f0       	push   $0xf0106daa
f0103bd6:	e8 6b fb ff ff       	call   f0103746 <cprintf>
f0103bdb:	83 c4 10             	add    $0x10,%esp
}
f0103bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f0103be1:	c9                   	leave  
f0103be2:	c3                   	ret    

f0103be3 <print_trapframe>:
}


void
print_trapframe(struct Trapframe *tf)
{
f0103be3:	55                   	push   %ebp
f0103be4:	89 e5                	mov    %esp,%ebp
f0103be6:	56                   	push   %esi
f0103be7:	53                   	push   %ebx
f0103be8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p\n", tf);
f0103beb:	83 ec 08             	sub    $0x8,%esp
f0103bee:	53                   	push   %ebx
f0103bef:	68 0e 6e 10 f0       	push   $0xf0106e0e
f0103bf4:	e8 4d fb ff ff       	call   f0103746 <cprintf>
	print_regs(&tf->tf_regs);
f0103bf9:	89 1c 24             	mov    %ebx,(%esp)
f0103bfc:	e8 54 ff ff ff       	call   f0103b55 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f0103c01:	83 c4 08             	add    $0x8,%esp
f0103c04:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f0103c08:	50                   	push   %eax
f0103c09:	68 20 6e 10 f0       	push   $0xf0106e20
f0103c0e:	e8 33 fb ff ff       	call   f0103746 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f0103c13:	83 c4 08             	add    $0x8,%esp
f0103c16:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f0103c1a:	50                   	push   %eax
f0103c1b:	68 33 6e 10 f0       	push   $0xf0106e33
f0103c20:	e8 21 fb ff ff       	call   f0103746 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c25:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f0103c28:	83 c4 10             	add    $0x10,%esp
f0103c2b:	83 f8 13             	cmp    $0x13,%eax
f0103c2e:	77 09                	ja     f0103c39 <print_trapframe+0x56>
		return excnames[trapno];
f0103c30:	8b 14 85 c0 70 10 f0 	mov    -0xfef8f40(,%eax,4),%edx
f0103c37:	eb 1e                	jmp    f0103c57 <print_trapframe+0x74>
	if (trapno == T_SYSCALL)
f0103c39:	83 f8 30             	cmp    $0x30,%eax
f0103c3c:	74 14                	je     f0103c52 <print_trapframe+0x6f>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103c3e:	8d 48 e0             	lea    -0x20(%eax),%ecx
		return "Hardware Interrupt";
f0103c41:	ba c5 6d 10 f0       	mov    $0xf0106dc5,%edx

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f0103c46:	83 f9 0f             	cmp    $0xf,%ecx
f0103c49:	76 0c                	jbe    f0103c57 <print_trapframe+0x74>
		return "Hardware Interrupt";
	return "(unknown trap)";
f0103c4b:	ba d8 6d 10 f0       	mov    $0xf0106dd8,%edx
f0103c50:	eb 05                	jmp    f0103c57 <print_trapframe+0x74>
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
		return excnames[trapno];
	if (trapno == T_SYSCALL)
		return "System call";
f0103c52:	ba b9 6d 10 f0       	mov    $0xf0106db9,%edx
{
	cprintf("TRAP frame at %p\n", tf);
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0103c57:	83 ec 04             	sub    $0x4,%esp
f0103c5a:	52                   	push   %edx
f0103c5b:	50                   	push   %eax
f0103c5c:	68 46 6e 10 f0       	push   $0xf0106e46
f0103c61:	e8 e0 fa ff ff       	call   f0103746 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0103c66:	83 c4 10             	add    $0x10,%esp
f0103c69:	3b 1d c0 db 39 f0    	cmp    0xf039dbc0,%ebx
f0103c6f:	75 1a                	jne    f0103c8b <print_trapframe+0xa8>
f0103c71:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103c75:	75 14                	jne    f0103c8b <print_trapframe+0xa8>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0103c77:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0103c7a:	83 ec 08             	sub    $0x8,%esp
f0103c7d:	50                   	push   %eax
f0103c7e:	68 58 6e 10 f0       	push   $0xf0106e58
f0103c83:	e8 be fa ff ff       	call   f0103746 <cprintf>
f0103c88:	83 c4 10             	add    $0x10,%esp
	cprintf("  err  0x%08x", tf->tf_err);
f0103c8b:	83 ec 08             	sub    $0x8,%esp
f0103c8e:	ff 73 2c             	pushl  0x2c(%ebx)
f0103c91:	68 67 6e 10 f0       	push   $0xf0106e67
f0103c96:	e8 ab fa ff ff       	call   f0103746 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0103c9b:	83 c4 10             	add    $0x10,%esp
f0103c9e:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0103ca2:	75 3f                	jne    f0103ce3 <print_trapframe+0x100>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f0103ca4:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0103ca7:	be e7 6d 10 f0       	mov    $0xf0106de7,%esi
f0103cac:	a8 01                	test   $0x1,%al
f0103cae:	75 05                	jne    f0103cb5 <print_trapframe+0xd2>
f0103cb0:	be f2 6d 10 f0       	mov    $0xf0106df2,%esi
f0103cb5:	b9 fe 6d 10 f0       	mov    $0xf0106dfe,%ecx
f0103cba:	a8 02                	test   $0x2,%al
f0103cbc:	75 05                	jne    f0103cc3 <print_trapframe+0xe0>
f0103cbe:	b9 04 6e 10 f0       	mov    $0xf0106e04,%ecx
f0103cc3:	ba 09 6e 10 f0       	mov    $0xf0106e09,%edx
f0103cc8:	a8 04                	test   $0x4,%al
f0103cca:	75 05                	jne    f0103cd1 <print_trapframe+0xee>
f0103ccc:	ba 45 6f 10 f0       	mov    $0xf0106f45,%edx
f0103cd1:	56                   	push   %esi
f0103cd2:	51                   	push   %ecx
f0103cd3:	52                   	push   %edx
f0103cd4:	68 75 6e 10 f0       	push   $0xf0106e75
f0103cd9:	e8 68 fa ff ff       	call   f0103746 <cprintf>
f0103cde:	83 c4 10             	add    $0x10,%esp
f0103ce1:	eb 10                	jmp    f0103cf3 <print_trapframe+0x110>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f0103ce3:	83 ec 0c             	sub    $0xc,%esp
f0103ce6:	68 1f 64 10 f0       	push   $0xf010641f
f0103ceb:	e8 56 fa ff ff       	call   f0103746 <cprintf>
f0103cf0:	83 c4 10             	add    $0x10,%esp
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f0103cf3:	83 ec 08             	sub    $0x8,%esp
f0103cf6:	ff 73 30             	pushl  0x30(%ebx)
f0103cf9:	68 84 6e 10 f0       	push   $0xf0106e84
f0103cfe:	e8 43 fa ff ff       	call   f0103746 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f0103d03:	83 c4 08             	add    $0x8,%esp
f0103d06:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f0103d0a:	50                   	push   %eax
f0103d0b:	68 93 6e 10 f0       	push   $0xf0106e93
f0103d10:	e8 31 fa ff ff       	call   f0103746 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f0103d15:	83 c4 08             	add    $0x8,%esp
f0103d18:	ff 73 38             	pushl  0x38(%ebx)
f0103d1b:	68 a6 6e 10 f0       	push   $0xf0106ea6
f0103d20:	e8 21 fa ff ff       	call   f0103746 <cprintf>
	cprintf("  esp  0x%08x\n", tf->tf_esp);
f0103d25:	83 c4 08             	add    $0x8,%esp
f0103d28:	ff 73 3c             	pushl  0x3c(%ebx)
f0103d2b:	68 b5 6e 10 f0       	push   $0xf0106eb5
f0103d30:	e8 11 fa ff ff       	call   f0103746 <cprintf>
	cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0103d35:	83 c4 08             	add    $0x8,%esp
f0103d38:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f0103d3c:	50                   	push   %eax
f0103d3d:	68 c4 6e 10 f0       	push   $0xf0106ec4
f0103d42:	e8 ff f9 ff ff       	call   f0103746 <cprintf>
f0103d47:	83 c4 10             	add    $0x10,%esp
}
f0103d4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0103d4d:	5b                   	pop    %ebx
f0103d4e:	5e                   	pop    %esi
f0103d4f:	5d                   	pop    %ebp
f0103d50:	c3                   	ret    

f0103d51 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0103d51:	55                   	push   %ebp
f0103d52:	89 e5                	mov    %esp,%ebp
f0103d54:	57                   	push   %edi
f0103d55:	56                   	push   %esi
f0103d56:	53                   	push   %ebx
f0103d57:	83 ec 0c             	sub    $0xc,%esp
f0103d5a:	8b 5d 08             	mov    0x8(%ebp),%ebx
f0103d5d:	0f 20 d6             	mov    %cr2,%esi
	fault_va = rcr2();

	// Handle kernel-mode page faults.

	// LAB 8: Your code here.
	if (tf->tf_cs == GD_KT)
f0103d60:	66 83 7b 34 08       	cmpw   $0x8,0x34(%ebx)
f0103d65:	75 17                	jne    f0103d7e <page_fault_handler+0x2d>
		panic("Kernel page fault!");
f0103d67:	83 ec 04             	sub    $0x4,%esp
f0103d6a:	68 d7 6e 10 f0       	push   $0xf0106ed7
f0103d6f:	68 4f 01 00 00       	push   $0x14f
f0103d74:	68 ea 6e 10 f0       	push   $0xf0106eea
f0103d79:	e8 72 c3 ff ff       	call   f01000f0 <_panic>
	//   user_mem_assert() and env_run() are useful here.
	//   To change what the user environment runs, modify 'curenv->env_tf'
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 9: Your code here.
	if (curenv->env_pgfault_upcall) {
f0103d7e:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f0103d83:	83 78 60 00          	cmpl   $0x0,0x60(%eax)
f0103d87:	74 66                	je     f0103def <page_fault_handler+0x9e>
		struct UTrapframe *utf;
		uintptr_t utf_addr;
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0103d89:	8b 53 3c             	mov    0x3c(%ebx),%edx
f0103d8c:	8d 8a 00 10 80 11    	lea    0x11801000(%edx),%ecx
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
		else 
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
f0103d92:	bf cc ff 7f ee       	mov    $0xee7fffcc,%edi

	// LAB 9: Your code here.
	if (curenv->env_pgfault_upcall) {
		struct UTrapframe *utf;
		uintptr_t utf_addr;
		if (UXSTACKTOP-PGSIZE<=tf->tf_esp && tf->tf_esp<=UXSTACKTOP-1)
f0103d97:	81 f9 ff 0f 00 00    	cmp    $0xfff,%ecx
f0103d9d:	77 05                	ja     f0103da4 <page_fault_handler+0x53>
			utf_addr = tf->tf_esp - sizeof(struct UTrapframe) - 4;
f0103d9f:	8d 4a c8             	lea    -0x38(%edx),%ecx
f0103da2:	89 cf                	mov    %ecx,%edi
		else 
			utf_addr = UXSTACKTOP - sizeof(struct UTrapframe);
		user_mem_assert(curenv, (void*)utf_addr, sizeof(struct UTrapframe), PTE_W);//1 is enough
f0103da4:	6a 02                	push   $0x2
f0103da6:	6a 34                	push   $0x34
f0103da8:	57                   	push   %edi
f0103da9:	50                   	push   %eax
f0103daa:	e8 8f ec ff ff       	call   f0102a3e <user_mem_assert>
		utf = (struct UTrapframe *) utf_addr;

		utf->utf_fault_va = fault_va;
f0103daf:	89 37                	mov    %esi,(%edi)
		utf->utf_err      = tf->tf_err;
f0103db1:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0103db4:	89 fa                	mov    %edi,%edx
f0103db6:	89 47 04             	mov    %eax,0x4(%edi)
		utf->utf_regs     = tf->tf_regs;
f0103db9:	8d 7a 08             	lea    0x8(%edx),%edi
f0103dbc:	b9 08 00 00 00       	mov    $0x8,%ecx
f0103dc1:	89 de                	mov    %ebx,%esi
f0103dc3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		utf->utf_eip      = tf->tf_eip;
f0103dc5:	8b 43 30             	mov    0x30(%ebx),%eax
f0103dc8:	89 d7                	mov    %edx,%edi
f0103dca:	89 42 28             	mov    %eax,0x28(%edx)
		utf->utf_eflags   = tf->tf_eflags;
f0103dcd:	8b 43 38             	mov    0x38(%ebx),%eax
f0103dd0:	89 42 2c             	mov    %eax,0x2c(%edx)
		utf->utf_esp      = tf->tf_esp;
f0103dd3:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0103dd6:	89 42 30             	mov    %eax,0x30(%edx)

		curenv->env_tf.tf_eip = (uintptr_t)curenv->env_pgfault_upcall;
f0103dd9:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f0103dde:	8b 50 60             	mov    0x60(%eax),%edx
f0103de1:	89 50 30             	mov    %edx,0x30(%eax)
		curenv->env_tf.tf_esp = utf_addr;
f0103de4:	89 78 3c             	mov    %edi,0x3c(%eax)
		env_run(curenv);
f0103de7:	89 04 24             	mov    %eax,(%esp)
f0103dea:	e8 ce f2 ff ff       	call   f01030bd <env_run>
	}

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0103def:	ff 73 30             	pushl  0x30(%ebx)
f0103df2:	56                   	push   %esi
f0103df3:	ff 70 48             	pushl  0x48(%eax)
f0103df6:	68 90 70 10 f0       	push   $0xf0107090
f0103dfb:	e8 46 f9 ff ff       	call   f0103746 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0103e00:	89 1c 24             	mov    %ebx,(%esp)
f0103e03:	e8 db fd ff ff       	call   f0103be3 <print_trapframe>
	env_destroy(curenv);
f0103e08:	83 c4 04             	add    $0x4,%esp
f0103e0b:	ff 35 a8 d3 39 f0    	pushl  0xf039d3a8
f0103e11:	e8 54 f2 ff ff       	call   f010306a <env_destroy>
f0103e16:	83 c4 10             	add    $0x10,%esp
}
f0103e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0103e1c:	5b                   	pop    %ebx
f0103e1d:	5e                   	pop    %esi
f0103e1e:	5f                   	pop    %edi
f0103e1f:	5d                   	pop    %ebp
f0103e20:	c3                   	ret    

f0103e21 <trap>:

}

void
trap(struct Trapframe *tf)
{
f0103e21:	55                   	push   %ebp
f0103e22:	89 e5                	mov    %esp,%ebp
f0103e24:	57                   	push   %edi
f0103e25:	56                   	push   %esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f0103e26:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f0103e27:	83 3d 90 e0 39 f0 00 	cmpl   $0x0,0xf039e090
f0103e2e:	74 01                	je     f0103e31 <trap+0x10>
		asm volatile("hlt");
f0103e30:	f4                   	hlt    

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0103e31:	9c                   	pushf  
f0103e32:	58                   	pop    %eax

	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0103e33:	f6 c4 02             	test   $0x2,%ah
f0103e36:	74 19                	je     f0103e51 <trap+0x30>
f0103e38:	68 f6 6e 10 f0       	push   $0xf0106ef6
f0103e3d:	68 94 61 10 f0       	push   $0xf0106194
f0103e42:	68 1c 01 00 00       	push   $0x11c
f0103e47:	68 ea 6e 10 f0       	push   $0xf0106eea
f0103e4c:	e8 9f c2 ff ff       	call   f01000f0 <_panic>

	if (debug) {
		cprintf("Incoming TRAP frame at %p\n", tf);
	}

	assert(curenv);
f0103e51:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f0103e56:	85 c0                	test   %eax,%eax
f0103e58:	75 19                	jne    f0103e73 <trap+0x52>
f0103e5a:	68 0f 6f 10 f0       	push   $0xf0106f0f
f0103e5f:	68 94 61 10 f0       	push   $0xf0106194
f0103e64:	68 22 01 00 00       	push   $0x122
f0103e69:	68 ea 6e 10 f0       	push   $0xf0106eea
f0103e6e:	e8 7d c2 ff ff       	call   f01000f0 <_panic>

	// Garbage collect if current enviroment is a zombie
	if (curenv->env_status == ENV_DYING) {
f0103e73:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f0103e77:	75 18                	jne    f0103e91 <trap+0x70>
		env_free(curenv);
f0103e79:	83 ec 0c             	sub    $0xc,%esp
f0103e7c:	50                   	push   %eax
f0103e7d:	e8 2c f0 ff ff       	call   f0102eae <env_free>
		curenv = NULL;
f0103e82:	c7 05 a8 d3 39 f0 00 	movl   $0x0,0xf039d3a8
f0103e89:	00 00 00 
		sched_yield();
f0103e8c:	e8 84 02 00 00       	call   f0104115 <sched_yield>
	}

	// Copy trap frame (which is currently on the stack)
	// into 'curenv->env_tf', so that running the environment
	// will restart at the trap point.
	curenv->env_tf = *tf;
f0103e91:	b9 11 00 00 00       	mov    $0x11,%ecx
f0103e96:	89 c7                	mov    %eax,%edi
f0103e98:	8b 75 08             	mov    0x8(%ebp),%esi
f0103e9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	// The trapframe on the stack should be ignored from here on.
	tf = &curenv->env_tf;
f0103e9d:	8b 35 a8 d3 39 f0    	mov    0xf039d3a8,%esi

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f0103ea3:	89 35 c0 db 39 f0    	mov    %esi,0xf039dbc0
	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	//

	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f0103ea9:	8b 46 28             	mov    0x28(%esi),%eax
f0103eac:	83 f8 27             	cmp    $0x27,%eax
f0103eaf:	75 1d                	jne    f0103ece <trap+0xad>
		cprintf("Spurious interrupt on irq 7\n");
f0103eb1:	83 ec 0c             	sub    $0xc,%esp
f0103eb4:	68 16 6f 10 f0       	push   $0xf0106f16
f0103eb9:	e8 88 f8 ff ff       	call   f0103746 <cprintf>
		print_trapframe(tf);
f0103ebe:	89 34 24             	mov    %esi,(%esp)
f0103ec1:	e8 1d fd ff ff       	call   f0103be3 <print_trapframe>
f0103ec6:	83 c4 10             	add    $0x10,%esp
f0103ec9:	e9 e5 00 00 00       	jmp    f0103fb3 <trap+0x192>
		return;
	}
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_CLOCK) {
f0103ece:	83 f8 28             	cmp    $0x28,%eax
f0103ed1:	75 21                	jne    f0103ef4 <trap+0xd3>
  		rtc_check_status();
f0103ed3:	e8 cf f6 ff ff       	call   f01035a7 <rtc_check_status>
  		vsys[VSYS_gettime] = gettime();
f0103ed8:	8b 35 94 e0 39 f0    	mov    0xf039e094,%esi
f0103ede:	e8 40 f6 ff ff       	call   f0103523 <gettime>
f0103ee3:	89 06                	mov    %eax,(%esi)
  		pic_send_eoi(PIC_EOI);
f0103ee5:	83 ec 0c             	sub    $0xc,%esp
f0103ee8:	6a 20                	push   $0x20
f0103eea:	e8 f3 f7 ff ff       	call   f01036e2 <pic_send_eoi>
		sched_yield();
f0103eef:	e8 21 02 00 00       	call   f0104115 <sched_yield>
		return;
	}
	if (tf->tf_trapno == T_PGFLT) {
f0103ef4:	83 f8 0e             	cmp    $0xe,%eax
f0103ef7:	75 11                	jne    f0103f0a <trap+0xe9>
		page_fault_handler(tf);
f0103ef9:	83 ec 0c             	sub    $0xc,%esp
f0103efc:	56                   	push   %esi
f0103efd:	e8 4f fe ff ff       	call   f0103d51 <page_fault_handler>
f0103f02:	83 c4 10             	add    $0x10,%esp
f0103f05:	e9 a9 00 00 00       	jmp    f0103fb3 <trap+0x192>
		return;
	}
	if (tf->tf_trapno == T_BRKPT) {
f0103f0a:	83 f8 03             	cmp    $0x3,%eax
f0103f0d:	75 11                	jne    f0103f20 <trap+0xff>
		monitor(tf);
f0103f0f:	83 ec 0c             	sub    $0xc,%esp
f0103f12:	56                   	push   %esi
f0103f13:	e8 11 ca ff ff       	call   f0100929 <monitor>
f0103f18:	83 c4 10             	add    $0x10,%esp
f0103f1b:	e9 93 00 00 00       	jmp    f0103fb3 <trap+0x192>
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
f0103f20:	83 f8 30             	cmp    $0x30,%eax
f0103f23:	75 21                	jne    f0103f46 <trap+0x125>
		tf->tf_regs.reg_eax = 
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
f0103f25:	83 ec 08             	sub    $0x8,%esp
f0103f28:	ff 76 04             	pushl  0x4(%esi)
f0103f2b:	ff 36                	pushl  (%esi)
f0103f2d:	ff 76 10             	pushl  0x10(%esi)
f0103f30:	ff 76 18             	pushl  0x18(%esi)
f0103f33:	ff 76 14             	pushl  0x14(%esi)
f0103f36:	ff 76 1c             	pushl  0x1c(%esi)
f0103f39:	e8 7c 02 00 00       	call   f01041ba <syscall>
	if (tf->tf_trapno == T_BRKPT) {
		monitor(tf);
		return;
	}
	if (tf->tf_trapno == T_SYSCALL) {
		tf->tf_regs.reg_eax = 
f0103f3e:	89 46 1c             	mov    %eax,0x1c(%esi)
f0103f41:	83 c4 20             	add    $0x20,%esp
f0103f44:	eb 6d                	jmp    f0103fb3 <trap+0x192>
			syscall(tf->tf_regs.reg_eax, tf->tf_regs.reg_edx, tf->tf_regs.reg_ecx,
				tf->tf_regs.reg_ebx, tf->tf_regs.reg_edi, tf->tf_regs.reg_esi);
		return;
	}
	if (tf->tf_trapno == IRQ_OFFSET+IRQ_KBD) {
f0103f46:	83 f8 21             	cmp    $0x21,%eax
f0103f49:	75 14                	jne    f0103f5f <trap+0x13e>
		
        kbd_intr();
f0103f4b:	e8 94 c5 ff ff       	call   f01004e4 <kbd_intr>
        pic_send_eoi(IRQ_KBD);
f0103f50:	83 ec 0c             	sub    $0xc,%esp
f0103f53:	6a 01                	push   $0x1
f0103f55:	e8 88 f7 ff ff       	call   f01036e2 <pic_send_eoi>
f0103f5a:	83 c4 10             	add    $0x10,%esp
f0103f5d:	eb 54                	jmp    f0103fb3 <trap+0x192>
        return;
    }

    if (tf->tf_trapno == IRQ_OFFSET+IRQ_SERIAL) {
f0103f5f:	83 f8 24             	cmp    $0x24,%eax
f0103f62:	75 14                	jne    f0103f78 <trap+0x157>
    	
        serial_intr();
f0103f64:	e8 5f c5 ff ff       	call   f01004c8 <serial_intr>
        pic_send_eoi(IRQ_SERIAL);
f0103f69:	83 ec 0c             	sub    $0xc,%esp
f0103f6c:	6a 04                	push   $0x4
f0103f6e:	e8 6f f7 ff ff       	call   f01036e2 <pic_send_eoi>
f0103f73:	83 c4 10             	add    $0x10,%esp
f0103f76:	eb 3b                	jmp    f0103fb3 <trap+0x192>

	// Handle keyboard and serial interrupts.
	// LAB 11: Your code here.


	print_trapframe(tf);
f0103f78:	83 ec 0c             	sub    $0xc,%esp
f0103f7b:	56                   	push   %esi
f0103f7c:	e8 62 fc ff ff       	call   f0103be3 <print_trapframe>

	if (tf->tf_cs == GD_KT) {
f0103f81:	83 c4 10             	add    $0x10,%esp
f0103f84:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0103f89:	75 17                	jne    f0103fa2 <trap+0x181>
		panic("unhandled trap in kernel");
f0103f8b:	83 ec 04             	sub    $0x4,%esp
f0103f8e:	68 33 6f 10 f0       	push   $0xf0106f33
f0103f93:	68 06 01 00 00       	push   $0x106
f0103f98:	68 ea 6e 10 f0       	push   $0xf0106eea
f0103f9d:	e8 4e c1 ff ff       	call   f01000f0 <_panic>
	} else {
		env_destroy(curenv);
f0103fa2:	83 ec 0c             	sub    $0xc,%esp
f0103fa5:	ff 35 a8 d3 39 f0    	pushl  0xf039d3a8
f0103fab:	e8 ba f0 ff ff       	call   f010306a <env_destroy>
f0103fb0:	83 c4 10             	add    $0x10,%esp
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f0103fb3:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f0103fb8:	85 c0                	test   %eax,%eax
f0103fba:	74 0f                	je     f0103fcb <trap+0x1aa>
f0103fbc:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f0103fc0:	75 09                	jne    f0103fcb <trap+0x1aa>
		env_run(curenv);
f0103fc2:	83 ec 0c             	sub    $0xc,%esp
f0103fc5:	50                   	push   %eax
f0103fc6:	e8 f2 f0 ff ff       	call   f01030bd <env_run>
	else
		sched_yield();
f0103fcb:	e8 45 01 00 00       	call   f0104115 <sched_yield>

f0103fd0 <_alltraps>:
.text
.globl _alltraps
.type _alltraps, @function;
.align 2
_alltraps:
	pushl %ds
f0103fd0:	1e                   	push   %ds
	pushl %es
f0103fd1:	06                   	push   %es
	pushal
f0103fd2:	60                   	pusha  
	pushl $GD_KD
f0103fd3:	6a 10                	push   $0x10
	popl %ds
f0103fd5:	1f                   	pop    %ds
	pushl $GD_KD
f0103fd6:	6a 10                	push   $0x10
	popl %es
f0103fd8:	07                   	pop    %es
	pushl %esp
f0103fd9:	54                   	push   %esp
	call trap
f0103fda:	e8 42 fe ff ff       	call   f0103e21 <trap>
f0103fdf:	90                   	nop

f0103fe0 <clock_thdlr>:

	pushl %esp  /* trap(%esp) */
	call trap
	jmp .
#else
TRAPHANDLER_NOEC(clock_thdlr, IRQ_OFFSET + IRQ_CLOCK)
f0103fe0:	6a 00                	push   $0x0
f0103fe2:	6a 28                	push   $0x28
f0103fe4:	e9 e7 ff ff ff       	jmp    f0103fd0 <_alltraps>
f0103fe9:	90                   	nop

f0103fea <th0>:
// LAB 8: Your code here.
	TRAPHANDLER_NOEC(th0, 0)
f0103fea:	6a 00                	push   $0x0
f0103fec:	6a 00                	push   $0x0
f0103fee:	e9 dd ff ff ff       	jmp    f0103fd0 <_alltraps>
f0103ff3:	90                   	nop

f0103ff4 <th1>:
	TRAPHANDLER_NOEC(th1, 1)
f0103ff4:	6a 00                	push   $0x0
f0103ff6:	6a 01                	push   $0x1
f0103ff8:	e9 d3 ff ff ff       	jmp    f0103fd0 <_alltraps>
f0103ffd:	90                   	nop

f0103ffe <th2>:
	TRAPHANDLER_NOEC(th2, 2)
f0103ffe:	6a 00                	push   $0x0
f0104000:	6a 02                	push   $0x2
f0104002:	e9 c9 ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104007:	90                   	nop

f0104008 <th3>:
	TRAPHANDLER_NOEC(th3, 3)
f0104008:	6a 00                	push   $0x0
f010400a:	6a 03                	push   $0x3
f010400c:	e9 bf ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104011:	90                   	nop

f0104012 <th4>:
	TRAPHANDLER_NOEC(th4, 4)
f0104012:	6a 00                	push   $0x0
f0104014:	6a 04                	push   $0x4
f0104016:	e9 b5 ff ff ff       	jmp    f0103fd0 <_alltraps>
f010401b:	90                   	nop

f010401c <th5>:
	TRAPHANDLER_NOEC(th5, 5)
f010401c:	6a 00                	push   $0x0
f010401e:	6a 05                	push   $0x5
f0104020:	e9 ab ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104025:	90                   	nop

f0104026 <th6>:
	TRAPHANDLER_NOEC(th6, 6)
f0104026:	6a 00                	push   $0x0
f0104028:	6a 06                	push   $0x6
f010402a:	e9 a1 ff ff ff       	jmp    f0103fd0 <_alltraps>
f010402f:	90                   	nop

f0104030 <th7>:
	TRAPHANDLER_NOEC(th7, 7)
f0104030:	6a 00                	push   $0x0
f0104032:	6a 07                	push   $0x7
f0104034:	e9 97 ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104039:	90                   	nop

f010403a <th8>:
	TRAPHANDLER(th8, 8)
f010403a:	6a 08                	push   $0x8
f010403c:	e9 8f ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104041:	90                   	nop

f0104042 <th10>:
	TRAPHANDLER(th10, 10)
f0104042:	6a 0a                	push   $0xa
f0104044:	e9 87 ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104049:	90                   	nop

f010404a <th11>:
	TRAPHANDLER(th11, 11)
f010404a:	6a 0b                	push   $0xb
f010404c:	e9 7f ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104051:	90                   	nop

f0104052 <th12>:
	TRAPHANDLER(th12, 12)
f0104052:	6a 0c                	push   $0xc
f0104054:	e9 77 ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104059:	90                   	nop

f010405a <th13>:
	TRAPHANDLER(th13, 13)
f010405a:	6a 0d                	push   $0xd
f010405c:	e9 6f ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104061:	90                   	nop

f0104062 <th14>:
	TRAPHANDLER(th14, 14)
f0104062:	6a 0e                	push   $0xe
f0104064:	e9 67 ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104069:	90                   	nop

f010406a <th16>:
	TRAPHANDLER_NOEC(th16, 16)
f010406a:	6a 00                	push   $0x0
f010406c:	6a 10                	push   $0x10
f010406e:	e9 5d ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104073:	90                   	nop

f0104074 <th17>:
	TRAPHANDLER(th17, 17)
f0104074:	6a 11                	push   $0x11
f0104076:	e9 55 ff ff ff       	jmp    f0103fd0 <_alltraps>
f010407b:	90                   	nop

f010407c <th18>:
	TRAPHANDLER_NOEC(th18, 18)
f010407c:	6a 00                	push   $0x0
f010407e:	6a 12                	push   $0x12
f0104080:	e9 4b ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104085:	90                   	nop

f0104086 <th48>:
	TRAPHANDLER_NOEC(th48, 48)
f0104086:	6a 00                	push   $0x0
f0104088:	6a 30                	push   $0x30
f010408a:	e9 41 ff ff ff       	jmp    f0103fd0 <_alltraps>
f010408f:	90                   	nop

f0104090 <th100>:
	TRAPHANDLER_NOEC(th100, IRQ_OFFSET + IRQ_KBD)
f0104090:	6a 00                	push   $0x0
f0104092:	6a 21                	push   $0x21
f0104094:	e9 37 ff ff ff       	jmp    f0103fd0 <_alltraps>
f0104099:	90                   	nop

f010409a <th101>:
	TRAPHANDLER_NOEC(th101, IRQ_OFFSET + IRQ_SERIAL)
f010409a:	6a 00                	push   $0x0
f010409c:	6a 24                	push   $0x24
f010409e:	e9 2d ff ff ff       	jmp    f0103fd0 <_alltraps>

f01040a3 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f01040a3:	55                   	push   %ebp
f01040a4:	89 e5                	mov    %esp,%ebp
f01040a6:	83 ec 08             	sub    $0x8,%esp
f01040a9:	a1 ac d3 39 f0       	mov    0xf039d3ac,%eax
f01040ae:	8d 50 54             	lea    0x54(%eax),%edx
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01040b1:	b9 00 00 00 00       	mov    $0x0,%ecx
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
f01040b6:	8b 02                	mov    (%edx),%eax
f01040b8:	83 e8 01             	sub    $0x1,%eax
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f01040bb:	83 f8 02             	cmp    $0x2,%eax
f01040be:	76 10                	jbe    f01040d0 <sched_halt+0x2d>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f01040c0:	83 c1 01             	add    $0x1,%ecx
f01040c3:	83 c2 78             	add    $0x78,%edx
f01040c6:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01040cc:	75 e8                	jne    f01040b6 <sched_halt+0x13>
f01040ce:	eb 08                	jmp    f01040d8 <sched_halt+0x35>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING ||
		     envs[i].env_status == ENV_DYING))
			break;
	}
	if (i == NENV) {
f01040d0:	81 f9 00 04 00 00    	cmp    $0x400,%ecx
f01040d6:	75 1f                	jne    f01040f7 <sched_halt+0x54>
		cprintf("No runnable environments in the system!\n");
f01040d8:	83 ec 0c             	sub    $0xc,%esp
f01040db:	68 10 71 10 f0       	push   $0xf0107110
f01040e0:	e8 61 f6 ff ff       	call   f0103746 <cprintf>
f01040e5:	83 c4 10             	add    $0x10,%esp
		while (1)
			monitor(NULL);
f01040e8:	83 ec 0c             	sub    $0xc,%esp
f01040eb:	6a 00                	push   $0x0
f01040ed:	e8 37 c8 ff ff       	call   f0100929 <monitor>
f01040f2:	83 c4 10             	add    $0x10,%esp
f01040f5:	eb f1                	jmp    f01040e8 <sched_halt+0x45>
	}

	// Mark that no environment is running on CPU
	curenv = NULL;
f01040f7:	c7 05 a8 d3 39 f0 00 	movl   $0x0,0xf039d3a8
f01040fe:	00 00 00 

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104101:	a1 c4 e0 39 f0       	mov    0xf039e0c4,%eax
f0104106:	bd 00 00 00 00       	mov    $0x0,%ebp
f010410b:	89 c4                	mov    %eax,%esp
f010410d:	6a 00                	push   $0x0
f010410f:	6a 00                	push   $0x0
f0104111:	fb                   	sti    
f0104112:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (cpu_ts.ts_esp0));
}
f0104113:	c9                   	leave  
f0104114:	c3                   	ret    

f0104115 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104115:	55                   	push   %ebp
f0104116:	89 e5                	mov    %esp,%ebp
f0104118:	56                   	push   %esi
f0104119:	53                   	push   %ebx
	// below to halt the cpu.

	//LAB 3: Your code here.
	
	struct Env *e;
	if (curenv == NULL) {
f010411a:	83 3d a8 d3 39 f0 00 	cmpl   $0x0,0xf039d3a8
f0104121:	75 0f                	jne    f0104132 <sched_yield+0x1d>
		curenv = &envs[NENV - 1];
f0104123:	a1 ac d3 39 f0       	mov    0xf039d3ac,%eax
f0104128:	05 88 df 01 00       	add    $0x1df88,%eax
f010412d:	a3 a8 d3 39 f0       	mov    %eax,0xf039d3a8
	}
	e = &envs[(curenv - envs + 1) % NENV];
f0104132:	8b 0d a8 d3 39 f0    	mov    0xf039d3a8,%ecx
f0104138:	8b 15 ac d3 39 f0    	mov    0xf039d3ac,%edx
f010413e:	89 d3                	mov    %edx,%ebx
f0104140:	89 c8                	mov    %ecx,%eax
f0104142:	29 d0                	sub    %edx,%eax
f0104144:	c1 f8 03             	sar    $0x3,%eax
f0104147:	69 c0 ef ee ee ee    	imul   $0xeeeeeeef,%eax,%eax
f010414d:	83 c0 01             	add    $0x1,%eax
f0104150:	89 c6                	mov    %eax,%esi
f0104152:	c1 fe 1f             	sar    $0x1f,%esi
f0104155:	c1 ee 16             	shr    $0x16,%esi
f0104158:	01 f0                	add    %esi,%eax
f010415a:	25 ff 03 00 00       	and    $0x3ff,%eax
f010415f:	29 f0                	sub    %esi,%eax
f0104161:	6b c0 78             	imul   $0x78,%eax,%eax
f0104164:	01 d0                	add    %edx,%eax
	while ((e != curenv) && (e->env_status != ENV_RUNNABLE)) {
f0104166:	eb 24                	jmp    f010418c <sched_yield+0x77>
		e = &envs[(e - envs + 1) % NENV];
f0104168:	29 d8                	sub    %ebx,%eax
f010416a:	c1 f8 03             	sar    $0x3,%eax
f010416d:	69 c0 ef ee ee ee    	imul   $0xeeeeeeef,%eax,%eax
f0104173:	83 c0 01             	add    $0x1,%eax
f0104176:	89 c6                	mov    %eax,%esi
f0104178:	c1 fe 1f             	sar    $0x1f,%esi
f010417b:	c1 ee 16             	shr    $0x16,%esi
f010417e:	01 f0                	add    %esi,%eax
f0104180:	25 ff 03 00 00       	and    $0x3ff,%eax
f0104185:	29 f0                	sub    %esi,%eax
f0104187:	6b c0 78             	imul   $0x78,%eax,%eax
f010418a:	01 d0                	add    %edx,%eax
	struct Env *e;
	if (curenv == NULL) {
		curenv = &envs[NENV - 1];
	}
	e = &envs[(curenv - envs + 1) % NENV];
	while ((e != curenv) && (e->env_status != ENV_RUNNABLE)) {
f010418c:	39 c8                	cmp    %ecx,%eax
f010418e:	74 08                	je     f0104198 <sched_yield+0x83>
f0104190:	83 78 54 02          	cmpl   $0x2,0x54(%eax)
f0104194:	75 d2                	jne    f0104168 <sched_yield+0x53>
f0104196:	eb 0d                	jmp    f01041a5 <sched_yield+0x90>
		e = &envs[(e - envs + 1) % NENV];
	}
	if ((e->env_status == ENV_RUNNABLE) || (e->env_status == ENV_RUNNING)) {
f0104198:	8b 41 54             	mov    0x54(%ecx),%eax
f010419b:	83 e8 02             	sub    $0x2,%eax
f010419e:	83 f8 01             	cmp    $0x1,%eax
f01041a1:	77 0b                	ja     f01041ae <sched_yield+0x99>
f01041a3:	89 c8                	mov    %ecx,%eax
		env_run(e);
f01041a5:	83 ec 0c             	sub    $0xc,%esp
f01041a8:	50                   	push   %eax
f01041a9:	e8 0f ef ff ff       	call   f01030bd <env_run>
	}
	// sched_halt never returns
	sched_halt();
f01041ae:	e8 f0 fe ff ff       	call   f01040a3 <sched_halt>
}
f01041b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
f01041b6:	5b                   	pop    %ebx
f01041b7:	5e                   	pop    %esi
f01041b8:	5d                   	pop    %ebp
f01041b9:	c3                   	ret    

f01041ba <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f01041ba:	55                   	push   %ebp
f01041bb:	89 e5                	mov    %esp,%ebp
f01041bd:	57                   	push   %edi
f01041be:	56                   	push   %esi
f01041bf:	53                   	push   %ebx
f01041c0:	83 ec 1c             	sub    $0x1c,%esp
f01041c3:	8b 45 08             	mov    0x8(%ebp),%eax
	// Call the function corresponding to the 'syscallno' parameter.
	// Return any appropriate return value.
	// LAB 8: Your code here.
	switch (syscallno) {
f01041c6:	83 f8 0e             	cmp    $0xe,%eax
f01041c9:	0f 87 b1 05 00 00    	ja     f0104780 <syscall+0x5c6>
f01041cf:	ff 24 85 98 71 10 f0 	jmp    *-0xfef8e68(,%eax,4)
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 8: Your code here.
	user_mem_assert(curenv, s, len, PTE_U);	
f01041d6:	6a 04                	push   $0x4
f01041d8:	ff 75 10             	pushl  0x10(%ebp)
f01041db:	ff 75 0c             	pushl  0xc(%ebp)
f01041de:	ff 35 a8 d3 39 f0    	pushl  0xf039d3a8
f01041e4:	e8 55 e8 ff ff       	call   f0102a3e <user_mem_assert>
	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01041e9:	83 c4 0c             	add    $0xc,%esp
f01041ec:	ff 75 0c             	pushl  0xc(%ebp)
f01041ef:	ff 75 10             	pushl  0x10(%ebp)
f01041f2:	68 39 71 10 f0       	push   $0xf0107139
f01041f7:	e8 4a f5 ff ff       	call   f0103746 <cprintf>
f01041fc:	83 c4 10             	add    $0x10,%esp
	// Return any appropriate return value.
	// LAB 8: Your code here.
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *) a1, a2);
			return 0;
f01041ff:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104204:	e9 93 05 00 00       	jmp    f010479c <syscall+0x5e2>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f0104209:	e8 e8 c2 ff ff       	call   f01004f6 <cons_getc>
f010420e:	89 c3                	mov    %eax,%ebx
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs((char *) a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
f0104210:	e9 87 05 00 00       	jmp    f010479c <syscall+0x5e2>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f0104215:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f010421a:	8b 58 48             	mov    0x48(%eax),%ebx
			sys_cputs((char *) a1, a2);
			return 0;
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
f010421d:	e9 7a 05 00 00       	jmp    f010479c <syscall+0x5e2>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104222:	83 ec 04             	sub    $0x4,%esp
f0104225:	6a 01                	push   $0x1
f0104227:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010422a:	50                   	push   %eax
f010422b:	ff 75 0c             	pushl  0xc(%ebp)
f010422e:	e8 c0 e8 ff ff       	call   f0102af3 <envid2env>
f0104233:	83 c4 10             	add    $0x10,%esp
f0104236:	85 c0                	test   %eax,%eax
f0104238:	78 50                	js     f010428a <syscall+0xd0>
		return r;
	if (e == curenv)
f010423a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010423d:	8b 15 a8 d3 39 f0    	mov    0xf039d3a8,%edx
f0104243:	39 d0                	cmp    %edx,%eax
f0104245:	75 15                	jne    f010425c <syscall+0xa2>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104247:	83 ec 08             	sub    $0x8,%esp
f010424a:	ff 70 48             	pushl  0x48(%eax)
f010424d:	68 3e 71 10 f0       	push   $0xf010713e
f0104252:	e8 ef f4 ff ff       	call   f0103746 <cprintf>
f0104257:	83 c4 10             	add    $0x10,%esp
f010425a:	eb 16                	jmp    f0104272 <syscall+0xb8>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f010425c:	83 ec 04             	sub    $0x4,%esp
f010425f:	ff 70 48             	pushl  0x48(%eax)
f0104262:	ff 72 48             	pushl  0x48(%edx)
f0104265:	68 59 71 10 f0       	push   $0xf0107159
f010426a:	e8 d7 f4 ff ff       	call   f0103746 <cprintf>
f010426f:	83 c4 10             	add    $0x10,%esp
	env_destroy(e);
f0104272:	83 ec 0c             	sub    $0xc,%esp
f0104275:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104278:	e8 ed ed ff ff       	call   f010306a <env_destroy>
f010427d:	83 c4 10             	add    $0x10,%esp
	return 0;
f0104280:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104285:	e9 12 05 00 00       	jmp    f010479c <syscall+0x5e2>
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
		return r;
f010428a:	89 c3                	mov    %eax,%ebx
		case SYS_cgetc:
			return sys_cgetc();
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy(a1);
f010428c:	e9 0b 05 00 00       	jmp    f010479c <syscall+0x5e2>
	// from the current environment -- but tweaked so sys_exofork
	// will appear to return 0.

	// LAB 9: Your code here.
	struct Env *child;
	if (env_alloc(&child, curenv->env_id) < 0) {
f0104291:	83 ec 08             	sub    $0x8,%esp
f0104294:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f0104299:	ff 70 48             	pushl  0x48(%eax)
f010429c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010429f:	50                   	push   %eax
f01042a0:	e8 4e e9 ff ff       	call   f0102bf3 <env_alloc>
f01042a5:	83 c4 10             	add    $0x10,%esp
f01042a8:	85 c0                	test   %eax,%eax
f01042aa:	78 2b                	js     f01042d7 <syscall+0x11d>
		return -E_NO_FREE_ENV;
	}

	child->env_status = ENV_NOT_RUNNABLE;
f01042ac:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042af:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	child->env_tf = curenv->env_tf;
f01042b6:	8b 35 a8 d3 39 f0    	mov    0xf039d3a8,%esi
f01042bc:	b9 11 00 00 00       	mov    $0x11,%ecx
f01042c1:	89 c7                	mov    %eax,%edi
f01042c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child->env_tf.tf_regs.reg_eax = 0;
f01042c5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01042c8:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
	return child->env_id;
f01042cf:	8b 58 48             	mov    0x48(%eax),%ebx
f01042d2:	e9 c5 04 00 00       	jmp    f010479c <syscall+0x5e2>
	// will appear to return 0.

	// LAB 9: Your code here.
	struct Env *child;
	if (env_alloc(&child, curenv->env_id) < 0) {
		return -E_NO_FREE_ENV;
f01042d7:	bb fb ff ff ff       	mov    $0xfffffffb,%ebx
		case SYS_getenvid:
			return sys_getenvid();
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_exofork:
			return sys_exofork();
f01042dc:	e9 bb 04 00 00       	jmp    f010479c <syscall+0x5e2>

	// LAB 9: Your code here.
	int r;
	struct Env *task;

	if ((r = envid2env(envid, &task, 1)) < 0)
f01042e1:	83 ec 04             	sub    $0x4,%esp
f01042e4:	6a 01                	push   $0x1
f01042e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01042e9:	50                   	push   %eax
f01042ea:	ff 75 0c             	pushl  0xc(%ebp)
f01042ed:	e8 01 e8 ff ff       	call   f0102af3 <envid2env>
f01042f2:	83 c4 10             	add    $0x10,%esp
f01042f5:	85 c0                	test   %eax,%eax
f01042f7:	78 22                	js     f010431b <syscall+0x161>
		return -E_BAD_ENV;

	if (status != ENV_FREE && status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
f01042f9:	f7 45 10 fd ff ff ff 	testl  $0xfffffffd,0x10(%ebp)
f0104300:	74 06                	je     f0104308 <syscall+0x14e>
f0104302:	83 7d 10 04          	cmpl   $0x4,0x10(%ebp)
f0104306:	75 1d                	jne    f0104325 <syscall+0x16b>
		return -E_INVAL;

	task->env_status = status;
f0104308:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010430b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010430e:	89 48 54             	mov    %ecx,0x54(%eax)

	return 0;
f0104311:	bb 00 00 00 00       	mov    $0x0,%ebx
f0104316:	e9 81 04 00 00       	jmp    f010479c <syscall+0x5e2>
	// LAB 9: Your code here.
	int r;
	struct Env *task;

	if ((r = envid2env(envid, &task, 1)) < 0)
		return -E_BAD_ENV;
f010431b:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104320:	e9 77 04 00 00       	jmp    f010479c <syscall+0x5e2>

	if (status != ENV_FREE && status != ENV_RUNNABLE && status != ENV_NOT_RUNNABLE)
		return -E_INVAL;
f0104325:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_env_destroy:
			return sys_env_destroy(a1);
		case SYS_exofork:
			return sys_exofork();
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
f010432a:	e9 6d 04 00 00       	jmp    f010479c <syscall+0x5e2>

	// LAB 9: Your code here.
	struct Env *e; 
	int flag = PTE_U|PTE_P;

	int ret = envid2env(envid, &e, 1);
f010432f:	83 ec 04             	sub    $0x4,%esp
f0104332:	6a 01                	push   $0x1
f0104334:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104337:	50                   	push   %eax
f0104338:	ff 75 0c             	pushl  0xc(%ebp)
f010433b:	e8 b3 e7 ff ff       	call   f0102af3 <envid2env>
	if (ret) 
f0104340:	83 c4 10             	add    $0x10,%esp
		return ret;
f0104343:	89 c3                	mov    %eax,%ebx
	// LAB 9: Your code here.
	struct Env *e; 
	int flag = PTE_U|PTE_P;

	int ret = envid2env(envid, &e, 1);
	if (ret) 
f0104345:	85 c0                	test   %eax,%eax
f0104347:	0f 85 4f 04 00 00    	jne    f010479c <syscall+0x5e2>
		return ret;
	if (va >= (void*)UTOP) 
f010434d:	81 7d 10 ff ff 7f ee 	cmpl   $0xee7fffff,0x10(%ebp)
f0104354:	77 57                	ja     f01043ad <syscall+0x1f3>
		return -E_INVAL;
	if ((perm & flag) != flag) 
f0104356:	8b 45 14             	mov    0x14(%ebp),%eax
f0104359:	83 e0 05             	and    $0x5,%eax
f010435c:	83 f8 05             	cmp    $0x5,%eax
f010435f:	75 56                	jne    f01043b7 <syscall+0x1fd>
		return -E_INVAL;
	if (perm & ~PTE_SYSCALL)
f0104361:	f7 45 14 f8 f1 ff ff 	testl  $0xfffff1f8,0x14(%ebp)
f0104368:	75 57                	jne    f01043c1 <syscall+0x207>
		return -E_INVAL;
	struct PageInfo *pg = page_alloc(1);
f010436a:	83 ec 0c             	sub    $0xc,%esp
f010436d:	6a 01                	push   $0x1
f010436f:	e8 22 cb ff ff       	call   f0100e96 <page_alloc>
f0104374:	89 c6                	mov    %eax,%esi
	if (!pg) 
f0104376:	83 c4 10             	add    $0x10,%esp
f0104379:	85 c0                	test   %eax,%eax
f010437b:	74 4e                	je     f01043cb <syscall+0x211>
		return -E_NO_MEM;
	//pg->pp_ref++;
	ret = page_insert(e->env_pgdir, pg, va, perm);
f010437d:	ff 75 14             	pushl  0x14(%ebp)
f0104380:	ff 75 10             	pushl  0x10(%ebp)
f0104383:	50                   	push   %eax
f0104384:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104387:	ff 70 5c             	pushl  0x5c(%eax)
f010438a:	e8 91 cd ff ff       	call   f0101120 <page_insert>
	if (ret) {
f010438f:	83 c4 10             	add    $0x10,%esp
		page_free(pg);
		return ret;
	}

	return 0;
f0104392:	89 c3                	mov    %eax,%ebx
	struct PageInfo *pg = page_alloc(1);
	if (!pg) 
		return -E_NO_MEM;
	//pg->pp_ref++;
	ret = page_insert(e->env_pgdir, pg, va, perm);
	if (ret) {
f0104394:	85 c0                	test   %eax,%eax
f0104396:	0f 84 00 04 00 00    	je     f010479c <syscall+0x5e2>
		page_free(pg);
f010439c:	83 ec 0c             	sub    $0xc,%esp
f010439f:	56                   	push   %esi
f01043a0:	e8 68 cb ff ff       	call   f0100f0d <page_free>
f01043a5:	83 c4 10             	add    $0x10,%esp
f01043a8:	e9 ef 03 00 00       	jmp    f010479c <syscall+0x5e2>

	int ret = envid2env(envid, &e, 1);
	if (ret) 
		return ret;
	if (va >= (void*)UTOP) 
		return -E_INVAL;
f01043ad:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01043b2:	e9 e5 03 00 00       	jmp    f010479c <syscall+0x5e2>
	if ((perm & flag) != flag) 
		return -E_INVAL;
f01043b7:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01043bc:	e9 db 03 00 00       	jmp    f010479c <syscall+0x5e2>
	if (perm & ~PTE_SYSCALL)
		return -E_INVAL;
f01043c1:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01043c6:	e9 d1 03 00 00       	jmp    f010479c <syscall+0x5e2>
	struct PageInfo *pg = page_alloc(1);
	if (!pg) 
		return -E_NO_MEM;
f01043cb:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f01043d0:	e9 c7 03 00 00       	jmp    f010479c <syscall+0x5e2>
	// LAB 9: Your code here.
	struct Env *srcenv, *dstenv;
	pte_t *srcpte;
	struct PageInfo *page;
	int flag = PTE_U|PTE_P;
	if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &dstenv, 1)) 
f01043d5:	83 ec 04             	sub    $0x4,%esp
f01043d8:	6a 01                	push   $0x1
f01043da:	8d 45 dc             	lea    -0x24(%ebp),%eax
f01043dd:	50                   	push   %eax
f01043de:	ff 75 0c             	pushl  0xc(%ebp)
f01043e1:	e8 0d e7 ff ff       	call   f0102af3 <envid2env>
f01043e6:	83 c4 10             	add    $0x10,%esp
f01043e9:	85 c0                	test   %eax,%eax
f01043eb:	0f 85 b7 00 00 00    	jne    f01044a8 <syscall+0x2ee>
f01043f1:	83 ec 04             	sub    $0x4,%esp
f01043f4:	6a 01                	push   $0x1
f01043f6:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01043f9:	50                   	push   %eax
f01043fa:	ff 75 14             	pushl  0x14(%ebp)
f01043fd:	e8 f1 e6 ff ff       	call   f0102af3 <envid2env>
f0104402:	83 c4 10             	add    $0x10,%esp
f0104405:	85 c0                	test   %eax,%eax
f0104407:	0f 85 a5 00 00 00    	jne    f01044b2 <syscall+0x2f8>
		return -E_BAD_ENV;
	if ((uint32_t)srcva >= UTOP || PGOFF(srcva) ||
f010440d:	81 7d 10 ff ff 7f ee 	cmpl   $0xee7fffff,0x10(%ebp)
f0104414:	0f 87 a2 00 00 00    	ja     f01044bc <syscall+0x302>
f010441a:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104421:	0f 85 9f 00 00 00    	jne    f01044c6 <syscall+0x30c>
f0104427:	81 7d 18 ff ff 7f ee 	cmpl   $0xee7fffff,0x18(%ebp)
f010442e:	0f 87 92 00 00 00    	ja     f01044c6 <syscall+0x30c>
		(uint32_t)dstva >= UTOP || PGOFF(dstva))
f0104434:	f7 45 18 ff 0f 00 00 	testl  $0xfff,0x18(%ebp)
f010443b:	0f 85 8f 00 00 00    	jne    f01044d0 <syscall+0x316>
		return -E_INVAL;
	if ((perm & flag) != flag) 
f0104441:	8b 45 1c             	mov    0x1c(%ebp),%eax
f0104444:	83 e0 05             	and    $0x5,%eax
f0104447:	83 f8 05             	cmp    $0x5,%eax
f010444a:	0f 85 8a 00 00 00    	jne    f01044da <syscall+0x320>
		return -E_INVAL;
	if (perm & ~PTE_SYSCALL)
f0104450:	f7 45 1c f8 f1 ff ff 	testl  $0xfffff1f8,0x1c(%ebp)
f0104457:	0f 85 87 00 00 00    	jne    f01044e4 <syscall+0x32a>
		return -E_INVAL;
	page = page_lookup(srcenv->env_pgdir, srcva, &srcpte);
f010445d:	83 ec 04             	sub    $0x4,%esp
f0104460:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104463:	50                   	push   %eax
f0104464:	ff 75 10             	pushl  0x10(%ebp)
f0104467:	8b 45 dc             	mov    -0x24(%ebp),%eax
f010446a:	ff 70 5c             	pushl  0x5c(%eax)
f010446d:	e8 df cb ff ff       	call   f0101051 <page_lookup>
	if (!page)
f0104472:	83 c4 10             	add    $0x10,%esp
f0104475:	85 c0                	test   %eax,%eax
f0104477:	74 75                	je     f01044ee <syscall+0x334>
		return -E_INVAL;
	if ((perm & PTE_W) && !(*srcpte & PTE_W))
f0104479:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
f010447d:	74 08                	je     f0104487 <syscall+0x2cd>
f010447f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104482:	f6 02 02             	testb  $0x2,(%edx)
f0104485:	74 71                	je     f01044f8 <syscall+0x33e>
		return -E_INVAL;
	if (page_insert(dstenv->env_pgdir, page, dstva, perm))
f0104487:	ff 75 1c             	pushl  0x1c(%ebp)
f010448a:	ff 75 18             	pushl  0x18(%ebp)
f010448d:	50                   	push   %eax
f010448e:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104491:	ff 70 5c             	pushl  0x5c(%eax)
f0104494:	e8 87 cc ff ff       	call   f0101120 <page_insert>
f0104499:	89 c3                	mov    %eax,%ebx
f010449b:	83 c4 10             	add    $0x10,%esp
f010449e:	85 c0                	test   %eax,%eax
f01044a0:	0f 84 f6 02 00 00    	je     f010479c <syscall+0x5e2>
f01044a6:	eb 5a                	jmp    f0104502 <syscall+0x348>
	struct Env *srcenv, *dstenv;
	pte_t *srcpte;
	struct PageInfo *page;
	int flag = PTE_U|PTE_P;
	if (envid2env(srcenvid, &srcenv, 1) || envid2env(dstenvid, &dstenv, 1)) 
		return -E_BAD_ENV;
f01044a8:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01044ad:	e9 ea 02 00 00       	jmp    f010479c <syscall+0x5e2>
f01044b2:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01044b7:	e9 e0 02 00 00       	jmp    f010479c <syscall+0x5e2>
	if ((uint32_t)srcva >= UTOP || PGOFF(srcva) ||
		(uint32_t)dstva >= UTOP || PGOFF(dstva))
		return -E_INVAL;
f01044bc:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044c1:	e9 d6 02 00 00       	jmp    f010479c <syscall+0x5e2>
f01044c6:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044cb:	e9 cc 02 00 00       	jmp    f010479c <syscall+0x5e2>
f01044d0:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044d5:	e9 c2 02 00 00       	jmp    f010479c <syscall+0x5e2>
	if ((perm & flag) != flag) 
		return -E_INVAL;
f01044da:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044df:	e9 b8 02 00 00       	jmp    f010479c <syscall+0x5e2>
	if (perm & ~PTE_SYSCALL)
		return -E_INVAL;
f01044e4:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044e9:	e9 ae 02 00 00       	jmp    f010479c <syscall+0x5e2>
	page = page_lookup(srcenv->env_pgdir, srcva, &srcpte);
	if (!page)
		return -E_INVAL;
f01044ee:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044f3:	e9 a4 02 00 00       	jmp    f010479c <syscall+0x5e2>
	if ((perm & PTE_W) && !(*srcpte & PTE_W))
		return -E_INVAL;
f01044f8:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f01044fd:	e9 9a 02 00 00       	jmp    f010479c <syscall+0x5e2>
	if (page_insert(dstenv->env_pgdir, page, dstva, perm))
		return -E_NO_MEM;
f0104502:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
		case SYS_env_set_status:
			return sys_env_set_status(a1, a2);
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
f0104507:	e9 90 02 00 00       	jmp    f010479c <syscall+0x5e2>
	// Hint: This function is a wrapper around page_remove().

	// LAB 9: Your code here.
	struct Env *task;

	if (envid2env(envid, &task, 1) < 0)
f010450c:	83 ec 04             	sub    $0x4,%esp
f010450f:	6a 01                	push   $0x1
f0104511:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0104514:	50                   	push   %eax
f0104515:	ff 75 0c             	pushl  0xc(%ebp)
f0104518:	e8 d6 e5 ff ff       	call   f0102af3 <envid2env>
f010451d:	83 c4 10             	add    $0x10,%esp
f0104520:	85 c0                	test   %eax,%eax
f0104522:	78 30                	js     f0104554 <syscall+0x39a>
		return -E_BAD_ENV;
	if ((uint32_t)va >= UTOP || PGOFF(va))
f0104524:	81 7d 10 ff ff 7f ee 	cmpl   $0xee7fffff,0x10(%ebp)
f010452b:	77 31                	ja     f010455e <syscall+0x3a4>
f010452d:	f7 45 10 ff 0f 00 00 	testl  $0xfff,0x10(%ebp)
f0104534:	75 32                	jne    f0104568 <syscall+0x3ae>
		return -E_INVAL;

	page_remove(task->env_pgdir, va);
f0104536:	83 ec 08             	sub    $0x8,%esp
f0104539:	ff 75 10             	pushl  0x10(%ebp)
f010453c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010453f:	ff 70 5c             	pushl  0x5c(%eax)
f0104542:	e8 8b cb ff ff       	call   f01010d2 <page_remove>
f0104547:	83 c4 10             	add    $0x10,%esp

	return 0;
f010454a:	bb 00 00 00 00       	mov    $0x0,%ebx
f010454f:	e9 48 02 00 00       	jmp    f010479c <syscall+0x5e2>

	// LAB 9: Your code here.
	struct Env *task;

	if (envid2env(envid, &task, 1) < 0)
		return -E_BAD_ENV;
f0104554:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f0104559:	e9 3e 02 00 00       	jmp    f010479c <syscall+0x5e2>
	if ((uint32_t)va >= UTOP || PGOFF(va))
		return -E_INVAL;
f010455e:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104563:	e9 34 02 00 00       	jmp    f010479c <syscall+0x5e2>
f0104568:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
		case SYS_page_alloc:
			return sys_page_alloc(a1, (void *)a2, a3);
		case SYS_page_map:
			return sys_page_map(a1, (void *)a2, a3, (void *)a4, a5);
		case SYS_page_unmap:
			return sys_page_unmap(a1, (void *)a2);
f010456d:	e9 2a 02 00 00       	jmp    f010479c <syscall+0x5e2>

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f0104572:	e8 9e fb ff ff       	call   f0104115 <sched_yield>
static int
sys_env_set_pgfault_upcall(envid_t envid, void *func)
{
	// LAB 9: Your code here.
	struct Env *e; 
	int ret = envid2env(envid, &e, 1);
f0104577:	83 ec 04             	sub    $0x4,%esp
f010457a:	6a 01                	push   $0x1
f010457c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010457f:	50                   	push   %eax
f0104580:	ff 75 0c             	pushl  0xc(%ebp)
f0104583:	e8 6b e5 ff ff       	call   f0102af3 <envid2env>
	if (ret) 
f0104588:	83 c4 10             	add    $0x10,%esp
f010458b:	85 c0                	test   %eax,%eax
f010458d:	75 09                	jne    f0104598 <syscall+0x3de>
		return ret;
	e->env_pgfault_upcall = func;
f010458f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104592:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104595:	89 7a 60             	mov    %edi,0x60(%edx)
			return sys_page_unmap(a1, (void *)a2);
		case SYS_yield:
			sys_yield();
			return 0;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
f0104598:	89 c3                	mov    %eax,%ebx
f010459a:	e9 fd 01 00 00       	jmp    f010479c <syscall+0x5e2>
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, unsigned perm)
{
	// LAB 9: Your code here.
	//panic("sys_ipc_try_send not implemented");
	struct Env *env;
	if (envid2env(envid, &env, 0)) 
f010459f:	83 ec 04             	sub    $0x4,%esp
f01045a2:	6a 00                	push   $0x0
f01045a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
f01045a7:	50                   	push   %eax
f01045a8:	ff 75 0c             	pushl  0xc(%ebp)
f01045ab:	e8 43 e5 ff ff       	call   f0102af3 <envid2env>
f01045b0:	89 c3                	mov    %eax,%ebx
f01045b2:	83 c4 10             	add    $0x10,%esp
f01045b5:	85 c0                	test   %eax,%eax
f01045b7:	0f 85 f0 00 00 00    	jne    f01046ad <syscall+0x4f3>
			return -E_BAD_ENV;
		if (!env->env_ipc_recving) 
f01045bd:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01045c0:	80 78 64 00          	cmpb   $0x0,0x64(%eax)
f01045c4:	0f 84 ed 00 00 00    	je     f01046b7 <syscall+0x4fd>
			return -E_IPC_NOT_RECV;
		if ((uintptr_t)srcva < UTOP) {
f01045ca:	81 7d 14 ff ff 7f ee 	cmpl   $0xee7fffff,0x14(%ebp)
f01045d1:	0f 87 aa 00 00 00    	ja     f0104681 <syscall+0x4c7>
			if ((uintptr_t)srcva & (PGOFF(srcva) != 0)) 
f01045d7:	f7 45 14 ff 0f 00 00 	testl  $0xfff,0x14(%ebp)
f01045de:	0f 95 c0             	setne  %al
f01045e1:	0f b6 c0             	movzbl %al,%eax
f01045e4:	85 45 14             	test   %eax,0x14(%ebp)
f01045e7:	75 66                	jne    f010464f <syscall+0x495>
				return -E_INVAL;
			if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~PTE_SYSCALL)) 
f01045e9:	8b 45 18             	mov    0x18(%ebp),%eax
f01045ec:	25 fd f1 ff ff       	and    $0xfffff1fd,%eax
f01045f1:	83 f8 05             	cmp    $0x5,%eax
f01045f4:	75 63                	jne    f0104659 <syscall+0x49f>
				return -E_INVAL;
			pte_t *pte;
			struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
f01045f6:	83 ec 04             	sub    $0x4,%esp
f01045f9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01045fc:	50                   	push   %eax
f01045fd:	ff 75 14             	pushl  0x14(%ebp)
f0104600:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f0104605:	ff 70 5c             	pushl  0x5c(%eax)
f0104608:	e8 44 ca ff ff       	call   f0101051 <page_lookup>
			if (!page) 
f010460d:	83 c4 10             	add    $0x10,%esp
f0104610:	85 c0                	test   %eax,%eax
f0104612:	74 4f                	je     f0104663 <syscall+0x4a9>
				return -E_INVAL;
			if ((perm & PTE_W) && !(*pte & PTE_W))
f0104614:	f6 45 18 02          	testb  $0x2,0x18(%ebp)
f0104618:	74 08                	je     f0104622 <syscall+0x468>
f010461a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010461d:	f6 02 02             	testb  $0x2,(%edx)
f0104620:	74 4b                	je     f010466d <syscall+0x4b3>
				return -E_INVAL;
			if ((uintptr_t)env->env_ipc_dstva < UTOP &&
f0104622:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104625:	8b 4a 68             	mov    0x68(%edx),%ecx
f0104628:	81 f9 ff ff 7f ee    	cmp    $0xee7fffff,%ecx
f010462e:	77 14                	ja     f0104644 <syscall+0x48a>
				page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) 
f0104630:	ff 75 18             	pushl  0x18(%ebp)
f0104633:	51                   	push   %ecx
f0104634:	50                   	push   %eax
f0104635:	ff 72 5c             	pushl  0x5c(%edx)
f0104638:	e8 e3 ca ff ff       	call   f0101120 <page_insert>
			struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!page) 
				return -E_INVAL;
			if ((perm & PTE_W) && !(*pte & PTE_W))
				return -E_INVAL;
			if ((uintptr_t)env->env_ipc_dstva < UTOP &&
f010463d:	83 c4 10             	add    $0x10,%esp
f0104640:	85 c0                	test   %eax,%eax
f0104642:	75 33                	jne    f0104677 <syscall+0x4bd>
				page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) 
				return -E_NO_MEM;
			env->env_ipc_perm = perm;
f0104644:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104647:	8b 7d 18             	mov    0x18(%ebp),%edi
f010464a:	89 78 74             	mov    %edi,0x74(%eax)
f010464d:	eb 39                	jmp    f0104688 <syscall+0x4ce>
			return -E_BAD_ENV;
		if (!env->env_ipc_recving) 
			return -E_IPC_NOT_RECV;
		if ((uintptr_t)srcva < UTOP) {
			if ((uintptr_t)srcva & (PGOFF(srcva) != 0)) 
				return -E_INVAL;
f010464f:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104654:	e9 43 01 00 00       	jmp    f010479c <syscall+0x5e2>
			if (!(perm & PTE_U) || !(perm & PTE_P) || (perm & ~PTE_SYSCALL)) 
				return -E_INVAL;
f0104659:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f010465e:	e9 39 01 00 00       	jmp    f010479c <syscall+0x5e2>
			pte_t *pte;
			struct PageInfo *page = page_lookup(curenv->env_pgdir, srcva, &pte);
			if (!page) 
				return -E_INVAL;
f0104663:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104668:	e9 2f 01 00 00       	jmp    f010479c <syscall+0x5e2>
			if ((perm & PTE_W) && !(*pte & PTE_W))
				return -E_INVAL;
f010466d:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
f0104672:	e9 25 01 00 00       	jmp    f010479c <syscall+0x5e2>
			if ((uintptr_t)env->env_ipc_dstva < UTOP &&
				page_insert(env->env_pgdir, page, env->env_ipc_dstva, perm)) 
				return -E_NO_MEM;
f0104677:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
f010467c:	e9 1b 01 00 00       	jmp    f010479c <syscall+0x5e2>
			env->env_ipc_perm = perm;
	}
	else 
		env->env_ipc_perm = 0;
f0104681:	c7 40 74 00 00 00 00 	movl   $0x0,0x74(%eax)
	env->env_ipc_recving = 0;
f0104688:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010468b:	c6 40 64 00          	movb   $0x0,0x64(%eax)
	env->env_ipc_from = curenv->env_id;
f010468f:	8b 15 a8 d3 39 f0    	mov    0xf039d3a8,%edx
f0104695:	8b 52 48             	mov    0x48(%edx),%edx
f0104698:	89 50 70             	mov    %edx,0x70(%eax)
	env->env_ipc_value = value;
f010469b:	8b 4d 10             	mov    0x10(%ebp),%ecx
f010469e:	89 48 6c             	mov    %ecx,0x6c(%eax)
	env->env_status = ENV_RUNNABLE;
f01046a1:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
f01046a8:	e9 ef 00 00 00       	jmp    f010479c <syscall+0x5e2>
{
	// LAB 9: Your code here.
	//panic("sys_ipc_try_send not implemented");
	struct Env *env;
	if (envid2env(envid, &env, 0)) 
			return -E_BAD_ENV;
f01046ad:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
f01046b2:	e9 e5 00 00 00       	jmp    f010479c <syscall+0x5e2>
		if (!env->env_ipc_recving) 
			return -E_IPC_NOT_RECV;
f01046b7:	bb f9 ff ff ff       	mov    $0xfffffff9,%ebx
			sys_yield();
			return 0;
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
f01046bc:	e9 db 00 00 00       	jmp    f010479c <syscall+0x5e2>
//	-E_INVAL if dstva < UTOP but dstva is not page-aligned.
static int
sys_ipc_recv(void *dstva)
{
	// LAB 9: Your code here.
	if ((uintptr_t)dstva < UTOP) {
f01046c1:	81 7d 0c ff ff 7f ee 	cmpl   $0xee7fffff,0xc(%ebp)
f01046c8:	77 20                	ja     f01046ea <syscall+0x530>
		if ((uintptr_t)dstva && (PGOFF(dstva) != 0))  
f01046ca:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01046ce:	74 0d                	je     f01046dd <syscall+0x523>
f01046d0:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
f01046d7:	0f 85 ba 00 00 00    	jne    f0104797 <syscall+0x5dd>
			return -E_INVAL;
		curenv->env_ipc_dstva = dstva;
f01046dd:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f01046e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01046e5:	89 78 68             	mov    %edi,0x68(%eax)
f01046e8:	eb 0c                	jmp    f01046f6 <syscall+0x53c>
	}
	else 
		curenv->env_ipc_dstva = (void *)UTOP;
f01046ea:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f01046ef:	c7 40 68 00 00 80 ee 	movl   $0xee800000,0x68(%eax)
	curenv->env_ipc_recving = 1;
f01046f6:	a1 a8 d3 39 f0       	mov    0xf039d3a8,%eax
f01046fb:	c6 40 64 01          	movb   $0x1,0x64(%eax)
	curenv->env_status = ENV_NOT_RUNNABLE;
f01046ff:	c7 40 54 04 00 00 00 	movl   $0x4,0x54(%eax)
	curenv->env_tf.tf_regs.reg_eax = 0;
f0104706:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

// Deschedule current environment and pick a different one to run.
static void
sys_yield(void)
{
	sched_yield();
f010470d:	e8 03 fa ff ff       	call   f0104115 <sched_yield>
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f0104712:	8b 75 10             	mov    0x10(%ebp),%esi
{
	// LAB 11: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *env;
	if (envid2env(envid, &env, 1))
f0104715:	83 ec 04             	sub    $0x4,%esp
f0104718:	6a 01                	push   $0x1
f010471a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f010471d:	50                   	push   %eax
f010471e:	ff 75 0c             	pushl  0xc(%ebp)
f0104721:	e8 cd e3 ff ff       	call   f0102af3 <envid2env>
f0104726:	89 c3                	mov    %eax,%ebx
f0104728:	83 c4 10             	add    $0x10,%esp
f010472b:	85 c0                	test   %eax,%eax
f010472d:	75 41                	jne    f0104770 <syscall+0x5b6>
		return -E_BAD_ENV;
	user_mem_assert(env, tf, sizeof(*tf), 0);
f010472f:	6a 00                	push   $0x0
f0104731:	6a 44                	push   $0x44
f0104733:	ff 75 10             	pushl  0x10(%ebp)
f0104736:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104739:	e8 00 e3 ff ff       	call   f0102a3e <user_mem_assert>
	env->env_tf = *tf;
f010473e:	b9 11 00 00 00       	mov    $0x11,%ecx
f0104743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104746:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	env->env_tf.tf_ds |= 3;
f0104748:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010474b:	66 83 48 24 03       	orw    $0x3,0x24(%eax)
	env->env_tf.tf_es |= 3;
f0104750:	66 83 48 20 03       	orw    $0x3,0x20(%eax)
	env->env_tf.tf_ss |= 3;
f0104755:	66 83 48 40 03       	orw    $0x3,0x40(%eax)
	env->env_tf.tf_cs |= 3;
f010475a:	66 83 48 34 03       	orw    $0x3,0x34(%eax)
	env->env_tf.tf_eflags |= FL_IF;
	env->env_tf.tf_eflags  &= ~FL_IOPL_MASK;
f010475f:	8b 50 38             	mov    0x38(%eax),%edx
f0104762:	80 e6 cf             	and    $0xcf,%dh
f0104765:	80 ce 02             	or     $0x2,%dh
f0104768:	89 50 38             	mov    %edx,0x38(%eax)
f010476b:	83 c4 10             	add    $0x10,%esp
f010476e:	eb 2c                	jmp    f010479c <syscall+0x5e2>
	// LAB 11: Your code here.
	// Remember to check whether the user has supplied us with a good
	// address!
	struct Env *env;
	if (envid2env(envid, &env, 1))
		return -E_BAD_ENV;
f0104770:	bb fe ff ff ff       	mov    $0xfffffffe,%ebx
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
f0104775:	eb 25                	jmp    f010479c <syscall+0x5e2>
// from 1970-01-01 00:00:00 UTC.
static int
sys_gettime(void)
{
	// LAB 12: Your code here.
	return gettime();
f0104777:	e8 a7 ed ff ff       	call   f0103523 <gettime>
f010477c:	89 c3                	mov    %eax,%ebx
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
		case SYS_env_set_trapframe:
			return sys_env_set_trapframe(a1, (struct Trapframe *)a2);
		case SYS_gettime:
			return sys_gettime();
f010477e:	eb 1c                	jmp    f010479c <syscall+0x5e2>
		default:
			panic("syscall not implemented");
f0104780:	83 ec 04             	sub    $0x4,%esp
f0104783:	68 71 71 10 f0       	push   $0xf0107171
f0104788:	68 c8 01 00 00       	push   $0x1c8
f010478d:	68 89 71 10 f0       	push   $0xf0107189
f0104792:	e8 59 b9 ff ff       	call   f01000f0 <_panic>
		case SYS_env_set_pgfault_upcall:
			return sys_env_set_pgfault_upcall(a1, (void *)a2);
		case SYS_ipc_try_send:
			return sys_ipc_try_send(a1, a2, (void *)a3, a4);
		case SYS_ipc_recv:
			return sys_ipc_recv((void *)a1);
f0104797:	bb fd ff ff ff       	mov    $0xfffffffd,%ebx
			return sys_gettime();
		default:
			panic("syscall not implemented");
			return -E_INVAL;
	}
}
f010479c:	89 d8                	mov    %ebx,%eax
f010479e:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01047a1:	5b                   	pop    %ebx
f01047a2:	5e                   	pop    %esi
f01047a3:	5f                   	pop    %edi
f01047a4:	5d                   	pop    %ebp
f01047a5:	c3                   	ret    

f01047a6 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f01047a6:	55                   	push   %ebp
f01047a7:	89 e5                	mov    %esp,%ebp
f01047a9:	57                   	push   %edi
f01047aa:	56                   	push   %esi
f01047ab:	53                   	push   %ebx
f01047ac:	83 ec 14             	sub    $0x14,%esp
f01047af:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01047b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01047b5:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01047b8:	8b 7d 08             	mov    0x8(%ebp),%edi
	int l = *region_left, r = *region_right, any_matches = 0;
f01047bb:	8b 1a                	mov    (%edx),%ebx
f01047bd:	8b 01                	mov    (%ecx),%eax
f01047bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
f01047c2:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)

	while (l <= r) {
f01047c9:	e9 88 00 00 00       	jmp    f0104856 <stab_binsearch+0xb0>
		int true_m = (l + r) / 2, m = true_m;
f01047ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
f01047d1:	01 d8                	add    %ebx,%eax
f01047d3:	89 c6                	mov    %eax,%esi
f01047d5:	c1 ee 1f             	shr    $0x1f,%esi
f01047d8:	01 c6                	add    %eax,%esi
f01047da:	d1 fe                	sar    %esi
f01047dc:	8d 04 76             	lea    (%esi,%esi,2),%eax
f01047df:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f01047e2:	8d 14 81             	lea    (%ecx,%eax,4),%edx
f01047e5:	89 f0                	mov    %esi,%eax

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01047e7:	eb 03                	jmp    f01047ec <stab_binsearch+0x46>
			m--;
f01047e9:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f01047ec:	39 c3                	cmp    %eax,%ebx
f01047ee:	7f 1f                	jg     f010480f <stab_binsearch+0x69>
f01047f0:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f01047f4:	83 ea 0c             	sub    $0xc,%edx
f01047f7:	39 f9                	cmp    %edi,%ecx
f01047f9:	75 ee                	jne    f01047e9 <stab_binsearch+0x43>
f01047fb:	89 45 e8             	mov    %eax,-0x18(%ebp)
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f01047fe:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104801:	8b 4d ec             	mov    -0x14(%ebp),%ecx
f0104804:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104808:	39 55 0c             	cmp    %edx,0xc(%ebp)
f010480b:	76 18                	jbe    f0104825 <stab_binsearch+0x7f>
f010480d:	eb 05                	jmp    f0104814 <stab_binsearch+0x6e>

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f010480f:	8d 5e 01             	lea    0x1(%esi),%ebx
			continue;
f0104812:	eb 42                	jmp    f0104856 <stab_binsearch+0xb0>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104814:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0104817:	89 03                	mov    %eax,(%ebx)
			l = true_m + 1;
f0104819:	8d 5e 01             	lea    0x1(%esi),%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010481c:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f0104823:	eb 31                	jmp    f0104856 <stab_binsearch+0xb0>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0104825:	39 55 0c             	cmp    %edx,0xc(%ebp)
f0104828:	73 17                	jae    f0104841 <stab_binsearch+0x9b>
			*region_right = m - 1;
f010482a:	8b 45 e8             	mov    -0x18(%ebp),%eax
f010482d:	83 e8 01             	sub    $0x1,%eax
f0104830:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104833:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104836:	89 06                	mov    %eax,(%esi)
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0104838:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
f010483f:	eb 15                	jmp    f0104856 <stab_binsearch+0xb0>
			*region_right = m - 1;
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104841:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f0104844:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104847:	89 1e                	mov    %ebx,(%esi)
			l = m;
			addr++;
f0104849:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f010484d:	89 c3                	mov    %eax,%ebx
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f010484f:	c7 45 e8 01 00 00 00 	movl   $0x1,-0x18(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104856:	3b 5d f0             	cmp    -0x10(%ebp),%ebx
f0104859:	0f 8e 6f ff ff ff    	jle    f01047ce <stab_binsearch+0x28>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f010485f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
f0104863:	75 0f                	jne    f0104874 <stab_binsearch+0xce>
		*region_right = *region_left - 1;
f0104865:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104868:	8b 00                	mov    (%eax),%eax
f010486a:	83 e8 01             	sub    $0x1,%eax
f010486d:	8b 75 e0             	mov    -0x20(%ebp),%esi
f0104870:	89 06                	mov    %eax,(%esi)
f0104872:	eb 2c                	jmp    f01048a0 <stab_binsearch+0xfa>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104874:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104877:	8b 00                	mov    (%eax),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104879:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010487c:	8b 0e                	mov    (%esi),%ecx
f010487e:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104881:	8b 75 ec             	mov    -0x14(%ebp),%esi
f0104884:	8d 14 96             	lea    (%esi,%edx,4),%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104887:	eb 03                	jmp    f010488c <stab_binsearch+0xe6>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
f0104889:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f010488c:	39 c8                	cmp    %ecx,%eax
f010488e:	7e 0b                	jle    f010489b <stab_binsearch+0xf5>
		     l > *region_left && stabs[l].n_type != type;
f0104890:	0f b6 5a 04          	movzbl 0x4(%edx),%ebx
f0104894:	83 ea 0c             	sub    $0xc,%edx
f0104897:	39 fb                	cmp    %edi,%ebx
f0104899:	75 ee                	jne    f0104889 <stab_binsearch+0xe3>
		     l--)
			/* do nothing */;
		*region_left = l;
f010489b:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f010489e:	89 06                	mov    %eax,(%esi)
	}
}
f01048a0:	83 c4 14             	add    $0x14,%esp
f01048a3:	5b                   	pop    %ebx
f01048a4:	5e                   	pop    %esi
f01048a5:	5f                   	pop    %edi
f01048a6:	5d                   	pop    %ebp
f01048a7:	c3                   	ret    

f01048a8 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f01048a8:	55                   	push   %ebp
f01048a9:	89 e5                	mov    %esp,%ebp
f01048ab:	57                   	push   %edi
f01048ac:	56                   	push   %esi
f01048ad:	53                   	push   %ebx
f01048ae:	83 ec 3c             	sub    $0x3c,%esp
f01048b1:	8b 7d 08             	mov    0x8(%ebp),%edi
f01048b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f01048b7:	c7 03 d4 71 10 f0    	movl   $0xf01071d4,(%ebx)
	info->eip_line = 0;
f01048bd:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f01048c4:	c7 43 08 d4 71 10 f0 	movl   $0xf01071d4,0x8(%ebx)
	info->eip_fn_namelen = 9;
f01048cb:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f01048d2:	89 7b 10             	mov    %edi,0x10(%ebx)
	info->eip_fn_narg = 0;
f01048d5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f01048dc:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f01048e2:	77 7e                	ja     f0104962 <debuginfo_eip+0xba>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 8: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
f01048e4:	6a 04                	push   $0x4
f01048e6:	6a 10                	push   $0x10
f01048e8:	68 00 00 20 00       	push   $0x200000
f01048ed:	ff 35 a8 d3 39 f0    	pushl  0xf039d3a8
f01048f3:	e8 b7 e0 ff ff       	call   f01029af <user_mem_check>
f01048f8:	83 c4 10             	add    $0x10,%esp
f01048fb:	85 c0                	test   %eax,%eax
f01048fd:	0f 85 05 02 00 00    	jne    f0104b08 <debuginfo_eip+0x260>
			return -1;

		stabs = usd->stabs;
f0104903:	a1 00 00 20 00       	mov    0x200000,%eax
f0104908:	89 c1                	mov    %eax,%ecx
f010490a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
		stab_end = usd->stab_end;
f010490d:	8b 35 04 00 20 00    	mov    0x200004,%esi
		stabstr = usd->stabstr;
f0104913:	a1 08 00 20 00       	mov    0x200008,%eax
f0104918:	89 45 c0             	mov    %eax,-0x40(%ebp)
		stabstr_end = usd->stabstr_end;
f010491b:	8b 15 0c 00 20 00    	mov    0x20000c,%edx
f0104921:	89 55 bc             	mov    %edx,-0x44(%ebp)

		// Make sure the STABS and string table memory is valid.
		// LAB 8: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
f0104924:	6a 04                	push   $0x4
f0104926:	6a 0c                	push   $0xc
f0104928:	51                   	push   %ecx
f0104929:	ff 35 a8 d3 39 f0    	pushl  0xf039d3a8
f010492f:	e8 7b e0 ff ff       	call   f01029af <user_mem_check>
f0104934:	83 c4 10             	add    $0x10,%esp
f0104937:	85 c0                	test   %eax,%eax
f0104939:	0f 85 d0 01 00 00    	jne    f0104b0f <debuginfo_eip+0x267>
			return -1;

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
f010493f:	6a 04                	push   $0x4
f0104941:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104944:	8b 4d c0             	mov    -0x40(%ebp),%ecx
f0104947:	29 ca                	sub    %ecx,%edx
f0104949:	52                   	push   %edx
f010494a:	51                   	push   %ecx
f010494b:	ff 35 a8 d3 39 f0    	pushl  0xf039d3a8
f0104951:	e8 59 e0 ff ff       	call   f01029af <user_mem_check>
f0104956:	83 c4 10             	add    $0x10,%esp
f0104959:	85 c0                	test   %eax,%eax
f010495b:	74 1f                	je     f010497c <debuginfo_eip+0xd4>
f010495d:	e9 b4 01 00 00       	jmp    f0104b16 <debuginfo_eip+0x26e>
	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
		stabstr_end = __STABSTR_END__;
f0104962:	c7 45 bc 50 50 11 f0 	movl   $0xf0115050,-0x44(%ebp)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
		stabstr = __STABSTR_BEGIN__;
f0104969:	c7 45 c0 31 1c 11 f0 	movl   $0xf0111c31,-0x40(%ebp)
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
		stab_end = __STAB_END__;
f0104970:	be 30 1c 11 f0       	mov    $0xf0111c30,%esi
	info->eip_fn_addr = addr;
	info->eip_fn_narg = 0;

	// Find the relevant set of stabs
	if (addr >= ULIM) {
		stabs = __STAB_BEGIN__;
f0104975:	c7 45 c4 98 75 10 f0 	movl   $0xf0107598,-0x3c(%ebp)
		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010497c:	8b 45 bc             	mov    -0x44(%ebp),%eax
f010497f:	39 45 c0             	cmp    %eax,-0x40(%ebp)
f0104982:	0f 83 95 01 00 00    	jae    f0104b1d <debuginfo_eip+0x275>
f0104988:	80 78 ff 00          	cmpb   $0x0,-0x1(%eax)
f010498c:	0f 85 92 01 00 00    	jne    f0104b24 <debuginfo_eip+0x27c>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104992:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104999:	2b 75 c4             	sub    -0x3c(%ebp),%esi
f010499c:	c1 fe 02             	sar    $0x2,%esi
f010499f:	69 c6 ab aa aa aa    	imul   $0xaaaaaaab,%esi,%eax
f01049a5:	83 e8 01             	sub    $0x1,%eax
f01049a8:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01049ab:	83 ec 08             	sub    $0x8,%esp
f01049ae:	57                   	push   %edi
f01049af:	6a 64                	push   $0x64
f01049b1:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f01049b4:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f01049b7:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f01049ba:	89 f0                	mov    %esi,%eax
f01049bc:	e8 e5 fd ff ff       	call   f01047a6 <stab_binsearch>
	if (lfile == 0)
f01049c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f01049c4:	83 c4 10             	add    $0x10,%esp
f01049c7:	85 c0                	test   %eax,%eax
f01049c9:	0f 84 5c 01 00 00    	je     f0104b2b <debuginfo_eip+0x283>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01049cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f01049d2:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01049d5:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01049d8:	83 ec 08             	sub    $0x8,%esp
f01049db:	57                   	push   %edi
f01049dc:	6a 24                	push   $0x24
f01049de:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f01049e1:	8d 55 dc             	lea    -0x24(%ebp),%edx
f01049e4:	89 f0                	mov    %esi,%eax
f01049e6:	e8 bb fd ff ff       	call   f01047a6 <stab_binsearch>

	if (lfun <= rfun) {
f01049eb:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01049ee:	8b 75 d8             	mov    -0x28(%ebp),%esi
f01049f1:	83 c4 10             	add    $0x10,%esp
f01049f4:	39 f0                	cmp    %esi,%eax
f01049f6:	7f 32                	jg     f0104a2a <debuginfo_eip+0x182>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f01049f8:	8d 14 40             	lea    (%eax,%eax,2),%edx
f01049fb:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01049fe:	8d 0c 91             	lea    (%ecx,%edx,4),%ecx
f0104a01:	8b 11                	mov    (%ecx),%edx
f0104a03:	89 55 b8             	mov    %edx,-0x48(%ebp)
f0104a06:	8b 55 bc             	mov    -0x44(%ebp),%edx
f0104a09:	2b 55 c0             	sub    -0x40(%ebp),%edx
f0104a0c:	39 55 b8             	cmp    %edx,-0x48(%ebp)
f0104a0f:	73 09                	jae    f0104a1a <debuginfo_eip+0x172>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104a11:	8b 55 b8             	mov    -0x48(%ebp),%edx
f0104a14:	03 55 c0             	add    -0x40(%ebp),%edx
f0104a17:	89 53 08             	mov    %edx,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104a1a:	8b 51 08             	mov    0x8(%ecx),%edx
f0104a1d:	89 53 10             	mov    %edx,0x10(%ebx)
		addr -= info->eip_fn_addr;
f0104a20:	29 d7                	sub    %edx,%edi
		// Search within the function definition for the line number.
		lline = lfun;
f0104a22:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfun;
f0104a25:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0104a28:	eb 0f                	jmp    f0104a39 <debuginfo_eip+0x191>
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104a2a:	89 7b 10             	mov    %edi,0x10(%ebx)
		lline = lfile;
f0104a2d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104a30:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		rline = rfile;
f0104a33:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104a36:	89 45 d0             	mov    %eax,-0x30(%ebp)
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104a39:	83 ec 08             	sub    $0x8,%esp
f0104a3c:	6a 3a                	push   $0x3a
f0104a3e:	ff 73 08             	pushl  0x8(%ebx)
f0104a41:	e8 1e 09 00 00       	call   f0105364 <strfind>
f0104a46:	2b 43 08             	sub    0x8(%ebx),%eax
f0104a49:	89 43 0c             	mov    %eax,0xc(%ebx)
	// Hint:
	//	There's a particular stabs type used for line numbers.
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
f0104a4c:	83 c4 08             	add    $0x8,%esp
f0104a4f:	57                   	push   %edi
f0104a50:	6a 44                	push   $0x44
f0104a52:	8d 4d d0             	lea    -0x30(%ebp),%ecx
f0104a55:	8d 55 d4             	lea    -0x2c(%ebp),%edx
f0104a58:	8b 75 c4             	mov    -0x3c(%ebp),%esi
f0104a5b:	89 f0                	mov    %esi,%eax
f0104a5d:	e8 44 fd ff ff       	call   f01047a6 <stab_binsearch>
	if (lline > rline)
f0104a62:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104a65:	83 c4 10             	add    $0x10,%esp
f0104a68:	3b 45 d0             	cmp    -0x30(%ebp),%eax
f0104a6b:	0f 8f c1 00 00 00    	jg     f0104b32 <debuginfo_eip+0x28a>
		return -1;
	info->eip_line = stabs[lline].n_desc;
f0104a71:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104a74:	0f b7 44 86 06       	movzwl 0x6(%esi,%eax,4),%eax
f0104a79:	89 43 04             	mov    %eax,0x4(%ebx)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104a7c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104a7f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0104a82:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104a85:	8d 14 96             	lea    (%esi,%edx,4),%edx
f0104a88:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104a8b:	eb 06                	jmp    f0104a93 <debuginfo_eip+0x1eb>
f0104a8d:	83 e8 01             	sub    $0x1,%eax
f0104a90:	83 ea 0c             	sub    $0xc,%edx
f0104a93:	39 c7                	cmp    %eax,%edi
f0104a95:	7f 2a                	jg     f0104ac1 <debuginfo_eip+0x219>
	       && stabs[lline].n_type != N_SOL
f0104a97:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104a9b:	80 f9 84             	cmp    $0x84,%cl
f0104a9e:	0f 84 9c 00 00 00    	je     f0104b40 <debuginfo_eip+0x298>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104aa4:	80 f9 64             	cmp    $0x64,%cl
f0104aa7:	75 e4                	jne    f0104a8d <debuginfo_eip+0x1e5>
f0104aa9:	83 7a 08 00          	cmpl   $0x0,0x8(%edx)
f0104aad:	74 de                	je     f0104a8d <debuginfo_eip+0x1e5>
f0104aaf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104ab2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0104ab5:	e9 8c 00 00 00       	jmp    f0104b46 <debuginfo_eip+0x29e>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104aba:	03 55 c0             	add    -0x40(%ebp),%edx
f0104abd:	89 13                	mov    %edx,(%ebx)
f0104abf:	eb 03                	jmp    f0104ac4 <debuginfo_eip+0x21c>
f0104ac1:	8b 5d 0c             	mov    0xc(%ebp),%ebx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104ac4:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104ac7:	8b 75 d8             	mov    -0x28(%ebp),%esi
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104aca:	b8 00 00 00 00       	mov    $0x0,%eax
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104acf:	39 f2                	cmp    %esi,%edx
f0104ad1:	0f 8d 8b 00 00 00    	jge    f0104b62 <debuginfo_eip+0x2ba>
		for (lline = lfun + 1;
f0104ad7:	83 c2 01             	add    $0x1,%edx
f0104ada:	89 55 d4             	mov    %edx,-0x2c(%ebp)
f0104add:	89 d0                	mov    %edx,%eax
f0104adf:	8d 14 52             	lea    (%edx,%edx,2),%edx
f0104ae2:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104ae5:	8d 14 97             	lea    (%edi,%edx,4),%edx
f0104ae8:	eb 04                	jmp    f0104aee <debuginfo_eip+0x246>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;
f0104aea:	83 43 14 01          	addl   $0x1,0x14(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104aee:	39 c6                	cmp    %eax,%esi
f0104af0:	7e 47                	jle    f0104b39 <debuginfo_eip+0x291>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104af2:	0f b6 4a 04          	movzbl 0x4(%edx),%ecx
f0104af6:	83 c0 01             	add    $0x1,%eax
f0104af9:	83 c2 0c             	add    $0xc,%edx
f0104afc:	80 f9 a0             	cmp    $0xa0,%cl
f0104aff:	74 e9                	je     f0104aea <debuginfo_eip+0x242>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104b01:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b06:	eb 5a                	jmp    f0104b62 <debuginfo_eip+0x2ba>

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 8: Your code here.
		if (user_mem_check(curenv, usd, sizeof(struct UserStabData), PTE_U))
			return -1;
f0104b08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b0d:	eb 53                	jmp    f0104b62 <debuginfo_eip+0x2ba>
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 8: Your code here.
		if (user_mem_check(curenv, stabs, sizeof(struct Stab), PTE_U))
			return -1;
f0104b0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b14:	eb 4c                	jmp    f0104b62 <debuginfo_eip+0x2ba>

		if (user_mem_check(curenv, stabstr, stabstr_end-stabstr, PTE_U))
			return -1;
f0104b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b1b:	eb 45                	jmp    f0104b62 <debuginfo_eip+0x2ba>
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f0104b1d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b22:	eb 3e                	jmp    f0104b62 <debuginfo_eip+0x2ba>
f0104b24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b29:	eb 37                	jmp    f0104b62 <debuginfo_eip+0x2ba>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f0104b2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b30:	eb 30                	jmp    f0104b62 <debuginfo_eip+0x2ba>
	//	Look at the STABS documentation and <inc/stab.h> to find
	//	which one.
	// Your code here.
	stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
	if (lline > rline)
		return -1;
f0104b32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104b37:	eb 29                	jmp    f0104b62 <debuginfo_eip+0x2ba>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0104b39:	b8 00 00 00 00       	mov    $0x0,%eax
f0104b3e:	eb 22                	jmp    f0104b62 <debuginfo_eip+0x2ba>
f0104b40:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104b43:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104b46:	8d 04 40             	lea    (%eax,%eax,2),%eax
f0104b49:	8b 7d c4             	mov    -0x3c(%ebp),%edi
f0104b4c:	8b 14 87             	mov    (%edi,%eax,4),%edx
f0104b4f:	8b 45 bc             	mov    -0x44(%ebp),%eax
f0104b52:	2b 45 c0             	sub    -0x40(%ebp),%eax
f0104b55:	39 c2                	cmp    %eax,%edx
f0104b57:	0f 82 5d ff ff ff    	jb     f0104aba <debuginfo_eip+0x212>
f0104b5d:	e9 62 ff ff ff       	jmp    f0104ac4 <debuginfo_eip+0x21c>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0104b62:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104b65:	5b                   	pop    %ebx
f0104b66:	5e                   	pop    %esi
f0104b67:	5f                   	pop    %edi
f0104b68:	5d                   	pop    %ebp
f0104b69:	c3                   	ret    

f0104b6a <find_function>:

uintptr_t
find_function(const char * const fname)
{
f0104b6a:	55                   	push   %ebp
f0104b6b:	89 e5                	mov    %esp,%ebp
f0104b6d:	57                   	push   %edi
f0104b6e:	56                   	push   %esi
f0104b6f:	53                   	push   %ebx
f0104b70:	83 ec 18             	sub    $0x18,%esp
	// const struct Stab *stabs = __STAB_BEGIN__, *stab_end = __STAB_END__;
	// const char *stabstr = __STABSTR_BEGIN__, *stabstr_end = __STABSTR_END__;
	//LAB 3: Your code here.
	const struct Stab *stab_start = __STAB_BEGIN__, *stab_end = __STAB_END__, *stab;
	const char *stabstr = __STABSTR_BEGIN__, *str;
	int length = strlen(fname), cmplen;
f0104b73:	ff 75 08             	pushl  0x8(%ebp)
f0104b76:	e8 87 06 00 00       	call   f0105202 <strlen>
f0104b7b:	89 c7                	mov    %eax,%edi
	for (stab = stab_start; stab < stab_end; stab++) {//цикл по все секции .stab
f0104b7d:	83 c4 10             	add    $0x10,%esp
f0104b80:	be 98 75 10 f0       	mov    $0xf0107598,%esi
f0104b85:	eb 3e                	jmp    f0104bc5 <find_function+0x5b>
		str = &stabstr[stab->n_strx];//n_strx - индекс строки с именем функции в секции .stabstr
f0104b87:	8b 06                	mov    (%esi),%eax
f0104b89:	8d 98 31 1c 11 f0    	lea    -0xfeee3cf(%eax),%ebx
		cmplen = strfind(str, ':') - str;
f0104b8f:	83 ec 08             	sub    $0x8,%esp
f0104b92:	6a 3a                	push   $0x3a
f0104b94:	53                   	push   %ebx
f0104b95:	e8 ca 07 00 00       	call   f0105364 <strfind>
f0104b9a:	29 d8                	sub    %ebx,%eax
		if ((stab->n_type == N_FUN) && (length == cmplen) && !strncmp(fname, str, cmplen))
f0104b9c:	83 c4 10             	add    $0x10,%esp
f0104b9f:	39 c7                	cmp    %eax,%edi
f0104ba1:	75 1f                	jne    f0104bc2 <find_function+0x58>
f0104ba3:	80 7e 04 24          	cmpb   $0x24,0x4(%esi)
f0104ba7:	75 19                	jne    f0104bc2 <find_function+0x58>
f0104ba9:	83 ec 04             	sub    $0x4,%esp
f0104bac:	50                   	push   %eax
f0104bad:	53                   	push   %ebx
f0104bae:	ff 75 08             	pushl  0x8(%ebp)
f0104bb1:	e8 55 07 00 00       	call   f010530b <strncmp>
f0104bb6:	83 c4 10             	add    $0x10,%esp
f0104bb9:	85 c0                	test   %eax,%eax
f0104bbb:	75 05                	jne    f0104bc2 <find_function+0x58>
			return stab->n_value;//возвращаем найденный адрес функции
f0104bbd:	8b 46 08             	mov    0x8(%esi),%eax
f0104bc0:	eb 10                	jmp    f0104bd2 <find_function+0x68>
	// const char *stabstr = __STABSTR_BEGIN__, *stabstr_end = __STABSTR_END__;
	//LAB 3: Your code here.
	const struct Stab *stab_start = __STAB_BEGIN__, *stab_end = __STAB_END__, *stab;
	const char *stabstr = __STABSTR_BEGIN__, *str;
	int length = strlen(fname), cmplen;
	for (stab = stab_start; stab < stab_end; stab++) {//цикл по все секции .stab
f0104bc2:	83 c6 0c             	add    $0xc,%esi
f0104bc5:	81 fe 30 1c 11 f0    	cmp    $0xf0111c30,%esi
f0104bcb:	72 ba                	jb     f0104b87 <find_function+0x1d>
		str = &stabstr[stab->n_strx];//n_strx - индекс строки с именем функции в секции .stabstr
		cmplen = strfind(str, ':') - str;
		if ((stab->n_type == N_FUN) && (length == cmplen) && !strncmp(fname, str, cmplen))
			return stab->n_value;//возвращаем найденный адрес функции
	}
	return 0;
f0104bcd:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0104bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104bd5:	5b                   	pop    %ebx
f0104bd6:	5e                   	pop    %esi
f0104bd7:	5f                   	pop    %edi
f0104bd8:	5d                   	pop    %ebp
f0104bd9:	c3                   	ret    

f0104bda <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104bda:	55                   	push   %ebp
f0104bdb:	89 e5                	mov    %esp,%ebp
f0104bdd:	57                   	push   %edi
f0104bde:	56                   	push   %esi
f0104bdf:	53                   	push   %ebx
f0104be0:	83 ec 1c             	sub    $0x1c,%esp
f0104be3:	89 c7                	mov    %eax,%edi
f0104be5:	89 d6                	mov    %edx,%esi
f0104be7:	8b 45 08             	mov    0x8(%ebp),%eax
f0104bea:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104bed:	89 d1                	mov    %edx,%ecx
f0104bef:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104bf2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104bf5:	8b 45 10             	mov    0x10(%ebp),%eax
f0104bf8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104bfb:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104bfe:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0104c05:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
f0104c08:	72 05                	jb     f0104c0f <printnum+0x35>
f0104c0a:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104c0d:	77 3e                	ja     f0104c4d <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104c0f:	83 ec 0c             	sub    $0xc,%esp
f0104c12:	ff 75 18             	pushl  0x18(%ebp)
f0104c15:	83 eb 01             	sub    $0x1,%ebx
f0104c18:	53                   	push   %ebx
f0104c19:	50                   	push   %eax
f0104c1a:	83 ec 08             	sub    $0x8,%esp
f0104c1d:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c20:	ff 75 e0             	pushl  -0x20(%ebp)
f0104c23:	ff 75 dc             	pushl  -0x24(%ebp)
f0104c26:	ff 75 d8             	pushl  -0x28(%ebp)
f0104c29:	e8 22 0c 00 00       	call   f0105850 <__udivdi3>
f0104c2e:	83 c4 18             	add    $0x18,%esp
f0104c31:	52                   	push   %edx
f0104c32:	50                   	push   %eax
f0104c33:	89 f2                	mov    %esi,%edx
f0104c35:	89 f8                	mov    %edi,%eax
f0104c37:	e8 9e ff ff ff       	call   f0104bda <printnum>
f0104c3c:	83 c4 20             	add    $0x20,%esp
f0104c3f:	eb 13                	jmp    f0104c54 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104c41:	83 ec 08             	sub    $0x8,%esp
f0104c44:	56                   	push   %esi
f0104c45:	ff 75 18             	pushl  0x18(%ebp)
f0104c48:	ff d7                	call   *%edi
f0104c4a:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104c4d:	83 eb 01             	sub    $0x1,%ebx
f0104c50:	85 db                	test   %ebx,%ebx
f0104c52:	7f ed                	jg     f0104c41 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104c54:	83 ec 08             	sub    $0x8,%esp
f0104c57:	56                   	push   %esi
f0104c58:	83 ec 04             	sub    $0x4,%esp
f0104c5b:	ff 75 e4             	pushl  -0x1c(%ebp)
f0104c5e:	ff 75 e0             	pushl  -0x20(%ebp)
f0104c61:	ff 75 dc             	pushl  -0x24(%ebp)
f0104c64:	ff 75 d8             	pushl  -0x28(%ebp)
f0104c67:	e8 14 0d 00 00       	call   f0105980 <__umoddi3>
f0104c6c:	83 c4 14             	add    $0x14,%esp
f0104c6f:	0f be 80 de 71 10 f0 	movsbl -0xfef8e22(%eax),%eax
f0104c76:	50                   	push   %eax
f0104c77:	ff d7                	call   *%edi
f0104c79:	83 c4 10             	add    $0x10,%esp
}
f0104c7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
f0104c7f:	5b                   	pop    %ebx
f0104c80:	5e                   	pop    %esi
f0104c81:	5f                   	pop    %edi
f0104c82:	5d                   	pop    %ebp
f0104c83:	c3                   	ret    

f0104c84 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104c84:	55                   	push   %ebp
f0104c85:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104c87:	83 fa 01             	cmp    $0x1,%edx
f0104c8a:	7e 0e                	jle    f0104c9a <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104c8c:	8b 10                	mov    (%eax),%edx
f0104c8e:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104c91:	89 08                	mov    %ecx,(%eax)
f0104c93:	8b 02                	mov    (%edx),%eax
f0104c95:	8b 52 04             	mov    0x4(%edx),%edx
f0104c98:	eb 22                	jmp    f0104cbc <getuint+0x38>
	else if (lflag)
f0104c9a:	85 d2                	test   %edx,%edx
f0104c9c:	74 10                	je     f0104cae <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104c9e:	8b 10                	mov    (%eax),%edx
f0104ca0:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104ca3:	89 08                	mov    %ecx,(%eax)
f0104ca5:	8b 02                	mov    (%edx),%eax
f0104ca7:	ba 00 00 00 00       	mov    $0x0,%edx
f0104cac:	eb 0e                	jmp    f0104cbc <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104cae:	8b 10                	mov    (%eax),%edx
f0104cb0:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104cb3:	89 08                	mov    %ecx,(%eax)
f0104cb5:	8b 02                	mov    (%edx),%eax
f0104cb7:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104cbc:	5d                   	pop    %ebp
f0104cbd:	c3                   	ret    

f0104cbe <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104cbe:	55                   	push   %ebp
f0104cbf:	89 e5                	mov    %esp,%ebp
f0104cc1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104cc4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104cc8:	8b 10                	mov    (%eax),%edx
f0104cca:	3b 50 04             	cmp    0x4(%eax),%edx
f0104ccd:	73 0a                	jae    f0104cd9 <sprintputch+0x1b>
		*b->buf++ = ch;
f0104ccf:	8d 4a 01             	lea    0x1(%edx),%ecx
f0104cd2:	89 08                	mov    %ecx,(%eax)
f0104cd4:	8b 45 08             	mov    0x8(%ebp),%eax
f0104cd7:	88 02                	mov    %al,(%edx)
}
f0104cd9:	5d                   	pop    %ebp
f0104cda:	c3                   	ret    

f0104cdb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f0104cdb:	55                   	push   %ebp
f0104cdc:	89 e5                	mov    %esp,%ebp
f0104cde:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
f0104ce1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
f0104ce4:	50                   	push   %eax
f0104ce5:	ff 75 10             	pushl  0x10(%ebp)
f0104ce8:	ff 75 0c             	pushl  0xc(%ebp)
f0104ceb:	ff 75 08             	pushl  0x8(%ebp)
f0104cee:	e8 05 00 00 00       	call   f0104cf8 <vprintfmt>
	va_end(ap);
f0104cf3:	83 c4 10             	add    $0x10,%esp
}
f0104cf6:	c9                   	leave  
f0104cf7:	c3                   	ret    

f0104cf8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104cf8:	55                   	push   %ebp
f0104cf9:	89 e5                	mov    %esp,%ebp
f0104cfb:	57                   	push   %edi
f0104cfc:	56                   	push   %esi
f0104cfd:	53                   	push   %ebx
f0104cfe:	83 ec 2c             	sub    $0x2c,%esp
f0104d01:	8b 75 08             	mov    0x8(%ebp),%esi
f0104d04:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104d07:	8b 7d 10             	mov    0x10(%ebp),%edi
f0104d0a:	eb 12                	jmp    f0104d1e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104d0c:	85 c0                	test   %eax,%eax
f0104d0e:	0f 84 8d 03 00 00    	je     f01050a1 <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
f0104d14:	83 ec 08             	sub    $0x8,%esp
f0104d17:	53                   	push   %ebx
f0104d18:	50                   	push   %eax
f0104d19:	ff d6                	call   *%esi
f0104d1b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0104d1e:	83 c7 01             	add    $0x1,%edi
f0104d21:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104d25:	83 f8 25             	cmp    $0x25,%eax
f0104d28:	75 e2                	jne    f0104d0c <vprintfmt+0x14>
f0104d2a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
f0104d2e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f0104d35:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104d3c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
f0104d43:	ba 00 00 00 00       	mov    $0x0,%edx
f0104d48:	eb 07                	jmp    f0104d51 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d4a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
f0104d4d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d51:	8d 47 01             	lea    0x1(%edi),%eax
f0104d54:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104d57:	0f b6 07             	movzbl (%edi),%eax
f0104d5a:	0f b6 c8             	movzbl %al,%ecx
f0104d5d:	83 e8 23             	sub    $0x23,%eax
f0104d60:	3c 55                	cmp    $0x55,%al
f0104d62:	0f 87 1e 03 00 00    	ja     f0105086 <vprintfmt+0x38e>
f0104d68:	0f b6 c0             	movzbl %al,%eax
f0104d6b:	ff 24 85 40 73 10 f0 	jmp    *-0xfef8cc0(,%eax,4)
f0104d72:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0104d75:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
f0104d79:	eb d6                	jmp    f0104d51 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104d7b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104d7e:	b8 00 00 00 00       	mov    $0x0,%eax
f0104d83:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0104d86:	8d 04 80             	lea    (%eax,%eax,4),%eax
f0104d89:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
f0104d8d:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
f0104d90:	8d 51 d0             	lea    -0x30(%ecx),%edx
f0104d93:	83 fa 09             	cmp    $0x9,%edx
f0104d96:	77 38                	ja     f0104dd0 <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f0104d98:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
f0104d9b:	eb e9                	jmp    f0104d86 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0104d9d:	8b 45 14             	mov    0x14(%ebp),%eax
f0104da0:	8d 48 04             	lea    0x4(%eax),%ecx
f0104da3:	89 4d 14             	mov    %ecx,0x14(%ebp)
f0104da6:	8b 00                	mov    (%eax),%eax
f0104da8:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0104dae:	eb 26                	jmp    f0104dd6 <vprintfmt+0xde>
f0104db0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104db3:	89 c8                	mov    %ecx,%eax
f0104db5:	c1 f8 1f             	sar    $0x1f,%eax
f0104db8:	f7 d0                	not    %eax
f0104dba:	21 c1                	and    %eax,%ecx
f0104dbc:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104dbf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104dc2:	eb 8d                	jmp    f0104d51 <vprintfmt+0x59>
f0104dc4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0104dc7:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
f0104dce:	eb 81                	jmp    f0104d51 <vprintfmt+0x59>
f0104dd0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f0104dd3:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
f0104dd6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
f0104dda:	0f 89 71 ff ff ff    	jns    f0104d51 <vprintfmt+0x59>
				width = precision, precision = -1;
f0104de0:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104de3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104de6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
f0104ded:	e9 5f ff ff ff       	jmp    f0104d51 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0104df2:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104df5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0104df8:	e9 54 ff ff ff       	jmp    f0104d51 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f0104dfd:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e00:	8d 50 04             	lea    0x4(%eax),%edx
f0104e03:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e06:	83 ec 08             	sub    $0x8,%esp
f0104e09:	53                   	push   %ebx
f0104e0a:	ff 30                	pushl  (%eax)
f0104e0c:	ff d6                	call   *%esi
			break;
f0104e0e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e11:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
f0104e14:	e9 05 ff ff ff       	jmp    f0104d1e <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
f0104e19:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e1c:	8d 50 04             	lea    0x4(%eax),%edx
f0104e1f:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e22:	8b 00                	mov    (%eax),%eax
f0104e24:	99                   	cltd   
f0104e25:	31 d0                	xor    %edx,%eax
f0104e27:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0104e29:	83 f8 0f             	cmp    $0xf,%eax
f0104e2c:	7f 0b                	jg     f0104e39 <vprintfmt+0x141>
f0104e2e:	8b 14 85 c0 74 10 f0 	mov    -0xfef8b40(,%eax,4),%edx
f0104e35:	85 d2                	test   %edx,%edx
f0104e37:	75 18                	jne    f0104e51 <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
f0104e39:	50                   	push   %eax
f0104e3a:	68 f6 71 10 f0       	push   $0xf01071f6
f0104e3f:	53                   	push   %ebx
f0104e40:	56                   	push   %esi
f0104e41:	e8 95 fe ff ff       	call   f0104cdb <printfmt>
f0104e46:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e49:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f0104e4c:	e9 cd fe ff ff       	jmp    f0104d1e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
f0104e51:	52                   	push   %edx
f0104e52:	68 a6 61 10 f0       	push   $0xf01061a6
f0104e57:	53                   	push   %ebx
f0104e58:	56                   	push   %esi
f0104e59:	e8 7d fe ff ff       	call   f0104cdb <printfmt>
f0104e5e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104e61:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104e64:	e9 b5 fe ff ff       	jmp    f0104d1e <vprintfmt+0x26>
f0104e69:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104e6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104e6f:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0104e72:	8b 45 14             	mov    0x14(%ebp),%eax
f0104e75:	8d 50 04             	lea    0x4(%eax),%edx
f0104e78:	89 55 14             	mov    %edx,0x14(%ebp)
f0104e7b:	8b 38                	mov    (%eax),%edi
f0104e7d:	85 ff                	test   %edi,%edi
f0104e7f:	75 05                	jne    f0104e86 <vprintfmt+0x18e>
				p = "(null)";
f0104e81:	bf ef 71 10 f0       	mov    $0xf01071ef,%edi
			if (width > 0 && padc != '-')
f0104e86:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
f0104e8a:	0f 84 91 00 00 00    	je     f0104f21 <vprintfmt+0x229>
f0104e90:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
f0104e94:	0f 8e 95 00 00 00    	jle    f0104f2f <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
f0104e9a:	83 ec 08             	sub    $0x8,%esp
f0104e9d:	51                   	push   %ecx
f0104e9e:	57                   	push   %edi
f0104e9f:	e8 76 03 00 00       	call   f010521a <strnlen>
f0104ea4:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104ea7:	29 c1                	sub    %eax,%ecx
f0104ea9:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0104eac:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
f0104eaf:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
f0104eb3:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0104eb6:	89 7d d4             	mov    %edi,-0x2c(%ebp)
f0104eb9:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104ebb:	eb 0f                	jmp    f0104ecc <vprintfmt+0x1d4>
					putch(padc, putdat);
f0104ebd:	83 ec 08             	sub    $0x8,%esp
f0104ec0:	53                   	push   %ebx
f0104ec1:	ff 75 e0             	pushl  -0x20(%ebp)
f0104ec4:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0104ec6:	83 ef 01             	sub    $0x1,%edi
f0104ec9:	83 c4 10             	add    $0x10,%esp
f0104ecc:	85 ff                	test   %edi,%edi
f0104ece:	7f ed                	jg     f0104ebd <vprintfmt+0x1c5>
f0104ed0:	8b 7d d4             	mov    -0x2c(%ebp),%edi
f0104ed3:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0104ed6:	89 c8                	mov    %ecx,%eax
f0104ed8:	c1 f8 1f             	sar    $0x1f,%eax
f0104edb:	f7 d0                	not    %eax
f0104edd:	21 c8                	and    %ecx,%eax
f0104edf:	29 c1                	sub    %eax,%ecx
f0104ee1:	89 75 08             	mov    %esi,0x8(%ebp)
f0104ee4:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104ee7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104eea:	89 cb                	mov    %ecx,%ebx
f0104eec:	eb 4d                	jmp    f0104f3b <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0104eee:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
f0104ef2:	74 1b                	je     f0104f0f <vprintfmt+0x217>
f0104ef4:	0f be c0             	movsbl %al,%eax
f0104ef7:	83 e8 20             	sub    $0x20,%eax
f0104efa:	83 f8 5e             	cmp    $0x5e,%eax
f0104efd:	76 10                	jbe    f0104f0f <vprintfmt+0x217>
					putch('?', putdat);
f0104eff:	83 ec 08             	sub    $0x8,%esp
f0104f02:	ff 75 0c             	pushl  0xc(%ebp)
f0104f05:	6a 3f                	push   $0x3f
f0104f07:	ff 55 08             	call   *0x8(%ebp)
f0104f0a:	83 c4 10             	add    $0x10,%esp
f0104f0d:	eb 0d                	jmp    f0104f1c <vprintfmt+0x224>
				else
					putch(ch, putdat);
f0104f0f:	83 ec 08             	sub    $0x8,%esp
f0104f12:	ff 75 0c             	pushl  0xc(%ebp)
f0104f15:	52                   	push   %edx
f0104f16:	ff 55 08             	call   *0x8(%ebp)
f0104f19:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0104f1c:	83 eb 01             	sub    $0x1,%ebx
f0104f1f:	eb 1a                	jmp    f0104f3b <vprintfmt+0x243>
f0104f21:	89 75 08             	mov    %esi,0x8(%ebp)
f0104f24:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104f27:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f2a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104f2d:	eb 0c                	jmp    f0104f3b <vprintfmt+0x243>
f0104f2f:	89 75 08             	mov    %esi,0x8(%ebp)
f0104f32:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104f35:	89 5d 0c             	mov    %ebx,0xc(%ebp)
f0104f38:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f0104f3b:	83 c7 01             	add    $0x1,%edi
f0104f3e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
f0104f42:	0f be d0             	movsbl %al,%edx
f0104f45:	85 d2                	test   %edx,%edx
f0104f47:	74 23                	je     f0104f6c <vprintfmt+0x274>
f0104f49:	85 f6                	test   %esi,%esi
f0104f4b:	78 a1                	js     f0104eee <vprintfmt+0x1f6>
f0104f4d:	83 ee 01             	sub    $0x1,%esi
f0104f50:	79 9c                	jns    f0104eee <vprintfmt+0x1f6>
f0104f52:	89 df                	mov    %ebx,%edi
f0104f54:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f57:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f5a:	eb 18                	jmp    f0104f74 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f0104f5c:	83 ec 08             	sub    $0x8,%esp
f0104f5f:	53                   	push   %ebx
f0104f60:	6a 20                	push   $0x20
f0104f62:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0104f64:	83 ef 01             	sub    $0x1,%edi
f0104f67:	83 c4 10             	add    $0x10,%esp
f0104f6a:	eb 08                	jmp    f0104f74 <vprintfmt+0x27c>
f0104f6c:	89 df                	mov    %ebx,%edi
f0104f6e:	8b 75 08             	mov    0x8(%ebp),%esi
f0104f71:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104f74:	85 ff                	test   %edi,%edi
f0104f76:	7f e4                	jg     f0104f5c <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0104f78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f0104f7b:	e9 9e fd ff ff       	jmp    f0104d1e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f0104f80:	83 fa 01             	cmp    $0x1,%edx
f0104f83:	7e 16                	jle    f0104f9b <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
f0104f85:	8b 45 14             	mov    0x14(%ebp),%eax
f0104f88:	8d 50 08             	lea    0x8(%eax),%edx
f0104f8b:	89 55 14             	mov    %edx,0x14(%ebp)
f0104f8e:	8b 50 04             	mov    0x4(%eax),%edx
f0104f91:	8b 00                	mov    (%eax),%eax
f0104f93:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104f96:	89 55 dc             	mov    %edx,-0x24(%ebp)
f0104f99:	eb 32                	jmp    f0104fcd <vprintfmt+0x2d5>
	else if (lflag)
f0104f9b:	85 d2                	test   %edx,%edx
f0104f9d:	74 18                	je     f0104fb7 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
f0104f9f:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fa2:	8d 50 04             	lea    0x4(%eax),%edx
f0104fa5:	89 55 14             	mov    %edx,0x14(%ebp)
f0104fa8:	8b 00                	mov    (%eax),%eax
f0104faa:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fad:	89 c1                	mov    %eax,%ecx
f0104faf:	c1 f9 1f             	sar    $0x1f,%ecx
f0104fb2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f0104fb5:	eb 16                	jmp    f0104fcd <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
f0104fb7:	8b 45 14             	mov    0x14(%ebp),%eax
f0104fba:	8d 50 04             	lea    0x4(%eax),%edx
f0104fbd:	89 55 14             	mov    %edx,0x14(%ebp)
f0104fc0:	8b 00                	mov    (%eax),%eax
f0104fc2:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104fc5:	89 c1                	mov    %eax,%ecx
f0104fc7:	c1 f9 1f             	sar    $0x1f,%ecx
f0104fca:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f0104fcd:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104fd0:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f0104fd3:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f0104fd8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
f0104fdc:	79 74                	jns    f0105052 <vprintfmt+0x35a>
				putch('-', putdat);
f0104fde:	83 ec 08             	sub    $0x8,%esp
f0104fe1:	53                   	push   %ebx
f0104fe2:	6a 2d                	push   $0x2d
f0104fe4:	ff d6                	call   *%esi
				num = -(long long) num;
f0104fe6:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104fe9:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104fec:	f7 d8                	neg    %eax
f0104fee:	83 d2 00             	adc    $0x0,%edx
f0104ff1:	f7 da                	neg    %edx
f0104ff3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
f0104ff6:	b9 0a 00 00 00       	mov    $0xa,%ecx
f0104ffb:	eb 55                	jmp    f0105052 <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0104ffd:	8d 45 14             	lea    0x14(%ebp),%eax
f0105000:	e8 7f fc ff ff       	call   f0104c84 <getuint>
			base = 10;
f0105005:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
f010500a:	eb 46                	jmp    f0105052 <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f010500c:	8d 45 14             	lea    0x14(%ebp),%eax
f010500f:	e8 70 fc ff ff       	call   f0104c84 <getuint>
			base = 8;
f0105014:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
f0105019:	eb 37                	jmp    f0105052 <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
f010501b:	83 ec 08             	sub    $0x8,%esp
f010501e:	53                   	push   %ebx
f010501f:	6a 30                	push   $0x30
f0105021:	ff d6                	call   *%esi
			putch('x', putdat);
f0105023:	83 c4 08             	add    $0x8,%esp
f0105026:	53                   	push   %ebx
f0105027:	6a 78                	push   $0x78
f0105029:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f010502b:	8b 45 14             	mov    0x14(%ebp),%eax
f010502e:	8d 50 04             	lea    0x4(%eax),%edx
f0105031:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0105034:	8b 00                	mov    (%eax),%eax
f0105036:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010503b:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010503e:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
f0105043:	eb 0d                	jmp    f0105052 <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0105045:	8d 45 14             	lea    0x14(%ebp),%eax
f0105048:	e8 37 fc ff ff       	call   f0104c84 <getuint>
			base = 16;
f010504d:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
f0105052:	83 ec 0c             	sub    $0xc,%esp
f0105055:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
f0105059:	57                   	push   %edi
f010505a:	ff 75 e0             	pushl  -0x20(%ebp)
f010505d:	51                   	push   %ecx
f010505e:	52                   	push   %edx
f010505f:	50                   	push   %eax
f0105060:	89 da                	mov    %ebx,%edx
f0105062:	89 f0                	mov    %esi,%eax
f0105064:	e8 71 fb ff ff       	call   f0104bda <printnum>
			break;
f0105069:	83 c4 20             	add    $0x20,%esp
f010506c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
f010506f:	e9 aa fc ff ff       	jmp    f0104d1e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f0105074:	83 ec 08             	sub    $0x8,%esp
f0105077:	53                   	push   %ebx
f0105078:	51                   	push   %ecx
f0105079:	ff d6                	call   *%esi
			break;
f010507b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010507e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
f0105081:	e9 98 fc ff ff       	jmp    f0104d1e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f0105086:	83 ec 08             	sub    $0x8,%esp
f0105089:	53                   	push   %ebx
f010508a:	6a 25                	push   $0x25
f010508c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
f010508e:	83 c4 10             	add    $0x10,%esp
f0105091:	eb 03                	jmp    f0105096 <vprintfmt+0x39e>
f0105093:	83 ef 01             	sub    $0x1,%edi
f0105096:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
f010509a:	75 f7                	jne    f0105093 <vprintfmt+0x39b>
f010509c:	e9 7d fc ff ff       	jmp    f0104d1e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
f01050a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01050a4:	5b                   	pop    %ebx
f01050a5:	5e                   	pop    %esi
f01050a6:	5f                   	pop    %edi
f01050a7:	5d                   	pop    %ebp
f01050a8:	c3                   	ret    

f01050a9 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f01050a9:	55                   	push   %ebp
f01050aa:	89 e5                	mov    %esp,%ebp
f01050ac:	83 ec 18             	sub    $0x18,%esp
f01050af:	8b 45 08             	mov    0x8(%ebp),%eax
f01050b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
f01050b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
f01050b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
f01050bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f01050bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
f01050c6:	85 c0                	test   %eax,%eax
f01050c8:	74 26                	je     f01050f0 <vsnprintf+0x47>
f01050ca:	85 d2                	test   %edx,%edx
f01050cc:	7e 22                	jle    f01050f0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f01050ce:	ff 75 14             	pushl  0x14(%ebp)
f01050d1:	ff 75 10             	pushl  0x10(%ebp)
f01050d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
f01050d7:	50                   	push   %eax
f01050d8:	68 be 4c 10 f0       	push   $0xf0104cbe
f01050dd:	e8 16 fc ff ff       	call   f0104cf8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f01050e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
f01050e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f01050e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
f01050eb:	83 c4 10             	add    $0x10,%esp
f01050ee:	eb 05                	jmp    f01050f5 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f01050f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f01050f5:	c9                   	leave  
f01050f6:	c3                   	ret    

f01050f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f01050f7:	55                   	push   %ebp
f01050f8:	89 e5                	mov    %esp,%ebp
f01050fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
f01050fd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
f0105100:	50                   	push   %eax
f0105101:	ff 75 10             	pushl  0x10(%ebp)
f0105104:	ff 75 0c             	pushl  0xc(%ebp)
f0105107:	ff 75 08             	pushl  0x8(%ebp)
f010510a:	e8 9a ff ff ff       	call   f01050a9 <vsnprintf>
	va_end(ap);

	return rc;
}
f010510f:	c9                   	leave  
f0105110:	c3                   	ret    

f0105111 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0105111:	55                   	push   %ebp
f0105112:	89 e5                	mov    %esp,%ebp
f0105114:	57                   	push   %edi
f0105115:	56                   	push   %esi
f0105116:	53                   	push   %ebx
f0105117:	83 ec 0c             	sub    $0xc,%esp
f010511a:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL) {
f010511d:	85 c0                	test   %eax,%eax
f010511f:	74 11                	je     f0105132 <readline+0x21>
#if JOS_KERNEL
		cprintf("%s", prompt);
f0105121:	83 ec 08             	sub    $0x8,%esp
f0105124:	50                   	push   %eax
f0105125:	68 a6 61 10 f0       	push   $0xf01061a6
f010512a:	e8 17 e6 ff ff       	call   f0103746 <cprintf>
f010512f:	83 c4 10             	add    $0x10,%esp
		fprintf(1, "%s", prompt);
#endif
	}

	i = 0;
	echoing = iscons(0);
f0105132:	83 ec 0c             	sub    $0xc,%esp
f0105135:	6a 00                	push   $0x0
f0105137:	e8 5c b5 ff ff       	call   f0100698 <iscons>
f010513c:	89 c7                	mov    %eax,%edi
f010513e:	83 c4 10             	add    $0x10,%esp
#else
		fprintf(1, "%s", prompt);
#endif
	}

	i = 0;
f0105141:	be 00 00 00 00       	mov    $0x0,%esi
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0105146:	e8 3c b5 ff ff       	call   f0100687 <getchar>
f010514b:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010514d:	85 c0                	test   %eax,%eax
f010514f:	79 29                	jns    f010517a <readline+0x69>
			if (c != -E_EOF)
				cprintf("read error: %i\n", c);
			return NULL;
f0105151:	b8 00 00 00 00       	mov    $0x0,%eax
	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
f0105156:	83 fb f8             	cmp    $0xfffffff8,%ebx
f0105159:	0f 84 9b 00 00 00    	je     f01051fa <readline+0xe9>
				cprintf("read error: %i\n", c);
f010515f:	83 ec 08             	sub    $0x8,%esp
f0105162:	53                   	push   %ebx
f0105163:	68 1f 75 10 f0       	push   $0xf010751f
f0105168:	e8 d9 e5 ff ff       	call   f0103746 <cprintf>
f010516d:	83 c4 10             	add    $0x10,%esp
			return NULL;
f0105170:	b8 00 00 00 00       	mov    $0x0,%eax
f0105175:	e9 80 00 00 00       	jmp    f01051fa <readline+0xe9>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f010517a:	83 f8 7f             	cmp    $0x7f,%eax
f010517d:	0f 94 c2             	sete   %dl
f0105180:	83 f8 08             	cmp    $0x8,%eax
f0105183:	0f 94 c0             	sete   %al
f0105186:	08 c2                	or     %al,%dl
f0105188:	74 1a                	je     f01051a4 <readline+0x93>
f010518a:	85 f6                	test   %esi,%esi
f010518c:	7e 16                	jle    f01051a4 <readline+0x93>
			if (echoing)
f010518e:	85 ff                	test   %edi,%edi
f0105190:	74 0d                	je     f010519f <readline+0x8e>
				cputchar('\b');
f0105192:	83 ec 0c             	sub    $0xc,%esp
f0105195:	6a 08                	push   $0x8
f0105197:	e8 db b4 ff ff       	call   f0100677 <cputchar>
f010519c:	83 c4 10             	add    $0x10,%esp
			i--;
f010519f:	83 ee 01             	sub    $0x1,%esi
f01051a2:	eb a2                	jmp    f0105146 <readline+0x35>
		} else if (c >= ' ' && i < BUFLEN-1) {
f01051a4:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f01051aa:	7f 23                	jg     f01051cf <readline+0xbe>
f01051ac:	83 fb 1f             	cmp    $0x1f,%ebx
f01051af:	7e 1e                	jle    f01051cf <readline+0xbe>
			if (echoing)
f01051b1:	85 ff                	test   %edi,%edi
f01051b3:	74 0c                	je     f01051c1 <readline+0xb0>
				cputchar(c);
f01051b5:	83 ec 0c             	sub    $0xc,%esp
f01051b8:	53                   	push   %ebx
f01051b9:	e8 b9 b4 ff ff       	call   f0100677 <cputchar>
f01051be:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
f01051c1:	88 9e 80 dc 39 f0    	mov    %bl,-0xfc62380(%esi)
f01051c7:	8d 76 01             	lea    0x1(%esi),%esi
f01051ca:	e9 77 ff ff ff       	jmp    f0105146 <readline+0x35>
		} else if (c == '\n' || c == '\r') {
f01051cf:	83 fb 0d             	cmp    $0xd,%ebx
f01051d2:	74 09                	je     f01051dd <readline+0xcc>
f01051d4:	83 fb 0a             	cmp    $0xa,%ebx
f01051d7:	0f 85 69 ff ff ff    	jne    f0105146 <readline+0x35>
			if (echoing)
f01051dd:	85 ff                	test   %edi,%edi
f01051df:	74 0d                	je     f01051ee <readline+0xdd>
				cputchar('\n');
f01051e1:	83 ec 0c             	sub    $0xc,%esp
f01051e4:	6a 0a                	push   $0xa
f01051e6:	e8 8c b4 ff ff       	call   f0100677 <cputchar>
f01051eb:	83 c4 10             	add    $0x10,%esp
			buf[i] = 0;
f01051ee:	c6 86 80 dc 39 f0 00 	movb   $0x0,-0xfc62380(%esi)
			return buf;
f01051f5:	b8 80 dc 39 f0       	mov    $0xf039dc80,%eax
		}
	}
}
f01051fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
f01051fd:	5b                   	pop    %ebx
f01051fe:	5e                   	pop    %esi
f01051ff:	5f                   	pop    %edi
f0105200:	5d                   	pop    %ebp
f0105201:	c3                   	ret    

f0105202 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f0105202:	55                   	push   %ebp
f0105203:	89 e5                	mov    %esp,%ebp
f0105205:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f0105208:	b8 00 00 00 00       	mov    $0x0,%eax
f010520d:	eb 03                	jmp    f0105212 <strlen+0x10>
		n++;
f010520f:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0105212:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f0105216:	75 f7                	jne    f010520f <strlen+0xd>
		n++;
	return n;
}
f0105218:	5d                   	pop    %ebp
f0105219:	c3                   	ret    

f010521a <strnlen>:

int
strnlen(const char *s, size_t size)
{
f010521a:	55                   	push   %ebp
f010521b:	89 e5                	mov    %esp,%ebp
f010521d:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0105220:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0105223:	ba 00 00 00 00       	mov    $0x0,%edx
f0105228:	eb 03                	jmp    f010522d <strnlen+0x13>
		n++;
f010522a:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f010522d:	39 c2                	cmp    %eax,%edx
f010522f:	74 08                	je     f0105239 <strnlen+0x1f>
f0105231:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
f0105235:	75 f3                	jne    f010522a <strnlen+0x10>
f0105237:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
f0105239:	5d                   	pop    %ebp
f010523a:	c3                   	ret    

f010523b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f010523b:	55                   	push   %ebp
f010523c:	89 e5                	mov    %esp,%ebp
f010523e:	53                   	push   %ebx
f010523f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105245:	89 c2                	mov    %eax,%edx
f0105247:	83 c2 01             	add    $0x1,%edx
f010524a:	83 c1 01             	add    $0x1,%ecx
f010524d:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
f0105251:	88 5a ff             	mov    %bl,-0x1(%edx)
f0105254:	84 db                	test   %bl,%bl
f0105256:	75 ef                	jne    f0105247 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0105258:	5b                   	pop    %ebx
f0105259:	5d                   	pop    %ebp
f010525a:	c3                   	ret    

f010525b <strcat>:

char *
strcat(char *dst, const char *src)
{
f010525b:	55                   	push   %ebp
f010525c:	89 e5                	mov    %esp,%ebp
f010525e:	53                   	push   %ebx
f010525f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105262:	53                   	push   %ebx
f0105263:	e8 9a ff ff ff       	call   f0105202 <strlen>
f0105268:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
f010526b:	ff 75 0c             	pushl  0xc(%ebp)
f010526e:	01 d8                	add    %ebx,%eax
f0105270:	50                   	push   %eax
f0105271:	e8 c5 ff ff ff       	call   f010523b <strcpy>
	return dst;
}
f0105276:	89 d8                	mov    %ebx,%eax
f0105278:	8b 5d fc             	mov    -0x4(%ebp),%ebx
f010527b:	c9                   	leave  
f010527c:	c3                   	ret    

f010527d <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f010527d:	55                   	push   %ebp
f010527e:	89 e5                	mov    %esp,%ebp
f0105280:	56                   	push   %esi
f0105281:	53                   	push   %ebx
f0105282:	8b 75 08             	mov    0x8(%ebp),%esi
f0105285:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f0105288:	89 f3                	mov    %esi,%ebx
f010528a:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f010528d:	89 f2                	mov    %esi,%edx
f010528f:	eb 0f                	jmp    f01052a0 <strncpy+0x23>
		*dst++ = *src;
f0105291:	83 c2 01             	add    $0x1,%edx
f0105294:	0f b6 01             	movzbl (%ecx),%eax
f0105297:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f010529a:	80 39 01             	cmpb   $0x1,(%ecx)
f010529d:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f01052a0:	39 da                	cmp    %ebx,%edx
f01052a2:	75 ed                	jne    f0105291 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f01052a4:	89 f0                	mov    %esi,%eax
f01052a6:	5b                   	pop    %ebx
f01052a7:	5e                   	pop    %esi
f01052a8:	5d                   	pop    %ebp
f01052a9:	c3                   	ret    

f01052aa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f01052aa:	55                   	push   %ebp
f01052ab:	89 e5                	mov    %esp,%ebp
f01052ad:	56                   	push   %esi
f01052ae:	53                   	push   %ebx
f01052af:	8b 75 08             	mov    0x8(%ebp),%esi
f01052b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01052b5:	8b 55 10             	mov    0x10(%ebp),%edx
f01052b8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f01052ba:	85 d2                	test   %edx,%edx
f01052bc:	74 21                	je     f01052df <strlcpy+0x35>
f01052be:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
f01052c2:	89 f2                	mov    %esi,%edx
f01052c4:	eb 09                	jmp    f01052cf <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
f01052c6:	83 c2 01             	add    $0x1,%edx
f01052c9:	83 c1 01             	add    $0x1,%ecx
f01052cc:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01052cf:	39 c2                	cmp    %eax,%edx
f01052d1:	74 09                	je     f01052dc <strlcpy+0x32>
f01052d3:	0f b6 19             	movzbl (%ecx),%ebx
f01052d6:	84 db                	test   %bl,%bl
f01052d8:	75 ec                	jne    f01052c6 <strlcpy+0x1c>
f01052da:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
f01052dc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
f01052df:	29 f0                	sub    %esi,%eax
}
f01052e1:	5b                   	pop    %ebx
f01052e2:	5e                   	pop    %esi
f01052e3:	5d                   	pop    %ebp
f01052e4:	c3                   	ret    

f01052e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01052e5:	55                   	push   %ebp
f01052e6:	89 e5                	mov    %esp,%ebp
f01052e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01052eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01052ee:	eb 06                	jmp    f01052f6 <strcmp+0x11>
		p++, q++;
f01052f0:	83 c1 01             	add    $0x1,%ecx
f01052f3:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01052f6:	0f b6 01             	movzbl (%ecx),%eax
f01052f9:	84 c0                	test   %al,%al
f01052fb:	74 04                	je     f0105301 <strcmp+0x1c>
f01052fd:	3a 02                	cmp    (%edx),%al
f01052ff:	74 ef                	je     f01052f0 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0105301:	0f b6 c0             	movzbl %al,%eax
f0105304:	0f b6 12             	movzbl (%edx),%edx
f0105307:	29 d0                	sub    %edx,%eax
}
f0105309:	5d                   	pop    %ebp
f010530a:	c3                   	ret    

f010530b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f010530b:	55                   	push   %ebp
f010530c:	89 e5                	mov    %esp,%ebp
f010530e:	53                   	push   %ebx
f010530f:	8b 45 08             	mov    0x8(%ebp),%eax
f0105312:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105315:	89 c3                	mov    %eax,%ebx
f0105317:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
f010531a:	eb 06                	jmp    f0105322 <strncmp+0x17>
		n--, p++, q++;
f010531c:	83 c0 01             	add    $0x1,%eax
f010531f:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0105322:	39 d8                	cmp    %ebx,%eax
f0105324:	74 15                	je     f010533b <strncmp+0x30>
f0105326:	0f b6 08             	movzbl (%eax),%ecx
f0105329:	84 c9                	test   %cl,%cl
f010532b:	74 04                	je     f0105331 <strncmp+0x26>
f010532d:	3a 0a                	cmp    (%edx),%cl
f010532f:	74 eb                	je     f010531c <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105331:	0f b6 00             	movzbl (%eax),%eax
f0105334:	0f b6 12             	movzbl (%edx),%edx
f0105337:	29 d0                	sub    %edx,%eax
f0105339:	eb 05                	jmp    f0105340 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
f010533b:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f0105340:	5b                   	pop    %ebx
f0105341:	5d                   	pop    %ebp
f0105342:	c3                   	ret    

f0105343 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0105343:	55                   	push   %ebp
f0105344:	89 e5                	mov    %esp,%ebp
f0105346:	8b 45 08             	mov    0x8(%ebp),%eax
f0105349:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010534d:	eb 07                	jmp    f0105356 <strchr+0x13>
		if (*s == c)
f010534f:	38 ca                	cmp    %cl,%dl
f0105351:	74 0f                	je     f0105362 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0105353:	83 c0 01             	add    $0x1,%eax
f0105356:	0f b6 10             	movzbl (%eax),%edx
f0105359:	84 d2                	test   %dl,%dl
f010535b:	75 f2                	jne    f010534f <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
f010535d:	b8 00 00 00 00       	mov    $0x0,%eax
}
f0105362:	5d                   	pop    %ebp
f0105363:	c3                   	ret    

f0105364 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0105364:	55                   	push   %ebp
f0105365:	89 e5                	mov    %esp,%ebp
f0105367:	8b 45 08             	mov    0x8(%ebp),%eax
f010536a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f010536e:	eb 03                	jmp    f0105373 <strfind+0xf>
f0105370:	83 c0 01             	add    $0x1,%eax
f0105373:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
f0105376:	84 d2                	test   %dl,%dl
f0105378:	74 04                	je     f010537e <strfind+0x1a>
f010537a:	38 ca                	cmp    %cl,%dl
f010537c:	75 f2                	jne    f0105370 <strfind+0xc>
			break;
	return (char *) s;
}
f010537e:	5d                   	pop    %ebp
f010537f:	c3                   	ret    

f0105380 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105380:	55                   	push   %ebp
f0105381:	89 e5                	mov    %esp,%ebp
f0105383:	57                   	push   %edi
f0105384:	56                   	push   %esi
f0105385:	53                   	push   %ebx
f0105386:	8b 7d 08             	mov    0x8(%ebp),%edi
f0105389:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
f010538c:	85 c9                	test   %ecx,%ecx
f010538e:	74 36                	je     f01053c6 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f0105390:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105396:	75 28                	jne    f01053c0 <memset+0x40>
f0105398:	f6 c1 03             	test   $0x3,%cl
f010539b:	75 23                	jne    f01053c0 <memset+0x40>
		c &= 0xFF;
f010539d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01053a1:	89 d3                	mov    %edx,%ebx
f01053a3:	c1 e3 08             	shl    $0x8,%ebx
f01053a6:	89 d6                	mov    %edx,%esi
f01053a8:	c1 e6 18             	shl    $0x18,%esi
f01053ab:	89 d0                	mov    %edx,%eax
f01053ad:	c1 e0 10             	shl    $0x10,%eax
f01053b0:	09 f0                	or     %esi,%eax
f01053b2:	09 c2                	or     %eax,%edx
f01053b4:	89 d0                	mov    %edx,%eax
f01053b6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
f01053b8:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
f01053bb:	fc                   	cld    
f01053bc:	f3 ab                	rep stos %eax,%es:(%edi)
f01053be:	eb 06                	jmp    f01053c6 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01053c0:	8b 45 0c             	mov    0xc(%ebp),%eax
f01053c3:	fc                   	cld    
f01053c4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01053c6:	89 f8                	mov    %edi,%eax
f01053c8:	5b                   	pop    %ebx
f01053c9:	5e                   	pop    %esi
f01053ca:	5f                   	pop    %edi
f01053cb:	5d                   	pop    %ebp
f01053cc:	c3                   	ret    

f01053cd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01053cd:	55                   	push   %ebp
f01053ce:	89 e5                	mov    %esp,%ebp
f01053d0:	57                   	push   %edi
f01053d1:	56                   	push   %esi
f01053d2:	8b 45 08             	mov    0x8(%ebp),%eax
f01053d5:	8b 75 0c             	mov    0xc(%ebp),%esi
f01053d8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f01053db:	39 c6                	cmp    %eax,%esi
f01053dd:	73 35                	jae    f0105414 <memmove+0x47>
f01053df:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f01053e2:	39 d0                	cmp    %edx,%eax
f01053e4:	73 2e                	jae    f0105414 <memmove+0x47>
		s += n;
		d += n;
f01053e6:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
f01053e9:	89 d6                	mov    %edx,%esi
f01053eb:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f01053ed:	f7 c6 03 00 00 00    	test   $0x3,%esi
f01053f3:	75 13                	jne    f0105408 <memmove+0x3b>
f01053f5:	f6 c1 03             	test   $0x3,%cl
f01053f8:	75 0e                	jne    f0105408 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
f01053fa:	83 ef 04             	sub    $0x4,%edi
f01053fd:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105400:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
f0105403:	fd                   	std    
f0105404:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f0105406:	eb 09                	jmp    f0105411 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
f0105408:	83 ef 01             	sub    $0x1,%edi
f010540b:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010540e:	fd                   	std    
f010540f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105411:	fc                   	cld    
f0105412:	eb 1d                	jmp    f0105431 <memmove+0x64>
f0105414:	89 f2                	mov    %esi,%edx
f0105416:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105418:	f6 c2 03             	test   $0x3,%dl
f010541b:	75 0f                	jne    f010542c <memmove+0x5f>
f010541d:	f6 c1 03             	test   $0x3,%cl
f0105420:	75 0a                	jne    f010542c <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
f0105422:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
f0105425:	89 c7                	mov    %eax,%edi
f0105427:	fc                   	cld    
f0105428:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
f010542a:	eb 05                	jmp    f0105431 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f010542c:	89 c7                	mov    %eax,%edi
f010542e:	fc                   	cld    
f010542f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105431:	5e                   	pop    %esi
f0105432:	5f                   	pop    %edi
f0105433:	5d                   	pop    %ebp
f0105434:	c3                   	ret    

f0105435 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105435:	55                   	push   %ebp
f0105436:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
f0105438:	ff 75 10             	pushl  0x10(%ebp)
f010543b:	ff 75 0c             	pushl  0xc(%ebp)
f010543e:	ff 75 08             	pushl  0x8(%ebp)
f0105441:	e8 87 ff ff ff       	call   f01053cd <memmove>
}
f0105446:	c9                   	leave  
f0105447:	c3                   	ret    

f0105448 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105448:	55                   	push   %ebp
f0105449:	89 e5                	mov    %esp,%ebp
f010544b:	56                   	push   %esi
f010544c:	53                   	push   %ebx
f010544d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105450:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105453:	89 c6                	mov    %eax,%esi
f0105455:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105458:	eb 1a                	jmp    f0105474 <memcmp+0x2c>
		if (*s1 != *s2)
f010545a:	0f b6 08             	movzbl (%eax),%ecx
f010545d:	0f b6 1a             	movzbl (%edx),%ebx
f0105460:	38 d9                	cmp    %bl,%cl
f0105462:	74 0a                	je     f010546e <memcmp+0x26>
			return (int) *s1 - (int) *s2;
f0105464:	0f b6 c1             	movzbl %cl,%eax
f0105467:	0f b6 db             	movzbl %bl,%ebx
f010546a:	29 d8                	sub    %ebx,%eax
f010546c:	eb 0f                	jmp    f010547d <memcmp+0x35>
		s1++, s2++;
f010546e:	83 c0 01             	add    $0x1,%eax
f0105471:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105474:	39 f0                	cmp    %esi,%eax
f0105476:	75 e2                	jne    f010545a <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0105478:	b8 00 00 00 00       	mov    $0x0,%eax
}
f010547d:	5b                   	pop    %ebx
f010547e:	5e                   	pop    %esi
f010547f:	5d                   	pop    %ebp
f0105480:	c3                   	ret    

f0105481 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f0105481:	55                   	push   %ebp
f0105482:	89 e5                	mov    %esp,%ebp
f0105484:	8b 45 08             	mov    0x8(%ebp),%eax
f0105487:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
f010548a:	89 c2                	mov    %eax,%edx
f010548c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f010548f:	eb 07                	jmp    f0105498 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
f0105491:	38 08                	cmp    %cl,(%eax)
f0105493:	74 07                	je     f010549c <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f0105495:	83 c0 01             	add    $0x1,%eax
f0105498:	39 d0                	cmp    %edx,%eax
f010549a:	72 f5                	jb     f0105491 <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f010549c:	5d                   	pop    %ebp
f010549d:	c3                   	ret    

f010549e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f010549e:	55                   	push   %ebp
f010549f:	89 e5                	mov    %esp,%ebp
f01054a1:	57                   	push   %edi
f01054a2:	56                   	push   %esi
f01054a3:	53                   	push   %ebx
f01054a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01054a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01054aa:	eb 03                	jmp    f01054af <strtol+0x11>
		s++;
f01054ac:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f01054af:	0f b6 01             	movzbl (%ecx),%eax
f01054b2:	3c 09                	cmp    $0x9,%al
f01054b4:	74 f6                	je     f01054ac <strtol+0xe>
f01054b6:	3c 20                	cmp    $0x20,%al
f01054b8:	74 f2                	je     f01054ac <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
f01054ba:	3c 2b                	cmp    $0x2b,%al
f01054bc:	75 0a                	jne    f01054c8 <strtol+0x2a>
		s++;
f01054be:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f01054c1:	bf 00 00 00 00       	mov    $0x0,%edi
f01054c6:	eb 10                	jmp    f01054d8 <strtol+0x3a>
f01054c8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
f01054cd:	3c 2d                	cmp    $0x2d,%al
f01054cf:	75 07                	jne    f01054d8 <strtol+0x3a>
		s++, neg = 1;
f01054d1:	8d 49 01             	lea    0x1(%ecx),%ecx
f01054d4:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01054d8:	85 db                	test   %ebx,%ebx
f01054da:	0f 94 c0             	sete   %al
f01054dd:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
f01054e3:	75 19                	jne    f01054fe <strtol+0x60>
f01054e5:	80 39 30             	cmpb   $0x30,(%ecx)
f01054e8:	75 14                	jne    f01054fe <strtol+0x60>
f01054ea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
f01054ee:	0f 85 8a 00 00 00    	jne    f010557e <strtol+0xe0>
		s += 2, base = 16;
f01054f4:	83 c1 02             	add    $0x2,%ecx
f01054f7:	bb 10 00 00 00       	mov    $0x10,%ebx
f01054fc:	eb 16                	jmp    f0105514 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
f01054fe:	84 c0                	test   %al,%al
f0105500:	74 12                	je     f0105514 <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
f0105502:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105507:	80 39 30             	cmpb   $0x30,(%ecx)
f010550a:	75 08                	jne    f0105514 <strtol+0x76>
		s++, base = 8;
f010550c:	83 c1 01             	add    $0x1,%ecx
f010550f:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
f0105514:	b8 00 00 00 00       	mov    $0x0,%eax
f0105519:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f010551c:	0f b6 11             	movzbl (%ecx),%edx
f010551f:	8d 72 d0             	lea    -0x30(%edx),%esi
f0105522:	89 f3                	mov    %esi,%ebx
f0105524:	80 fb 09             	cmp    $0x9,%bl
f0105527:	77 08                	ja     f0105531 <strtol+0x93>
			dig = *s - '0';
f0105529:	0f be d2             	movsbl %dl,%edx
f010552c:	83 ea 30             	sub    $0x30,%edx
f010552f:	eb 22                	jmp    f0105553 <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
f0105531:	8d 72 9f             	lea    -0x61(%edx),%esi
f0105534:	89 f3                	mov    %esi,%ebx
f0105536:	80 fb 19             	cmp    $0x19,%bl
f0105539:	77 08                	ja     f0105543 <strtol+0xa5>
			dig = *s - 'a' + 10;
f010553b:	0f be d2             	movsbl %dl,%edx
f010553e:	83 ea 57             	sub    $0x57,%edx
f0105541:	eb 10                	jmp    f0105553 <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
f0105543:	8d 72 bf             	lea    -0x41(%edx),%esi
f0105546:	89 f3                	mov    %esi,%ebx
f0105548:	80 fb 19             	cmp    $0x19,%bl
f010554b:	77 16                	ja     f0105563 <strtol+0xc5>
			dig = *s - 'A' + 10;
f010554d:	0f be d2             	movsbl %dl,%edx
f0105550:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
f0105553:	3b 55 10             	cmp    0x10(%ebp),%edx
f0105556:	7d 0f                	jge    f0105567 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
f0105558:	83 c1 01             	add    $0x1,%ecx
f010555b:	0f af 45 10          	imul   0x10(%ebp),%eax
f010555f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
f0105561:	eb b9                	jmp    f010551c <strtol+0x7e>
f0105563:	89 c2                	mov    %eax,%edx
f0105565:	eb 02                	jmp    f0105569 <strtol+0xcb>
f0105567:	89 c2                	mov    %eax,%edx

	if (endptr)
f0105569:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f010556d:	74 05                	je     f0105574 <strtol+0xd6>
		*endptr = (char *) s;
f010556f:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105572:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
f0105574:	85 ff                	test   %edi,%edi
f0105576:	74 0c                	je     f0105584 <strtol+0xe6>
f0105578:	89 d0                	mov    %edx,%eax
f010557a:	f7 d8                	neg    %eax
f010557c:	eb 06                	jmp    f0105584 <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010557e:	84 c0                	test   %al,%al
f0105580:	75 8a                	jne    f010550c <strtol+0x6e>
f0105582:	eb 90                	jmp    f0105514 <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
f0105584:	5b                   	pop    %ebx
f0105585:	5e                   	pop    %esi
f0105586:	5f                   	pop    %edi
f0105587:	5d                   	pop    %ebp
f0105588:	c3                   	ret    

f0105589 <tsc_calibrate>:
	delta /= i*256*1000;
	return delta;
}

void tsc_calibrate(void)
{
f0105589:	55                   	push   %ebp
f010558a:	89 e5                	mov    %esp,%ebp
f010558c:	57                   	push   %edi
f010558d:	56                   	push   %esi
f010558e:	53                   	push   %ebx
f010558f:	83 ec 3c             	sub    $0x3c,%esp
    int i;
    for (i = 0; i < TIMES; i++) {
f0105592:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105599:	ba 61 00 00 00       	mov    $0x61,%edx
f010559e:	ec                   	in     (%dx),%al
	int i;
	uint64_t tsc, delta;
	unsigned long d1, d2;

	/* Set the Gate high, disable speaker */
	outb(0x61, (inb(0x61) & ~0x02) | 0x01);
f010559f:	83 e0 fc             	and    $0xfffffffc,%eax
f01055a2:	83 c8 01             	or     $0x1,%eax
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01055a5:	ee                   	out    %al,(%dx)
f01055a6:	b2 43                	mov    $0x43,%dl
f01055a8:	b8 b0 ff ff ff       	mov    $0xffffffb0,%eax
f01055ad:	ee                   	out    %al,(%dx)
f01055ae:	b9 42 00 00 00       	mov    $0x42,%ecx
f01055b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01055b8:	89 ca                	mov    %ecx,%edx
f01055ba:	ee                   	out    %al,(%dx)
f01055bb:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01055bc:	ec                   	in     (%dx),%al
f01055bd:	ec                   	in     (%dx),%al
}

static inline int pit_expect_msb(unsigned char val, uint64_t *tscp, unsigned long *deltap)
{
	int count;
	uint64_t tsc = 0;
f01055be:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
f01055c5:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)

	for (count = 0; count < 50000; count++) {
f01055cc:	b1 00                	mov    $0x0,%cl
f01055ce:	bb 42 00 00 00       	mov    $0x42,%ebx
f01055d3:	89 da                	mov    %ebx,%edx
f01055d5:	ec                   	in     (%dx),%al
f01055d6:	ec                   	in     (%dx),%al
		if (!pit_verify_msb(val))
f01055d7:	3c ff                	cmp    $0xff,%al
f01055d9:	75 13                	jne    f01055ee <tsc_calibrate+0x65>

static __inline uint64_t
read_tsc(void)
{
	uint64_t tsc;
	__asm __volatile("rdtsc" : "=A" (tsc));
f01055db:	0f 31                	rdtsc  
f01055dd:	89 45 d8             	mov    %eax,-0x28(%ebp)
f01055e0:	89 55 dc             	mov    %edx,-0x24(%ebp)
static inline int pit_expect_msb(unsigned char val, uint64_t *tscp, unsigned long *deltap)
{
	int count;
	uint64_t tsc = 0;

	for (count = 0; count < 50000; count++) {
f01055e3:	83 c1 01             	add    $0x1,%ecx
f01055e6:	81 f9 50 c3 00 00    	cmp    $0xc350,%ecx
f01055ec:	75 e5                	jne    f01055d3 <tsc_calibrate+0x4a>
f01055ee:	0f 31                	rdtsc  
	 * need to delay for a microsecond. The easiest way
	 * to do that is to just read back the 16-bit counter
	 * once from the PIT.
	 */
	pit_verify_msb(0);
	if (pit_expect_msb(0xff, &tsc, &d1)) {
f01055f0:	83 f9 05             	cmp    $0x5,%ecx
f01055f3:	0f 8e 08 01 00 00    	jle    f0105701 <tsc_calibrate+0x178>
	for (count = 0; count < 50000; count++) {
		if (!pit_verify_msb(val))
			break;
		tsc = read_tsc();
	}
	*deltap = read_tsc() - tsc;
f01055f9:	2b 45 d8             	sub    -0x28(%ebp),%eax
f01055fc:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01055ff:	bf 01 00 00 00       	mov    $0x1,%edi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105604:	b9 42 00 00 00       	mov    $0x42,%ecx
	 * once from the PIT.
	 */
	pit_verify_msb(0);
	if (pit_expect_msb(0xff, &tsc, &d1)) {
		for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
			if (!pit_expect_msb(0xff-i, &delta, &d2))
f0105609:	89 f8                	mov    %edi,%eax
f010560b:	88 45 c7             	mov    %al,-0x39(%ebp)
f010560e:	89 fe                	mov    %edi,%esi
f0105610:	f7 d6                	not    %esi
}

static inline int pit_expect_msb(unsigned char val, uint64_t *tscp, unsigned long *deltap)
{
	int count;
	uint64_t tsc = 0;
f0105612:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0105619:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

	for (count = 0; count < 50000; count++) {
f0105620:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105625:	89 ca                	mov    %ecx,%edx
f0105627:	ec                   	in     (%dx),%al
f0105628:	ec                   	in     (%dx),%al
		if (!pit_verify_msb(val))
f0105629:	89 f2                	mov    %esi,%edx
f010562b:	38 c2                	cmp    %al,%dl
f010562d:	75 13                	jne    f0105642 <tsc_calibrate+0xb9>

static __inline uint64_t
read_tsc(void)
{
	uint64_t tsc;
	__asm __volatile("rdtsc" : "=A" (tsc));
f010562f:	0f 31                	rdtsc  
f0105631:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105634:	89 55 e4             	mov    %edx,-0x1c(%ebp)
static inline int pit_expect_msb(unsigned char val, uint64_t *tscp, unsigned long *deltap)
{
	int count;
	uint64_t tsc = 0;

	for (count = 0; count < 50000; count++) {
f0105637:	83 c3 01             	add    $0x1,%ebx
f010563a:	81 fb 50 c3 00 00    	cmp    $0xc350,%ebx
f0105640:	75 e3                	jne    f0105625 <tsc_calibrate+0x9c>
f0105642:	0f 31                	rdtsc  
		if (!pit_verify_msb(val))
			break;
		tsc = read_tsc();
	}
	*deltap = read_tsc() - tsc;
f0105644:	89 c6                	mov    %eax,%esi
f0105646:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0105649:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f010564c:	29 c6                	sub    %eax,%esi
f010564e:	89 75 e0             	mov    %esi,-0x20(%ebp)
	 * once from the PIT.
	 */
	pit_verify_msb(0);
	if (pit_expect_msb(0xff, &tsc, &d1)) {
		for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
			if (!pit_expect_msb(0xff-i, &delta, &d2))
f0105651:	83 fb 05             	cmp    $0x5,%ebx
f0105654:	0f 8e a7 00 00 00    	jle    f0105701 <tsc_calibrate+0x178>
				break;

			/*
			 * Iterate until the error is less than 500 ppm
			 */
			delta -= tsc;
f010565a:	2b 45 d8             	sub    -0x28(%ebp),%eax
f010565d:	1b 55 dc             	sbb    -0x24(%ebp),%edx
			if (d1+d2 >= delta >> 11)
f0105660:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0105663:	03 75 e0             	add    -0x20(%ebp),%esi
f0105666:	89 75 c0             	mov    %esi,-0x40(%ebp)
f0105669:	89 75 c8             	mov    %esi,-0x38(%ebp)
f010566c:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
f0105673:	89 c3                	mov    %eax,%ebx
f0105675:	89 d6                	mov    %edx,%esi
f0105677:	0f ac d3 0b          	shrd   $0xb,%edx,%ebx
f010567b:	c1 ee 0b             	shr    $0xb,%esi
f010567e:	89 5d b8             	mov    %ebx,-0x48(%ebp)
f0105681:	89 75 bc             	mov    %esi,-0x44(%ebp)
f0105684:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0105687:	72 16                	jb     f010569f <tsc_calibrate+0x116>
f0105689:	8b 5d b8             	mov    -0x48(%ebp),%ebx
f010568c:	39 5d c0             	cmp    %ebx,-0x40(%ebp)
f010568f:	72 0e                	jb     f010569f <tsc_calibrate+0x116>
	 * to do that is to just read back the 16-bit counter
	 * once from the PIT.
	 */
	pit_verify_msb(0);
	if (pit_expect_msb(0xff, &tsc, &d1)) {
		for (i = 1; i <= MAX_QUICK_PIT_ITERATIONS; i++) {
f0105691:	83 c7 01             	add    $0x1,%edi
f0105694:	83 ff 75             	cmp    $0x75,%edi
f0105697:	0f 85 6c ff ff ff    	jne    f0105609 <tsc_calibrate+0x80>
f010569d:	eb 62                	jmp    f0105701 <tsc_calibrate+0x178>
f010569f:	89 c3                	mov    %eax,%ebx
f01056a1:	89 d6                	mov    %edx,%esi

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01056a3:	ba 42 00 00 00       	mov    $0x42,%edx
f01056a8:	ec                   	in     (%dx),%al
f01056a9:	ec                   	in     (%dx),%al
			 * all TSC reads were stable wrt the PIT.
			 *
			 * This also guarantees serialization of the
			 * last cycle read ('d2') in pit_expect_msb.
			 */
			if (!pit_verify_msb(0xfe - i))
f01056aa:	ba fe ff ff ff       	mov    $0xfffffffe,%edx
f01056af:	2a 55 c7             	sub    -0x39(%ebp),%dl
f01056b2:	38 c2                	cmp    %al,%dl
f01056b4:	75 4b                	jne    f0105701 <tsc_calibrate+0x178>
	 *
	 * kHz = ticks / time-in-seconds / 1000;
	 * kHz = (t2 - t1) / (I * 256 / PIT_TICK_RATE) / 1000
	 * kHz = ((t2 - t1) * PIT_TICK_RATE) / (I * 256 * 1000)
	 */
	delta += (long)(d2 - d1)/2;
f01056b6:	8b 45 e0             	mov    -0x20(%ebp),%eax
f01056b9:	2b 45 d0             	sub    -0x30(%ebp),%eax
f01056bc:	89 c2                	mov    %eax,%edx
f01056be:	c1 ea 1f             	shr    $0x1f,%edx
f01056c1:	01 d0                	add    %edx,%eax
f01056c3:	d1 f8                	sar    %eax
f01056c5:	99                   	cltd   
f01056c6:	01 d8                	add    %ebx,%eax
f01056c8:	11 f2                	adc    %esi,%edx

	delta *= PIT_TICK_RATE;
f01056ca:	69 ca de 34 12 00    	imul   $0x1234de,%edx,%ecx
f01056d0:	ba de 34 12 00       	mov    $0x1234de,%edx
f01056d5:	f7 e2                	mul    %edx
f01056d7:	01 ca                	add    %ecx,%edx
	delta /= i*256*1000;
f01056d9:	69 cf 00 e8 03 00    	imul   $0x3e800,%edi,%ecx
f01056df:	89 cb                	mov    %ecx,%ebx
f01056e1:	c1 fb 1f             	sar    $0x1f,%ebx
f01056e4:	53                   	push   %ebx
f01056e5:	51                   	push   %ecx
f01056e6:	52                   	push   %edx
f01056e7:	50                   	push   %eax
f01056e8:	e8 63 01 00 00       	call   f0105850 <__udivdi3>
f01056ed:	83 c4 10             	add    $0x10,%esp

void tsc_calibrate(void)
{
    int i;
    for (i = 0; i < TIMES; i++) {
        if ((cpu_freq = quick_pit_calibrate()))
f01056f0:	85 c0                	test   %eax,%eax
f01056f2:	74 0d                	je     f0105701 <tsc_calibrate+0x178>
f01056f4:	a3 28 e1 39 f0       	mov    %eax,0xf039e128
            break;
    }
    if (i == TIMES) {
f01056f9:	83 7d d4 64          	cmpl   $0x64,-0x2c(%ebp)
f01056fd:	75 2c                	jne    f010572b <tsc_calibrate+0x1a2>
f01056ff:	eb 10                	jmp    f0105711 <tsc_calibrate+0x188>
}

void tsc_calibrate(void)
{
    int i;
    for (i = 0; i < TIMES; i++) {
f0105701:	83 45 d4 01          	addl   $0x1,-0x2c(%ebp)
f0105705:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0105708:	83 f8 64             	cmp    $0x64,%eax
f010570b:	0f 85 88 fe ff ff    	jne    f0105599 <tsc_calibrate+0x10>
        if ((cpu_freq = quick_pit_calibrate()))
            break;
    }
    if (i == TIMES) {
        cpu_freq = DEFAULT_FREQ;
f0105711:	c7 05 28 e1 39 f0 a0 	movl   $0x2625a0,0xf039e128
f0105718:	25 26 00 
        cprintf("Can't calibrate pit timer. Using default frequency\n");
f010571b:	83 ec 0c             	sub    $0xc,%esp
f010571e:	68 30 75 10 f0       	push   $0xf0107530
f0105723:	e8 1e e0 ff ff       	call   f0103746 <cprintf>
f0105728:	83 c4 10             	add    $0x10,%esp
    }

    cprintf("Detected %lu.%03lu MHz processor.\n",
f010572b:	8b 0d 28 e1 39 f0    	mov    0xf039e128,%ecx
f0105731:	83 ec 04             	sub    $0x4,%esp
f0105734:	ba d3 4d 62 10       	mov    $0x10624dd3,%edx
f0105739:	89 c8                	mov    %ecx,%eax
f010573b:	f7 e2                	mul    %edx
f010573d:	c1 ea 06             	shr    $0x6,%edx
f0105740:	69 c2 e8 03 00 00    	imul   $0x3e8,%edx,%eax
f0105746:	29 c1                	sub    %eax,%ecx
f0105748:	51                   	push   %ecx
f0105749:	52                   	push   %edx
f010574a:	68 64 75 10 f0       	push   $0xf0107564
f010574f:	e8 f2 df ff ff       	call   f0103746 <cprintf>
f0105754:	83 c4 10             	add    $0x10,%esp
		(unsigned long)cpu_freq / 1000,
		(unsigned long)cpu_freq % 1000);
}
f0105757:	8d 65 f4             	lea    -0xc(%ebp),%esp
f010575a:	5b                   	pop    %ebx
f010575b:	5e                   	pop    %esi
f010575c:	5f                   	pop    %edi
f010575d:	5d                   	pop    %ebp
f010575e:	c3                   	ret    

f010575f <print_time>:

void print_time(unsigned seconds)
{
f010575f:	55                   	push   %ebp
f0105760:	89 e5                	mov    %esp,%ebp
f0105762:	83 ec 10             	sub    $0x10,%esp
	cprintf("%d\n", seconds);
f0105765:	ff 75 08             	pushl  0x8(%ebp)
f0105768:	68 5e 5e 10 f0       	push   $0xf0105e5e
f010576d:	e8 d4 df ff ff       	call   f0103746 <cprintf>
f0105772:	83 c4 10             	add    $0x10,%esp
}
f0105775:	c9                   	leave  
f0105776:	c3                   	ret    

f0105777 <print_timer_error>:

void print_timer_error(void)
{
f0105777:	55                   	push   %ebp
f0105778:	89 e5                	mov    %esp,%ebp
f010577a:	83 ec 14             	sub    $0x14,%esp
	cprintf("Timer Error\n");
f010577d:	68 88 75 10 f0       	push   $0xf0107588
f0105782:	e8 bf df ff ff       	call   f0103746 <cprintf>
f0105787:	83 c4 10             	add    $0x10,%esp
}
f010578a:	c9                   	leave  
f010578b:	c3                   	ret    

f010578c <timer_start>:

bool timer_flag = 0;
uint64_t tsc = 0;

void timer_start(void)
{
f010578c:	55                   	push   %ebp
f010578d:	89 e5                	mov    %esp,%ebp

static __inline uint64_t
read_tsc(void)
{
	uint64_t tsc;
	__asm __volatile("rdtsc" : "=A" (tsc));
f010578f:	0f 31                	rdtsc  
	tsc = read_tsc();
f0105791:	a3 80 e0 39 f0       	mov    %eax,0xf039e080
f0105796:	89 15 84 e0 39 f0    	mov    %edx,0xf039e084
	timer_flag = 1;
f010579c:	c6 05 88 e0 39 f0 01 	movb   $0x1,0xf039e088
}
f01057a3:	5d                   	pop    %ebp
f01057a4:	c3                   	ret    

f01057a5 <timer_stop>:

void timer_stop(void)
{
f01057a5:	55                   	push   %ebp
f01057a6:	89 e5                	mov    %esp,%ebp
f01057a8:	57                   	push   %edi
f01057a9:	56                   	push   %esi
	if (timer_flag) {
f01057aa:	80 3d 88 e0 39 f0 00 	cmpb   $0x0,0xf039e088
f01057b1:	74 4b                	je     f01057fe <timer_stop+0x59>
f01057b3:	0f 31                	rdtsc  
		uint64_t cur_tsc = read_tsc() - tsc;
		print_time(cur_tsc / cpu_freq / 1000);
f01057b5:	83 ec 10             	sub    $0x10,%esp
}

void timer_stop(void)
{
	if (timer_flag) {
		uint64_t cur_tsc = read_tsc() - tsc;
f01057b8:	2b 05 80 e0 39 f0    	sub    0xf039e080,%eax
f01057be:	1b 15 84 e0 39 f0    	sbb    0xf039e084,%edx
		print_time(cur_tsc / cpu_freq / 1000);
f01057c4:	8b 35 28 e1 39 f0    	mov    0xf039e128,%esi
f01057ca:	bf 00 00 00 00       	mov    $0x0,%edi
f01057cf:	57                   	push   %edi
f01057d0:	56                   	push   %esi
f01057d1:	52                   	push   %edx
f01057d2:	50                   	push   %eax
f01057d3:	e8 78 00 00 00       	call   f0105850 <__udivdi3>
f01057d8:	83 c4 10             	add    $0x10,%esp
f01057db:	6a 00                	push   $0x0
f01057dd:	68 e8 03 00 00       	push   $0x3e8
f01057e2:	52                   	push   %edx
f01057e3:	50                   	push   %eax
f01057e4:	e8 67 00 00 00       	call   f0105850 <__udivdi3>
f01057e9:	83 c4 14             	add    $0x14,%esp
f01057ec:	50                   	push   %eax
f01057ed:	e8 6d ff ff ff       	call   f010575f <print_time>
		timer_flag = 0;
f01057f2:	c6 05 88 e0 39 f0 00 	movb   $0x0,0xf039e088
f01057f9:	83 c4 10             	add    $0x10,%esp
f01057fc:	eb 05                	jmp    f0105803 <timer_stop+0x5e>
	} else {
		print_timer_error();
f01057fe:	e8 74 ff ff ff       	call   f0105777 <print_timer_error>
	}
f0105803:	8d 65 f8             	lea    -0x8(%ebp),%esp
f0105806:	5e                   	pop    %esi
f0105807:	5f                   	pop    %edi
f0105808:	5d                   	pop    %ebp
f0105809:	c3                   	ret    

f010580a <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f010580a:	55                   	push   %ebp
f010580b:	89 e5                	mov    %esp,%ebp
	lk->locked = 0;
f010580d:	8b 45 08             	mov    0x8(%ebp),%eax
f0105810:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
#endif
}
f0105816:	5d                   	pop    %ebp
f0105817:	c3                   	ret    

f0105818 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0105818:	55                   	push   %ebp
f0105819:	89 e5                	mov    %esp,%ebp
f010581b:	8b 55 08             	mov    0x8(%ebp),%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010581e:	b9 01 00 00 00       	mov    $0x1,%ecx
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it.
	while (xchg(&lk->locked, 1) != 0)
f0105823:	eb 02                	jmp    f0105827 <spin_lock+0xf>
		asm volatile ("pause");
f0105825:	f3 90                	pause  
f0105827:	89 c8                	mov    %ecx,%eax
f0105829:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it.
	while (xchg(&lk->locked, 1) != 0)
f010582c:	85 c0                	test   %eax,%eax
f010582e:	75 f5                	jne    f0105825 <spin_lock+0xd>

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	get_caller_pcs(lk->pcs);
#endif
}
f0105830:	5d                   	pop    %ebp
f0105831:	c3                   	ret    

f0105832 <spin_unlock>:

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f0105832:	55                   	push   %ebp
f0105833:	89 e5                	mov    %esp,%ebp
f0105835:	8b 55 08             	mov    0x8(%ebp),%edx
f0105838:	b8 00 00 00 00       	mov    $0x0,%eax
f010583d:	f0 87 02             	lock xchg %eax,(%edx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f0105840:	5d                   	pop    %ebp
f0105841:	c3                   	ret    
f0105842:	66 90                	xchg   %ax,%ax
f0105844:	66 90                	xchg   %ax,%ax
f0105846:	66 90                	xchg   %ax,%ax
f0105848:	66 90                	xchg   %ax,%ax
f010584a:	66 90                	xchg   %ax,%ax
f010584c:	66 90                	xchg   %ax,%ax
f010584e:	66 90                	xchg   %ax,%ax

f0105850 <__udivdi3>:
f0105850:	55                   	push   %ebp
f0105851:	57                   	push   %edi
f0105852:	56                   	push   %esi
f0105853:	83 ec 10             	sub    $0x10,%esp
f0105856:	8b 54 24 2c          	mov    0x2c(%esp),%edx
f010585a:	8b 7c 24 20          	mov    0x20(%esp),%edi
f010585e:	8b 74 24 24          	mov    0x24(%esp),%esi
f0105862:	8b 4c 24 28          	mov    0x28(%esp),%ecx
f0105866:	85 d2                	test   %edx,%edx
f0105868:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010586c:	89 34 24             	mov    %esi,(%esp)
f010586f:	89 c8                	mov    %ecx,%eax
f0105871:	75 35                	jne    f01058a8 <__udivdi3+0x58>
f0105873:	39 f1                	cmp    %esi,%ecx
f0105875:	0f 87 bd 00 00 00    	ja     f0105938 <__udivdi3+0xe8>
f010587b:	85 c9                	test   %ecx,%ecx
f010587d:	89 cd                	mov    %ecx,%ebp
f010587f:	75 0b                	jne    f010588c <__udivdi3+0x3c>
f0105881:	b8 01 00 00 00       	mov    $0x1,%eax
f0105886:	31 d2                	xor    %edx,%edx
f0105888:	f7 f1                	div    %ecx
f010588a:	89 c5                	mov    %eax,%ebp
f010588c:	89 f0                	mov    %esi,%eax
f010588e:	31 d2                	xor    %edx,%edx
f0105890:	f7 f5                	div    %ebp
f0105892:	89 c6                	mov    %eax,%esi
f0105894:	89 f8                	mov    %edi,%eax
f0105896:	f7 f5                	div    %ebp
f0105898:	89 f2                	mov    %esi,%edx
f010589a:	83 c4 10             	add    $0x10,%esp
f010589d:	5e                   	pop    %esi
f010589e:	5f                   	pop    %edi
f010589f:	5d                   	pop    %ebp
f01058a0:	c3                   	ret    
f01058a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f01058a8:	3b 14 24             	cmp    (%esp),%edx
f01058ab:	77 7b                	ja     f0105928 <__udivdi3+0xd8>
f01058ad:	0f bd f2             	bsr    %edx,%esi
f01058b0:	83 f6 1f             	xor    $0x1f,%esi
f01058b3:	0f 84 97 00 00 00    	je     f0105950 <__udivdi3+0x100>
f01058b9:	bd 20 00 00 00       	mov    $0x20,%ebp
f01058be:	89 d7                	mov    %edx,%edi
f01058c0:	89 f1                	mov    %esi,%ecx
f01058c2:	29 f5                	sub    %esi,%ebp
f01058c4:	d3 e7                	shl    %cl,%edi
f01058c6:	89 c2                	mov    %eax,%edx
f01058c8:	89 e9                	mov    %ebp,%ecx
f01058ca:	d3 ea                	shr    %cl,%edx
f01058cc:	89 f1                	mov    %esi,%ecx
f01058ce:	09 fa                	or     %edi,%edx
f01058d0:	8b 3c 24             	mov    (%esp),%edi
f01058d3:	d3 e0                	shl    %cl,%eax
f01058d5:	89 54 24 08          	mov    %edx,0x8(%esp)
f01058d9:	89 e9                	mov    %ebp,%ecx
f01058db:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01058df:	8b 44 24 04          	mov    0x4(%esp),%eax
f01058e3:	89 fa                	mov    %edi,%edx
f01058e5:	d3 ea                	shr    %cl,%edx
f01058e7:	89 f1                	mov    %esi,%ecx
f01058e9:	d3 e7                	shl    %cl,%edi
f01058eb:	89 e9                	mov    %ebp,%ecx
f01058ed:	d3 e8                	shr    %cl,%eax
f01058ef:	09 c7                	or     %eax,%edi
f01058f1:	89 f8                	mov    %edi,%eax
f01058f3:	f7 74 24 08          	divl   0x8(%esp)
f01058f7:	89 d5                	mov    %edx,%ebp
f01058f9:	89 c7                	mov    %eax,%edi
f01058fb:	f7 64 24 0c          	mull   0xc(%esp)
f01058ff:	39 d5                	cmp    %edx,%ebp
f0105901:	89 14 24             	mov    %edx,(%esp)
f0105904:	72 11                	jb     f0105917 <__udivdi3+0xc7>
f0105906:	8b 54 24 04          	mov    0x4(%esp),%edx
f010590a:	89 f1                	mov    %esi,%ecx
f010590c:	d3 e2                	shl    %cl,%edx
f010590e:	39 c2                	cmp    %eax,%edx
f0105910:	73 5e                	jae    f0105970 <__udivdi3+0x120>
f0105912:	3b 2c 24             	cmp    (%esp),%ebp
f0105915:	75 59                	jne    f0105970 <__udivdi3+0x120>
f0105917:	8d 47 ff             	lea    -0x1(%edi),%eax
f010591a:	31 f6                	xor    %esi,%esi
f010591c:	89 f2                	mov    %esi,%edx
f010591e:	83 c4 10             	add    $0x10,%esp
f0105921:	5e                   	pop    %esi
f0105922:	5f                   	pop    %edi
f0105923:	5d                   	pop    %ebp
f0105924:	c3                   	ret    
f0105925:	8d 76 00             	lea    0x0(%esi),%esi
f0105928:	31 f6                	xor    %esi,%esi
f010592a:	31 c0                	xor    %eax,%eax
f010592c:	89 f2                	mov    %esi,%edx
f010592e:	83 c4 10             	add    $0x10,%esp
f0105931:	5e                   	pop    %esi
f0105932:	5f                   	pop    %edi
f0105933:	5d                   	pop    %ebp
f0105934:	c3                   	ret    
f0105935:	8d 76 00             	lea    0x0(%esi),%esi
f0105938:	89 f2                	mov    %esi,%edx
f010593a:	31 f6                	xor    %esi,%esi
f010593c:	89 f8                	mov    %edi,%eax
f010593e:	f7 f1                	div    %ecx
f0105940:	89 f2                	mov    %esi,%edx
f0105942:	83 c4 10             	add    $0x10,%esp
f0105945:	5e                   	pop    %esi
f0105946:	5f                   	pop    %edi
f0105947:	5d                   	pop    %ebp
f0105948:	c3                   	ret    
f0105949:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0105950:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
f0105954:	76 0b                	jbe    f0105961 <__udivdi3+0x111>
f0105956:	31 c0                	xor    %eax,%eax
f0105958:	3b 14 24             	cmp    (%esp),%edx
f010595b:	0f 83 37 ff ff ff    	jae    f0105898 <__udivdi3+0x48>
f0105961:	b8 01 00 00 00       	mov    $0x1,%eax
f0105966:	e9 2d ff ff ff       	jmp    f0105898 <__udivdi3+0x48>
f010596b:	90                   	nop
f010596c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105970:	89 f8                	mov    %edi,%eax
f0105972:	31 f6                	xor    %esi,%esi
f0105974:	e9 1f ff ff ff       	jmp    f0105898 <__udivdi3+0x48>
f0105979:	66 90                	xchg   %ax,%ax
f010597b:	66 90                	xchg   %ax,%ax
f010597d:	66 90                	xchg   %ax,%ax
f010597f:	90                   	nop

f0105980 <__umoddi3>:
f0105980:	55                   	push   %ebp
f0105981:	57                   	push   %edi
f0105982:	56                   	push   %esi
f0105983:	83 ec 20             	sub    $0x20,%esp
f0105986:	8b 44 24 34          	mov    0x34(%esp),%eax
f010598a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
f010598e:	8b 7c 24 38          	mov    0x38(%esp),%edi
f0105992:	89 c6                	mov    %eax,%esi
f0105994:	89 44 24 10          	mov    %eax,0x10(%esp)
f0105998:	8b 44 24 3c          	mov    0x3c(%esp),%eax
f010599c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
f01059a0:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f01059a4:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f01059a8:	89 74 24 18          	mov    %esi,0x18(%esp)
f01059ac:	85 c0                	test   %eax,%eax
f01059ae:	89 c2                	mov    %eax,%edx
f01059b0:	75 1e                	jne    f01059d0 <__umoddi3+0x50>
f01059b2:	39 f7                	cmp    %esi,%edi
f01059b4:	76 52                	jbe    f0105a08 <__umoddi3+0x88>
f01059b6:	89 c8                	mov    %ecx,%eax
f01059b8:	89 f2                	mov    %esi,%edx
f01059ba:	f7 f7                	div    %edi
f01059bc:	89 d0                	mov    %edx,%eax
f01059be:	31 d2                	xor    %edx,%edx
f01059c0:	83 c4 20             	add    $0x20,%esp
f01059c3:	5e                   	pop    %esi
f01059c4:	5f                   	pop    %edi
f01059c5:	5d                   	pop    %ebp
f01059c6:	c3                   	ret    
f01059c7:	89 f6                	mov    %esi,%esi
f01059c9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f01059d0:	39 f0                	cmp    %esi,%eax
f01059d2:	77 5c                	ja     f0105a30 <__umoddi3+0xb0>
f01059d4:	0f bd e8             	bsr    %eax,%ebp
f01059d7:	83 f5 1f             	xor    $0x1f,%ebp
f01059da:	75 64                	jne    f0105a40 <__umoddi3+0xc0>
f01059dc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
f01059e0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
f01059e4:	0f 86 f6 00 00 00    	jbe    f0105ae0 <__umoddi3+0x160>
f01059ea:	3b 44 24 18          	cmp    0x18(%esp),%eax
f01059ee:	0f 82 ec 00 00 00    	jb     f0105ae0 <__umoddi3+0x160>
f01059f4:	8b 44 24 14          	mov    0x14(%esp),%eax
f01059f8:	8b 54 24 18          	mov    0x18(%esp),%edx
f01059fc:	83 c4 20             	add    $0x20,%esp
f01059ff:	5e                   	pop    %esi
f0105a00:	5f                   	pop    %edi
f0105a01:	5d                   	pop    %ebp
f0105a02:	c3                   	ret    
f0105a03:	90                   	nop
f0105a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105a08:	85 ff                	test   %edi,%edi
f0105a0a:	89 fd                	mov    %edi,%ebp
f0105a0c:	75 0b                	jne    f0105a19 <__umoddi3+0x99>
f0105a0e:	b8 01 00 00 00       	mov    $0x1,%eax
f0105a13:	31 d2                	xor    %edx,%edx
f0105a15:	f7 f7                	div    %edi
f0105a17:	89 c5                	mov    %eax,%ebp
f0105a19:	8b 44 24 10          	mov    0x10(%esp),%eax
f0105a1d:	31 d2                	xor    %edx,%edx
f0105a1f:	f7 f5                	div    %ebp
f0105a21:	89 c8                	mov    %ecx,%eax
f0105a23:	f7 f5                	div    %ebp
f0105a25:	eb 95                	jmp    f01059bc <__umoddi3+0x3c>
f0105a27:	89 f6                	mov    %esi,%esi
f0105a29:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
f0105a30:	89 c8                	mov    %ecx,%eax
f0105a32:	89 f2                	mov    %esi,%edx
f0105a34:	83 c4 20             	add    $0x20,%esp
f0105a37:	5e                   	pop    %esi
f0105a38:	5f                   	pop    %edi
f0105a39:	5d                   	pop    %ebp
f0105a3a:	c3                   	ret    
f0105a3b:	90                   	nop
f0105a3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105a40:	b8 20 00 00 00       	mov    $0x20,%eax
f0105a45:	89 e9                	mov    %ebp,%ecx
f0105a47:	29 e8                	sub    %ebp,%eax
f0105a49:	d3 e2                	shl    %cl,%edx
f0105a4b:	89 c7                	mov    %eax,%edi
f0105a4d:	89 44 24 18          	mov    %eax,0x18(%esp)
f0105a51:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0105a55:	89 f9                	mov    %edi,%ecx
f0105a57:	d3 e8                	shr    %cl,%eax
f0105a59:	89 c1                	mov    %eax,%ecx
f0105a5b:	8b 44 24 0c          	mov    0xc(%esp),%eax
f0105a5f:	09 d1                	or     %edx,%ecx
f0105a61:	89 fa                	mov    %edi,%edx
f0105a63:	89 4c 24 10          	mov    %ecx,0x10(%esp)
f0105a67:	89 e9                	mov    %ebp,%ecx
f0105a69:	d3 e0                	shl    %cl,%eax
f0105a6b:	89 f9                	mov    %edi,%ecx
f0105a6d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105a71:	89 f0                	mov    %esi,%eax
f0105a73:	d3 e8                	shr    %cl,%eax
f0105a75:	89 e9                	mov    %ebp,%ecx
f0105a77:	89 c7                	mov    %eax,%edi
f0105a79:	8b 44 24 1c          	mov    0x1c(%esp),%eax
f0105a7d:	d3 e6                	shl    %cl,%esi
f0105a7f:	89 d1                	mov    %edx,%ecx
f0105a81:	89 fa                	mov    %edi,%edx
f0105a83:	d3 e8                	shr    %cl,%eax
f0105a85:	89 e9                	mov    %ebp,%ecx
f0105a87:	09 f0                	or     %esi,%eax
f0105a89:	8b 74 24 1c          	mov    0x1c(%esp),%esi
f0105a8d:	f7 74 24 10          	divl   0x10(%esp)
f0105a91:	d3 e6                	shl    %cl,%esi
f0105a93:	89 d1                	mov    %edx,%ecx
f0105a95:	f7 64 24 0c          	mull   0xc(%esp)
f0105a99:	39 d1                	cmp    %edx,%ecx
f0105a9b:	89 74 24 14          	mov    %esi,0x14(%esp)
f0105a9f:	89 d7                	mov    %edx,%edi
f0105aa1:	89 c6                	mov    %eax,%esi
f0105aa3:	72 0a                	jb     f0105aaf <__umoddi3+0x12f>
f0105aa5:	39 44 24 14          	cmp    %eax,0x14(%esp)
f0105aa9:	73 10                	jae    f0105abb <__umoddi3+0x13b>
f0105aab:	39 d1                	cmp    %edx,%ecx
f0105aad:	75 0c                	jne    f0105abb <__umoddi3+0x13b>
f0105aaf:	89 d7                	mov    %edx,%edi
f0105ab1:	89 c6                	mov    %eax,%esi
f0105ab3:	2b 74 24 0c          	sub    0xc(%esp),%esi
f0105ab7:	1b 7c 24 10          	sbb    0x10(%esp),%edi
f0105abb:	89 ca                	mov    %ecx,%edx
f0105abd:	89 e9                	mov    %ebp,%ecx
f0105abf:	8b 44 24 14          	mov    0x14(%esp),%eax
f0105ac3:	29 f0                	sub    %esi,%eax
f0105ac5:	19 fa                	sbb    %edi,%edx
f0105ac7:	d3 e8                	shr    %cl,%eax
f0105ac9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
f0105ace:	89 d7                	mov    %edx,%edi
f0105ad0:	d3 e7                	shl    %cl,%edi
f0105ad2:	89 e9                	mov    %ebp,%ecx
f0105ad4:	09 f8                	or     %edi,%eax
f0105ad6:	d3 ea                	shr    %cl,%edx
f0105ad8:	83 c4 20             	add    $0x20,%esp
f0105adb:	5e                   	pop    %esi
f0105adc:	5f                   	pop    %edi
f0105add:	5d                   	pop    %ebp
f0105ade:	c3                   	ret    
f0105adf:	90                   	nop
f0105ae0:	8b 74 24 10          	mov    0x10(%esp),%esi
f0105ae4:	29 f9                	sub    %edi,%ecx
f0105ae6:	19 c6                	sbb    %eax,%esi
f0105ae8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
f0105aec:	89 74 24 18          	mov    %esi,0x18(%esp)
f0105af0:	e9 ff fe ff ff       	jmp    f01059f4 <__umoddi3+0x74>
