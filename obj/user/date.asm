
obj/user/date:     file format elf32-i386


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
  80002c:	e8 18 03 00 00       	call   800349 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <is_leap_year>:
    int tm_mon;                   /* Month.       [0-11] */
    int tm_year;                  /* Year - 1900.  */
};

bool is_leap_year(int year)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	8b 4d 08             	mov    0x8(%ebp),%ecx
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
  800039:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  80003e:	89 c8                	mov    %ecx,%eax
  800040:	f7 ea                	imul   %edx
  800042:	c1 fa 07             	sar    $0x7,%edx
  800045:	89 c8                	mov    %ecx,%eax
  800047:	c1 f8 1f             	sar    $0x1f,%eax
  80004a:	29 c2                	sub    %eax,%edx
  80004c:	69 d2 90 01 00 00    	imul   $0x190,%edx,%edx
  800052:	b8 01 00 00 00       	mov    $0x1,%eax
  800057:	39 d1                	cmp    %edx,%ecx
  800059:	74 25                	je     800080 <is_leap_year+0x4d>
  80005b:	b0 00                	mov    $0x0,%al
  80005d:	f6 c1 03             	test   $0x3,%cl
  800060:	75 1e                	jne    800080 <is_leap_year+0x4d>
  800062:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  800067:	89 c8                	mov    %ecx,%eax
  800069:	f7 ea                	imul   %edx
  80006b:	c1 fa 05             	sar    $0x5,%edx
  80006e:	89 c8                	mov    %ecx,%eax
  800070:	c1 f8 1f             	sar    $0x1f,%eax
  800073:	29 c2                	sub    %eax,%edx
  800075:	6b d2 64             	imul   $0x64,%edx,%edx
  800078:	39 d1                	cmp    %edx,%ecx
  80007a:	0f 95 c0             	setne  %al
  80007d:	0f b6 c0             	movzbl %al,%eax
  800080:	83 e0 01             	and    $0x1,%eax
}
  800083:	5d                   	pop    %ebp
  800084:	c3                   	ret    

00800085 <d_to_s>:

int d_to_s(int d)
{
  800085:	55                   	push   %ebp
  800086:	89 e5                	mov    %esp,%ebp
    return d * 24 * 60 * 60;
  800088:	69 45 08 80 51 01 00 	imul   $0x15180,0x8(%ebp),%eax
}
  80008f:	5d                   	pop    %ebp
  800090:	c3                   	ret    

00800091 <timestamp>:

int timestamp(struct tm *time)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	57                   	push   %edi
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	83 ec 34             	sub    $0x34,%esp
    int result = 0, year, month;
    for (year = 1970; year < time->tm_year + 2000; year++)
  80009a:	8b 45 08             	mov    0x8(%ebp),%eax
  80009d:	8b 40 14             	mov    0x14(%eax),%eax
  8000a0:	89 45 c0             	mov    %eax,-0x40(%ebp)
  8000a3:	8d b8 d0 07 00 00    	lea    0x7d0(%eax),%edi
  8000a9:	be b2 07 00 00       	mov    $0x7b2,%esi
    return d * 24 * 60 * 60;
}

