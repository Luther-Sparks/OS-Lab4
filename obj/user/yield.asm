
obj/user/yield:     file format elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003e:	a1 60 40 80 00       	mov    0x804060,%eax
  800043:	8b 40 48             	mov    0x48(%eax),%eax
  800046:	50                   	push   %eax
  800047:	68 60 10 80 00       	push   $0x801060
  80004c:	e8 4d 01 00 00       	call   80019e <cprintf>
  800051:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < 5; i++) {
  800054:	bb 00 00 00 00       	mov    $0x0,%ebx
		sys_yield();
  800059:	e8 69 0b 00 00       	call   800bc7 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005e:	a1 60 40 80 00       	mov    0x804060,%eax
		cprintf("Back in environment %08x, iteration %d.\n",
  800063:	8b 40 48             	mov    0x48(%eax),%eax
  800066:	83 ec 04             	sub    $0x4,%esp
  800069:	53                   	push   %ebx
  80006a:	50                   	push   %eax
  80006b:	68 80 10 80 00       	push   $0x801080
  800070:	e8 29 01 00 00       	call   80019e <cprintf>
	for (i = 0; i < 5; i++) {
  800075:	83 c3 01             	add    $0x1,%ebx
  800078:	83 c4 10             	add    $0x10,%esp
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d9                	jne    800059 <umain+0x26>
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 60 40 80 00       	mov    0x804060,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	50                   	push   %eax
  80008c:	68 ac 10 80 00       	push   $0x8010ac
  800091:	e8 08 01 00 00       	call   80019e <cprintf>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	f3 0f 1e fb          	endbr32 
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	56                   	push   %esi
  8000a6:	53                   	push   %ebx
  8000a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000aa:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000ad:	e8 f2 0a 00 00       	call   800ba4 <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000b2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b7:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8000bd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c2:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c7:	85 db                	test   %ebx,%ebx
  8000c9:	7e 07                	jle    8000d2 <libmain+0x34>
		binaryname = argv[0];
  8000cb:	8b 06                	mov    (%esi),%eax
  8000cd:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	56                   	push   %esi
  8000d6:	53                   	push   %ebx
  8000d7:	e8 57 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 0a 00 00 00       	call   8000eb <exit>
}
  8000e1:	83 c4 10             	add    $0x10,%esp
  8000e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000e7:	5b                   	pop    %ebx
  8000e8:	5e                   	pop    %esi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000eb:	f3 0f 1e fb          	endbr32 
  8000ef:	55                   	push   %ebp
  8000f0:	89 e5                	mov    %esp,%ebp
  8000f2:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000f5:	6a 00                	push   $0x0
  8000f7:	e8 63 0a 00 00       	call   800b5f <sys_env_destroy>
}
  8000fc:	83 c4 10             	add    $0x10,%esp
  8000ff:	c9                   	leave  
  800100:	c3                   	ret    

00800101 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800101:	f3 0f 1e fb          	endbr32 
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	53                   	push   %ebx
  800109:	83 ec 04             	sub    $0x4,%esp
  80010c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80010f:	8b 13                	mov    (%ebx),%edx
  800111:	8d 42 01             	lea    0x1(%edx),%eax
  800114:	89 03                	mov    %eax,(%ebx)
  800116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800119:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80011d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800122:	74 09                	je     80012d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800124:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800128:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	68 ff 00 00 00       	push   $0xff
  800135:	8d 43 08             	lea    0x8(%ebx),%eax
  800138:	50                   	push   %eax
  800139:	e8 dc 09 00 00       	call   800b1a <sys_cputs>
		b->idx = 0;
  80013e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800144:	83 c4 10             	add    $0x10,%esp
  800147:	eb db                	jmp    800124 <putch+0x23>

00800149 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800149:	f3 0f 1e fb          	endbr32 
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800156:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80015d:	00 00 00 
	b.cnt = 0;
  800160:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800167:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80016a:	ff 75 0c             	pushl  0xc(%ebp)
  80016d:	ff 75 08             	pushl  0x8(%ebp)
  800170:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800176:	50                   	push   %eax
  800177:	68 01 01 80 00       	push   $0x800101
  80017c:	e8 20 01 00 00       	call   8002a1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800181:	83 c4 08             	add    $0x8,%esp
  800184:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80018a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	e8 84 09 00 00       	call   800b1a <sys_cputs>

	return b.cnt;
}
  800196:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80019c:	c9                   	leave  
  80019d:	c3                   	ret    

0080019e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80019e:	f3 0f 1e fb          	endbr32 
  8001a2:	55                   	push   %ebp
  8001a3:	89 e5                	mov    %esp,%ebp
  8001a5:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001a8:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ab:	50                   	push   %eax
  8001ac:	ff 75 08             	pushl  0x8(%ebp)
  8001af:	e8 95 ff ff ff       	call   800149 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001b4:	c9                   	leave  
  8001b5:	c3                   	ret    

008001b6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 1c             	sub    $0x1c,%esp
  8001bf:	89 c7                	mov    %eax,%edi
  8001c1:	89 d6                	mov    %edx,%esi
  8001c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001c9:	89 d1                	mov    %edx,%ecx
  8001cb:	89 c2                	mov    %eax,%edx
  8001cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001e3:	39 c2                	cmp    %eax,%edx
  8001e5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001e8:	72 3e                	jb     800228 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ea:	83 ec 0c             	sub    $0xc,%esp
  8001ed:	ff 75 18             	pushl  0x18(%ebp)
  8001f0:	83 eb 01             	sub    $0x1,%ebx
  8001f3:	53                   	push   %ebx
  8001f4:	50                   	push   %eax
  8001f5:	83 ec 08             	sub    $0x8,%esp
  8001f8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001fe:	ff 75 dc             	pushl  -0x24(%ebp)
  800201:	ff 75 d8             	pushl  -0x28(%ebp)
  800204:	e8 f7 0b 00 00       	call   800e00 <__udivdi3>
  800209:	83 c4 18             	add    $0x18,%esp
  80020c:	52                   	push   %edx
  80020d:	50                   	push   %eax
  80020e:	89 f2                	mov    %esi,%edx
  800210:	89 f8                	mov    %edi,%eax
  800212:	e8 9f ff ff ff       	call   8001b6 <printnum>
  800217:	83 c4 20             	add    $0x20,%esp
  80021a:	eb 13                	jmp    80022f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80021c:	83 ec 08             	sub    $0x8,%esp
  80021f:	56                   	push   %esi
  800220:	ff 75 18             	pushl  0x18(%ebp)
  800223:	ff d7                	call   *%edi
  800225:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	85 db                	test   %ebx,%ebx
  80022d:	7f ed                	jg     80021c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	83 ec 04             	sub    $0x4,%esp
  800236:	ff 75 e4             	pushl  -0x1c(%ebp)
  800239:	ff 75 e0             	pushl  -0x20(%ebp)
  80023c:	ff 75 dc             	pushl  -0x24(%ebp)
  80023f:	ff 75 d8             	pushl  -0x28(%ebp)
  800242:	e8 c9 0c 00 00       	call   800f10 <__umoddi3>
  800247:	83 c4 14             	add    $0x14,%esp
  80024a:	0f be 80 d5 10 80 00 	movsbl 0x8010d5(%eax),%eax
  800251:	50                   	push   %eax
  800252:	ff d7                	call   *%edi
}
  800254:	83 c4 10             	add    $0x10,%esp
  800257:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025a:	5b                   	pop    %ebx
  80025b:	5e                   	pop    %esi
  80025c:	5f                   	pop    %edi
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80025f:	f3 0f 1e fb          	endbr32 
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800269:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80026d:	8b 10                	mov    (%eax),%edx
  80026f:	3b 50 04             	cmp    0x4(%eax),%edx
  800272:	73 0a                	jae    80027e <sprintputch+0x1f>
		*b->buf++ = ch;
  800274:	8d 4a 01             	lea    0x1(%edx),%ecx
  800277:	89 08                	mov    %ecx,(%eax)
  800279:	8b 45 08             	mov    0x8(%ebp),%eax
  80027c:	88 02                	mov    %al,(%edx)
}
  80027e:	5d                   	pop    %ebp
  80027f:	c3                   	ret    

