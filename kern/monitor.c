// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/tsc.h>
#include <kern/pmap.h>
#include <kern/trap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "test", "Display something", mon_test},
	{ "backtrace", "Display stack backtrace", mon_backtrace},
	{ "timer_start", "Start the countdown", mon_start}, 
	{ "timer_stop", "Display time in seconds since last start call", mon_stop},
	{ "memory", "Display physical page status", mon_memory},
};
#define NCOMMANDS (sizeof(commands)/sizeof(commands[0]))

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
	cprintf("  _start                  %08x (phys)\n", (uint32_t)_start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n",
            (uint32_t)entry, (uint32_t)entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n",
            (uint32_t)etext, (uint32_t)etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n",
            (uint32_t)edata, (uint32_t)edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n",
            (uint32_t)end, (uint32_t)end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
	    ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t ebp = read_ebp(), *ebp_pointer, eip;
	struct Eipdebuginfo dbg;	
	cprintf("Stack backtrace:\n");
	while (ebp) {
		ebp_pointer = (uint32_t *)ebp;
		eip = ebp_pointer[1];
		cprintf("  ebp  %08x  eip %08x  args ", ebp, eip);
		int i;
		for (i = 2; i < 6; i++)
			cprintf(" %08x", ebp_pointer[i]);
		cprintf("\n");
		debuginfo_eip(eip, &dbg);
		cprintf("          %s:%d: %.*s+%d\n",
		    dbg.eip_file, dbg.eip_line, dbg.eip_fn_namelen, dbg.eip_fn_name, eip - dbg.eip_fn_addr);
		ebp = *ebp_pointer;
	}
	return 0;
}

int
mon_test(int argc, char **argv, struct Trapframe *tf)
{
	cprintf("It works!\n");
	return 0;
}

int
mon_start(int argc, char **argv, struct  Trapframe *tf)
{
	timer_start();
	return 0;
}

int
mon_stop(int argc, char **argv, struct  Trapframe *tf)
{
	timer_stop();
	return 0;
}

int
mon_memory(int argc, char **argv, struct Trapframe *tf) {
	int i, start = 1, state_flag = 1, ref_flag = 0;
	for (i = 0; i < npages; i++) {

		if (pages[i].pp_ref) {
			ref_flag = 1;
		} else {
			ref_flag = 0;
		}

		if (state_flag != ref_flag) {
			if (start != i)
				cprintf("%d..%d", start, i);
			else
				cprintf("%d", start);

			if (state_flag) 
				cprintf(" ALLOCATED\n");
			else
				cprintf(" FREE\n");

			start = i + 1;
			state_flag = ref_flag;
		}
	}
	if (start != npages) {
		if (state_flag == 0)
			cprintf("%d..%d FREE\n", start, npages);
		else
			cprintf("%d..%d ALLOCATED\n", start, npages);
	}
	return 0;
}
/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

static int
runcmd(char *buf, struct Trapframe *tf)
{
	int argc;
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
		if (*buf == 0)
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
			buf++;
	}
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
	return 0;
}

void
monitor(struct Trapframe *tf)
{
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");

	if (tf != NULL)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
