
obj/user/faultread:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0!\n", *(unsigned*)0);
  80003d:	ff 35 00 00 00 00    	pushl  0x0
  800043:	68 20 10 80 00       	push   $0x801020
  800048:	e8 05 01 00 00       	call   800152 <cprintf>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800061:	e8 f2 0a 00 00       	call   800b58 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800066:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006b:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800071:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800076:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007b:	85 db                	test   %ebx,%ebx
  80007d:	7e 07                	jle    800086 <libmain+0x34>
		binaryname = argv[0];
  80007f:	8b 06                	mov    (%esi),%eax
  800081:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800086:	83 ec 08             	sub    $0x8,%esp
  800089:	56                   	push   %esi
  80008a:	53                   	push   %ebx
  80008b:	e8 a3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800090:	e8 0a 00 00 00       	call   80009f <exit>
}
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5e                   	pop    %esi
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    

0080009f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009f:	f3 0f 1e fb          	endbr32 
  8000a3:	55                   	push   %ebp
  8000a4:	89 e5                	mov    %esp,%ebp
  8000a6:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a9:	6a 00                	push   $0x0
  8000ab:	e8 63 0a 00 00       	call   800b13 <sys_env_destroy>
}
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000b5:	f3 0f 1e fb          	endbr32 
  8000b9:	55                   	push   %ebp
  8000ba:	89 e5                	mov    %esp,%ebp
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c3:	8b 13                	mov    (%ebx),%edx
  8000c5:	8d 42 01             	lea    0x1(%edx),%eax
  8000c8:	89 03                	mov    %eax,(%ebx)
  8000ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000d6:	74 09                	je     8000e1 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000d8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000df:	c9                   	leave  
  8000e0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000e1:	83 ec 08             	sub    $0x8,%esp
  8000e4:	68 ff 00 00 00       	push   $0xff
  8000e9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ec:	50                   	push   %eax
  8000ed:	e8 dc 09 00 00       	call   800ace <sys_cputs>
		b->idx = 0;
  8000f2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	eb db                	jmp    8000d8 <putch+0x23>

008000fd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000fd:	f3 0f 1e fb          	endbr32 
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800111:	00 00 00 
	b.cnt = 0;
  800114:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011e:	ff 75 0c             	pushl  0xc(%ebp)
  800121:	ff 75 08             	pushl  0x8(%ebp)
  800124:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012a:	50                   	push   %eax
  80012b:	68 b5 00 80 00       	push   $0x8000b5
  800130:	e8 20 01 00 00       	call   800255 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800135:	83 c4 08             	add    $0x8,%esp
  800138:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800144:	50                   	push   %eax
  800145:	e8 84 09 00 00       	call   800ace <sys_cputs>

	return b.cnt;
}
  80014a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800150:	c9                   	leave  
  800151:	c3                   	ret    

00800152 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800152:	f3 0f 1e fb          	endbr32 
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80015c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015f:	50                   	push   %eax
  800160:	ff 75 08             	pushl  0x8(%ebp)
  800163:	e8 95 ff ff ff       	call   8000fd <vcprintf>
	va_end(ap);

	return cnt;
}
  800168:	c9                   	leave  
  800169:	c3                   	ret    

0080016a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 1c             	sub    $0x1c,%esp
  800173:	89 c7                	mov    %eax,%edi
  800175:	89 d6                	mov    %edx,%esi
  800177:	8b 45 08             	mov    0x8(%ebp),%eax
  80017a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017d:	89 d1                	mov    %edx,%ecx
  80017f:	89 c2                	mov    %eax,%edx
  800181:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800184:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800187:	8b 45 10             	mov    0x10(%ebp),%eax
  80018a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800190:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800197:	39 c2                	cmp    %eax,%edx
  800199:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80019c:	72 3e                	jb     8001dc <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80019e:	83 ec 0c             	sub    $0xc,%esp
  8001a1:	ff 75 18             	pushl  0x18(%ebp)
  8001a4:	83 eb 01             	sub    $0x1,%ebx
  8001a7:	53                   	push   %ebx
  8001a8:	50                   	push   %eax
  8001a9:	83 ec 08             	sub    $0x8,%esp
  8001ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001af:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b8:	e8 03 0c 00 00       	call   800dc0 <__udivdi3>
  8001bd:	83 c4 18             	add    $0x18,%esp
  8001c0:	52                   	push   %edx
  8001c1:	50                   	push   %eax
  8001c2:	89 f2                	mov    %esi,%edx
  8001c4:	89 f8                	mov    %edi,%eax
  8001c6:	e8 9f ff ff ff       	call   80016a <printnum>
  8001cb:	83 c4 20             	add    $0x20,%esp
  8001ce:	eb 13                	jmp    8001e3 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001d0:	83 ec 08             	sub    $0x8,%esp
  8001d3:	56                   	push   %esi
  8001d4:	ff 75 18             	pushl  0x18(%ebp)
  8001d7:	ff d7                	call   *%edi
  8001d9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001dc:	83 eb 01             	sub    $0x1,%ebx
  8001df:	85 db                	test   %ebx,%ebx
  8001e1:	7f ed                	jg     8001d0 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	56                   	push   %esi
  8001e7:	83 ec 04             	sub    $0x4,%esp
  8001ea:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ed:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f6:	e8 d5 0c 00 00       	call   800ed0 <__umoddi3>
  8001fb:	83 c4 14             	add    $0x14,%esp
  8001fe:	0f be 80 48 10 80 00 	movsbl 0x801048(%eax),%eax
  800205:	50                   	push   %eax
  800206:	ff d7                	call   *%edi
}
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020e:	5b                   	pop    %ebx
  80020f:	5e                   	pop    %esi
  800210:	5f                   	pop    %edi
  800211:	5d                   	pop    %ebp
  800212:	c3                   	ret    

00800213 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800213:	f3 0f 1e fb          	endbr32 
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800221:	8b 10                	mov    (%eax),%edx
  800223:	3b 50 04             	cmp    0x4(%eax),%edx
  800226:	73 0a                	jae    800232 <sprintputch+0x1f>
		*b->buf++ = ch;
  800228:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022b:	89 08                	mov    %ecx,(%eax)
  80022d:	8b 45 08             	mov    0x8(%ebp),%eax
  800230:	88 02                	mov    %al,(%edx)
}
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    

00800234 <printfmt>:
{
  800234:	f3 0f 1e fb          	endbr32 
  800238:	55                   	push   %ebp
  800239:	89 e5                	mov    %esp,%ebp
  80023b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80023e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800241:	50                   	push   %eax
  800242:	ff 75 10             	pushl  0x10(%ebp)
  800245:	ff 75 0c             	pushl  0xc(%ebp)
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	e8 05 00 00 00       	call   800255 <vprintfmt>
}
  800250:	83 c4 10             	add    $0x10,%esp
  800253:	c9                   	leave  
  800254:	c3                   	ret    