00800280 <printfmt>:
{
  800280:	f3 0f 1e fb          	endbr32 
  800284:	55                   	push   %ebp
  800285:	89 e5                	mov    %esp,%ebp
  800287:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80028a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80028d:	50                   	push   %eax
  80028e:	ff 75 10             	pushl  0x10(%ebp)
  800291:	ff 75 0c             	pushl  0xc(%ebp)
  800294:	ff 75 08             	pushl  0x8(%ebp)
  800297:	e8 05 00 00 00       	call   8002a1 <vprintfmt>
}
  80029c:	83 c4 10             	add    $0x10,%esp
  80029f:	c9                   	leave  
  8002a0:	c3                   	ret    

008002a1 <vprintfmt>:
{
  8002a1:	f3 0f 1e fb          	endbr32 
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 3c             	sub    $0x3c,%esp
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b7:	e9 8e 03 00 00       	jmp    80064a <vprintfmt+0x3a9>
		padc = ' ';
  8002bc:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002c7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002da:	8d 47 01             	lea    0x1(%edi),%eax
  8002dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e0:	0f b6 17             	movzbl (%edi),%edx
  8002e3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002e6:	3c 55                	cmp    $0x55,%al
  8002e8:	0f 87 df 03 00 00    	ja     8006cd <vprintfmt+0x42c>
  8002ee:	0f b6 c0             	movzbl %al,%eax
  8002f1:	3e ff 24 85 a0 11 80 	notrack jmp *0x8011a0(,%eax,4)
  8002f8:	00 
  8002f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8002fc:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800300:	eb d8                	jmp    8002da <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800302:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800305:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800309:	eb cf                	jmp    8002da <vprintfmt+0x39>
  80030b:	0f b6 d2             	movzbl %dl,%edx
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800311:	b8 00 00 00 00       	mov    $0x0,%eax
  800316:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800319:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80031c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800320:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800323:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800326:	83 f9 09             	cmp    $0x9,%ecx
  800329:	77 55                	ja     800380 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  80032b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80032e:	eb e9                	jmp    800319 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800330:	8b 45 14             	mov    0x14(%ebp),%eax
  800333:	8b 00                	mov    (%eax),%eax
  800335:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800338:	8b 45 14             	mov    0x14(%ebp),%eax
  80033b:	8d 40 04             	lea    0x4(%eax),%eax
  80033e:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800344:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800348:	79 90                	jns    8002da <vprintfmt+0x39>
				width = precision, precision = -1;
  80034a:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80034d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800350:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800357:	eb 81                	jmp    8002da <vprintfmt+0x39>
  800359:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80035c:	85 c0                	test   %eax,%eax
  80035e:	ba 00 00 00 00       	mov    $0x0,%edx
  800363:	0f 49 d0             	cmovns %eax,%edx
  800366:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80036c:	e9 69 ff ff ff       	jmp    8002da <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800374:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80037b:	e9 5a ff ff ff       	jmp    8002da <vprintfmt+0x39>
  800380:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800383:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800386:	eb bc                	jmp    800344 <vprintfmt+0xa3>
			lflag++;
  800388:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80038b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80038e:	e9 47 ff ff ff       	jmp    8002da <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800393:	8b 45 14             	mov    0x14(%ebp),%eax
  800396:	8d 78 04             	lea    0x4(%eax),%edi
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	53                   	push   %ebx
  80039d:	ff 30                	pushl  (%eax)
  80039f:	ff d6                	call   *%esi
			break;
  8003a1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003a4:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003a7:	e9 9b 02 00 00       	jmp    800647 <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8003af:	8d 78 04             	lea    0x4(%eax),%edi
  8003b2:	8b 00                	mov    (%eax),%eax
  8003b4:	99                   	cltd   
  8003b5:	31 d0                	xor    %edx,%eax
  8003b7:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003b9:	83 f8 08             	cmp    $0x8,%eax
  8003bc:	7f 23                	jg     8003e1 <vprintfmt+0x140>
  8003be:	8b 14 85 00 13 80 00 	mov    0x801300(,%eax,4),%edx
  8003c5:	85 d2                	test   %edx,%edx
  8003c7:	74 18                	je     8003e1 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003c9:	52                   	push   %edx
  8003ca:	68 f6 10 80 00       	push   $0x8010f6
  8003cf:	53                   	push   %ebx
  8003d0:	56                   	push   %esi
  8003d1:	e8 aa fe ff ff       	call   800280 <printfmt>
  8003d6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003d9:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003dc:	e9 66 02 00 00       	jmp    800647 <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003e1:	50                   	push   %eax
  8003e2:	68 ed 10 80 00       	push   $0x8010ed
  8003e7:	53                   	push   %ebx
  8003e8:	56                   	push   %esi
  8003e9:	e8 92 fe ff ff       	call   800280 <printfmt>
  8003ee:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f1:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003f4:	e9 4e 02 00 00       	jmp    800647 <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	83 c0 04             	add    $0x4,%eax
  8003ff:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800407:	85 d2                	test   %edx,%edx
  800409:	b8 e6 10 80 00       	mov    $0x8010e6,%eax
  80040e:	0f 45 c2             	cmovne %edx,%eax
  800411:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800414:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800418:	7e 06                	jle    800420 <vprintfmt+0x17f>
  80041a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80041e:	75 0d                	jne    80042d <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800420:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800423:	89 c7                	mov    %eax,%edi
  800425:	03 45 e0             	add    -0x20(%ebp),%eax
  800428:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80042b:	eb 55                	jmp    800482 <vprintfmt+0x1e1>
  80042d:	83 ec 08             	sub    $0x8,%esp
  800430:	ff 75 d8             	pushl  -0x28(%ebp)
  800433:	ff 75 cc             	pushl  -0x34(%ebp)
  800436:	e8 46 03 00 00       	call   800781 <strnlen>
  80043b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80043e:	29 c2                	sub    %eax,%edx
  800440:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  800443:	83 c4 10             	add    $0x10,%esp
  800446:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  800448:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80044f:	85 ff                	test   %edi,%edi
  800451:	7e 11                	jle    800464 <vprintfmt+0x1c3>
					putch(padc, putdat);
  800453:	83 ec 08             	sub    $0x8,%esp
  800456:	53                   	push   %ebx
  800457:	ff 75 e0             	pushl  -0x20(%ebp)
  80045a:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80045c:	83 ef 01             	sub    $0x1,%edi
  80045f:	83 c4 10             	add    $0x10,%esp
  800462:	eb eb                	jmp    80044f <vprintfmt+0x1ae>
  800464:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	b8 00 00 00 00       	mov    $0x0,%eax
  80046e:	0f 49 c2             	cmovns %edx,%eax
  800471:	29 c2                	sub    %eax,%edx
  800473:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800476:	eb a8                	jmp    800420 <vprintfmt+0x17f>
					putch(ch, putdat);
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	53                   	push   %ebx
  80047c:	52                   	push   %edx
  80047d:	ff d6                	call   *%esi
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800485:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800487:	83 c7 01             	add    $0x1,%edi
  80048a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048e:	0f be d0             	movsbl %al,%edx
  800491:	85 d2                	test   %edx,%edx
  800493:	74 4b                	je     8004e0 <vprintfmt+0x23f>
  800495:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800499:	78 06                	js     8004a1 <vprintfmt+0x200>
  80049b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80049f:	78 1e                	js     8004bf <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004a5:	74 d1                	je     800478 <vprintfmt+0x1d7>
  8004a7:	0f be c0             	movsbl %al,%eax
  8004aa:	83 e8 20             	sub    $0x20,%eax
  8004ad:	83 f8 5e             	cmp    $0x5e,%eax
  8004b0:	76 c6                	jbe    800478 <vprintfmt+0x1d7>
					putch('?', putdat);
  8004b2:	83 ec 08             	sub    $0x8,%esp
  8004b5:	53                   	push   %ebx
  8004b6:	6a 3f                	push   $0x3f
  8004b8:	ff d6                	call   *%esi
  8004ba:	83 c4 10             	add    $0x10,%esp
  8004bd:	eb c3                	jmp    800482 <vprintfmt+0x1e1>
  8004bf:	89 cf                	mov    %ecx,%edi
  8004c1:	eb 0e                	jmp    8004d1 <vprintfmt+0x230>
				putch(' ', putdat);
  8004c3:	83 ec 08             	sub    $0x8,%esp
  8004c6:	53                   	push   %ebx
  8004c7:	6a 20                	push   $0x20
  8004c9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004cb:	83 ef 01             	sub    $0x1,%edi
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	85 ff                	test   %edi,%edi
  8004d3:	7f ee                	jg     8004c3 <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004d5:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004d8:	89 45 14             	mov    %eax,0x14(%ebp)
  8004db:	e9 67 01 00 00       	jmp    800647 <vprintfmt+0x3a6>
  8004e0:	89 cf                	mov    %ecx,%edi
  8004e2:	eb ed                	jmp    8004d1 <vprintfmt+0x230>
	if (lflag >= 2)
  8004e4:	83 f9 01             	cmp    $0x1,%ecx
  8004e7:	7f 1b                	jg     800504 <vprintfmt+0x263>
	else if (lflag)
  8004e9:	85 c9                	test   %ecx,%ecx
  8004eb:	74 63                	je     800550 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f0:	8b 00                	mov    (%eax),%eax
  8004f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f5:	99                   	cltd   
  8004f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 40 04             	lea    0x4(%eax),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800502:	eb 17                	jmp    80051b <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  800504:	8b 45 14             	mov    0x14(%ebp),%eax
  800507:	8b 50 04             	mov    0x4(%eax),%edx
  80050a:	8b 00                	mov    (%eax),%eax
  80050c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8d 40 08             	lea    0x8(%eax),%eax
  800518:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80051b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80051e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800521:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800526:	85 c9                	test   %ecx,%ecx
  800528:	0f 89 ff 00 00 00    	jns    80062d <vprintfmt+0x38c>
				putch('-', putdat);
  80052e:	83 ec 08             	sub    $0x8,%esp
  800531:	53                   	push   %ebx
  800532:	6a 2d                	push   $0x2d
  800534:	ff d6                	call   *%esi
				num = -(long long) num;
  800536:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800539:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80053c:	f7 da                	neg    %edx
  80053e:	83 d1 00             	adc    $0x0,%ecx
  800541:	f7 d9                	neg    %ecx
  800543:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800546:	b8 0a 00 00 00       	mov    $0xa,%eax
  80054b:	e9 dd 00 00 00       	jmp    80062d <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800550:	8b 45 14             	mov    0x14(%ebp),%eax
  800553:	8b 00                	mov    (%eax),%eax
  800555:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800558:	99                   	cltd   
  800559:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8d 40 04             	lea    0x4(%eax),%eax
  800562:	89 45 14             	mov    %eax,0x14(%ebp)
  800565:	eb b4                	jmp    80051b <vprintfmt+0x27a>
	if (lflag >= 2)
  800567:	83 f9 01             	cmp    $0x1,%ecx
  80056a:	7f 1e                	jg     80058a <vprintfmt+0x2e9>
	else if (lflag)
  80056c:	85 c9                	test   %ecx,%ecx
  80056e:	74 32                	je     8005a2 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	8b 10                	mov    (%eax),%edx
  800575:	b9 00 00 00 00       	mov    $0x0,%ecx
  80057a:	8d 40 04             	lea    0x4(%eax),%eax
  80057d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800580:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  800585:	e9 a3 00 00 00       	jmp    80062d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8b 10                	mov    (%eax),%edx
  80058f:	8b 48 04             	mov    0x4(%eax),%ecx
  800592:	8d 40 08             	lea    0x8(%eax),%eax
  800595:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800598:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  80059d:	e9 8b 00 00 00       	jmp    80062d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8b 10                	mov    (%eax),%edx
  8005a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b2:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005b7:	eb 74                	jmp    80062d <vprintfmt+0x38c>
	if (lflag >= 2)
  8005b9:	83 f9 01             	cmp    $0x1,%ecx
  8005bc:	7f 1b                	jg     8005d9 <vprintfmt+0x338>
	else if (lflag)
  8005be:	85 c9                	test   %ecx,%ecx
  8005c0:	74 2c                	je     8005ee <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c5:	8b 10                	mov    (%eax),%edx
  8005c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005d2:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005d7:	eb 54                	jmp    80062d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e1:	8d 40 08             	lea    0x8(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005e7:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005ec:	eb 3f                	jmp    80062d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f1:	8b 10                	mov    (%eax),%edx
  8005f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f8:	8d 40 04             	lea    0x4(%eax),%eax
  8005fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005fe:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  800603:	eb 28                	jmp    80062d <vprintfmt+0x38c>
			putch('0', putdat);
  800605:	83 ec 08             	sub    $0x8,%esp
  800608:	53                   	push   %ebx
  800609:	6a 30                	push   $0x30
  80060b:	ff d6                	call   *%esi
			putch('x', putdat);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	53                   	push   %ebx
  800611:	6a 78                	push   $0x78
  800613:	ff d6                	call   *%esi
			num = (unsigned long long)
  800615:	8b 45 14             	mov    0x14(%ebp),%eax
  800618:	8b 10                	mov    (%eax),%edx
  80061a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80061f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800622:	8d 40 04             	lea    0x4(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800628:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  80062d:	83 ec 0c             	sub    $0xc,%esp
  800630:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800634:	57                   	push   %edi
  800635:	ff 75 e0             	pushl  -0x20(%ebp)
  800638:	50                   	push   %eax
  800639:	51                   	push   %ecx
  80063a:	52                   	push   %edx
  80063b:	89 da                	mov    %ebx,%edx
  80063d:	89 f0                	mov    %esi,%eax
  80063f:	e8 72 fb ff ff       	call   8001b6 <printnum>
			break;
  800644:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  800647:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  80064a:	83 c7 01             	add    $0x1,%edi
  80064d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800651:	83 f8 25             	cmp    $0x25,%eax
  800654:	0f 84 62 fc ff ff    	je     8002bc <vprintfmt+0x1b>
			if (ch == '\0')										
  80065a:	85 c0                	test   %eax,%eax
  80065c:	0f 84 8b 00 00 00    	je     8006ed <vprintfmt+0x44c>
			putch(ch, putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	53                   	push   %ebx
  800666:	50                   	push   %eax
  800667:	ff d6                	call   *%esi
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	eb dc                	jmp    80064a <vprintfmt+0x3a9>
	if (lflag >= 2)
  80066e:	83 f9 01             	cmp    $0x1,%ecx
  800671:	7f 1b                	jg     80068e <vprintfmt+0x3ed>
	else if (lflag)
  800673:	85 c9                	test   %ecx,%ecx
  800675:	74 2c                	je     8006a3 <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
  80067c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800681:	8d 40 04             	lea    0x4(%eax),%eax
  800684:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800687:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  80068c:	eb 9f                	jmp    80062d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8b 10                	mov    (%eax),%edx
  800693:	8b 48 04             	mov    0x4(%eax),%ecx
  800696:	8d 40 08             	lea    0x8(%eax),%eax
  800699:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80069c:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006a1:	eb 8a                	jmp    80062d <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 10                	mov    (%eax),%edx
  8006a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006b8:	e9 70 ff ff ff       	jmp    80062d <vprintfmt+0x38c>
			putch(ch, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	6a 25                	push   $0x25
  8006c3:	ff d6                	call   *%esi
			break;
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	e9 7a ff ff ff       	jmp    800647 <vprintfmt+0x3a6>
			putch('%', putdat);
  8006cd:	83 ec 08             	sub    $0x8,%esp
  8006d0:	53                   	push   %ebx
  8006d1:	6a 25                	push   $0x25
  8006d3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	89 f8                	mov    %edi,%eax
  8006da:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006de:	74 05                	je     8006e5 <vprintfmt+0x444>
  8006e0:	83 e8 01             	sub    $0x1,%eax
  8006e3:	eb f5                	jmp    8006da <vprintfmt+0x439>
  8006e5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e8:	e9 5a ff ff ff       	jmp    800647 <vprintfmt+0x3a6>
}
  8006ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f0:	5b                   	pop    %ebx
  8006f1:	5e                   	pop    %esi
  8006f2:	5f                   	pop    %edi
  8006f3:	5d                   	pop    %ebp
  8006f4:	c3                   	ret    

008006f5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f5:	f3 0f 1e fb          	endbr32 
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	83 ec 18             	sub    $0x18,%esp
  8006ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800702:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800705:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800708:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80070c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800716:	85 c0                	test   %eax,%eax
  800718:	74 26                	je     800740 <vsnprintf+0x4b>
  80071a:	85 d2                	test   %edx,%edx
  80071c:	7e 22                	jle    800740 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071e:	ff 75 14             	pushl  0x14(%ebp)
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800727:	50                   	push   %eax
  800728:	68 5f 02 80 00       	push   $0x80025f
  80072d:	e8 6f fb ff ff       	call   8002a1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800732:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800735:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800738:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073b:	83 c4 10             	add    $0x10,%esp
}
  80073e:	c9                   	leave  
  80073f:	c3                   	ret    
		return -E_INVAL;
  800740:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800745:	eb f7                	jmp    80073e <vsnprintf+0x49>

00800747 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800747:	f3 0f 1e fb          	endbr32 
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800751:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800754:	50                   	push   %eax
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	ff 75 08             	pushl  0x8(%ebp)
  80075e:	e8 92 ff ff ff       	call   8006f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800765:	f3 0f 1e fb          	endbr32 
  800769:	55                   	push   %ebp
  80076a:	89 e5                	mov    %esp,%ebp
  80076c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076f:	b8 00 00 00 00       	mov    $0x0,%eax
  800774:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800778:	74 05                	je     80077f <strlen+0x1a>
		n++;
  80077a:	83 c0 01             	add    $0x1,%eax
  80077d:	eb f5                	jmp    800774 <strlen+0xf>
	return n;
}
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800781:	f3 0f 1e fb          	endbr32 
  800785:	55                   	push   %ebp
  800786:	89 e5                	mov    %esp,%ebp
  800788:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80078b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078e:	b8 00 00 00 00       	mov    $0x0,%eax
  800793:	39 d0                	cmp    %edx,%eax
  800795:	74 0d                	je     8007a4 <strnlen+0x23>
  800797:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80079b:	74 05                	je     8007a2 <strnlen+0x21>
		n++;
  80079d:	83 c0 01             	add    $0x1,%eax
  8007a0:	eb f1                	jmp    800793 <strnlen+0x12>
  8007a2:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a4:	89 d0                	mov    %edx,%eax
  8007a6:	5d                   	pop    %ebp
  8007a7:	c3                   	ret    

008007a8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a8:	f3 0f 1e fb          	endbr32 
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bb:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007bf:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c2:	83 c0 01             	add    $0x1,%eax
  8007c5:	84 d2                	test   %dl,%dl
  8007c7:	75 f2                	jne    8007bb <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007c9:	89 c8                	mov    %ecx,%eax
  8007cb:	5b                   	pop    %ebx
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ce:	f3 0f 1e fb          	endbr32 
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	83 ec 10             	sub    $0x10,%esp
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 83 ff ff ff       	call   800765 <strlen>
  8007e2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 b8 ff ff ff       	call   8007a8 <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	f3 0f 1e fb          	endbr32 
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	89 f3                	mov    %esi,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	89 f0                	mov    %esi,%eax
  80080d:	39 d8                	cmp    %ebx,%eax
  80080f:	74 11                	je     800822 <strncpy+0x2b>
		*dst++ = *src;
  800811:	83 c0 01             	add    $0x1,%eax
  800814:	0f b6 0a             	movzbl (%edx),%ecx
  800817:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081a:	80 f9 01             	cmp    $0x1,%cl
  80081d:	83 da ff             	sbb    $0xffffffff,%edx
  800820:	eb eb                	jmp    80080d <strncpy+0x16>
	}
	return ret;
}
  800822:	89 f0                	mov    %esi,%eax
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800828:	f3 0f 1e fb          	endbr32 
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800837:	8b 55 10             	mov    0x10(%ebp),%edx
  80083a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083c:	85 d2                	test   %edx,%edx
  80083e:	74 21                	je     800861 <strlcpy+0x39>
  800840:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800844:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800846:	39 c2                	cmp    %eax,%edx
  800848:	74 14                	je     80085e <strlcpy+0x36>
  80084a:	0f b6 19             	movzbl (%ecx),%ebx
  80084d:	84 db                	test   %bl,%bl
  80084f:	74 0b                	je     80085c <strlcpy+0x34>
			*dst++ = *src++;
  800851:	83 c1 01             	add    $0x1,%ecx
  800854:	83 c2 01             	add    $0x1,%edx
  800857:	88 5a ff             	mov    %bl,-0x1(%edx)
  80085a:	eb ea                	jmp    800846 <strlcpy+0x1e>
  80085c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80085e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800861:	29 f0                	sub    %esi,%eax
}
  800863:	5b                   	pop    %ebx
  800864:	5e                   	pop    %esi
  800865:	5d                   	pop    %ebp
  800866:	c3                   	ret    

