
obj/user/hello:     file format elf32-i386


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
  80002c:	e8 31 00 00 00       	call   800062 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  80003d:	68 40 10 80 00       	push   $0x801040
  800042:	e8 1b 01 00 00       	call   800162 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800047:	a1 60 40 80 00       	mov    0x804060,%eax
  80004c:	8b 40 48             	mov    0x48(%eax),%eax
  80004f:	83 c4 08             	add    $0x8,%esp
  800052:	50                   	push   %eax
  800053:	68 4e 10 80 00       	push   $0x80104e
  800058:	e8 05 01 00 00       	call   800162 <cprintf>
}
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	c9                   	leave  
  800061:	c3                   	ret    

00800062 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800062:	f3 0f 1e fb          	endbr32 
  800066:	55                   	push   %ebp
  800067:	89 e5                	mov    %esp,%ebp
  800069:	56                   	push   %esi
  80006a:	53                   	push   %ebx
  80006b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  800071:	e8 f2 0a 00 00       	call   800b68 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  800076:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007b:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800081:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800086:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008b:	85 db                	test   %ebx,%ebx
  80008d:	7e 07                	jle    800096 <libmain+0x34>
		binaryname = argv[0];
  80008f:	8b 06                	mov    (%esi),%eax
  800091:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800096:	83 ec 08             	sub    $0x8,%esp
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
  80009b:	e8 93 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0a 00 00 00       	call   8000af <exit>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    

008000af <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000af:	f3 0f 1e fb          	endbr32 
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 63 0a 00 00       	call   800b23 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c5:	f3 0f 1e fb          	endbr32 
  8000c9:	55                   	push   %ebp
  8000ca:	89 e5                	mov    %esp,%ebp
  8000cc:	53                   	push   %ebx
  8000cd:	83 ec 04             	sub    $0x4,%esp
  8000d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d3:	8b 13                	mov    (%ebx),%edx
  8000d5:	8d 42 01             	lea    0x1(%edx),%eax
  8000d8:	89 03                	mov    %eax,(%ebx)
  8000da:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000dd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000e6:	74 09                	je     8000f1 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8000e8:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ef:	c9                   	leave  
  8000f0:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8000f1:	83 ec 08             	sub    $0x8,%esp
  8000f4:	68 ff 00 00 00       	push   $0xff
  8000f9:	8d 43 08             	lea    0x8(%ebx),%eax
  8000fc:	50                   	push   %eax
  8000fd:	e8 dc 09 00 00       	call   800ade <sys_cputs>
		b->idx = 0;
  800102:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	eb db                	jmp    8000e8 <putch+0x23>

0080010d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010d:	f3 0f 1e fb          	endbr32 
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80011a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800121:	00 00 00 
	b.cnt = 0;
  800124:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80012b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012e:	ff 75 0c             	pushl  0xc(%ebp)
  800131:	ff 75 08             	pushl  0x8(%ebp)
  800134:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013a:	50                   	push   %eax
  80013b:	68 c5 00 80 00       	push   $0x8000c5
  800140:	e8 20 01 00 00       	call   800265 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800145:	83 c4 08             	add    $0x8,%esp
  800148:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800154:	50                   	push   %eax
  800155:	e8 84 09 00 00       	call   800ade <sys_cputs>

	return b.cnt;
}
  80015a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800160:	c9                   	leave  
  800161:	c3                   	ret    

00800162 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800162:	f3 0f 1e fb          	endbr32 
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80016c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80016f:	50                   	push   %eax
  800170:	ff 75 08             	pushl  0x8(%ebp)
  800173:	e8 95 ff ff ff       	call   80010d <vcprintf>
	va_end(ap);

	return cnt;
}
  800178:	c9                   	leave  
  800179:	c3                   	ret    

0080017a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	57                   	push   %edi
  80017e:	56                   	push   %esi
  80017f:	53                   	push   %ebx
  800180:	83 ec 1c             	sub    $0x1c,%esp
  800183:	89 c7                	mov    %eax,%edi
  800185:	89 d6                	mov    %edx,%esi
  800187:	8b 45 08             	mov    0x8(%ebp),%eax
  80018a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80018d:	89 d1                	mov    %edx,%ecx
  80018f:	89 c2                	mov    %eax,%edx
  800191:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800194:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800197:	8b 45 10             	mov    0x10(%ebp),%eax
  80019a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80019d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001a0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001a7:	39 c2                	cmp    %eax,%edx
  8001a9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ac:	72 3e                	jb     8001ec <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ae:	83 ec 0c             	sub    $0xc,%esp
  8001b1:	ff 75 18             	pushl  0x18(%ebp)
  8001b4:	83 eb 01             	sub    $0x1,%ebx
  8001b7:	53                   	push   %ebx
  8001b8:	50                   	push   %eax
  8001b9:	83 ec 08             	sub    $0x8,%esp
  8001bc:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001bf:	ff 75 e0             	pushl  -0x20(%ebp)
  8001c2:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c5:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c8:	e8 03 0c 00 00       	call   800dd0 <__udivdi3>
  8001cd:	83 c4 18             	add    $0x18,%esp
  8001d0:	52                   	push   %edx
  8001d1:	50                   	push   %eax
  8001d2:	89 f2                	mov    %esi,%edx
  8001d4:	89 f8                	mov    %edi,%eax
  8001d6:	e8 9f ff ff ff       	call   80017a <printnum>
  8001db:	83 c4 20             	add    $0x20,%esp
  8001de:	eb 13                	jmp    8001f3 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001e0:	83 ec 08             	sub    $0x8,%esp
  8001e3:	56                   	push   %esi
  8001e4:	ff 75 18             	pushl  0x18(%ebp)
  8001e7:	ff d7                	call   *%edi
  8001e9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8001ec:	83 eb 01             	sub    $0x1,%ebx
  8001ef:	85 db                	test   %ebx,%ebx
  8001f1:	7f ed                	jg     8001e0 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	83 ec 04             	sub    $0x4,%esp
  8001fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800200:	ff 75 dc             	pushl  -0x24(%ebp)
  800203:	ff 75 d8             	pushl  -0x28(%ebp)
  800206:	e8 d5 0c 00 00       	call   800ee0 <__umoddi3>
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	0f be 80 6f 10 80 00 	movsbl 0x80106f(%eax),%eax
  800215:	50                   	push   %eax
  800216:	ff d7                	call   *%edi
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800223:	f3 0f 1e fb          	endbr32 
  800227:	55                   	push   %ebp
  800228:	89 e5                	mov    %esp,%ebp
  80022a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80022d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800231:	8b 10                	mov    (%eax),%edx
  800233:	3b 50 04             	cmp    0x4(%eax),%edx
  800236:	73 0a                	jae    800242 <sprintputch+0x1f>
		*b->buf++ = ch;
  800238:	8d 4a 01             	lea    0x1(%edx),%ecx
  80023b:	89 08                	mov    %ecx,(%eax)
  80023d:	8b 45 08             	mov    0x8(%ebp),%eax
  800240:	88 02                	mov    %al,(%edx)
}
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    

