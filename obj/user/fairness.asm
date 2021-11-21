
obj/user/fairness:     file format elf32-i386


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
  80002c:	e8 74 00 00 00       	call   8000a5 <libmain>
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
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 10             	sub    $0x10,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003f:	e8 67 0b 00 00       	call   800bab <sys_getenvid>
  800044:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800046:	81 3d 60 40 80 00 84 	cmpl   $0xeec00084,0x804060
  80004d:	00 c0 ee 
  800050:	74 2d                	je     80007f <umain+0x4c>
		while (1) {
			ipc_recv(&who, 0, 0);
			cprintf("%x recv from %x\n", id, who);
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800052:	a1 cc 00 c0 ee       	mov    0xeec000cc,%eax
  800057:	83 ec 04             	sub    $0x4,%esp
  80005a:	50                   	push   %eax
  80005b:	53                   	push   %ebx
  80005c:	68 91 11 80 00       	push   $0x801191
  800061:	e8 3f 01 00 00       	call   8001a5 <cprintf>
  800066:	83 c4 10             	add    $0x10,%esp
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  800069:	a1 cc 00 c0 ee       	mov    0xeec000cc,%eax
  80006e:	6a 00                	push   $0x0
  800070:	6a 00                	push   $0x0
  800072:	6a 00                	push   $0x0
  800074:	50                   	push   %eax
  800075:	e8 af 0d 00 00       	call   800e29 <ipc_send>
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	eb ea                	jmp    800069 <umain+0x36>
			ipc_recv(&who, 0, 0);
  80007f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800082:	83 ec 04             	sub    $0x4,%esp
  800085:	6a 00                	push   $0x0
  800087:	6a 00                	push   $0x0
  800089:	56                   	push   %esi
  80008a:	e8 2d 0d 00 00       	call   800dbc <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80008f:	83 c4 0c             	add    $0xc,%esp
  800092:	ff 75 f4             	pushl  -0xc(%ebp)
  800095:	53                   	push   %ebx
  800096:	68 80 11 80 00       	push   $0x801180
  80009b:	e8 05 01 00 00       	call   8001a5 <cprintf>
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	eb dd                	jmp    800082 <umain+0x4f>

008000a5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a5:	f3 0f 1e fb          	endbr32 
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
  8000ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000b1:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t envid = sys_getenvid();
  8000b4:	e8 f2 0a 00 00       	call   800bab <sys_getenvid>
	thisenv = envs + ENVX(envid);
  8000b9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000be:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  8000c4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c9:	a3 60 40 80 00       	mov    %eax,0x804060

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ce:	85 db                	test   %ebx,%ebx
  8000d0:	7e 07                	jle    8000d9 <libmain+0x34>
		binaryname = argv[0];
  8000d2:	8b 06                	mov    (%esi),%eax
  8000d4:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d9:	83 ec 08             	sub    $0x8,%esp
  8000dc:	56                   	push   %esi
  8000dd:	53                   	push   %ebx
  8000de:	e8 50 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e3:	e8 0a 00 00 00       	call   8000f2 <exit>
}
  8000e8:	83 c4 10             	add    $0x10,%esp
  8000eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000ee:	5b                   	pop    %ebx
  8000ef:	5e                   	pop    %esi
  8000f0:	5d                   	pop    %ebp
  8000f1:	c3                   	ret    

008000f2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f2:	f3 0f 1e fb          	endbr32 
  8000f6:	55                   	push   %ebp
  8000f7:	89 e5                	mov    %esp,%ebp
  8000f9:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000fc:	6a 00                	push   $0x0
  8000fe:	e8 63 0a 00 00       	call   800b66 <sys_env_destroy>
}
  800103:	83 c4 10             	add    $0x10,%esp
  800106:	c9                   	leave  
  800107:	c3                   	ret    

00800108 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800108:	f3 0f 1e fb          	endbr32 
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	53                   	push   %ebx
  800110:	83 ec 04             	sub    $0x4,%esp
  800113:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800116:	8b 13                	mov    (%ebx),%edx
  800118:	8d 42 01             	lea    0x1(%edx),%eax
  80011b:	89 03                	mov    %eax,(%ebx)
  80011d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800120:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800124:	3d ff 00 00 00       	cmp    $0xff,%eax
  800129:	74 09                	je     800134 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80012b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80012f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800132:	c9                   	leave  
  800133:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 dc 09 00 00       	call   800b21 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	eb db                	jmp    80012b <putch+0x23>

00800150 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800150:	f3 0f 1e fb          	endbr32 
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80015d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800164:	00 00 00 
	b.cnt = 0;
  800167:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80016e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800171:	ff 75 0c             	pushl  0xc(%ebp)
  800174:	ff 75 08             	pushl  0x8(%ebp)
  800177:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80017d:	50                   	push   %eax
  80017e:	68 08 01 80 00       	push   $0x800108
  800183:	e8 20 01 00 00       	call   8002a8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800188:	83 c4 08             	add    $0x8,%esp
  80018b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800191:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800197:	50                   	push   %eax
  800198:	e8 84 09 00 00       	call   800b21 <sys_cputs>

	return b.cnt;
}
  80019d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a3:	c9                   	leave  
  8001a4:	c3                   	ret    

008001a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a5:	f3 0f 1e fb          	endbr32 
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001af:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b2:	50                   	push   %eax
  8001b3:	ff 75 08             	pushl  0x8(%ebp)
  8001b6:	e8 95 ff ff ff       	call   800150 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001bb:	c9                   	leave  
  8001bc:	c3                   	ret    

008001bd <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bd:	55                   	push   %ebp
  8001be:	89 e5                	mov    %esp,%ebp
  8001c0:	57                   	push   %edi
  8001c1:	56                   	push   %esi
  8001c2:	53                   	push   %ebx
  8001c3:	83 ec 1c             	sub    $0x1c,%esp
  8001c6:	89 c7                	mov    %eax,%edi
  8001c8:	89 d6                	mov    %edx,%esi
  8001ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d0:	89 d1                	mov    %edx,%ecx
  8001d2:	89 c2                	mov    %eax,%edx
  8001d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d7:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e3:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001ea:	39 c2                	cmp    %eax,%edx
  8001ec:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001ef:	72 3e                	jb     80022f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f1:	83 ec 0c             	sub    $0xc,%esp
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	83 eb 01             	sub    $0x1,%ebx
  8001fa:	53                   	push   %ebx
  8001fb:	50                   	push   %eax
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 00 0d 00 00       	call   800f10 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9f ff ff ff       	call   8001bd <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 13                	jmp    800236 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80022f:	83 eb 01             	sub    $0x1,%ebx
  800232:	85 db                	test   %ebx,%ebx
  800234:	7f ed                	jg     800223 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800236:	83 ec 08             	sub    $0x8,%esp
  800239:	56                   	push   %esi
  80023a:	83 ec 04             	sub    $0x4,%esp
  80023d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800240:	ff 75 e0             	pushl  -0x20(%ebp)
  800243:	ff 75 dc             	pushl  -0x24(%ebp)
  800246:	ff 75 d8             	pushl  -0x28(%ebp)
  800249:	e8 d2 0d 00 00       	call   801020 <__umoddi3>
  80024e:	83 c4 14             	add    $0x14,%esp
  800251:	0f be 80 b2 11 80 00 	movsbl 0x8011b2(%eax),%eax
  800258:	50                   	push   %eax
  800259:	ff d7                	call   *%edi
}
  80025b:	83 c4 10             	add    $0x10,%esp
  80025e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800261:	5b                   	pop    %ebx
  800262:	5e                   	pop    %esi
  800263:	5f                   	pop    %edi
  800264:	5d                   	pop    %ebp
  800265:	c3                   	ret    