int timestamp(struct tm *time)
{
    int result = 0, year, month;
  8000ae:	bb 00 00 00 00       	mov    $0x0,%ebx
    for (year = 1970; year < time->tm_year + 2000; year++)
  8000b3:	eb 1c                	jmp    8000d1 <timestamp+0x40>
    {
        result += d_to_s(365 + is_leap_year(year));
  8000b5:	56                   	push   %esi
  8000b6:	e8 78 ff ff ff       	call   800033 <is_leap_year>
  8000bb:	83 c4 04             	add    $0x4,%esp
  8000be:	0f b6 c0             	movzbl %al,%eax
  8000c1:	05 6d 01 00 00       	add    $0x16d,%eax
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
  8000c6:	69 c0 80 51 01 00    	imul   $0x15180,%eax,%eax
int timestamp(struct tm *time)
{
    int result = 0, year, month;
    for (year = 1970; year < time->tm_year + 2000; year++)
    {
        result += d_to_s(365 + is_leap_year(year));
  8000cc:	01 c3                	add    %eax,%ebx
}

int timestamp(struct tm *time)
{
    int result = 0, year, month;
    for (year = 1970; year < time->tm_year + 2000; year++)
  8000ce:	83 c6 01             	add    $0x1,%esi
  8000d1:	39 fe                	cmp    %edi,%esi
  8000d3:	7c e0                	jl     8000b5 <timestamp+0x24>
    {
        result += d_to_s(365 + is_leap_year(year));
    }
    int months[] = {31, 28 + is_leap_year(year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
  8000d5:	c7 45 c4 1f 00 00 00 	movl   $0x1f,-0x3c(%ebp)
  8000dc:	56                   	push   %esi
  8000dd:	e8 51 ff ff ff       	call   800033 <is_leap_year>
  8000e2:	83 c4 04             	add    $0x4,%esp
  8000e5:	0f b6 c0             	movzbl %al,%eax
  8000e8:	83 c0 1c             	add    $0x1c,%eax
  8000eb:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8000ee:	c7 45 cc 1f 00 00 00 	movl   $0x1f,-0x34(%ebp)
  8000f5:	c7 45 d0 1e 00 00 00 	movl   $0x1e,-0x30(%ebp)
  8000fc:	c7 45 d4 1f 00 00 00 	movl   $0x1f,-0x2c(%ebp)
  800103:	c7 45 d8 1e 00 00 00 	movl   $0x1e,-0x28(%ebp)
  80010a:	c7 45 dc 1f 00 00 00 	movl   $0x1f,-0x24(%ebp)
  800111:	c7 45 e0 1f 00 00 00 	movl   $0x1f,-0x20(%ebp)
  800118:	c7 45 e4 1e 00 00 00 	movl   $0x1e,-0x1c(%ebp)
  80011f:	c7 45 e8 1f 00 00 00 	movl   $0x1f,-0x18(%ebp)
  800126:	c7 45 ec 1e 00 00 00 	movl   $0x1e,-0x14(%ebp)
  80012d:	c7 45 f0 1f 00 00 00 	movl   $0x1f,-0x10(%ebp)
    for (month = 0; month < time->tm_mon; month++)
  800134:	8b 45 08             	mov    0x8(%ebp),%eax
  800137:	8b 48 10             	mov    0x10(%eax),%ecx
  80013a:	b8 00 00 00 00       	mov    $0x0,%eax
  80013f:	eb 0d                	jmp    80014e <timestamp+0xbd>
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
  800141:	69 54 85 c4 80 51 01 	imul   $0x15180,-0x3c(%ebp,%eax,4),%edx
  800148:	00 
        result += d_to_s(365 + is_leap_year(year));
    }
    int months[] = {31, 28 + is_leap_year(year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    for (month = 0; month < time->tm_mon; month++)
    {
        result += d_to_s(months[month]);
  800149:	01 d3                	add    %edx,%ebx
    for (year = 1970; year < time->tm_year + 2000; year++)
    {
        result += d_to_s(365 + is_leap_year(year));
    }
    int months[] = {31, 28 + is_leap_year(year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    for (month = 0; month < time->tm_mon; month++)
  80014b:	83 c0 01             	add    $0x1,%eax
  80014e:	39 c8                	cmp    %ecx,%eax
  800150:	7c ef                	jl     800141 <timestamp+0xb0>
    {
        result += d_to_s(months[month]);
    }
    result += d_to_s(time->tm_mday) + time->tm_hour*60*60 + time->tm_min*60 + time->tm_sec;
  800152:	8b 45 08             	mov    0x8(%ebp),%eax
  800155:	69 50 08 10 0e 00 00 	imul   $0xe10,0x8(%eax),%edx
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
  80015c:	69 40 0c 80 51 01 00 	imul   $0x15180,0xc(%eax),%eax
    int months[] = {31, 28 + is_leap_year(year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
    for (month = 0; month < time->tm_mon; month++)
    {
        result += d_to_s(months[month]);
    }
    result += d_to_s(time->tm_mday) + time->tm_hour*60*60 + time->tm_min*60 + time->tm_sec;
  800163:	01 c2                	add    %eax,%edx
  800165:	8b 45 08             	mov    0x8(%ebp),%eax
  800168:	6b 40 04 3c          	imul   $0x3c,0x4(%eax),%eax
  80016c:	01 d0                	add    %edx,%eax
  80016e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800171:	03 07                	add    (%edi),%eax
  800173:	01 d8                	add    %ebx,%eax
    return result;
}
  800175:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    

0080017d <mktime>:

void mktime(int time, struct tm *tm)
{
  80017d:	55                   	push   %ebp
  80017e:	89 e5                	mov    %esp,%ebp
  800180:	57                   	push   %edi
  800181:	56                   	push   %esi
  800182:	53                   	push   %ebx
  800183:	83 ec 30             	sub    $0x30,%esp
  800186:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800189:	8b 7d 0c             	mov    0xc(%ebp),%edi
    int year = 70;
  80018c:	be 46 00 00 00       	mov    $0x46,%esi
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;

    while (time > d_to_s(365 + is_leap_year(1900+year))) {
  800191:	eb 05                	jmp    800198 <mktime+0x1b>
        time -= d_to_s(365 + is_leap_year(1900+year));
  800193:	29 d3                	sub    %edx,%ebx
        year++;
  800195:	83 c6 01             	add    $0x1,%esi
  800198:	8d 86 6c 07 00 00    	lea    0x76c(%esi),%eax
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;

    while (time > d_to_s(365 + is_leap_year(1900+year))) {
  80019e:	50                   	push   %eax
  80019f:	e8 8f fe ff ff       	call   800033 <is_leap_year>
  8001a4:	83 c4 04             	add    $0x4,%esp
  8001a7:	0f b6 c0             	movzbl %al,%eax
  8001aa:	8d 90 6d 01 00 00    	lea    0x16d(%eax),%edx
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
  8001b0:	69 d2 80 51 01 00    	imul   $0x15180,%edx,%edx
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;

    while (time > d_to_s(365 + is_leap_year(1900+year))) {
  8001b6:	39 d3                	cmp    %edx,%ebx
  8001b8:	7f d9                	jg     800193 <mktime+0x16>
        time -= d_to_s(365 + is_leap_year(1900+year));
        year++;
    }
    tm->tm_year = year;
  8001ba:	89 77 14             	mov    %esi,0x14(%edi)

    int months[] = {31, 28 + is_leap_year(1900+year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };
  8001bd:	c7 45 c4 1f 00 00 00 	movl   $0x1f,-0x3c(%ebp)
  8001c4:	83 c0 1c             	add    $0x1c,%eax
  8001c7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8001ca:	c7 45 cc 1f 00 00 00 	movl   $0x1f,-0x34(%ebp)
  8001d1:	c7 45 d0 1e 00 00 00 	movl   $0x1e,-0x30(%ebp)
  8001d8:	c7 45 d4 1f 00 00 00 	movl   $0x1f,-0x2c(%ebp)
  8001df:	c7 45 d8 1e 00 00 00 	movl   $0x1e,-0x28(%ebp)
  8001e6:	c7 45 dc 1f 00 00 00 	movl   $0x1f,-0x24(%ebp)
  8001ed:	c7 45 e0 1f 00 00 00 	movl   $0x1f,-0x20(%ebp)
  8001f4:	c7 45 e4 1e 00 00 00 	movl   $0x1e,-0x1c(%ebp)
  8001fb:	c7 45 e8 1f 00 00 00 	movl   $0x1f,-0x18(%ebp)
  800202:	c7 45 ec 1e 00 00 00 	movl   $0x1e,-0x14(%ebp)
  800209:	c7 45 f0 1f 00 00 00 	movl   $0x1f,-0x10(%ebp)
}

void mktime(int time, struct tm *tm)
{
    int year = 70;
    int month = 0;
  800210:	b8 00 00 00 00       	mov    $0x0,%eax
    }
    tm->tm_year = year;

    int months[] = {31, 28 + is_leap_year(1900+year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    while (time > d_to_s(months[month])){
  800215:	eb 05                	jmp    80021c <mktime+0x9f>
        time -= d_to_s(months[month]);
  800217:	29 d3                	sub    %edx,%ebx
        month++;
  800219:	83 c0 01             	add    $0x1,%eax
    return (year % 400 == 0) || (year % 4 == 0 && year % 100 != 0);
}

int d_to_s(int d)
{
    return d * 24 * 60 * 60;
  80021c:	69 54 85 c4 80 51 01 	imul   $0x15180,-0x3c(%ebp,%eax,4),%edx
  800223:	00 
    }
    tm->tm_year = year;

    int months[] = {31, 28 + is_leap_year(1900+year), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

    while (time > d_to_s(months[month])){
  800224:	39 d3                	cmp    %edx,%ebx
  800226:	7f ef                	jg     800217 <mktime+0x9a>
        time -= d_to_s(months[month]);
        month++;
    }
    tm->tm_mon = month;
  800228:	89 47 10             	mov    %eax,0x10(%edi)

void mktime(int time, struct tm *tm)
{
    int year = 70;
    int month = 0;
    int day = 0;
  80022b:	b8 00 00 00 00       	mov    $0x0,%eax
        time -= d_to_s(months[month]);
        month++;
    }
    tm->tm_mon = month;

    while (time > d_to_s(1)) {
  800230:	eb 09                	jmp    80023b <mktime+0xbe>
        time -= d_to_s(1);
  800232:	81 eb 80 51 01 00    	sub    $0x15180,%ebx
        day++;
  800238:	83 c0 01             	add    $0x1,%eax
        time -= d_to_s(months[month]);
        month++;
    }
    tm->tm_mon = month;

    while (time > d_to_s(1)) {
  80023b:	81 fb 80 51 01 00    	cmp    $0x15180,%ebx
  800241:	7f ef                	jg     800232 <mktime+0xb5>
        time -= d_to_s(1);
        day++;
    }
    tm->tm_mday = day;
  800243:	89 47 0c             	mov    %eax,0xc(%edi)
void mktime(int time, struct tm *tm)
{
    int year = 70;
    int month = 0;
    int day = 0;
    int hour = 0;
  800246:	b8 00 00 00 00       	mov    $0x0,%eax
        time -= d_to_s(1);
        day++;
    }
    tm->tm_mday = day;

    while (time >= 60*60) {
  80024b:	eb 09                	jmp    800256 <mktime+0xd9>
        time -= 60*60;
  80024d:	81 eb 10 0e 00 00    	sub    $0xe10,%ebx
        hour++;
  800253:	83 c0 01             	add    $0x1,%eax
        time -= d_to_s(1);
        day++;
    }
    tm->tm_mday = day;

    while (time >= 60*60) {
  800256:	81 fb 0f 0e 00 00    	cmp    $0xe0f,%ebx
  80025c:	7f ef                	jg     80024d <mktime+0xd0>
        time -= 60*60;
        hour++;
    }

    tm->tm_hour = hour;
  80025e:	89 47 08             	mov    %eax,0x8(%edi)
{
    int year = 70;
    int month = 0;
    int day = 0;
    int hour = 0;
    int minute = 0;
  800261:	b8 00 00 00 00       	mov    $0x0,%eax
        hour++;
    }

    tm->tm_hour = hour;

    while (time >= 60) {
  800266:	eb 06                	jmp    80026e <mktime+0xf1>
        time -= 60;
  800268:	83 eb 3c             	sub    $0x3c,%ebx
        minute++;
  80026b:	83 c0 01             	add    $0x1,%eax
        hour++;
    }

    tm->tm_hour = hour;

    while (time >= 60) {
  80026e:	83 fb 3b             	cmp    $0x3b,%ebx
  800271:	7f f5                	jg     800268 <mktime+0xeb>
        time -= 60;
        minute++;
    }

    tm->tm_min = minute;
  800273:	89 47 04             	mov    %eax,0x4(%edi)
    tm->tm_sec = time;
  800276:	89 1f                	mov    %ebx,(%edi)
}
  800278:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027b:	5b                   	pop    %ebx
  80027c:	5e                   	pop    %esi
  80027d:	5f                   	pop    %edi
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <print_datetime>:

void print_datetime(struct tm *tm)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	83 ec 0c             	sub    $0xc,%esp
  800286:	8b 45 08             	mov    0x8(%ebp),%eax
    cprintf("%04d-%02d-%02d %02d:%02d:%02d\n",
  800289:	ff 30                	pushl  (%eax)
  80028b:	ff 70 04             	pushl  0x4(%eax)
  80028e:	ff 70 08             	pushl  0x8(%eax)
  800291:	ff 70 0c             	pushl  0xc(%eax)
  800294:	8b 48 10             	mov    0x10(%eax),%ecx
  800297:	8d 51 01             	lea    0x1(%ecx),%edx
  80029a:	52                   	push   %edx
  80029b:	8b 40 14             	mov    0x14(%eax),%eax
  80029e:	05 6c 07 00 00       	add    $0x76c,%eax
  8002a3:	50                   	push   %eax
  8002a4:	68 00 21 80 00       	push   $0x802100
  8002a9:	e8 d4 01 00 00       	call   800482 <cprintf>
  8002ae:	83 c4 20             	add    $0x20,%esp
        tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
        tm->tm_hour, tm->tm_min, tm->tm_sec);
}
  8002b1:	c9                   	leave  
  8002b2:	c3                   	ret    

008002b3 <snprint_datetime>:

void snprint_datetime(char *buf, int size, struct tm *tm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bc:	8b 45 10             	mov    0x10(%ebp),%eax
    assert(size >= 10 + 1 + 8 + 1);
  8002bf:	83 f9 13             	cmp    $0x13,%ecx
  8002c2:	7f 16                	jg     8002da <snprint_datetime+0x27>
  8002c4:	68 1f 21 80 00       	push   $0x80211f
  8002c9:	68 36 21 80 00       	push   $0x802136
  8002ce:	6a 60                	push   $0x60
  8002d0:	68 4b 21 80 00       	push   $0x80214b
  8002d5:	e8 cf 00 00 00       	call   8003a9 <_panic>
    snprintf(buf, size,
  8002da:	83 ec 0c             	sub    $0xc,%esp
  8002dd:	ff 30                	pushl  (%eax)
  8002df:	ff 70 04             	pushl  0x4(%eax)
  8002e2:	ff 70 08             	pushl  0x8(%eax)
  8002e5:	ff 70 0c             	pushl  0xc(%eax)
  8002e8:	8b 50 10             	mov    0x10(%eax),%edx
  8002eb:	83 c2 01             	add    $0x1,%edx
  8002ee:	52                   	push   %edx
  8002ef:	8b 40 14             	mov    0x14(%eax),%eax
  8002f2:	05 6c 07 00 00       	add    $0x76c,%eax
  8002f7:	50                   	push   %eax
  8002f8:	68 58 21 80 00       	push   $0x802158
  8002fd:	51                   	push   %ecx
  8002fe:	ff 75 08             	pushl  0x8(%ebp)
  800301:	e8 ad 06 00 00       	call   8009b3 <snprintf>
  800306:	83 c4 30             	add    $0x30,%esp
          "%04d-%02d-%02d %02d:%02d:%02d",
          tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday,
          tm->tm_hour, tm->tm_min, tm->tm_sec);
}
  800309:	c9                   	leave  
  80030a:	c3                   	ret    

0080030b <umain>:
#include <inc/types.h>
#include <inc/time.h>
#include <inc/stdio.h>
#include <inc/lib.h>

void umain (int argc, char **argv) {
  80030b:	55                   	push   %ebp
  80030c:	89 e5                	mov    %esp,%ebp
  80030e:	53                   	push   %ebx
  80030f:	83 ec 34             	sub    $0x34,%esp
    char time[20];
    int now = sys_gettime();
  800312:	e8 ea 0c 00 00       	call   801001 <sys_gettime>
    struct tm tnow;

    mktime(now, &tnow);
  800317:	83 ec 08             	sub    $0x8,%esp
  80031a:	8d 5d cc             	lea    -0x34(%ebp),%ebx
  80031d:	53                   	push   %ebx
  80031e:	50                   	push   %eax
  80031f:	e8 59 fe ff ff       	call   80017d <mktime>

    snprint_datetime(time, 20, &tnow);
  800324:	83 c4 0c             	add    $0xc,%esp
  800327:	53                   	push   %ebx
  800328:	6a 14                	push   $0x14
  80032a:	8d 5d e4             	lea    -0x1c(%ebp),%ebx
  80032d:	53                   	push   %ebx
  80032e:	e8 80 ff ff ff       	call   8002b3 <snprint_datetime>
    cprintf("DATE: %s\n", time);
  800333:	83 c4 08             	add    $0x8,%esp
  800336:	53                   	push   %ebx
  800337:	68 76 21 80 00       	push   $0x802176
  80033c:	e8 41 01 00 00       	call   800482 <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp
}
  800344:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800347:	c9                   	leave  
  800348:	c3                   	ret    

00800349 <libmain>:
void (* volatile sys_exit)(void);
#endif

void
libmain(int argc, char **argv)
{
  800349:	55                   	push   %ebp
  80034a:	89 e5                	mov    %esp,%ebp
  80034c:	56                   	push   %esi
  80034d:	53                   	push   %ebx
  80034e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800351:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 8: Your code here.
	thisenv = envs + ENVX(sys_getenvid());
  800354:	e8 79 0a 00 00       	call   800dd2 <sys_getenvid>
  800359:	25 ff 03 00 00       	and    $0x3ff,%eax
  80035e:	6b c0 78             	imul   $0x78,%eax,%eax
  800361:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800366:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80036b:	85 db                	test   %ebx,%ebx
  80036d:	7e 07                	jle    800376 <libmain+0x2d>
		binaryname = argv[0];
  80036f:	8b 06                	mov    (%esi),%eax
  800371:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
  80037b:	e8 8b ff ff ff       	call   80030b <umain>

	// exit
#ifdef JOS_PROG
	sys_exit();
#else
	exit();
  800380:	e8 0a 00 00 00       	call   80038f <exit>
  800385:	83 c4 10             	add    $0x10,%esp
#endif
}
  800388:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800395:	e8 52 0e 00 00       	call   8011ec <close_all>
	sys_env_destroy(0);
  80039a:	83 ec 0c             	sub    $0xc,%esp
  80039d:	6a 00                	push   $0x0
  80039f:	e8 ed 09 00 00       	call   800d91 <sys_env_destroy>
  8003a4:	83 c4 10             	add    $0x10,%esp
}
  8003a7:	c9                   	leave  
  8003a8:	c3                   	ret    

008003a9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8003a9:	55                   	push   %ebp
  8003aa:	89 e5                	mov    %esp,%ebp
  8003ac:	56                   	push   %esi
  8003ad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8003ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8003b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8003b7:	e8 16 0a 00 00       	call   800dd2 <sys_getenvid>
  8003bc:	83 ec 0c             	sub    $0xc,%esp
  8003bf:	ff 75 0c             	pushl  0xc(%ebp)
  8003c2:	ff 75 08             	pushl  0x8(%ebp)
  8003c5:	56                   	push   %esi
  8003c6:	50                   	push   %eax
  8003c7:	68 8c 21 80 00       	push   $0x80218c
  8003cc:	e8 b1 00 00 00       	call   800482 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8003d1:	83 c4 18             	add    $0x18,%esp
  8003d4:	53                   	push   %ebx
  8003d5:	ff 75 10             	pushl  0x10(%ebp)
  8003d8:	e8 54 00 00 00       	call   800431 <vcprintf>
	cprintf("\n");
  8003dd:	c7 04 24 67 25 80 00 	movl   $0x802567,(%esp)
  8003e4:	e8 99 00 00 00       	call   800482 <cprintf>
  8003e9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8003ec:	cc                   	int3   
  8003ed:	eb fd                	jmp    8003ec <_panic+0x43>

008003ef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	53                   	push   %ebx
  8003f3:	83 ec 04             	sub    $0x4,%esp
  8003f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8003f9:	8b 13                	mov    (%ebx),%edx
  8003fb:	8d 42 01             	lea    0x1(%edx),%eax
  8003fe:	89 03                	mov    %eax,(%ebx)
  800400:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800403:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800407:	3d ff 00 00 00       	cmp    $0xff,%eax
  80040c:	75 1a                	jne    800428 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80040e:	83 ec 08             	sub    $0x8,%esp
  800411:	68 ff 00 00 00       	push   $0xff
  800416:	8d 43 08             	lea    0x8(%ebx),%eax
  800419:	50                   	push   %eax
  80041a:	e8 35 09 00 00       	call   800d54 <sys_cputs>
		b->idx = 0;
  80041f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800425:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800428:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80042c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80042f:	c9                   	leave  
  800430:	c3                   	ret    

00800431 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800431:	55                   	push   %ebp
  800432:	89 e5                	mov    %esp,%ebp
  800434:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80043a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800441:	00 00 00 
	b.cnt = 0;
  800444:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80044b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80044e:	ff 75 0c             	pushl  0xc(%ebp)
  800451:	ff 75 08             	pushl  0x8(%ebp)
  800454:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80045a:	50                   	push   %eax
  80045b:	68 ef 03 80 00       	push   $0x8003ef
  800460:	e8 4f 01 00 00       	call   8005b4 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800465:	83 c4 08             	add    $0x8,%esp
  800468:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80046e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800474:	50                   	push   %eax
  800475:	e8 da 08 00 00       	call   800d54 <sys_cputs>

	return b.cnt;
}
  80047a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800480:	c9                   	leave  
  800481:	c3                   	ret    

00800482 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800488:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80048b:	50                   	push   %eax
  80048c:	ff 75 08             	pushl  0x8(%ebp)
  80048f:	e8 9d ff ff ff       	call   800431 <vcprintf>
	va_end(ap);

	return cnt;
}
  800494:	c9                   	leave  
  800495:	c3                   	ret    

00800496 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800496:	55                   	push   %ebp
  800497:	89 e5                	mov    %esp,%ebp
  800499:	57                   	push   %edi
  80049a:	56                   	push   %esi
  80049b:	53                   	push   %ebx
  80049c:	83 ec 1c             	sub    $0x1c,%esp
  80049f:	89 c7                	mov    %eax,%edi
  8004a1:	89 d6                	mov    %edx,%esi
  8004a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a9:	89 d1                	mov    %edx,%ecx
  8004ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ae:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8004b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004ba:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004c1:	39 4d e4             	cmp    %ecx,-0x1c(%ebp)
  8004c4:	72 05                	jb     8004cb <printnum+0x35>
  8004c6:	3b 45 d8             	cmp    -0x28(%ebp),%eax
  8004c9:	77 3e                	ja     800509 <printnum+0x73>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8004cb:	83 ec 0c             	sub    $0xc,%esp
  8004ce:	ff 75 18             	pushl  0x18(%ebp)
  8004d1:	83 eb 01             	sub    $0x1,%ebx
  8004d4:	53                   	push   %ebx
  8004d5:	50                   	push   %eax
  8004d6:	83 ec 08             	sub    $0x8,%esp
  8004d9:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8004df:	ff 75 dc             	pushl  -0x24(%ebp)
  8004e2:	ff 75 d8             	pushl  -0x28(%ebp)
  8004e5:	e8 46 19 00 00       	call   801e30 <__udivdi3>
  8004ea:	83 c4 18             	add    $0x18,%esp
  8004ed:	52                   	push   %edx
  8004ee:	50                   	push   %eax
  8004ef:	89 f2                	mov    %esi,%edx
  8004f1:	89 f8                	mov    %edi,%eax
  8004f3:	e8 9e ff ff ff       	call   800496 <printnum>
  8004f8:	83 c4 20             	add    $0x20,%esp
  8004fb:	eb 13                	jmp    800510 <printnum+0x7a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	56                   	push   %esi
  800501:	ff 75 18             	pushl  0x18(%ebp)
  800504:	ff d7                	call   *%edi
  800506:	83 c4 10             	add    $0x10,%esp
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800509:	83 eb 01             	sub    $0x1,%ebx
  80050c:	85 db                	test   %ebx,%ebx
  80050e:	7f ed                	jg     8004fd <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	56                   	push   %esi
  800514:	83 ec 04             	sub    $0x4,%esp
  800517:	ff 75 e4             	pushl  -0x1c(%ebp)
  80051a:	ff 75 e0             	pushl  -0x20(%ebp)
  80051d:	ff 75 dc             	pushl  -0x24(%ebp)
  800520:	ff 75 d8             	pushl  -0x28(%ebp)
  800523:	e8 38 1a 00 00       	call   801f60 <__umoddi3>
  800528:	83 c4 14             	add    $0x14,%esp
  80052b:	0f be 80 af 21 80 00 	movsbl 0x8021af(%eax),%eax
  800532:	50                   	push   %eax
  800533:	ff d7                	call   *%edi
  800535:	83 c4 10             	add    $0x10,%esp
}
  800538:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80053b:	5b                   	pop    %ebx
  80053c:	5e                   	pop    %esi
  80053d:	5f                   	pop    %edi
  80053e:	5d                   	pop    %ebp
  80053f:	c3                   	ret    

00800540 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800540:	55                   	push   %ebp
  800541:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800543:	83 fa 01             	cmp    $0x1,%edx
  800546:	7e 0e                	jle    800556 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  800548:	8b 10                	mov    (%eax),%edx
  80054a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80054d:	89 08                	mov    %ecx,(%eax)
  80054f:	8b 02                	mov    (%edx),%eax
  800551:	8b 52 04             	mov    0x4(%edx),%edx
  800554:	eb 22                	jmp    800578 <getuint+0x38>
	else if (lflag)
  800556:	85 d2                	test   %edx,%edx
  800558:	74 10                	je     80056a <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80055a:	8b 10                	mov    (%eax),%edx
  80055c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80055f:	89 08                	mov    %ecx,(%eax)
  800561:	8b 02                	mov    (%edx),%eax
  800563:	ba 00 00 00 00       	mov    $0x0,%edx
  800568:	eb 0e                	jmp    800578 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80056a:	8b 10                	mov    (%eax),%edx
  80056c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80056f:	89 08                	mov    %ecx,(%eax)
  800571:	8b 02                	mov    (%edx),%eax
  800573:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800578:	5d                   	pop    %ebp
  800579:	c3                   	ret    

0080057a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800580:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800584:	8b 10                	mov    (%eax),%edx
  800586:	3b 50 04             	cmp    0x4(%eax),%edx
  800589:	73 0a                	jae    800595 <sprintputch+0x1b>
		*b->buf++ = ch;
  80058b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80058e:	89 08                	mov    %ecx,(%eax)
  800590:	8b 45 08             	mov    0x8(%ebp),%eax
  800593:	88 02                	mov    %al,(%edx)
}
  800595:	5d                   	pop    %ebp
  800596:	c3                   	ret    

00800597 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80059d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8005a0:	50                   	push   %eax
  8005a1:	ff 75 10             	pushl  0x10(%ebp)
  8005a4:	ff 75 0c             	pushl  0xc(%ebp)
  8005a7:	ff 75 08             	pushl  0x8(%ebp)
  8005aa:	e8 05 00 00 00       	call   8005b4 <vprintfmt>
	va_end(ap);
  8005af:	83 c4 10             	add    $0x10,%esp
}
  8005b2:	c9                   	leave  
  8005b3:	c3                   	ret    

008005b4 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8005b4:	55                   	push   %ebp
  8005b5:	89 e5                	mov    %esp,%ebp
  8005b7:	57                   	push   %edi
  8005b8:	56                   	push   %esi
  8005b9:	53                   	push   %ebx
  8005ba:	83 ec 2c             	sub    $0x2c,%esp
  8005bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8005c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8005c3:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005c6:	eb 12                	jmp    8005da <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8005c8:	85 c0                	test   %eax,%eax
  8005ca:	0f 84 8d 03 00 00    	je     80095d <vprintfmt+0x3a9>
				return;
			putch(ch, putdat);
  8005d0:	83 ec 08             	sub    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	50                   	push   %eax
  8005d5:	ff d6                	call   *%esi
  8005d7:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005da:	83 c7 01             	add    $0x1,%edi
  8005dd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005e1:	83 f8 25             	cmp    $0x25,%eax
  8005e4:	75 e2                	jne    8005c8 <vprintfmt+0x14>
  8005e6:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8005ea:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8005f1:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005f8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8005ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800604:	eb 07                	jmp    80060d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800606:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800609:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060d:	8d 47 01             	lea    0x1(%edi),%eax
  800610:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800613:	0f b6 07             	movzbl (%edi),%eax
  800616:	0f b6 c8             	movzbl %al,%ecx
  800619:	83 e8 23             	sub    $0x23,%eax
  80061c:	3c 55                	cmp    $0x55,%al
  80061e:	0f 87 1e 03 00 00    	ja     800942 <vprintfmt+0x38e>
  800624:	0f b6 c0             	movzbl %al,%eax
  800627:	ff 24 85 00 23 80 00 	jmp    *0x802300(,%eax,4)
  80062e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800631:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800635:	eb d6                	jmp    80060d <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800637:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80063a:	b8 00 00 00 00       	mov    $0x0,%eax
  80063f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800642:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800645:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  800649:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  80064c:	8d 51 d0             	lea    -0x30(%ecx),%edx
  80064f:	83 fa 09             	cmp    $0x9,%edx
  800652:	77 38                	ja     80068c <vprintfmt+0xd8>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800654:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800657:	eb e9                	jmp    800642 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8d 48 04             	lea    0x4(%eax),%ecx
  80065f:	89 4d 14             	mov    %ecx,0x14(%ebp)
  800662:	8b 00                	mov    (%eax),%eax
  800664:	89 45 d0             	mov    %eax,-0x30(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80066a:	eb 26                	jmp    800692 <vprintfmt+0xde>
  80066c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80066f:	89 c8                	mov    %ecx,%eax
  800671:	c1 f8 1f             	sar    $0x1f,%eax
  800674:	f7 d0                	not    %eax
  800676:	21 c1                	and    %eax,%ecx
  800678:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067e:	eb 8d                	jmp    80060d <vprintfmt+0x59>
  800680:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800683:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80068a:	eb 81                	jmp    80060d <vprintfmt+0x59>
  80068c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80068f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800692:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800696:	0f 89 71 ff ff ff    	jns    80060d <vprintfmt+0x59>
				width = precision, precision = -1;
  80069c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80069f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8006a9:	e9 5f ff ff ff       	jmp    80060d <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8006ae:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8006b4:	e9 54 ff ff ff       	jmp    80060d <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8d 50 04             	lea    0x4(%eax),%edx
  8006bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	ff 30                	pushl  (%eax)
  8006c8:	ff d6                	call   *%esi
			break;
  8006ca:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8006d0:	e9 05 ff ff ff       	jmp    8005da <vprintfmt+0x26>

		// error message
		case 'i':
			err = va_arg(ap, int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	99                   	cltd   
  8006e1:	31 d0                	xor    %edx,%eax
  8006e3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006e5:	83 f8 0f             	cmp    $0xf,%eax
  8006e8:	7f 0b                	jg     8006f5 <vprintfmt+0x141>
  8006ea:	8b 14 85 80 24 80 00 	mov    0x802480(,%eax,4),%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	75 18                	jne    80070d <vprintfmt+0x159>
				printfmt(putch, putdat, "error %d", err);
  8006f5:	50                   	push   %eax
  8006f6:	68 c7 21 80 00       	push   $0x8021c7
  8006fb:	53                   	push   %ebx
  8006fc:	56                   	push   %esi
  8006fd:	e8 95 fe ff ff       	call   800597 <printfmt>
  800702:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800705:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'i':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800708:	e9 cd fe ff ff       	jmp    8005da <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80070d:	52                   	push   %edx
  80070e:	68 48 21 80 00       	push   $0x802148
  800713:	53                   	push   %ebx
  800714:	56                   	push   %esi
  800715:	e8 7d fe ff ff       	call   800597 <printfmt>
  80071a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800720:	e9 b5 fe ff ff       	jmp    8005da <vprintfmt+0x26>
  800725:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800728:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80072b:	89 45 cc             	mov    %eax,-0x34(%ebp)
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8d 50 04             	lea    0x4(%eax),%edx
  800734:	89 55 14             	mov    %edx,0x14(%ebp)
  800737:	8b 38                	mov    (%eax),%edi
  800739:	85 ff                	test   %edi,%edi
  80073b:	75 05                	jne    800742 <vprintfmt+0x18e>
				p = "(null)";
  80073d:	bf c0 21 80 00       	mov    $0x8021c0,%edi
			if (width > 0 && padc != '-')
  800742:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800746:	0f 84 91 00 00 00    	je     8007dd <vprintfmt+0x229>
  80074c:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800750:	0f 8e 95 00 00 00    	jle    8007eb <vprintfmt+0x237>
				for (width -= strnlen(p, precision); width > 0; width--)
  800756:	83 ec 08             	sub    $0x8,%esp
  800759:	51                   	push   %ecx
  80075a:	57                   	push   %edi
  80075b:	e8 85 02 00 00       	call   8009e5 <strnlen>
  800760:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800763:	29 c1                	sub    %eax,%ecx
  800765:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800768:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80076b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80076f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800772:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800775:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800777:	eb 0f                	jmp    800788 <vprintfmt+0x1d4>
					putch(padc, putdat);
  800779:	83 ec 08             	sub    $0x8,%esp
  80077c:	53                   	push   %ebx
  80077d:	ff 75 e0             	pushl  -0x20(%ebp)
  800780:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800782:	83 ef 01             	sub    $0x1,%edi
  800785:	83 c4 10             	add    $0x10,%esp
  800788:	85 ff                	test   %edi,%edi
  80078a:	7f ed                	jg     800779 <vprintfmt+0x1c5>
  80078c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80078f:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800792:	89 c8                	mov    %ecx,%eax
  800794:	c1 f8 1f             	sar    $0x1f,%eax
  800797:	f7 d0                	not    %eax
  800799:	21 c8                	and    %ecx,%eax
  80079b:	29 c1                	sub    %eax,%ecx
  80079d:	89 75 08             	mov    %esi,0x8(%ebp)
  8007a0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007a3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007a6:	89 cb                	mov    %ecx,%ebx
  8007a8:	eb 4d                	jmp    8007f7 <vprintfmt+0x243>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8007aa:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8007ae:	74 1b                	je     8007cb <vprintfmt+0x217>
  8007b0:	0f be c0             	movsbl %al,%eax
  8007b3:	83 e8 20             	sub    $0x20,%eax
  8007b6:	83 f8 5e             	cmp    $0x5e,%eax
  8007b9:	76 10                	jbe    8007cb <vprintfmt+0x217>
					putch('?', putdat);
  8007bb:	83 ec 08             	sub    $0x8,%esp
  8007be:	ff 75 0c             	pushl  0xc(%ebp)
  8007c1:	6a 3f                	push   $0x3f
  8007c3:	ff 55 08             	call   *0x8(%ebp)
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	eb 0d                	jmp    8007d8 <vprintfmt+0x224>
				else
					putch(ch, putdat);
  8007cb:	83 ec 08             	sub    $0x8,%esp
  8007ce:	ff 75 0c             	pushl  0xc(%ebp)
  8007d1:	52                   	push   %edx
  8007d2:	ff 55 08             	call   *0x8(%ebp)
  8007d5:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8007d8:	83 eb 01             	sub    $0x1,%ebx
  8007db:	eb 1a                	jmp    8007f7 <vprintfmt+0x243>
  8007dd:	89 75 08             	mov    %esi,0x8(%ebp)
  8007e0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007e3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007e6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007e9:	eb 0c                	jmp    8007f7 <vprintfmt+0x243>
  8007eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8007ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8007f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8007f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8007f7:	83 c7 01             	add    $0x1,%edi
  8007fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007fe:	0f be d0             	movsbl %al,%edx
  800801:	85 d2                	test   %edx,%edx
  800803:	74 23                	je     800828 <vprintfmt+0x274>
  800805:	85 f6                	test   %esi,%esi
  800807:	78 a1                	js     8007aa <vprintfmt+0x1f6>
  800809:	83 ee 01             	sub    $0x1,%esi
  80080c:	79 9c                	jns    8007aa <vprintfmt+0x1f6>
  80080e:	89 df                	mov    %ebx,%edi
  800810:	8b 75 08             	mov    0x8(%ebp),%esi
  800813:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800816:	eb 18                	jmp    800830 <vprintfmt+0x27c>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	6a 20                	push   $0x20
  80081e:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800820:	83 ef 01             	sub    $0x1,%edi
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	eb 08                	jmp    800830 <vprintfmt+0x27c>
  800828:	89 df                	mov    %ebx,%edi
  80082a:	8b 75 08             	mov    0x8(%ebp),%esi
  80082d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800830:	85 ff                	test   %edi,%edi
  800832:	7f e4                	jg     800818 <vprintfmt+0x264>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800834:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800837:	e9 9e fd ff ff       	jmp    8005da <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80083c:	83 fa 01             	cmp    $0x1,%edx
  80083f:	7e 16                	jle    800857 <vprintfmt+0x2a3>
		return va_arg(*ap, long long);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8d 50 08             	lea    0x8(%eax),%edx
  800847:	89 55 14             	mov    %edx,0x14(%ebp)
  80084a:	8b 50 04             	mov    0x4(%eax),%edx
  80084d:	8b 00                	mov    (%eax),%eax
  80084f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800852:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800855:	eb 32                	jmp    800889 <vprintfmt+0x2d5>
	else if (lflag)
  800857:	85 d2                	test   %edx,%edx
  800859:	74 18                	je     800873 <vprintfmt+0x2bf>
		return va_arg(*ap, long);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8d 50 04             	lea    0x4(%eax),%edx
  800861:	89 55 14             	mov    %edx,0x14(%ebp)
  800864:	8b 00                	mov    (%eax),%eax
  800866:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800869:	89 c1                	mov    %eax,%ecx
  80086b:	c1 f9 1f             	sar    $0x1f,%ecx
  80086e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800871:	eb 16                	jmp    800889 <vprintfmt+0x2d5>
	else
		return va_arg(*ap, int);
  800873:	8b 45 14             	mov    0x14(%ebp),%eax
  800876:	8d 50 04             	lea    0x4(%eax),%edx
  800879:	89 55 14             	mov    %edx,0x14(%ebp)
  80087c:	8b 00                	mov    (%eax),%eax
  80087e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800881:	89 c1                	mov    %eax,%ecx
  800883:	c1 f9 1f             	sar    $0x1f,%ecx
  800886:	89 4d dc             	mov    %ecx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800889:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80088c:	8b 55 dc             	mov    -0x24(%ebp),%edx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80088f:	b9 0a 00 00 00       	mov    $0xa,%ecx
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800894:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800898:	79 74                	jns    80090e <vprintfmt+0x35a>
				putch('-', putdat);
  80089a:	83 ec 08             	sub    $0x8,%esp
  80089d:	53                   	push   %ebx
  80089e:	6a 2d                	push   $0x2d
  8008a0:	ff d6                	call   *%esi
				num = -(long long) num;
  8008a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8008a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8008a8:	f7 d8                	neg    %eax
  8008aa:	83 d2 00             	adc    $0x0,%edx
  8008ad:	f7 da                	neg    %edx
  8008af:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8008b2:	b9 0a 00 00 00       	mov    $0xa,%ecx
  8008b7:	eb 55                	jmp    80090e <vprintfmt+0x35a>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8008b9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008bc:	e8 7f fc ff ff       	call   800540 <getuint>
			base = 10;
  8008c1:	b9 0a 00 00 00       	mov    $0xa,%ecx
			goto number;
  8008c6:	eb 46                	jmp    80090e <vprintfmt+0x35a>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
  8008c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8008cb:	e8 70 fc ff ff       	call   800540 <getuint>
			base = 8;
  8008d0:	b9 08 00 00 00       	mov    $0x8,%ecx
			goto number;
  8008d5:	eb 37                	jmp    80090e <vprintfmt+0x35a>

		// pointer
		case 'p':
			putch('0', putdat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	53                   	push   %ebx
  8008db:	6a 30                	push   $0x30
  8008dd:	ff d6                	call   *%esi
			putch('x', putdat);
  8008df:	83 c4 08             	add    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	6a 78                	push   $0x78
  8008e5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ea:	8d 50 04             	lea    0x4(%eax),%edx
  8008ed:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8008f0:	8b 00                	mov    (%eax),%eax
  8008f2:	ba 00 00 00 00       	mov    $0x0,%edx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008f7:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008fa:	b9 10 00 00 00       	mov    $0x10,%ecx
			goto number;
  8008ff:	eb 0d                	jmp    80090e <vprintfmt+0x35a>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800901:	8d 45 14             	lea    0x14(%ebp),%eax
  800904:	e8 37 fc ff ff       	call   800540 <getuint>
			base = 16;
  800909:	b9 10 00 00 00       	mov    $0x10,%ecx
		number:
			printnum(putch, putdat, num, base, width, padc);
  80090e:	83 ec 0c             	sub    $0xc,%esp
  800911:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800915:	57                   	push   %edi
  800916:	ff 75 e0             	pushl  -0x20(%ebp)
  800919:	51                   	push   %ecx
  80091a:	52                   	push   %edx
  80091b:	50                   	push   %eax
  80091c:	89 da                	mov    %ebx,%edx
  80091e:	89 f0                	mov    %esi,%eax
  800920:	e8 71 fb ff ff       	call   800496 <printnum>
			break;
  800925:	83 c4 20             	add    $0x20,%esp
  800928:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092b:	e9 aa fc ff ff       	jmp    8005da <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800930:	83 ec 08             	sub    $0x8,%esp
  800933:	53                   	push   %ebx
  800934:	51                   	push   %ecx
  800935:	ff d6                	call   *%esi
			break;
  800937:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80093a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80093d:	e9 98 fc ff ff       	jmp    8005da <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800942:	83 ec 08             	sub    $0x8,%esp
  800945:	53                   	push   %ebx
  800946:	6a 25                	push   $0x25
  800948:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	eb 03                	jmp    800952 <vprintfmt+0x39e>
  80094f:	83 ef 01             	sub    $0x1,%edi
  800952:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800956:	75 f7                	jne    80094f <vprintfmt+0x39b>
  800958:	e9 7d fc ff ff       	jmp    8005da <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80095d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	83 ec 18             	sub    $0x18,%esp
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800971:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800974:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800978:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80097b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800982:	85 c0                	test   %eax,%eax
  800984:	74 26                	je     8009ac <vsnprintf+0x47>
  800986:	85 d2                	test   %edx,%edx
  800988:	7e 22                	jle    8009ac <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098a:	ff 75 14             	pushl  0x14(%ebp)
  80098d:	ff 75 10             	pushl  0x10(%ebp)
  800990:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800993:	50                   	push   %eax
  800994:	68 7a 05 80 00       	push   $0x80057a
  800999:	e8 16 fc ff ff       	call   8005b4 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80099e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009a1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	eb 05                	jmp    8009b1 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8009ac:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8009b1:	c9                   	leave  
  8009b2:	c3                   	ret    

008009b3 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b3:	55                   	push   %ebp
  8009b4:	89 e5                	mov    %esp,%ebp
  8009b6:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009b9:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009bc:	50                   	push   %eax
  8009bd:	ff 75 10             	pushl  0x10(%ebp)
  8009c0:	ff 75 0c             	pushl  0xc(%ebp)
  8009c3:	ff 75 08             	pushl  0x8(%ebp)
  8009c6:	e8 9a ff ff ff       	call   800965 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009cb:	c9                   	leave  
  8009cc:	c3                   	ret    

008009cd <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d8:	eb 03                	jmp    8009dd <strlen+0x10>
		n++;
  8009da:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009dd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009e1:	75 f7                	jne    8009da <strlen+0xd>
		n++;
	return n;
}
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f3:	eb 03                	jmp    8009f8 <strnlen+0x13>
		n++;
  8009f5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009f8:	39 c2                	cmp    %eax,%edx
  8009fa:	74 08                	je     800a04 <strnlen+0x1f>
  8009fc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800a00:	75 f3                	jne    8009f5 <strnlen+0x10>
  800a02:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	53                   	push   %ebx
  800a0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a10:	89 c2                	mov    %eax,%edx
  800a12:	83 c2 01             	add    $0x1,%edx
  800a15:	83 c1 01             	add    $0x1,%ecx
  800a18:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a1c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a1f:	84 db                	test   %bl,%bl
  800a21:	75 ef                	jne    800a12 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a23:	5b                   	pop    %ebx
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	53                   	push   %ebx
  800a2a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a2d:	53                   	push   %ebx
  800a2e:	e8 9a ff ff ff       	call   8009cd <strlen>
  800a33:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a36:	ff 75 0c             	pushl  0xc(%ebp)
  800a39:	01 d8                	add    %ebx,%eax
  800a3b:	50                   	push   %eax
  800a3c:	e8 c5 ff ff ff       	call   800a06 <strcpy>
	return dst;
}
  800a41:	89 d8                	mov    %ebx,%eax
  800a43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a46:	c9                   	leave  
  800a47:	c3                   	ret    

00800a48 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a53:	89 f3                	mov    %esi,%ebx
  800a55:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a58:	89 f2                	mov    %esi,%edx
  800a5a:	eb 0f                	jmp    800a6b <strncpy+0x23>
		*dst++ = *src;
  800a5c:	83 c2 01             	add    $0x1,%edx
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a65:	80 39 01             	cmpb   $0x1,(%ecx)
  800a68:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a6b:	39 da                	cmp    %ebx,%edx
  800a6d:	75 ed                	jne    800a5c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a6f:	89 f0                	mov    %esi,%eax
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5d                   	pop    %ebp
  800a74:	c3                   	ret    

00800a75 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a75:	55                   	push   %ebp
  800a76:	89 e5                	mov    %esp,%ebp
  800a78:	56                   	push   %esi
  800a79:	53                   	push   %ebx
  800a7a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a80:	8b 55 10             	mov    0x10(%ebp),%edx
  800a83:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a85:	85 d2                	test   %edx,%edx
  800a87:	74 21                	je     800aaa <strlcpy+0x35>
  800a89:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a8d:	89 f2                	mov    %esi,%edx
  800a8f:	eb 09                	jmp    800a9a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a91:	83 c2 01             	add    $0x1,%edx
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a9a:	39 c2                	cmp    %eax,%edx
  800a9c:	74 09                	je     800aa7 <strlcpy+0x32>
  800a9e:	0f b6 19             	movzbl (%ecx),%ebx
  800aa1:	84 db                	test   %bl,%bl
  800aa3:	75 ec                	jne    800a91 <strlcpy+0x1c>
  800aa5:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800aa7:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800aaa:	29 f0                	sub    %esi,%eax
}
  800aac:	5b                   	pop    %ebx
  800aad:	5e                   	pop    %esi
  800aae:	5d                   	pop    %ebp
  800aaf:	c3                   	ret    

00800ab0 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ab6:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800ab9:	eb 06                	jmp    800ac1 <strcmp+0x11>
		p++, q++;
  800abb:	83 c1 01             	add    $0x1,%ecx
  800abe:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ac1:	0f b6 01             	movzbl (%ecx),%eax
  800ac4:	84 c0                	test   %al,%al
  800ac6:	74 04                	je     800acc <strcmp+0x1c>
  800ac8:	3a 02                	cmp    (%edx),%al
  800aca:	74 ef                	je     800abb <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800acc:	0f b6 c0             	movzbl %al,%eax
  800acf:	0f b6 12             	movzbl (%edx),%edx
  800ad2:	29 d0                	sub    %edx,%eax
}
  800ad4:	5d                   	pop    %ebp
  800ad5:	c3                   	ret    

00800ad6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	53                   	push   %ebx
  800ada:	8b 45 08             	mov    0x8(%ebp),%eax
  800add:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae0:	89 c3                	mov    %eax,%ebx
  800ae2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ae5:	eb 06                	jmp    800aed <strncmp+0x17>
		n--, p++, q++;
  800ae7:	83 c0 01             	add    $0x1,%eax
  800aea:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aed:	39 d8                	cmp    %ebx,%eax
  800aef:	74 15                	je     800b06 <strncmp+0x30>
  800af1:	0f b6 08             	movzbl (%eax),%ecx
  800af4:	84 c9                	test   %cl,%cl
  800af6:	74 04                	je     800afc <strncmp+0x26>
  800af8:	3a 0a                	cmp    (%edx),%cl
  800afa:	74 eb                	je     800ae7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800afc:	0f b6 00             	movzbl (%eax),%eax
  800aff:	0f b6 12             	movzbl (%edx),%edx
  800b02:	29 d0                	sub    %edx,%eax
  800b04:	eb 05                	jmp    800b0b <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	8b 45 08             	mov    0x8(%ebp),%eax
  800b14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b18:	eb 07                	jmp    800b21 <strchr+0x13>
		if (*s == c)
  800b1a:	38 ca                	cmp    %cl,%dl
  800b1c:	74 0f                	je     800b2d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b1e:	83 c0 01             	add    $0x1,%eax
  800b21:	0f b6 10             	movzbl (%eax),%edx
  800b24:	84 d2                	test   %dl,%dl
  800b26:	75 f2                	jne    800b1a <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b39:	eb 03                	jmp    800b3e <strfind+0xf>
  800b3b:	83 c0 01             	add    $0x1,%eax
  800b3e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b41:	84 d2                	test   %dl,%dl
  800b43:	74 04                	je     800b49 <strfind+0x1a>
  800b45:	38 ca                	cmp    %cl,%dl
  800b47:	75 f2                	jne    800b3b <strfind+0xc>
			break;
	return (char *) s;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b54:	8b 4d 10             	mov    0x10(%ebp),%ecx
	if (n == 0)
  800b57:	85 c9                	test   %ecx,%ecx
  800b59:	74 36                	je     800b91 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b5b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b61:	75 28                	jne    800b8b <memset+0x40>
  800b63:	f6 c1 03             	test   $0x3,%cl
  800b66:	75 23                	jne    800b8b <memset+0x40>
		c &= 0xFF;
  800b68:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b6c:	89 d3                	mov    %edx,%ebx
  800b6e:	c1 e3 08             	shl    $0x8,%ebx
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	c1 e6 18             	shl    $0x18,%esi
  800b76:	89 d0                	mov    %edx,%eax
  800b78:	c1 e0 10             	shl    $0x10,%eax
  800b7b:	09 f0                	or     %esi,%eax
  800b7d:	09 c2                	or     %eax,%edx
  800b7f:	89 d0                	mov    %edx,%eax
  800b81:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b83:	c1 e9 02             	shr    $0x2,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800b86:	fc                   	cld    
  800b87:	f3 ab                	rep stos %eax,%es:(%edi)
  800b89:	eb 06                	jmp    800b91 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8e:	fc                   	cld    
  800b8f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b91:	89 f8                	mov    %edi,%eax
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5f                   	pop    %edi
  800b96:	5d                   	pop    %ebp
  800b97:	c3                   	ret    

00800b98 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	57                   	push   %edi
  800b9c:	56                   	push   %esi
  800b9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ba3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ba6:	39 c6                	cmp    %eax,%esi
  800ba8:	73 35                	jae    800bdf <memmove+0x47>
  800baa:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800bad:	39 d0                	cmp    %edx,%eax
  800baf:	73 2e                	jae    800bdf <memmove+0x47>
		s += n;
		d += n;
  800bb1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	09 fe                	or     %edi,%esi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb8:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bbe:	75 13                	jne    800bd3 <memmove+0x3b>
  800bc0:	f6 c1 03             	test   $0x3,%cl
  800bc3:	75 0e                	jne    800bd3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bc5:	83 ef 04             	sub    $0x4,%edi
  800bc8:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bcb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800bce:	fd                   	std    
  800bcf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd1:	eb 09                	jmp    800bdc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bd3:	83 ef 01             	sub    $0x1,%edi
  800bd6:	8d 72 ff             	lea    -0x1(%edx),%esi
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bd9:	fd                   	std    
  800bda:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bdc:	fc                   	cld    
  800bdd:	eb 1d                	jmp    800bfc <memmove+0x64>
  800bdf:	89 f2                	mov    %esi,%edx
  800be1:	09 c2                	or     %eax,%edx
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800be3:	f6 c2 03             	test   $0x3,%dl
  800be6:	75 0f                	jne    800bf7 <memmove+0x5f>
  800be8:	f6 c1 03             	test   $0x3,%cl
  800beb:	75 0a                	jne    800bf7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bed:	c1 e9 02             	shr    $0x2,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800bf0:	89 c7                	mov    %eax,%edi
  800bf2:	fc                   	cld    
  800bf3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bf5:	eb 05                	jmp    800bfc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bf7:	89 c7                	mov    %eax,%edi
  800bf9:	fc                   	cld    
  800bfa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bfc:	5e                   	pop    %esi
  800bfd:	5f                   	pop    %edi
  800bfe:	5d                   	pop    %ebp
  800bff:	c3                   	ret    

00800c00 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800c03:	ff 75 10             	pushl  0x10(%ebp)
  800c06:	ff 75 0c             	pushl  0xc(%ebp)
  800c09:	ff 75 08             	pushl  0x8(%ebp)
  800c0c:	e8 87 ff ff ff       	call   800b98 <memmove>
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1e:	89 c6                	mov    %eax,%esi
  800c20:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c23:	eb 1a                	jmp    800c3f <memcmp+0x2c>
		if (*s1 != *s2)
  800c25:	0f b6 08             	movzbl (%eax),%ecx
  800c28:	0f b6 1a             	movzbl (%edx),%ebx
  800c2b:	38 d9                	cmp    %bl,%cl
  800c2d:	74 0a                	je     800c39 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c2f:	0f b6 c1             	movzbl %cl,%eax
  800c32:	0f b6 db             	movzbl %bl,%ebx
  800c35:	29 d8                	sub    %ebx,%eax
  800c37:	eb 0f                	jmp    800c48 <memcmp+0x35>
		s1++, s2++;
  800c39:	83 c0 01             	add    $0x1,%eax
  800c3c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c3f:	39 f0                	cmp    %esi,%eax
  800c41:	75 e2                	jne    800c25 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c43:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c55:	89 c2                	mov    %eax,%edx
  800c57:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c5a:	eb 07                	jmp    800c63 <memfind+0x17>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c5c:	38 08                	cmp    %cl,(%eax)
  800c5e:	74 07                	je     800c67 <memfind+0x1b>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c60:	83 c0 01             	add    $0x1,%eax
  800c63:	39 d0                	cmp    %edx,%eax
  800c65:	72 f5                	jb     800c5c <memfind+0x10>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c67:	5d                   	pop    %ebp
  800c68:	c3                   	ret    

00800c69 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c69:	55                   	push   %ebp
  800c6a:	89 e5                	mov    %esp,%ebp
  800c6c:	57                   	push   %edi
  800c6d:	56                   	push   %esi
  800c6e:	53                   	push   %ebx
  800c6f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c75:	eb 03                	jmp    800c7a <strtol+0x11>
		s++;
  800c77:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c7a:	0f b6 01             	movzbl (%ecx),%eax
  800c7d:	3c 09                	cmp    $0x9,%al
  800c7f:	74 f6                	je     800c77 <strtol+0xe>
  800c81:	3c 20                	cmp    $0x20,%al
  800c83:	74 f2                	je     800c77 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c85:	3c 2b                	cmp    $0x2b,%al
  800c87:	75 0a                	jne    800c93 <strtol+0x2a>
		s++;
  800c89:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c8c:	bf 00 00 00 00       	mov    $0x0,%edi
  800c91:	eb 10                	jmp    800ca3 <strtol+0x3a>
  800c93:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c98:	3c 2d                	cmp    $0x2d,%al
  800c9a:	75 07                	jne    800ca3 <strtol+0x3a>
		s++, neg = 1;
  800c9c:	8d 49 01             	lea    0x1(%ecx),%ecx
  800c9f:	66 bf 01 00          	mov    $0x1,%di

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca3:	85 db                	test   %ebx,%ebx
  800ca5:	0f 94 c0             	sete   %al
  800ca8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cae:	75 19                	jne    800cc9 <strtol+0x60>
  800cb0:	80 39 30             	cmpb   $0x30,(%ecx)
  800cb3:	75 14                	jne    800cc9 <strtol+0x60>
  800cb5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800cb9:	0f 85 8a 00 00 00    	jne    800d49 <strtol+0xe0>
		s += 2, base = 16;
  800cbf:	83 c1 02             	add    $0x2,%ecx
  800cc2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cc7:	eb 16                	jmp    800cdf <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800cc9:	84 c0                	test   %al,%al
  800ccb:	74 12                	je     800cdf <strtol+0x76>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ccd:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cd2:	80 39 30             	cmpb   $0x30,(%ecx)
  800cd5:	75 08                	jne    800cdf <strtol+0x76>
		s++, base = 8;
  800cd7:	83 c1 01             	add    $0x1,%ecx
  800cda:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce4:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce7:	0f b6 11             	movzbl (%ecx),%edx
  800cea:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ced:	89 f3                	mov    %esi,%ebx
  800cef:	80 fb 09             	cmp    $0x9,%bl
  800cf2:	77 08                	ja     800cfc <strtol+0x93>
			dig = *s - '0';
  800cf4:	0f be d2             	movsbl %dl,%edx
  800cf7:	83 ea 30             	sub    $0x30,%edx
  800cfa:	eb 22                	jmp    800d1e <strtol+0xb5>
		else if (*s >= 'a' && *s <= 'z')
  800cfc:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cff:	89 f3                	mov    %esi,%ebx
  800d01:	80 fb 19             	cmp    $0x19,%bl
  800d04:	77 08                	ja     800d0e <strtol+0xa5>
			dig = *s - 'a' + 10;
  800d06:	0f be d2             	movsbl %dl,%edx
  800d09:	83 ea 57             	sub    $0x57,%edx
  800d0c:	eb 10                	jmp    800d1e <strtol+0xb5>
		else if (*s >= 'A' && *s <= 'Z')
  800d0e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d11:	89 f3                	mov    %esi,%ebx
  800d13:	80 fb 19             	cmp    $0x19,%bl
  800d16:	77 16                	ja     800d2e <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d18:	0f be d2             	movsbl %dl,%edx
  800d1b:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d1e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d21:	7d 0f                	jge    800d32 <strtol+0xc9>
			break;
		s++, val = (val * base) + dig;
  800d23:	83 c1 01             	add    $0x1,%ecx
  800d26:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d2a:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d2c:	eb b9                	jmp    800ce7 <strtol+0x7e>
  800d2e:	89 c2                	mov    %eax,%edx
  800d30:	eb 02                	jmp    800d34 <strtol+0xcb>
  800d32:	89 c2                	mov    %eax,%edx

	if (endptr)
  800d34:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d38:	74 05                	je     800d3f <strtol+0xd6>
		*endptr = (char *) s;
  800d3a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d3d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d3f:	85 ff                	test   %edi,%edi
  800d41:	74 0c                	je     800d4f <strtol+0xe6>
  800d43:	89 d0                	mov    %edx,%eax
  800d45:	f7 d8                	neg    %eax
  800d47:	eb 06                	jmp    800d4f <strtol+0xe6>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d49:	84 c0                	test   %al,%al
  800d4b:	75 8a                	jne    800cd7 <strtol+0x6e>
  800d4d:	eb 90                	jmp    800cdf <strtol+0x76>
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 c3                	mov    %eax,%ebx
  800d67:	89 c7                	mov    %eax,%edi
  800d69:	89 c6                	mov    %eax,%esi
  800d6b:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d6d:	5b                   	pop    %ebx
  800d6e:	5e                   	pop    %esi
  800d6f:	5f                   	pop    %edi
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	57                   	push   %edi
  800d76:	56                   	push   %esi
  800d77:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d78:	ba 00 00 00 00       	mov    $0x0,%edx
  800d7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800d82:	89 d1                	mov    %edx,%ecx
  800d84:	89 d3                	mov    %edx,%ebx
  800d86:	89 d7                	mov    %edx,%edi
  800d88:	89 d6                	mov    %edx,%esi
  800d8a:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	57                   	push   %edi
  800d95:	56                   	push   %esi
  800d96:	53                   	push   %ebx
  800d97:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d9a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9f:	b8 03 00 00 00       	mov    $0x3,%eax
  800da4:	8b 55 08             	mov    0x8(%ebp),%edx
  800da7:	89 cb                	mov    %ecx,%ebx
  800da9:	89 cf                	mov    %ecx,%edi
  800dab:	89 ce                	mov    %ecx,%esi
  800dad:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800daf:	85 c0                	test   %eax,%eax
  800db1:	7e 17                	jle    800dca <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	50                   	push   %eax
  800db7:	6a 03                	push   $0x3
  800db9:	68 df 24 80 00       	push   $0x8024df
  800dbe:	6a 23                	push   $0x23
  800dc0:	68 fc 24 80 00       	push   $0x8024fc
  800dc5:	e8 df f5 ff ff       	call   8003a9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    

00800dd2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddd:	b8 02 00 00 00       	mov    $0x2,%eax
  800de2:	89 d1                	mov    %edx,%ecx
  800de4:	89 d3                	mov    %edx,%ebx
  800de6:	89 d7                	mov    %edx,%edi
  800de8:	89 d6                	mov    %edx,%esi
  800dea:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <sys_yield>:

void
sys_yield(void)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800df7:	ba 00 00 00 00       	mov    $0x0,%edx
  800dfc:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e01:	89 d1                	mov    %edx,%ecx
  800e03:	89 d3                	mov    %edx,%ebx
  800e05:	89 d7                	mov    %edx,%edi
  800e07:	89 d6                	mov    %edx,%esi
  800e09:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
  800e16:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e19:	be 00 00 00 00       	mov    $0x0,%esi
  800e1e:	b8 04 00 00 00       	mov    $0x4,%eax
  800e23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e26:	8b 55 08             	mov    0x8(%ebp),%edx
  800e29:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2c:	89 f7                	mov    %esi,%edi
  800e2e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7e 17                	jle    800e4b <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e34:	83 ec 0c             	sub    $0xc,%esp
  800e37:	50                   	push   %eax
  800e38:	6a 04                	push   $0x4
  800e3a:	68 df 24 80 00       	push   $0x8024df
  800e3f:	6a 23                	push   $0x23
  800e41:	68 fc 24 80 00       	push   $0x8024fc
  800e46:	e8 5e f5 ff ff       	call   8003a9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4e:	5b                   	pop    %ebx
  800e4f:	5e                   	pop    %esi
  800e50:	5f                   	pop    %edi
  800e51:	5d                   	pop    %ebp
  800e52:	c3                   	ret    

00800e53 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5c:	b8 05 00 00 00       	mov    $0x5,%eax
  800e61:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e64:	8b 55 08             	mov    0x8(%ebp),%edx
  800e67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6d:	8b 75 18             	mov    0x18(%ebp),%esi
  800e70:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7e 17                	jle    800e8d <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e76:	83 ec 0c             	sub    $0xc,%esp
  800e79:	50                   	push   %eax
  800e7a:	6a 05                	push   $0x5
  800e7c:	68 df 24 80 00       	push   $0x8024df
  800e81:	6a 23                	push   $0x23
  800e83:	68 fc 24 80 00       	push   $0x8024fc
  800e88:	e8 1c f5 ff ff       	call   8003a9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e8d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e90:	5b                   	pop    %ebx
  800e91:	5e                   	pop    %esi
  800e92:	5f                   	pop    %edi
  800e93:	5d                   	pop    %ebp
  800e94:	c3                   	ret    

00800e95 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	57                   	push   %edi
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
  800e9b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ea8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eab:	8b 55 08             	mov    0x8(%ebp),%edx
  800eae:	89 df                	mov    %ebx,%edi
  800eb0:	89 de                	mov    %ebx,%esi
  800eb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	7e 17                	jle    800ecf <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	50                   	push   %eax
  800ebc:	6a 06                	push   $0x6
  800ebe:	68 df 24 80 00       	push   $0x8024df
  800ec3:	6a 23                	push   $0x23
  800ec5:	68 fc 24 80 00       	push   $0x8024fc
  800eca:	e8 da f4 ff ff       	call   8003a9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ecf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed2:	5b                   	pop    %ebx
  800ed3:	5e                   	pop    %esi
  800ed4:	5f                   	pop    %edi
  800ed5:	5d                   	pop    %ebp
  800ed6:	c3                   	ret    

00800ed7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee5:	b8 08 00 00 00       	mov    $0x8,%eax
  800eea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eed:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef0:	89 df                	mov    %ebx,%edi
  800ef2:	89 de                	mov    %ebx,%esi
  800ef4:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	7e 17                	jle    800f11 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efa:	83 ec 0c             	sub    $0xc,%esp
  800efd:	50                   	push   %eax
  800efe:	6a 08                	push   $0x8
  800f00:	68 df 24 80 00       	push   $0x8024df
  800f05:	6a 23                	push   $0x23
  800f07:	68 fc 24 80 00       	push   $0x8024fc
  800f0c:	e8 98 f4 ff ff       	call   8003a9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800f11:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5f                   	pop    %edi
  800f17:	5d                   	pop    %ebp
  800f18:	c3                   	ret    

00800f19 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f19:	55                   	push   %ebp
  800f1a:	89 e5                	mov    %esp,%ebp
  800f1c:	57                   	push   %edi
  800f1d:	56                   	push   %esi
  800f1e:	53                   	push   %ebx
  800f1f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f27:	b8 09 00 00 00       	mov    $0x9,%eax
  800f2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f32:	89 df                	mov    %ebx,%edi
  800f34:	89 de                	mov    %ebx,%esi
  800f36:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f38:	85 c0                	test   %eax,%eax
  800f3a:	7e 17                	jle    800f53 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f3c:	83 ec 0c             	sub    $0xc,%esp
  800f3f:	50                   	push   %eax
  800f40:	6a 09                	push   $0x9
  800f42:	68 df 24 80 00       	push   $0x8024df
  800f47:	6a 23                	push   $0x23
  800f49:	68 fc 24 80 00       	push   $0x8024fc
  800f4e:	e8 56 f4 ff ff       	call   8003a9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f56:	5b                   	pop    %ebx
  800f57:	5e                   	pop    %esi
  800f58:	5f                   	pop    %edi
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	57                   	push   %edi
  800f5f:	56                   	push   %esi
  800f60:	53                   	push   %ebx
  800f61:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f64:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f6e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f71:	8b 55 08             	mov    0x8(%ebp),%edx
  800f74:	89 df                	mov    %ebx,%edi
  800f76:	89 de                	mov    %ebx,%esi
  800f78:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	7e 17                	jle    800f95 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	50                   	push   %eax
  800f82:	6a 0a                	push   $0xa
  800f84:	68 df 24 80 00       	push   $0x8024df
  800f89:	6a 23                	push   $0x23
  800f8b:	68 fc 24 80 00       	push   $0x8024fc
  800f90:	e8 14 f4 ff ff       	call   8003a9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f98:	5b                   	pop    %ebx
  800f99:	5e                   	pop    %esi
  800f9a:	5f                   	pop    %edi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    

00800f9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fa3:	be 00 00 00 00       	mov    $0x0,%esi
  800fa8:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fb6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800fb9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    

00800fc0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	57                   	push   %edi
  800fc4:	56                   	push   %esi
  800fc5:	53                   	push   %ebx
  800fc6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fce:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fd3:	8b 55 08             	mov    0x8(%ebp),%edx
  800fd6:	89 cb                	mov    %ecx,%ebx
  800fd8:	89 cf                	mov    %ecx,%edi
  800fda:	89 ce                	mov    %ecx,%esi
  800fdc:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fde:	85 c0                	test   %eax,%eax
  800fe0:	7e 17                	jle    800ff9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	50                   	push   %eax
  800fe6:	6a 0d                	push   $0xd
  800fe8:	68 df 24 80 00       	push   $0x8024df
  800fed:	6a 23                	push   $0x23
  800fef:	68 fc 24 80 00       	push   $0x8024fc
  800ff4:	e8 b0 f3 ff ff       	call   8003a9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800ff9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ffc:	5b                   	pop    %ebx
  800ffd:	5e                   	pop    %esi
  800ffe:	5f                   	pop    %edi
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <sys_gettime>:

int sys_gettime(void)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	57                   	push   %edi
  801005:	56                   	push   %esi
  801006:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801007:	ba 00 00 00 00       	mov    $0x0,%edx
  80100c:	b8 0e 00 00 00       	mov    $0xe,%eax
  801011:	89 d1                	mov    %edx,%ecx
  801013:	89 d3                	mov    %edx,%ebx
  801015:	89 d7                	mov    %edx,%edi
  801017:	89 d6                	mov    %edx,%esi
  801019:	cd 30                	int    $0x30
}

int sys_gettime(void)
{
	return syscall(SYS_gettime, 0, 0, 0, 0, 0, 0);
  80101b:	5b                   	pop    %ebx
  80101c:	5e                   	pop    %esi
  80101d:	5f                   	pop    %edi
  80101e:	5d                   	pop    %ebp
  80101f:	c3                   	ret    

00801020 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
  801026:	05 00 00 00 30       	add    $0x30000000,%eax
  80102b:	c1 e8 0c             	shr    $0xc,%eax
}
  80102e:	5d                   	pop    %ebp
  80102f:	c3                   	ret    

00801030 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
}

char*
fd2data(struct Fd *fd)
{
	return INDEX2DATA(fd2num(fd));
  80103b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801040:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801045:	5d                   	pop    %ebp
  801046:	c3                   	ret    

00801047 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801052:	89 c2                	mov    %eax,%edx
  801054:	c1 ea 16             	shr    $0x16,%edx
  801057:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80105e:	f6 c2 01             	test   $0x1,%dl
  801061:	74 11                	je     801074 <fd_alloc+0x2d>
  801063:	89 c2                	mov    %eax,%edx
  801065:	c1 ea 0c             	shr    $0xc,%edx
  801068:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80106f:	f6 c2 01             	test   $0x1,%dl
  801072:	75 09                	jne    80107d <fd_alloc+0x36>
			*fd_store = fd;
  801074:	89 01                	mov    %eax,(%ecx)
			return 0;
  801076:	b8 00 00 00 00       	mov    $0x0,%eax
  80107b:	eb 17                	jmp    801094 <fd_alloc+0x4d>
  80107d:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801082:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801087:	75 c9                	jne    801052 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801089:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  80108f:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    

00801096 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80109c:	83 f8 1f             	cmp    $0x1f,%eax
  80109f:	77 36                	ja     8010d7 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a1:	c1 e0 0c             	shl    $0xc,%eax
  8010a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010a9:	89 c2                	mov    %eax,%edx
  8010ab:	c1 ea 16             	shr    $0x16,%edx
  8010ae:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b5:	f6 c2 01             	test   $0x1,%dl
  8010b8:	74 24                	je     8010de <fd_lookup+0x48>
  8010ba:	89 c2                	mov    %eax,%edx
  8010bc:	c1 ea 0c             	shr    $0xc,%edx
  8010bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010c6:	f6 c2 01             	test   $0x1,%dl
  8010c9:	74 1a                	je     8010e5 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8010d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d5:	eb 13                	jmp    8010ea <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010dc:	eb 0c                	jmp    8010ea <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e3:	eb 05                	jmp    8010ea <fd_lookup+0x54>
  8010e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    

008010ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010f5:	ba 88 25 80 00       	mov    $0x802588,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010fa:	eb 13                	jmp    80110f <dev_lookup+0x23>
  8010fc:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  8010ff:	39 08                	cmp    %ecx,(%eax)
  801101:	75 0c                	jne    80110f <dev_lookup+0x23>
			*dev = devtab[i];
  801103:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801106:	89 01                	mov    %eax,(%ecx)
			return 0;
  801108:	b8 00 00 00 00       	mov    $0x0,%eax
  80110d:	eb 2e                	jmp    80113d <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80110f:	8b 02                	mov    (%edx),%eax
  801111:	85 c0                	test   %eax,%eax
  801113:	75 e7                	jne    8010fc <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801115:	a1 04 40 80 00       	mov    0x804004,%eax
  80111a:	8b 40 48             	mov    0x48(%eax),%eax
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	51                   	push   %ecx
  801121:	50                   	push   %eax
  801122:	68 0c 25 80 00       	push   $0x80250c
  801127:	e8 56 f3 ff ff       	call   800482 <cprintf>
	*dev = 0;
  80112c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80112f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	56                   	push   %esi
  801143:	53                   	push   %ebx
  801144:	83 ec 10             	sub    $0x10,%esp
  801147:	8b 75 08             	mov    0x8(%ebp),%esi
  80114a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80114d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801150:	50                   	push   %eax
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801151:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801157:	c1 e8 0c             	shr    $0xc,%eax
fd_close(struct Fd *fd, bool must_exist)
{
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80115a:	50                   	push   %eax
  80115b:	e8 36 ff ff ff       	call   801096 <fd_lookup>
  801160:	83 c4 08             	add    $0x8,%esp
  801163:	85 c0                	test   %eax,%eax
  801165:	78 05                	js     80116c <fd_close+0x2d>
	    || fd != fd2)
  801167:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80116a:	74 0b                	je     801177 <fd_close+0x38>
		return (must_exist ? r : 0);
  80116c:	80 fb 01             	cmp    $0x1,%bl
  80116f:	19 d2                	sbb    %edx,%edx
  801171:	f7 d2                	not    %edx
  801173:	21 d0                	and    %edx,%eax
  801175:	eb 41                	jmp    8011b8 <fd_close+0x79>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801177:	83 ec 08             	sub    $0x8,%esp
  80117a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117d:	50                   	push   %eax
  80117e:	ff 36                	pushl  (%esi)
  801180:	e8 67 ff ff ff       	call   8010ec <dev_lookup>
  801185:	89 c3                	mov    %eax,%ebx
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	78 1a                	js     8011a8 <fd_close+0x69>
		if (dev->dev_close)
  80118e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801191:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801194:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801199:	85 c0                	test   %eax,%eax
  80119b:	74 0b                	je     8011a8 <fd_close+0x69>
			r = (*dev->dev_close)(fd);
  80119d:	83 ec 0c             	sub    $0xc,%esp
  8011a0:	56                   	push   %esi
  8011a1:	ff d0                	call   *%eax
  8011a3:	89 c3                	mov    %eax,%ebx
  8011a5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	56                   	push   %esi
  8011ac:	6a 00                	push   $0x0
  8011ae:	e8 e2 fc ff ff       	call   800e95 <sys_page_unmap>
	return r;
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	89 d8                	mov    %ebx,%eax
}
  8011b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5d                   	pop    %ebp
  8011be:	c3                   	ret    

008011bf <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011bf:	55                   	push   %ebp
  8011c0:	89 e5                	mov    %esp,%ebp
  8011c2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c8:	50                   	push   %eax
  8011c9:	ff 75 08             	pushl  0x8(%ebp)
  8011cc:	e8 c5 fe ff ff       	call   801096 <fd_lookup>
  8011d1:	89 c2                	mov    %eax,%edx
  8011d3:	83 c4 08             	add    $0x8,%esp
  8011d6:	85 d2                	test   %edx,%edx
  8011d8:	78 10                	js     8011ea <close+0x2b>
		return r;
	else
		return fd_close(fd, 1);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	6a 01                	push   $0x1
  8011df:	ff 75 f4             	pushl  -0xc(%ebp)
  8011e2:	e8 58 ff ff ff       	call   80113f <fd_close>
  8011e7:	83 c4 10             	add    $0x10,%esp
}
  8011ea:	c9                   	leave  
  8011eb:	c3                   	ret    

008011ec <close_all>:

void
close_all(void)
{
  8011ec:	55                   	push   %ebp
  8011ed:	89 e5                	mov    %esp,%ebp
  8011ef:	53                   	push   %ebx
  8011f0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011f8:	83 ec 0c             	sub    $0xc,%esp
  8011fb:	53                   	push   %ebx
  8011fc:	e8 be ff ff ff       	call   8011bf <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801201:	83 c3 01             	add    $0x1,%ebx
  801204:	83 c4 10             	add    $0x10,%esp
  801207:	83 fb 20             	cmp    $0x20,%ebx
  80120a:	75 ec                	jne    8011f8 <close_all+0xc>
		close(i);
}
  80120c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120f:	c9                   	leave  
  801210:	c3                   	ret    

00801211 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	57                   	push   %edi
  801215:	56                   	push   %esi
  801216:	53                   	push   %ebx
  801217:	83 ec 2c             	sub    $0x2c,%esp
  80121a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80121d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	ff 75 08             	pushl  0x8(%ebp)
  801224:	e8 6d fe ff ff       	call   801096 <fd_lookup>
  801229:	89 c2                	mov    %eax,%edx
  80122b:	83 c4 08             	add    $0x8,%esp
  80122e:	85 d2                	test   %edx,%edx
  801230:	0f 88 c1 00 00 00    	js     8012f7 <dup+0xe6>
		return r;
	close(newfdnum);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	56                   	push   %esi
  80123a:	e8 80 ff ff ff       	call   8011bf <close>

	newfd = INDEX2FD(newfdnum);
  80123f:	89 f3                	mov    %esi,%ebx
  801241:	c1 e3 0c             	shl    $0xc,%ebx
  801244:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80124a:	83 c4 04             	add    $0x4,%esp
  80124d:	ff 75 e4             	pushl  -0x1c(%ebp)
  801250:	e8 db fd ff ff       	call   801030 <fd2data>
  801255:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801257:	89 1c 24             	mov    %ebx,(%esp)
  80125a:	e8 d1 fd ff ff       	call   801030 <fd2data>
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801265:	89 f8                	mov    %edi,%eax
  801267:	c1 e8 16             	shr    $0x16,%eax
  80126a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801271:	a8 01                	test   $0x1,%al
  801273:	74 37                	je     8012ac <dup+0x9b>
  801275:	89 f8                	mov    %edi,%eax
  801277:	c1 e8 0c             	shr    $0xc,%eax
  80127a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801281:	f6 c2 01             	test   $0x1,%dl
  801284:	74 26                	je     8012ac <dup+0x9b>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801286:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128d:	83 ec 0c             	sub    $0xc,%esp
  801290:	25 07 0e 00 00       	and    $0xe07,%eax
  801295:	50                   	push   %eax
  801296:	ff 75 d4             	pushl  -0x2c(%ebp)
  801299:	6a 00                	push   $0x0
  80129b:	57                   	push   %edi
  80129c:	6a 00                	push   $0x0
  80129e:	e8 b0 fb ff ff       	call   800e53 <sys_page_map>
  8012a3:	89 c7                	mov    %eax,%edi
  8012a5:	83 c4 20             	add    $0x20,%esp
  8012a8:	85 c0                	test   %eax,%eax
  8012aa:	78 2e                	js     8012da <dup+0xc9>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012af:	89 d0                	mov    %edx,%eax
  8012b1:	c1 e8 0c             	shr    $0xc,%eax
  8012b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bb:	83 ec 0c             	sub    $0xc,%esp
  8012be:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c3:	50                   	push   %eax
  8012c4:	53                   	push   %ebx
  8012c5:	6a 00                	push   $0x0
  8012c7:	52                   	push   %edx
  8012c8:	6a 00                	push   $0x0
  8012ca:	e8 84 fb ff ff       	call   800e53 <sys_page_map>
  8012cf:	89 c7                	mov    %eax,%edi
  8012d1:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012d4:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d6:	85 ff                	test   %edi,%edi
  8012d8:	79 1d                	jns    8012f7 <dup+0xe6>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012da:	83 ec 08             	sub    $0x8,%esp
  8012dd:	53                   	push   %ebx
  8012de:	6a 00                	push   $0x0
  8012e0:	e8 b0 fb ff ff       	call   800e95 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012e5:	83 c4 08             	add    $0x8,%esp
  8012e8:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012eb:	6a 00                	push   $0x0
  8012ed:	e8 a3 fb ff ff       	call   800e95 <sys_page_unmap>
	return r;
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	89 f8                	mov    %edi,%eax
}
  8012f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012fa:	5b                   	pop    %ebx
  8012fb:	5e                   	pop    %esi
  8012fc:	5f                   	pop    %edi
  8012fd:	5d                   	pop    %ebp
  8012fe:	c3                   	ret    

008012ff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012ff:	55                   	push   %ebp
  801300:	89 e5                	mov    %esp,%ebp
  801302:	53                   	push   %ebx
  801303:	83 ec 14             	sub    $0x14,%esp
  801306:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801309:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80130c:	50                   	push   %eax
  80130d:	53                   	push   %ebx
  80130e:	e8 83 fd ff ff       	call   801096 <fd_lookup>
  801313:	83 c4 08             	add    $0x8,%esp
  801316:	89 c2                	mov    %eax,%edx
  801318:	85 c0                	test   %eax,%eax
  80131a:	78 6d                	js     801389 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131c:	83 ec 08             	sub    $0x8,%esp
  80131f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801322:	50                   	push   %eax
  801323:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801326:	ff 30                	pushl  (%eax)
  801328:	e8 bf fd ff ff       	call   8010ec <dev_lookup>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 4c                	js     801380 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801334:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801337:	8b 42 08             	mov    0x8(%edx),%eax
  80133a:	83 e0 03             	and    $0x3,%eax
  80133d:	83 f8 01             	cmp    $0x1,%eax
  801340:	75 21                	jne    801363 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801342:	a1 04 40 80 00       	mov    0x804004,%eax
  801347:	8b 40 48             	mov    0x48(%eax),%eax
  80134a:	83 ec 04             	sub    $0x4,%esp
  80134d:	53                   	push   %ebx
  80134e:	50                   	push   %eax
  80134f:	68 4d 25 80 00       	push   $0x80254d
  801354:	e8 29 f1 ff ff       	call   800482 <cprintf>
		return -E_INVAL;
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801361:	eb 26                	jmp    801389 <read+0x8a>
	}
	if (!dev->dev_read)
  801363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801366:	8b 40 08             	mov    0x8(%eax),%eax
  801369:	85 c0                	test   %eax,%eax
  80136b:	74 17                	je     801384 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80136d:	83 ec 04             	sub    $0x4,%esp
  801370:	ff 75 10             	pushl  0x10(%ebp)
  801373:	ff 75 0c             	pushl  0xc(%ebp)
  801376:	52                   	push   %edx
  801377:	ff d0                	call   *%eax
  801379:	89 c2                	mov    %eax,%edx
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	eb 09                	jmp    801389 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801380:	89 c2                	mov    %eax,%edx
  801382:	eb 05                	jmp    801389 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801384:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801389:	89 d0                	mov    %edx,%eax
  80138b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	57                   	push   %edi
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	83 ec 0c             	sub    $0xc,%esp
  801399:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80139f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a4:	eb 21                	jmp    8013c7 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a6:	83 ec 04             	sub    $0x4,%esp
  8013a9:	89 f0                	mov    %esi,%eax
  8013ab:	29 d8                	sub    %ebx,%eax
  8013ad:	50                   	push   %eax
  8013ae:	89 d8                	mov    %ebx,%eax
  8013b0:	03 45 0c             	add    0xc(%ebp),%eax
  8013b3:	50                   	push   %eax
  8013b4:	57                   	push   %edi
  8013b5:	e8 45 ff ff ff       	call   8012ff <read>
		if (m < 0)
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 0c                	js     8013cd <readn+0x3d>
			return m;
		if (m == 0)
  8013c1:	85 c0                	test   %eax,%eax
  8013c3:	74 06                	je     8013cb <readn+0x3b>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c5:	01 c3                	add    %eax,%ebx
  8013c7:	39 f3                	cmp    %esi,%ebx
  8013c9:	72 db                	jb     8013a6 <readn+0x16>
		if (m < 0)
			return m;
		if (m == 0)
			break;
	}
	return tot;
  8013cb:	89 d8                	mov    %ebx,%eax
}
  8013cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d0:	5b                   	pop    %ebx
  8013d1:	5e                   	pop    %esi
  8013d2:	5f                   	pop    %edi
  8013d3:	5d                   	pop    %ebp
  8013d4:	c3                   	ret    

008013d5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013d5:	55                   	push   %ebp
  8013d6:	89 e5                	mov    %esp,%ebp
  8013d8:	53                   	push   %ebx
  8013d9:	83 ec 14             	sub    $0x14,%esp
  8013dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013df:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e2:	50                   	push   %eax
  8013e3:	53                   	push   %ebx
  8013e4:	e8 ad fc ff ff       	call   801096 <fd_lookup>
  8013e9:	83 c4 08             	add    $0x8,%esp
  8013ec:	89 c2                	mov    %eax,%edx
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 68                	js     80145a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f2:	83 ec 08             	sub    $0x8,%esp
  8013f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013f8:	50                   	push   %eax
  8013f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013fc:	ff 30                	pushl  (%eax)
  8013fe:	e8 e9 fc ff ff       	call   8010ec <dev_lookup>
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 47                	js     801451 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80140d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801411:	75 21                	jne    801434 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801413:	a1 04 40 80 00       	mov    0x804004,%eax
  801418:	8b 40 48             	mov    0x48(%eax),%eax
  80141b:	83 ec 04             	sub    $0x4,%esp
  80141e:	53                   	push   %ebx
  80141f:	50                   	push   %eax
  801420:	68 69 25 80 00       	push   $0x802569
  801425:	e8 58 f0 ff ff       	call   800482 <cprintf>
		return -E_INVAL;
  80142a:	83 c4 10             	add    $0x10,%esp
  80142d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801432:	eb 26                	jmp    80145a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801434:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801437:	8b 52 0c             	mov    0xc(%edx),%edx
  80143a:	85 d2                	test   %edx,%edx
  80143c:	74 17                	je     801455 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80143e:	83 ec 04             	sub    $0x4,%esp
  801441:	ff 75 10             	pushl  0x10(%ebp)
  801444:	ff 75 0c             	pushl  0xc(%ebp)
  801447:	50                   	push   %eax
  801448:	ff d2                	call   *%edx
  80144a:	89 c2                	mov    %eax,%edx
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	eb 09                	jmp    80145a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801451:	89 c2                	mov    %eax,%edx
  801453:	eb 05                	jmp    80145a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801455:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80145a:	89 d0                	mov    %edx,%eax
  80145c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80145f:	c9                   	leave  
  801460:	c3                   	ret    

00801461 <seek>:

int
seek(int fdnum, off_t offset)
{
  801461:	55                   	push   %ebp
  801462:	89 e5                	mov    %esp,%ebp
  801464:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801467:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80146a:	50                   	push   %eax
  80146b:	ff 75 08             	pushl  0x8(%ebp)
  80146e:	e8 23 fc ff ff       	call   801096 <fd_lookup>
  801473:	83 c4 08             	add    $0x8,%esp
  801476:	85 c0                	test   %eax,%eax
  801478:	78 0e                	js     801488 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80147a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80147d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801480:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801483:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	53                   	push   %ebx
  80148e:	83 ec 14             	sub    $0x14,%esp
  801491:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801494:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	53                   	push   %ebx
  801499:	e8 f8 fb ff ff       	call   801096 <fd_lookup>
  80149e:	83 c4 08             	add    $0x8,%esp
  8014a1:	89 c2                	mov    %eax,%edx
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 65                	js     80150c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b1:	ff 30                	pushl  (%eax)
  8014b3:	e8 34 fc ff ff       	call   8010ec <dev_lookup>
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 44                	js     801503 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c6:	75 21                	jne    8014e9 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014c8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014cd:	8b 40 48             	mov    0x48(%eax),%eax
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	53                   	push   %ebx
  8014d4:	50                   	push   %eax
  8014d5:	68 2c 25 80 00       	push   $0x80252c
  8014da:	e8 a3 ef ff ff       	call   800482 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014e7:	eb 23                	jmp    80150c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8014e9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ec:	8b 52 18             	mov    0x18(%edx),%edx
  8014ef:	85 d2                	test   %edx,%edx
  8014f1:	74 14                	je     801507 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014f3:	83 ec 08             	sub    $0x8,%esp
  8014f6:	ff 75 0c             	pushl  0xc(%ebp)
  8014f9:	50                   	push   %eax
  8014fa:	ff d2                	call   *%edx
  8014fc:	89 c2                	mov    %eax,%edx
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	eb 09                	jmp    80150c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801503:	89 c2                	mov    %eax,%edx
  801505:	eb 05                	jmp    80150c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801507:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80150c:	89 d0                	mov    %edx,%eax
  80150e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801511:	c9                   	leave  
  801512:	c3                   	ret    

00801513 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 14             	sub    $0x14,%esp
  80151a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	ff 75 08             	pushl  0x8(%ebp)
  801524:	e8 6d fb ff ff       	call   801096 <fd_lookup>
  801529:	83 c4 08             	add    $0x8,%esp
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 58                	js     80158a <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801532:	83 ec 08             	sub    $0x8,%esp
  801535:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801538:	50                   	push   %eax
  801539:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153c:	ff 30                	pushl  (%eax)
  80153e:	e8 a9 fb ff ff       	call   8010ec <dev_lookup>
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	78 37                	js     801581 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80154a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80154d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801551:	74 32                	je     801585 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801553:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801556:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80155d:	00 00 00 
	stat->st_isdir = 0;
  801560:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801567:	00 00 00 
	stat->st_dev = dev;
  80156a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801570:	83 ec 08             	sub    $0x8,%esp
  801573:	53                   	push   %ebx
  801574:	ff 75 f0             	pushl  -0x10(%ebp)
  801577:	ff 50 14             	call   *0x14(%eax)
  80157a:	89 c2                	mov    %eax,%edx
  80157c:	83 c4 10             	add    $0x10,%esp
  80157f:	eb 09                	jmp    80158a <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801581:	89 c2                	mov    %eax,%edx
  801583:	eb 05                	jmp    80158a <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801585:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80158a:	89 d0                	mov    %edx,%eax
  80158c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80158f:	c9                   	leave  
  801590:	c3                   	ret    

00801591 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801591:	55                   	push   %ebp
  801592:	89 e5                	mov    %esp,%ebp
  801594:	56                   	push   %esi
  801595:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801596:	83 ec 08             	sub    $0x8,%esp
  801599:	6a 00                	push   $0x0
  80159b:	ff 75 08             	pushl  0x8(%ebp)
  80159e:	e8 e7 01 00 00       	call   80178a <open>
  8015a3:	89 c3                	mov    %eax,%ebx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 db                	test   %ebx,%ebx
  8015aa:	78 1b                	js     8015c7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	ff 75 0c             	pushl  0xc(%ebp)
  8015b2:	53                   	push   %ebx
  8015b3:	e8 5b ff ff ff       	call   801513 <fstat>
  8015b8:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ba:	89 1c 24             	mov    %ebx,(%esp)
  8015bd:	e8 fd fb ff ff       	call   8011bf <close>
	return r;
  8015c2:	83 c4 10             	add    $0x10,%esp
  8015c5:	89 f0                	mov    %esi,%eax
}
  8015c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ca:	5b                   	pop    %ebx
  8015cb:	5e                   	pop    %esi
  8015cc:	5d                   	pop    %ebp
  8015cd:	c3                   	ret    

008015ce <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	56                   	push   %esi
  8015d2:	53                   	push   %ebx
  8015d3:	89 c6                	mov    %eax,%esi
  8015d5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015d7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015de:	75 12                	jne    8015f2 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015e0:	83 ec 0c             	sub    $0xc,%esp
  8015e3:	6a 03                	push   $0x3
  8015e5:	e8 d2 07 00 00       	call   801dbc <ipc_find_env>
  8015ea:	a3 00 40 80 00       	mov    %eax,0x804000
  8015ef:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015f2:	6a 07                	push   $0x7
  8015f4:	68 00 50 80 00       	push   $0x805000
  8015f9:	56                   	push   %esi
  8015fa:	ff 35 00 40 80 00    	pushl  0x804000
  801600:	e8 66 07 00 00       	call   801d6b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801605:	83 c4 0c             	add    $0xc,%esp
  801608:	6a 00                	push   $0x0
  80160a:	53                   	push   %ebx
  80160b:	6a 00                	push   $0x0
  80160d:	e8 f3 06 00 00       	call   801d05 <ipc_recv>
}
  801612:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801615:	5b                   	pop    %ebx
  801616:	5e                   	pop    %esi
  801617:	5d                   	pop    %ebp
  801618:	c3                   	ret    