00800244 <printfmt>:
{
  800244:	f3 0f 1e fb          	endbr32 
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80024e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800251:	50                   	push   %eax
  800252:	ff 75 10             	pushl  0x10(%ebp)
  800255:	ff 75 0c             	pushl  0xc(%ebp)
  800258:	ff 75 08             	pushl  0x8(%ebp)
  80025b:	e8 05 00 00 00       	call   800265 <vprintfmt>
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <vprintfmt>:
{
  800265:	f3 0f 1e fb          	endbr32 
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	57                   	push   %edi
  80026d:	56                   	push   %esi
  80026e:	53                   	push   %ebx
  80026f:	83 ec 3c             	sub    $0x3c,%esp
  800272:	8b 75 08             	mov    0x8(%ebp),%esi
  800275:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800278:	8b 7d 10             	mov    0x10(%ebp),%edi
  80027b:	e9 8e 03 00 00       	jmp    80060e <vprintfmt+0x3a9>
		padc = ' ';
  800280:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800284:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80028b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800292:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800299:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80029e:	8d 47 01             	lea    0x1(%edi),%eax
  8002a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002a4:	0f b6 17             	movzbl (%edi),%edx
  8002a7:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002aa:	3c 55                	cmp    $0x55,%al
  8002ac:	0f 87 df 03 00 00    	ja     800691 <vprintfmt+0x42c>
  8002b2:	0f b6 c0             	movzbl %al,%eax
  8002b5:	3e ff 24 85 40 11 80 	notrack jmp *0x801140(,%eax,4)
  8002bc:	00 
  8002bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002c0:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8002c4:	eb d8                	jmp    80029e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8002c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c9:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8002cd:	eb cf                	jmp    80029e <vprintfmt+0x39>
  8002cf:	0f b6 d2             	movzbl %dl,%edx
  8002d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8002d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8002da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8002dd:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e0:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e4:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e7:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002ea:	83 f9 09             	cmp    $0x9,%ecx
  8002ed:	77 55                	ja     800344 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  8002ef:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8002f2:	eb e9                	jmp    8002dd <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8002f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f7:	8b 00                	mov    (%eax),%eax
  8002f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ff:	8d 40 04             	lea    0x4(%eax),%eax
  800302:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800305:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800308:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80030c:	79 90                	jns    80029e <vprintfmt+0x39>
				width = precision, precision = -1;
  80030e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800311:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800314:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80031b:	eb 81                	jmp    80029e <vprintfmt+0x39>
  80031d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800320:	85 c0                	test   %eax,%eax
  800322:	ba 00 00 00 00       	mov    $0x0,%edx
  800327:	0f 49 d0             	cmovns %eax,%edx
  80032a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800330:	e9 69 ff ff ff       	jmp    80029e <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800335:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800338:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80033f:	e9 5a ff ff ff       	jmp    80029e <vprintfmt+0x39>
  800344:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800347:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80034a:	eb bc                	jmp    800308 <vprintfmt+0xa3>
			lflag++;
  80034c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80034f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800352:	e9 47 ff ff ff       	jmp    80029e <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800357:	8b 45 14             	mov    0x14(%ebp),%eax
  80035a:	8d 78 04             	lea    0x4(%eax),%edi
  80035d:	83 ec 08             	sub    $0x8,%esp
  800360:	53                   	push   %ebx
  800361:	ff 30                	pushl  (%eax)
  800363:	ff d6                	call   *%esi
			break;
  800365:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800368:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80036b:	e9 9b 02 00 00       	jmp    80060b <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  800370:	8b 45 14             	mov    0x14(%ebp),%eax
  800373:	8d 78 04             	lea    0x4(%eax),%edi
  800376:	8b 00                	mov    (%eax),%eax
  800378:	99                   	cltd   
  800379:	31 d0                	xor    %edx,%eax
  80037b:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80037d:	83 f8 08             	cmp    $0x8,%eax
  800380:	7f 23                	jg     8003a5 <vprintfmt+0x140>
  800382:	8b 14 85 a0 12 80 00 	mov    0x8012a0(,%eax,4),%edx
  800389:	85 d2                	test   %edx,%edx
  80038b:	74 18                	je     8003a5 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  80038d:	52                   	push   %edx
  80038e:	68 90 10 80 00       	push   $0x801090
  800393:	53                   	push   %ebx
  800394:	56                   	push   %esi
  800395:	e8 aa fe ff ff       	call   800244 <printfmt>
  80039a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80039d:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003a0:	e9 66 02 00 00       	jmp    80060b <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003a5:	50                   	push   %eax
  8003a6:	68 87 10 80 00       	push   $0x801087
  8003ab:	53                   	push   %ebx
  8003ac:	56                   	push   %esi
  8003ad:	e8 92 fe ff ff       	call   800244 <printfmt>
  8003b2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003b5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003b8:	e9 4e 02 00 00       	jmp    80060b <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	83 c0 04             	add    $0x4,%eax
  8003c3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8003c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8003cb:	85 d2                	test   %edx,%edx
  8003cd:	b8 80 10 80 00       	mov    $0x801080,%eax
  8003d2:	0f 45 c2             	cmovne %edx,%eax
  8003d5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8003d8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003dc:	7e 06                	jle    8003e4 <vprintfmt+0x17f>
  8003de:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8003e2:	75 0d                	jne    8003f1 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8003e7:	89 c7                	mov    %eax,%edi
  8003e9:	03 45 e0             	add    -0x20(%ebp),%eax
  8003ec:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ef:	eb 55                	jmp    800446 <vprintfmt+0x1e1>
  8003f1:	83 ec 08             	sub    $0x8,%esp
  8003f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f7:	ff 75 cc             	pushl  -0x34(%ebp)
  8003fa:	e8 46 03 00 00       	call   800745 <strnlen>
  8003ff:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800402:	29 c2                	sub    %eax,%edx
  800404:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800407:	83 c4 10             	add    $0x10,%esp
  80040a:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80040c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800410:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	85 ff                	test   %edi,%edi
  800415:	7e 11                	jle    800428 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	53                   	push   %ebx
  80041b:	ff 75 e0             	pushl  -0x20(%ebp)
  80041e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800420:	83 ef 01             	sub    $0x1,%edi
  800423:	83 c4 10             	add    $0x10,%esp
  800426:	eb eb                	jmp    800413 <vprintfmt+0x1ae>
  800428:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80042b:	85 d2                	test   %edx,%edx
  80042d:	b8 00 00 00 00       	mov    $0x0,%eax
  800432:	0f 49 c2             	cmovns %edx,%eax
  800435:	29 c2                	sub    %eax,%edx
  800437:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80043a:	eb a8                	jmp    8003e4 <vprintfmt+0x17f>
					putch(ch, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	52                   	push   %edx
  800441:	ff d6                	call   *%esi
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800449:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80044b:	83 c7 01             	add    $0x1,%edi
  80044e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800452:	0f be d0             	movsbl %al,%edx
  800455:	85 d2                	test   %edx,%edx
  800457:	74 4b                	je     8004a4 <vprintfmt+0x23f>
  800459:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045d:	78 06                	js     800465 <vprintfmt+0x200>
  80045f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800463:	78 1e                	js     800483 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  800465:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800469:	74 d1                	je     80043c <vprintfmt+0x1d7>
  80046b:	0f be c0             	movsbl %al,%eax
  80046e:	83 e8 20             	sub    $0x20,%eax
  800471:	83 f8 5e             	cmp    $0x5e,%eax
  800474:	76 c6                	jbe    80043c <vprintfmt+0x1d7>
					putch('?', putdat);
  800476:	83 ec 08             	sub    $0x8,%esp
  800479:	53                   	push   %ebx
  80047a:	6a 3f                	push   $0x3f
  80047c:	ff d6                	call   *%esi
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	eb c3                	jmp    800446 <vprintfmt+0x1e1>
  800483:	89 cf                	mov    %ecx,%edi
  800485:	eb 0e                	jmp    800495 <vprintfmt+0x230>
				putch(' ', putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	53                   	push   %ebx
  80048b:	6a 20                	push   $0x20
  80048d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80048f:	83 ef 01             	sub    $0x1,%edi
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	85 ff                	test   %edi,%edi
  800497:	7f ee                	jg     800487 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  800499:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80049c:	89 45 14             	mov    %eax,0x14(%ebp)
  80049f:	e9 67 01 00 00       	jmp    80060b <vprintfmt+0x3a6>
  8004a4:	89 cf                	mov    %ecx,%edi
  8004a6:	eb ed                	jmp    800495 <vprintfmt+0x230>
	if (lflag >= 2)
  8004a8:	83 f9 01             	cmp    $0x1,%ecx
  8004ab:	7f 1b                	jg     8004c8 <vprintfmt+0x263>
	else if (lflag)
  8004ad:	85 c9                	test   %ecx,%ecx
  8004af:	74 63                	je     800514 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8b 00                	mov    (%eax),%eax
  8004b6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b9:	99                   	cltd   
  8004ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c0:	8d 40 04             	lea    0x4(%eax),%eax
  8004c3:	89 45 14             	mov    %eax,0x14(%ebp)
  8004c6:	eb 17                	jmp    8004df <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  8004c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004cb:	8b 50 04             	mov    0x4(%eax),%edx
  8004ce:	8b 00                	mov    (%eax),%eax
  8004d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004d3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d9:	8d 40 08             	lea    0x8(%eax),%eax
  8004dc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8004df:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004e2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8004e5:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8004ea:	85 c9                	test   %ecx,%ecx
  8004ec:	0f 89 ff 00 00 00    	jns    8005f1 <vprintfmt+0x38c>
				putch('-', putdat);
  8004f2:	83 ec 08             	sub    $0x8,%esp
  8004f5:	53                   	push   %ebx
  8004f6:	6a 2d                	push   $0x2d
  8004f8:	ff d6                	call   *%esi
				num = -(long long) num;
  8004fa:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8004fd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800500:	f7 da                	neg    %edx
  800502:	83 d1 00             	adc    $0x0,%ecx
  800505:	f7 d9                	neg    %ecx
  800507:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80050a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80050f:	e9 dd 00 00 00       	jmp    8005f1 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800514:	8b 45 14             	mov    0x14(%ebp),%eax
  800517:	8b 00                	mov    (%eax),%eax
  800519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051c:	99                   	cltd   
  80051d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800520:	8b 45 14             	mov    0x14(%ebp),%eax
  800523:	8d 40 04             	lea    0x4(%eax),%eax
  800526:	89 45 14             	mov    %eax,0x14(%ebp)
  800529:	eb b4                	jmp    8004df <vprintfmt+0x27a>
	if (lflag >= 2)
  80052b:	83 f9 01             	cmp    $0x1,%ecx
  80052e:	7f 1e                	jg     80054e <vprintfmt+0x2e9>
	else if (lflag)
  800530:	85 c9                	test   %ecx,%ecx
  800532:	74 32                	je     800566 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800534:	8b 45 14             	mov    0x14(%ebp),%eax
  800537:	8b 10                	mov    (%eax),%edx
  800539:	b9 00 00 00 00       	mov    $0x0,%ecx
  80053e:	8d 40 04             	lea    0x4(%eax),%eax
  800541:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800544:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800549:	e9 a3 00 00 00       	jmp    8005f1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8b 10                	mov    (%eax),%edx
  800553:	8b 48 04             	mov    0x4(%eax),%ecx
  800556:	8d 40 08             	lea    0x8(%eax),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80055c:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  800561:	e9 8b 00 00 00       	jmp    8005f1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 10                	mov    (%eax),%edx
  80056b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  80057b:	eb 74                	jmp    8005f1 <vprintfmt+0x38c>
	if (lflag >= 2)
  80057d:	83 f9 01             	cmp    $0x1,%ecx
  800580:	7f 1b                	jg     80059d <vprintfmt+0x338>
	else if (lflag)
  800582:	85 c9                	test   %ecx,%ecx
  800584:	74 2c                	je     8005b2 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  800586:	8b 45 14             	mov    0x14(%ebp),%eax
  800589:	8b 10                	mov    (%eax),%edx
  80058b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800590:	8d 40 04             	lea    0x4(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800596:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  80059b:	eb 54                	jmp    8005f1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 10                	mov    (%eax),%edx
  8005a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a5:	8d 40 08             	lea    0x8(%eax),%eax
  8005a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ab:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005b0:	eb 3f                	jmp    8005f1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b5:	8b 10                	mov    (%eax),%edx
  8005b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bc:	8d 40 04             	lea    0x4(%eax),%eax
  8005bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005c2:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  8005c7:	eb 28                	jmp    8005f1 <vprintfmt+0x38c>
			putch('0', putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	6a 30                	push   $0x30
  8005cf:	ff d6                	call   *%esi
			putch('x', putdat);
  8005d1:	83 c4 08             	add    $0x8,%esp
  8005d4:	53                   	push   %ebx
  8005d5:	6a 78                	push   $0x78
  8005d7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005e3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8005e6:	8d 40 04             	lea    0x4(%eax),%eax
  8005e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005ec:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f1:	83 ec 0c             	sub    $0xc,%esp
  8005f4:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005f8:	57                   	push   %edi
  8005f9:	ff 75 e0             	pushl  -0x20(%ebp)
  8005fc:	50                   	push   %eax
  8005fd:	51                   	push   %ecx
  8005fe:	52                   	push   %edx
  8005ff:	89 da                	mov    %ebx,%edx
  800601:	89 f0                	mov    %esi,%eax
  800603:	e8 72 fb ff ff       	call   80017a <printnum>
			break;
  800608:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  80060e:	83 c7 01             	add    $0x1,%edi
  800611:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800615:	83 f8 25             	cmp    $0x25,%eax
  800618:	0f 84 62 fc ff ff    	je     800280 <vprintfmt+0x1b>
			if (ch == '\0')										
  80061e:	85 c0                	test   %eax,%eax
  800620:	0f 84 8b 00 00 00    	je     8006b1 <vprintfmt+0x44c>
			putch(ch, putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	50                   	push   %eax
  80062b:	ff d6                	call   *%esi
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb dc                	jmp    80060e <vprintfmt+0x3a9>
	if (lflag >= 2)
  800632:	83 f9 01             	cmp    $0x1,%ecx
  800635:	7f 1b                	jg     800652 <vprintfmt+0x3ed>
	else if (lflag)
  800637:	85 c9                	test   %ecx,%ecx
  800639:	74 2c                	je     800667 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80064b:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800650:	eb 9f                	jmp    8005f1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 10                	mov    (%eax),%edx
  800657:	8b 48 04             	mov    0x4(%eax),%ecx
  80065a:	8d 40 08             	lea    0x8(%eax),%eax
  80065d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800660:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  800665:	eb 8a                	jmp    8005f1 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  800667:	8b 45 14             	mov    0x14(%ebp),%eax
  80066a:	8b 10                	mov    (%eax),%edx
  80066c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800671:	8d 40 04             	lea    0x4(%eax),%eax
  800674:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800677:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  80067c:	e9 70 ff ff ff       	jmp    8005f1 <vprintfmt+0x38c>
			putch(ch, putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 25                	push   $0x25
  800687:	ff d6                	call   *%esi
			break;
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	e9 7a ff ff ff       	jmp    80060b <vprintfmt+0x3a6>
			putch('%', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 25                	push   $0x25
  800697:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	89 f8                	mov    %edi,%eax
  80069e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006a2:	74 05                	je     8006a9 <vprintfmt+0x444>
  8006a4:	83 e8 01             	sub    $0x1,%eax
  8006a7:	eb f5                	jmp    80069e <vprintfmt+0x439>
  8006a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ac:	e9 5a ff ff ff       	jmp    80060b <vprintfmt+0x3a6>
}
  8006b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b4:	5b                   	pop    %ebx
  8006b5:	5e                   	pop    %esi
  8006b6:	5f                   	pop    %edi
  8006b7:	5d                   	pop    %ebp
  8006b8:	c3                   	ret    

008006b9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b9:	f3 0f 1e fb          	endbr32 
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	83 ec 18             	sub    $0x18,%esp
  8006c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006cc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006da:	85 c0                	test   %eax,%eax
  8006dc:	74 26                	je     800704 <vsnprintf+0x4b>
  8006de:	85 d2                	test   %edx,%edx
  8006e0:	7e 22                	jle    800704 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e2:	ff 75 14             	pushl  0x14(%ebp)
  8006e5:	ff 75 10             	pushl  0x10(%ebp)
  8006e8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	68 23 02 80 00       	push   $0x800223
  8006f1:	e8 6f fb ff ff       	call   800265 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ff:	83 c4 10             	add    $0x10,%esp
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    
		return -E_INVAL;
  800704:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800709:	eb f7                	jmp    800702 <vsnprintf+0x49>

0080070b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80070b:	f3 0f 1e fb          	endbr32 
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800715:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800718:	50                   	push   %eax
  800719:	ff 75 10             	pushl  0x10(%ebp)
  80071c:	ff 75 0c             	pushl  0xc(%ebp)
  80071f:	ff 75 08             	pushl  0x8(%ebp)
  800722:	e8 92 ff ff ff       	call   8006b9 <vsnprintf>
	va_end(ap);

	return rc;
}
  800727:	c9                   	leave  
  800728:	c3                   	ret    

00800729 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800729:	f3 0f 1e fb          	endbr32 
  80072d:	55                   	push   %ebp
  80072e:	89 e5                	mov    %esp,%ebp
  800730:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800733:	b8 00 00 00 00       	mov    $0x0,%eax
  800738:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073c:	74 05                	je     800743 <strlen+0x1a>
		n++;
  80073e:	83 c0 01             	add    $0x1,%eax
  800741:	eb f5                	jmp    800738 <strlen+0xf>
	return n;
}
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800745:	f3 0f 1e fb          	endbr32 
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800752:	b8 00 00 00 00       	mov    $0x0,%eax
  800757:	39 d0                	cmp    %edx,%eax
  800759:	74 0d                	je     800768 <strnlen+0x23>
  80075b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80075f:	74 05                	je     800766 <strnlen+0x21>
		n++;
  800761:	83 c0 01             	add    $0x1,%eax
  800764:	eb f1                	jmp    800757 <strnlen+0x12>
  800766:	89 c2                	mov    %eax,%edx
	return n;
}
  800768:	89 d0                	mov    %edx,%eax
  80076a:	5d                   	pop    %ebp
  80076b:	c3                   	ret    

0080076c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80076c:	f3 0f 1e fb          	endbr32 
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	53                   	push   %ebx
  800774:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800777:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80077a:	b8 00 00 00 00       	mov    $0x0,%eax
  80077f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800783:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800786:	83 c0 01             	add    $0x1,%eax
  800789:	84 d2                	test   %dl,%dl
  80078b:	75 f2                	jne    80077f <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80078d:	89 c8                	mov    %ecx,%eax
  80078f:	5b                   	pop    %ebx
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800792:	f3 0f 1e fb          	endbr32 
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	53                   	push   %ebx
  80079a:	83 ec 10             	sub    $0x10,%esp
  80079d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007a0:	53                   	push   %ebx
  8007a1:	e8 83 ff ff ff       	call   800729 <strlen>
  8007a6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007a9:	ff 75 0c             	pushl  0xc(%ebp)
  8007ac:	01 d8                	add    %ebx,%eax
  8007ae:	50                   	push   %eax
  8007af:	e8 b8 ff ff ff       	call   80076c <strcpy>
	return dst;
}
  8007b4:	89 d8                	mov    %ebx,%eax
  8007b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007bb:	f3 0f 1e fb          	endbr32 
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	56                   	push   %esi
  8007c3:	53                   	push   %ebx
  8007c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ca:	89 f3                	mov    %esi,%ebx
  8007cc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007cf:	89 f0                	mov    %esi,%eax
  8007d1:	39 d8                	cmp    %ebx,%eax
  8007d3:	74 11                	je     8007e6 <strncpy+0x2b>
		*dst++ = *src;
  8007d5:	83 c0 01             	add    $0x1,%eax
  8007d8:	0f b6 0a             	movzbl (%edx),%ecx
  8007db:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007de:	80 f9 01             	cmp    $0x1,%cl
  8007e1:	83 da ff             	sbb    $0xffffffff,%edx
  8007e4:	eb eb                	jmp    8007d1 <strncpy+0x16>
	}
	return ret;
}
  8007e6:	89 f0                	mov    %esi,%eax
  8007e8:	5b                   	pop    %ebx
  8007e9:	5e                   	pop    %esi
  8007ea:	5d                   	pop    %ebp
  8007eb:	c3                   	ret    

008007ec <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007ec:	f3 0f 1e fb          	endbr32 
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	56                   	push   %esi
  8007f4:	53                   	push   %ebx
  8007f5:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007fb:	8b 55 10             	mov    0x10(%ebp),%edx
  8007fe:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800800:	85 d2                	test   %edx,%edx
  800802:	74 21                	je     800825 <strlcpy+0x39>
  800804:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800808:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80080a:	39 c2                	cmp    %eax,%edx
  80080c:	74 14                	je     800822 <strlcpy+0x36>
  80080e:	0f b6 19             	movzbl (%ecx),%ebx
  800811:	84 db                	test   %bl,%bl
  800813:	74 0b                	je     800820 <strlcpy+0x34>
			*dst++ = *src++;
  800815:	83 c1 01             	add    $0x1,%ecx
  800818:	83 c2 01             	add    $0x1,%edx
  80081b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80081e:	eb ea                	jmp    80080a <strlcpy+0x1e>
  800820:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800822:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800825:	29 f0                	sub    %esi,%eax
}
  800827:	5b                   	pop    %ebx
  800828:	5e                   	pop    %esi
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80082b:	f3 0f 1e fb          	endbr32 
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800835:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800838:	0f b6 01             	movzbl (%ecx),%eax
  80083b:	84 c0                	test   %al,%al
  80083d:	74 0c                	je     80084b <strcmp+0x20>
  80083f:	3a 02                	cmp    (%edx),%al
  800841:	75 08                	jne    80084b <strcmp+0x20>
		p++, q++;
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	83 c2 01             	add    $0x1,%edx
  800849:	eb ed                	jmp    800838 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 c0             	movzbl %al,%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
}
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    