00800266 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800266:	f3 0f 1e fb          	endbr32 
  80026a:	55                   	push   %ebp
  80026b:	89 e5                	mov    %esp,%ebp
  80026d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800270:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800274:	8b 10                	mov    (%eax),%edx
  800276:	3b 50 04             	cmp    0x4(%eax),%edx
  800279:	73 0a                	jae    800285 <sprintputch+0x1f>
		*b->buf++ = ch;
  80027b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027e:	89 08                	mov    %ecx,(%eax)
  800280:	8b 45 08             	mov    0x8(%ebp),%eax
  800283:	88 02                	mov    %al,(%edx)
}
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <printfmt>:
{
  800287:	f3 0f 1e fb          	endbr32 
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800291:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800294:	50                   	push   %eax
  800295:	ff 75 10             	pushl  0x10(%ebp)
  800298:	ff 75 0c             	pushl  0xc(%ebp)
  80029b:	ff 75 08             	pushl  0x8(%ebp)
  80029e:	e8 05 00 00 00       	call   8002a8 <vprintfmt>
}
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <vprintfmt>:
{
  8002a8:	f3 0f 1e fb          	endbr32 
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	57                   	push   %edi
  8002b0:	56                   	push   %esi
  8002b1:	53                   	push   %ebx
  8002b2:	83 ec 3c             	sub    $0x3c,%esp
  8002b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002be:	e9 8e 03 00 00       	jmp    800651 <vprintfmt+0x3a9>
		padc = ' ';
  8002c3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8002c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8002ce:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8002d5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8002dc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8002e1:	8d 47 01             	lea    0x1(%edi),%eax
  8002e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002e7:	0f b6 17             	movzbl (%edi),%edx
  8002ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8002ed:	3c 55                	cmp    $0x55,%al
  8002ef:	0f 87 df 03 00 00    	ja     8006d4 <vprintfmt+0x42c>
  8002f5:	0f b6 c0             	movzbl %al,%eax
  8002f8:	3e ff 24 85 80 12 80 	notrack jmp *0x801280(,%eax,4)
  8002ff:	00 
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800303:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800307:	eb d8                	jmp    8002e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800310:	eb cf                	jmp    8002e1 <vprintfmt+0x39>
  800312:	0f b6 d2             	movzbl %dl,%edx
  800315:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800318:	b8 00 00 00 00       	mov    $0x0,%eax
  80031d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800320:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800323:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800327:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80032a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80032d:	83 f9 09             	cmp    $0x9,%ecx
  800330:	77 55                	ja     800387 <vprintfmt+0xdf>
			for (precision = 0; ; ++fmt) {
  800332:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800335:	eb e9                	jmp    800320 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800337:	8b 45 14             	mov    0x14(%ebp),%eax
  80033a:	8b 00                	mov    (%eax),%eax
  80033c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033f:	8b 45 14             	mov    0x14(%ebp),%eax
  800342:	8d 40 04             	lea    0x4(%eax),%eax
  800345:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800348:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80034b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80034f:	79 90                	jns    8002e1 <vprintfmt+0x39>
				width = precision, precision = -1;
  800351:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800354:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800357:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80035e:	eb 81                	jmp    8002e1 <vprintfmt+0x39>
  800360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800363:	85 c0                	test   %eax,%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	0f 49 d0             	cmovns %eax,%edx
  80036d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800373:	e9 69 ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80037b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800382:	e9 5a ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
  800387:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80038a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80038d:	eb bc                	jmp    80034b <vprintfmt+0xa3>
			lflag++;
  80038f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800392:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800395:	e9 47 ff ff ff       	jmp    8002e1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80039a:	8b 45 14             	mov    0x14(%ebp),%eax
  80039d:	8d 78 04             	lea    0x4(%eax),%edi
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	53                   	push   %ebx
  8003a4:	ff 30                	pushl  (%eax)
  8003a6:	ff d6                	call   *%esi
			break;
  8003a8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ab:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ae:	e9 9b 02 00 00       	jmp    80064e <vprintfmt+0x3a6>
			err = va_arg(ap, int);
  8003b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b6:	8d 78 04             	lea    0x4(%eax),%edi
  8003b9:	8b 00                	mov    (%eax),%eax
  8003bb:	99                   	cltd   
  8003bc:	31 d0                	xor    %edx,%eax
  8003be:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003c0:	83 f8 08             	cmp    $0x8,%eax
  8003c3:	7f 23                	jg     8003e8 <vprintfmt+0x140>
  8003c5:	8b 14 85 e0 13 80 00 	mov    0x8013e0(,%eax,4),%edx
  8003cc:	85 d2                	test   %edx,%edx
  8003ce:	74 18                	je     8003e8 <vprintfmt+0x140>
				printfmt(putch, putdat, "%s", p);
  8003d0:	52                   	push   %edx
  8003d1:	68 d3 11 80 00       	push   $0x8011d3
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 aa fe ff ff       	call   800287 <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8003e3:	e9 66 02 00 00       	jmp    80064e <vprintfmt+0x3a6>
				printfmt(putch, putdat, "error %d", err);
  8003e8:	50                   	push   %eax
  8003e9:	68 ca 11 80 00       	push   $0x8011ca
  8003ee:	53                   	push   %ebx
  8003ef:	56                   	push   %esi
  8003f0:	e8 92 fe ff ff       	call   800287 <printfmt>
  8003f5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8003f8:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8003fb:	e9 4e 02 00 00       	jmp    80064e <vprintfmt+0x3a6>
			if ((p = va_arg(ap, char *)) == NULL)
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	83 c0 04             	add    $0x4,%eax
  800406:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80040e:	85 d2                	test   %edx,%edx
  800410:	b8 c3 11 80 00       	mov    $0x8011c3,%eax
  800415:	0f 45 c2             	cmovne %edx,%eax
  800418:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80041b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80041f:	7e 06                	jle    800427 <vprintfmt+0x17f>
  800421:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800425:	75 0d                	jne    800434 <vprintfmt+0x18c>
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80042a:	89 c7                	mov    %eax,%edi
  80042c:	03 45 e0             	add    -0x20(%ebp),%eax
  80042f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800432:	eb 55                	jmp    800489 <vprintfmt+0x1e1>
  800434:	83 ec 08             	sub    $0x8,%esp
  800437:	ff 75 d8             	pushl  -0x28(%ebp)
  80043a:	ff 75 cc             	pushl  -0x34(%ebp)
  80043d:	e8 46 03 00 00       	call   800788 <strnlen>
  800442:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800445:	29 c2                	sub    %eax,%edx
  800447:	89 55 c4             	mov    %edx,-0x3c(%ebp)
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	89 d7                	mov    %edx,%edi
					putch(padc, putdat);
  80044f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800453:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800456:	85 ff                	test   %edi,%edi
  800458:	7e 11                	jle    80046b <vprintfmt+0x1c3>
					putch(padc, putdat);
  80045a:	83 ec 08             	sub    $0x8,%esp
  80045d:	53                   	push   %ebx
  80045e:	ff 75 e0             	pushl  -0x20(%ebp)
  800461:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800463:	83 ef 01             	sub    $0x1,%edi
  800466:	83 c4 10             	add    $0x10,%esp
  800469:	eb eb                	jmp    800456 <vprintfmt+0x1ae>
  80046b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80046e:	85 d2                	test   %edx,%edx
  800470:	b8 00 00 00 00       	mov    $0x0,%eax
  800475:	0f 49 c2             	cmovns %edx,%eax
  800478:	29 c2                	sub    %eax,%edx
  80047a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80047d:	eb a8                	jmp    800427 <vprintfmt+0x17f>
					putch(ch, putdat);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	53                   	push   %ebx
  800483:	52                   	push   %edx
  800484:	ff d6                	call   *%esi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80048e:	83 c7 01             	add    $0x1,%edi
  800491:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800495:	0f be d0             	movsbl %al,%edx
  800498:	85 d2                	test   %edx,%edx
  80049a:	74 4b                	je     8004e7 <vprintfmt+0x23f>
  80049c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a0:	78 06                	js     8004a8 <vprintfmt+0x200>
  8004a2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004a6:	78 1e                	js     8004c6 <vprintfmt+0x21e>
				if (altflag && (ch < ' ' || ch > '~'))
  8004a8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ac:	74 d1                	je     80047f <vprintfmt+0x1d7>
  8004ae:	0f be c0             	movsbl %al,%eax
  8004b1:	83 e8 20             	sub    $0x20,%eax
  8004b4:	83 f8 5e             	cmp    $0x5e,%eax
  8004b7:	76 c6                	jbe    80047f <vprintfmt+0x1d7>
					putch('?', putdat);
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	53                   	push   %ebx
  8004bd:	6a 3f                	push   $0x3f
  8004bf:	ff d6                	call   *%esi
  8004c1:	83 c4 10             	add    $0x10,%esp
  8004c4:	eb c3                	jmp    800489 <vprintfmt+0x1e1>
  8004c6:	89 cf                	mov    %ecx,%edi
  8004c8:	eb 0e                	jmp    8004d8 <vprintfmt+0x230>
				putch(' ', putdat);
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	53                   	push   %ebx
  8004ce:	6a 20                	push   $0x20
  8004d0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8004d2:	83 ef 01             	sub    $0x1,%edi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7f ee                	jg     8004ca <vprintfmt+0x222>
			if ((p = va_arg(ap, char *)) == NULL)
  8004dc:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8004df:	89 45 14             	mov    %eax,0x14(%ebp)
  8004e2:	e9 67 01 00 00       	jmp    80064e <vprintfmt+0x3a6>
  8004e7:	89 cf                	mov    %ecx,%edi
  8004e9:	eb ed                	jmp    8004d8 <vprintfmt+0x230>
	if (lflag >= 2)
  8004eb:	83 f9 01             	cmp    $0x1,%ecx
  8004ee:	7f 1b                	jg     80050b <vprintfmt+0x263>
	else if (lflag)
  8004f0:	85 c9                	test   %ecx,%ecx
  8004f2:	74 63                	je     800557 <vprintfmt+0x2af>
		return va_arg(*ap, long);
  8004f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f7:	8b 00                	mov    (%eax),%eax
  8004f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fc:	99                   	cltd   
  8004fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 40 04             	lea    0x4(%eax),%eax
  800506:	89 45 14             	mov    %eax,0x14(%ebp)
  800509:	eb 17                	jmp    800522 <vprintfmt+0x27a>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 50 04             	mov    0x4(%eax),%edx
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 08             	lea    0x8(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800522:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800525:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800528:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  80052d:	85 c9                	test   %ecx,%ecx
  80052f:	0f 89 ff 00 00 00    	jns    800634 <vprintfmt+0x38c>
				putch('-', putdat);
  800535:	83 ec 08             	sub    $0x8,%esp
  800538:	53                   	push   %ebx
  800539:	6a 2d                	push   $0x2d
  80053b:	ff d6                	call   *%esi
				num = -(long long) num;
  80053d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800540:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800543:	f7 da                	neg    %edx
  800545:	83 d1 00             	adc    $0x0,%ecx
  800548:	f7 d9                	neg    %ecx
  80054a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80054d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800552:	e9 dd 00 00 00       	jmp    800634 <vprintfmt+0x38c>
		return va_arg(*ap, int);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055f:	99                   	cltd   
  800560:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 40 04             	lea    0x4(%eax),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
  80056c:	eb b4                	jmp    800522 <vprintfmt+0x27a>
	if (lflag >= 2)
  80056e:	83 f9 01             	cmp    $0x1,%ecx
  800571:	7f 1e                	jg     800591 <vprintfmt+0x2e9>
	else if (lflag)
  800573:	85 c9                	test   %ecx,%ecx
  800575:	74 32                	je     8005a9 <vprintfmt+0x301>
		return va_arg(*ap, unsigned long);
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	8b 10                	mov    (%eax),%edx
  80057c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800581:	8d 40 04             	lea    0x4(%eax),%eax
  800584:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800587:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long);
  80058c:	e9 a3 00 00 00       	jmp    800634 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8b 10                	mov    (%eax),%edx
  800596:	8b 48 04             	mov    0x4(%eax),%ecx
  800599:	8d 40 08             	lea    0x8(%eax),%eax
  80059c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80059f:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned long long);
  8005a4:	e9 8b 00 00 00       	jmp    800634 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8b 10                	mov    (%eax),%edx
  8005ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b3:	8d 40 04             	lea    0x4(%eax),%eax
  8005b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005b9:	b8 0a 00 00 00       	mov    $0xa,%eax
		return va_arg(*ap, unsigned int);
  8005be:	eb 74                	jmp    800634 <vprintfmt+0x38c>
	if (lflag >= 2)
  8005c0:	83 f9 01             	cmp    $0x1,%ecx
  8005c3:	7f 1b                	jg     8005e0 <vprintfmt+0x338>
	else if (lflag)
  8005c5:	85 c9                	test   %ecx,%ecx
  8005c7:	74 2c                	je     8005f5 <vprintfmt+0x34d>
		return va_arg(*ap, unsigned long);
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8b 10                	mov    (%eax),%edx
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	8d 40 04             	lea    0x4(%eax),%eax
  8005d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005d9:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long);
  8005de:	eb 54                	jmp    800634 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  8005e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e3:	8b 10                	mov    (%eax),%edx
  8005e5:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e8:	8d 40 08             	lea    0x8(%eax),%eax
  8005eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  8005ee:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned long long);
  8005f3:	eb 3f                	jmp    800634 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 8;
  800605:	b8 08 00 00 00       	mov    $0x8,%eax
		return va_arg(*ap, unsigned int);
  80060a:	eb 28                	jmp    800634 <vprintfmt+0x38c>
			putch('0', putdat);
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	6a 30                	push   $0x30
  800612:	ff d6                	call   *%esi
			putch('x', putdat);
  800614:	83 c4 08             	add    $0x8,%esp
  800617:	53                   	push   %ebx
  800618:	6a 78                	push   $0x78
  80061a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8b 10                	mov    (%eax),%edx
  800621:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800626:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062f:	b8 10 00 00 00       	mov    $0x10,%eax
			printnum(putch, putdat, num, base, width, padc);
  800634:	83 ec 0c             	sub    $0xc,%esp
  800637:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80063b:	57                   	push   %edi
  80063c:	ff 75 e0             	pushl  -0x20(%ebp)
  80063f:	50                   	push   %eax
  800640:	51                   	push   %ecx
  800641:	52                   	push   %edx
  800642:	89 da                	mov    %ebx,%edx
  800644:	89 f0                	mov    %esi,%eax
  800646:	e8 72 fb ff ff       	call   8001bd <printnum>
			break;
  80064b:	83 c4 20             	add    $0x20,%esp
			if ((p = va_arg(ap, char *)) == NULL)
  80064e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {	
  800651:	83 c7 01             	add    $0x1,%edi
  800654:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800658:	83 f8 25             	cmp    $0x25,%eax
  80065b:	0f 84 62 fc ff ff    	je     8002c3 <vprintfmt+0x1b>
			if (ch == '\0')										
  800661:	85 c0                	test   %eax,%eax
  800663:	0f 84 8b 00 00 00    	je     8006f4 <vprintfmt+0x44c>
			putch(ch, putdat);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	53                   	push   %ebx
  80066d:	50                   	push   %eax
  80066e:	ff d6                	call   *%esi
  800670:	83 c4 10             	add    $0x10,%esp
  800673:	eb dc                	jmp    800651 <vprintfmt+0x3a9>
	if (lflag >= 2)
  800675:	83 f9 01             	cmp    $0x1,%ecx
  800678:	7f 1b                	jg     800695 <vprintfmt+0x3ed>
	else if (lflag)
  80067a:	85 c9                	test   %ecx,%ecx
  80067c:	74 2c                	je     8006aa <vprintfmt+0x402>
		return va_arg(*ap, unsigned long);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 10                	mov    (%eax),%edx
  800683:	b9 00 00 00 00       	mov    $0x0,%ecx
  800688:	8d 40 04             	lea    0x4(%eax),%eax
  80068b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80068e:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long);
  800693:	eb 9f                	jmp    800634 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned long long);
  800695:	8b 45 14             	mov    0x14(%ebp),%eax
  800698:	8b 10                	mov    (%eax),%edx
  80069a:	8b 48 04             	mov    0x4(%eax),%ecx
  80069d:	8d 40 08             	lea    0x8(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned long long);
  8006a8:	eb 8a                	jmp    800634 <vprintfmt+0x38c>
		return va_arg(*ap, unsigned int);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8b 10                	mov    (%eax),%edx
  8006af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ba:	b8 10 00 00 00       	mov    $0x10,%eax
		return va_arg(*ap, unsigned int);
  8006bf:	e9 70 ff ff ff       	jmp    800634 <vprintfmt+0x38c>
			putch(ch, putdat);
  8006c4:	83 ec 08             	sub    $0x8,%esp
  8006c7:	53                   	push   %ebx
  8006c8:	6a 25                	push   $0x25
  8006ca:	ff d6                	call   *%esi
			break;
  8006cc:	83 c4 10             	add    $0x10,%esp
  8006cf:	e9 7a ff ff ff       	jmp    80064e <vprintfmt+0x3a6>
			putch('%', putdat);
  8006d4:	83 ec 08             	sub    $0x8,%esp
  8006d7:	53                   	push   %ebx
  8006d8:	6a 25                	push   $0x25
  8006da:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	89 f8                	mov    %edi,%eax
  8006e1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006e5:	74 05                	je     8006ec <vprintfmt+0x444>
  8006e7:	83 e8 01             	sub    $0x1,%eax
  8006ea:	eb f5                	jmp    8006e1 <vprintfmt+0x439>
  8006ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ef:	e9 5a ff ff ff       	jmp    80064e <vprintfmt+0x3a6>
}
  8006f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5f                   	pop    %edi
  8006fa:	5d                   	pop    %ebp
  8006fb:	c3                   	ret    