00800255 <vprintfmt>:
{
  800255:	f3 0f 1e fb          	endbr32 
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	57                   	push   %edi
  80025d:	56                   	push   %esi
  80025e:	53                   	push   %ebx
  80025f:	83 ec 3c             	sub    $0x3c,%esp
  800262:	8b 75 08             	mov    0x8(%ebp),%esi
  800265:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800268:	8b 7d 10             	mov    0x10(%ebp),%edi
  80026b:	e9 8e 03 00 00       	jmp    8005fe <vprintfmt+0x3a9>
		padc = ' ';
  800270:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800274:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80027b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800282:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800289:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80028e:	8d 47 01             	lea    0x1(%edi),%eax
  800291:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800294:	0f b6 17             	movzbl (%edi),%edx
  800297:	8d 42 dd             	lea    -0x23(%edx),%eax
  80029a:	3c 55                	cmp    $0x55,%al
  80029c:	0f 87 df 03 00 00    	ja     800681 <vprintfmt+0x42c>
  8002a2:	0f b6 c0             	movzbl %al,%eax
  8002a5:	3e ff 24 85 00 11 80 	notrack jmp *0x801100(,%eax,4)
  8002ac:	00 
  8002ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002b0:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002b4:	eb d8                	jmp    80028e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002b9:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002bd:	eb cf                	jmp    80028e <vprintfmt+0x39>
  8002bf:	0f b6 d2             	movzbl %dl,%edx
  8002c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002ca:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002cd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002d0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002da:	83 f9 09             	cmp    $0x9,%ecx
  8002dd:	77 55                	ja     800334 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002df:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002e2:	eb e9                	jmp    8002cd <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e7:	8b 00                	mov    (%eax),%eax
  8002e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ef:	8d 40 04             	lea    0x4(%eax),%eax
  8002f2:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8002f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8002f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8002fc:	79 90                	jns    80028e <vprintfmt+0x39>
				width = precision, precision = -1;
  8002fe:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800301:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800304:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80030b:	eb 81                	jmp    80028e <vprintfmt+0x39>
  80030d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800310:	85 c0                	test   %eax,%eax
  800312:	ba 00 00 00 00       	mov    $0x0,%edx
  800317:	0f 49 d0             	cmovns %eax,%edx
  80031a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80031d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800320:	e9 69 ff ff ff       	jmp    80028e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800325:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800328:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80032f:	e9 5a ff ff ff       	jmp    80028e <vprintfmt+0x39>
  800334:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800337:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033a:	eb bc                	jmp    8002f8 <vprintfmt+0xa3>
			lflag++;
  80033c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80033f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800342:	e9 47 ff ff ff       	jmp    80028e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800347:	8b 45 14             	mov    0x14(%ebp),%eax
  80034a:	8d 78 04             	lea    0x4(%eax),%edi
  80034d:	83 ec 08             	sub    $0x8,%esp
  800350:	53                   	push   %ebx
  800351:	ff 30                	pushl  (%eax)
  800353:	ff d6                	call   *%esi
			break;
  800355:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800358:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80035b:	e9 9b 02 00 00       	jmp    8005fb <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800360:	8b 45 14             	mov    0x14(%ebp),%eax
  800363:	8d 78 04             	lea    0x4(%eax),%edi
  800366:	8b 00                	mov    (%eax),%eax
  800368:	99                   	cltd   
  800369:	31 d0                	xor    %edx,%eax
  80036b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80036d:	83 f8 08             	cmp    $0x8,%eax
  800370:	7f 23                	jg     800395 <vprintfmt+0x140>
  800372:	8b 14 85 60 12 80 00 	mov    0x801260(,%eax,4),%edx
  800379:	85 d2                	test   %edx,%edx
  80037b:	74 18                	je     800395 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80037d:	52                   	push   %edx
  80037e:	68 69 10 80 00       	push   $0x801069
  800383:	53                   	push   %ebx
  800384:	56                   	push   %esi
  800385:	e8 aa fe ff ff       	call   800234 <printfmt>
  80038a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80038d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800390:	e9 66 02 00 00       	jmp    8005fb <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  800395:	50                   	push   %eax
  800396:	68 60 10 80 00       	push   $0x801060
  80039b:	53                   	push   %ebx
  80039c:	56                   	push   %esi
  80039d:	e8 92 fe ff ff       	call   800234 <printfmt>
  8003a2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003a5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003a8:	e9 4e 02 00 00       	jmp    8005fb <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b0:	83 c0 04             	add    $0x4,%eax
  8003b3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003bb:	85 d2                	test   %edx,%edx
  8003bd:	b8 59 10 80 00       	mov    $0x801059,%eax
  8003c2:	0f 45 c2             	cmovne %edx,%eax
  8003c5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003c8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003cc:	7e 06                	jle    8003d4 <vprintfmt+0x17f>
  8003ce:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003d2:	75 0d                	jne    8003e1 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003d4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003d7:	89 c7                	mov    %eax,%edi
  8003d9:	03 45 e0             	add    -0x20(%ebp),%eax
  8003dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003df:	eb 55                	jmp    800436 <vprintfmt+0x1e1>
  8003e1:	83 ec 08             	sub    $0x8,%esp
  8003e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003e7:	ff 75 cc             	pushl  -0x34(%ebp)
  8003ea:	e8 46 03 00 00       	call   800735 <strnlen>
  8003ef:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003f2:	29 c2                	sub    %eax,%edx
  8003f4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  8003f7:	83 c4 10             	add    $0x10,%esp
  8003fa:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  8003fc:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800400:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800403:	85 ff                	test   %edi,%edi
  800405:	7e 11                	jle    800418 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800407:	83 ec 08             	sub    $0x8,%esp
  80040a:	53                   	push   %ebx
  80040b:	ff 75 e0             	pushl  -0x20(%ebp)
  80040e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800410:	83 ef 01             	sub    $0x1,%edi
  800413:	83 c4 10             	add    $0x10,%esp
  800416:	eb eb                	jmp    800403 <vprintfmt+0x1ae>
  800418:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80041b:	85 d2                	test   %edx,%edx
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
  800422:	0f 49 c2             	cmovns %edx,%eax
  800425:	29 c2                	sub    %eax,%edx
  800427:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80042a:	eb a8                	jmp    8003d4 <vprintfmt+0x17f>
					putch(ch, putdat);
  80042c:	83 ec 08             	sub    $0x8,%esp
  80042f:	53                   	push   %ebx
  800430:	52                   	push   %edx
  800431:	ff d6                	call   *%esi
  800433:	83 c4 10             	add    $0x10,%esp
  800436:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800439:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80043b:	83 c7 01             	add    $0x1,%edi
  80043e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800442:	0f be d0             	movsbl %al,%edx
  800445:	85 d2                	test   %edx,%edx
  800447:	74 4b                	je     800494 <vprintfmt+0x23f>
  800449:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80044d:	78 06                	js     800455 <vprintfmt+0x200>
  80044f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800453:	78 1e                	js     800473 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800455:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800459:	74 d1                	je     80042c <vprintfmt+0x1d7>
  80045b:	0f be c0             	movsbl %al,%eax
  80045e:	83 e8 20             	sub    $0x20,%eax
  800461:	83 f8 5e             	cmp    $0x5e,%eax
  800464:	76 c6                	jbe    80042c <vprintfmt+0x1d7>
					putch('?', putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	53                   	push   %ebx
  80046a:	6a 3f                	push   $0x3f
  80046c:	ff d6                	call   *%esi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb c3                	jmp    800436 <vprintfmt+0x1e1>
  800473:	89 cf                	mov    %ecx,%edi
  800475:	eb 0e                	jmp    800485 <vprintfmt+0x230>
				putch(' ', putdat);
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	53                   	push   %ebx
  80047b:	6a 20                	push   $0x20
  80047d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80047f:	83 ef 01             	sub    $0x1,%edi
  800482:	83 c4 10             	add    $0x10,%esp
  800485:	85 ff                	test   %edi,%edi
  800487:	7f ee                	jg     800477 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800489:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80048c:	89 45 14             	mov    %eax,0x14(%ebp)
  80048f:	e9 67 01 00 00       	jmp    8005fb <vprintfmt+0x3a6>
  800494:	89 cf                	mov    %ecx,%edi
  800496:	eb ed                	jmp    800485 <vprintfmt+0x230>
	if (lflag >= 2)
  800498:	83 f9 01             	cmp    $0x1,%ecx
  80049b:	7f 1b                	jg     8004b8 <vprintfmt+0x263>
	else if (lflag)
  80049d:	85 c9                	test   %ecx,%ecx
  80049f:	74 63                	je     800504 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a4:	8b 00                	mov    (%eax),%eax
  8004a6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a9:	99                   	cltd   
  8004aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b0:	8d 40 04             	lea    0x4(%eax),%eax
  8004b3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004b6:	eb 17                	jmp    8004cf <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004bb:	8b 50 04             	mov    0x4(%eax),%edx
  8004be:	8b 00                	mov    (%eax),%eax
  8004c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c9:	8d 40 08             	lea    0x8(%eax),%eax
  8004cc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004cf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004d2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004d5:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004da:	85 c9                	test   %ecx,%ecx
  8004dc:	0f 89 ff 00 00 00    	jns    8005e1 <vprintfmt+0x38c>
				putch('-', putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	6a 2d                	push   $0x2d
  8004e8:	ff d6                	call   *%esi
				num = -(long long) num;
  8004ea:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004ed:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8004f0:	f7 da                	neg    %edx
  8004f2:	83 d1 00             	adc    $0x0,%ecx
  8004f5:	f7 d9                	neg    %ecx
  8004f7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8004fa:	b8 0a 00 00 00       	mov    $0xa,%eax
  8004ff:	e9 dd 00 00 00       	jmp    8005e1 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8b 00                	mov    (%eax),%eax
  800509:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050c:	99                   	cltd   
  80050d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 40 04             	lea    0x4(%eax),%eax
  800516:	89 45 14             	mov    %eax,0x14(%ebp)
  800519:	eb b4                	jmp    8004cf <vprintfmt+0x27a>
	if (lflag >= 2)
  80051b:	83 f9 01             	cmp    $0x1,%ecx
  80051e:	7f 1e                	jg     80053e <vprintfmt+0x2e9>
	else if (lflag)
  800520:	85 c9                	test   %ecx,%ecx
  800522:	74 32                	je     800556 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800524:	8b 45 14             	mov    0x14(%ebp),%eax
  800527:	8b 10                	mov    (%eax),%edx
  800529:	b9 00 00 00 00       	mov    $0x0,%ecx
  80052e:	8d 40 04             	lea    0x4(%eax),%eax
  800531:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800534:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800539:	e9 a3 00 00 00       	jmp    8005e1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80053e:	8b 45 14             	mov    0x14(%ebp),%eax
  800541:	8b 10                	mov    (%eax),%edx
  800543:	8b 48 04             	mov    0x4(%eax),%ecx
  800546:	8d 40 08             	lea    0x8(%eax),%eax
  800549:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80054c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800551:	e9 8b 00 00 00       	jmp    8005e1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800556:	8b 45 14             	mov    0x14(%ebp),%eax
  800559:	8b 10                	mov    (%eax),%edx
  80055b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800560:	8d 40 04             	lea    0x4(%eax),%eax
  800563:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800566:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80056b:	eb 74                	jmp    8005e1 <vprintfmt+0x38c>
	if (lflag >= 2)
  80056d:	83 f9 01             	cmp    $0x1,%ecx
  800570:	7f 1b                	jg     80058d <vprintfmt+0x338>
	else if (lflag)
  800572:	85 c9                	test   %ecx,%ecx
  800574:	74 2c                	je     8005a2 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 10                	mov    (%eax),%edx
  80057b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800580:	8d 40 04             	lea    0x4(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800586:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80058b:	eb 54                	jmp    8005e1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 10                	mov    (%eax),%edx
  800592:	8b 48 04             	mov    0x4(%eax),%ecx
  800595:	8d 40 08             	lea    0x8(%eax),%eax
  800598:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  80059b:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005a0:	eb 3f                	jmp    8005e1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005b2:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005b7:	eb 28                	jmp    8005e1 <vprintfmt+0x38c>
			putch('0', putdat);
  8005b9:	83 ec 08             	sub    $0x8,%esp
  8005bc:	53                   	push   %ebx
  8005bd:	6a 30                	push   $0x30
  8005bf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005c1:	83 c4 08             	add    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	6a 78                	push   $0x78
  8005c7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005d3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005d6:	8d 40 04             	lea    0x4(%eax),%eax
  8005d9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005dc:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005e1:	83 ec 0c             	sub    $0xc,%esp
  8005e4:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005e8:	57                   	push   %edi
  8005e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005ec:	50                   	push   %eax
  8005ed:	51                   	push   %ecx
  8005ee:	52                   	push   %edx
  8005ef:	89 da                	mov    %ebx,%edx
  8005f1:	89 f0                	mov    %esi,%eax
  8005f3:	e8 72 fb ff ff       	call   80016a <printnum>
			break;
  8005f8:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  8005fb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  8005fe:	83 c7 01             	add    $0x1,%edi
  800601:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800605:	83 f8 25             	cmp    $0x25,%eax
  800608:	0f 84 62 fc ff ff    	je     800270 <vprintfmt+0x1b>
			if (ch == '\0')										
  80060e:	85 c0                	test   %eax,%eax
  800610:	0f 84 8b 00 00 00    	je     8006a1 <vprintfmt+0x44c>
			putch(ch, putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	50                   	push   %eax
  80061b:	ff d6                	call   *%esi
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	eb dc                	jmp    8005fe <vprintfmt+0x3a9>
	if (lflag >= 2)
  800622:	83 f9 01             	cmp    $0x1,%ecx
  800625:	7f 1b                	jg     800642 <vprintfmt+0x3ed>
	else if (lflag)
  800627:	85 c9                	test   %ecx,%ecx
  800629:	74 2c                	je     800657 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8b 10                	mov    (%eax),%edx
  800630:	b9 00 00 00 00       	mov    $0x0,%ecx
  800635:	8d 40 04             	lea    0x4(%eax),%eax
  800638:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80063b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800640:	eb 9f                	jmp    8005e1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8b 10                	mov    (%eax),%edx
  800647:	8b 48 04             	mov    0x4(%eax),%ecx
  80064a:	8d 40 08             	lea    0x8(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800650:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800655:	eb 8a                	jmp    8005e1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80066c:	e9 70 ff ff ff       	jmp    8005e1 <vprintfmt+0x38c>
			putch(ch, putdat);
  800671:	83 ec 08             	sub    $0x8,%esp
  800674:	53                   	push   %ebx
  800675:	6a 25                	push   $0x25
  800677:	ff d6                	call   *%esi
			break;
  800679:	83 c4 10             	add    $0x10,%esp
  80067c:	e9 7a ff ff ff       	jmp    8005fb <vprintfmt+0x3a6>
			putch('%', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 25                	push   $0x25
  800687:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	89 f8                	mov    %edi,%eax
  80068e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800692:	74 05                	je     800699 <vprintfmt+0x444>
  800694:	83 e8 01             	sub    $0x1,%eax
  800697:	eb f5                	jmp    80068e <vprintfmt+0x439>
  800699:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80069c:	e9 5a ff ff ff       	jmp    8005fb <vprintfmt+0x3a6>
}
  8006a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006a4:	5b                   	pop    %ebx
  8006a5:	5e                   	pop    %esi
  8006a6:	5f                   	pop    %edi
  8006a7:	5d                   	pop    %ebp
  8006a8:	c3                   	ret    

008006a9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a9:	f3 0f 1e fb          	endbr32 
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	83 ec 18             	sub    $0x18,%esp
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006ca:	85 c0                	test   %eax,%eax
  8006cc:	74 26                	je     8006f4 <vsnprintf+0x4b>
  8006ce:	85 d2                	test   %edx,%edx
  8006d0:	7e 22                	jle    8006f4 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d2:	ff 75 14             	pushl  0x14(%ebp)
  8006d5:	ff 75 10             	pushl  0x10(%ebp)
  8006d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	68 13 02 80 00       	push   $0x800213
  8006e1:	e8 6f fb ff ff       	call   800255 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ef:	83 c4 10             	add    $0x10,%esp
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    
		return -E_INVAL;
  8006f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006f9:	eb f7                	jmp    8006f2 <vsnprintf+0x49>

008006fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006fb:	f3 0f 1e fb          	endbr32 
  8006ff:	55                   	push   %ebp
  800700:	89 e5                	mov    %esp,%ebp
  800702:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800705:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800708:	50                   	push   %eax
  800709:	ff 75 10             	pushl  0x10(%ebp)
  80070c:	ff 75 0c             	pushl  0xc(%ebp)
  80070f:	ff 75 08             	pushl  0x8(%ebp)
  800712:	e8 92 ff ff ff       	call   8006a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800717:	c9                   	leave  
  800718:	c3                   	ret    

00800719 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800719:	f3 0f 1e fb          	endbr32 
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800723:	b8 00 00 00 00       	mov    $0x0,%eax
  800728:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80072c:	74 05                	je     800733 <strlen+0x1a>
		n++;
  80072e:	83 c0 01             	add    $0x1,%eax
  800731:	eb f5                	jmp    800728 <strlen+0xf>
	return n;
}
  800733:	5d                   	pop    %ebp
  800734:	c3                   	ret    

00800735 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800735:	f3 0f 1e fb          	endbr32 
  800739:	55                   	push   %ebp
  80073a:	89 e5                	mov    %esp,%ebp
  80073c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800742:	b8 00 00 00 00       	mov    $0x0,%eax
  800747:	39 d0                	cmp    %edx,%eax
  800749:	74 0d                	je     800758 <strnlen+0x23>
  80074b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80074f:	74 05                	je     800756 <strnlen+0x21>
		n++;
  800751:	83 c0 01             	add    $0x1,%eax
  800754:	eb f1                	jmp    800747 <strnlen+0x12>
  800756:	89 c2                	mov    %eax,%edx
	return n;
}
  800758:	89 d0                	mov    %edx,%eax
  80075a:	5d                   	pop    %ebp
  80075b:	c3                   	ret    

0080075c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80075c:	f3 0f 1e fb          	endbr32 
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	53                   	push   %ebx
  800764:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800767:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076a:	b8 00 00 00 00       	mov    $0x0,%eax
  80076f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800773:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800776:	83 c0 01             	add    $0x1,%eax
  800779:	84 d2                	test   %dl,%dl
  80077b:	75 f2                	jne    80076f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80077d:	89 c8                	mov    %ecx,%eax
  80077f:	5b                   	pop    %ebx
  800780:	5d                   	pop    %ebp
  800781:	c3                   	ret    

00800782 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800782:	f3 0f 1e fb          	endbr32 
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	53                   	push   %ebx
  80078a:	83 ec 10             	sub    $0x10,%esp
  80078d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800790:	53                   	push   %ebx
  800791:	e8 83 ff ff ff       	call   800719 <strlen>
  800796:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800799:	ff 75 0c             	pushl  0xc(%ebp)
  80079c:	01 d8                	add    %ebx,%eax
  80079e:	50                   	push   %eax
  80079f:	e8 b8 ff ff ff       	call   80075c <strcpy>
	return dst;
}
  8007a4:	89 d8                	mov    %ebx,%eax
  8007a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ab:	f3 0f 1e fb          	endbr32 
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ba:	89 f3                	mov    %esi,%ebx
  8007bc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bf:	89 f0                	mov    %esi,%eax
  8007c1:	39 d8                	cmp    %ebx,%eax
  8007c3:	74 11                	je     8007d6 <strncpy+0x2b>
		*dst++ = *src;
  8007c5:	83 c0 01             	add    $0x1,%eax
  8007c8:	0f b6 0a             	movzbl (%edx),%ecx
  8007cb:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ce:	80 f9 01             	cmp    $0x1,%cl
  8007d1:	83 da ff             	sbb    $0xffffffff,%edx
  8007d4:	eb eb                	jmp    8007c1 <strncpy+0x16>
	}
	return ret;
}
  8007d6:	89 f0                	mov    %esi,%eax
  8007d8:	5b                   	pop    %ebx
  8007d9:	5e                   	pop    %esi
  8007da:	5d                   	pop    %ebp
  8007db:	c3                   	ret    

008007dc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007dc:	f3 0f 1e fb          	endbr32 
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	56                   	push   %esi
  8007e4:	53                   	push   %ebx
  8007e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007eb:	8b 55 10             	mov    0x10(%ebp),%edx
  8007ee:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f0:	85 d2                	test   %edx,%edx
  8007f2:	74 21                	je     800815 <strlcpy+0x39>
  8007f4:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007f8:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8007fa:	39 c2                	cmp    %eax,%edx
  8007fc:	74 14                	je     800812 <strlcpy+0x36>
  8007fe:	0f b6 19             	movzbl (%ecx),%ebx
  800801:	84 db                	test   %bl,%bl
  800803:	74 0b                	je     800810 <strlcpy+0x34>
			*dst++ = *src++;
  800805:	83 c1 01             	add    $0x1,%ecx
  800808:	83 c2 01             	add    $0x1,%edx
  80080b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80080e:	eb ea                	jmp    8007fa <strlcpy+0x1e>
  800810:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800812:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800815:	29 f0                	sub    %esi,%eax
}
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80081b:	f3 0f 1e fb          	endbr32 
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800828:	0f b6 01             	movzbl (%ecx),%eax
  80082b:	84 c0                	test   %al,%al
  80082d:	74 0c                	je     80083b <strcmp+0x20>
  80082f:	3a 02                	cmp    (%edx),%al
  800831:	75 08                	jne    80083b <strcmp+0x20>
		p++, q++;
  800833:	83 c1 01             	add    $0x1,%ecx
  800836:	83 c2 01             	add    $0x1,%edx
  800839:	eb ed                	jmp    800828 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 c0             	movzbl %al,%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
}
  800843:	5d                   	pop    %ebp
  800844:	c3                   	ret    