00800855 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800855:	f3 0f 1e fb          	endbr32 
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	53                   	push   %ebx
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	8b 55 0c             	mov    0xc(%ebp),%edx
  800863:	89 c3                	mov    %eax,%ebx
  800865:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800868:	eb 06                	jmp    800870 <strncmp+0x1b>
		n--, p++, q++;
  80086a:	83 c0 01             	add    $0x1,%eax
  80086d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800870:	39 d8                	cmp    %ebx,%eax
  800872:	74 16                	je     80088a <strncmp+0x35>
  800874:	0f b6 08             	movzbl (%eax),%ecx
  800877:	84 c9                	test   %cl,%cl
  800879:	74 04                	je     80087f <strncmp+0x2a>
  80087b:	3a 0a                	cmp    (%edx),%cl
  80087d:	74 eb                	je     80086a <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 00             	movzbl (%eax),%eax
  800882:	0f b6 12             	movzbl (%edx),%edx
  800885:	29 d0                	sub    %edx,%eax
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    
		return 0;
  80088a:	b8 00 00 00 00       	mov    $0x0,%eax
  80088f:	eb f6                	jmp    800887 <strncmp+0x32>

00800891 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800891:	f3 0f 1e fb          	endbr32 
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	8b 45 08             	mov    0x8(%ebp),%eax
  80089b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80089f:	0f b6 10             	movzbl (%eax),%edx
  8008a2:	84 d2                	test   %dl,%dl
  8008a4:	74 09                	je     8008af <strchr+0x1e>
		if (*s == c)
  8008a6:	38 ca                	cmp    %cl,%dl
  8008a8:	74 0a                	je     8008b4 <strchr+0x23>
	for (; *s; s++)
  8008aa:	83 c0 01             	add    $0x1,%eax
  8008ad:	eb f0                	jmp    80089f <strchr+0xe>
			return (char *) s;
	return 0;
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008b6:	f3 0f 1e fb          	endbr32 
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008c7:	38 ca                	cmp    %cl,%dl
  8008c9:	74 09                	je     8008d4 <strfind+0x1e>
  8008cb:	84 d2                	test   %dl,%dl
  8008cd:	74 05                	je     8008d4 <strfind+0x1e>
	for (; *s; s++)
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	eb f0                	jmp    8008c4 <strfind+0xe>
			break;
	return (char *) s;
}
  8008d4:	5d                   	pop    %ebp
  8008d5:	c3                   	ret    