008006fc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006fc:	f3 0f 1e fb          	endbr32 
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	83 ec 18             	sub    $0x18,%esp
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80070c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80070f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800713:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800716:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80071d:	85 c0                	test   %eax,%eax
  80071f:	74 26                	je     800747 <vsnprintf+0x4b>
  800721:	85 d2                	test   %edx,%edx
  800723:	7e 22                	jle    800747 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800725:	ff 75 14             	pushl  0x14(%ebp)
  800728:	ff 75 10             	pushl  0x10(%ebp)
  80072b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80072e:	50                   	push   %eax
  80072f:	68 66 02 80 00       	push   $0x800266
  800734:	e8 6f fb ff ff       	call   8002a8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800739:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80073c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80073f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800742:	83 c4 10             	add    $0x10,%esp
}
  800745:	c9                   	leave  
  800746:	c3                   	ret    
		return -E_INVAL;
  800747:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80074c:	eb f7                	jmp    800745 <vsnprintf+0x49>

0080074e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80074e:	f3 0f 1e fb          	endbr32 
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800758:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80075b:	50                   	push   %eax
  80075c:	ff 75 10             	pushl  0x10(%ebp)
  80075f:	ff 75 0c             	pushl  0xc(%ebp)
  800762:	ff 75 08             	pushl  0x8(%ebp)
  800765:	e8 92 ff ff ff       	call   8006fc <vsnprintf>
	va_end(ap);

	return rc;
}
  80076a:	c9                   	leave  
  80076b:	c3                   	ret    