00800845 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800845:	f3 0f 1e fb          	endbr32 
  800849:	55                   	push   %ebp
  80084a:	89 e5                	mov    %esp,%ebp
  80084c:	53                   	push   %ebx
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 c3                	mov    %eax,%ebx
  800855:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800858:	eb 06                	jmp    800860 <strncmp+0x1b>
		n--, p++, q++;
  80085a:	83 c0 01             	add    $0x1,%eax
  80085d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800860:	39 d8                	cmp    %ebx,%eax
  800862:	74 16                	je     80087a <strncmp+0x35>
  800864:	0f b6 08             	movzbl (%eax),%ecx
  800867:	84 c9                	test   %cl,%cl
  800869:	74 04                	je     80086f <strncmp+0x2a>
  80086b:	3a 0a                	cmp    (%edx),%cl
  80086d:	74 eb                	je     80085a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086f:	0f b6 00             	movzbl (%eax),%eax
  800872:	0f b6 12             	movzbl (%edx),%edx
  800875:	29 d0                	sub    %edx,%eax
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    
		return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
  80087f:	eb f6                	jmp    800877 <strncmp+0x32>

00800881 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800881:	f3 0f 1e fb          	endbr32 
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	0f b6 10             	movzbl (%eax),%edx
  800892:	84 d2                	test   %dl,%dl
  800894:	74 09                	je     80089f <strchr+0x1e>
		if (*s == c)
  800896:	38 ca                	cmp    %cl,%dl
  800898:	74 0a                	je     8008a4 <strchr+0x23>
	for (; *s; s++)
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	eb f0                	jmp    80088f <strchr+0xe>
			return (char *) s;
	return 0;
  80089f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a6:	f3 0f 1e fb          	endbr32 
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008b4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b7:	38 ca                	cmp    %cl,%dl
  8008b9:	74 09                	je     8008c4 <strfind+0x1e>
  8008bb:	84 d2                	test   %dl,%dl
  8008bd:	74 05                	je     8008c4 <strfind+0x1e>
	for (; *s; s++)
  8008bf:	83 c0 01             	add    $0x1,%eax
  8008c2:	eb f0                	jmp    8008b4 <strfind+0xe>
			break;
	return (char *) s;
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008c6:	f3 0f 1e fb          	endbr32 
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	57                   	push   %edi
  8008ce:	56                   	push   %esi
  8008cf:	53                   	push   %ebx
  8008d0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008d3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008d6:	85 c9                	test   %ecx,%ecx
  8008d8:	74 31                	je     80090b <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008da:	89 f8                	mov    %edi,%eax
  8008dc:	09 c8                	or     %ecx,%eax
  8008de:	a8 03                	test   $0x3,%al
  8008e0:	75 23                	jne    800905 <memset+0x3f>
		c &= 0xFF;
  8008e2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008e6:	89 d3                	mov    %edx,%ebx
  8008e8:	c1 e3 08             	shl    $0x8,%ebx
  8008eb:	89 d0                	mov    %edx,%eax
  8008ed:	c1 e0 18             	shl    $0x18,%eax
  8008f0:	89 d6                	mov    %edx,%esi
  8008f2:	c1 e6 10             	shl    $0x10,%esi
  8008f5:	09 f0                	or     %esi,%eax
  8008f7:	09 c2                	or     %eax,%edx
  8008f9:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8008fb:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8008fe:	89 d0                	mov    %edx,%eax
  800900:	fc                   	cld    
  800901:	f3 ab                	rep stos %eax,%es:(%edi)
  800903:	eb 06                	jmp    80090b <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800905:	8b 45 0c             	mov    0xc(%ebp),%eax
  800908:	fc                   	cld    
  800909:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80090b:	89 f8                	mov    %edi,%eax
  80090d:	5b                   	pop    %ebx
  80090e:	5e                   	pop    %esi
  80090f:	5f                   	pop    %edi
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800912:	f3 0f 1e fb          	endbr32 
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	57                   	push   %edi
  80091a:	56                   	push   %esi
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800921:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800924:	39 c6                	cmp    %eax,%esi
  800926:	73 32                	jae    80095a <memmove+0x48>
  800928:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80092b:	39 c2                	cmp    %eax,%edx
  80092d:	76 2b                	jbe    80095a <memmove+0x48>
		s += n;
		d += n;
  80092f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800932:	89 fe                	mov    %edi,%esi
  800934:	09 ce                	or     %ecx,%esi
  800936:	09 d6                	or     %edx,%esi
  800938:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80093e:	75 0e                	jne    80094e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800940:	83 ef 04             	sub    $0x4,%edi
  800943:	8d 72 fc             	lea    -0x4(%edx),%esi
  800946:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800949:	fd                   	std    
  80094a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094c:	eb 09                	jmp    800957 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80094e:	83 ef 01             	sub    $0x1,%edi
  800951:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800954:	fd                   	std    
  800955:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800957:	fc                   	cld    
  800958:	eb 1a                	jmp    800974 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095a:	89 c2                	mov    %eax,%edx
  80095c:	09 ca                	or     %ecx,%edx
  80095e:	09 f2                	or     %esi,%edx
  800960:	f6 c2 03             	test   $0x3,%dl
  800963:	75 0a                	jne    80096f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800965:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096d:	eb 05                	jmp    800974 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80096f:	89 c7                	mov    %eax,%edi
  800971:	fc                   	cld    
  800972:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800974:	5e                   	pop    %esi
  800975:	5f                   	pop    %edi
  800976:	5d                   	pop    %ebp
  800977:	c3                   	ret    