00801619 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80161f:	8b 45 08             	mov    0x8(%ebp),%eax
  801622:	8b 40 0c             	mov    0xc(%eax),%eax
  801625:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80162a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801632:	ba 00 00 00 00       	mov    $0x0,%edx
  801637:	b8 02 00 00 00       	mov    $0x2,%eax
  80163c:	e8 8d ff ff ff       	call   8015ce <fsipc>
}
  801641:	c9                   	leave  
  801642:	c3                   	ret    

00801643 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	8b 40 0c             	mov    0xc(%eax),%eax
  80164f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801654:	ba 00 00 00 00       	mov    $0x0,%edx
  801659:	b8 06 00 00 00       	mov    $0x6,%eax
  80165e:	e8 6b ff ff ff       	call   8015ce <fsipc>
}
  801663:	c9                   	leave  
  801664:	c3                   	ret    

00801665 <devfile_stat>:
	return write;
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801665:	55                   	push   %ebp
  801666:	89 e5                	mov    %esp,%ebp
  801668:	53                   	push   %ebx
  801669:	83 ec 04             	sub    $0x4,%esp
  80166c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80166f:	8b 45 08             	mov    0x8(%ebp),%eax
  801672:	8b 40 0c             	mov    0xc(%eax),%eax
  801675:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80167a:	ba 00 00 00 00       	mov    $0x0,%edx
  80167f:	b8 05 00 00 00       	mov    $0x5,%eax
  801684:	e8 45 ff ff ff       	call   8015ce <fsipc>
  801689:	89 c2                	mov    %eax,%edx
  80168b:	85 d2                	test   %edx,%edx
  80168d:	78 2c                	js     8016bb <devfile_stat+0x56>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80168f:	83 ec 08             	sub    $0x8,%esp
  801692:	68 00 50 80 00       	push   $0x805000
  801697:	53                   	push   %ebx
  801698:	e8 69 f3 ff ff       	call   800a06 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80169d:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016a8:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ad:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b3:	83 c4 10             	add    $0x10,%esp
  8016b6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	83 ec 08             	sub    $0x8,%esp
  8016c6:	8b 45 10             	mov    0x10(%ebp),%eax
	// bytes than requested.
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
  8016c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016cc:	8b 52 0c             	mov    0xc(%edx),%edx
  8016cf:	89 15 00 50 80 00    	mov    %edx,0x805000
	size_t movesize = sizeof(req->req_buf);
	if (n < movesize)
  8016d5:	3d f7 0f 00 00       	cmp    $0xff7,%eax
  8016da:	76 05                	jbe    8016e1 <devfile_write+0x21>
	// LAB 10: Your code here
	// panic("devfile_write not implemented");
	//int r;
	struct Fsreq_write *req = &fsipcbuf.write;
   	req->req_fileid = fd->fd_file.id;
	size_t movesize = sizeof(req->req_buf);
  8016dc:	b8 f8 0f 00 00       	mov    $0xff8,%eax
	if (n < movesize)
	        movesize = n;
    	req->req_n = movesize;
  8016e1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(req->req_buf, buf, movesize);
  8016e6:	83 ec 04             	sub    $0x4,%esp
  8016e9:	50                   	push   %eax
  8016ea:	ff 75 0c             	pushl  0xc(%ebp)
  8016ed:	68 08 50 80 00       	push   $0x805008
  8016f2:	e8 a1 f4 ff ff       	call   800b98 <memmove>
	ssize_t write = fsipc(FSREQ_WRITE, NULL);
  8016f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016fc:	b8 04 00 00 00       	mov    $0x4,%eax
  801701:	e8 c8 fe ff ff       	call   8015ce <fsipc>
	return write;
}
  801706:	c9                   	leave  
  801707:	c3                   	ret    