0080076c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80076c:	f3 0f 1e fb          	endbr32 
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800776:	b8 00 00 00 00       	mov    $0x0,%eax
  80077b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80077f:	74 05                	je     800786 <strlen+0x1a>
		n++;
  800781:	83 c0 01             	add    $0x1,%eax
  800784:	eb f5                	jmp    80077b <strlen+0xf>
	return n;
}
  800786:	5d                   	pop    %ebp
  800787:	c3                   	ret    

00800788 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800788:	f3 0f 1e fb          	endbr32 
  80078c:	55                   	push   %ebp
  80078d:	89 e5                	mov    %esp,%ebp
  80078f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800795:	b8 00 00 00 00       	mov    $0x0,%eax
  80079a:	39 d0                	cmp    %edx,%eax
  80079c:	74 0d                	je     8007ab <strnlen+0x23>
  80079e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007a2:	74 05                	je     8007a9 <strnlen+0x21>
		n++;
  8007a4:	83 c0 01             	add    $0x1,%eax
  8007a7:	eb f1                	jmp    80079a <strnlen+0x12>
  8007a9:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ab:	89 d0                	mov    %edx,%eax
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007af:	f3 0f 1e fb          	endbr32 
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	53                   	push   %ebx
  8007b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c9:	83 c0 01             	add    $0x1,%eax
  8007cc:	84 d2                	test   %dl,%dl
  8007ce:	75 f2                	jne    8007c2 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007d0:	89 c8                	mov    %ecx,%eax
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d5:	f3 0f 1e fb          	endbr32 
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 10             	sub    $0x10,%esp
  8007e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e3:	53                   	push   %ebx
  8007e4:	e8 83 ff ff ff       	call   80076c <strlen>
  8007e9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007ec:	ff 75 0c             	pushl  0xc(%ebp)
  8007ef:	01 d8                	add    %ebx,%eax
  8007f1:	50                   	push   %eax
  8007f2:	e8 b8 ff ff ff       	call   8007af <strcpy>
	return dst;
}
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fe:	f3 0f 1e fb          	endbr32 
  800802:	55                   	push   %ebp
  800803:	89 e5                	mov    %esp,%ebp
  800805:	56                   	push   %esi
  800806:	53                   	push   %ebx
  800807:	8b 75 08             	mov    0x8(%ebp),%esi
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080d:	89 f3                	mov    %esi,%ebx
  80080f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800812:	89 f0                	mov    %esi,%eax
  800814:	39 d8                	cmp    %ebx,%eax
  800816:	74 11                	je     800829 <strncpy+0x2b>
		*dst++ = *src;
  800818:	83 c0 01             	add    $0x1,%eax
  80081b:	0f b6 0a             	movzbl (%edx),%ecx
  80081e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800821:	80 f9 01             	cmp    $0x1,%cl
  800824:	83 da ff             	sbb    $0xffffffff,%edx
  800827:	eb eb                	jmp    800814 <strncpy+0x16>
	}
	return ret;
}
  800829:	89 f0                	mov    %esi,%eax
  80082b:	5b                   	pop    %ebx
  80082c:	5e                   	pop    %esi
  80082d:	5d                   	pop    %ebp
  80082e:	c3                   	ret    

0080082f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082f:	f3 0f 1e fb          	endbr32 
  800833:	55                   	push   %ebp
  800834:	89 e5                	mov    %esp,%ebp
  800836:	56                   	push   %esi
  800837:	53                   	push   %ebx
  800838:	8b 75 08             	mov    0x8(%ebp),%esi
  80083b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80083e:	8b 55 10             	mov    0x10(%ebp),%edx
  800841:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800843:	85 d2                	test   %edx,%edx
  800845:	74 21                	je     800868 <strlcpy+0x39>
  800847:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80084b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80084d:	39 c2                	cmp    %eax,%edx
  80084f:	74 14                	je     800865 <strlcpy+0x36>
  800851:	0f b6 19             	movzbl (%ecx),%ebx
  800854:	84 db                	test   %bl,%bl
  800856:	74 0b                	je     800863 <strlcpy+0x34>
			*dst++ = *src++;
  800858:	83 c1 01             	add    $0x1,%ecx
  80085b:	83 c2 01             	add    $0x1,%edx
  80085e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800861:	eb ea                	jmp    80084d <strlcpy+0x1e>
  800863:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800865:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800868:	29 f0                	sub    %esi,%eax
}
  80086a:	5b                   	pop    %ebx
  80086b:	5e                   	pop    %esi
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80086e:	f3 0f 1e fb          	endbr32 
  800872:	55                   	push   %ebp
  800873:	89 e5                	mov    %esp,%ebp
  800875:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800878:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80087b:	0f b6 01             	movzbl (%ecx),%eax
  80087e:	84 c0                	test   %al,%al
  800880:	74 0c                	je     80088e <strcmp+0x20>
  800882:	3a 02                	cmp    (%edx),%al
  800884:	75 08                	jne    80088e <strcmp+0x20>
		p++, q++;
  800886:	83 c1 01             	add    $0x1,%ecx
  800889:	83 c2 01             	add    $0x1,%edx
  80088c:	eb ed                	jmp    80087b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80088e:	0f b6 c0             	movzbl %al,%eax
  800891:	0f b6 12             	movzbl (%edx),%edx
  800894:	29 d0                	sub    %edx,%eax
}
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    

00800898 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800898:	f3 0f 1e fb          	endbr32 
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	53                   	push   %ebx
  8008a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a6:	89 c3                	mov    %eax,%ebx
  8008a8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ab:	eb 06                	jmp    8008b3 <strncmp+0x1b>
		n--, p++, q++;
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008b3:	39 d8                	cmp    %ebx,%eax
  8008b5:	74 16                	je     8008cd <strncmp+0x35>
  8008b7:	0f b6 08             	movzbl (%eax),%ecx
  8008ba:	84 c9                	test   %cl,%cl
  8008bc:	74 04                	je     8008c2 <strncmp+0x2a>
  8008be:	3a 0a                	cmp    (%edx),%cl
  8008c0:	74 eb                	je     8008ad <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008c2:	0f b6 00             	movzbl (%eax),%eax
  8008c5:	0f b6 12             	movzbl (%edx),%edx
  8008c8:	29 d0                	sub    %edx,%eax
}
  8008ca:	5b                   	pop    %ebx
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    
		return 0;
  8008cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d2:	eb f6                	jmp    8008ca <strncmp+0x32>

008008d4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008d4:	f3 0f 1e fb          	endbr32 
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	8b 45 08             	mov    0x8(%ebp),%eax
  8008de:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e2:	0f b6 10             	movzbl (%eax),%edx
  8008e5:	84 d2                	test   %dl,%dl
  8008e7:	74 09                	je     8008f2 <strchr+0x1e>
		if (*s == c)
  8008e9:	38 ca                	cmp    %cl,%dl
  8008eb:	74 0a                	je     8008f7 <strchr+0x23>
	for (; *s; s++)
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	eb f0                	jmp    8008e2 <strchr+0xe>
			return (char *) s;
	return 0;
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008f9:	f3 0f 1e fb          	endbr32 
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800907:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80090a:	38 ca                	cmp    %cl,%dl
  80090c:	74 09                	je     800917 <strfind+0x1e>
  80090e:	84 d2                	test   %dl,%dl
  800910:	74 05                	je     800917 <strfind+0x1e>
	for (; *s; s++)
  800912:	83 c0 01             	add    $0x1,%eax
  800915:	eb f0                	jmp    800907 <strfind+0xe>
			break;
	return (char *) s;
}
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    