00800867 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800867:	f3 0f 1e fb          	endbr32 
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800871:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800874:	0f b6 01             	movzbl (%ecx),%eax
  800877:	84 c0                	test   %al,%al
  800879:	74 0c                	je     800887 <strcmp+0x20>
  80087b:	3a 02                	cmp    (%edx),%al
  80087d:	75 08                	jne    800887 <strcmp+0x20>
		p++, q++;
  80087f:	83 c1 01             	add    $0x1,%ecx
  800882:	83 c2 01             	add    $0x1,%edx
  800885:	eb ed                	jmp    800874 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800887:	0f b6 c0             	movzbl %al,%eax
  80088a:	0f b6 12             	movzbl (%edx),%edx
  80088d:	29 d0                	sub    %edx,%eax
}
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800891:	f3 0f 1e fb          	endbr32 
  800895:	55                   	push   %ebp
  800896:	89 e5                	mov    %esp,%ebp
  800898:	53                   	push   %ebx
  800899:	8b 45 08             	mov    0x8(%ebp),%eax
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 c3                	mov    %eax,%ebx
  8008a1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a4:	eb 06                	jmp    8008ac <strncmp+0x1b>
		n--, p++, q++;
  8008a6:	83 c0 01             	add    $0x1,%eax
  8008a9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ac:	39 d8                	cmp    %ebx,%eax
  8008ae:	74 16                	je     8008c6 <strncmp+0x35>
  8008b0:	0f b6 08             	movzbl (%eax),%ecx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	74 04                	je     8008bb <strncmp+0x2a>
  8008b7:	3a 0a                	cmp    (%edx),%cl
  8008b9:	74 eb                	je     8008a6 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008bb:	0f b6 00             	movzbl (%eax),%eax
  8008be:	0f b6 12             	movzbl (%edx),%edx
  8008c1:	29 d0                	sub    %edx,%eax
}
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    
		return 0;
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb f6                	jmp    8008c3 <strncmp+0x32>