00800978 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800978:	f3 0f 1e fb          	endbr32 
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800982:	ff 75 10             	pushl  0x10(%ebp)
  800985:	ff 75 0c             	pushl  0xc(%ebp)
  800988:	ff 75 08             	pushl  0x8(%ebp)
  80098b:	e8 82 ff ff ff       	call   800912 <memmove>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800992:	f3 0f 1e fb          	endbr32 
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a1:	89 c6                	mov    %eax,%esi
  8009a3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009a6:	39 f0                	cmp    %esi,%eax
  8009a8:	74 1c                	je     8009c6 <memcmp+0x34>
		if (*s1 != *s2)
  8009aa:	0f b6 08             	movzbl (%eax),%ecx
  8009ad:	0f b6 1a             	movzbl (%edx),%ebx
  8009b0:	38 d9                	cmp    %bl,%cl
  8009b2:	75 08                	jne    8009bc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	83 c2 01             	add    $0x1,%edx
  8009ba:	eb ea                	jmp    8009a6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009bc:	0f b6 c1             	movzbl %cl,%eax
  8009bf:	0f b6 db             	movzbl %bl,%ebx
  8009c2:	29 d8                	sub    %ebx,%eax
  8009c4:	eb 05                	jmp    8009cb <memcmp+0x39>
	}

	return 0;
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	5b                   	pop    %ebx
  8009cc:	5e                   	pop    %esi
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009cf:	f3 0f 1e fb          	endbr32 
  8009d3:	55                   	push   %ebp
  8009d4:	89 e5                	mov    %esp,%ebp
  8009d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009dc:	89 c2                	mov    %eax,%edx
  8009de:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009e1:	39 d0                	cmp    %edx,%eax
  8009e3:	73 09                	jae    8009ee <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009e5:	38 08                	cmp    %cl,(%eax)
  8009e7:	74 05                	je     8009ee <memfind+0x1f>
	for (; s < ends; s++)
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	eb f3                	jmp    8009e1 <memfind+0x12>
			break;
	return (void *) s;
}
  8009ee:	5d                   	pop    %ebp
  8009ef:	c3                   	ret    