00801708 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	56                   	push   %esi
  80170c:	53                   	push   %ebx
  80170d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801710:	8b 45 08             	mov    0x8(%ebp),%eax
  801713:	8b 40 0c             	mov    0xc(%eax),%eax
  801716:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80171b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801721:	ba 00 00 00 00       	mov    $0x0,%edx
  801726:	b8 03 00 00 00       	mov    $0x3,%eax
  80172b:	e8 9e fe ff ff       	call   8015ce <fsipc>
  801730:	89 c3                	mov    %eax,%ebx
  801732:	85 c0                	test   %eax,%eax
  801734:	78 4b                	js     801781 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801736:	39 c6                	cmp    %eax,%esi
  801738:	73 16                	jae    801750 <devfile_read+0x48>
  80173a:	68 98 25 80 00       	push   $0x802598
  80173f:	68 36 21 80 00       	push   $0x802136
  801744:	6a 7c                	push   $0x7c
  801746:	68 9f 25 80 00       	push   $0x80259f
  80174b:	e8 59 ec ff ff       	call   8003a9 <_panic>
	assert(r <= PGSIZE);
  801750:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801755:	7e 16                	jle    80176d <devfile_read+0x65>
  801757:	68 aa 25 80 00       	push   $0x8025aa
  80175c:	68 36 21 80 00       	push   $0x802136
  801761:	6a 7d                	push   $0x7d
  801763:	68 9f 25 80 00       	push   $0x80259f
  801768:	e8 3c ec ff ff       	call   8003a9 <_panic>
	memmove(buf, &fsipcbuf, r);
  80176d:	83 ec 04             	sub    $0x4,%esp
  801770:	50                   	push   %eax
  801771:	68 00 50 80 00       	push   $0x805000
  801776:	ff 75 0c             	pushl  0xc(%ebp)
  801779:	e8 1a f4 ff ff       	call   800b98 <memmove>
	return r;
  80177e:	83 c4 10             	add    $0x10,%esp
}
  801781:	89 d8                	mov    %ebx,%eax
  801783:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801786:	5b                   	pop    %ebx
  801787:	5e                   	pop    %esi
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	53                   	push   %ebx
  80178e:	83 ec 20             	sub    $0x20,%esp
  801791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801794:	53                   	push   %ebx
  801795:	e8 33 f2 ff ff       	call   8009cd <strlen>
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017a2:	7f 67                	jg     80180b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017a4:	83 ec 0c             	sub    $0xc,%esp
  8017a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017aa:	50                   	push   %eax
  8017ab:	e8 97 f8 ff ff       	call   801047 <fd_alloc>
  8017b0:	83 c4 10             	add    $0x10,%esp
		return r;
  8017b3:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017b5:	85 c0                	test   %eax,%eax
  8017b7:	78 57                	js     801810 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017b9:	83 ec 08             	sub    $0x8,%esp
  8017bc:	53                   	push   %ebx
  8017bd:	68 00 50 80 00       	push   $0x805000
  8017c2:	e8 3f f2 ff ff       	call   800a06 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ca:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8017d7:	e8 f2 fd ff ff       	call   8015ce <fsipc>
  8017dc:	89 c3                	mov    %eax,%ebx
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	79 14                	jns    8017f9 <open+0x6f>
		fd_close(fd, 0);
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	6a 00                	push   $0x0
  8017ea:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ed:	e8 4d f9 ff ff       	call   80113f <fd_close>
		return r;
  8017f2:	83 c4 10             	add    $0x10,%esp
  8017f5:	89 da                	mov    %ebx,%edx
  8017f7:	eb 17                	jmp    801810 <open+0x86>
	}

	return fd2num(fd);
  8017f9:	83 ec 0c             	sub    $0xc,%esp
  8017fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8017ff:	e8 1c f8 ff ff       	call   801020 <fd2num>
  801804:	89 c2                	mov    %eax,%edx
  801806:	83 c4 10             	add    $0x10,%esp
  801809:	eb 05                	jmp    801810 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80180b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801810:	89 d0                	mov    %edx,%eax
  801812:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801815:	c9                   	leave  
  801816:	c3                   	ret    