008008cd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008cd:	f3 0f 1e fb          	endbr32 
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008db:	0f b6 10             	movzbl (%eax),%edx
  8008de:	84 d2                	test   %dl,%dl
  8008e0:	74 09                	je     8008eb <strchr+0x1e>
		if (*s == c)
  8008e2:	38 ca                	cmp    %cl,%dl
  8008e4:	74 0a                	je     8008f0 <strchr+0x23>
	for (; *s; s++)
  8008e6:	83 c0 01             	add    $0x1,%eax
  8008e9:	eb f0                	jmp    8008db <strchr+0xe>
			return (char *) s;
	return 0;
  8008eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f0:	5d                   	pop    %ebp
  8008f1:	c3                   	ret    

008008f2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f2:	f3 0f 1e fb          	endbr32 
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800900:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800903:	38 ca                	cmp    %cl,%dl
  800905:	74 09                	je     800910 <strfind+0x1e>
  800907:	84 d2                	test   %dl,%dl
  800909:	74 05                	je     800910 <strfind+0x1e>
	for (; *s; s++)
  80090b:	83 c0 01             	add    $0x1,%eax
  80090e:	eb f0                	jmp    800900 <strfind+0xe>
			break;
	return (char *) s;
}
  800910:	5d                   	pop    %ebp
  800911:	c3                   	ret    