00800919 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800919:	f3 0f 1e fb          	endbr32 
  80091d:	55                   	push   %ebp
  80091e:	89 e5                	mov    %esp,%ebp
  800920:	57                   	push   %edi
  800921:	56                   	push   %esi
  800922:	53                   	push   %ebx
  800923:	8b 7d 08             	mov    0x8(%ebp),%edi
  800926:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800929:	85 c9                	test   %ecx,%ecx
  80092b:	74 31                	je     80095e <memset+0x45>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80092d:	89 f8                	mov    %edi,%eax
  80092f:	09 c8                	or     %ecx,%eax
  800931:	a8 03                	test   $0x3,%al
  800933:	75 23                	jne    800958 <memset+0x3f>
		c &= 0xFF;
  800935:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800939:	89 d3                	mov    %edx,%ebx
  80093b:	c1 e3 08             	shl    $0x8,%ebx
  80093e:	89 d0                	mov    %edx,%eax
  800940:	c1 e0 18             	shl    $0x18,%eax
  800943:	89 d6                	mov    %edx,%esi
  800945:	c1 e6 10             	shl    $0x10,%esi
  800948:	09 f0                	or     %esi,%eax
  80094a:	09 c2                	or     %eax,%edx
  80094c:	09 da                	or     %ebx,%edx
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80094e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800951:	89 d0                	mov    %edx,%eax
  800953:	fc                   	cld    
  800954:	f3 ab                	rep stos %eax,%es:(%edi)
  800956:	eb 06                	jmp    80095e <memset+0x45>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800958:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095b:	fc                   	cld    
  80095c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80095e:	89 f8                	mov    %edi,%eax
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5f                   	pop    %edi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800965:	f3 0f 1e fb          	endbr32 
  800969:	55                   	push   %ebp
  80096a:	89 e5                	mov    %esp,%ebp
  80096c:	57                   	push   %edi
  80096d:	56                   	push   %esi
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	8b 75 0c             	mov    0xc(%ebp),%esi
  800974:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800977:	39 c6                	cmp    %eax,%esi
  800979:	73 32                	jae    8009ad <memmove+0x48>
  80097b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097e:	39 c2                	cmp    %eax,%edx
  800980:	76 2b                	jbe    8009ad <memmove+0x48>
		s += n;
		d += n;
  800982:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 fe                	mov    %edi,%esi
  800987:	09 ce                	or     %ecx,%esi
  800989:	09 d6                	or     %edx,%esi
  80098b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800991:	75 0e                	jne    8009a1 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800993:	83 ef 04             	sub    $0x4,%edi
  800996:	8d 72 fc             	lea    -0x4(%edx),%esi
  800999:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80099c:	fd                   	std    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 09                	jmp    8009aa <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a1:	83 ef 01             	sub    $0x1,%edi
  8009a4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a7:	fd                   	std    
  8009a8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009aa:	fc                   	cld    
  8009ab:	eb 1a                	jmp    8009c7 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ad:	89 c2                	mov    %eax,%edx
  8009af:	09 ca                	or     %ecx,%edx
  8009b1:	09 f2                	or     %esi,%edx
  8009b3:	f6 c2 03             	test   $0x3,%dl
  8009b6:	75 0a                	jne    8009c2 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009bb:	89 c7                	mov    %eax,%edi
  8009bd:	fc                   	cld    
  8009be:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c0:	eb 05                	jmp    8009c7 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009c2:	89 c7                	mov    %eax,%edi
  8009c4:	fc                   	cld    
  8009c5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c7:	5e                   	pop    %esi
  8009c8:	5f                   	pop    %edi
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cb:	f3 0f 1e fb          	endbr32 
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d5:	ff 75 10             	pushl  0x10(%ebp)
  8009d8:	ff 75 0c             	pushl  0xc(%ebp)
  8009db:	ff 75 08             	pushl  0x8(%ebp)
  8009de:	e8 82 ff ff ff       	call   800965 <memmove>
}
  8009e3:	c9                   	leave  
  8009e4:	c3                   	ret    

008009e5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e5:	f3 0f 1e fb          	endbr32 
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	56                   	push   %esi
  8009ed:	53                   	push   %ebx
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f4:	89 c6                	mov    %eax,%esi
  8009f6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f9:	39 f0                	cmp    %esi,%eax
  8009fb:	74 1c                	je     800a19 <memcmp+0x34>
		if (*s1 != *s2)
  8009fd:	0f b6 08             	movzbl (%eax),%ecx
  800a00:	0f b6 1a             	movzbl (%edx),%ebx
  800a03:	38 d9                	cmp    %bl,%cl
  800a05:	75 08                	jne    800a0f <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a07:	83 c0 01             	add    $0x1,%eax
  800a0a:	83 c2 01             	add    $0x1,%edx
  800a0d:	eb ea                	jmp    8009f9 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a0f:	0f b6 c1             	movzbl %cl,%eax
  800a12:	0f b6 db             	movzbl %bl,%ebx
  800a15:	29 d8                	sub    %ebx,%eax
  800a17:	eb 05                	jmp    800a1e <memcmp+0x39>
	}

	return 0;
  800a19:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5e                   	pop    %esi
  800a20:	5d                   	pop    %ebp
  800a21:	c3                   	ret    

00800a22 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a22:	f3 0f 1e fb          	endbr32 
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a2f:	89 c2                	mov    %eax,%edx
  800a31:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a34:	39 d0                	cmp    %edx,%eax
  800a36:	73 09                	jae    800a41 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a38:	38 08                	cmp    %cl,(%eax)
  800a3a:	74 05                	je     800a41 <memfind+0x1f>
	for (; s < ends; s++)
  800a3c:	83 c0 01             	add    $0x1,%eax
  800a3f:	eb f3                	jmp    800a34 <memfind+0x12>
			break;
	return (void *) s;
}
  800a41:	5d                   	pop    %ebp
  800a42:	c3                   	ret    

00800a43 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a43:	f3 0f 1e fb          	endbr32 
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a53:	eb 03                	jmp    800a58 <strtol+0x15>
		s++;
  800a55:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a58:	0f b6 01             	movzbl (%ecx),%eax
  800a5b:	3c 20                	cmp    $0x20,%al
  800a5d:	74 f6                	je     800a55 <strtol+0x12>
  800a5f:	3c 09                	cmp    $0x9,%al
  800a61:	74 f2                	je     800a55 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a63:	3c 2b                	cmp    $0x2b,%al
  800a65:	74 2a                	je     800a91 <strtol+0x4e>
	int neg = 0;
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a6c:	3c 2d                	cmp    $0x2d,%al
  800a6e:	74 2b                	je     800a9b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a76:	75 0f                	jne    800a87 <strtol+0x44>
  800a78:	80 39 30             	cmpb   $0x30,(%ecx)
  800a7b:	74 28                	je     800aa5 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7d:	85 db                	test   %ebx,%ebx
  800a7f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a84:	0f 44 d8             	cmove  %eax,%ebx
  800a87:	b8 00 00 00 00       	mov    $0x0,%eax
  800a8c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8f:	eb 46                	jmp    800ad7 <strtol+0x94>
		s++;
  800a91:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a94:	bf 00 00 00 00       	mov    $0x0,%edi
  800a99:	eb d5                	jmp    800a70 <strtol+0x2d>
		s++, neg = 1;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa3:	eb cb                	jmp    800a70 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa5:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa9:	74 0e                	je     800ab9 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 d8                	jne    800a87 <strtol+0x44>
		s++, base = 8;
  800aaf:	83 c1 01             	add    $0x1,%ecx
  800ab2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab7:	eb ce                	jmp    800a87 <strtol+0x44>
		s += 2, base = 16;
  800ab9:	83 c1 02             	add    $0x2,%ecx
  800abc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac1:	eb c4                	jmp    800a87 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac3:	0f be d2             	movsbl %dl,%edx
  800ac6:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac9:	3b 55 10             	cmp    0x10(%ebp),%edx
  800acc:	7d 3a                	jge    800b08 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ace:	83 c1 01             	add    $0x1,%ecx
  800ad1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ad7:	0f b6 11             	movzbl (%ecx),%edx
  800ada:	8d 72 d0             	lea    -0x30(%edx),%esi
  800add:	89 f3                	mov    %esi,%ebx
  800adf:	80 fb 09             	cmp    $0x9,%bl
  800ae2:	76 df                	jbe    800ac3 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ae4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 08                	ja     800af6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800aee:	0f be d2             	movsbl %dl,%edx
  800af1:	83 ea 57             	sub    $0x57,%edx
  800af4:	eb d3                	jmp    800ac9 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800af6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 08                	ja     800b08 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b00:	0f be d2             	movsbl %dl,%edx
  800b03:	83 ea 37             	sub    $0x37,%edx
  800b06:	eb c1                	jmp    800ac9 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0c:	74 05                	je     800b13 <strtol+0xd0>
		*endptr = (char *) s;
  800b0e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b11:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b13:	89 c2                	mov    %eax,%edx
  800b15:	f7 da                	neg    %edx
  800b17:	85 ff                	test   %edi,%edi
  800b19:	0f 45 c2             	cmovne %edx,%eax
}
  800b1c:	5b                   	pop    %ebx
  800b1d:	5e                   	pop    %esi
  800b1e:	5f                   	pop    %edi
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b21:	f3 0f 1e fb          	endbr32 
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	57                   	push   %edi
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b30:	8b 55 08             	mov    0x8(%ebp),%edx
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b36:	89 c3                	mov    %eax,%ebx
  800b38:	89 c7                	mov    %eax,%edi
  800b3a:	89 c6                	mov    %eax,%esi
  800b3c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b43:	f3 0f 1e fb          	endbr32 
  800b47:	55                   	push   %ebp
  800b48:	89 e5                	mov    %esp,%ebp
  800b4a:	57                   	push   %edi
  800b4b:	56                   	push   %esi
  800b4c:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 01 00 00 00       	mov    $0x1,%eax
  800b57:	89 d1                	mov    %edx,%ecx
  800b59:	89 d3                	mov    %edx,%ebx
  800b5b:	89 d7                	mov    %edx,%edi
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b66:	f3 0f 1e fb          	endbr32 
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	57                   	push   %edi
  800b6e:	56                   	push   %esi
  800b6f:	53                   	push   %ebx
  800b70:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800b73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b78:	8b 55 08             	mov    0x8(%ebp),%edx
  800b7b:	b8 03 00 00 00       	mov    $0x3,%eax
  800b80:	89 cb                	mov    %ecx,%ebx
  800b82:	89 cf                	mov    %ecx,%edi
  800b84:	89 ce                	mov    %ecx,%esi
  800b86:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b88:	85 c0                	test   %eax,%eax
  800b8a:	7f 08                	jg     800b94 <sys_env_destroy+0x2e>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b8c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5f                   	pop    %edi
  800b92:	5d                   	pop    %ebp
  800b93:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b94:	83 ec 0c             	sub    $0xc,%esp
  800b97:	50                   	push   %eax
  800b98:	6a 03                	push   $0x3
  800b9a:	68 04 14 80 00       	push   $0x801404
  800b9f:	6a 23                	push   $0x23
  800ba1:	68 21 14 80 00       	push   $0x801421
  800ba6:	e8 19 03 00 00       	call   800ec4 <_panic>