008009f0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009f0:	f3 0f 1e fb          	endbr32 
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	57                   	push   %edi
  8009f8:	56                   	push   %esi
  8009f9:	53                   	push   %ebx
  8009fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a00:	eb 03                	jmp    800a05 <strtol+0x15>
		s++;
  800a02:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a05:	0f b6 01             	movzbl (%ecx),%eax
  800a08:	3c 20                	cmp    $0x20,%al
  800a0a:	74 f6                	je     800a02 <strtol+0x12>
  800a0c:	3c 09                	cmp    $0x9,%al
  800a0e:	74 f2                	je     800a02 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a10:	3c 2b                	cmp    $0x2b,%al
  800a12:	74 2a                	je     800a3e <strtol+0x4e>
	int neg = 0;
  800a14:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a19:	3c 2d                	cmp    $0x2d,%al
  800a1b:	74 2b                	je     800a48 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a23:	75 0f                	jne    800a34 <strtol+0x44>
  800a25:	80 39 30             	cmpb   $0x30,(%ecx)
  800a28:	74 28                	je     800a52 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a2a:	85 db                	test   %ebx,%ebx
  800a2c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a31:	0f 44 d8             	cmove  %eax,%ebx
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
  800a39:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a3c:	eb 46                	jmp    800a84 <strtol+0x94>
		s++;
  800a3e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a41:	bf 00 00 00 00       	mov    $0x0,%edi
  800a46:	eb d5                	jmp    800a1d <strtol+0x2d>
		s++, neg = 1;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a50:	eb cb                	jmp    800a1d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a52:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a56:	74 0e                	je     800a66 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a58:	85 db                	test   %ebx,%ebx
  800a5a:	75 d8                	jne    800a34 <strtol+0x44>
		s++, base = 8;
  800a5c:	83 c1 01             	add    $0x1,%ecx
  800a5f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a64:	eb ce                	jmp    800a34 <strtol+0x44>
		s += 2, base = 16;
  800a66:	83 c1 02             	add    $0x2,%ecx
  800a69:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6e:	eb c4                	jmp    800a34 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a70:	0f be d2             	movsbl %dl,%edx
  800a73:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a76:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a79:	7d 3a                	jge    800ab5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a7b:	83 c1 01             	add    $0x1,%ecx
  800a7e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a82:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a84:	0f b6 11             	movzbl (%ecx),%edx
  800a87:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a8a:	89 f3                	mov    %esi,%ebx
  800a8c:	80 fb 09             	cmp    $0x9,%bl
  800a8f:	76 df                	jbe    800a70 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a91:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a94:	89 f3                	mov    %esi,%ebx
  800a96:	80 fb 19             	cmp    $0x19,%bl
  800a99:	77 08                	ja     800aa3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a9b:	0f be d2             	movsbl %dl,%edx
  800a9e:	83 ea 57             	sub    $0x57,%edx
  800aa1:	eb d3                	jmp    800a76 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aa3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800aa6:	89 f3                	mov    %esi,%ebx
  800aa8:	80 fb 19             	cmp    $0x19,%bl
  800aab:	77 08                	ja     800ab5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800aad:	0f be d2             	movsbl %dl,%edx
  800ab0:	83 ea 37             	sub    $0x37,%edx
  800ab3:	eb c1                	jmp    800a76 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ab5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ab9:	74 05                	je     800ac0 <strtol+0xd0>
		*endptr = (char *) s;
  800abb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abe:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ac0:	89 c2                	mov    %eax,%edx
  800ac2:	f7 da                	neg    %edx
  800ac4:	85 ff                	test   %edi,%edi
  800ac6:	0f 45 c2             	cmovne %edx,%eax
}
  800ac9:	5b                   	pop    %ebx
  800aca:	5e                   	pop    %esi
  800acb:	5f                   	pop    %edi
  800acc:	5d                   	pop    %ebp
  800acd:	c3                   	ret    