00800912 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800912:	f3 0f 1e fb          	endbr32 
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	57                   	push   %edi
  80091a:	56                   	push   %esi
  80091b:	53                   	push   %ebx
  80091c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800922:	85 c9                	test   %ecx,%ecx
  800924:	74 31                	je     800957 <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800926:	89 f8                	mov    %edi,%eax
  800928:	09 c8                	or     %ecx,%eax
  80092a:	a8 03                	test   $0x3,%al
  80092c:	75 23                	jne    800951 <memset+0x3f>
		c &= 0xFF;
  80092e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800932:	89 d3                	mov    %edx,%ebx
  800934:	c1 e3 08             	shl    $0x8,%ebx
  800937:	89 d0                	mov    %edx,%eax
  800939:	c1 e0 18             	shl    $0x18,%eax
  80093c:	89 d6                	mov    %edx,%esi
  80093e:	c1 e6 10             	shl    $0x10,%esi
  800941:	09 f0                	or     %esi,%eax
  800943:	09 c2                	or     %eax,%edx
  800945:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800947:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80094a:	89 d0                	mov    %edx,%eax
  80094c:	fc                   	cld    
  80094d:	f3 ab                	rep stos %eax,%es:(%edi)
  80094f:	eb 06                	jmp    800957 <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800951:	8b 45 0c             	mov    0xc(%ebp),%eax
  800954:	fc                   	cld    
  800955:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800957:	89 f8                	mov    %edi,%eax
  800959:	5b                   	pop    %ebx
  80095a:	5e                   	pop    %esi
  80095b:	5f                   	pop    %edi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095e:	f3 0f 1e fb          	endbr32 
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	57                   	push   %edi
  800966:	56                   	push   %esi
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800970:	39 c6                	cmp    %eax,%esi
  800972:	73 32                	jae    8009a6 <memmove+0x48>
  800974:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800977:	39 c2                	cmp    %eax,%edx
  800979:	76 2b                	jbe    8009a6 <memmove+0x48>
		s += n;
		d += n;
  80097b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097e:	89 fe                	mov    %edi,%esi
  800980:	09 ce                	or     %ecx,%esi
  800982:	09 d6                	or     %edx,%esi
  800984:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80098a:	75 0e                	jne    80099a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098c:	83 ef 04             	sub    $0x4,%edi
  80098f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800992:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800995:	fd                   	std    
  800996:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800998:	eb 09                	jmp    8009a3 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80099a:	83 ef 01             	sub    $0x1,%edi
  80099d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a0:	fd                   	std    
  8009a1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a3:	fc                   	cld    
  8009a4:	eb 1a                	jmp    8009c0 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a6:	89 c2                	mov    %eax,%edx
  8009a8:	09 ca                	or     %ecx,%edx
  8009aa:	09 f2                	or     %esi,%edx
  8009ac:	f6 c2 03             	test   $0x3,%dl
  8009af:	75 0a                	jne    8009bb <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b4:	89 c7                	mov    %eax,%edi
  8009b6:	fc                   	cld    
  8009b7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b9:	eb 05                	jmp    8009c0 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009bb:	89 c7                	mov    %eax,%edi
  8009bd:	fc                   	cld    
  8009be:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c0:	5e                   	pop    %esi
  8009c1:	5f                   	pop    %edi
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c4:	f3 0f 1e fb          	endbr32 
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009ce:	ff 75 10             	pushl  0x10(%ebp)
  8009d1:	ff 75 0c             	pushl  0xc(%ebp)
  8009d4:	ff 75 08             	pushl  0x8(%ebp)
  8009d7:	e8 82 ff ff ff       	call   80095e <memmove>
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009de:	f3 0f 1e fb          	endbr32 
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	56                   	push   %esi
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ed:	89 c6                	mov    %eax,%esi
  8009ef:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f2:	39 f0                	cmp    %esi,%eax
  8009f4:	74 1c                	je     800a12 <memcmp+0x34>
		if (*s1 != *s2)
  8009f6:	0f b6 08             	movzbl (%eax),%ecx
  8009f9:	0f b6 1a             	movzbl (%edx),%ebx
  8009fc:	38 d9                	cmp    %bl,%cl
  8009fe:	75 08                	jne    800a08 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a00:	83 c0 01             	add    $0x1,%eax
  800a03:	83 c2 01             	add    $0x1,%edx
  800a06:	eb ea                	jmp    8009f2 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a08:	0f b6 c1             	movzbl %cl,%eax
  800a0b:	0f b6 db             	movzbl %bl,%ebx
  800a0e:	29 d8                	sub    %ebx,%eax
  800a10:	eb 05                	jmp    800a17 <memcmp+0x39>
	}

	return 0;
  800a12:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a17:	5b                   	pop    %ebx
  800a18:	5e                   	pop    %esi
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1b:	f3 0f 1e fb          	endbr32 
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a28:	89 c2                	mov    %eax,%edx
  800a2a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2d:	39 d0                	cmp    %edx,%eax
  800a2f:	73 09                	jae    800a3a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a31:	38 08                	cmp    %cl,(%eax)
  800a33:	74 05                	je     800a3a <memfind+0x1f>
	for (; s < ends; s++)
  800a35:	83 c0 01             	add    $0x1,%eax
  800a38:	eb f3                	jmp    800a2d <memfind+0x12>
			break;
	return (void *) s;
}
  800a3a:	5d                   	pop    %ebp
  800a3b:	c3                   	ret    