00800bab <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bab:	f3 0f 1e fb          	endbr32 
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 02 00 00 00       	mov    $0x2,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_yield>:

void
sys_yield(void)
{
  800bce:	f3 0f 1e fb          	endbr32 
  800bd2:	55                   	push   %ebp
  800bd3:	89 e5                	mov    %esp,%ebp
  800bd5:	57                   	push   %edi
  800bd6:	56                   	push   %esi
  800bd7:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bd8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bdd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800be2:	89 d1                	mov    %edx,%ecx
  800be4:	89 d3                	mov    %edx,%ebx
  800be6:	89 d7                	mov    %edx,%edi
  800be8:	89 d6                	mov    %edx,%esi
  800bea:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bec:	5b                   	pop    %ebx
  800bed:	5e                   	pop    %esi
  800bee:	5f                   	pop    %edi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bf1:	f3 0f 1e fb          	endbr32 
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	57                   	push   %edi
  800bf9:	56                   	push   %esi
  800bfa:	53                   	push   %ebx
  800bfb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800bfe:	be 00 00 00 00       	mov    $0x0,%esi
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c09:	b8 04 00 00 00       	mov    $0x4,%eax
  800c0e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c11:	89 f7                	mov    %esi,%edi
  800c13:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c15:	85 c0                	test   %eax,%eax
  800c17:	7f 08                	jg     800c21 <sys_page_alloc+0x30>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 04                	push   $0x4
  800c27:	68 04 14 80 00       	push   $0x801404
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 21 14 80 00       	push   $0x801421
  800c33:	e8 8c 02 00 00       	call   800ec4 <_panic>

00800c38 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c38:	f3 0f 1e fb          	endbr32 
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c45:	8b 55 08             	mov    0x8(%ebp),%edx
  800c48:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4b:	b8 05 00 00 00       	mov    $0x5,%eax
  800c50:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c53:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c56:	8b 75 18             	mov    0x18(%ebp),%esi
  800c59:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c5b:	85 c0                	test   %eax,%eax
  800c5d:	7f 08                	jg     800c67 <sys_page_map+0x2f>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c67:	83 ec 0c             	sub    $0xc,%esp
  800c6a:	50                   	push   %eax
  800c6b:	6a 05                	push   $0x5
  800c6d:	68 04 14 80 00       	push   $0x801404
  800c72:	6a 23                	push   $0x23
  800c74:	68 21 14 80 00       	push   $0x801421
  800c79:	e8 46 02 00 00       	call   800ec4 <_panic>

00800c7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7e:	f3 0f 1e fb          	endbr32 
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	8b 55 08             	mov    0x8(%ebp),%edx
  800c93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c96:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7f 08                	jg     800cad <sys_page_unmap+0x2f>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ca5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca8:	5b                   	pop    %ebx
  800ca9:	5e                   	pop    %esi
  800caa:	5f                   	pop    %edi
  800cab:	5d                   	pop    %ebp
  800cac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	50                   	push   %eax
  800cb1:	6a 06                	push   $0x6
  800cb3:	68 04 14 80 00       	push   $0x801404
  800cb8:	6a 23                	push   $0x23
  800cba:	68 21 14 80 00       	push   $0x801421
  800cbf:	e8 00 02 00 00       	call   800ec4 <_panic>

00800cc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cc4:	f3 0f 1e fb          	endbr32 
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	57                   	push   %edi
  800ccc:	56                   	push   %esi
  800ccd:	53                   	push   %ebx
  800cce:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800cd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdc:	b8 08 00 00 00       	mov    $0x8,%eax
  800ce1:	89 df                	mov    %ebx,%edi
  800ce3:	89 de                	mov    %ebx,%esi
  800ce5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7f 08                	jg     800cf3 <sys_env_set_status+0x2f>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 08                	push   $0x8
  800cf9:	68 04 14 80 00       	push   $0x801404
  800cfe:	6a 23                	push   $0x23
  800d00:	68 21 14 80 00       	push   $0x801421
  800d05:	e8 ba 01 00 00       	call   800ec4 <_panic>

00800d0a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d0a:	f3 0f 1e fb          	endbr32 
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	57                   	push   %edi
  800d12:	56                   	push   %esi
  800d13:	53                   	push   %ebx
  800d14:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	b8 09 00 00 00       	mov    $0x9,%eax
  800d27:	89 df                	mov    %ebx,%edi
  800d29:	89 de                	mov    %ebx,%esi
  800d2b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d2d:	85 c0                	test   %eax,%eax
  800d2f:	7f 08                	jg     800d39 <sys_env_set_pgfault_upcall+0x2f>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	50                   	push   %eax
  800d3d:	6a 09                	push   $0x9
  800d3f:	68 04 14 80 00       	push   $0x801404
  800d44:	6a 23                	push   $0x23
  800d46:	68 21 14 80 00       	push   $0x801421
  800d4b:	e8 74 01 00 00       	call   800ec4 <_panic>

00800d50 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d60:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d65:	be 00 00 00 00       	mov    $0x0,%esi
  800d6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d6d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d70:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d77:	f3 0f 1e fb          	endbr32 
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	57                   	push   %edi
  800d7f:	56                   	push   %esi
  800d80:	53                   	push   %ebx
  800d81:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"							//执行int T_SYSCALL指令
  800d84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d89:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d91:	89 cb                	mov    %ecx,%ebx
  800d93:	89 cf                	mov    %ecx,%edi
  800d95:	89 ce                	mov    %ecx,%esi
  800d97:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d99:	85 c0                	test   %eax,%eax
  800d9b:	7f 08                	jg     800da5 <sys_ipc_recv+0x2e>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da0:	5b                   	pop    %ebx
  800da1:	5e                   	pop    %esi
  800da2:	5f                   	pop    %edi
  800da3:	5d                   	pop    %ebp
  800da4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da5:	83 ec 0c             	sub    $0xc,%esp
  800da8:	50                   	push   %eax
  800da9:	6a 0c                	push   $0xc
  800dab:	68 04 14 80 00       	push   $0x801404
  800db0:	6a 23                	push   $0x23
  800db2:	68 21 14 80 00       	push   $0x801421
  800db7:	e8 08 01 00 00       	call   800ec4 <_panic>

00800dbc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  800dbc:	f3 0f 1e fb          	endbr32 
  800dc0:	55                   	push   %ebp
  800dc1:	89 e5                	mov    %esp,%ebp
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
  800dc5:	8b 75 08             	mov    0x8(%ebp),%esi
  800dc8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800dd5:	0f 44 c2             	cmove  %edx,%eax
	}
	int r = sys_ipc_recv(pg);
  800dd8:	83 ec 0c             	sub    $0xc,%esp
  800ddb:	50                   	push   %eax
  800ddc:	e8 96 ff ff ff       	call   800d77 <sys_ipc_recv>
	if (r < 0) {				
  800de1:	83 c4 10             	add    $0x10,%esp
  800de4:	85 c0                	test   %eax,%eax
  800de6:	78 2b                	js     800e13 <ipc_recv+0x57>
		if (from_env_store) *from_env_store = 0;
		if (perm_store) *perm_store = 0;
		return r;
	}
	if (from_env_store)
  800de8:	85 f6                	test   %esi,%esi
  800dea:	74 0a                	je     800df6 <ipc_recv+0x3a>
		*from_env_store = thisenv->env_ipc_from;
  800dec:	a1 60 40 80 00       	mov    0x804060,%eax
  800df1:	8b 40 74             	mov    0x74(%eax),%eax
  800df4:	89 06                	mov    %eax,(%esi)
	if (perm_store)
  800df6:	85 db                	test   %ebx,%ebx
  800df8:	74 0a                	je     800e04 <ipc_recv+0x48>
		*perm_store = thisenv->env_ipc_perm;
  800dfa:	a1 60 40 80 00       	mov    0x804060,%eax
  800dff:	8b 40 78             	mov    0x78(%eax),%eax
  800e02:	89 03                	mov    %eax,(%ebx)
	return thisenv->env_ipc_value;
  800e04:	a1 60 40 80 00       	mov    0x804060,%eax
  800e09:	8b 40 70             	mov    0x70(%eax),%eax
}
  800e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
		if (from_env_store) *from_env_store = 0;
  800e13:	85 f6                	test   %esi,%esi
  800e15:	74 06                	je     800e1d <ipc_recv+0x61>
  800e17:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if (perm_store) *perm_store = 0;
  800e1d:	85 db                	test   %ebx,%ebx
  800e1f:	74 eb                	je     800e0c <ipc_recv+0x50>
  800e21:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800e27:	eb e3                	jmp    800e0c <ipc_recv+0x50>