00801817 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80181d:	ba 00 00 00 00       	mov    $0x0,%edx
  801822:	b8 08 00 00 00       	mov    $0x8,%eax
  801827:	e8 a2 fd ff ff       	call   8015ce <fsipc>
}
  80182c:	c9                   	leave  
  80182d:	c3                   	ret    

0080182e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801836:	83 ec 0c             	sub    $0xc,%esp
  801839:	ff 75 08             	pushl  0x8(%ebp)
  80183c:	e8 ef f7 ff ff       	call   801030 <fd2data>
  801841:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801843:	83 c4 08             	add    $0x8,%esp
  801846:	68 b6 25 80 00       	push   $0x8025b6
  80184b:	53                   	push   %ebx
  80184c:	e8 b5 f1 ff ff       	call   800a06 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801851:	8b 56 04             	mov    0x4(%esi),%edx
  801854:	89 d0                	mov    %edx,%eax
  801856:	2b 06                	sub    (%esi),%eax
  801858:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80185e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801865:	00 00 00 
	stat->st_dev = &devpipe;
  801868:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80186f:	30 80 00 
	return 0;
}
  801872:	b8 00 00 00 00       	mov    $0x0,%eax
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    

0080187e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80187e:	55                   	push   %ebp
  80187f:	89 e5                	mov    %esp,%ebp
  801881:	53                   	push   %ebx
  801882:	83 ec 0c             	sub    $0xc,%esp
  801885:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801888:	53                   	push   %ebx
  801889:	6a 00                	push   $0x0
  80188b:	e8 05 f6 ff ff       	call   800e95 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801890:	89 1c 24             	mov    %ebx,(%esp)
  801893:	e8 98 f7 ff ff       	call   801030 <fd2data>
  801898:	83 c4 08             	add    $0x8,%esp
  80189b:	50                   	push   %eax
  80189c:	6a 00                	push   $0x0
  80189e:	e8 f2 f5 ff ff       	call   800e95 <sys_page_unmap>
}
  8018a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a6:	c9                   	leave  
  8018a7:	c3                   	ret    

