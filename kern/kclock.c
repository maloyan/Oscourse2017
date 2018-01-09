/* See COPYRIGHT for copyright information. */

#include <inc/x86.h>
#include <kern/kclock.h>
#include <inc/time.h>

int get_time()
{
	struct tm time;
	time.tm_sec = BCD2BIN(mc146818_read(RTC_SEC));
	time.tm_min = BCD2BIN(mc146818_read(RTC_MIN));
	time.tm_hour = BCD2BIN(mc146818_read(RTC_HOUR));
	time.tm_mday = BCD2BIN(mc146818_read(RTC_DAY));
	time.tm_mon = BCD2BIN(mc146818_read(RTC_MON)) - 1;
	time.tm_year = BCD2BIN(mc146818_read(RTC_YEAR));
	return timestamp(&time);
}

int gettime(void)
{
	nmi_disable();
	// LAB 12: your code here
	int t1, t2;
	do {
	  t1 = get_time();
	  t2 = get_time();
	} while (!(mc146818_read(RTC_AREG)& RTC_UPDATE_IN_PROGRESS) && t1 != t2);

	nmi_enable();
	return t1;
}

void
rtc_init(void)
{
	nmi_disable();
	// LAB 4: your code here
	// 1. Переключение на регистр часов B.
	// 2. Чтение значения регистра B из порта ввода-вывода.
	// 3. Установка бита RTC_PIE.
	// 4. Запись обновленного значения регистра в порт ввода-вывода.
	
	outb(IO_RTC_CMND, RTC_BREG);
	uint8_t regB = inb(IO_RTC_DATA);
	regB = regB | RTC_PIE;
	outb(IO_RTC_DATA, regB);

	// Измените процедуру rtc_init так, чтобы прерывания от часов приходили один раз в полсекунды.
	// Для этого необходимо изменить делитель частоты, которому соответствуют младшие 4 бита регистра часов A.

	outb(IO_RTC_CMND, RTC_AREG);
	uint8_t regA = inb(IO_RTC_DATA);
	regA = regA ;
	//outb(IO_RTC_CMND, RTC_AREG);
	outb(IO_RTC_DATA, regA);

	nmi_enable();
}

uint8_t
rtc_check_status(void)
{
	uint8_t status = 0;
	// LAB 4: your code here
	// Для проверки статуса часов в функции rtc_check_status необходимо прочитать значение регистра часов C.
	outb(IO_RTC_CMND, RTC_CREG);
	status = inb(IO_RTC_DATA);
	return status;
}

unsigned
mc146818_read(unsigned reg)
{
	outb(IO_RTC_CMND, reg);
	return inb(IO_RTC_DATA);
}

void
mc146818_write(unsigned reg, unsigned datum)
{
	outb(IO_RTC_CMND, reg);
	outb(IO_RTC_DATA, datum);
}