00800ace <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ace:	f3 0f 1e fb          	endbr32 
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ad8:	b8 00 00 00 00       	mov    $0x0,%eax
  800add:	8b 55 08             	mov    0x8(%ebp),%edx
  800ae0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ae3:	89 c3                	mov    %eax,%ebx
  800ae5:	89 c7                	mov    %eax,%edi
  800ae7:	89 c6                	mov    %eax,%esi
  800ae9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aeb:	5b                   	pop    %ebx
  800aec:	5e                   	pop    %esi
  800aed:	5f                   	pop    %edi
  800aee:	5d                   	pop    %ebp
  800aef:	c3                   	ret    

00800af0 <sys_cgetc>:

int
sys_cgetc(void)
{
  800af0:	f3 0f 1e fb          	endbr32 
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	57                   	push   %edi
  800af8:	56                   	push   %esi
  800af9:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800afa:	ba 00 00 00 00       	mov    $0x0,%edx
  800aff:	b8 01 00 00 00       	mov    $0x1,%eax
  800b04:	89 d1                	mov    %edx,%ecx
  800b06:	89 d3                	mov    %edx,%ebx
  800b08:	89 d7                	mov    %edx,%edi
  800b0a:	89 d6                	mov    %edx,%esi
  800b0c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b13:	f3 0f 1e fb          	endbr32 
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	57                   	push   %edi
  800b1b:	56                   	push   %esi
  800b1c:	53                   	push   %ebx
  800b1d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b25:	8b 55 08             	mov    0x8(%ebp),%edx
  800b28:	b8 03 00 00 00       	mov    $0x3,%eax
  800b2d:	89 cb                	mov    %ecx,%ebx
  800b2f:	89 cf                	mov    %ecx,%edi
  800b31:	89 ce                	mov    %ecx,%esi
  800b33:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b35:	85 c0                	test   %eax,%eax
  800b37:	7f 08                	jg     800b41 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	50                   	push   %eax
  800b45:	6a 03                	push   $0x3
  800b47:	68 84 12 80 00       	push   $0x801284
  800b4c:	6a 23                	push   $0x23
  800b4e:	68 a1 12 80 00       	push   $0x8012a1
  800b53:	e8 11 02 00 00       	call   800d69 <_panic>

00800b58 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b58:	f3 0f 1e fb          	endbr32 
  800b5c:	55                   	push   %ebp
  800b5d:	89 e5                	mov    %esp,%ebp
  800b5f:	57                   	push   %edi
  800b60:	56                   	push   %esi
  800b61:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 02 00 00 00       	mov    $0x2,%eax
  800b6c:	89 d1                	mov    %edx,%ecx
  800b6e:	89 d3                	mov    %edx,%ebx
  800b70:	89 d7                	mov    %edx,%edi
  800b72:	89 d6                	mov    %edx,%esi
  800b74:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b76:	5b                   	pop    %ebx
  800b77:	5e                   	pop    %esi
  800b78:	5f                   	pop    %edi
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <sys_yield>:

void
sys_yield(void)
{
  800b7b:	f3 0f 1e fb          	endbr32 
  800b7f:	55                   	push   %ebp
  800b80:	89 e5                	mov    %esp,%ebp
  800b82:	57                   	push   %edi
  800b83:	56                   	push   %esi
  800b84:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b85:	ba 00 00 00 00       	mov    $0x0,%edx
  800b8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8f:	89 d1                	mov    %edx,%ecx
  800b91:	89 d3                	mov    %edx,%ebx
  800b93:	89 d7                	mov    %edx,%edi
  800b95:	89 d6                	mov    %edx,%esi
  800b97:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5f                   	pop    %edi
  800b9c:	5d                   	pop    %ebp
  800b9d:	c3                   	ret    

00800b9e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b9e:	f3 0f 1e fb          	endbr32 
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	57                   	push   %edi
  800ba6:	56                   	push   %esi
  800ba7:	53                   	push   %ebx
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bab:	be 00 00 00 00       	mov    $0x0,%esi
  800bb0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bb6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bbb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bbe:	89 f7                	mov    %esi,%edi
  800bc0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bc2:	85 c0                	test   %eax,%eax
  800bc4:	7f 08                	jg     800bce <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	50                   	push   %eax
  800bd2:	6a 04                	push   $0x4
  800bd4:	68 84 12 80 00       	push   $0x801284
  800bd9:	6a 23                	push   $0x23
  800bdb:	68 a1 12 80 00       	push   $0x8012a1
  800be0:	e8 84 01 00 00       	call   800d69 <_panic>

00800be5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be5:	f3 0f 1e fb          	endbr32 
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
  800bec:	57                   	push   %edi
  800bed:	56                   	push   %esi
  800bee:	53                   	push   %ebx
  800bef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf8:	b8 05 00 00 00       	mov    $0x5,%eax
  800bfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c03:	8b 75 18             	mov    0x18(%ebp),%esi
  800c06:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c08:	85 c0                	test   %eax,%eax
  800c0a:	7f 08                	jg     800c14 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0f:	5b                   	pop    %ebx
  800c10:	5e                   	pop    %esi
  800c11:	5f                   	pop    %edi
  800c12:	5d                   	pop    %ebp
  800c13:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c14:	83 ec 0c             	sub    $0xc,%esp
  800c17:	50                   	push   %eax
  800c18:	6a 05                	push   $0x5
  800c1a:	68 84 12 80 00       	push   $0x801284
  800c1f:	6a 23                	push   $0x23
  800c21:	68 a1 12 80 00       	push   $0x8012a1
  800c26:	e8 3e 01 00 00       	call   800d69 <_panic>

00800c2b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c2b:	f3 0f 1e fb          	endbr32 
  800c2f:	55                   	push   %ebp
  800c30:	89 e5                	mov    %esp,%ebp
  800c32:	57                   	push   %edi
  800c33:	56                   	push   %esi
  800c34:	53                   	push   %ebx
  800c35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c38:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c43:	b8 06 00 00 00       	mov    $0x6,%eax
  800c48:	89 df                	mov    %ebx,%edi
  800c4a:	89 de                	mov    %ebx,%esi
  800c4c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c4e:	85 c0                	test   %eax,%eax
  800c50:	7f 08                	jg     800c5a <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5a:	83 ec 0c             	sub    $0xc,%esp
  800c5d:	50                   	push   %eax
  800c5e:	6a 06                	push   $0x6
  800c60:	68 84 12 80 00       	push   $0x801284
  800c65:	6a 23                	push   $0x23
  800c67:	68 a1 12 80 00       	push   $0x8012a1
  800c6c:	e8 f8 00 00 00       	call   800d69 <_panic>

00800c71 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c71:	f3 0f 1e fb          	endbr32 
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 08                	push   $0x8
  800ca6:	68 84 12 80 00       	push   $0x801284
  800cab:	6a 23                	push   $0x23
  800cad:	68 a1 12 80 00       	push   $0x8012a1
  800cb2:	e8 b2 00 00 00       	call   800d69 <_panic>

00800cb7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb7:	f3 0f 1e fb          	endbr32 
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	57                   	push   %edi
  800cbf:	56                   	push   %esi
  800cc0:	53                   	push   %ebx
  800cc1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd4:	89 df                	mov    %ebx,%edi
  800cd6:	89 de                	mov    %ebx,%esi
  800cd8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	7f 08                	jg     800ce6 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce1:	5b                   	pop    %ebx
  800ce2:	5e                   	pop    %esi
  800ce3:	5f                   	pop    %edi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	50                   	push   %eax
  800cea:	6a 09                	push   $0x9
  800cec:	68 84 12 80 00       	push   $0x801284
  800cf1:	6a 23                	push   $0x23
  800cf3:	68 a1 12 80 00       	push   $0x8012a1
  800cf8:	e8 6c 00 00 00       	call   800d69 <_panic>

00800cfd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfd:	f3 0f 1e fb          	endbr32 
  800d01:	55                   	push   %ebp
  800d02:	89 e5                	mov    %esp,%ebp
  800d04:	57                   	push   %edi
  800d05:	56                   	push   %esi
  800d06:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d12:	be 00 00 00 00       	mov    $0x0,%esi
  800d17:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    

00800d24 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d24:	f3 0f 1e fb          	endbr32 
  800d28:	55                   	push   %ebp
  800d29:	89 e5                	mov    %esp,%ebp
  800d2b:	57                   	push   %edi
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d31:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d36:	8b 55 08             	mov    0x8(%ebp),%edx
  800d39:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3e:	89 cb                	mov    %ecx,%ebx
  800d40:	89 cf                	mov    %ecx,%edi
  800d42:	89 ce                	mov    %ecx,%esi
  800d44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7f 08                	jg     800d52 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 0c                	push   $0xc
  800d58:	68 84 12 80 00       	push   $0x801284
  800d5d:	6a 23                	push   $0x23
  800d5f:	68 a1 12 80 00       	push   $0x8012a1
  800d64:	e8 00 00 00 00       	call   800d69 <_panic>

00800d69 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d69:	f3 0f 1e fb          	endbr32 
  800d6d:	55                   	push   %ebp
  800d6e:	89 e5                	mov    %esp,%ebp
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d72:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d75:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d7b:	e8 d8 fd ff ff       	call   800b58 <sys_getenvid>
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	ff 75 0c             	pushl  0xc(%ebp)
  800d86:	ff 75 08             	pushl  0x8(%ebp)
  800d89:	56                   	push   %esi
  800d8a:	50                   	push   %eax
  800d8b:	68 b0 12 80 00       	push   $0x8012b0
  800d90:	e8 bd f3 ff ff       	call   800152 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800d95:	83 c4 18             	add    $0x18,%esp
  800d98:	53                   	push   %ebx
  800d99:	ff 75 10             	pushl  0x10(%ebp)
  800d9c:	e8 5c f3 ff ff       	call   8000fd <vcprintf>
	cprintf("\n");
  800da1:	c7 04 24 3c 10 80 00 	movl   $0x80103c,(%esp)
  800da8:	e8 a5 f3 ff ff       	call   800152 <cprintf>
  800dad:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800db0:	cc                   	int3   
  800db1:	eb fd                	jmp    800db0 <_panic+0x47>
  800db3:	66 90                	xchg   %ax,%ax
  800db5:	66 90                	xchg   %ax,%ax
  800db7:	66 90                	xchg   %ax,%ax
  800db9:	66 90                	xchg   %ax,%ax
  800dbb:	66 90                	xchg   %ax,%ax
  800dbd:	66 90                	xchg   %ax,%ax
  800dbf:	90                   	nop

00800dc0 <__udivdi3>:
  800dc0:	f3 0f 1e fb          	endbr32 
  800dc4:	55                   	push   %ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
  800dc8:	83 ec 1c             	sub    $0x1c,%esp
  800dcb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800dcf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dd3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800dd7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800ddb:	85 d2                	test   %edx,%edx
  800ddd:	75 19                	jne    800df8 <__udivdi3+0x38>
  800ddf:	39 f3                	cmp    %esi,%ebx
  800de1:	76 4d                	jbe    800e30 <__udivdi3+0x70>
  800de3:	31 ff                	xor    %edi,%edi
  800de5:	89 e8                	mov    %ebp,%eax
  800de7:	89 f2                	mov    %esi,%edx
  800de9:	f7 f3                	div    %ebx
  800deb:	89 fa                	mov    %edi,%edx
  800ded:	83 c4 1c             	add    $0x1c,%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
  800df5:	8d 76 00             	lea    0x0(%esi),%esi
  800df8:	39 f2                	cmp    %esi,%edx
  800dfa:	76 14                	jbe    800e10 <__udivdi3+0x50>
  800dfc:	31 ff                	xor    %edi,%edi
  800dfe:	31 c0                	xor    %eax,%eax
  800e00:	89 fa                	mov    %edi,%edx
  800e02:	83 c4 1c             	add    $0x1c,%esp
  800e05:	5b                   	pop    %ebx
  800e06:	5e                   	pop    %esi
  800e07:	5f                   	pop    %edi
  800e08:	5d                   	pop    %ebp
  800e09:	c3                   	ret    
  800e0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e10:	0f bd fa             	bsr    %edx,%edi
  800e13:	83 f7 1f             	xor    $0x1f,%edi
  800e16:	75 48                	jne    800e60 <__udivdi3+0xa0>
  800e18:	39 f2                	cmp    %esi,%edx
  800e1a:	72 06                	jb     800e22 <__udivdi3+0x62>
  800e1c:	31 c0                	xor    %eax,%eax
  800e1e:	39 eb                	cmp    %ebp,%ebx
  800e20:	77 de                	ja     800e00 <__udivdi3+0x40>
  800e22:	b8 01 00 00 00       	mov    $0x1,%eax
  800e27:	eb d7                	jmp    800e00 <__udivdi3+0x40>
  800e29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e30:	89 d9                	mov    %ebx,%ecx
  800e32:	85 db                	test   %ebx,%ebx
  800e34:	75 0b                	jne    800e41 <__udivdi3+0x81>
  800e36:	b8 01 00 00 00       	mov    $0x1,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	f7 f3                	div    %ebx
  800e3f:	89 c1                	mov    %eax,%ecx
  800e41:	31 d2                	xor    %edx,%edx
  800e43:	89 f0                	mov    %esi,%eax
  800e45:	f7 f1                	div    %ecx
  800e47:	89 c6                	mov    %eax,%esi
  800e49:	89 e8                	mov    %ebp,%eax
  800e4b:	89 f7                	mov    %esi,%edi
  800e4d:	f7 f1                	div    %ecx
  800e4f:	89 fa                	mov    %edi,%edx
  800e51:	83 c4 1c             	add    $0x1c,%esp
  800e54:	5b                   	pop    %ebx
  800e55:	5e                   	pop    %esi
  800e56:	5f                   	pop    %edi
  800e57:	5d                   	pop    %ebp
  800e58:	c3                   	ret    
  800e59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e60:	89 f9                	mov    %edi,%ecx
  800e62:	b8 20 00 00 00       	mov    $0x20,%eax
  800e67:	29 f8                	sub    %edi,%eax
  800e69:	d3 e2                	shl    %cl,%edx
  800e6b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e6f:	89 c1                	mov    %eax,%ecx
  800e71:	89 da                	mov    %ebx,%edx
  800e73:	d3 ea                	shr    %cl,%edx
  800e75:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e79:	09 d1                	or     %edx,%ecx
  800e7b:	89 f2                	mov    %esi,%edx
  800e7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e81:	89 f9                	mov    %edi,%ecx
  800e83:	d3 e3                	shl    %cl,%ebx
  800e85:	89 c1                	mov    %eax,%ecx
  800e87:	d3 ea                	shr    %cl,%edx
  800e89:	89 f9                	mov    %edi,%ecx
  800e8b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e8f:	89 eb                	mov    %ebp,%ebx
  800e91:	d3 e6                	shl    %cl,%esi
  800e93:	89 c1                	mov    %eax,%ecx
  800e95:	d3 eb                	shr    %cl,%ebx
  800e97:	09 de                	or     %ebx,%esi
  800e99:	89 f0                	mov    %esi,%eax
  800e9b:	f7 74 24 08          	divl   0x8(%esp)
  800e9f:	89 d6                	mov    %edx,%esi
  800ea1:	89 c3                	mov    %eax,%ebx
  800ea3:	f7 64 24 0c          	mull   0xc(%esp)
  800ea7:	39 d6                	cmp    %edx,%esi
  800ea9:	72 15                	jb     800ec0 <__udivdi3+0x100>
  800eab:	89 f9                	mov    %edi,%ecx
  800ead:	d3 e5                	shl    %cl,%ebp
  800eaf:	39 c5                	cmp    %eax,%ebp
  800eb1:	73 04                	jae    800eb7 <__udivdi3+0xf7>
  800eb3:	39 d6                	cmp    %edx,%esi
  800eb5:	74 09                	je     800ec0 <__udivdi3+0x100>
  800eb7:	89 d8                	mov    %ebx,%eax
  800eb9:	31 ff                	xor    %edi,%edi
  800ebb:	e9 40 ff ff ff       	jmp    800e00 <__udivdi3+0x40>
  800ec0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ec3:	31 ff                	xor    %edi,%edi
  800ec5:	e9 36 ff ff ff       	jmp    800e00 <__udivdi3+0x40>
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__umoddi3>:
  800ed0:	f3 0f 1e fb          	endbr32 
  800ed4:	55                   	push   %ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 1c             	sub    $0x1c,%esp
  800edb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800edf:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ee3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ee7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	75 19                	jne    800f08 <__umoddi3+0x38>
  800eef:	39 df                	cmp    %ebx,%edi
  800ef1:	76 5d                	jbe    800f50 <__umoddi3+0x80>
  800ef3:	89 f0                	mov    %esi,%eax
  800ef5:	89 da                	mov    %ebx,%edx
  800ef7:	f7 f7                	div    %edi
  800ef9:	89 d0                	mov    %edx,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	83 c4 1c             	add    $0x1c,%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    
  800f05:	8d 76 00             	lea    0x0(%esi),%esi
  800f08:	89 f2                	mov    %esi,%edx
  800f0a:	39 d8                	cmp    %ebx,%eax
  800f0c:	76 12                	jbe    800f20 <__umoddi3+0x50>
  800f0e:	89 f0                	mov    %esi,%eax
  800f10:	89 da                	mov    %ebx,%edx
  800f12:	83 c4 1c             	add    $0x1c,%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    
  800f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f20:	0f bd e8             	bsr    %eax,%ebp
  800f23:	83 f5 1f             	xor    $0x1f,%ebp
  800f26:	75 50                	jne    800f78 <__umoddi3+0xa8>
  800f28:	39 d8                	cmp    %ebx,%eax
  800f2a:	0f 82 e0 00 00 00    	jb     801010 <__umoddi3+0x140>
  800f30:	89 d9                	mov    %ebx,%ecx
  800f32:	39 f7                	cmp    %esi,%edi
  800f34:	0f 86 d6 00 00 00    	jbe    801010 <__umoddi3+0x140>
  800f3a:	89 d0                	mov    %edx,%eax
  800f3c:	89 ca                	mov    %ecx,%edx
  800f3e:	83 c4 1c             	add    $0x1c,%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    
  800f46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
  800f50:	89 fd                	mov    %edi,%ebp
  800f52:	85 ff                	test   %edi,%edi
  800f54:	75 0b                	jne    800f61 <__umoddi3+0x91>
  800f56:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5b:	31 d2                	xor    %edx,%edx
  800f5d:	f7 f7                	div    %edi
  800f5f:	89 c5                	mov    %eax,%ebp
  800f61:	89 d8                	mov    %ebx,%eax
  800f63:	31 d2                	xor    %edx,%edx
  800f65:	f7 f5                	div    %ebp
  800f67:	89 f0                	mov    %esi,%eax
  800f69:	f7 f5                	div    %ebp
  800f6b:	89 d0                	mov    %edx,%eax
  800f6d:	31 d2                	xor    %edx,%edx
  800f6f:	eb 8c                	jmp    800efd <__umoddi3+0x2d>
  800f71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f78:	89 e9                	mov    %ebp,%ecx
  800f7a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f7f:	29 ea                	sub    %ebp,%edx
  800f81:	d3 e0                	shl    %cl,%eax
  800f83:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f87:	89 d1                	mov    %edx,%ecx
  800f89:	89 f8                	mov    %edi,%eax
  800f8b:	d3 e8                	shr    %cl,%eax
  800f8d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f91:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f95:	8b 54 24 04          	mov    0x4(%esp),%edx
  800f99:	09 c1                	or     %eax,%ecx
  800f9b:	89 d8                	mov    %ebx,%eax
  800f9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fa1:	89 e9                	mov    %ebp,%ecx
  800fa3:	d3 e7                	shl    %cl,%edi
  800fa5:	89 d1                	mov    %edx,%ecx
  800fa7:	d3 e8                	shr    %cl,%eax
  800fa9:	89 e9                	mov    %ebp,%ecx
  800fab:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800faf:	d3 e3                	shl    %cl,%ebx
  800fb1:	89 c7                	mov    %eax,%edi
  800fb3:	89 d1                	mov    %edx,%ecx
  800fb5:	89 f0                	mov    %esi,%eax
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	89 fa                	mov    %edi,%edx
  800fbd:	d3 e6                	shl    %cl,%esi
  800fbf:	09 d8                	or     %ebx,%eax
  800fc1:	f7 74 24 08          	divl   0x8(%esp)
  800fc5:	89 d1                	mov    %edx,%ecx
  800fc7:	89 f3                	mov    %esi,%ebx
  800fc9:	f7 64 24 0c          	mull   0xc(%esp)
  800fcd:	89 c6                	mov    %eax,%esi
  800fcf:	89 d7                	mov    %edx,%edi
  800fd1:	39 d1                	cmp    %edx,%ecx
  800fd3:	72 06                	jb     800fdb <__umoddi3+0x10b>
  800fd5:	75 10                	jne    800fe7 <__umoddi3+0x117>
  800fd7:	39 c3                	cmp    %eax,%ebx
  800fd9:	73 0c                	jae    800fe7 <__umoddi3+0x117>
  800fdb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fdf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fe3:	89 d7                	mov    %edx,%edi
  800fe5:	89 c6                	mov    %eax,%esi
  800fe7:	89 ca                	mov    %ecx,%edx
  800fe9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800fee:	29 f3                	sub    %esi,%ebx
  800ff0:	19 fa                	sbb    %edi,%edx
  800ff2:	89 d0                	mov    %edx,%eax
  800ff4:	d3 e0                	shl    %cl,%eax
  800ff6:	89 e9                	mov    %ebp,%ecx
  800ff8:	d3 eb                	shr    %cl,%ebx
  800ffa:	d3 ea                	shr    %cl,%edx
  800ffc:	09 d8                	or     %ebx,%eax
  800ffe:	83 c4 1c             	add    $0x1c,%esp
  801001:	5b                   	pop    %ebx
  801002:	5e                   	pop    %esi
  801003:	5f                   	pop    %edi
  801004:	5d                   	pop    %ebp
  801005:	c3                   	ret    
  801006:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80100d:	8d 76 00             	lea    0x0(%esi),%esi
  801010:	29 fe                	sub    %edi,%esi
  801012:	19 c3                	sbb    %eax,%ebx
  801014:	89 f2                	mov    %esi,%edx
  801016:	89 d9                	mov    %ebx,%ecx
  801018:	e9 1d ff ff ff       	jmp    800f3a <__umoddi3+0x6a>