008018a8 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018a8:	55                   	push   %ebp
  8018a9:	89 e5                	mov    %esp,%ebp
  8018ab:	57                   	push   %edi
  8018ac:	56                   	push   %esi
  8018ad:	53                   	push   %ebx
  8018ae:	83 ec 1c             	sub    $0x1c,%esp
  8018b1:	89 c7                	mov    %eax,%edi
  8018b3:	89 d6                	mov    %edx,%esi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018b5:	a1 04 40 80 00       	mov    0x804004,%eax
  8018ba:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8018bd:	83 ec 0c             	sub    $0xc,%esp
  8018c0:	57                   	push   %edi
  8018c1:	e8 2e 05 00 00       	call   801df4 <pageref>
  8018c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018c9:	89 34 24             	mov    %esi,(%esp)
  8018cc:	e8 23 05 00 00       	call   801df4 <pageref>
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018d7:	0f 94 c0             	sete   %al
  8018da:	0f b6 c0             	movzbl %al,%eax
		nn = thisenv->env_runs;
  8018dd:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8018e3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018e6:	39 cb                	cmp    %ecx,%ebx
  8018e8:	74 15                	je     8018ff <_pipeisclosed+0x57>
			return ret;
		if (n != nn)
			cprintf("pipe race avoided: runs %d - %d, pageref eq: %d\n", n, thisenv->env_runs, ret);
  8018ea:	8b 52 58             	mov    0x58(%edx),%edx
  8018ed:	50                   	push   %eax
  8018ee:	52                   	push   %edx
  8018ef:	53                   	push   %ebx
  8018f0:	68 c4 25 80 00       	push   $0x8025c4
  8018f5:	e8 88 eb ff ff       	call   800482 <cprintf>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	eb b6                	jmp    8018b5 <_pipeisclosed+0xd>
	}
}
  8018ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5f                   	pop    %edi
  801905:	5d                   	pop    %ebp
  801906:	c3                   	ret    