00800e29 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  800e29:	f3 0f 1e fb          	endbr32 
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 0c             	sub    $0xc,%esp
  800e36:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e39:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	if (pg == NULL) {
		pg = (void *)-1;
  800e3f:	85 db                	test   %ebx,%ebx
  800e41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  800e46:	0f 44 d8             	cmove  %eax,%ebx
	}
	int r;
	while(1) {
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800e49:	ff 75 14             	pushl  0x14(%ebp)
  800e4c:	53                   	push   %ebx
  800e4d:	56                   	push   %esi
  800e4e:	57                   	push   %edi
  800e4f:	e8 fc fe ff ff       	call   800d50 <sys_ipc_try_send>
		if (r == 0) {		
  800e54:	83 c4 10             	add    $0x10,%esp
  800e57:	85 c0                	test   %eax,%eax
  800e59:	74 1e                	je     800e79 <ipc_send+0x50>
			return;
		} else if (r == -E_IPC_NOT_RECV) {
  800e5b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  800e5e:	75 07                	jne    800e67 <ipc_send+0x3e>
			sys_yield();
  800e60:	e8 69 fd ff ff       	call   800bce <sys_yield>
		r = sys_ipc_try_send(to_env, val, pg, perm);
  800e65:	eb e2                	jmp    800e49 <ipc_send+0x20>
		} else {			
			panic("ipc_send():%e", r);
  800e67:	50                   	push   %eax
  800e68:	68 2f 14 80 00       	push   $0x80142f
  800e6d:	6a 41                	push   $0x41
  800e6f:	68 3d 14 80 00       	push   $0x80143d
  800e74:	e8 4b 00 00 00       	call   800ec4 <_panic>
		}
	}
}
  800e79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e7c:	5b                   	pop    %ebx
  800e7d:	5e                   	pop    %esi
  800e7e:	5f                   	pop    %edi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  800e81:	f3 0f 1e fb          	endbr32 
  800e85:	55                   	push   %ebp
  800e86:	89 e5                	mov    %esp,%ebp
  800e88:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  800e8b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  800e90:	69 d0 84 00 00 00    	imul   $0x84,%eax,%edx
  800e96:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  800e9c:	8b 52 50             	mov    0x50(%edx),%edx
  800e9f:	39 ca                	cmp    %ecx,%edx
  800ea1:	74 11                	je     800eb4 <ipc_find_env+0x33>
	for (i = 0; i < NENV; i++)
  800ea3:	83 c0 01             	add    $0x1,%eax
  800ea6:	3d 00 04 00 00       	cmp    $0x400,%eax
  800eab:	75 e3                	jne    800e90 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  800ead:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb2:	eb 0e                	jmp    800ec2 <ipc_find_env+0x41>
			return envs[i].env_id;
  800eb4:	69 c0 84 00 00 00    	imul   $0x84,%eax,%eax
  800eba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ebf:	8b 40 48             	mov    0x48(%eax),%eax
}
  800ec2:	5d                   	pop    %ebp
  800ec3:	c3                   	ret    

00800ec4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ec4:	f3 0f 1e fb          	endbr32 
  800ec8:	55                   	push   %ebp
  800ec9:	89 e5                	mov    %esp,%ebp
  800ecb:	56                   	push   %esi
  800ecc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ecd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ed0:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800ed6:	e8 d0 fc ff ff       	call   800bab <sys_getenvid>
  800edb:	83 ec 0c             	sub    $0xc,%esp
  800ede:	ff 75 0c             	pushl  0xc(%ebp)
  800ee1:	ff 75 08             	pushl  0x8(%ebp)
  800ee4:	56                   	push   %esi
  800ee5:	50                   	push   %eax
  800ee6:	68 48 14 80 00       	push   $0x801448
  800eeb:	e8 b5 f2 ff ff       	call   8001a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800ef0:	83 c4 18             	add    $0x18,%esp
  800ef3:	53                   	push   %ebx
  800ef4:	ff 75 10             	pushl  0x10(%ebp)
  800ef7:	e8 54 f2 ff ff       	call   800150 <vcprintf>
	cprintf("\n");
  800efc:	c7 04 24 8f 11 80 00 	movl   $0x80118f,(%esp)
  800f03:	e8 9d f2 ff ff       	call   8001a5 <cprintf>
  800f08:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800f0b:	cc                   	int3   
  800f0c:	eb fd                	jmp    800f0b <_panic+0x47>
  800f0e:	66 90                	xchg   %ax,%ax

00800f10 <__udivdi3>:
  800f10:	f3 0f 1e fb          	endbr32 
  800f14:	55                   	push   %ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 1c             	sub    $0x1c,%esp
  800f1b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800f1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800f23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800f27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800f2b:	85 d2                	test   %edx,%edx
  800f2d:	75 19                	jne    800f48 <__udivdi3+0x38>
  800f2f:	39 f3                	cmp    %esi,%ebx
  800f31:	76 4d                	jbe    800f80 <__udivdi3+0x70>
  800f33:	31 ff                	xor    %edi,%edi
  800f35:	89 e8                	mov    %ebp,%eax
  800f37:	89 f2                	mov    %esi,%edx
  800f39:	f7 f3                	div    %ebx
  800f3b:	89 fa                	mov    %edi,%edx
  800f3d:	83 c4 1c             	add    $0x1c,%esp
  800f40:	5b                   	pop    %ebx
  800f41:	5e                   	pop    %esi
  800f42:	5f                   	pop    %edi
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    
  800f45:	8d 76 00             	lea    0x0(%esi),%esi
  800f48:	39 f2                	cmp    %esi,%edx
  800f4a:	76 14                	jbe    800f60 <__udivdi3+0x50>
  800f4c:	31 ff                	xor    %edi,%edi
  800f4e:	31 c0                	xor    %eax,%eax
  800f50:	89 fa                	mov    %edi,%edx
  800f52:	83 c4 1c             	add    $0x1c,%esp
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    
  800f5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f60:	0f bd fa             	bsr    %edx,%edi
  800f63:	83 f7 1f             	xor    $0x1f,%edi
  800f66:	75 48                	jne    800fb0 <__udivdi3+0xa0>
  800f68:	39 f2                	cmp    %esi,%edx
  800f6a:	72 06                	jb     800f72 <__udivdi3+0x62>
  800f6c:	31 c0                	xor    %eax,%eax
  800f6e:	39 eb                	cmp    %ebp,%ebx
  800f70:	77 de                	ja     800f50 <__udivdi3+0x40>
  800f72:	b8 01 00 00 00       	mov    $0x1,%eax
  800f77:	eb d7                	jmp    800f50 <__udivdi3+0x40>
  800f79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f80:	89 d9                	mov    %ebx,%ecx
  800f82:	85 db                	test   %ebx,%ebx
  800f84:	75 0b                	jne    800f91 <__udivdi3+0x81>
  800f86:	b8 01 00 00 00       	mov    $0x1,%eax
  800f8b:	31 d2                	xor    %edx,%edx
  800f8d:	f7 f3                	div    %ebx
  800f8f:	89 c1                	mov    %eax,%ecx
  800f91:	31 d2                	xor    %edx,%edx
  800f93:	89 f0                	mov    %esi,%eax
  800f95:	f7 f1                	div    %ecx
  800f97:	89 c6                	mov    %eax,%esi
  800f99:	89 e8                	mov    %ebp,%eax
  800f9b:	89 f7                	mov    %esi,%edi
  800f9d:	f7 f1                	div    %ecx
  800f9f:	89 fa                	mov    %edi,%edx
  800fa1:	83 c4 1c             	add    $0x1c,%esp
  800fa4:	5b                   	pop    %ebx
  800fa5:	5e                   	pop    %esi
  800fa6:	5f                   	pop    %edi
  800fa7:	5d                   	pop    %ebp
  800fa8:	c3                   	ret    
  800fa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800fb0:	89 f9                	mov    %edi,%ecx
  800fb2:	b8 20 00 00 00       	mov    $0x20,%eax
  800fb7:	29 f8                	sub    %edi,%eax
  800fb9:	d3 e2                	shl    %cl,%edx
  800fbb:	89 54 24 08          	mov    %edx,0x8(%esp)
  800fbf:	89 c1                	mov    %eax,%ecx
  800fc1:	89 da                	mov    %ebx,%edx
  800fc3:	d3 ea                	shr    %cl,%edx
  800fc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800fc9:	09 d1                	or     %edx,%ecx
  800fcb:	89 f2                	mov    %esi,%edx
  800fcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800fd1:	89 f9                	mov    %edi,%ecx
  800fd3:	d3 e3                	shl    %cl,%ebx
  800fd5:	89 c1                	mov    %eax,%ecx
  800fd7:	d3 ea                	shr    %cl,%edx
  800fd9:	89 f9                	mov    %edi,%ecx
  800fdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800fdf:	89 eb                	mov    %ebp,%ebx
  800fe1:	d3 e6                	shl    %cl,%esi
  800fe3:	89 c1                	mov    %eax,%ecx
  800fe5:	d3 eb                	shr    %cl,%ebx
  800fe7:	09 de                	or     %ebx,%esi
  800fe9:	89 f0                	mov    %esi,%eax
  800feb:	f7 74 24 08          	divl   0x8(%esp)
  800fef:	89 d6                	mov    %edx,%esi
  800ff1:	89 c3                	mov    %eax,%ebx
  800ff3:	f7 64 24 0c          	mull   0xc(%esp)
  800ff7:	39 d6                	cmp    %edx,%esi
  800ff9:	72 15                	jb     801010 <__udivdi3+0x100>
  800ffb:	89 f9                	mov    %edi,%ecx
  800ffd:	d3 e5                	shl    %cl,%ebp
  800fff:	39 c5                	cmp    %eax,%ebp
  801001:	73 04                	jae    801007 <__udivdi3+0xf7>
  801003:	39 d6                	cmp    %edx,%esi
  801005:	74 09                	je     801010 <__udivdi3+0x100>
  801007:	89 d8                	mov    %ebx,%eax
  801009:	31 ff                	xor    %edi,%edi
  80100b:	e9 40 ff ff ff       	jmp    800f50 <__udivdi3+0x40>
  801010:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801013:	31 ff                	xor    %edi,%edi
  801015:	e9 36 ff ff ff       	jmp    800f50 <__udivdi3+0x40>
  80101a:	66 90                	xchg   %ax,%ax
  80101c:	66 90                	xchg   %ax,%ax
  80101e:	66 90                	xchg   %ax,%ax