008008d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008d6:	f3 0f 1e fb          	endbr32 
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	57                   	push   %edi
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008e3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008e6:	85 c9                	test   %ecx,%ecx
  8008e8:	74 31                	je     80091b <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ea:	89 f8                	mov    %edi,%eax
  8008ec:	09 c8                	or     %ecx,%eax
  8008ee:	a8 03                	test   $0x3,%al
  8008f0:	75 23                	jne    800915 <memset+0x3f>
		c &= 0xFF;
  8008f2:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008f6:	89 d3                	mov    %edx,%ebx
  8008f8:	c1 e3 08             	shl    $0x8,%ebx
  8008fb:	89 d0                	mov    %edx,%eax
  8008fd:	c1 e0 18             	shl    $0x18,%eax
  800900:	89 d6                	mov    %edx,%esi
  800902:	c1 e6 10             	shl    $0x10,%esi
  800905:	09 f0                	or     %esi,%eax
  800907:	09 c2                	or     %eax,%edx
  800909:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80090b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80090e:	89 d0                	mov    %edx,%eax
  800910:	fc                   	cld    
  800911:	f3 ab                	rep stos %eax,%es:(%edi)
  800913:	eb 06                	jmp    80091b <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800915:	8b 45 0c             	mov    0xc(%ebp),%eax
  800918:	fc                   	cld    
  800919:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80091b:	89 f8                	mov    %edi,%eax
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5f                   	pop    %edi
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800922:	f3 0f 1e fb          	endbr32 
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	57                   	push   %edi
  80092a:	56                   	push   %esi
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800931:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800934:	39 c6                	cmp    %eax,%esi
  800936:	73 32                	jae    80096a <memmove+0x48>
  800938:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80093b:	39 c2                	cmp    %eax,%edx
  80093d:	76 2b                	jbe    80096a <memmove+0x48>
		s += n;
		d += n;
  80093f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800942:	89 fe                	mov    %edi,%esi
  800944:	09 ce                	or     %ecx,%esi
  800946:	09 d6                	or     %edx,%esi
  800948:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80094e:	75 0e                	jne    80095e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800950:	83 ef 04             	sub    $0x4,%edi
  800953:	8d 72 fc             	lea    -0x4(%edx),%esi
  800956:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800959:	fd                   	std    
  80095a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80095c:	eb 09                	jmp    800967 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80095e:	83 ef 01             	sub    $0x1,%edi
  800961:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800964:	fd                   	std    
  800965:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800967:	fc                   	cld    
  800968:	eb 1a                	jmp    800984 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80096a:	89 c2                	mov    %eax,%edx
  80096c:	09 ca                	or     %ecx,%edx
  80096e:	09 f2                	or     %esi,%edx
  800970:	f6 c2 03             	test   $0x3,%dl
  800973:	75 0a                	jne    80097f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800975:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800978:	89 c7                	mov    %eax,%edi
  80097a:	fc                   	cld    
  80097b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097d:	eb 05                	jmp    800984 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80097f:	89 c7                	mov    %eax,%edi
  800981:	fc                   	cld    
  800982:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800984:	5e                   	pop    %esi
  800985:	5f                   	pop    %edi
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800988:	f3 0f 1e fb          	endbr32 
  80098c:	55                   	push   %ebp
  80098d:	89 e5                	mov    %esp,%ebp
  80098f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800992:	ff 75 10             	pushl  0x10(%ebp)
  800995:	ff 75 0c             	pushl  0xc(%ebp)
  800998:	ff 75 08             	pushl  0x8(%ebp)
  80099b:	e8 82 ff ff ff       	call   800922 <memmove>
}
  8009a0:	c9                   	leave  
  8009a1:	c3                   	ret    