00801907 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	57                   	push   %edi
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	83 ec 28             	sub    $0x28,%esp
  801910:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801913:	56                   	push   %esi
  801914:	e8 17 f7 ff ff       	call   801030 <fd2data>
  801919:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	bf 00 00 00 00       	mov    $0x0,%edi
  801923:	eb 4b                	jmp    801970 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801925:	89 da                	mov    %ebx,%edx
  801927:	89 f0                	mov    %esi,%eax
  801929:	e8 7a ff ff ff       	call   8018a8 <_pipeisclosed>
  80192e:	85 c0                	test   %eax,%eax
  801930:	75 48                	jne    80197a <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801932:	e8 ba f4 ff ff       	call   800df1 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801937:	8b 43 04             	mov    0x4(%ebx),%eax
  80193a:	8b 0b                	mov    (%ebx),%ecx
  80193c:	8d 51 20             	lea    0x20(%ecx),%edx
  80193f:	39 d0                	cmp    %edx,%eax
  801941:	73 e2                	jae    801925 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801943:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801946:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80194a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80194d:	89 c2                	mov    %eax,%edx
  80194f:	c1 fa 1f             	sar    $0x1f,%edx
  801952:	89 d1                	mov    %edx,%ecx
  801954:	c1 e9 1b             	shr    $0x1b,%ecx
  801957:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80195a:	83 e2 1f             	and    $0x1f,%edx
  80195d:	29 ca                	sub    %ecx,%edx
  80195f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801963:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801967:	83 c0 01             	add    $0x1,%eax
  80196a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80196d:	83 c7 01             	add    $0x1,%edi
  801970:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801973:	75 c2                	jne    801937 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801975:	8b 45 10             	mov    0x10(%ebp),%eax
  801978:	eb 05                	jmp    80197f <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80197a:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80197f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801982:	5b                   	pop    %ebx
  801983:	5e                   	pop    %esi
  801984:	5f                   	pop    %edi
  801985:	5d                   	pop    %ebp
  801986:	c3                   	ret    

00801987 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801987:	55                   	push   %ebp
  801988:	89 e5                	mov    %esp,%ebp
  80198a:	57                   	push   %edi
  80198b:	56                   	push   %esi
  80198c:	53                   	push   %ebx
  80198d:	83 ec 18             	sub    $0x18,%esp
  801990:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801993:	57                   	push   %edi
  801994:	e8 97 f6 ff ff       	call   801030 <fd2data>
  801999:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019a3:	eb 3d                	jmp    8019e2 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019a5:	85 db                	test   %ebx,%ebx
  8019a7:	74 04                	je     8019ad <devpipe_read+0x26>
				return i;
  8019a9:	89 d8                	mov    %ebx,%eax
  8019ab:	eb 44                	jmp    8019f1 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019ad:	89 f2                	mov    %esi,%edx
  8019af:	89 f8                	mov    %edi,%eax
  8019b1:	e8 f2 fe ff ff       	call   8018a8 <_pipeisclosed>
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	75 32                	jne    8019ec <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019ba:	e8 32 f4 ff ff       	call   800df1 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019bf:	8b 06                	mov    (%esi),%eax
  8019c1:	3b 46 04             	cmp    0x4(%esi),%eax
  8019c4:	74 df                	je     8019a5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019c6:	99                   	cltd   
  8019c7:	c1 ea 1b             	shr    $0x1b,%edx
  8019ca:	01 d0                	add    %edx,%eax
  8019cc:	83 e0 1f             	and    $0x1f,%eax
  8019cf:	29 d0                	sub    %edx,%eax
  8019d1:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d9:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8019dc:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019df:	83 c3 01             	add    $0x1,%ebx
  8019e2:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8019e5:	75 d8                	jne    8019bf <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8019e7:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ea:	eb 05                	jmp    8019f1 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019ec:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8019f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5f                   	pop    %edi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	56                   	push   %esi
  8019fd:	53                   	push   %ebx
  8019fe:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a04:	50                   	push   %eax
  801a05:	e8 3d f6 ff ff       	call   801047 <fd_alloc>
  801a0a:	83 c4 10             	add    $0x10,%esp
  801a0d:	89 c2                	mov    %eax,%edx
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	0f 88 2c 01 00 00    	js     801b43 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a17:	83 ec 04             	sub    $0x4,%esp
  801a1a:	68 07 04 00 00       	push   $0x407
  801a1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801a22:	6a 00                	push   $0x0
  801a24:	e8 e7 f3 ff ff       	call   800e10 <sys_page_alloc>
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	89 c2                	mov    %eax,%edx
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	0f 88 0d 01 00 00    	js     801b43 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a36:	83 ec 0c             	sub    $0xc,%esp
  801a39:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a3c:	50                   	push   %eax
  801a3d:	e8 05 f6 ff ff       	call   801047 <fd_alloc>
  801a42:	89 c3                	mov    %eax,%ebx
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	85 c0                	test   %eax,%eax
  801a49:	0f 88 e2 00 00 00    	js     801b31 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4f:	83 ec 04             	sub    $0x4,%esp
  801a52:	68 07 04 00 00       	push   $0x407
  801a57:	ff 75 f0             	pushl  -0x10(%ebp)
  801a5a:	6a 00                	push   $0x0
  801a5c:	e8 af f3 ff ff       	call   800e10 <sys_page_alloc>
  801a61:	89 c3                	mov    %eax,%ebx
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	0f 88 c3 00 00 00    	js     801b31 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a6e:	83 ec 0c             	sub    $0xc,%esp
  801a71:	ff 75 f4             	pushl  -0xc(%ebp)
  801a74:	e8 b7 f5 ff ff       	call   801030 <fd2data>
  801a79:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7b:	83 c4 0c             	add    $0xc,%esp
  801a7e:	68 07 04 00 00       	push   $0x407
  801a83:	50                   	push   %eax
  801a84:	6a 00                	push   $0x0
  801a86:	e8 85 f3 ff ff       	call   800e10 <sys_page_alloc>
  801a8b:	89 c3                	mov    %eax,%ebx
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	85 c0                	test   %eax,%eax
  801a92:	0f 88 89 00 00 00    	js     801b21 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a98:	83 ec 0c             	sub    $0xc,%esp
  801a9b:	ff 75 f0             	pushl  -0x10(%ebp)
  801a9e:	e8 8d f5 ff ff       	call   801030 <fd2data>
  801aa3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801aaa:	50                   	push   %eax
  801aab:	6a 00                	push   $0x0
  801aad:	56                   	push   %esi
  801aae:	6a 00                	push   $0x0
  801ab0:	e8 9e f3 ff ff       	call   800e53 <sys_page_map>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	83 c4 20             	add    $0x20,%esp
  801aba:	85 c0                	test   %eax,%eax
  801abc:	78 55                	js     801b13 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801abe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ac9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801acc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801ad3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801ad9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801adc:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ade:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ae1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801ae8:	83 ec 0c             	sub    $0xc,%esp
  801aeb:	ff 75 f4             	pushl  -0xc(%ebp)
  801aee:	e8 2d f5 ff ff       	call   801020 <fd2num>
  801af3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801af6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801af8:	83 c4 04             	add    $0x4,%esp
  801afb:	ff 75 f0             	pushl  -0x10(%ebp)
  801afe:	e8 1d f5 ff ff       	call   801020 <fd2num>
  801b03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b06:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b11:	eb 30                	jmp    801b43 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b13:	83 ec 08             	sub    $0x8,%esp
  801b16:	56                   	push   %esi
  801b17:	6a 00                	push   $0x0
  801b19:	e8 77 f3 ff ff       	call   800e95 <sys_page_unmap>
  801b1e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b21:	83 ec 08             	sub    $0x8,%esp
  801b24:	ff 75 f0             	pushl  -0x10(%ebp)
  801b27:	6a 00                	push   $0x0
  801b29:	e8 67 f3 ff ff       	call   800e95 <sys_page_unmap>
  801b2e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b31:	83 ec 08             	sub    $0x8,%esp
  801b34:	ff 75 f4             	pushl  -0xc(%ebp)
  801b37:	6a 00                	push   $0x0
  801b39:	e8 57 f3 ff ff       	call   800e95 <sys_page_unmap>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b43:	89 d0                	mov    %edx,%eax
  801b45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b55:	50                   	push   %eax
  801b56:	ff 75 08             	pushl  0x8(%ebp)
  801b59:	e8 38 f5 ff ff       	call   801096 <fd_lookup>
  801b5e:	89 c2                	mov    %eax,%edx
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 d2                	test   %edx,%edx
  801b65:	78 18                	js     801b7f <pipeisclosed+0x33>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b67:	83 ec 0c             	sub    $0xc,%esp
  801b6a:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6d:	e8 be f4 ff ff       	call   801030 <fd2data>
	return _pipeisclosed(fd, p);
  801b72:	89 c2                	mov    %eax,%edx
  801b74:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b77:	e8 2c fd ff ff       	call   8018a8 <_pipeisclosed>
  801b7c:	83 c4 10             	add    $0x10,%esp
}
  801b7f:	c9                   	leave  
  801b80:	c3                   	ret    

00801b81 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801b81:	55                   	push   %ebp
  801b82:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801b84:	b8 00 00 00 00       	mov    $0x0,%eax
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b91:	68 f8 25 80 00       	push   $0x8025f8
  801b96:	ff 75 0c             	pushl  0xc(%ebp)
  801b99:	e8 68 ee ff ff       	call   800a06 <strcpy>
	return 0;
}
  801b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	57                   	push   %edi
  801ba9:	56                   	push   %esi
  801baa:	53                   	push   %ebx
  801bab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bb1:	bb 00 00 00 00       	mov    $0x0,%ebx
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bb6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bbc:	eb 2e                	jmp    801bec <devcons_write+0x47>
		m = n - tot;
  801bbe:	8b 55 10             	mov    0x10(%ebp),%edx
  801bc1:	29 da                	sub    %ebx,%edx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
  801bc3:	be 7f 00 00 00       	mov    $0x7f,%esi

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
		if (m > sizeof(buf) - 1)
  801bc8:	83 fa 7f             	cmp    $0x7f,%edx
  801bcb:	77 02                	ja     801bcf <devcons_write+0x2a>
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801bcd:	89 d6                	mov    %edx,%esi
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bcf:	83 ec 04             	sub    $0x4,%esp
  801bd2:	56                   	push   %esi
  801bd3:	03 45 0c             	add    0xc(%ebp),%eax
  801bd6:	50                   	push   %eax
  801bd7:	57                   	push   %edi
  801bd8:	e8 bb ef ff ff       	call   800b98 <memmove>
		sys_cputs(buf, m);
  801bdd:	83 c4 08             	add    $0x8,%esp
  801be0:	56                   	push   %esi
  801be1:	57                   	push   %edi
  801be2:	e8 6d f1 ff ff       	call   800d54 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be7:	01 f3                	add    %esi,%ebx
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bf1:	72 cb                	jb     801bbe <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bf6:	5b                   	pop    %ebx
  801bf7:	5e                   	pop    %esi
  801bf8:	5f                   	pop    %edi
  801bf9:	5d                   	pop    %ebp
  801bfa:	c3                   	ret    

00801bfb <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 08             	sub    $0x8,%esp
	int c;

	if (n == 0)
		return 0;
  801c01:	b8 00 00 00 00       	mov    $0x0,%eax
static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
	int c;

	if (n == 0)
  801c06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c0a:	75 07                	jne    801c13 <devcons_read+0x18>
  801c0c:	eb 28                	jmp    801c36 <devcons_read+0x3b>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c0e:	e8 de f1 ff ff       	call   800df1 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c13:	e8 5a f1 ff ff       	call   800d72 <sys_cgetc>
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	74 f2                	je     801c0e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c1c:	85 c0                	test   %eax,%eax
  801c1e:	78 16                	js     801c36 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c20:	83 f8 04             	cmp    $0x4,%eax
  801c23:	74 0c                	je     801c31 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c28:	88 02                	mov    %al,(%edx)
	return 1;
  801c2a:	b8 01 00 00 00       	mov    $0x1,%eax
  801c2f:	eb 05                	jmp    801c36 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c31:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c36:	c9                   	leave  
  801c37:	c3                   	ret    

00801c38 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c41:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c44:	6a 01                	push   $0x1
  801c46:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c49:	50                   	push   %eax
  801c4a:	e8 05 f1 ff ff       	call   800d54 <sys_cputs>
  801c4f:	83 c4 10             	add    $0x10,%esp
}
  801c52:	c9                   	leave  
  801c53:	c3                   	ret    

00801c54 <getchar>:

int
getchar(void)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c5a:	6a 01                	push   $0x1
  801c5c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c5f:	50                   	push   %eax
  801c60:	6a 00                	push   $0x0
  801c62:	e8 98 f6 ff ff       	call   8012ff <read>
	if (r < 0)
  801c67:	83 c4 10             	add    $0x10,%esp
  801c6a:	85 c0                	test   %eax,%eax
  801c6c:	78 0f                	js     801c7d <getchar+0x29>
		return r;
	if (r < 1)
  801c6e:	85 c0                	test   %eax,%eax
  801c70:	7e 06                	jle    801c78 <getchar+0x24>
		return -E_EOF;
	return c;
  801c72:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c76:	eb 05                	jmp    801c7d <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c78:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    

00801c7f <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c88:	50                   	push   %eax
  801c89:	ff 75 08             	pushl  0x8(%ebp)
  801c8c:	e8 05 f4 ff ff       	call   801096 <fd_lookup>
  801c91:	83 c4 10             	add    $0x10,%esp
  801c94:	85 c0                	test   %eax,%eax
  801c96:	78 11                	js     801ca9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801c98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca1:	39 10                	cmp    %edx,(%eax)
  801ca3:	0f 94 c0             	sete   %al
  801ca6:	0f b6 c0             	movzbl %al,%eax
}
  801ca9:	c9                   	leave  
  801caa:	c3                   	ret    

00801cab <opencons>:

int
opencons(void)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb4:	50                   	push   %eax
  801cb5:	e8 8d f3 ff ff       	call   801047 <fd_alloc>
  801cba:	83 c4 10             	add    $0x10,%esp
		return r;
  801cbd:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cbf:	85 c0                	test   %eax,%eax
  801cc1:	78 3e                	js     801d01 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cc3:	83 ec 04             	sub    $0x4,%esp
  801cc6:	68 07 04 00 00       	push   $0x407
  801ccb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cce:	6a 00                	push   $0x0
  801cd0:	e8 3b f1 ff ff       	call   800e10 <sys_page_alloc>
  801cd5:	83 c4 10             	add    $0x10,%esp
		return r;
  801cd8:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cda:	85 c0                	test   %eax,%eax
  801cdc:	78 23                	js     801d01 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801cde:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ce9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cec:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cf3:	83 ec 0c             	sub    $0xc,%esp
  801cf6:	50                   	push   %eax
  801cf7:	e8 24 f3 ff ff       	call   801020 <fd2num>
  801cfc:	89 c2                	mov    %eax,%edx
  801cfe:	83 c4 10             	add    $0x10,%esp
}
  801d01:	89 d0                	mov    %edx,%eax
  801d03:	c9                   	leave  
  801d04:	c3                   	ret    

00801d05 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d05:	55                   	push   %ebp
  801d06:	89 e5                	mov    %esp,%ebp
  801d08:	56                   	push   %esi
  801d09:	53                   	push   %ebx
  801d0a:	8b 75 08             	mov    0x8(%ebp),%esi
  801d0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d10:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (from_env_store) *from_env_store = 0;
  801d13:	85 f6                	test   %esi,%esi
  801d15:	74 06                	je     801d1d <ipc_recv+0x18>
  801d17:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
	if (perm_store) *perm_store = 0;
  801d1d:	85 db                	test   %ebx,%ebx
  801d1f:	74 06                	je     801d27 <ipc_recv+0x22>
  801d21:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	if (!pg) pg = (void*) -1;
  801d27:	83 f8 01             	cmp    $0x1,%eax
  801d2a:	19 d2                	sbb    %edx,%edx
  801d2c:	09 d0                	or     %edx,%eax
	int ret = sys_ipc_recv(pg);
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	50                   	push   %eax
  801d32:	e8 89 f2 ff ff       	call   800fc0 <sys_ipc_recv>
  801d37:	89 c2                	mov    %eax,%edx
	if (ret) return ret;
  801d39:	83 c4 10             	add    $0x10,%esp
  801d3c:	85 d2                	test   %edx,%edx
  801d3e:	75 24                	jne    801d64 <ipc_recv+0x5f>
	if (from_env_store)
  801d40:	85 f6                	test   %esi,%esi
  801d42:	74 0a                	je     801d4e <ipc_recv+0x49>
		*from_env_store = thisenv->env_ipc_from;
  801d44:	a1 04 40 80 00       	mov    0x804004,%eax
  801d49:	8b 40 70             	mov    0x70(%eax),%eax
  801d4c:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  801d4e:	85 db                	test   %ebx,%ebx
  801d50:	74 0a                	je     801d5c <ipc_recv+0x57>
		*perm_store = thisenv->env_ipc_perm;
  801d52:	a1 04 40 80 00       	mov    0x804004,%eax
  801d57:	8b 40 74             	mov    0x74(%eax),%eax
  801d5a:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  801d5c:	a1 04 40 80 00       	mov    0x804004,%eax
  801d61:	8b 40 6c             	mov    0x6c(%eax),%eax
}
  801d64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d67:	5b                   	pop    %ebx
  801d68:	5e                   	pop    %esi
  801d69:	5d                   	pop    %ebp
  801d6a:	c3                   	ret    