00800a3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3c:	f3 0f 1e fb          	endbr32 
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	57                   	push   %edi
  800a44:	56                   	push   %esi
  800a45:	53                   	push   %ebx
  800a46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a49:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4c:	eb 03                	jmp    800a51 <strtol+0x15>
		s++;
  800a4e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a51:	0f b6 01             	movzbl (%ecx),%eax
  800a54:	3c 20                	cmp    $0x20,%al
  800a56:	74 f6                	je     800a4e <strtol+0x12>
  800a58:	3c 09                	cmp    $0x9,%al
  800a5a:	74 f2                	je     800a4e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a5c:	3c 2b                	cmp    $0x2b,%al
  800a5e:	74 2a                	je     800a8a <strtol+0x4e>
	int neg = 0;
  800a60:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a65:	3c 2d                	cmp    $0x2d,%al
  800a67:	74 2b                	je     800a94 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a69:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6f:	75 0f                	jne    800a80 <strtol+0x44>
  800a71:	80 39 30             	cmpb   $0x30,(%ecx)
  800a74:	74 28                	je     800a9e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a7d:	0f 44 d8             	cmove  %eax,%ebx
  800a80:	b8 00 00 00 00       	mov    $0x0,%eax
  800a85:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a88:	eb 46                	jmp    800ad0 <strtol+0x94>
		s++;
  800a8a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a8d:	bf 00 00 00 00       	mov    $0x0,%edi
  800a92:	eb d5                	jmp    800a69 <strtol+0x2d>
		s++, neg = 1;
  800a94:	83 c1 01             	add    $0x1,%ecx
  800a97:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9c:	eb cb                	jmp    800a69 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa2:	74 0e                	je     800ab2 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aa4:	85 db                	test   %ebx,%ebx
  800aa6:	75 d8                	jne    800a80 <strtol+0x44>
		s++, base = 8;
  800aa8:	83 c1 01             	add    $0x1,%ecx
  800aab:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab0:	eb ce                	jmp    800a80 <strtol+0x44>
		s += 2, base = 16;
  800ab2:	83 c1 02             	add    $0x2,%ecx
  800ab5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aba:	eb c4                	jmp    800a80 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac5:	7d 3a                	jge    800b01 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ace:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad0:	0f b6 11             	movzbl (%ecx),%edx
  800ad3:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad6:	89 f3                	mov    %esi,%ebx
  800ad8:	80 fb 09             	cmp    $0x9,%bl
  800adb:	76 df                	jbe    800abc <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800add:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae0:	89 f3                	mov    %esi,%ebx
  800ae2:	80 fb 19             	cmp    $0x19,%bl
  800ae5:	77 08                	ja     800aef <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae7:	0f be d2             	movsbl %dl,%edx
  800aea:	83 ea 57             	sub    $0x57,%edx
  800aed:	eb d3                	jmp    800ac2 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aef:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af2:	89 f3                	mov    %esi,%ebx
  800af4:	80 fb 19             	cmp    $0x19,%bl
  800af7:	77 08                	ja     800b01 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af9:	0f be d2             	movsbl %dl,%edx
  800afc:	83 ea 37             	sub    $0x37,%edx
  800aff:	eb c1                	jmp    800ac2 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b01:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b05:	74 05                	je     800b0c <strtol+0xd0>
		*endptr = (char *) s;
  800b07:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b0a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0c:	89 c2                	mov    %eax,%edx
  800b0e:	f7 da                	neg    %edx
  800b10:	85 ff                	test   %edi,%edi
  800b12:	0f 45 c2             	cmovne %edx,%eax
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b1a:	f3 0f 1e fb          	endbr32 
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	57                   	push   %edi
  800b22:	56                   	push   %esi
  800b23:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b24:	b8 00 00 00 00       	mov    $0x0,%eax
  800b29:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b2f:	89 c3                	mov    %eax,%ebx
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	89 c6                	mov    %eax,%esi
  800b35:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3c:	f3 0f 1e fb          	endbr32 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	57                   	push   %edi
  800b44:	56                   	push   %esi
  800b45:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b46:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b50:	89 d1                	mov    %edx,%ecx
  800b52:	89 d3                	mov    %edx,%ebx
  800b54:	89 d7                	mov    %edx,%edi
  800b56:	89 d6                	mov    %edx,%esi
  800b58:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5f                   	pop    %edi
  800b5d:	5d                   	pop    %ebp
  800b5e:	c3                   	ret    

00800b5f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5f:	f3 0f 1e fb          	endbr32 
  800b63:	55                   	push   %ebp
  800b64:	89 e5                	mov    %esp,%ebp
  800b66:	57                   	push   %edi
  800b67:	56                   	push   %esi
  800b68:	53                   	push   %ebx
  800b69:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b71:	8b 55 08             	mov    0x8(%ebp),%edx
  800b74:	b8 03 00 00 00       	mov    $0x3,%eax
  800b79:	89 cb                	mov    %ecx,%ebx
  800b7b:	89 cf                	mov    %ecx,%edi
  800b7d:	89 ce                	mov    %ecx,%esi
  800b7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b81:	85 c0                	test   %eax,%eax
  800b83:	7f 08                	jg     800b8d <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5f                   	pop    %edi
  800b8b:	5d                   	pop    %ebp
  800b8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8d:	83 ec 0c             	sub    $0xc,%esp
  800b90:	50                   	push   %eax
  800b91:	6a 03                	push   $0x3
  800b93:	68 24 13 80 00       	push   $0x801324
  800b98:	6a 23                	push   $0x23
  800b9a:	68 41 13 80 00       	push   $0x801341
  800b9f:	e8 11 02 00 00       	call   800db5 <_panic>

00800ba4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba4:	f3 0f 1e fb          	endbr32 
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	57                   	push   %edi
  800bac:	56                   	push   %esi
  800bad:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bae:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb3:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb8:	89 d1                	mov    %edx,%ecx
  800bba:	89 d3                	mov    %edx,%ebx
  800bbc:	89 d7                	mov    %edx,%edi
  800bbe:	89 d6                	mov    %edx,%esi
  800bc0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5f                   	pop    %edi
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <sys_yield>:

void
sys_yield(void)
{
  800bc7:	f3 0f 1e fb          	endbr32 
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bdb:	89 d1                	mov    %edx,%ecx
  800bdd:	89 d3                	mov    %edx,%ebx
  800bdf:	89 d7                	mov    %edx,%edi
  800be1:	89 d6                	mov    %edx,%esi
  800be3:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800be5:	5b                   	pop    %ebx
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bea:	f3 0f 1e fb          	endbr32 
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bf7:	be 00 00 00 00       	mov    $0x0,%esi
  800bfc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	b8 04 00 00 00       	mov    $0x4,%eax
  800c07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0a:	89 f7                	mov    %esi,%edi
  800c0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c0e:	85 c0                	test   %eax,%eax
  800c10:	7f 08                	jg     800c1a <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c15:	5b                   	pop    %ebx
  800c16:	5e                   	pop    %esi
  800c17:	5f                   	pop    %edi
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1a:	83 ec 0c             	sub    $0xc,%esp
  800c1d:	50                   	push   %eax
  800c1e:	6a 04                	push   $0x4
  800c20:	68 24 13 80 00       	push   $0x801324
  800c25:	6a 23                	push   $0x23
  800c27:	68 41 13 80 00       	push   $0x801341
  800c2c:	e8 84 01 00 00       	call   800db5 <_panic>

00800c31 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c31:	f3 0f 1e fb          	endbr32 
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	57                   	push   %edi
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	b8 05 00 00 00       	mov    $0x5,%eax
  800c49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800c52:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c54:	85 c0                	test   %eax,%eax
  800c56:	7f 08                	jg     800c60 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5b:	5b                   	pop    %ebx
  800c5c:	5e                   	pop    %esi
  800c5d:	5f                   	pop    %edi
  800c5e:	5d                   	pop    %ebp
  800c5f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 05                	push   $0x5
  800c66:	68 24 13 80 00       	push   $0x801324
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 41 13 80 00       	push   $0x801341
  800c72:	e8 3e 01 00 00       	call   800db5 <_panic>

00800c77 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c77:	f3 0f 1e fb          	endbr32 
  800c7b:	55                   	push   %ebp
  800c7c:	89 e5                	mov    %esp,%ebp
  800c7e:	57                   	push   %edi
  800c7f:	56                   	push   %esi
  800c80:	53                   	push   %ebx
  800c81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c84:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c89:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c94:	89 df                	mov    %ebx,%edi
  800c96:	89 de                	mov    %ebx,%esi
  800c98:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c9a:	85 c0                	test   %eax,%eax
  800c9c:	7f 08                	jg     800ca6 <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c9e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5f                   	pop    %edi
  800ca4:	5d                   	pop    %ebp
  800ca5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 06                	push   $0x6
  800cac:	68 24 13 80 00       	push   $0x801324
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 41 13 80 00       	push   $0x801341
  800cb8:	e8 f8 00 00 00       	call   800db5 <_panic>

00800cbd <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cbd:	f3 0f 1e fb          	endbr32 
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd5:	b8 08 00 00 00       	mov    $0x8,%eax
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7f 08                	jg     800cec <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cec:	83 ec 0c             	sub    $0xc,%esp
  800cef:	50                   	push   %eax
  800cf0:	6a 08                	push   $0x8
  800cf2:	68 24 13 80 00       	push   $0x801324
  800cf7:	6a 23                	push   $0x23
  800cf9:	68 41 13 80 00       	push   $0x801341
  800cfe:	e8 b2 00 00 00       	call   800db5 <_panic>

00800d03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d03:	f3 0f 1e fb          	endbr32 
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d10:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d15:	8b 55 08             	mov    0x8(%ebp),%edx
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	b8 09 00 00 00       	mov    $0x9,%eax
  800d20:	89 df                	mov    %ebx,%edi
  800d22:	89 de                	mov    %ebx,%esi
  800d24:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7f 08                	jg     800d32 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d32:	83 ec 0c             	sub    $0xc,%esp
  800d35:	50                   	push   %eax
  800d36:	6a 09                	push   $0x9
  800d38:	68 24 13 80 00       	push   $0x801324
  800d3d:	6a 23                	push   $0x23
  800d3f:	68 41 13 80 00       	push   $0x801341
  800d44:	e8 6c 00 00 00       	call   800db5 <_panic>

00800d49 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d49:	f3 0f 1e fb          	endbr32 
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	57                   	push   %edi
  800d51:	56                   	push   %esi
  800d52:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d5e:	be 00 00 00 00       	mov    $0x0,%esi
  800d63:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d66:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d69:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d6b:	5b                   	pop    %ebx
  800d6c:	5e                   	pop    %esi
  800d6d:	5f                   	pop    %edi
  800d6e:	5d                   	pop    %ebp
  800d6f:	c3                   	ret    

00800d70 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d70:	f3 0f 1e fb          	endbr32 
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	57                   	push   %edi
  800d78:	56                   	push   %esi
  800d79:	53                   	push   %ebx
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8a:	89 cb                	mov    %ecx,%ebx
  800d8c:	89 cf                	mov    %ecx,%edi
  800d8e:	89 ce                	mov    %ecx,%esi
  800d90:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d92:	85 c0                	test   %eax,%eax
  800d94:	7f 08                	jg     800d9e <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d96:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d99:	5b                   	pop    %ebx
  800d9a:	5e                   	pop    %esi
  800d9b:	5f                   	pop    %edi
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	50                   	push   %eax
  800da2:	6a 0c                	push   $0xc
  800da4:	68 24 13 80 00       	push   $0x801324
  800da9:	6a 23                	push   $0x23
  800dab:	68 41 13 80 00       	push   $0x801341
  800db0:	e8 00 00 00 00       	call   800db5 <_panic>

00800db5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800db5:	f3 0f 1e fb          	endbr32 
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	56                   	push   %esi
  800dbd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800dbe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800dc1:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800dc7:	e8 d8 fd ff ff       	call   800ba4 <sys_getenvid>
  800dcc:	83 ec 0c             	sub    $0xc,%esp
  800dcf:	ff 75 0c             	pushl  0xc(%ebp)
  800dd2:	ff 75 08             	pushl  0x8(%ebp)
  800dd5:	56                   	push   %esi
  800dd6:	50                   	push   %eax
  800dd7:	68 50 13 80 00       	push   $0x801350
  800ddc:	e8 bd f3 ff ff       	call   80019e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800de1:	83 c4 18             	add    $0x18,%esp
  800de4:	53                   	push   %ebx
  800de5:	ff 75 10             	pushl  0x10(%ebp)
  800de8:	e8 5c f3 ff ff       	call   800149 <vcprintf>
	cprintf("\n");
  800ded:	c7 04 24 73 13 80 00 	movl   $0x801373,(%esp)
  800df4:	e8 a5 f3 ff ff       	call   80019e <cprintf>
  800df9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800dfc:	cc                   	int3   
  800dfd:	eb fd                	jmp    800dfc <_panic+0x47>
  800dff:	90                   	nop

00800e00 <__udivdi3>:
  800e00:	f3 0f 1e fb          	endbr32 
  800e04:	55                   	push   %ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	83 ec 1c             	sub    $0x1c,%esp
  800e0b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800e13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800e1b:	85 d2                	test   %edx,%edx
  800e1d:	75 19                	jne    800e38 <__udivdi3+0x38>
  800e1f:	39 f3                	cmp    %esi,%ebx
  800e21:	76 4d                	jbe    800e70 <__udivdi3+0x70>
  800e23:	31 ff                	xor    %edi,%edi
  800e25:	89 e8                	mov    %ebp,%eax
  800e27:	89 f2                	mov    %esi,%edx
  800e29:	f7 f3                	div    %ebx
  800e2b:	89 fa                	mov    %edi,%edx
  800e2d:	83 c4 1c             	add    $0x1c,%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    
  800e35:	8d 76 00             	lea    0x0(%esi),%esi
  800e38:	39 f2                	cmp    %esi,%edx
  800e3a:	76 14                	jbe    800e50 <__udivdi3+0x50>
  800e3c:	31 ff                	xor    %edi,%edi
  800e3e:	31 c0                	xor    %eax,%eax
  800e40:	89 fa                	mov    %edi,%edx
  800e42:	83 c4 1c             	add    $0x1c,%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    
  800e4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e50:	0f bd fa             	bsr    %edx,%edi
  800e53:	83 f7 1f             	xor    $0x1f,%edi
  800e56:	75 48                	jne    800ea0 <__udivdi3+0xa0>
  800e58:	39 f2                	cmp    %esi,%edx
  800e5a:	72 06                	jb     800e62 <__udivdi3+0x62>
  800e5c:	31 c0                	xor    %eax,%eax
  800e5e:	39 eb                	cmp    %ebp,%ebx
  800e60:	77 de                	ja     800e40 <__udivdi3+0x40>
  800e62:	b8 01 00 00 00       	mov    $0x1,%eax
  800e67:	eb d7                	jmp    800e40 <__udivdi3+0x40>
  800e69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e70:	89 d9                	mov    %ebx,%ecx
  800e72:	85 db                	test   %ebx,%ebx
  800e74:	75 0b                	jne    800e81 <__udivdi3+0x81>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f3                	div    %ebx
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	31 d2                	xor    %edx,%edx
  800e83:	89 f0                	mov    %esi,%eax
  800e85:	f7 f1                	div    %ecx
  800e87:	89 c6                	mov    %eax,%esi
  800e89:	89 e8                	mov    %ebp,%eax
  800e8b:	89 f7                	mov    %esi,%edi
  800e8d:	f7 f1                	div    %ecx
  800e8f:	89 fa                	mov    %edi,%edx
  800e91:	83 c4 1c             	add    $0x1c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	89 f9                	mov    %edi,%ecx
  800ea2:	b8 20 00 00 00       	mov    $0x20,%eax
  800ea7:	29 f8                	sub    %edi,%eax
  800ea9:	d3 e2                	shl    %cl,%edx
  800eab:	89 54 24 08          	mov    %edx,0x8(%esp)
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	89 da                	mov    %ebx,%edx
  800eb3:	d3 ea                	shr    %cl,%edx
  800eb5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800eb9:	09 d1                	or     %edx,%ecx
  800ebb:	89 f2                	mov    %esi,%edx
  800ebd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ec1:	89 f9                	mov    %edi,%ecx
  800ec3:	d3 e3                	shl    %cl,%ebx
  800ec5:	89 c1                	mov    %eax,%ecx
  800ec7:	d3 ea                	shr    %cl,%edx
  800ec9:	89 f9                	mov    %edi,%ecx
  800ecb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ecf:	89 eb                	mov    %ebp,%ebx
  800ed1:	d3 e6                	shl    %cl,%esi
  800ed3:	89 c1                	mov    %eax,%ecx
  800ed5:	d3 eb                	shr    %cl,%ebx
  800ed7:	09 de                	or     %ebx,%esi
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	f7 74 24 08          	divl   0x8(%esp)
  800edf:	89 d6                	mov    %edx,%esi
  800ee1:	89 c3                	mov    %eax,%ebx
  800ee3:	f7 64 24 0c          	mull   0xc(%esp)
  800ee7:	39 d6                	cmp    %edx,%esi
  800ee9:	72 15                	jb     800f00 <__udivdi3+0x100>
  800eeb:	89 f9                	mov    %edi,%ecx
  800eed:	d3 e5                	shl    %cl,%ebp
  800eef:	39 c5                	cmp    %eax,%ebp
  800ef1:	73 04                	jae    800ef7 <__udivdi3+0xf7>
  800ef3:	39 d6                	cmp    %edx,%esi
  800ef5:	74 09                	je     800f00 <__udivdi3+0x100>
  800ef7:	89 d8                	mov    %ebx,%eax
  800ef9:	31 ff                	xor    %edi,%edi
  800efb:	e9 40 ff ff ff       	jmp    800e40 <__udivdi3+0x40>
  800f00:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f03:	31 ff                	xor    %edi,%edi
  800f05:	e9 36 ff ff ff       	jmp    800e40 <__udivdi3+0x40>
  800f0a:	66 90                	xchg   %ax,%ax
  800f0c:	66 90                	xchg   %ax,%ax
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__umoddi3>:
  800f10:	f3 0f 1e fb          	endbr32 
  800f14:	55                   	push   %ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 1c             	sub    $0x1c,%esp
  800f1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800f1f:	8b 74 24 30          	mov    0x30(%esp),%esi
  800f23:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800f27:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800f2b:	85 c0                	test   %eax,%eax
  800f2d:	75 19                	jne    800f48 <__umoddi3+0x38>
  800f2f:	39 df                	cmp    %ebx,%edi
  800f31:	76 5d                	jbe    800f90 <__umoddi3+0x80>
  800f33:	89 f0                	mov    %esi,%eax
  800f35:	89 da                	mov    %ebx,%edx
  800f37:	f7 f7                	div    %edi
  800f39:	89 d0                	mov    %edx,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	89 f2                	mov    %esi,%edx
  800f4a:	39 d8                	cmp    %ebx,%eax
  800f4c:	76 12                	jbe    800f60 <__umoddi3+0x50>
  800f4e:	89 f0                	mov    %esi,%eax
  800f50:	89 da                	mov    %ebx,%edx
  800f52:	83 c4 1c             	add    $0x1c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	0f bd e8             	bsr    %eax,%ebp
  800f63:	83 f5 1f             	xor    $0x1f,%ebp
  800f66:	75 50                	jne    800fb8 <__umoddi3+0xa8>
  800f68:	39 d8                	cmp    %ebx,%eax
  800f6a:	0f 82 e0 00 00 00    	jb     801050 <__umoddi3+0x140>
  800f70:	89 d9                	mov    %ebx,%ecx
  800f72:	39 f7                	cmp    %esi,%edi
  800f74:	0f 86 d6 00 00 00    	jbe    801050 <__umoddi3+0x140>
  800f7a:	89 d0                	mov    %edx,%eax
  800f7c:	89 ca                	mov    %ecx,%edx
  800f7e:	83 c4 1c             	add    $0x1c,%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5f                   	pop    %edi
  800f84:	5d                   	pop    %ebp
  800f85:	c3                   	ret    
  800f86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f8d:	8d 76 00             	lea    0x0(%esi),%esi
  800f90:	89 fd                	mov    %edi,%ebp
  800f92:	85 ff                	test   %edi,%edi
  800f94:	75 0b                	jne    800fa1 <__umoddi3+0x91>
  800f96:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9b:	31 d2                	xor    %edx,%edx
  800f9d:	f7 f7                	div    %edi
  800f9f:	89 c5                	mov    %eax,%ebp
  800fa1:	89 d8                	mov    %ebx,%eax
  800fa3:	31 d2                	xor    %edx,%edx
  800fa5:	f7 f5                	div    %ebp
  800fa7:	89 f0                	mov    %esi,%eax
  800fa9:	f7 f5                	div    %ebp
  800fab:	89 d0                	mov    %edx,%eax
  800fad:	31 d2                	xor    %edx,%edx
  800faf:	eb 8c                	jmp    800f3d <__umoddi3+0x2d>
  800fb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb8:	89 e9                	mov    %ebp,%ecx
  800fba:	ba 20 00 00 00       	mov    $0x20,%edx
  800fbf:	29 ea                	sub    %ebp,%edx
  800fc1:	d3 e0                	shl    %cl,%eax
  800fc3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc7:	89 d1                	mov    %edx,%ecx
  800fc9:	89 f8                	mov    %edi,%eax
  800fcb:	d3 e8                	shr    %cl,%eax
  800fcd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  800fd5:	8b 54 24 04          	mov    0x4(%esp),%edx
  800fd9:	09 c1                	or     %eax,%ecx
  800fdb:	89 d8                	mov    %ebx,%eax
  800fdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fe1:	89 e9                	mov    %ebp,%ecx
  800fe3:	d3 e7                	shl    %cl,%edi
  800fe5:	89 d1                	mov    %edx,%ecx
  800fe7:	d3 e8                	shr    %cl,%eax
  800fe9:	89 e9                	mov    %ebp,%ecx
  800feb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  800fef:	d3 e3                	shl    %cl,%ebx
  800ff1:	89 c7                	mov    %eax,%edi
  800ff3:	89 d1                	mov    %edx,%ecx
  800ff5:	89 f0                	mov    %esi,%eax
  800ff7:	d3 e8                	shr    %cl,%eax
  800ff9:	89 e9                	mov    %ebp,%ecx
  800ffb:	89 fa                	mov    %edi,%edx
  800ffd:	d3 e6                	shl    %cl,%esi
  800fff:	09 d8                	or     %ebx,%eax
  801001:	f7 74 24 08          	divl   0x8(%esp)
  801005:	89 d1                	mov    %edx,%ecx
  801007:	89 f3                	mov    %esi,%ebx
  801009:	f7 64 24 0c          	mull   0xc(%esp)
  80100d:	89 c6                	mov    %eax,%esi
  80100f:	89 d7                	mov    %edx,%edi
  801011:	39 d1                	cmp    %edx,%ecx
  801013:	72 06                	jb     80101b <__umoddi3+0x10b>
  801015:	75 10                	jne    801027 <__umoddi3+0x117>
  801017:	39 c3                	cmp    %eax,%ebx
  801019:	73 0c                	jae    801027 <__umoddi3+0x117>
  80101b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80101f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801023:	89 d7                	mov    %edx,%edi
  801025:	89 c6                	mov    %eax,%esi
  801027:	89 ca                	mov    %ecx,%edx
  801029:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80102e:	29 f3                	sub    %esi,%ebx
  801030:	19 fa                	sbb    %edi,%edx
  801032:	89 d0                	mov    %edx,%eax
  801034:	d3 e0                	shl    %cl,%eax
  801036:	89 e9                	mov    %ebp,%ecx
  801038:	d3 eb                	shr    %cl,%ebx
  80103a:	d3 ea                	shr    %cl,%edx
  80103c:	09 d8                	or     %ebx,%eax
  80103e:	83 c4 1c             	add    $0x1c,%esp
  801041:	5b                   	pop    %ebx
  801042:	5e                   	pop    %esi
  801043:	5f                   	pop    %edi
  801044:	5d                   	pop    %ebp
  801045:	c3                   	ret    
  801046:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80104d:	8d 76 00             	lea    0x0(%esi),%esi
  801050:	29 fe                	sub    %edi,%esi
  801052:	19 c3                	sbb    %eax,%ebx
  801054:	89 f2                	mov    %esi,%edx
  801056:	89 d9                	mov    %ebx,%ecx
  801058:	e9 1d ff ff ff       	jmp    800f7a <__umoddi3+0x6a>