008009a2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009a2:	f3 0f 1e fb          	endbr32 
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	89 c6                	mov    %eax,%esi
  8009b3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b6:	39 f0                	cmp    %esi,%eax
  8009b8:	74 1c                	je     8009d6 <memcmp+0x34>
		if (*s1 != *s2)
  8009ba:	0f b6 08             	movzbl (%eax),%ecx
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	38 d9                	cmp    %bl,%cl
  8009c2:	75 08                	jne    8009cc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009c4:	83 c0 01             	add    $0x1,%eax
  8009c7:	83 c2 01             	add    $0x1,%edx
  8009ca:	eb ea                	jmp    8009b6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009cc:	0f b6 c1             	movzbl %cl,%eax
  8009cf:	0f b6 db             	movzbl %bl,%ebx
  8009d2:	29 d8                	sub    %ebx,%eax
  8009d4:	eb 05                	jmp    8009db <memcmp+0x39>
	}

	return 0;
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	5b                   	pop    %ebx
  8009dc:	5e                   	pop    %esi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009ec:	89 c2                	mov    %eax,%edx
  8009ee:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009f1:	39 d0                	cmp    %edx,%eax
  8009f3:	73 09                	jae    8009fe <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009f5:	38 08                	cmp    %cl,(%eax)
  8009f7:	74 05                	je     8009fe <memfind+0x1f>
	for (; s < ends; s++)
  8009f9:	83 c0 01             	add    $0x1,%eax
  8009fc:	eb f3                	jmp    8009f1 <memfind+0x12>
			break;
	return (void *) s;
}
  8009fe:	5d                   	pop    %ebp
  8009ff:	c3                   	ret    

00800a00 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a00:	f3 0f 1e fb          	endbr32 
  800a04:	55                   	push   %ebp
  800a05:	89 e5                	mov    %esp,%ebp
  800a07:	57                   	push   %edi
  800a08:	56                   	push   %esi
  800a09:	53                   	push   %ebx
  800a0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a10:	eb 03                	jmp    800a15 <strtol+0x15>
		s++;
  800a12:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a15:	0f b6 01             	movzbl (%ecx),%eax
  800a18:	3c 20                	cmp    $0x20,%al
  800a1a:	74 f6                	je     800a12 <strtol+0x12>
  800a1c:	3c 09                	cmp    $0x9,%al
  800a1e:	74 f2                	je     800a12 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a20:	3c 2b                	cmp    $0x2b,%al
  800a22:	74 2a                	je     800a4e <strtol+0x4e>
	int neg = 0;
  800a24:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a29:	3c 2d                	cmp    $0x2d,%al
  800a2b:	74 2b                	je     800a58 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a33:	75 0f                	jne    800a44 <strtol+0x44>
  800a35:	80 39 30             	cmpb   $0x30,(%ecx)
  800a38:	74 28                	je     800a62 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3a:	85 db                	test   %ebx,%ebx
  800a3c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a41:	0f 44 d8             	cmove  %eax,%ebx
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
  800a49:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a4c:	eb 46                	jmp    800a94 <strtol+0x94>
		s++;
  800a4e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a51:	bf 00 00 00 00       	mov    $0x0,%edi
  800a56:	eb d5                	jmp    800a2d <strtol+0x2d>
		s++, neg = 1;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a60:	eb cb                	jmp    800a2d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a62:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a66:	74 0e                	je     800a76 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a68:	85 db                	test   %ebx,%ebx
  800a6a:	75 d8                	jne    800a44 <strtol+0x44>
		s++, base = 8;
  800a6c:	83 c1 01             	add    $0x1,%ecx
  800a6f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a74:	eb ce                	jmp    800a44 <strtol+0x44>
		s += 2, base = 16;
  800a76:	83 c1 02             	add    $0x2,%ecx
  800a79:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a7e:	eb c4                	jmp    800a44 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a80:	0f be d2             	movsbl %dl,%edx
  800a83:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a86:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a89:	7d 3a                	jge    800ac5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a8b:	83 c1 01             	add    $0x1,%ecx
  800a8e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a92:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a94:	0f b6 11             	movzbl (%ecx),%edx
  800a97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 09             	cmp    $0x9,%bl
  800a9f:	76 df                	jbe    800a80 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800aa1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa4:	89 f3                	mov    %esi,%ebx
  800aa6:	80 fb 19             	cmp    $0x19,%bl
  800aa9:	77 08                	ja     800ab3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aab:	0f be d2             	movsbl %dl,%edx
  800aae:	83 ea 57             	sub    $0x57,%edx
  800ab1:	eb d3                	jmp    800a86 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ab3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab6:	89 f3                	mov    %esi,%ebx
  800ab8:	80 fb 19             	cmp    $0x19,%bl
  800abb:	77 08                	ja     800ac5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800abd:	0f be d2             	movsbl %dl,%edx
  800ac0:	83 ea 37             	sub    $0x37,%edx
  800ac3:	eb c1                	jmp    800a86 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ac5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ac9:	74 05                	je     800ad0 <strtol+0xd0>
		*endptr = (char *) s;
  800acb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ace:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ad0:	89 c2                	mov    %eax,%edx
  800ad2:	f7 da                	neg    %edx
  800ad4:	85 ff                	test   %edi,%edi
  800ad6:	0f 45 c2             	cmovne %edx,%eax
}
  800ad9:	5b                   	pop    %ebx
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ade:	f3 0f 1e fb          	endbr32 
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  800aed:	8b 55 08             	mov    0x8(%ebp),%edx
  800af0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800af3:	89 c3                	mov    %eax,%ebx
  800af5:	89 c7                	mov    %eax,%edi
  800af7:	89 c6                	mov    %eax,%esi
  800af9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5f                   	pop    %edi
  800afe:	5d                   	pop    %ebp
  800aff:	c3                   	ret    