00801d6b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d6b:	55                   	push   %ebp
  801d6c:	89 e5                	mov    %esp,%ebp
  801d6e:	57                   	push   %edi
  801d6f:	56                   	push   %esi
  801d70:	53                   	push   %ebx
  801d71:	83 ec 0c             	sub    $0xc,%esp
  801d74:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d77:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
  801d7d:	83 fb 01             	cmp    $0x1,%ebx
  801d80:	19 c0                	sbb    %eax,%eax
  801d82:	09 c3                	or     %eax,%ebx
  801d84:	eb 1c                	jmp    801da2 <ipc_send+0x37>
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
		if (ret == 0) break;
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
  801d86:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d89:	74 12                	je     801d9d <ipc_send+0x32>
  801d8b:	50                   	push   %eax
  801d8c:	68 04 26 80 00       	push   $0x802604
  801d91:	6a 36                	push   $0x36
  801d93:	68 1b 26 80 00       	push   $0x80261b
  801d98:	e8 0c e6 ff ff       	call   8003a9 <_panic>
		sys_yield();
  801d9d:	e8 4f f0 ff ff       	call   800df1 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 9: Your code here.
	if (!pg) pg = (void*)-1;
	int ret;
	while ((ret = sys_ipc_try_send(to_env, val, pg, perm))) {
  801da2:	ff 75 14             	pushl  0x14(%ebp)
  801da5:	53                   	push   %ebx
  801da6:	56                   	push   %esi
  801da7:	57                   	push   %edi
  801da8:	e8 f0 f1 ff ff       	call   800f9d <sys_ipc_try_send>
		if (ret == 0) break;
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	85 c0                	test   %eax,%eax
  801db2:	75 d2                	jne    801d86 <ipc_send+0x1b>
		if (ret != -E_IPC_NOT_RECV) panic("not E_IPC_NOT_RECV, %i", ret);
		sys_yield();
	}
}
  801db4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db7:	5b                   	pop    %ebx
  801db8:	5e                   	pop    %esi
  801db9:	5f                   	pop    %edi
  801dba:	5d                   	pop    %ebp
  801dbb:	c3                   	ret    

00801dbc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801dc2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dc7:	6b d0 78             	imul   $0x78,%eax,%edx
  801dca:	83 c2 50             	add    $0x50,%edx
  801dcd:	8b 92 00 00 c0 ee    	mov    -0x11400000(%edx),%edx
  801dd3:	39 ca                	cmp    %ecx,%edx
  801dd5:	75 0d                	jne    801de4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801dd7:	6b c0 78             	imul   $0x78,%eax,%eax
  801dda:	05 40 00 c0 ee       	add    $0xeec00040,%eax
  801ddf:	8b 40 08             	mov    0x8(%eax),%eax
  801de2:	eb 0e                	jmp    801df2 <ipc_find_env+0x36>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801de4:	83 c0 01             	add    $0x1,%eax
  801de7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dec:	75 d9                	jne    801dc7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801dee:	66 b8 00 00          	mov    $0x0,%ax
}
  801df2:	5d                   	pop    %ebp
  801df3:	c3                   	ret    

00801df4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801dfa:	89 d0                	mov    %edx,%eax
  801dfc:	c1 e8 16             	shr    $0x16,%eax
  801dff:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801e06:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e0b:	f6 c1 01             	test   $0x1,%cl
  801e0e:	74 1d                	je     801e2d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801e10:	c1 ea 0c             	shr    $0xc,%edx
  801e13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801e1a:	f6 c2 01             	test   $0x1,%dl
  801e1d:	74 0e                	je     801e2d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e1f:	c1 ea 0c             	shr    $0xc,%edx
  801e22:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801e29:	ef 
  801e2a:	0f b7 c0             	movzwl %ax,%eax
}
  801e2d:	5d                   	pop    %ebp
  801e2e:	c3                   	ret    
  801e2f:	90                   	nop

00801e30 <__udivdi3>:
  801e30:	55                   	push   %ebp
  801e31:	57                   	push   %edi
  801e32:	56                   	push   %esi
  801e33:	83 ec 10             	sub    $0x10,%esp
  801e36:	8b 54 24 2c          	mov    0x2c(%esp),%edx
  801e3a:	8b 7c 24 20          	mov    0x20(%esp),%edi
  801e3e:	8b 74 24 24          	mov    0x24(%esp),%esi
  801e42:	8b 4c 24 28          	mov    0x28(%esp),%ecx
  801e46:	85 d2                	test   %edx,%edx
  801e48:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801e4c:	89 34 24             	mov    %esi,(%esp)
  801e4f:	89 c8                	mov    %ecx,%eax
  801e51:	75 35                	jne    801e88 <__udivdi3+0x58>
  801e53:	39 f1                	cmp    %esi,%ecx
  801e55:	0f 87 bd 00 00 00    	ja     801f18 <__udivdi3+0xe8>
  801e5b:	85 c9                	test   %ecx,%ecx
  801e5d:	89 cd                	mov    %ecx,%ebp
  801e5f:	75 0b                	jne    801e6c <__udivdi3+0x3c>
  801e61:	b8 01 00 00 00       	mov    $0x1,%eax
  801e66:	31 d2                	xor    %edx,%edx
  801e68:	f7 f1                	div    %ecx
  801e6a:	89 c5                	mov    %eax,%ebp
  801e6c:	89 f0                	mov    %esi,%eax
  801e6e:	31 d2                	xor    %edx,%edx
  801e70:	f7 f5                	div    %ebp
  801e72:	89 c6                	mov    %eax,%esi
  801e74:	89 f8                	mov    %edi,%eax
  801e76:	f7 f5                	div    %ebp
  801e78:	89 f2                	mov    %esi,%edx
  801e7a:	83 c4 10             	add    $0x10,%esp
  801e7d:	5e                   	pop    %esi
  801e7e:	5f                   	pop    %edi
  801e7f:	5d                   	pop    %ebp
  801e80:	c3                   	ret    
  801e81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e88:	3b 14 24             	cmp    (%esp),%edx
  801e8b:	77 7b                	ja     801f08 <__udivdi3+0xd8>
  801e8d:	0f bd f2             	bsr    %edx,%esi
  801e90:	83 f6 1f             	xor    $0x1f,%esi
  801e93:	0f 84 97 00 00 00    	je     801f30 <__udivdi3+0x100>
  801e99:	bd 20 00 00 00       	mov    $0x20,%ebp
  801e9e:	89 d7                	mov    %edx,%edi
  801ea0:	89 f1                	mov    %esi,%ecx
  801ea2:	29 f5                	sub    %esi,%ebp
  801ea4:	d3 e7                	shl    %cl,%edi
  801ea6:	89 c2                	mov    %eax,%edx
  801ea8:	89 e9                	mov    %ebp,%ecx
  801eaa:	d3 ea                	shr    %cl,%edx
  801eac:	89 f1                	mov    %esi,%ecx
  801eae:	09 fa                	or     %edi,%edx
  801eb0:	8b 3c 24             	mov    (%esp),%edi
  801eb3:	d3 e0                	shl    %cl,%eax
  801eb5:	89 54 24 08          	mov    %edx,0x8(%esp)
  801eb9:	89 e9                	mov    %ebp,%ecx
  801ebb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ebf:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ec3:	89 fa                	mov    %edi,%edx
  801ec5:	d3 ea                	shr    %cl,%edx
  801ec7:	89 f1                	mov    %esi,%ecx
  801ec9:	d3 e7                	shl    %cl,%edi
  801ecb:	89 e9                	mov    %ebp,%ecx
  801ecd:	d3 e8                	shr    %cl,%eax
  801ecf:	09 c7                	or     %eax,%edi
  801ed1:	89 f8                	mov    %edi,%eax
  801ed3:	f7 74 24 08          	divl   0x8(%esp)
  801ed7:	89 d5                	mov    %edx,%ebp
  801ed9:	89 c7                	mov    %eax,%edi
  801edb:	f7 64 24 0c          	mull   0xc(%esp)
  801edf:	39 d5                	cmp    %edx,%ebp
  801ee1:	89 14 24             	mov    %edx,(%esp)
  801ee4:	72 11                	jb     801ef7 <__udivdi3+0xc7>
  801ee6:	8b 54 24 04          	mov    0x4(%esp),%edx
  801eea:	89 f1                	mov    %esi,%ecx
  801eec:	d3 e2                	shl    %cl,%edx
  801eee:	39 c2                	cmp    %eax,%edx
  801ef0:	73 5e                	jae    801f50 <__udivdi3+0x120>
  801ef2:	3b 2c 24             	cmp    (%esp),%ebp
  801ef5:	75 59                	jne    801f50 <__udivdi3+0x120>
  801ef7:	8d 47 ff             	lea    -0x1(%edi),%eax
  801efa:	31 f6                	xor    %esi,%esi
  801efc:	89 f2                	mov    %esi,%edx
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	5e                   	pop    %esi
  801f02:	5f                   	pop    %edi
  801f03:	5d                   	pop    %ebp
  801f04:	c3                   	ret    
  801f05:	8d 76 00             	lea    0x0(%esi),%esi
  801f08:	31 f6                	xor    %esi,%esi
  801f0a:	31 c0                	xor    %eax,%eax
  801f0c:	89 f2                	mov    %esi,%edx
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	5e                   	pop    %esi
  801f12:	5f                   	pop    %edi
  801f13:	5d                   	pop    %ebp
  801f14:	c3                   	ret    
  801f15:	8d 76 00             	lea    0x0(%esi),%esi
  801f18:	89 f2                	mov    %esi,%edx
  801f1a:	31 f6                	xor    %esi,%esi
  801f1c:	89 f8                	mov    %edi,%eax
  801f1e:	f7 f1                	div    %ecx
  801f20:	89 f2                	mov    %esi,%edx
  801f22:	83 c4 10             	add    $0x10,%esp
  801f25:	5e                   	pop    %esi
  801f26:	5f                   	pop    %edi
  801f27:	5d                   	pop    %ebp
  801f28:	c3                   	ret    
  801f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f30:	3b 4c 24 04          	cmp    0x4(%esp),%ecx
  801f34:	76 0b                	jbe    801f41 <__udivdi3+0x111>
  801f36:	31 c0                	xor    %eax,%eax
  801f38:	3b 14 24             	cmp    (%esp),%edx
  801f3b:	0f 83 37 ff ff ff    	jae    801e78 <__udivdi3+0x48>
  801f41:	b8 01 00 00 00       	mov    $0x1,%eax
  801f46:	e9 2d ff ff ff       	jmp    801e78 <__udivdi3+0x48>
  801f4b:	90                   	nop
  801f4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f50:	89 f8                	mov    %edi,%eax
  801f52:	31 f6                	xor    %esi,%esi
  801f54:	e9 1f ff ff ff       	jmp    801e78 <__udivdi3+0x48>
  801f59:	66 90                	xchg   %ax,%ax
  801f5b:	66 90                	xchg   %ax,%ax
  801f5d:	66 90                	xchg   %ax,%ax
  801f5f:	90                   	nop

00801f60 <__umoddi3>:
  801f60:	55                   	push   %ebp
  801f61:	57                   	push   %edi
  801f62:	56                   	push   %esi
  801f63:	83 ec 20             	sub    $0x20,%esp
  801f66:	8b 44 24 34          	mov    0x34(%esp),%eax
  801f6a:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801f6e:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f72:	89 c6                	mov    %eax,%esi
  801f74:	89 44 24 10          	mov    %eax,0x10(%esp)
  801f78:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801f7c:	89 4c 24 1c          	mov    %ecx,0x1c(%esp)
  801f80:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f84:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  801f88:	89 74 24 18          	mov    %esi,0x18(%esp)
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	89 c2                	mov    %eax,%edx
  801f90:	75 1e                	jne    801fb0 <__umoddi3+0x50>
  801f92:	39 f7                	cmp    %esi,%edi
  801f94:	76 52                	jbe    801fe8 <__umoddi3+0x88>
  801f96:	89 c8                	mov    %ecx,%eax
  801f98:	89 f2                	mov    %esi,%edx
  801f9a:	f7 f7                	div    %edi
  801f9c:	89 d0                	mov    %edx,%eax
  801f9e:	31 d2                	xor    %edx,%edx
  801fa0:	83 c4 20             	add    $0x20,%esp
  801fa3:	5e                   	pop    %esi
  801fa4:	5f                   	pop    %edi
  801fa5:	5d                   	pop    %ebp
  801fa6:	c3                   	ret    
  801fa7:	89 f6                	mov    %esi,%esi
  801fa9:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  801fb0:	39 f0                	cmp    %esi,%eax
  801fb2:	77 5c                	ja     802010 <__umoddi3+0xb0>
  801fb4:	0f bd e8             	bsr    %eax,%ebp
  801fb7:	83 f5 1f             	xor    $0x1f,%ebp
  801fba:	75 64                	jne    802020 <__umoddi3+0xc0>
  801fbc:	8b 6c 24 14          	mov    0x14(%esp),%ebp
  801fc0:	39 6c 24 0c          	cmp    %ebp,0xc(%esp)
  801fc4:	0f 86 f6 00 00 00    	jbe    8020c0 <__umoddi3+0x160>
  801fca:	3b 44 24 18          	cmp    0x18(%esp),%eax
  801fce:	0f 82 ec 00 00 00    	jb     8020c0 <__umoddi3+0x160>
  801fd4:	8b 44 24 14          	mov    0x14(%esp),%eax
  801fd8:	8b 54 24 18          	mov    0x18(%esp),%edx
  801fdc:	83 c4 20             	add    $0x20,%esp
  801fdf:	5e                   	pop    %esi
  801fe0:	5f                   	pop    %edi
  801fe1:	5d                   	pop    %ebp
  801fe2:	c3                   	ret    
  801fe3:	90                   	nop
  801fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fe8:	85 ff                	test   %edi,%edi
  801fea:	89 fd                	mov    %edi,%ebp
  801fec:	75 0b                	jne    801ff9 <__umoddi3+0x99>
  801fee:	b8 01 00 00 00       	mov    $0x1,%eax
  801ff3:	31 d2                	xor    %edx,%edx
  801ff5:	f7 f7                	div    %edi
  801ff7:	89 c5                	mov    %eax,%ebp
  801ff9:	8b 44 24 10          	mov    0x10(%esp),%eax
  801ffd:	31 d2                	xor    %edx,%edx
  801fff:	f7 f5                	div    %ebp
  802001:	89 c8                	mov    %ecx,%eax
  802003:	f7 f5                	div    %ebp
  802005:	eb 95                	jmp    801f9c <__umoddi3+0x3c>
  802007:	89 f6                	mov    %esi,%esi
  802009:	8d bc 27 00 00 00 00 	lea    0x0(%edi,%eiz,1),%edi
  802010:	89 c8                	mov    %ecx,%eax
  802012:	89 f2                	mov    %esi,%edx
  802014:	83 c4 20             	add    $0x20,%esp
  802017:	5e                   	pop    %esi
  802018:	5f                   	pop    %edi
  802019:	5d                   	pop    %ebp
  80201a:	c3                   	ret    
  80201b:	90                   	nop
  80201c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802020:	b8 20 00 00 00       	mov    $0x20,%eax
  802025:	89 e9                	mov    %ebp,%ecx
  802027:	29 e8                	sub    %ebp,%eax
  802029:	d3 e2                	shl    %cl,%edx
  80202b:	89 c7                	mov    %eax,%edi
  80202d:	89 44 24 18          	mov    %eax,0x18(%esp)
  802031:	8b 44 24 0c          	mov    0xc(%esp),%eax
  802035:	89 f9                	mov    %edi,%ecx
  802037:	d3 e8                	shr    %cl,%eax
  802039:	89 c1                	mov    %eax,%ecx
  80203b:	8b 44 24 0c          	mov    0xc(%esp),%eax
  80203f:	09 d1                	or     %edx,%ecx
  802041:	89 fa                	mov    %edi,%edx
  802043:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  802047:	89 e9                	mov    %ebp,%ecx
  802049:	d3 e0                	shl    %cl,%eax
  80204b:	89 f9                	mov    %edi,%ecx
  80204d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802051:	89 f0                	mov    %esi,%eax
  802053:	d3 e8                	shr    %cl,%eax
  802055:	89 e9                	mov    %ebp,%ecx
  802057:	89 c7                	mov    %eax,%edi
  802059:	8b 44 24 1c          	mov    0x1c(%esp),%eax
  80205d:	d3 e6                	shl    %cl,%esi
  80205f:	89 d1                	mov    %edx,%ecx
  802061:	89 fa                	mov    %edi,%edx
  802063:	d3 e8                	shr    %cl,%eax
  802065:	89 e9                	mov    %ebp,%ecx
  802067:	09 f0                	or     %esi,%eax
  802069:	8b 74 24 1c          	mov    0x1c(%esp),%esi
  80206d:	f7 74 24 10          	divl   0x10(%esp)
  802071:	d3 e6                	shl    %cl,%esi
  802073:	89 d1                	mov    %edx,%ecx
  802075:	f7 64 24 0c          	mull   0xc(%esp)
  802079:	39 d1                	cmp    %edx,%ecx
  80207b:	89 74 24 14          	mov    %esi,0x14(%esp)
  80207f:	89 d7                	mov    %edx,%edi
  802081:	89 c6                	mov    %eax,%esi
  802083:	72 0a                	jb     80208f <__umoddi3+0x12f>
  802085:	39 44 24 14          	cmp    %eax,0x14(%esp)
  802089:	73 10                	jae    80209b <__umoddi3+0x13b>
  80208b:	39 d1                	cmp    %edx,%ecx
  80208d:	75 0c                	jne    80209b <__umoddi3+0x13b>
  80208f:	89 d7                	mov    %edx,%edi
  802091:	89 c6                	mov    %eax,%esi
  802093:	2b 74 24 0c          	sub    0xc(%esp),%esi
  802097:	1b 7c 24 10          	sbb    0x10(%esp),%edi
  80209b:	89 ca                	mov    %ecx,%edx
  80209d:	89 e9                	mov    %ebp,%ecx
  80209f:	8b 44 24 14          	mov    0x14(%esp),%eax
  8020a3:	29 f0                	sub    %esi,%eax
  8020a5:	19 fa                	sbb    %edi,%edx
  8020a7:	d3 e8                	shr    %cl,%eax
  8020a9:	0f b6 4c 24 18       	movzbl 0x18(%esp),%ecx
  8020ae:	89 d7                	mov    %edx,%edi
  8020b0:	d3 e7                	shl    %cl,%edi
  8020b2:	89 e9                	mov    %ebp,%ecx
  8020b4:	09 f8                	or     %edi,%eax
  8020b6:	d3 ea                	shr    %cl,%edx
  8020b8:	83 c4 20             	add    $0x20,%esp
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    
  8020bf:	90                   	nop
  8020c0:	8b 74 24 10          	mov    0x10(%esp),%esi
  8020c4:	29 f9                	sub    %edi,%ecx
  8020c6:	19 c6                	sbb    %eax,%esi
  8020c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8020cc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8020d0:	e9 ff fe ff ff       	jmp    801fd4 <__umoddi3+0x74>