00801020 <__umoddi3>:
  801020:	f3 0f 1e fb          	endbr32 
  801024:	55                   	push   %ebp
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	83 ec 1c             	sub    $0x1c,%esp
  80102b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80102f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801033:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801037:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80103b:	85 c0                	test   %eax,%eax
  80103d:	75 19                	jne    801058 <__umoddi3+0x38>
  80103f:	39 df                	cmp    %ebx,%edi
  801041:	76 5d                	jbe    8010a0 <__umoddi3+0x80>
  801043:	89 f0                	mov    %esi,%eax
  801045:	89 da                	mov    %ebx,%edx
  801047:	f7 f7                	div    %edi
  801049:	89 d0                	mov    %edx,%eax
  80104b:	31 d2                	xor    %edx,%edx
  80104d:	83 c4 1c             	add    $0x1c,%esp
  801050:	5b                   	pop    %ebx
  801051:	5e                   	pop    %esi
  801052:	5f                   	pop    %edi
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    
  801055:	8d 76 00             	lea    0x0(%esi),%esi
  801058:	89 f2                	mov    %esi,%edx
  80105a:	39 d8                	cmp    %ebx,%eax
  80105c:	76 12                	jbe    801070 <__umoddi3+0x50>
  80105e:	89 f0                	mov    %esi,%eax
  801060:	89 da                	mov    %ebx,%edx
  801062:	83 c4 1c             	add    $0x1c,%esp
  801065:	5b                   	pop    %ebx
  801066:	5e                   	pop    %esi
  801067:	5f                   	pop    %edi
  801068:	5d                   	pop    %ebp
  801069:	c3                   	ret    
  80106a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801070:	0f bd e8             	bsr    %eax,%ebp
  801073:	83 f5 1f             	xor    $0x1f,%ebp
  801076:	75 50                	jne    8010c8 <__umoddi3+0xa8>
  801078:	39 d8                	cmp    %ebx,%eax
  80107a:	0f 82 e0 00 00 00    	jb     801160 <__umoddi3+0x140>
  801080:	89 d9                	mov    %ebx,%ecx
  801082:	39 f7                	cmp    %esi,%edi
  801084:	0f 86 d6 00 00 00    	jbe    801160 <__umoddi3+0x140>
  80108a:	89 d0                	mov    %edx,%eax
  80108c:	89 ca                	mov    %ecx,%edx
  80108e:	83 c4 1c             	add    $0x1c,%esp
  801091:	5b                   	pop    %ebx
  801092:	5e                   	pop    %esi
  801093:	5f                   	pop    %edi
  801094:	5d                   	pop    %ebp
  801095:	c3                   	ret    
  801096:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80109d:	8d 76 00             	lea    0x0(%esi),%esi
  8010a0:	89 fd                	mov    %edi,%ebp
  8010a2:	85 ff                	test   %edi,%edi
  8010a4:	75 0b                	jne    8010b1 <__umoddi3+0x91>
  8010a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8010ab:	31 d2                	xor    %edx,%edx
  8010ad:	f7 f7                	div    %edi
  8010af:	89 c5                	mov    %eax,%ebp
  8010b1:	89 d8                	mov    %ebx,%eax
  8010b3:	31 d2                	xor    %edx,%edx
  8010b5:	f7 f5                	div    %ebp
  8010b7:	89 f0                	mov    %esi,%eax
  8010b9:	f7 f5                	div    %ebp
  8010bb:	89 d0                	mov    %edx,%eax
  8010bd:	31 d2                	xor    %edx,%edx
  8010bf:	eb 8c                	jmp    80104d <__umoddi3+0x2d>
  8010c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8010c8:	89 e9                	mov    %ebp,%ecx
  8010ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8010cf:	29 ea                	sub    %ebp,%edx
  8010d1:	d3 e0                	shl    %cl,%eax
  8010d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8010d7:	89 d1                	mov    %edx,%ecx
  8010d9:	89 f8                	mov    %edi,%eax
  8010db:	d3 e8                	shr    %cl,%eax
  8010dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8010e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8010e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8010e9:	09 c1                	or     %eax,%ecx
  8010eb:	89 d8                	mov    %ebx,%eax
  8010ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8010f1:	89 e9                	mov    %ebp,%ecx
  8010f3:	d3 e7                	shl    %cl,%edi
  8010f5:	89 d1                	mov    %edx,%ecx
  8010f7:	d3 e8                	shr    %cl,%eax
  8010f9:	89 e9                	mov    %ebp,%ecx
  8010fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8010ff:	d3 e3                	shl    %cl,%ebx
  801101:	89 c7                	mov    %eax,%edi
  801103:	89 d1                	mov    %edx,%ecx
  801105:	89 f0                	mov    %esi,%eax
  801107:	d3 e8                	shr    %cl,%eax
  801109:	89 e9                	mov    %ebp,%ecx
  80110b:	89 fa                	mov    %edi,%edx
  80110d:	d3 e6                	shl    %cl,%esi
  80110f:	09 d8                	or     %ebx,%eax
  801111:	f7 74 24 08          	divl   0x8(%esp)
  801115:	89 d1                	mov    %edx,%ecx
  801117:	89 f3                	mov    %esi,%ebx
  801119:	f7 64 24 0c          	mull   0xc(%esp)
  80111d:	89 c6                	mov    %eax,%esi
  80111f:	89 d7                	mov    %edx,%edi
  801121:	39 d1                	cmp    %edx,%ecx
  801123:	72 06                	jb     80112b <__umoddi3+0x10b>
  801125:	75 10                	jne    801137 <__umoddi3+0x117>
  801127:	39 c3                	cmp    %eax,%ebx
  801129:	73 0c                	jae    801137 <__umoddi3+0x117>
  80112b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80112f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801133:	89 d7                	mov    %edx,%edi
  801135:	89 c6                	mov    %eax,%esi
  801137:	89 ca                	mov    %ecx,%edx
  801139:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80113e:	29 f3                	sub    %esi,%ebx
  801140:	19 fa                	sbb    %edi,%edx
  801142:	89 d0                	mov    %edx,%eax
  801144:	d3 e0                	shl    %cl,%eax
  801146:	89 e9                	mov    %ebp,%ecx
  801148:	d3 eb                	shr    %cl,%ebx
  80114a:	d3 ea                	shr    %cl,%edx
  80114c:	09 d8                	or     %ebx,%eax
  80114e:	83 c4 1c             	add    $0x1c,%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    
  801156:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80115d:	8d 76 00             	lea    0x0(%esi),%esi
  801160:	29 fe                	sub    %edi,%esi
  801162:	19 c3                	sbb    %eax,%ebx
  801164:	89 f2                	mov    %esi,%edx
  801166:	89 d9                	mov    %ebx,%ecx
  801168:	e9 1d ff ff ff       	jmp    80108a <__umoddi3+0x6a>