00800b00 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b00:	f3 0f 1e fb          	endbr32 
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	57                   	push   %edi
  800b08:	56                   	push   %esi
  800b09:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b14:	89 d1                	mov    %edx,%ecx
  800b16:	89 d3                	mov    %edx,%ebx
  800b18:	89 d7                	mov    %edx,%edi
  800b1a:	89 d6                	mov    %edx,%esi
  800b1c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b23:	f3 0f 1e fb          	endbr32 
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	57                   	push   %edi
  800b2b:	56                   	push   %esi
  800b2c:	53                   	push   %ebx
  800b2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
  800b38:	b8 03 00 00 00       	mov    $0x3,%eax
  800b3d:	89 cb                	mov    %ecx,%ebx
  800b3f:	89 cf                	mov    %ecx,%edi
  800b41:	89 ce                	mov    %ecx,%esi
  800b43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b45:	85 c0                	test   %eax,%eax
  800b47:	7f 08                	jg     800b51 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b4c:	5b                   	pop    %ebx
  800b4d:	5e                   	pop    %esi
  800b4e:	5f                   	pop    %edi
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	50                   	push   %eax
  800b55:	6a 03                	push   $0x3
  800b57:	68 c4 12 80 00       	push   $0x8012c4
  800b5c:	6a 23                	push   $0x23
  800b5e:	68 e1 12 80 00       	push   $0x8012e1
  800b63:	e8 11 02 00 00       	call   800d79 <_panic>

00800b68 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b68:	f3 0f 1e fb          	endbr32 
  800b6c:	55                   	push   %ebp
  800b6d:	89 e5                	mov    %esp,%ebp
  800b6f:	57                   	push   %edi
  800b70:	56                   	push   %esi
  800b71:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	b8 02 00 00 00       	mov    $0x2,%eax
  800b7c:	89 d1                	mov    %edx,%ecx
  800b7e:	89 d3                	mov    %edx,%ebx
  800b80:	89 d7                	mov    %edx,%edi
  800b82:	89 d6                	mov    %edx,%esi
  800b84:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_yield>:

void
sys_yield(void)
{
  800b8b:	f3 0f 1e fb          	endbr32 
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	f3 0f 1e fb          	endbr32 
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bbb:	be 00 00 00 00       	mov    $0x0,%esi
  800bc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bce:	89 f7                	mov    %esi,%edi
  800bd0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd2:	85 c0                	test   %eax,%eax
  800bd4:	7f 08                	jg     800bde <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd9:	5b                   	pop    %ebx
  800bda:	5e                   	pop    %esi
  800bdb:	5f                   	pop    %edi
  800bdc:	5d                   	pop    %ebp
  800bdd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 04                	push   $0x4
  800be4:	68 c4 12 80 00       	push   $0x8012c4
  800be9:	6a 23                	push   $0x23
  800beb:	68 e1 12 80 00       	push   $0x8012e1
  800bf0:	e8 84 01 00 00       	call   800d79 <_panic>

00800bf5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf5:	f3 0f 1e fb          	endbr32 
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	57                   	push   %edi
  800bfd:	56                   	push   %esi
  800bfe:	53                   	push   %ebx
  800bff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c08:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c10:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c13:	8b 75 18             	mov    0x18(%ebp),%esi
  800c16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c18:	85 c0                	test   %eax,%eax
  800c1a:	7f 08                	jg     800c24 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1f:	5b                   	pop    %ebx
  800c20:	5e                   	pop    %esi
  800c21:	5f                   	pop    %edi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c24:	83 ec 0c             	sub    $0xc,%esp
  800c27:	50                   	push   %eax
  800c28:	6a 05                	push   $0x5
  800c2a:	68 c4 12 80 00       	push   $0x8012c4
  800c2f:	6a 23                	push   $0x23
  800c31:	68 e1 12 80 00       	push   $0x8012e1
  800c36:	e8 3e 01 00 00       	call   800d79 <_panic>

00800c3b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3b:	f3 0f 1e fb          	endbr32 
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c48:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	b8 06 00 00 00       	mov    $0x6,%eax
  800c58:	89 df                	mov    %ebx,%edi
  800c5a:	89 de                	mov    %ebx,%esi
  800c5c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	7f 08                	jg     800c6a <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c62:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c6a:	83 ec 0c             	sub    $0xc,%esp
  800c6d:	50                   	push   %eax
  800c6e:	6a 06                	push   $0x6
  800c70:	68 c4 12 80 00       	push   $0x8012c4
  800c75:	6a 23                	push   $0x23
  800c77:	68 e1 12 80 00       	push   $0x8012e1
  800c7c:	e8 f8 00 00 00       	call   800d79 <_panic>

00800c81 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c81:	f3 0f 1e fb          	endbr32 
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	57                   	push   %edi
  800c89:	56                   	push   %esi
  800c8a:	53                   	push   %ebx
  800c8b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c93:	8b 55 08             	mov    0x8(%ebp),%edx
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9e:	89 df                	mov    %ebx,%edi
  800ca0:	89 de                	mov    %ebx,%esi
  800ca2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca4:	85 c0                	test   %eax,%eax
  800ca6:	7f 08                	jg     800cb0 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb0:	83 ec 0c             	sub    $0xc,%esp
  800cb3:	50                   	push   %eax
  800cb4:	6a 08                	push   $0x8
  800cb6:	68 c4 12 80 00       	push   $0x8012c4
  800cbb:	6a 23                	push   $0x23
  800cbd:	68 e1 12 80 00       	push   $0x8012e1
  800cc2:	e8 b2 00 00 00       	call   800d79 <_panic>

00800cc7 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc7:	f3 0f 1e fb          	endbr32 
  800ccb:	55                   	push   %ebp
  800ccc:	89 e5                	mov    %esp,%ebp
  800cce:	57                   	push   %edi
  800ccf:	56                   	push   %esi
  800cd0:	53                   	push   %ebx
  800cd1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cd4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdf:	b8 09 00 00 00       	mov    $0x9,%eax
  800ce4:	89 df                	mov    %ebx,%edi
  800ce6:	89 de                	mov    %ebx,%esi
  800ce8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cea:	85 c0                	test   %eax,%eax
  800cec:	7f 08                	jg     800cf6 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf6:	83 ec 0c             	sub    $0xc,%esp
  800cf9:	50                   	push   %eax
  800cfa:	6a 09                	push   $0x9
  800cfc:	68 c4 12 80 00       	push   $0x8012c4
  800d01:	6a 23                	push   $0x23
  800d03:	68 e1 12 80 00       	push   $0x8012e1
  800d08:	e8 6c 00 00 00       	call   800d79 <_panic>

00800d0d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0d:	f3 0f 1e fb          	endbr32 
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	57                   	push   %edi
  800d15:	56                   	push   %esi
  800d16:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d17:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d22:	be 00 00 00 00       	mov    $0x0,%esi
  800d27:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2a:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    

00800d34 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d34:	f3 0f 1e fb          	endbr32 
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	57                   	push   %edi
  800d3c:	56                   	push   %esi
  800d3d:	53                   	push   %ebx
  800d3e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d41:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d46:	8b 55 08             	mov    0x8(%ebp),%edx
  800d49:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4e:	89 cb                	mov    %ecx,%ebx
  800d50:	89 cf                	mov    %ecx,%edi
  800d52:	89 ce                	mov    %ecx,%esi
  800d54:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d56:	85 c0                	test   %eax,%eax
  800d58:	7f 08                	jg     800d62 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d5d:	5b                   	pop    %ebx
  800d5e:	5e                   	pop    %esi
  800d5f:	5f                   	pop    %edi
  800d60:	5d                   	pop    %ebp
  800d61:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	50                   	push   %eax
  800d66:	6a 0c                	push   $0xc
  800d68:	68 c4 12 80 00       	push   $0x8012c4
  800d6d:	6a 23                	push   $0x23
  800d6f:	68 e1 12 80 00       	push   $0x8012e1
  800d74:	e8 00 00 00 00       	call   800d79 <_panic>

00800d79 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800d79:	f3 0f 1e fb          	endbr32 
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
  800d80:	56                   	push   %esi
  800d81:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800d82:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800d85:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800d8b:	e8 d8 fd ff ff       	call   800b68 <sys_getenvid>
  800d90:	83 ec 0c             	sub    $0xc,%esp
  800d93:	ff 75 0c             	pushl  0xc(%ebp)
  800d96:	ff 75 08             	pushl  0x8(%ebp)
  800d99:	56                   	push   %esi
  800d9a:	50                   	push   %eax
  800d9b:	68 f0 12 80 00       	push   $0x8012f0
  800da0:	e8 bd f3 ff ff       	call   800162 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800da5:	83 c4 18             	add    $0x18,%esp
  800da8:	53                   	push   %ebx
  800da9:	ff 75 10             	pushl  0x10(%ebp)
  800dac:	e8 5c f3 ff ff       	call   80010d <vcprintf>
	cprintf("\n");
  800db1:	c7 04 24 4c 10 80 00 	movl   $0x80104c,(%esp)
  800db8:	e8 a5 f3 ff ff       	call   800162 <cprintf>
  800dbd:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dc0:	cc                   	int3   
  800dc1:	eb fd                	jmp    800dc0 <_panic+0x47>
  800dc3:	66 90                	xchg   %ax,%ax
  800dc5:	66 90                	xchg   %ax,%ax
  800dc7:	66 90                	xchg   %ax,%ax
  800dc9:	66 90                	xchg   %ax,%ax
  800dcb:	66 90                	xchg   %ax,%ax
  800dcd:	66 90                	xchg   %ax,%ax
  800dcf:	90                   	nop

00800dd0 <__udivdi3>:
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	57                   	push   %edi
  800dd6:	56                   	push   %esi
  800dd7:	53                   	push   %ebx
  800dd8:	83 ec 1c             	sub    $0x1c,%esp
  800ddb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800ddf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800de3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800de7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800deb:	85 d2                	test   %edx,%edx
  800ded:	75 19                	jne    800e08 <__udivdi3+0x38>
  800def:	39 f3                	cmp    %esi,%ebx
  800df1:	76 4d                	jbe    800e40 <__udivdi3+0x70>
  800df3:	31 ff                	xor    %edi,%edi
  800df5:	89 e8                	mov    %ebp,%eax
  800df7:	89 f2                	mov    %esi,%edx
  800df9:	f7 f3                	div    %ebx
  800dfb:	89 fa                	mov    %edi,%edx
  800dfd:	83 c4 1c             	add    $0x1c,%esp
  800e00:	5b                   	pop    %ebx
  800e01:	5e                   	pop    %esi
  800e02:	5f                   	pop    %edi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    
  800e05:	8d 76 00             	lea    0x0(%esi),%esi
  800e08:	39 f2                	cmp    %esi,%edx
  800e0a:	76 14                	jbe    800e20 <__udivdi3+0x50>
  800e0c:	31 ff                	xor    %edi,%edi
  800e0e:	31 c0                	xor    %eax,%eax
  800e10:	89 fa                	mov    %edi,%edx
  800e12:	83 c4 1c             	add    $0x1c,%esp
  800e15:	5b                   	pop    %ebx
  800e16:	5e                   	pop    %esi
  800e17:	5f                   	pop    %edi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
  800e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e20:	0f bd fa             	bsr    %edx,%edi
  800e23:	83 f7 1f             	xor    $0x1f,%edi
  800e26:	75 48                	jne    800e70 <__udivdi3+0xa0>
  800e28:	39 f2                	cmp    %esi,%edx
  800e2a:	72 06                	jb     800e32 <__udivdi3+0x62>
  800e2c:	31 c0                	xor    %eax,%eax
  800e2e:	39 eb                	cmp    %ebp,%ebx
  800e30:	77 de                	ja     800e10 <__udivdi3+0x40>
  800e32:	b8 01 00 00 00       	mov    $0x1,%eax
  800e37:	eb d7                	jmp    800e10 <__udivdi3+0x40>
  800e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e40:	89 d9                	mov    %ebx,%ecx
  800e42:	85 db                	test   %ebx,%ebx
  800e44:	75 0b                	jne    800e51 <__udivdi3+0x81>
  800e46:	b8 01 00 00 00       	mov    $0x1,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	f7 f3                	div    %ebx
  800e4f:	89 c1                	mov    %eax,%ecx
  800e51:	31 d2                	xor    %edx,%edx
  800e53:	89 f0                	mov    %esi,%eax
  800e55:	f7 f1                	div    %ecx
  800e57:	89 c6                	mov    %eax,%esi
  800e59:	89 e8                	mov    %ebp,%eax
  800e5b:	89 f7                	mov    %esi,%edi
  800e5d:	f7 f1                	div    %ecx
  800e5f:	89 fa                	mov    %edi,%edx
  800e61:	83 c4 1c             	add    $0x1c,%esp
  800e64:	5b                   	pop    %ebx
  800e65:	5e                   	pop    %esi
  800e66:	5f                   	pop    %edi
  800e67:	5d                   	pop    %ebp
  800e68:	c3                   	ret    
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 f9                	mov    %edi,%ecx
  800e72:	b8 20 00 00 00       	mov    $0x20,%eax
  800e77:	29 f8                	sub    %edi,%eax
  800e79:	d3 e2                	shl    %cl,%edx
  800e7b:	89 54 24 08          	mov    %edx,0x8(%esp)
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 da                	mov    %ebx,%edx
  800e83:	d3 ea                	shr    %cl,%edx
  800e85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e89:	09 d1                	or     %edx,%ecx
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e91:	89 f9                	mov    %edi,%ecx
  800e93:	d3 e3                	shl    %cl,%ebx
  800e95:	89 c1                	mov    %eax,%ecx
  800e97:	d3 ea                	shr    %cl,%edx
  800e99:	89 f9                	mov    %edi,%ecx
  800e9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e9f:	89 eb                	mov    %ebp,%ebx
  800ea1:	d3 e6                	shl    %cl,%esi
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	d3 eb                	shr    %cl,%ebx
  800ea7:	09 de                	or     %ebx,%esi
  800ea9:	89 f0                	mov    %esi,%eax
  800eab:	f7 74 24 08          	divl   0x8(%esp)
  800eaf:	89 d6                	mov    %edx,%esi
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	f7 64 24 0c          	mull   0xc(%esp)
  800eb7:	39 d6                	cmp    %edx,%esi
  800eb9:	72 15                	jb     800ed0 <__udivdi3+0x100>
  800ebb:	89 f9                	mov    %edi,%ecx
  800ebd:	d3 e5                	shl    %cl,%ebp
  800ebf:	39 c5                	cmp    %eax,%ebp
  800ec1:	73 04                	jae    800ec7 <__udivdi3+0xf7>
  800ec3:	39 d6                	cmp    %edx,%esi
  800ec5:	74 09                	je     800ed0 <__udivdi3+0x100>
  800ec7:	89 d8                	mov    %ebx,%eax
  800ec9:	31 ff                	xor    %edi,%edi
  800ecb:	e9 40 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800ed0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ed3:	31 ff                	xor    %edi,%edi
  800ed5:	e9 36 ff ff ff       	jmp    800e10 <__udivdi3+0x40>
  800eda:	66 90                	xchg   %ax,%ax
  800edc:	66 90                	xchg   %ax,%ax
  800ede:	66 90                	xchg   %ax,%ax

00800ee0 <__umoddi3>:
  800ee0:	f3 0f 1e fb          	endbr32 
  800ee4:	55                   	push   %ebp
  800ee5:	57                   	push   %edi
  800ee6:	56                   	push   %esi
  800ee7:	53                   	push   %ebx
  800ee8:	83 ec 1c             	sub    $0x1c,%esp
  800eeb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800eef:	8b 74 24 30          	mov    0x30(%esp),%esi
  800ef3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ef7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800efb:	85 c0                	test   %eax,%eax
  800efd:	75 19                	jne    800f18 <__umoddi3+0x38>
  800eff:	39 df                	cmp    %ebx,%edi
  800f01:	76 5d                	jbe    800f60 <__umoddi3+0x80>
  800f03:	89 f0                	mov    %esi,%eax
  800f05:	89 da                	mov    %ebx,%edx
  800f07:	f7 f7                	div    %edi
  800f09:	89 d0                	mov    %edx,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	83 c4 1c             	add    $0x1c,%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    
  800f15:	8d 76 00             	lea    0x0(%esi),%esi
  800f18:	89 f2                	mov    %esi,%edx
  800f1a:	39 d8                	cmp    %ebx,%eax
  800f1c:	76 12                	jbe    800f30 <__umoddi3+0x50>
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	89 da                	mov    %ebx,%edx
  800f22:	83 c4 1c             	add    $0x1c,%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	0f bd e8             	bsr    %eax,%ebp
  800f33:	83 f5 1f             	xor    $0x1f,%ebp
  800f36:	75 50                	jne    800f88 <__umoddi3+0xa8>
  800f38:	39 d8                	cmp    %ebx,%eax
  800f3a:	0f 82 e0 00 00 00    	jb     801020 <__umoddi3+0x140>
  800f40:	89 d9                	mov    %ebx,%ecx
  800f42:	39 f7                	cmp    %esi,%edi
  800f44:	0f 86 d6 00 00 00    	jbe    801020 <__umoddi3+0x140>
  800f4a:	89 d0                	mov    %edx,%eax
  800f4c:	89 ca                	mov    %ecx,%edx
  800f4e:	83 c4 1c             	add    $0x1c,%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5f                   	pop    %edi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
  800f56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	89 fd                	mov    %edi,%ebp
  800f62:	85 ff                	test   %edi,%edi
  800f64:	75 0b                	jne    800f71 <__umoddi3+0x91>
  800f66:	b8 01 00 00 00       	mov    $0x1,%eax
  800f6b:	31 d2                	xor    %edx,%edx
  800f6d:	f7 f7                	div    %edi
  800f6f:	89 c5                	mov    %eax,%ebp
  800f71:	89 d8                	mov    %ebx,%eax
  800f73:	31 d2                	xor    %edx,%edx
  800f75:	f7 f5                	div    %ebp
  800f77:	89 f0                	mov    %esi,%eax
  800f79:	f7 f5                	div    %ebp
  800f7b:	89 d0                	mov    %edx,%eax
  800f7d:	31 d2                	xor    %edx,%edx
  800f7f:	eb 8c                	jmp    800f0d <__umoddi3+0x2d>
  800f81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f88:	89 e9                	mov    %ebp,%ecx
  800f8a:	ba 20 00 00 00       	mov    $0x20,%edx
  800f8f:	29 ea                	sub    %ebp,%edx
  800f91:	d3 e0                	shl    %cl,%eax
  800f93:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f97:	89 d1                	mov    %edx,%ecx
  800f99:	89 f8                	mov    %edi,%eax
  800f9b:	d3 e8                	shr    %cl,%eax
  800f9d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fa5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fa9:	09 c1                	or     %eax,%ecx
  800fab:	89 d8                	mov    %ebx,%eax
  800fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fb1:	89 e9                	mov    %ebp,%ecx
  800fb3:	d3 e7                	shl    %cl,%edi
  800fb5:	89 d1                	mov    %edx,%ecx
  800fb7:	d3 e8                	shr    %cl,%eax
  800fb9:	89 e9                	mov    %ebp,%ecx
  800fbb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fbf:	d3 e3                	shl    %cl,%ebx
  800fc1:	89 c7                	mov    %eax,%edi
  800fc3:	89 d1                	mov    %edx,%ecx
  800fc5:	89 f0                	mov    %esi,%eax
  800fc7:	d3 e8                	shr    %cl,%eax
  800fc9:	89 e9                	mov    %ebp,%ecx
  800fcb:	89 fa                	mov    %edi,%edx
  800fcd:	d3 e6                	shl    %cl,%esi
  800fcf:	09 d8                	or     %ebx,%eax
  800fd1:	f7 74 24 08          	divl   0x8(%esp)
  800fd5:	89 d1                	mov    %edx,%ecx
  800fd7:	89 f3                	mov    %esi,%ebx
  800fd9:	f7 64 24 0c          	mull   0xc(%esp)
  800fdd:	89 c6                	mov    %eax,%esi
  800fdf:	89 d7                	mov    %edx,%edi
  800fe1:	39 d1                	cmp    %edx,%ecx
  800fe3:	72 06                	jb     800feb <__umoddi3+0x10b>
  800fe5:	75 10                	jne    800ff7 <__umoddi3+0x117>
  800fe7:	39 c3                	cmp    %eax,%ebx
  800fe9:	73 0c                	jae    800ff7 <__umoddi3+0x117>
  800feb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  800fef:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ff3:	89 d7                	mov    %edx,%edi
  800ff5:	89 c6                	mov    %eax,%esi
  800ff7:	89 ca                	mov    %ecx,%edx
  800ff9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ffe:	29 f3                	sub    %esi,%ebx
  801000:	19 fa                	sbb    %edi,%edx
  801002:	89 d0                	mov    %edx,%eax
  801004:	d3 e0                	shl    %cl,%eax
  801006:	89 e9                	mov    %ebp,%ecx
  801008:	d3 eb                	shr    %cl,%ebx
  80100a:	d3 ea                	shr    %cl,%edx
  80100c:	09 d8                	or     %ebx,%eax
  80100e:	83 c4 1c             	add    $0x1c,%esp
  801011:	5b                   	pop    %ebx
  801012:	5e                   	pop    %esi
  801013:	5f                   	pop    %edi
  801014:	5d                   	pop    %ebp
  801015:	c3                   	ret    
  801016:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80101d:	8d 76 00             	lea    0x0(%esi),%esi
  801020:	29 fe                	sub    %edi,%esi
  801022:	19 c3                	sbb    %eax,%ebx
  801024:	89 f2                	mov    %esi,%edx
  801026:	89 d9                	mov    %ebx,%ecx
  801028:	e9 1d ff ff ff       	jmp    800f4a <__umoddi3+0x6a>
